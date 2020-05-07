xquery version "3.0";
(:~
This is a component file of the VdU Software for a Virtual Research Environment for the handling of Medieval charters.

As the source code is available here, it is somewhere between an alpha- and a beta-release, may be changed without any consideration of backward compatibility of other parts of the system, therefore, without any notice.

This file is part of the VdU Virtual Research Environment Toolkit (VdU/VRET).

The VdU/VRET is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

VdU/VRET is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with VdU/VRET.  If not, see <http://www.gnu.org/licenses/>.

We expect VdU/VRET to be distributed in the future with a license more lenient towards the inclusion of components into other systems, once it leaves the active development stage.
:)

module namespace revision="http://www.monasterium.net/NS/revision";

declare namespace xrx="http://www.monasterium.net/NS/xrx";

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../xrx/conf.xqm";
import module namespace template="http://www.monasterium.net/NS/template"
    at "../xrx/template.xqm";
import module namespace data="http://www.monasterium.net/NS/data"
    at "../data/data.xqm";
import module namespace atom="http://www.w3.org/2005/Atom"
    at "../data/atom.xqm";
import module namespace upd="http://www.monasterium.net/NS/upd"
    at "../xrx/upd.xqm";
        
declare variable $revision:atom-template := template:get('tag:www.monasterium.net,2011:/core/template/revision');

declare function revision:atomid($atomid as xs:string, 
                                 $metadata-scope as xs:string, 
                                 $revisionnum as xs:integer) as xs:string {

    concat($atomid, '/', $metadata-scope, '/', xs:string($revisionnum))
};

declare function revision:objectid($atomid as xs:string) as xs:string {

    (tokenize($atomid, '/'))[last() - 2]
};

(:
  move a Atom entry from public to private
  or to draft scope
  
  a) get the public entry and insert revision info
  b) archive the updated entry
  c) save it into the public scope again
  d) move the entry to the private/draft scope
  e) save it into the public space again
:)
declare function revision:start($atomid as xs:string,
                                $metadata-scope as xs:string) as element() {

    (: extract metadata object infos from atom id :)
    let $object-type := data:object-type($atomid, <xrx:metadata/>)
    let $object-uri-tokens := data:uri-tokens($atomid, <xrx:metadata/>)
    let $objectid := data:objectid($atomid, <xrx:metadata/>)

    (: get public entry :)
    let $entry-base-collection-path := 
        data:base-collection-path(
            $object-type,
            $object-uri-tokens,
            'public',
            false(),
            <xrx:metadata/>
        )
 
    let $entry := data:entry($entry-base-collection-path, $atomid)

    (: insert revisioninfo :)
    let $revisioninfo := revision:composeinfo($atomid, 'public', 'start', '')
    let $insert-revisioninfo := revision:insertinfo($entry, $revisioninfo)
    
    (: archive the public entry :)
    let $archive := revision:archive($atomid, 'public')
    
    (: save it again into the public scope :)
    let $entryname := util:document-name($entry)
    let $feed := 
        data:feed($object-type, $object-uri-tokens, 'public', false(), <xrx:metadata/>)    
    let $post := 
        atom:POSTSILENT($feed, $entryname, $insert-revisioninfo)
    
    (: move to private or draft scope :)
    let $move := revision:move($atomid, 'public', $metadata-scope)
    
    (: save again :)
    let $post2 := 
        atom:POSTSILENT($feed, $entryname, $insert-revisioninfo)
    
    return
    
    $insert-revisioninfo
};

(:
    move a Atom entry from draft to private
    or from private to draft scope
    
    a) get the source entry and insert revisioninfo
    b) save the source entry
    c) move the revision entry to the destination scope
    d) save the entry again to archive
    e) archive the entry from source scope
