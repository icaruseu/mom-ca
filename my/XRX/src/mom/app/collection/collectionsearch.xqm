xquery version "3.0";
(:~
This is a component file of the VdU Software for a Virtual Research Environment for the handling of Medieval charters.

As the source code is available here, it is somewhere between an alpha- and a beta-release, may be changed without any consideration of backward compatibility of other parts of the system, theregore, without any notice.

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

module namespace collectionsearch="http://www.monasterium.net/NS/collectionsearch";


declare namespace cei="http://www.monasterium.net/NS/cei";
declare namespace atom="http://www.w3.org/2005/Atom";

import module namespace conf="http://www.monasterium.net/NS/conf";
import module namespace jsonx="http://www.monasterium.net/NS/jsonx";



(: test if the atom:id of the actuel collection is the same as the id of the collection saved in the session variable
if not delete session variables so the user doesn't see results from other register searches:)
declare function collectionsearch:cleanSession($collectionId, $sessionVariable){

    let $cleaned := if($sessionVariable//collectionid/text() != $collectionId) then(

    let $clean_collectionSearchAsJson := session:remove-attribute("_collectionSearchAsJson")
    let $clean_collectionSearchAsXml := session:remove-attribute("_collectionSearchCharters")
        return fn:true())
        else(fn:false())

    return $cleaned
};

(: take all charters in the actual collection with the element <$node_name> check first character of content == $first_charater.
if $first_char == "All" take all Charters.
Save the id of the Charters, <$node_name>-text(), the values of @reg and @key
:)

declare function collectionsearch:createResults($collection, $collection_id, $node_name, $first_character) as node(){


    (:save some search-informations into xml:)
    <search>
        <collectionid>{$collection_id}</collectionid>
        <node_name>{$node_name}</node_name>
        <first_character>{$first_character}</first_character>
        <mode>false</mode>
        <results>
            {
                (:for all charters in collection with the node == $node_name:)
            for $entries in distinct-values($collection//cei:text//*[name()=$node_name]) order by $entries return
                (:When $first_character == "All", don't test if the first character of node/text() == $first_character,
                  save contentn of node and count nodes with same content and save result:)
                if($first_character = "All") then
                    if(string($entries) eq "") then()
                    else(
                        <result>
                            <term>{$entries}</term>
                            <count>{count($collection//cei:text//*[name()=$node_name][. eq $entries])}</count>
                            <charters>
                                {
                                    (: for all nodes with the same content save ids of charters and @key and @reg values. :)
                                    for $entrie in $collection//cei:text//*[name()=$node_name][. eq $entries]
                                    return <charter>
                                        <key>{$entrie/@key/string()}</key>
                                        <reg>{$entrie/@reg/string()}</reg>
                                        <id>{root($entrie)//atom:id/text()}</id>
                                    </charter>
                                }
                            </charters>
                        </result>
                    )
                else(
                    (:same as befor but this time the first character of node/text() must match $first_character:)
                    if(string($entries) eq "") then()
                    else(
                        if(starts-with(upper-case(string($entries)), $first_character) ) then(
                            <result>
                                <term>{string($entries)}</term>
                                <count>{count($collection//cei:text//*[name()=$node_name][. eq $entries])}</count>
                                <charters>
                                    {
                                        for $entrie in $collection//cei:text//*[name()=$node_name][. eq $entries]
                                        return <charter>
                                            <key>{$entrie/@key/string()}</key>
                                            <reg>{$entrie/@reg/string()}</reg>
                                            <id>{root($entrie)//atom:id/text()}</id>

                                        </charter>
                                    }
                                </charters>
                            </result>
                        )
                        else()
                    )
                )
            }
        </results>
    </search>
};

(:
    example for structure of $resultXml see collectionsearch:createResults()
 for all <result>-elements with the childelement <key> with different content in $resultXml create new <result>
:)
declare function collectionsearch:createKeyResultXml($resultXml) as node(){
    <search>
        <collectionid>{$resultXml/collectionid/text()}</collectionid>
        <node_name>{$resultXml/node_name/text()}</node_name>
        <first_character>{$resultXml/first_character/text()}</first_character>
        <mode>{$resultXml//mode/text()}</mode>
        {
            for $key in distinct-values($resultXml//key) order by $key
            return if($key != "") then
                <result>
                    <term>{$key}</term>
                    <charters>
                        {
                            for $charter in $resultXml//charter[key = $key]
                            return <charter>
                                <reg>{$charter/reg/text()}</reg>
                                <content>{$charter/../../term/text()}</content>
                                <id>{$charter/id/text()}</id>
                            </charter>
                        }
                    </charters>
                </result>
            else()
        }
    </search>
};

(:    example for structure of $resultXml see collectionsearch:createResults()
 for all <result>-elements with the childelement <reg> with different content in $resultXml create new <result>
 :)
declare function collectionsearch:createRegResultXml($resultXml)as node(){
   <search>
        <collectionid>{$resultXml/collectionid/text()}</collectionid>
        <node_name>{$resultXml/node_name/text()}</node_name>
        <first_character>{$resultXml/first_character/text()}</first_character>
        <mode>{$resultXml//mode/text()}</mode>
        {
            for $reg in distinct-values($resultXml//reg) order by $reg
            return if($reg != "") then
                <result>
                    <term>{$reg}</term>
                    <charters>
                        {
                            for $charter in $resultXml//charter[reg = $reg]
                            return <charter>
                                <key>{$charter/key/text()}</key>
                                <content>{$charter/../../term/text()}</content>
                                <id>{$charter/id/text()}</id>
                            </charter>
                        }
                    </charters>
                </result>
            else()
        }
    </search>

};
(: for example for $collectionSearch_results look collectionsearch:createResults()
takes all charter id in result with <term>/text() ==$search_term
For all ids get the charters in the actual Collection and save them into new xml with some search informations.
:)
declare function collectionsearch:createCharterResultXml($collection_id, $collection_path, $search_term, $type, $collectionSearch_results) as node(){
    let $atomids :=
        for $result in $collectionSearch_results//result[term/text() = $search_term]
        return $result//charter/id
    return
    <myCollectionSearchCharters>
        <collectionid>{$collection_id}</collectionid>
        <collectionpath>{$collection_path}</collectionpath>
        <searchterm>{$search_term}</searchterm>
        <type>{$type}</type>
        <results>
            {
                if($type = "content") then(
                    if($atomids/../reg != "") then(<regs>{$atomids/../reg}</regs>) else(),
                    if($atomids/../key !="") then(<keys>{$atomids/../key}</keys>)else()
                )

                else if($type = "key") then (
                    if($atomids/../reg !="") then(<regs>{$atomids/../reg}</regs>)else(),
                    if($atomids/../content !="")then(<contents>{$atomids/../content}</contents>)else()
                )
                else if($type = "reg") then(
                        if($atomids/../content !="")then(<contents>{$atomids/../content}</contents>)else(),
                        if($atomids/../key !="") then(<keys>{$atomids/../key}</keys>)else()
                    )
                    else()
            }
            {

                for $id in distinct-values($atomids/text())
                let $tokenized_id := tokenize($id, "/")
                let $filepath := concat($collection_path,"/", $tokenized_id[last()], ".cei.xml")
                let $doc := doc($filepath)

                return if(not(empty($doc))) then $doc else doc(concat($collection_path,"/", $tokenized_id[last()], ".charter.xml"))
            }
        </results>
    </myCollectionSearchCharters>
};


(: creates a json from $resultXml,
   for resultXml exampel see collectionsearch:createResults():)
declare function collectionsearch:createResultJson($resultXml){
    let $resultJson :=
        jsonx:object((
            jsonx:pair(
                    jsonx:string("collection_id"),
                    jsonx:string($resultXml/collectionid/text())
            ),
            jsonx:pair(
                    jsonx:string("node_name"),
                    jsonx:string($resultXml/node_name/text())
            ),
            jsonx:pair(
                    jsonx:string("first_character"),
                    jsonx:string($resultXml/first_character/text())
            ),
            jsonx:pair(
                    jsonx:string("mode"),
                    jsonx:string($resultXml//mode/text())
            ),
            jsonx:pair(
                    jsonx:string("results"),
                    jsonx:array(
                            for $result in $resultXml//result
                            return jsonx:object((
                                jsonx:pair(
                                        jsonx:string("term"),
                                        jsonx:string($result/term)
                                ),
                                jsonx:pair(
                                        jsonx:string("count"),
                                        jsonx:string(if(not(empty($result/count))) then $result/count else(""))
                                ),
                                jsonx:pair(
                                        jsonx:string("charter"),
                                        jsonx:array(
                                                for $charter in $result/charters/charter
                                                return jsonx:object((
                                                    jsonx:pair(
                                                            jsonx:string("key"),
                                                            jsonx:string(if(not(empty($charter/key))) then $charter/key else(""))),
                                                    jsonx:pair(
                                                            jsonx:string("reg"),
                                                            jsonx:string(if(not(empty($charter/reg))) then $charter/reg else(""))),
                                                    jsonx:pair(
                                                            jsonx:string("content"),
                                                            jsonx:string(if(not(empty($charter/content))) then $charter/content else(""))),
                                                    jsonx:pair(
                                                            jsonx:string("id"),
                                                            jsonx:string(if(not(empty($charter/id))) then $charter/id else(""))
                                                    )
                                                ))
                                        )
                                )
                            ))
                    )
            )
        ))




    return $resultJson

};

(:following functions returns content of elements in $searchXml (see collectionsearch:createResults )
was important because namespace-trouble in collection-register.widget.xml
:)
declare function collectionsearch:searchterm($searchXml){$searchXml//searchterm/text()};
declare function collectionsearch:type($searchXml) { $searchXml//type/text()};
declare function collectionsearch:keys($searchXml) { $searchXml//keys };
declare function collectionsearch:regs($searchXml) { $searchXml//regs};
declare function collectionsearch:content($searchXml) {$searchXml//contents};


