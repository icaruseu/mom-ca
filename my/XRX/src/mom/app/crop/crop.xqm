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

module namespace crop="http://www.monasterium.net/NS/crop";

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../xrx/conf.xqm";
    
declare namespace response="http://exist-db.org/xquery/response";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace image="http://exist-db.org/xquery/image";
declare namespace httpclient="http://exist-db.org/xquery/httpclient";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace xrx="http://www.monasterium.net/NS/xrx";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace atom="http://www.w3.org/2005/Atom";

declare variable $crop:db-base-uri := conf:param('data-db-base-uri');

import module "http://exist-db.org/xquery/util";

declare function crop:crop-images($metadata)
{
let $typus := request:get-parameter("type","0")
let $functype := request:get-parameter("amp;functype","0")
let $pathToBinaryResource := replace(request:get-parameter("amp;url","0"), " ", "%20")
let $x1 := request:get-parameter("amp;x1","0")
let $x2 := request:get-parameter("amp;x2","0")
let $y1 := request:get-parameter("amp;y1","0")
let $y2 := request:get-parameter("amp;y2","0")
let $status := request:get-parameter("amp;status","0")
let $delete := request:get-parameter("amp;id","0")
let $file-name := xmldb:encode(request:get-parameter("amp;user","0"))
let $collection := concat($crop:db-base-uri, 'xrx.user/')
let $name := substring-before(substring-after($metadata, 'name='), '?!')
let $type := substring-before(substring-after($metadata, 'type='), '?!')
let $imagename := substring-before(substring-after($metadata, 'imagename='), '?!')
let $datasetid := substring-before(substring-after($metadata, 'dataid='), '?!')
let $imagenote := substring-after($metadata, 'imagenote=')
let $actualdate := current-dateTime()
let $code := xs:string(sum((year-from-dateTime($actualdate),month-from-dateTime($actualdate),day-from-dateTime($actualdate),hours-from-dateTime($actualdate),minutes-from-dateTime($actualdate),seconds-from-dateTime($actualdate))))
let $id := concat(concat(substring($name,1,2),substring($type,1,2)), translate($code, '.', ''))
let $cropid :=  translate($code, '.', '')
let $size := substring-before(substring-after($metadata, 'size='), '?!')
let $anno-id := concat($size, $code)
let $img := httpclient:get(xs:anyURI($pathToBinaryResource), true(),
<headers>
<header name="User-Agent" value="User-Agent: Mozilla/4.0"/>
</headers>)
 return 
if(fn:compare($typus,"get")=0) then
    image:crop($img/*[2]/text(), (xs:integer($x1), xs:integer($y1), xs:integer($x2), xs:integer($y2)), 'image/jpeg')

else if(fn:compare($typus,"relocate")=0) then 
    let $reldata := doc(concat(concat($collection, $file-name), ".xml"))//*:data[@*:id=$datasetid]
    let $copydata := <xrx:data id="{$id}" imagename="{string($reldata/@imagename)}" status="{string($reldata/@status)}"> 
                          <xrx:img>{$reldata/*:img/text()}</xrx:img>
                          <xrx:url>{$reldata/*:url/text()}</xrx:url>
                          <xrx:note>{$reldata/*:note/text()}</xrx:note>
                    </xrx:data>
    let $store-return-status := update insert $copydata into doc(concat(concat($collection, $file-name), ".xml"))//*:cropelement[@*:id=$delete]
    return
        let $delete-return-status := update delete doc(concat(concat($collection, $file-name), ".xml"))//*:data[@*:id=$datasetid]
        return
        <data><dataid>{$id}</dataid><cropid>{$delete}</cropid></data>

else if(fn:compare($typus,"post")=0) then
    if (fn:compare($functype,"new")=0) then
        let $cropexist := doc(concat(concat($collection, $file-name), ".xml"))//*:cropping
        return
            if (empty($cropexist)) then
                let $data :=
                    <xrx:cropping>
                        <xrx:cropelement name="{$name}" type="{$type}" id="{$cropid}">
                            <xrx:data id="{$id}" imagename="{$imagename}" status="privat"> 
                                <xrx:img>{substring-before(substring-after($metadata, 'img='), '?!')}</xrx:img>
                                <xrx:url>{substring-before(substring-after($metadata, 'url='), '?!')}</xrx:url>
                                <xrx:note>{$imagenote}</xrx:note>
                            </xrx:data>
                        </xrx:cropelement>
                    </xrx:cropping>
                let $store-return-status := update insert $data following doc(concat(concat($collection, $file-name), ".xml"))//*:info
                return 
                    <data><dataid>{$id}</dataid><cropid>{string($cropexist//*:cropelement[@*:name=$name and @*:type=$type]/@*:id)}</cropid></data>
                    
            else if($cropexist//*:cropelement[@*:name=$name and @*:type=$type]) then
                let $data :=
                        <xrx:data id="{$id}" imagename="{$imagename}" status="privat"> 
                                <xrx:img>{substring-before(substring-after($metadata, 'img='), '?!')}</xrx:img>
                                <xrx:url>{substring-before(substring-after($metadata, 'url='), '?!')}</xrx:url>
                                <xrx:note>{$imagenote}</xrx:note>
                        </xrx:data>
                let $store-return-status := update insert $data into doc(concat(concat($collection, $file-name), ".xml"))//*:cropelement[@*:name=$name and @*:type=$type]       
                return
                    <response><dataid>{$id}</dataid><cropid>{string($cropexist//*:cropelement[@*:name=$name and @*:type=$type]/@*:id)}</cropid></response>
                    
            else
                let $data :=
                        <xrx:cropelement name="{$name}" type="{$type}" id="{$cropid}">
                            <xrx:data id="{$id}" imagename="{$imagename}" status="privat"> 
                                <xrx:img>{substring-before(substring-after($metadata, 'img='), '?!')}</xrx:img>
                                <xrx:url>{substring-before(substring-after($metadata, 'url='), '?!')}</xrx:url>
                                <xrx:note>{$imagenote}</xrx:note>
                            </xrx:data>
                        </xrx:cropelement>
                let $store-return-status := update insert $data into doc(concat(concat($collection, $file-name), ".xml"))//*:cropping
                return 
                    <data><dataid>{$id}</dataid><cropid>{string($cropexist//*:cropelement[@*:name=$name and @*:type=$type]/@*:id)}</cropid></data>
                     
    else
        let $cropexist := doc(concat(concat($collection, $file-name), ".xml"))//*:cropping
        return
            if($cropexist//*:cropelement[@*:id=$delete]) then
                let $data :=
                    <xrx:data id="{$id}" imagename="{$imagename}" status="privat"> 
                                <xrx:img>{substring-before(substring-after($metadata, 'img='), '?!')}</xrx:img>
                                <xrx:url>{substring-before(substring-after($metadata, 'url='), '?!')}</xrx:url>
                                <xrx:note>{$imagenote}</xrx:note>
                    </xrx:data>
                let $store-return-status := update insert $data into doc(concat(concat($collection, $file-name), ".xml"))//*:cropelement[@*:id=$delete]       
                return
                      <response><dataid>{$id}</dataid><cropid>{$delete}</cropid></response>
            else
                let $data :=
                        <xrx:cropelement name="{$name}" type="{$type}" id="{$cropid}">
                            <xrx:data id="{$id}" imagename="{$imagename}" status="privat"> 
                                <xrx:img>{substring-before(substring-after($metadata, 'img='), '?!')}</xrx:img>
                                <xrx:url>{substring-before(substring-after($metadata, 'url='), '?!')}</xrx:url>
                                <xrx:note>{$imagenote}</xrx:note>
                            </xrx:data>
                        </xrx:cropelement>
                let $store-return-status := update insert $data into doc(concat(concat($collection, $file-name), ".xml"))//*:cropping
                return
                      <data><dataid>{$id}</dataid><cropid>{$cropid}</cropid></data>
                      
else if(fn:compare($typus,"delete")=0) then
    let $datas := doc(concat(concat($collection, $file-name), ".xml"))//*:data[@*:id=$delete]/..
    return
        if(count($datas//*:data)>1) then
            let $delete-return-status := update delete doc(concat(concat($collection, $file-name), ".xml"))//*:data[@*:id=$delete]
            return
                <response>{string("delete")}</response>
        else 
            let $deletesecond-return-status := update delete doc(concat(concat($collection, $file-name), ".xml"))//*:data[@*:id=$delete]/..
                return
                <response>{string("deleteAll")}</response>
                
else if(fn:compare($typus,"editCollection")=0) then
    if (fn:compare($functype,"type")=0) then
        let $cropelement := doc(concat(concat($collection, $file-name), ".xml"))//*:cropelement[@*:id=$delete]
        let $data :=
                            <xrx:cropelement name="{string($cropelement//@name)}" type="{$type}" id="{$delete}">
                                {
                                let $cropdata := $cropelement//*:data
                                for $single in $cropdata
                                return
                                <xrx:data id="{string($single/@id)}" imagename="{string($single/@imagename)}" status="{string($single/@status)}"> 
                                    <xrx:img>{$single/*:img/text()}</xrx:img>
                                    <xrx:url>{$single/*:url/text()}</xrx:url>
                                    <xrx:note>{$single/*:note/text()}</xrx:note>
                                </xrx:data>
                                }
                            </xrx:cropelement>
        let $cropreplace-return-status := update replace doc(concat(concat($collection, $file-name), ".xml"))//*:cropelement[@*:id=$delete] with $data
        return
            <response>{string("update")}</response>
            
    else if(fn:compare($functype,"name")=0)then
        let $cropelement := doc(concat(concat($collection, $file-name), ".xml"))//*:cropelement[@*:id=$delete]
        let $data :=
                            <xrx:cropelement name="{$name}" type="{string($cropelement//@type)}" id="{$delete}" cid="{string($cropelement//@charterid)}">
                                {
                                let $cropdata := $cropelement//*:data
                                for $single in $cropdata
                                return
                                <xrx:data id="{string($single/@id)}" imagename="{string($single/@imagename)}" status="{string($single/@status)}"> 
                                    <xrx:img>{$single/*:img/text()}</xrx:img>
                                    <xrx:url>{$single/*:url/text()}</xrx:url>
                                    <xrx:note>{$single/*:note/text()}</xrx:note>
                                </xrx:data>
                                }
                            </xrx:cropelement>
        let $cropreplace-return-status := update replace doc(concat(concat($collection, $file-name), ".xml"))//*:cropelement[@*:id=$delete] with $data
        return
            <response>{string("update")}</response>
    else if(fn:compare($functype,"image")=0)then
        let $cropelement := doc(concat(concat($collection, $file-name), ".xml"))//*:cropelement[@*:id=$delete]
        let $data :=
                            <xrx:cropelement name="{string($cropelement//@name)}" type="{string($cropelement//@type)}" id="{$delete}" cid="{string($cropelement//@charterid)}">
                                {
                                let $cropdata := $cropelement//*:data
                                for $single in $cropdata
                                return
                                if($single/@*:id=$datasetid) then
                                    <xrx:data id="{string($single/@id)}" imagename="{$imagename}" status="{string($single/@status)}"> 
                                        <xrx:img>{$single/*:img/text()}</xrx:img>
                                        <xrx:url>{$single/*:url/text()}</xrx:url>
                                        <xrx:note>{$single/*:note/text()}</xrx:note>
                                    </xrx:data>
                                else
                                    <xrx:data id="{string($single/@id)}" imagename="{string($single/@imagename)}" status="{string($single/@status)}"> 
                                        <xrx:img>{$single/*:img/text()}</xrx:img>
                                        <xrx:url>{$single/*:url/text()}</xrx:url>
                                        <xrx:note>{$single/*:note/text()}</xrx:note>
                                    </xrx:data>
                                }
                            </xrx:cropelement>
        let $cropreplace-return-status := update replace doc(concat(concat($collection, $file-name), ".xml"))//*:cropelement[@*:id=$delete] with $data
        return
            <response>{string("update")}</response>
    else if(fn:compare($functype,"note")=0)then
        let $cropelement := doc(concat(concat($collection, $file-name), ".xml"))//*:cropelement[@*:id=$delete]
        let $data :=
                            <xrx:cropelement name="{string($cropelement//@name)}" type="{string($cropelement//@type)}" id="{$delete}" cid="{string($cropelement//@charterid)}">
                                {
                                let $cropdata := $cropelement//*:data
                                for $single in $cropdata
                                return
                                if($single/@*:id=$datasetid) then
                                    <xrx:data id="{string($single/@id)}" imagename="{string($single/@imagename)}" status="{string($single/@status)}"> 
                                        <xrx:img>{$single/*:img/text()}</xrx:img>
                                        <xrx:url>{$single/*:url/text()}</xrx:url>
                                        <xrx:note>{$imagenote}</xrx:note>
                                    </xrx:data>
                                else
                                    <xrx:data id="{string($single/@id)}" imagename="{string($single/@imagename)}" status="{string($single/@status)}"> 
                                        <xrx:img>{$single/*:img/text()}</xrx:img>
                                        <xrx:url>{$single/*:url/text()}</xrx:url>
                                        <xrx:note>{$single/*:note/text()}</xrx:note>
                                    </xrx:data>
                                }
                            </xrx:cropelement>
        let $cropreplace-return-status := update replace doc(concat(concat($collection, $file-name), ".xml"))//*:cropelement[@*:id=$delete] with $data
        return
            <response>{string("update")}</response>
    else()

else if(fn:compare($typus,"deleteAnno")=0) then
    let $annodelete-return-status := update delete doc(concat(concat($collection, $file-name), ".xml"))//*:annotationelement[@*:id=$delete]
    return
         <response>{string("delete")}</response> 
                
else if(fn:compare($typus,"postAnno")=0) then  
    let $cropexist := doc(concat(concat($collection, $file-name), ".xml"))//*:annotations
        return
            if (empty($cropexist)) then
                let $data :=
                    <xrx:annotations>
                        <xrx:annotationelement id="{$anno-id}" x1="{substring-before(substring-after($metadata, 'x1='), '?!')}" x2="{substring-before(substring-after($metadata, 'x2='), '?!')}" y1="{substring-before(substring-after($metadata, 'y1='), '?!')}" y2="{substring-before(substring-after($metadata, 'y2='), '?!')}" size="{$size}" status="privat">
                            <xrx:data> 
                                <xrx:text>{substring-after($metadata, 'annotation=')}</xrx:text>
                                <xrx:url>{substring-before(substring-after($metadata, 'url='), '?!')}</xrx:url>
                            </xrx:data>
                        </xrx:annotationelement>
                    </xrx:annotations>
                let $store-return-status := update insert $data following doc(concat(concat($collection, $file-name), ".xml"))//*:info
                return 
                    <response>{$anno-id}</response>
           else
                let $data :=
                        <xrx:annotationelement id="{$anno-id}" x1="{substring-before(substring-after($metadata, 'x1='), '?!')}" x2="{substring-before(substring-after($metadata, 'x2='), '?!')}" y1="{substring-before(substring-after($metadata, 'y1='), '?!')}" y2="{substring-before(substring-after($metadata, 'y2='), '?!')}" size="{$size}" status="privat">
                            <xrx:data> 
                                <xrx:text>{substring-after($metadata, 'annotation=')}</xrx:text>
                                <xrx:url>{substring-before(substring-after($metadata, 'url='), '?!')}</xrx:url>
                            </xrx:data>
                        </xrx:annotationelement>
                let $store-return-status := update insert $data into doc(concat(concat($collection, $file-name), ".xml"))//*:annotations
                return
                    <response>{$anno-id}</response>
                     
else if(fn:compare($typus,"updateAnno")=0) then 
    let $annoreplace-return-status := update replace doc(concat(concat($collection, $file-name), ".xml"))//*:annotationelement[@*:id=$delete]//*:text with <xrx:text>{substring-after($metadata, 'annotation=')}</xrx:text> 
    return
        <response>{string("update")}</response>

else if(fn:compare($typus,"editAnno")=0) then 
    let $askelement := doc(concat(concat($collection, $file-name), ".xml"))//*:annotationelement[@*:id=$delete]
    let $data := 
                    <xrx:annotationelement id="{$id}" x1="{string($askelement//@x1)}" x2="{string($askelement//@x2)}" y1="{string($askelement//@y1)}" y2="{string($askelement//@y2)}" size="{string($askelement//@size)}" status="{$status}">
                         <xrx:data archive="{$askelement//@*:archive}" fond="{$askelement//@*:fond}" charter="{$askelement//@*:charter}">
                            <xrx:text>{$askelement//*:text/text()}</xrx:text>
                            <xrx:url>{$askelement//*:url/text()}</xrx:url>
                         </xrx:data>
                    </xrx:annotationelement>
    let $annoreplace-return-status := update replace doc(concat(concat($collection, $file-name), ".xml"))//*:annotationelement[@*:id=$delete] with $data
    return
        <response>{string("update")}</response>   

 
        
else()
};

declare function crop:compare-annos(){
let $typus := request:get-parameter("type","0")
let $name := request:get-parameter("amp;name","0")
let $type := request:get-parameter("amp;type","0")
let $side := request:get-parameter("amp;side","0")
let $changeType := request:get-parameter("amp;changeType","0")
let $id := request:get-parameter("amp;id","0")
let $file-name := xmldb:encode(request:get-parameter("amp;user","0"))
let $collection := concat($crop:db-base-uri, 'xrx.user/')
return
if(fn:compare($typus,"list")=0) then
    let $annos := doc(concat(concat($collection, $file-name), ".xml"))//*:cropelement[@*:type=$type]
        return
        if(fn:compare($side,"left")=0) then
            <select class="choose" id="namelistleft" name="namelistleft" style="background: #ddd;-moz-border-radius:5px;-webkit-border-radius:5px;-khtml-border-radius:5px;border-radius:5px;border:solid #808080 1px;" onChange="showImage('left', '{$file-name}');">
               <option></option>
               {
               for $name in $annos
                   return 
                    if($name != "")then
                      <option>{string($name//@name)}</option>
                    else()
               }
            </select>               
        else if(fn:compare($side,"right")=0) then 
            <select class="choose" id="namelistright" name="namelistright" style="background: #ddd;-moz-border-radius:5px;-webkit-border-radius:5px;-khtml-border-radius:5px;border-radius:5px;border:solid #808080 1px;" onChange="showImage('right', '{$file-name}');">
               <option></option>
               {
               for $name in $annos
                   return 
                   if($name != "")then
                      <option>{string($name//@name)}</option>
                   else()
               }
            </select>
        else
            (<select class="choose" id="relnamelist" style="position:relative;left:13px;top:10px;background: #ddd;-moz-border-radius:5px;-webkit-border-radius:5px;-khtml-border-radius:5px;border-radius:5px;border:solid #808080 1px;" onChange="$('#relAdjust').css('display', 'block');">
               <option></option>
               {
               for $name in $annos
                   return 
                   <option value="{string($name/@id)}">{string($name//@name)}</option>
               }
            </select>)
            
else if(fn:compare($typus,"view")=0) then
    let $datas := doc(concat(concat($collection, $file-name), ".xml"))//*:cropelement[@*:name=$name and @*:type=$type]//*:data
        return
        for $data at $number in $datas
            return
            if($number = 1) then
                if(fn:compare($side,"left")=0) then
                <data><img src="{$data/*:img}" id="leftImg" alt="{$number}" class="img" title="{$data/*:url}"/><imagename>{string($data//@*:imagename)}</imagename><imagenote>{$data//*:note/text()}</imagenote></data>
                else 
                <data><img src="{$data/*:img}" id="rightImg" alt="{$number}" class="img" title="{$data/*:url}"/><imagename>{string($data//@*:imagename)}</imagename><imagenote>{$data//*:note/text()}</imagenote></data>
            else()
            
else if(fn:compare($typus,"change")=0) then
    let $datas := doc(concat(concat($collection, $file-name), ".xml"))//*:cropelement[@*:name=$name and @*:type=$type]//*:data
    let $numberDatas := count($datas)
        return
        for $data at $number in $datas
            return
            if(fn:compare($changeType,"up")=0) then
                if(($id cast as xs:integer) = $numberDatas) then
                    if($number = 1) then
                         if(fn:compare($side,"left")=0) then
                         <data><img src="{$data/*:img}" id="leftImg" alt="{$number}" class="img" title="{$data/*:url}"/><imagename>{string($data//@*:imagename)}</imagename><imagenote>{$data//*:note/text()}</imagenote></data>
                        else 
                        <data><img src="{$data/*:img}" id="rightImg" alt="{$number}" class="img" title="{$data/*:url}"/><imagename>{string($data//@*:imagename)}</imagename><imagenote>{$data//*:note/text()}</imagenote></data>
                    else()
                else 
                    if($number = (($id cast as xs:integer)+1)) then
                        if(fn:compare($side,"left")=0) then
                            <data><img src="{$data/*:img}" id="leftImg" alt="{$number}" class="img" title="{$data/*:url}"/><imagename>{string($data//@*:imagename)}</imagename><imagenote>{$data//*:note/text()}</imagenote></data>
                            else 
                            <data><img src="{$data/*:img}" id="rightImg" alt="{$number}" class="img" title="{$data/*:url}"/><imagename>{string($data//@*:imagename)}</imagename><imagenote>{$data//*:note/text()}</imagenote></data>
                        else()
            else 
                if(($id cast as xs:integer) = 1) then
                    if($number = $numberDatas) then
                         if(fn:compare($side,"left")=0) then
                            <data><img src="{$data/*:img}" id="leftImg" alt="{$number}" class="img" title="{$data/*:url}"/><imagename>{string($data//@*:imagename)}</imagename><imagenote>{$data//*:note/text()}</imagenote></data>
                            else 
                            <data><img src="{$data/*:img}" id="rightImg" alt="{$number}" class="img" title="{$data/*:url}"/><imagename>{string($data//@*:imagename)}</imagename><imagenote>{$data//*:note/text()}</imagenote></data>
                        else()
                else 
                    if($number = (($id cast as xs:integer)-1)) then
                        if(fn:compare($side,"left")=0) then
                           <data><img src="{$data/*:img}" id="leftImg" alt="{$number}" class="img" title="{$data/*:url}"/><imagename>{string($data//@*:imagename)}</imagename><imagenote>{$data//*:note/text()}</imagenote></data>
                            else 
                            <data><img src="{$data/*:img}" id="rightImg" alt="{$number}" class="img" title="{$data/*:url}"/><imagename>{string($data//@*:imagename)}</imagename><imagenote>{$data//*:note/text()}</imagenote></data>
                        else()          
else()
};

declare function crop:publish-annos($metadata){
let $type := request:get-parameter("type","0")
let $status := request:get-parameter("amp;status","0")
let $id := request:get-parameter("amp;id","0")
let $number := request:get-parameter("amp;requestid","0")
let $file-name := xmldb:encode(request:get-parameter("amp;user","0"))
let $platform-id := request:get-parameter("amp;platformid","0")
let $collection := concat($crop:db-base-uri, 'xrx.user/')
let $publiccol := concat($crop:db-base-uri, 'metadata.charter.public/')
let $currentdate := current-date()
let $actualdate := current-dateTime()
let $factor := request:get-parameter("amp;factor","0")
let $fond := request:get-parameter("amp;fond","0")
let $archive := request:get-parameter("amp;archive","0")
let $charter := request:get-parameter("amp;charter","0")
return

if(fn:compare($type,"ask")=0) then 
    let $moderator := doc(concat(concat($collection, $file-name), ".xml"))//*:moderator
    let $askelement := doc(concat(concat($collection, $file-name), ".xml"))//*:annotationelement[@*:id=$id]
    let $askexist := doc(concat(concat($collection, xmldb:encode($moderator)), ".xml"))//*:askelements
        return
        if(empty($askexist)) then
            let $data := 
                <xrx:askelements>
                    <xrx:askelement id="{$id}" x1="{string($askelement//@x1)}" x2="{string($askelement//@x2)}" y1="{string($askelement//@y1)}" y2="{string($askelement//@y2)}" size="{string($askelement//@size)}" user="{$file-name}" date="{$currentdate}">
                         <xrx:data archive="{$archive}" fond="{$fond}" charter="{$charter}"> 
                            <xrx:text>{$askelement//*:text/text()}</xrx:text>
                            <xrx:url>{$askelement//*:url/text()}</xrx:url>
                         </xrx:data>
                    </xrx:askelement>
               </xrx:askelements>
           let $udata := 
                    <xrx:annotationelement id="{$id}" x1="{string($askelement//@x1)}" x2="{string($askelement//@x2)}" y1="{string($askelement//@y1)}" y2="{string($askelement//@y2)}" size="{string($askelement//@size)}" status="wait">
                         <xrx:data archive="{$archive}" fond="{$fond}" charter="{$charter}"> 
                            <xrx:text>{$askelement//*:text/text()}</xrx:text>
                            <xrx:url>{$askelement//*:url/text()}</xrx:url>
                         </xrx:data>
                    </xrx:annotationelement>
            let $store-return-status := update insert $data following doc(concat(concat($collection, xmldb:encode($moderator)), ".xml"))//*:info
            let $annoreplace-return-status := update replace doc(concat(concat($collection, $file-name), ".xml"))//*:annotationelement[@* :id=$id] with $udata
             return
                <div id="annotools{$number}" style="background: rgba(0, 0, 0, 0.0);z-index:1;display:none;position:absolute;left:{xs:integer(string($askelement//@x1))+xs:integer(string($askelement//@y2))}px;top:{xs:integer(string($askelement//@y1))-25}px;" onmouseover="$('#directannotext{$number}').css('display', 'block');$('#directannofield{$number}').css('border-color','black');$('#annotools{$number}').css('display', 'block');" onmouseout="$('#annotools{$number}').css('display', 'none');$('#directannotext{$number}').css('display', 'none');$('#directannofield{$number}').css('border-color','red');">
                      <span class="release">
                        Wait for release
                      </span>
                   </div>
                
        else
            let $data := 
                    <xrx:askelement id="{$id}" x1="{string($askelement//@x1)}" x2="{string($askelement//@x2)}" y1="{string($askelement//@y1)}" y2="{string($askelement//@y2)}" size="{string($askelement//@size)}" user="{$file-name}" date="{$currentdate}">
                         <xrx:data archive="{$archive}" fond="{$fond}" charter="{$charter}"> 
                            <xrx:text>{$askelement//*:text/text()}</xrx:text>
                            <xrx:url>{$askelement//*:url/text()}</xrx:url>
                         </xrx:data>
                    </xrx:askelement>
            let $udata := 
                    <xrx:annotationelement id="{$id}" x1="{string($askelement//@x1)}" x2="{string($askelement//@x2)}" y1="{string($askelement//@y1)}" y2="{string($askelement//@y2)}" size="{string($askelement//@size)}" status="wait">
                         <xrx:data archive="{$archive}" fond="{$fond}" charter="{$charter}"> 
                            <xrx:text>{$askelement//*:text/text()}</xrx:text>
                            <xrx:url>{$askelement//*:url/text()}</xrx:url>
                         </xrx:data>
                    </xrx:annotationelement>
            let $store-return-status := update insert $data into doc(concat(concat($collection, xmldb:encode($moderator)), ".xml"))//*:askelements
            let $annoreplace-return-status := update replace doc(concat(concat($collection, $file-name), ".xml"))//*:annotationelement[@*:id=$id] with $udata
             return
                <div id="annotools{$number}" style="background: rgba(0, 0, 0, 0.0);z-index:1;display:none;position:absolute;left:{xs:integer(string($askelement//@x1))+xs:integer(string($askelement//@y2))}px;top:{xs:integer(string($askelement//@y1))-25}px;" onmouseover="$('#directannotext{$number}').css('display', 'block');$('#directannofield{$number}').css('border-color','black');$('#annotools{$number}').css('display', 'block');" onmouseout="$('#annotools{$number}').css('display', 'none');$('#directannotext{$number}').css('display', 'none');$('#directannofield{$number}').css('border-color','red');">
                      <span class="release">
                        Wait for release
                      </span>
                   </div>

else if(fn:compare($type,"image")=0)then
     let $askelement := doc(concat(concat($collection, $file-name), ".xml"))//*:askelement[@*:id=$id]
     return
        let $response :=
            <div id="pub{$number}">
                <img id="pubimg{$number}" src="{$askelement//*:url}" class="rimg"></img>
                <div class="direct" style="left:{string($askelement/@x1)}px;top:{string($askelement/@y1)}px;height:{string($askelement/@x2)}px;width:{string($askelement/@y2)}px;" onmouseover="$('#pubannotext{$number}').css('display', 'block');$('#pubannofield{$number}').css('border-color','black');$('#pubtools{$number}').css('display', 'block');" onmouseout="$('#pubannotext{$number}').css('display', 'none');$('#pubannofield{$number}').css('border-color','red');$('#pubtools{$number}').css('display', 'none');" id="pubannofield{$number}">&#160;</div>
                <div style="max-width:400px;z-index:1;-moz-border-radius:3px;-webkit-border-radius:3px;-khtml-border-radius:3px;border-radius:3px;display:none;position:absolute;background-color:rgb(240,243,226);left:{xs:integer(string($askelement/@x1))}px;top:{xs:integer(string($askelement/@y1))+xs:integer(string($askelement/@x2))+5}px;" id="pubannotext{$number}" onmouseover="$('#pubannotext{$number}').css('display', 'block');$('#pubannofield{$number}').css('border-color','black');$('#pubannofield{$number}').css('display','block');$('#pubtools{$number}').css('display', 'block');" onmouseout="$('#pubannotext{$number}').css('display', 'none');$('#pubannofield{$number}').css('border-color','red');$('#pubtools{$number}').css('display', 'none');">{$askelement//*:text/text()}</div>               
                <div id="pubtools{$number}" style="background: rgba(0, 0, 0, 0.0);z-index:1;display:none;position:absolute;left:{xs:integer(string($askelement/@x1))+xs:integer(string($askelement/@y2))}px;top:{xs:integer(string($askelement/@y1))-25}px;" onmouseover="$('#pubannotext{$number}').css('display', 'block');$('#pubannofield{$number}').css('border-color','black');$('#pubtools{$number}').css('display', 'block');" onmouseout="$('#pubtools{$number}').css('display', 'none');$('#pubannotext{$number}').css('display', 'none');$('#pubannofield{$number}').css('border-color','red');">
                    <p id="edittool{$number}" onClick="editAnno('request', '{$askelement/@*:id}', '{$file-name}', '{$askelement//@*:archive}', '{$askelement//@*:fond}', '{$askelement//@*:charter}', 'response', '{$number}')" style="position:relative;left:6px;float:left;">
                         <img src="{concat('/', $platform-id, '/button_edit.png')}" style="width:13px;" title="Edit Annotation"/>
                    </p>
                </div>                                      
            </div>
        return
            $response

else if(fn:compare($type,"getreport")=0)then
     let $askelement := doc(concat(concat($collection, $file-name), ".xml"))//*:reportelement[@*:id=$id]
     return
        let $response :=
            <div id="rep{$number}">
                <img id="repimg{$number}" src="{$askelement//*:url}" class="rimg"></img>
                <div class="direct" style="left:{string($askelement/@x1)}px;top:{string($askelement/@y1)}px;height:{string($askelement/@x2)}px;width:{string($askelement/@y2)}px;" onmouseover="$('#repannotext{$number}').css('display', 'block');$('#repannofield{$number}').css('border-color','black');$('#reptools{$number}').css('display', 'block');" onmouseout="$('#repannotext{$number}').css('display', 'none');$('#repannofield{$number}').css('border-color','red');$('#reptools{$number}').css('display', 'none');" id="repannofield{$number}">&#160;</div>
                <div style="max-width:400px;z-index:1;-moz-border-radius:3px;-webkit-border-radius:3px;-khtml-border-radius:3px;border-radius:3px;display:none;position:absolute;background-color:rgb(240,243,226);left:{xs:integer(string($askelement/@x1))}px;top:{xs:integer(string($askelement/@y1))+xs:integer(string($askelement/@x2))+5}px;" id="repannotext{$number}" onmouseover="$('#repannotext{$number}').css('display', 'block');$('#repannofield{$number}').css('border-color','black');$('#repannofield{$number}').css('display','block');$('#reptools{$number}').css('display', 'block');" onmouseout="$('#repannotext{$number}').css('display', 'none');$('#repannofield{$number}').css('border-color','red');$('#reptools{$number}').css('display', 'none');">{$askelement//*:text/text()}</div>               
                <div id="reptools{$number}" style="background: rgba(0, 0, 0, 0.0);z-index:1;display:none;position:absolute;left:{xs:integer(string($askelement/@x1))+xs:integer(string($askelement/@y2))}px;top:{xs:integer(string($askelement/@y1))-25}px;width:30px;" onmouseover="$('#repannotext{$number}').css('display', 'block');$('#repannofield{$number}').css('border-color','black');$('#reptools{$number}').css('display', 'block');" onmouseout="$('#reptools{$number}').css('display', 'none');$('#repannotext{$number}').css('display', 'none');$('#repannofield{$number}').css('border-color','red');">
                    <p id="editreptool{$number}" onClick="editAnno('request', '{$askelement/@*:id}', '{$file-name}', '{$askelement//@*:archive}', '{$askelement//@*:fond}', '{$askelement//@*:charter}', 'report', '{$number}')" style="position:relative;left:6px;float:left;">
                         <img src="{concat('/', $platform-id, '/button_edit.png')}" style="width:13px;" title="Edit Annotation"/>
                    </p>
                    <p id="delreptool{$number}" onClick="deletePublic('request','{$askelement/@*:id}', '{$file-name}', '{$askelement//@*:archive}', '{$askelement//@*:fond}', '{$askelement//@*:charter}', 'request')" style="position:relative;left:8px;float:left;">
                         <img src="{concat('/', $platform-id, '/remove.png')}" style="width:13px;" title="Delete Annotation"/>
                   </p>
                </div>                
            </div>
        return
            $response

else if(fn:compare($type,"request")=0)then
     let $askelement := doc(concat(concat($collection, $file-name), ".xml"))//*:annotationelement[@*:id=$id]
     return
        let $response :=
            <div id="views{$number}">
                <img id="requestimg{$number}" src="{$askelement//*:url}" class="rimg"></img>
                <div class="direct" style="left:{string($askelement/@x1)}px;top:{string($askelement/@y1)}px;height:{string($askelement/@x2)}px;width:{string($askelement/@y2)}px;" onmouseover="$('#directannotext{$number}').css('display', 'block');$('#directannofield{$number}').css('border-color','black');" onmouseout="$('#directannotext{$number}').css('display', 'none');$('#directannofield{$number}').css('border-color','red');" id="directannofield{$number}">&#160;</div>
                <div style="background: rgba(0, 0, 0, 0.0);max-width:400px;z-index:1;-moz-border-radius:3px;-webkit-border-radius:3px;-khtml-border-radius:3px;border-radius:3px;display:none;position:absolute;background-color:rgb(240,243,226);left:{xs:integer(string($askelement/@x1))}px;top:{xs:integer(string($askelement/@y1))+xs:integer(string($askelement/@x2))+5}px;" id="directannotext{$number}" onmouseover="$('#directannotext{$number}').css('display', 'block');$('#directannofield{$number}').css('border-color','black');$('#directannofield{$number}').css('display','block');" onmouseout="$('#directannotext{$number}').css('display', 'none');$('#directannofield{$number}').css('border-color','red');">{$askelement//*:text/text()}</div>               
            </div>
        return
            $response

else if(fn:compare($type,"modcrop")=0)then
     let $askelement := doc(concat(concat($collection, $file-name), ".xml"))//*:data[@*:id=$id]
     return
        let $response :=
            <div id="pub{$number}">
                <a href="{$askelement//*:url}">
                    <img id="pubimg{$number}" src="{$askelement//*:img}" class="rimg"></img>
                </a>
            </div>
        return
            $response

else if(fn:compare($type,"sendImage")=0)then
     let $askelement := doc(concat(concat($collection, $file-name), ".xml"))//*:data[@*:id=$id]
     return
        let $response :=
            <div id="sendview{$number}">
                <a href="{$askelement//*:url}">
                    <img id="sendimg{$number}" src="{$askelement//*:img}" class="rimg"></img>
                </a>
            </div>
        return
            $response

else if(fn:compare($type,"usercrop")=0)then
     let $askelement := doc(concat(concat($collection, $file-name), ".xml"))//*:data[@*:id=$id]
     return
        let $response :=
            <div id="views{$number}">
                <a href="{$askelement//*:url}">
                    <img id="requestimg{$number}" src="{$askelement//*:img}" class="rimg"></img>
                </a>
            </div>
        return
            $response            
            
else if(fn:compare($type,"critic")=0)then
     let $askelement := doc(concat(concat($collection, $file-name), ".xml"))//*:reportelement[@*:id=$id]
     return
        let $response :=
            <div id="viewscritic{$number}" style="width:450px;">
                <img id="criticimg{$number}" src="{$askelement//*:url}" class="rimg"></img>
                <div class="direct" style="left:{string($askelement/@x1)}px;top:{string($askelement/@y1)}px;height:{string($askelement/@x2)}px;width:{string($askelement/@y2)}px;" onmouseover="$('#directannotextcritic{$number}').css('display', 'block');$('#directannofieldcritic{$number}').css('border-color','black');" onmouseout="$('#directannotextcritic{$number}').css('display', 'none');$('#directannofieldcritic{$number}').css('border-color','red');" id="directannofieldcritic{$number}">&#160;</div>
                <div style="background: rgba(0, 0, 0, 0.0);max-width:400px;z-index:1;-moz-border-radius:3px;-webkit-border-radius:3px;-khtml-border-radius:3px;border-radius:3px;display:none;position:absolute;background-color:rgb(240,243,226);left:{xs:integer(string($askelement/@x1))}px;top:{xs:integer(string($askelement/@y1))+xs:integer(string($askelement/@x2))+5}px;" id="directannotextcritic{$number}" onmouseover="$('#directannotextcritic{$number}').css('display', 'block');$('#directannofieldcritic{$number}').css('border-color','black');$('#directannofield{$number}').css('display','block');" onmouseout="$('#directannotextcritic{$number}').css('display', 'none');$('#directannofieldcritic{$number}').css('border-color','red');">{$askelement//*:text/text()}</div>               
            </div>
        return
            $response
            
else if(fn:compare($type,"accept")=0)then
     let $askelement := doc(concat(concat($collection, $file-name), ".xml"))//*:askelement[@*:id=$id]
     let $teiexist := doc(concat(concat(concat(concat($publiccol, string($askelement//@*:archive), '/'), string($askelement//@*:fond), '/'), string($askelement//@*:charter)), ".cei.xml"))//*:tei
     let $user := $askelement//@*:user
     let $data := 
                    <xrx:annotationelement id="{$id}" x1="{string($askelement//@x1)}" x2="{string($askelement//@x2)}" y1="{string($askelement//@y1)}" y2="{string($askelement//@y2)}" size="{string($askelement//@size)}" status="accept">
                         <xrx:data archive="{$askelement//@*:archive}" fond="{$askelement//@*:fond}" charter="{$askelement//@*:charter}">
                            <xrx:text>{$askelement//*:text/text()}</xrx:text>
                            <xrx:url>{$askelement//*:url/text()}</xrx:url>
                            <xrx:comment>{$metadata}</xrx:comment>
                         </xrx:data>
                    </xrx:annotationelement>
     let $annoreplace-return-status := update replace doc(concat(concat($collection, string($user)), ".xml"))//*:annotationelement[@*:id=$id] with $data
     let $atomreplace-return-status := update replace doc(concat(concat(concat(concat($publiccol, string($askelement//@*:archive), '/'), string($askelement//@*:fond), '/'), string($askelement//@*:charter)), ".cei.xml"))//*:updated with <atom:updated>{$actualdate}</atom:updated> 
     return 
             if(empty($teiexist)) then        
                    let $publishdata := 
                        <tei:tei xmlns:tei="http://www.tei-c.org/ns/1.0">
                            <tei:facsimile>
                               <tei:surfaceGrp>
                                   <tei:surface id="{$id}" ulx="{string($askelement//@x1)}" uly="{string($askelement//@y1)}">
                                        <tei:graphic url="{$askelement//*:url/text()}" scale="{string($askelement//@size)}" height="{string($askelement//@x2)}" width="{string($askelement//@y2)}"/>
                                        <tei:span resp="{string($user)}">{$askelement//*:text/text()}</tei:span>                 
                                   </tei:surface>
                               </tei:surfaceGrp>
                           </tei:facsimile>
                        </tei:tei>
                     let $store-return-status := update insert $publishdata into doc(concat(concat(concat(concat($publiccol, string($askelement//@*:archive), '/'), string($askelement//@*:fond), '/'), string($askelement//@*:charter)), ".cei.xml"))//*:content
                     let $askdelete-return-status := update delete doc(concat(concat($collection, $file-name), ".xml"))//*:askelement[@*:id=$id]
                     return
                         <response>done</response>
                else
                    let $publishdata :=
                        <tei:surface id="{$id}" ulx="{string($askelement//@x1)}" uly="{string($askelement//@y1)}">
                               <tei:graphic url="{$askelement//*:url/text()}" scale="{string($askelement//@size)}" height="{string($askelement//@x2)}" width="{string($askelement//@y2)}"/>
                               <tei:span resp="{string($user)}">{$askelement//*:text/text()}</tei:span>                 
                        </tei:surface>
                    let $store-return-status := update insert $publishdata into doc(concat(concat(concat(concat($publiccol, string($askelement//@*:archive), '/'), string($askelement//@*:fond), '/'), string($askelement//@*:charter)), ".cei.xml"))//*:surfaceGrp
                    let $askdelete-return-status := update delete doc(concat(concat($collection, $file-name), ".xml"))//*:askelement[@*:id=$id]
                     return
                         <response>done</response>

else if(fn:compare($type,"directPub")=0)then
     let $askelement := doc(concat(concat($collection, $file-name), ".xml"))//*:annotationelement[@*:id=$id]
     let $teiexist := doc(concat(concat(concat(concat($publiccol, string($archive), '/'), string($fond), '/'), string($charter)), ".cei.xml"))//*:tei
     let $atomreplace-return-status := update replace doc(concat(concat(concat(concat($publiccol, string($archive), '/'), string($fond), '/'), string($charter)), ".cei.xml"))//*:updated with <atom:updated>{$actualdate}</atom:updated> 
     return 
             if(empty($teiexist)) then        
                    let $publishdata := 
                        <tei:tei xmlns:tei="http://www.tei-c.org/ns/1.0">
                            <tei:facsimile>
                               <tei:surfaceGrp>
                                   <tei:surface id="{$id}" ulx="{string($askelement//@x1)}" uly="{string($askelement//@y1)}">
                                        <tei:graphic url="{$askelement//*:url/text()}" scale="{string($askelement//@size)}" height="{string($askelement//@x2)}" width="{string($askelement//@y2)}"/>
                                        <tei:span resp="{$file-name}">{$askelement//*:text/text()}</tei:span>                 
                                   </tei:surface>
                               </tei:surfaceGrp>
                           </tei:facsimile>
                        </tei:tei>
                     let $store-return-status := update insert $publishdata into doc(concat(concat(concat(concat($publiccol, string($archive), '/'), string($fond), '/'), string($charter)), ".cei.xml"))//*:content
                     let $annodelete-return-status := update delete doc(concat(concat($collection, $file-name), ".xml"))//*:annotationelement[@*:id=$id]
                     return
                         <response>done</response>
                else
                    let $publishdata :=
                        <tei:surface id="{$id}" ulx="{string($askelement//@x1)}" uly="{string($askelement//@y1)}">
                               <tei:graphic url="{$askelement//*:url/text()}" scale="{string($askelement//@size)}" height="{string($askelement//@x2)}" width="{string($askelement//@y2)}"/>
                               <tei:span resp="{$file-name}">{$askelement//*:text/text()}</tei:span>                 
                        </tei:surface>
                    let $store-return-status := update insert $publishdata into doc(concat(concat(concat(concat($publiccol, string($archive), '/'), string($fond), '/'), string($charter)), ".cei.xml"))//*:surfaceGrp
                    let $annodelete-return-status := update delete doc(concat(concat($collection, $file-name), ".xml"))//*:annotationelement[@*:id=$id]
                    return
                         <response>done</response>
                         
else if(fn:compare($type,"decline")=0)then
     let $askelement := doc(concat(concat($collection, $file-name), ".xml"))//*:askelement[@*:id=$id]
     let $user := $askelement//@*:user
        return
           let $data := 
                    <xrx:annotationelement id="{$id}" x1="{string($askelement//@x1)}" x2="{string($askelement//@x2)}" y1="{string($askelement//@y1)}" y2="{string($askelement//@y2)}" size="{string($askelement//@size)}" status="decline">
                         <xrx:data archive="{$askelement//@*:archive}" fond="{$askelement//@*:fond}" charter="{$askelement//@*:charter}"> 
                            <xrx:text>{$askelement//*:text/text()}</xrx:text>
                            <xrx:url>{$askelement//*:url/text()}</xrx:url>
                            <xrx:comment>{$metadata}</xrx:comment>
                         </xrx:data>
                    </xrx:annotationelement>
            let $annoreplace-return-status := update replace doc(concat(concat($collection, string($user)), ".xml"))//*:annotationelement[@*:id=$id] with $data
            let $askdelete-return-status := update delete doc(concat(concat($collection, $file-name), ".xml"))//*:askelement[@*:id=$id]
             return
                <response>done</response>
 
else if(fn:compare($type,"answerReport")=0)then
     let $askelement := doc(concat(concat($collection, $file-name), ".xml"))//*:reportelement[@*:id=$id]
     let $user := $askelement//@*:reporter
        return
           let $data := 
                    <xrx:reportelement id="{$id}" x1="{string($askelement//@x1)}" x2="{string($askelement//@x2)}" y1="{string($askelement//@y1)}" y2="{string($askelement//@y2)}" size="{string($askelement//@size)}" status="answer">
                         <xrx:data archive="{$askelement//@*:archive}" fond="{$askelement//@*:fond}" charter="{$askelement//@*:charter}">
                            <xrx:text>{$askelement//*:text/text()}</xrx:text>
                            <xrx:url>{$askelement//*:url/text()}</xrx:url>
                            <xrx:comment>{$metadata}</xrx:comment>
                         </xrx:data>
                    </xrx:reportelement>
            let $annoreplace-return-status := update replace doc(concat(concat($collection, string($user)), ".xml"))//*:reportelement[@*:id=$id] with $data
            let $askdelete-return-status := update delete doc(concat(concat($collection, $file-name), ".xml"))//*:reportelement[@*:id=$id]
             return
                <response>done</response>

else if(fn:compare($type,"hide")=0)then
     if(fn:compare($status,"accept")=0) then
        let $askdelete-return-status := update delete doc(concat(concat($collection, $file-name), ".xml"))//*:annotationelement[@*:id=$id]
        return
          <response>done</response>
     else if(fn:compare($status,"decline")=0) then 
        let $askelement := doc(concat(concat($collection, $file-name), ".xml"))//*:annotationelement[@*:id=$id]
        let $data := 
                    <xrx:annotationelement id="{$id}" x1="{string($askelement//@x1)}" x2="{string($askelement//@x2)}" y1="{string($askelement//@y1)}" y2="{string($askelement//@y2)}" size="{string($askelement//@size)}" status="wait-for-edit">
                         <xrx:data archive="{$askelement//@*:archive}" fond="{$askelement//@*:fond}" charter="{$askelement//@*:charter}">
                            <xrx:text>{$askelement//*:text/text()}</xrx:text>
                            <xrx:url>{$askelement//*:url/text()}</xrx:url>
                         </xrx:data>
                    </xrx:annotationelement>
        let $annoreplace-return-status := update replace doc(concat(concat($collection, $file-name), ".xml"))//*:annotationelement[@*:id=$id] with $data
        return
          <response>done</response>
      else
        let $askdelete-return-status := update delete doc(concat(concat($collection, $file-name), ".xml"))//*:reportelement[@*:id=$id]
        return
          <response>done</response>  
          
else if(fn:compare($type,"report")=0)then
        let $askelement := doc(concat(concat(concat(concat($publiccol, $archive, '/'), $fond, '/'), $charter), ".cei.xml"))//*:surface[@*:id=$id]
        let $moderator := doc(concat(concat($collection, string($askelement//*:span/@*:resp)), ".xml"))//*:moderator
        return
            let $udata := 
                    <xrx:reportelement id="{$id}" x1="{string($askelement//@*:ulx)}" x2="{string($askelement//*:graphic/@*:height)}" y1="{string($askelement//@*:uly)}" y2="{string($askelement//*:graphic/@*:width)}" size="{string($askelement//*:graphic/@*:scale)}" status="wait">
                         <xrx:data archive="{$archive}" fond="{$fond}" charter="{$charter}">
                            <xrx:text>{$askelement//*:span/text()}</xrx:text>
                            <xrx:url>{string($askelement//*:graphic/@*:url)}</xrx:url>
                         </xrx:data>
                    </xrx:reportelement>
            let $data := 
                    <xrx:reportelement id="{$id}" x1="{string($askelement//@*:ulx)}" x2="{string($askelement//*:graphic/@*:height)}" y1="{string($askelement//@*:uly)}" y2="{string($askelement//*:graphic/@*:width)}" size="{string($askelement//*:graphic/@*:scale)}" reporter="{$file-name}" date="{$currentdate}">
                         <xrx:data archive="{$archive}" fond="{$fond}" charter="{$charter}">
                            <xrx:text>{$askelement//*:span/text()}</xrx:text>
                            <xrx:url>{string($askelement//*:graphic/@*:url)}</xrx:url>
                            <xrx:comment>{$metadata}</xrx:comment>
                         </xrx:data>
                    </xrx:reportelement>
            let $store-return-status := update insert $data into doc(concat(concat($collection, xmldb:encode($moderator)), ".xml"))//*:askelements
            let $annoreplace-return-status := update insert $udata into doc(concat(concat($collection, $file-name), ".xml"))//*:annotations
             return
                <response>done</response>
          
else if(fn:compare($type,"deleteAnno")=0) then
    let $annodelete-return-status := update delete doc(concat(concat(concat(concat($publiccol, $archive, '/'), $fond, '/'), $charter), ".cei.xml"))//*:surface[@*:id=$id]
    let $atomreplace-return-status := update replace doc(concat(concat(concat(concat($publiccol, $archive, '/'), $fond, '/'), $charter), ".cei.xml"))//*:updated with <atom:updated>{$actualdate}</atom:updated> 
    return
         <response>{string("delete")}</response> 

else if(fn:compare($type,"updateAnno")=0) then 
    if(fn:compare($status,"report")=0) then
        let $reporter := doc(concat(concat($collection, $file-name), ".xml"))//*:reportelement[@*:id=$id]//@*:reporter
        let $userreplace-return-status := update replace doc(concat(concat($collection, $file-name), ".xml"))//*:reportelement[@*:id=$id]//*:text with <xrx:text>{substring-after($metadata, 'annotation=')}</xrx:text> 
        let $annoreplace-return-status := update replace doc(concat(concat(concat(concat($publiccol, $archive, '/'), $fond, '/'), $charter), ".cei.xml"))//*:surface[@*:id=$id]//*:span with <tei:span resp="{$reporter}">{substring-after($metadata, 'annotation=')}</tei:span> 
        let $atomreplace-return-status := update replace doc(concat(concat(concat(concat($publiccol, $archive, '/'), $fond, '/'), $charter), ".cei.xml"))//*:updated with <atom:updated>{$actualdate}</atom:updated> 
        return
            <response>{string("update")}</response>
    else
        let $reporter := string(doc(concat(concat(concat(concat($publiccol, $archive, '/'), $fond, '/'), $charter), ".cei.xml"))//*:surface[@*:id=$id]//*:span//@*:resp)
        let $annoreplace-return-status := update replace doc(concat(concat(concat(concat($publiccol, $archive, '/'), $fond, '/'), $charter), ".cei.xml"))//*:surface[@*:id=$id]//*:span with <tei:span resp="{$reporter}">{substring-after($metadata, 'annotation=')}</tei:span> 
        let $atomreplace-return-status := update replace doc(concat(concat(concat(concat($publiccol, $archive, '/'), $fond, '/'), $charter), ".cei.xml"))//*:updated with <atom:updated>{$actualdate}</atom:updated> 
        return
            <response>{string("update")}</response>

else if(fn:compare($type,"editAnno")=0) then 
    let $annoreplace-return-status := update replace doc(concat(concat($collection, $file-name), ".xml"))//*:askelement[@*:id=$id]//*:text with <xrx:text>{substring-after($metadata, 'annotation=')}</xrx:text> 
    return
        <response>{string("update")}</response> 
        

else()
};

declare function crop:publish-cropimages($metadata){
let $typus := request:get-parameter("type","0")
let $functype := request:get-parameter("amp;functype","0")
let $nid := request:get-parameter("amp;number","0")
let $changeType := request:get-parameter("amp;changeType","0")
let $id := request:get-parameter("amp;id","0")
let $singleID := request:get-parameter("amp;dataid","0")
let $file-name := xmldb:encode(request:get-parameter("amp;user","0"))
let $send-user := request:get-parameter("amp;sendUser","0")
let $collection := concat($crop:db-base-uri, 'xrx.user/')
let $name := substring-before(substring-after($metadata, 'name='), '?!')
let $type := substring-before(substring-after($metadata, 'type='), '?!')
let $imagename := substring-before(substring-after($metadata, 'imagename='), '?!')
let $savepath := concat($crop:db-base-uri, 'metadata.imagecollections/imagecollections.xml')
let $imagenote := substring-after($metadata, 'imagenote=')
let $actualdate := current-dateTime()
let $currentdate := current-date()
let $code := xs:string(sum((year-from-dateTime($actualdate),month-from-dateTime($actualdate),day-from-dateTime($actualdate),hours-from-dateTime($actualdate),minutes-from-dateTime($actualdate),seconds-from-dateTime($actualdate))))
let $newid := concat(concat(substring($name,1,2),substring($type,1,2)), translate($code, '.', ''))
let $cropid :=  translate($code, '.', '')
return
if(fn:compare($typus,"AskNewData")=0) then 
    let $moderator := doc(concat(concat($collection, $file-name), ".xml"))//*:moderator
    let $askelement := doc(concat(concat($collection, $file-name), ".xml"))//*:data[@*:id=$id]
    let $askexist := doc(concat(concat($collection, xmldb:encode($moderator)), ".xml"))//*:askcrops
        return
        if(empty($askexist)) then
            let $data := 
                <xrx:askcrops>
                    <xrx:askcrop id="{$cropid}" name="{$name}" type="{$type}" user="{$file-name}" date="{$currentdate}" collection="new">
                         <xrx:data id="{$newid}" imagename="{$imagename}"> 
                                <xrx:img>{substring-before(substring-after($metadata, 'img='), '?!')}</xrx:img>
                                <xrx:url>{substring-before(substring-after($metadata, 'url='), '?!')}</xrx:url>
                                <xrx:note>{$imagenote}</xrx:note>
                         </xrx:data>
                    </xrx:askcrop>
               </xrx:askcrops>
               
           let $udata := 
                         <xrx:data id="{$newid}" imagename="{$imagename}" status="wait" newtype="{$type}" newname="{$name}" collection="new"> 
                                <xrx:img>{substring-before(substring-after($metadata, 'img='), '?!')}</xrx:img>
                                <xrx:url>{substring-before(substring-after($metadata, 'url='), '?!')}</xrx:url>
                                <xrx:note>{$imagenote}</xrx:note>
                         </xrx:data>
                         
            let $store-return-status := update insert $data following doc(concat(concat($collection, xmldb:encode($moderator)), ".xml"))//*:info
            let $annoreplace-return-status := update replace doc(concat(concat($collection, $file-name), ".xml"))//*:data[@*:id=$id] with $udata
            return
               <data><dataid>{$newid}</dataid><cropid>{$cropid}</cropid></data>
                
        else
            let $data := 
                    <xrx:askcrop id="{$cropid}" name="{$name}" type="{$type}" user="{$file-name}" date="{$currentdate}" collection="new">
                         <xrx:data id="{$newid}" imagename="{$imagename}"> 
                                <xrx:img>{substring-before(substring-after($metadata, 'img='), '?!')}</xrx:img>
                                <xrx:url>{substring-before(substring-after($metadata, 'url='), '?!')}</xrx:url>
                                <xrx:note>{$imagenote}</xrx:note>
                         </xrx:data>
                    </xrx:askcrop>
            let $udata := 
                    <xrx:data id="{$newid}" imagename="{$imagename}" status="wait" newtype="{$type}" newname="{$name}" collection="new"> 
                                <xrx:img>{substring-before(substring-after($metadata, 'img='), '?!')}</xrx:img>
                                <xrx:url>{substring-before(substring-after($metadata, 'url='), '?!')}</xrx:url>
                                <xrx:note>{$imagenote}</xrx:note>
                   </xrx:data>
                   
            let $store-return-status := update insert $data into doc(concat(concat($collection, xmldb:encode($moderator)), ".xml"))//*:askcrops
            let $annoreplace-return-status := update replace doc(concat(concat($collection, $file-name), ".xml"))//*:data[@*:id=$id] with $udata
             return
                <data><dataid>{$newid}</dataid><cropid>{$cropid}</cropid></data>
                
else if(fn:compare($typus,"AskExistData")=0) then 
    let $moderator := doc(concat(concat($collection, $file-name), ".xml"))//*:moderator
    let $askelement := doc($savepath)//*:cropelement[@*:id=$id]
        return
            let $data := 
                    <xrx:askcrop id="{$cropid}" name="{string($askelement/@name)}" type="{string($askelement/@type)}" user="{$file-name}" date="{$currentdate}" collection="{$id}">
                         <xrx:data id="{$newid}" imagename="{$imagename}"> 
                                <xrx:img>{substring-before(substring-after($metadata, 'img='), '?!')}</xrx:img>
                                <xrx:url>{substring-before(substring-after($metadata, 'url='), '?!')}</xrx:url>
                                <xrx:note>{$imagenote}</xrx:note>
                         </xrx:data>
                    </xrx:askcrop>
            let $udata := 
                    <xrx:data id="{$newid}" imagename="{$imagename}" status="wait" newtype="{string($askelement/@type)}" newname="{string($askelement/@name)}" collection="{$id}"> 
                                <xrx:img>{substring-before(substring-after($metadata, 'img='), '?!')}</xrx:img>
                                <xrx:url>{substring-before(substring-after($metadata, 'url='), '?!')}</xrx:url>
                                <xrx:note>{$imagenote}</xrx:note>
                   </xrx:data>
                   
            let $store-return-status := update insert $data into doc(concat(concat($collection, xmldb:encode($moderator)), ".xml"))//*:askcrops
            let $annoreplace-return-status := update replace doc(concat(concat($collection, $file-name), ".xml"))//*:data[@*:id=$singleID] with $udata
             return
                <data><dataid>{$newid}</dataid></data>

else if(fn:compare($typus,"publishNewMod")=0)then
     let $askelement := doc(concat(concat($collection, $file-name), ".xml"))//*:data[@*:id=$id]
     let $firstname := doc(concat(concat($collection, $file-name), ".xml"))//*:firstname
     let $lastname := doc(concat(concat($collection, $file-name), ".xml"))//*:name
     return
        let $publishdata := 
            <xrx:cropelement name="{$name}" type="{$type}" id="{$cropid}" firstname="{$firstname/text()}" lastname="{$lastname/text()}" user="{$file-name}">
                <xrx:data id="{$newid}" imagename="{$imagename}" firstname="{$firstname/text()}" lastname="{$lastname/text()}" user="{$file-name}">
                    <xrx:img>{$askelement//*:img/text()}</xrx:img>
                    <xrx:url>{$askelement//*:url/text()}</xrx:url>
                    <xrx:note>{$imagenote}</xrx:note>
                </xrx:data>
           </xrx:cropelement>
                           
       let $store-return-status := update insert $publishdata into doc($savepath)//*:imagecollections
       return
           <data><dataid>{$newid}</dataid><cropid>{$cropid}</cropid></data>

else if(fn:compare($typus,"publishExistMod")=0)then
     let $askelement := doc($savepath)//*:cropelement[@*:id=$id]
     let $firstname := doc(concat(concat($collection, $file-name), ".xml"))//*:firstname
     let $name := doc(concat(concat($collection, $file-name), ".xml"))//*:name
     return
          let $publishdata := 
              <xrx:data id="{$newid}" imagename="{$imagename}" firstname="{$firstname/text()}" lastname="{$name/text()}" user="{$file-name}">
                   <xrx:img>{substring-before(substring-after($metadata, 'img='), '?!')}</xrx:img>
                   <xrx:url>{substring-before(substring-after($metadata, 'url='), '?!')}</xrx:url>
                   <xrx:note>{$imagenote}</xrx:note>
             </xrx:data>
                               
         let $store-return-status := update insert $publishdata into doc($savepath)//*:cropelement[@*:id=$id]
                    return
                    <data><dataid>{$newid}</dataid></data>
                
else if(fn:compare($typus,"accept")=0)then
     let $askelement := doc(concat(concat($collection, $file-name), ".xml"))//*:askcrop[@*:id=$id]
     let $colinfo := string($askelement/@*:collection)
     let $dataid := string($askelement/*:data/@id)
     let $user := $askelement//@*:user
     let $firstname := doc(concat(concat($collection, string($user)), ".xml"))//*:firstname
     let $name := doc(concat(concat($collection, string($user)), ".xml"))//*:name
     return
        if(fn:compare($colinfo,"new")=0) then
            let $publishdata := 
                           <xrx:cropelement name="{string($askelement/@name)}" type="{string($askelement/@type)}" id="{string($askelement/@id)}" firstname="{$firstname/text()}" lastname="{$name/text()}" user="{$user}">
                               <xrx:data id="{$dataid}" imagename="{string($askelement//@imagename)}" firstname="{$firstname/text()}" lastname="{$name/text()}" user="{$user}">
                                   <xrx:img>{$askelement//*:img/text()}</xrx:img>
                                   <xrx:url>{$askelement//*:url/text()}</xrx:url>
                                   <xrx:note>{$askelement//*:note/text()}</xrx:note>
                               </xrx:data>
                           </xrx:cropelement>
            let $udata := 
                           <xrx:data id="{$dataid}" imagename="{string($askelement//@imagename)}" newtype="{string($askelement//@type)}" newname="{string($askelement//@name)}" collection="new" status="accept">
                                   <xrx:img>{$askelement//*:img/text()}</xrx:img>
                                   <xrx:url>{$askelement//*:url/text()}</xrx:url>
                                   <xrx:note>{$askelement//*:note/text()}</xrx:note>
                                   <xrx:comment>{$metadata}</xrx:comment>
                           </xrx:data>
                           
            let $annoreplace-return-status := update replace doc(concat(concat($collection, string($user)), ".xml"))//*:data[@*:id=$dataid] with $udata
            let $store-return-status := update insert $publishdata into doc($savepath)//*:imagecollections
            let $askdelete-return-status := update delete doc(concat(concat($collection, $file-name), ".xml"))//*:askcrop[@*:id=$id]
                return
                <response>done</response>
        else
            let $existcol := doc($savepath)//*:cropelement[@*:id=$colinfo]
            return
            if(not(empty($existcol))) then
                let $publishdata := 
                                   <xrx:data id="{$dataid}" imagename="{string($askelement//@imagename)}" firstname="{$firstname/text()}" lastname="{$name/text()}" user="{$user}">
                                       <xrx:img>{$askelement//*:img/text()}</xrx:img>
                                       <xrx:url>{$askelement//*:url/text()}</xrx:url>
                                       <xrx:note>{$askelement//*:note/text()}</xrx:note>
                                   </xrx:data>
                let $udata := 
                               <xrx:data id="{$dataid}" imagename="{string($askelement//@imagename)}" newtype="{string($askelement//@type)}" newname="{string($askelement//@name)}" collection="{$colinfo}" status="accept">
                                       <xrx:img>{$askelement//*:img/text()}</xrx:img>
                                       <xrx:url>{$askelement//*:url/text()}</xrx:url>
                                       <xrx:note>{$askelement//*:note/text()}</xrx:note>
                                       <xrx:comment>{$metadata}</xrx:comment>
                               </xrx:data>
                               
                let $annoreplace-return-status := update replace doc(concat(concat($collection, string($user)), ".xml"))//*:data[@*:id=$dataid] with $udata
                let $store-return-status := update insert $publishdata into doc($savepath)//*:cropelement[@*:id=$colinfo]
                let $askdelete-return-status := update delete doc(concat(concat($collection, $file-name), ".xml"))//*:askcrop[@*:id=$id]
                    return
                    <response>done</response>
            else
                let $publishdata := 
                           <xrx:cropelement name="{string($askelement/@name)}" type="{string($askelement/@type)}" id="{$cropid}" firstname="{$firstname/text()}" lastname="{$name/text()}" user="{$user}">
                               <xrx:data id="{$dataid}" imagename="{string($askelement//@imagename)}" firstname="{$firstname/text()}" lastname="{$name/text()}" user="{$user}">
                                   <xrx:img>{$askelement//*:img/text()}</xrx:img>
                                   <xrx:url>{$askelement//*:url/text()}</xrx:url>
                                   <xrx:note>{$askelement//*:note/text()}</xrx:note>
                               </xrx:data>
                           </xrx:cropelement>
                let $udata := 
                               <xrx:data id="{$dataid}" imagename="{string($askelement//@imagename)}" newtype="{string($askelement//@type)}" newname="{string($askelement//@name)}" collection="{$colinfo}" status="accept">
                                       <xrx:img>{$askelement//*:img/text()}</xrx:img>
                                       <xrx:url>{$askelement//*:url/text()}</xrx:url>
                                       <xrx:note>{$askelement//*:note/text()}</xrx:note>
                                       <xrx:comment>{$metadata}</xrx:comment>
                               </xrx:data>
                               
                let $annoreplace-return-status := update replace doc(concat(concat($collection, string($user)), ".xml"))//*:data[@*:id=$dataid] with $udata
                let $store-return-status := update insert $publishdata into doc($savepath)//*:imagecollections
                let $askdelete-return-status := update delete doc(concat(concat($collection, $file-name), ".xml"))//*:askcrop[@*:id=$id]
                    return
                    <response>done</response>
                
                         
else if(fn:compare($typus,"decline")=0)then
     let $askelement := doc(concat(concat($collection, $file-name), ".xml"))//*:askcrop[@*:id=$id]
     let $dataid := string($askelement/*:data/@id)
     let $user := $askelement//@*:user
        return
           let $data := 
                    <xrx:data id="{$dataid}" imagename="{string($askelement//@imagename)}" newtype="{string($askelement//@type)}" newname="{string($askelement//@name)}" collection="string($askelement/@*:collection)" status="decline">
                            <xrx:img>{$askelement//*:img/text()}</xrx:img>
                            <xrx:url>{$askelement//*:url/text()}</xrx:url>
                            <xrx:note>{$askelement//*:note/text()}</xrx:note>
                            <xrx:comment>{$metadata}</xrx:comment>
                    </xrx:data>
                    
            let $annoreplace-return-status := update replace doc(concat(concat($collection, string($user)), ".xml"))//*:data[@*:id=$dataid] with $data
            let $askdelete-return-status := update delete doc(concat(concat($collection, $file-name), ".xml"))//*:askcrop[@*:id=$id]
             return
                <response>done</response>
                

                
else if(fn:compare($typus,"declineSend")=0)then
     let $askdelete-return-status := update delete doc(concat(concat($collection, $file-name), ".xml"))//*:asksend[@*:id=$id]
             return
                <response>done</response>

else if(fn:compare($typus,"hide")=0)then
        let $askelement := doc(concat(concat($collection, $file-name), ".xml"))//*:data[@*:id=$id]
        let $data := 
                    <xrx:data id="{$id}" imagename="{string($askelement//@imagename)}" status="privat">
                            <xrx:img>{$askelement//*:img/text()}</xrx:img>
                            <xrx:url>{$askelement//*:url/text()}</xrx:url>
                            <xrx:note>{$askelement//*:note/text()}</xrx:note>
                    </xrx:data>
        let $annoreplace-return-status := update replace doc(concat(concat($collection, $file-name), ".xml"))//*:data[@*:id=$id] with $data
        return
          <response>done</response> 

else if(fn:compare($typus,"editCollection")=0) then
    if (fn:compare($functype,"type")=0) then
        let $cropelement := doc($savepath)//*:cropelement[@*:id=$id]
        let $data :=
                            <xrx:cropelement name="{string($cropelement//@name)}" type="{$type}" id="{$id}" firstname="{string($cropelement/@firstname)}" lastname="{string($cropelement/@lastname)}" user="{string($cropelement/@user)}">
                                {
                                let $cropdata := $cropelement//*:data
                                for $single in $cropdata
                                return
                                <xrx:data id="{string($single/@id)}" imagename="{string($single/@imagename)}" firstname="{string($single/@firstname)}" lastname="{string($single/@lastname)}" user="{string($single/@user)}"> 
                                    <xrx:img>{$single/*:img/text()}</xrx:img>
                                    <xrx:url>{$single/*:url/text()}</xrx:url>
                                    <xrx:note>{$single/*:note/text()}</xrx:note>
                                </xrx:data>
                                }
                            </xrx:cropelement>
        let $cropreplace-return-status := update replace doc($savepath)//*:cropelement[@*:id=$id] with $data
        return
            <response>{string("update")}</response>
            
     else if(fn:compare($functype,"name")=0)then
        let $cropelement := doc($savepath)//*:cropelement[@*:id=$id]
        let $data :=
                            <xrx:cropelement name="{$name}" type="{string($cropelement//@type)}" id="{$id}" firstname="{string($cropelement/@firstname)}" lastname="{string($cropelement/@lastname)}" user="{string($cropelement/@user)}">
                                {
                                let $cropdata := $cropelement//*:data
                                for $single in $cropdata
                                return
                                <xrx:data id="{string($single/@id)}" imagename="{string($single/@imagename)}" firstname="{string($single/@firstname)}" lastname="{string($single/@lastname)}" user="{string($single/@user)}"> 
                                    <xrx:img>{$single/*:img/text()}</xrx:img>
                                    <xrx:url>{$single/*:url/text()}</xrx:url>
                                    <xrx:note>{$single/*:note/text()}</xrx:note>
                                </xrx:data>
                                }
                            </xrx:cropelement>
        let $cropreplace-return-status := update replace doc($savepath)//*:cropelement[@*:id=$id] with $data
        return
            <response>{string("update")}</response>
            
     else if(fn:compare($functype,"image")=0)then
        let $cropelement := doc($savepath)//*:cropelement[@*:id=$id]
        let $idno := substring-before(substring-after($metadata, 'dataid='), '?!')
        let $data :=
                            <xrx:cropelement name="{string($cropelement//@name)}" type="{string($cropelement//@type)}" id="{$id}" firstname="{string($cropelement/@firstname)}" lastname="{string($cropelement/@lastname)}" user="{string($cropelement/@user)}">
                                {
                                let $cropdata := $cropelement//*:data
                                for $single in $cropdata
                                return
                                if($single/@*:id= $idno) then
                                    <xrx:data id="{string($single/@id)}" imagename="{$imagename}" firstname="{string($single/@firstname)}" lastname="{string($single/@lastname)}" user="{string($single/@user)}"> 
                                        <xrx:img>{$single/*:img/text()}</xrx:img>
                                        <xrx:url>{$single/*:url/text()}</xrx:url>
                                        <xrx:note>{$single/*:note/text()}</xrx:note>
                                    </xrx:data>
                                else
                                    <xrx:data id="{string($single/@id)}" imagename="{string($single/@imagename)}" firstname="{string($single/@firstname)}" lastname="{string($single/@lastname)}" user="{string($single/@user)}"> 
                                        <xrx:img>{$single/*:img/text()}</xrx:img>
                                        <xrx:url>{$single/*:url/text()}</xrx:url>
                                        <xrx:note>{$single/*:note/text()}</xrx:note>
                                    </xrx:data>
                                }
                            </xrx:cropelement>
        let $cropreplace-return-status := update replace doc($savepath)//*:cropelement[@*:id=$id] with $data
        return
            <response>{string("update")}</response>
            
    else if(fn:compare($functype,"note")=0)then
        let $cropelement := doc($savepath)//*:cropelement[@*:id=$id]
        let $idno := substring-before(substring-after($metadata, 'dataid='), '?!')
        let $data :=
                            <xrx:cropelement name="{string($cropelement//@name)}" type="{string($cropelement//@type)}" id="{$id}" firstname="{string($cropelement/@firstname)}" lastname="{string($cropelement/@lastname)}" user="{string($cropelement/@user)}">
                                {
                                let $cropdata := $cropelement//*:data
                                for $single in $cropdata
                                return
                                if($single/@*:id= $idno) then
                                    <xrx:data id="{string($single/@id)}" imagename="{string($single/@imagename)}" firstname="{string($single/@firstname)}" lastname="{string($single/@lastname)}" user="{string($single/@user)}"> 
                                        <xrx:img>{$single/*:img/text()}</xrx:img>
                                        <xrx:url>{$single/*:url/text()}</xrx:url>
                                        <xrx:note>{$imagenote}</xrx:note>
                                    </xrx:data>
                                else
                                    <xrx:data id="{string($single/@id)}" imagename="{string($single/@imagename)}" firstname="{string($single/@firstname)}" lastname="{string($single/@lastname)}" user="{string($single/@user)}"> 
                                        <xrx:img>{$single/*:img/text()}</xrx:img>
                                        <xrx:url>{$single/*:url/text()}</xrx:url>
                                        <xrx:note>{$single/*:note/text()}</xrx:note>
                                    </xrx:data>
                                }
                            </xrx:cropelement>
        let $cropreplace-return-status := update replace doc($savepath)//*:cropelement[@*:id=$id] with $data
        return
            <response>{string("update")}</response>
     else()

else if(fn:compare($typus,"saveCollection")=0) then
        let $cropelement := doc($savepath)//*:cropelement[@*:id=$id]
        let $data :=
                            <xrx:cropelement name="{string($cropelement//@name)}" type="{string($cropelement//@type)}" id="{$cropid}">
                                {
                                let $cropdata := $cropelement//*:data
                                for $single in $cropdata
                                return
                                <xrx:data id="{string($single/@id)}" imagename="{string($single/@imagename)}" status="privat"> 
                                    <xrx:img>{$single/*:img/text()}</xrx:img>
                                    <xrx:url>{$single/*:url/text()}</xrx:url>
                                    <xrx:note>{$single/*:note/text()}</xrx:note>
                                </xrx:data>
                                }
                            </xrx:cropelement>
        let $cropinsert-return-status := update insert $data into doc(concat(concat($collection, $file-name), ".xml"))//*:cropping
        return
            <response>{string("saved")}</response>

else if(fn:compare($typus,"change")=0) then
    let $datas := doc($savepath)//*:cropelement[@*:id=$id]//*:data
    let $numberDatas := count($datas)
        return
        for $data at $number in $datas
            return
            if(fn:compare($changeType,"up")=0) then
                if(($nid cast as xs:integer) = $numberDatas) then
                    if($number = 1) then
                         <data><img src="{$data/*:img}" id="cropimg" alt="{$number}" class="cropimg"/><url>{$data//*:url/text()}</url><user>{string($data/@*:firstname)}&#160;{string($data/@*:lastname)}</user><imagename>{string($data//@*:imagename)}</imagename><imagenote>{$data//*:note/text()}</imagenote></data>
                    else()
                else 
                    if($number = (($nid cast as xs:integer)+1)) then
                         <data><img src="{$data/*:img}" id="cropimg" alt="{$number}" class="cropimg"/><url>{$data//*:url/text()}</url><user>{string($data/@*:firstname)}&#160;{string($data/@*:lastname)}</user><imagename>{string($data//@*:imagename)}</imagename><imagenote>{$data//*:note/text()}</imagenote></data>
                    else()
            else 
                if(($nid cast as xs:integer) = 1) then
                    if($number = $numberDatas) then
                        <data><img src="{$data/*:img}" id="cropimg" alt="{$number}" class="cropimg"/><url>{$data//*:url/text()}</url><user>{string($data/@*:firstname)}&#160;{string($data/@*:lastname)}</user><imagename>{string($data//@*:imagename)}</imagename><imagenote>{$data//*:note/text()}</imagenote></data>
                     else()
                else 
                    if($number = (($nid cast as xs:integer)-1)) then
                        <data><img src="{$data/*:img}" id="cropimg" alt="{$number}" class="cropimg"/><url>{$data//*:url/text()}</url><user>{string($data/@*:firstname)}&#160;{string($data/@*:lastname)}</user><imagename>{string($data//@*:imagename)}</imagename><imagenote>{$data//*:note/text()}</imagenote></data>
                    else()    

else if(fn:compare($typus,"delete")=0) then
	 let $datas := doc($savepath)//*:data[@*:id=$id]/..
    return
        if(count($datas//*:data)>1) then
            let $delete-return-status := update delete doc($savepath)//*:data[@*:id=$id]
            return
                <response>{string("delete")}</response>
        else 
            let $deletesecond-return-status := update delete doc($savepath)//*:data[@*:id=$id]/..
                return
                <response>{string("deleteAll")}</response>

else if(fn:compare($typus,"sendImage")=0) then 
    let $sendelement := doc(concat(concat($collection, $file-name), ".xml"))//*:data[@*:id=$id]
    let $askexist := doc(concat(concat($collection, $send-user), ".xml"))//*:asksends
        return
        if(empty($askexist)) then
            let $data := 
                 <xrx:asksends>
                    <xrx:asksend id="{$cropid}" user="{$file-name}">
                         <xrx:data id="{$cropid}" imagename="{string($sendelement/@imagename)}"> 
                                <xrx:img>{$sendelement/*:img/text()}</xrx:img>
                                <xrx:url>{$sendelement/*:url/text()}</xrx:url>
                                <xrx:note>{$sendelement/*:note/text()}</xrx:note>
                         </xrx:data>
                    </xrx:asksend>
                </xrx:asksends>
                   
            let $store-return-status := update insert $data following doc(concat(concat($collection,  xmldb:encode($send-user)), ".xml"))//*:info
             return
                <response>{string("send")}</response>
        else
            let $data := 
                    <xrx:asksend id="{$cropid}" user="{$file-name}">
                         <xrx:data id="{$cropid}" imagename="{string($sendelement/@imagename)}"> 
                                <xrx:img>{$sendelement/*:img/text()}</xrx:img>
                                <xrx:url>{$sendelement/*:url/text()}</xrx:url>
                                <xrx:note>{$sendelement/*:note/text()}</xrx:note>
                         </xrx:data>
                    </xrx:asksend>
                   
            let $store-return-status := update insert $data into doc(concat(concat($collection,  xmldb:encode($send-user)), ".xml"))//*:asksends
             return
                <response>{string("send")}</response>

else()
};