:)
declare function revision:suggest($atomid as xs:string,
                                  $metadata-scope-from as xs:string,
                                  $metadata-scope-to as xs:string,
                                  $comment as xs:string?) as element() {

    (: extract metadata object infos from atom id :)
    let $object-type := data:object-type($atomid, <xrx:metadata/>)
    let $object-uri-tokens := data:uri-tokens($atomid, <xrx:metadata/>)
    let $objectid := data:objectid($atomid, <xrx:metadata/>)

    (: get the source entry :)
    let $source-entry-base-collection-path := 
        data:base-collection-path(
            $object-type,
            $object-uri-tokens,
            $metadata-scope-from,
            false(),
            <xrx:metadata/>
        )
 
    let $source-entry := data:entry($source-entry-base-collection-path, $atomid)
    let $source-entryname := util:document-name($source-entry)
    let $revision-who := xs:string($source-entry/xrx:revision/xrx:who/text())
    
    (: insert revisioninfo :)
    let $revisioninfo := revision:composeinfo($atomid, $metadata-scope-from, 'suggest', $comment)
    let $insert-revisioninfo := revision:insertinfo($source-entry, $revisioninfo)
    
    (: save source entry :) 
    let $source-feed := 
        data:feed($object-type, $object-uri-tokens, $metadata-scope-from, false(), <xrx:metadata/>)    
    let $put-source-entry := 
        atom:PUTSILENT($source-feed, $source-entryname, $insert-revisioninfo)

    (: move entry from source to destination scope :)
    (: do we send it back to the private space of a user? :)
    let $destination-metadata-scope := 
        if($metadata-scope-to = 'private') then
            concat($metadata-scope-to, ':', $revision-who)
        else $metadata-scope-to
    let $move := 
        revision:move($atomid, $metadata-scope-from, $destination-metadata-scope)

    (: save entry again :)
    let $put-source-entry2 := 
        atom:PUTSILENT($source-feed, $source-entryname, $insert-revisioninfo)

    (: archive source entry :)
    let $archive := revision:archive($atomid, $metadata-scope-from)

    return
    
    $archive
};

(:
    reject a revision
    
    a) get the revision entry
    b) insert revisioninfo into entry
    c) save the updated entry
    d) archive the entry
:)
declare function revision:reject($atomid as xs:string, 
                                 $metadata-scope as xs:string,
                                 $comment) as element() {

    (: extract metadata object infos from atom id :)
    let $object-type := data:object-type($atomid, <xrx:metadata/>)
    let $object-uri-tokens := data:uri-tokens($atomid, <xrx:metadata/>)
    let $objectid := data:objectid($atomid, <xrx:metadata/>)

    (: get the source entry :)
    let $entry-base-collection-path := 
        data:base-collection-path(
            $object-type,
            $object-uri-tokens,
            $metadata-scope,
            false(),
            <xrx:metadata/>
        )
 
    let $entry := data:entry($entry-base-collection-path, $atomid)
    
    (: insert revisioninfo :)
    let $revisioninfo := revision:composeinfo($atomid, $metadata-scope, 'reject', $comment)
    let $insert-revisioninfo := revision:insertinfo($entry, $revisioninfo)
    
    (: save entry :) 
    let $feed := 
        data:feed($object-type, $object-uri-tokens, $metadata-scope, false(), <xrx:metadata/>) 
    let $entryname := util:document-name($entry)   
    let $put-source-entry := 
        atom:PUTSILENT($feed, $entryname, $insert-revisioninfo)
    
    (: archive entry :)
    let $archive := revision:archive($atomid, $metadata-scope)
    
    return
    
    $insert-revisioninfo
};

(:
    move a Atom entry from draft [or private] 
    to public scope
    
    a) archive the entry of the public scope
    b) get draft/private entry and insert revision info
    c) save the updated draft/private entry
    d) move the draft/private entry to public scope 
    e) save draft/private entry again
    f) archive the entry of the draft/private scope
