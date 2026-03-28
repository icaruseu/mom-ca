xquery version "3.1";

(:~
 : REPAIR SCRIPT: Migrate legacy saved charters to new locking system.
 :
 : The old MOM-CA stored "saved" (locked) charters in the user's community XML:
 :   <xrx:saved_list>
 :     <xrx:saved>
 :       <xrx:id>tag:www.monasterium.net,2011:/charter/AT-StiAA/Urkunden/1291_IV_21</xrx:id>
 :       <xrx:start_time>2019-04-18T09:56:50.911Z</xrx:start_time>
 :       <xrx:freigabe>no</xrx:freigabe>
 :     </xrx:saved>
 :   </xrx:saved_list>
 :
 : This script:
 : 1. Finds all users with saved_list entries
 : 2. For each saved charter, creates a lock file in /db/mom-data/charter-locks/
 : 3. For private copies in metadata.charter that match (by idno or charter-key),
 :    sets the @sameAs attribute pointing to the original public charter
 :
 : Run in eXide: http://localhost:8080/exist/apps/eXide/
 : Or upload and execute via REST.
 :)

declare namespace xrx = "http://www.monasterium.net/NS/xrx";
declare namespace atom = "http://www.w3.org/2005/Atom";
declare namespace cei = "http://www.monasterium.net/NS/cei";

(: Ensure charter-locks collection exists :)
let $lock-path := '/db/mom-data/charter-locks'
let $_ := if (not(xmldb:collection-available($lock-path))) then
    xmldb:create-collection('/db/mom-data', 'charter-locks') else ()

(: Process each user :)
let $users := xmldb:get-child-collections('/db/mom-data/xrx.user')

let $results :=
    for $u in $users
    let $u-path := '/db/mom-data/xrx.user/' || $u
    let $resources := xmldb:get-child-resources($u-path)

    (: Find community.xml files with saved_list :)
    for $r in $resources
    where ends-with($r, '.community.xml') or ends-with($r, '.xml')
    let $doc := try { doc($u-path || '/' || $r) } catch * { () }
    where exists($doc//xrx:saved_list/xrx:saved)

    let $username := xmldb:decode($u)

    for $saved in $doc//xrx:saved_list/xrx:saved
    let $charter-id := normalize-space($saved/xrx:id)
    let $save-date := normalize-space($saved/xrx:start_time)
    let $freigabe := normalize-space($saved/xrx:freigabe)

    where $charter-id ne ''

    (: Check if lock already exists :)
    let $lock-filename := xmldb:encode($charter-id) || '.xml'
    let $lock-exists := util:binary-doc-available($lock-path || '/' || $lock-filename)
        or doc-available($lock-path || '/' || $lock-filename)

    return
        if ($lock-exists) then
            <skipped user="{$username}" charter="{$charter-id}" reason="lock already exists"/>
        else
            (: Find if user has a private copy of this charter :)
            let $charter-base := $u-path || '/metadata.charter'
            let $private-copy :=
                if (xmldb:collection-available($charter-base)) then
                    let $sub-colls := xmldb:get-child-collections($charter-base)
                    return
                        for $sc in $sub-colls
                        let $sc-path := $charter-base || '/' || $sc
                        (: Match by original charter key in atom:id or by idno :)
                        let $charter-key := tokenize($charter-id, '/')[last()]
                        let $matches := collection($sc-path)/atom:entry[
                            contains(atom:id, $charter-key)
                            or normalize-space((.//cei:body/cei:idno)[1]) = $charter-key
                        ]
                        return $matches[1]
                else ()

            let $private-atom-id := if (exists($private-copy)) then
                string($private-copy[1]/atom:id) else ''

            (: Create lock file :)
            let $lock-xml :=
                <lock xmlns="http://www.monasterium.net/NS/lock">
                    <charter-id>{$charter-id}</charter-id>
                    <user>{$username}</user>
                    <date>{if ($save-date ne '') then $save-date else string(current-dateTime())}</date>
                    <private-id>{$private-atom-id}</private-id>
                </lock>
            let $_ := xmldb:store($lock-path, $lock-filename, $lock-xml)

            (: If there's a private copy, set @sameAs on it :)
            let $_ :=
                if (exists($private-copy) and not($private-copy[1]//cei:text/@sameAs)) then
                    let $cei-text := $private-copy[1]//cei:text[1]
                    return
                        if (exists($cei-text)) then
                            update insert attribute sameAs { $charter-id } into $cei-text
                        else ()
                else ()

            return
                <migrated user="{$username}" charter="{$charter-id}"
                          privateCopy="{exists($private-copy)}"
                          privateId="{$private-atom-id}"
                          freigabe="{$freigabe}"/>

return
<repair-result timestamp="{current-dateTime()}">
    <summary>
        <total-processed>{count($results)}</total-processed>
        <migrated>{count($results[self::migrated])}</migrated>
        <skipped>{count($results[self::skipped])}</skipped>
        <with-private-copy>{count($results[@privateCopy='true'])}</with-private-copy>
    </summary>
    {$results}
</repair-result>