:)
declare function revision:publish($atomid as xs:string, 
                                  $metadata-scope-from as xs:string) {

    (: extract metadata object infos from atom id :)
    let $object-type := data:object-type($atomid, <xrx:metadata/>)
    let $object-uri-tokens := data:uri-tokens($atomid, <xrx:metadata/>)
    let $objectid := data:objectid($atomid, <xrx:metadata/>)

    (: get the draft/private entry :)
    let $entry-base-collection-path := 
        data:base-collection-path(
            $object-type,
            $object-uri-tokens,
            $metadata-scope-from,
            false(),
            <xrx:metadata/>
        )
 
    let $entry := collection($entry-base-collection-path)//atom:id[.=$atomid]/parent::atom:entry
    let $entryname := util:document-name($entry)
    (:let $entry := data:entry($entry-base-collection-path, $atomid):)

    (: insert revisioninfo :)
    let $revisioninfo := revision:composeinfo($atomid, $metadata-scope-from, 'publish', '')
    let $insert-revisioninfo := revision:insertinfo($entry, $revisioninfo)
        
    (: archive the public entry :)
    let $archive-public-revision := revision:archive($atomid, 'public')

    (: save draft/private entry :)
    let $feed :=
        data:feed(
            $object-type,
            $object-uri-tokens,
            $metadata-scope-from, 
            false(),
            <xrx:metadata/>
        )
    let $post := 
        atom:POSTSILENT($feed, $entryname, $insert-revisioninfo)

    (: move the entry :)
    let $move-entry := revision:move($atomid, $metadata-scope-from, 'public')

    (: save draft/private entry again :)
    let $post2 := 
        atom:POSTSILENT($feed, $entryname, $insert-revisioninfo)

    (: archive the draft/private entry :)
    let $archive-revision := revision:archive($atomid, $metadata-scope-from)

    return
    
    $post
};

(:
  ID related functions
:)
declare function revision:nextnum($base-collection as node()*) as xs:integer {

    count($base-collection/atom:entry)
};

declare function revision:lastnum($base-collection as node()*) as xs:integer {

    count($base-collection/atom:entry) - 1
};

declare function revision:object-type($revision-atomid as xs:string) as xs:string {

    data:object-type($revision-atomid, <xrx:revision/>)
};

declare function revision:uri-tokens($revision-atomid as xs:string) as xs:string {

    data:uri-tokens($revision-atomid, <xrx:revision/>)
};

declare function revision:metadata-scope($revision-atomid as xs:string) as xs:string {

    (tokenize($revision-atomid, '/'))[last() - 1]
};

declare function revision:num($revision-atomid as xs:string) as xs:string {

    (tokenize($revision-atomid, '/'))[last()]
};

(:
  entry related functions
:)
declare function revision:entry($revision-atomid as xs:string,
                                $revision-who as xs:string?) as element(){

    (: not yet finished! :)
    (: extract metadata object infos from atom id :)
    let $metadata-scope := revision:metadata-scope($revision-atomid)
    let $revisionnum := revision:num($revision-atomid)
    let $object-type := revision:object-type($revision-atomid)
    let $object-uri-tokens := revision:uri-tokens($revision-atomid)
    let $objectid := revision:objectid($revision-atomid)
    
    (: return the entry depending on the metadata scope :)
    return
    if($metadata-scope = 'private') then
        let $base-collection-path := 
            data:uri(
                concat(
                    conf:param('xrx-user-db-base-uri'),
                    $revision-who,
                    '/metadata.',
                    $object-type,
                    '.revision/',
                    string-join(
                        $object-uri-tokens,
                        '/'
                    )
                )
            )
        let $base-collection :=
            collection($base-collection-path)
        return
        $base-collection//atom:id[.=$revision-atomid]/parent::atom:entry
    else if($metadata-scope = 'draft') then
        let $base-collection := 
            revision:base-collection($object-type, $object-uri-tokens, $objectid, $metadata-scope)
        return
        $base-collection//atom:id[.=$revision-atomid]/parent::atom:entry
    else()
};

(:
  entry related functions
:)
declare function revision:lastentry($atomid as xs:string, 
                                    $metadata-scope as xs:string) {
    
    (: extract metadata object infos from atom id :)
    let $object-type := data:object-type($atomid, <xrx:metadata/>)
    let $object-uri-tokens := data:uri-tokens($atomid, <xrx:metadata/>)
    let $objectid := data:objectid($atomid, <xrx:metadata/>)

    let $optimized-metadata-scope := 
        if(starts-with($metadata-scope, 'private:')) then 'private' else $metadata-scope
    
    let $base-collection :=
        revision:base-collection($object-type, $object-uri-tokens, $objectid, $metadata-scope)
    let $lastrevision-num :=
        revision:lastnum($base-collection)
    let $lastrevision-atomid :=
        revision:atomid($atomid, $optimized-metadata-scope, $lastrevision-num)
    let $lastrevision :=
        $base-collection//atom:id[.=$lastrevision-atomid]/parent::atom:entry    
    
    return
    
    $lastrevision
};

declare function revision:entryname($object-type as xs:string, 
                                    $objectid as xs:string, 
                                    $revisionnum as xs:integer) as xs:string {

    xmldb:encode(
        xmldb:decode(
            concat(
                $objectid,
                '.',
                $object-type,
                '.revision.',
                xs:string($revisionnum),
                '.xml'
            )
        )
    )
};

(:
  feed related functions
:)
declare function revision:feed($object-type as xs:string,
                               $metadata-scope as xs:string) as xs:string {

    data:feed($object-type, $metadata-scope, true(), <xrx:metadata/>)
};

declare function revision:feed($object-type as xs:string, 
                               $object-uri-tokens as xs:string*, 
                               $objectid as xs:string, 
                               $metadata-scope as xs:string) as xs:string {

    data:feed($object-type, ($object-uri-tokens, $objectid), $metadata-scope, true(), <xrx:metadata/>)
};

(:
  collection related functions
:)
declare function revision:base-collection($object-type as xs:string,
                                          $object-uri-tokens as xs:string*,
                                          $objectid as xs:string,
                                          $metadata-scope as xs:string) as node()* {
                                             
    collection(
        revision:base-collection-path(
            $object-type,
            $object-uri-tokens,
            $objectid,
            $metadata-scope
        )
    )
};

declare function revision:base-collection-path($object-type as xs:string, 
                                               $object-uri-tokens as xs:string*,
                                               $objectid as xs:string,
                                               $metadata-scope as xs:string) as xs:string {
    
    data:base-collection-path(
        $object-type,
        ($object-uri-tokens, $objectid),
        $metadata-scope,
        true(),
        <xrx:metadata/>
    )                                                            
};

(:
    only for internal usage
:)
declare function revision:archive($atomid as xs:string,
                                  $metadata-scope as xs:string) {

    (: extract metadata object infos from atom id :)
    let $object-type := data:object-type($atomid, <xrx:metadata/>)
    let $object-uri-tokens := data:uri-tokens($atomid, <xrx:metadata/>)
    let $objectid := data:objectid($atomid, <xrx:metadata/>)

    (: get the entry :)
    let $entry-base-collection-path := 
        data:base-collection-path(
            $object-type,
            $object-uri-tokens,
            $metadata-scope,
            false(),
            <xrx:metadata/>
        )

    let $entry := collection($entry-base-collection-path)//atom:id[.=$atomid]/parent::atom:entry
    (:let $entry := data:entry($entry-base-collection-path, $atomid):)

    let $entryname := util:document-name($entry)

    (: prepare the revision entry :)

    (: get revision infos :)
    let $revision-base-collection := 
        revision:base-collection(
            $object-type, 
            $object-uri-tokens,
            $objectid,
            $metadata-scope
        )
    let $revisionnum := revision:nextnum($revision-base-collection)
    let $revisionid := revision:atomid($atomid, $metadata-scope, $revisionnum)
    (: insert the new Atom ID into the current entry :)
    let $revision-entry := 
        upd:replace-element-content(
            $entry/atom:id,
            text{ $revisionid }
        )
    (: revision feed :)
    let $revisionfeed := 
        revision:feed(
            $object-type,
            $object-uri-tokens,
            $objectid,
            $metadata-scope
        )
    (: revision entry name :)
    let $revision-entryname := revision:entryname($object-type, $objectid, $revisionnum)
    
    (: store the revision entry and delete the entry:)
    let $store := atom:POSTSILENT($revisionfeed, $revision-entryname, $revision-entry)
    let $remove := xmldb:remove($entry-base-collection-path, $entryname)

    return
    
    $revision-entry
};

declare function revision:move($atomid as xs:string, 
                               $metadata-scope-from as xs:string, 
                               $metadata-scope-to as xs:string) {

    (: extract metadata object infos from atom id :)
    let $object-type := data:object-type($atomid, <xrx:metadata/>)
    let $object-uri-tokens := data:uri-tokens($atomid, <xrx:metadata/>)
    let $objectid := data:objectid($atomid, <xrx:metadata/>)

    (: source info :)
    let $source-base-collection-path := 
        data:base-collection-path(
            $object-type,
            $object-uri-tokens,
            $metadata-scope-from,
            false(),
            <xrx:metadata/>
        )
    
    (: entry to be moved and entry info :)
    let $entry := data:entry($source-base-collection-path, $atomid)
    let $entryname := util:document-name($entry)

    (: destination info :)
    let $destination-feed := 
        data:feed(
            $object-type,
            $object-uri-tokens,
            $metadata-scope-to, 
            false(), 
            <xrx:metadata/>
        )

    (: store the entry into the destination collection :)
    let $store := atom:POSTSILENT($destination-feed, $entryname, $entry)
    (: remove the entry from the source collection :)
    let $remove := xmldb:remove($source-base-collection-path, $entryname)
    
    return
    
    $entry
};

(:
    revision info functions
:)
declare function revision:insertinfo($entry as element(atom:entry), 
                                     $revisioninfo as element(xrx:revision)) as element() {
    let $xslt :=
        <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
            xmlns:atom="http://www.w3.org/2005/Atom"
            xmlns:xrx="http://www.monasterium.net/NS/xrx" 
            version="1.0">
            <xsl:template match="xrx:revision"/>
            <xsl:template match="atom:content">
              { $revisioninfo }
              <xsl:copy-of select="."/>
            </xsl:template>
            <xsl:template match="@*|*" priority="-2">
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()" />
                </xsl:copy>
            </xsl:template>
        </xsl:stylesheet>
    return
    transform:transform($entry, $xslt, ())                                 
};

declare function revision:removeinfo($entry as element(atom:entry)) as element() {

    let $xslt :=
        <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
            xmlns:xrx="http://www.monasterium.net/NS/xrx" 
            version="1.0">
            <xsl:template match="xrx:revision"/>
            <xsl:template match="@*|*" priority="-2">
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()" />
                </xsl:copy>
            </xsl:template>
        </xsl:stylesheet>
    return
    transform:transform($entry, $xslt, ()) 
};

declare function revision:composeinfo($atomid as xs:string, 
                                      $metadata-scope as xs:string,
                                      $operation as xs:string,
                                      $comment as xs:string?) as element() {

    (: extract metadata object infos from atom id :)
    let $object-type := data:object-type($atomid, <xrx:metadata/>)
    let $object-uri-tokens := data:uri-tokens($atomid, <xrx:metadata/>)
    let $objectid := data:objectid($atomid, <xrx:metadata/>)
    
    (: compose revision Atom ID :)
    let $base-collection := 
        revision:base-collection(
            $object-type, 
            $object-uri-tokens,
            $objectid,
            $metadata-scope
        )
    let $num := revision:nextnum($base-collection)
    let $revision-atomid := revision:atomid($atomid, $metadata-scope, $num)
    
    return
    <xrx:revision>
        <xrx:id>{ $revision-atomid }</xrx:id>
        <xrx:who>{ sm:id()//sm:username/text() }</xrx:who>
        <xrx:when>{ current-dateTime() }</xrx:when>
        <xrx:operation>{ $operation }</xrx:operation>
        <xrx:comment>{ $comment }</xrx:comment>
    </xrx:revision>
};
