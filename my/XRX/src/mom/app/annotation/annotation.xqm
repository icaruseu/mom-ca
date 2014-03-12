xquery version "1.0";
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

module namespace annotation="http://www.monasterium.net/NS/annotation";

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../conf/conf.xqm";

import module "http://exist-db.org/xquery/util";


declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace xrx="http://www.monasterium.net/NS/xrx";
declare namespace cei="http://www.monasterium.net/NS/cei";
declare namespace tei="http://www.monasterium.net/NS/tei";
declare namespace svg="http://www.w3.org/2000/svg";
declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace image="http://exist-db.org/xquery/image";


(: ***** Variables of annotations app ***** :)
declare variable $annotation:scope                                   := request:get-parameter("scope","0");
declare variable $annotation:charter                                 := request:get-parameter("charter","0");
declare variable $annotation:img-name                                := request:get-parameter("imgName","0");
declare variable $annotation:zone-id                                 := request:get-parameter("zoneId","0");
declare variable $annotation:svg-id                                  := request:get-parameter("svgId","0");
declare variable $annotation:collection-base-path-charter            := concat(conf:param("xrx-user-db-base-uri"), xmldb:encode($xrx:user-id), "/metadata.charter/"); 
declare variable $annotation:collection-base-path-svg                := if($annotation:scope="private")then
                                                                          concat(conf:param("xrx-user-db-base-uri"), xmldb:encode($xrx:user-id), "/metadata.svg/")
                                                                        else
                                                                          conf:param('svg-db-base-uri');
declare variable $annotation:collection-atom-base-path-svg           := if($annotation:scope="private")then
                                                                          concat(conf:param("xrx-user-atom-base-uri"), xmldb:encode($xrx:user-id), "/metadata.svg/")
                                                                        else
                                                                          conf:param('svg-atom-base-uri');
declare variable $annotation:collection-base-path-cropped-anno       := if($annotation:scope="private")then
                                                                          concat(conf:param("xrx-user-db-base-uri"), xmldb:encode($xrx:user-id), "/metadata.cropped-annotation/")
                                                                        else
                                                                          conf:param('cropped-anno-db-base-uri');
declare variable $annotation:collection-atom-base-path-cropped-anno  := if($annotation:scope="private")then
                                                                          concat(conf:param("xrx-user-atom-base-uri"), xmldb:encode($xrx:user-id), "/metadata.cropped-annotation/")
                                                                        else
                                                                          conf:param('cropped-anno-atom-base-uri');

(: ************************************
    Functions of the annotation module to 
    - create
    - edit
    - publish
    annotations/ cropped images
    - get metadata bindings of widgets
   ************************************ :)

(: create rect- tag for svg file :)
declare function annotation:create-rect-svg($metadata, $svg-file) as item()* {
(: POST- params :)
let $x        := substring-before(substring-after($metadata, 'x='), '?!;')
let $y        := substring-before(substring-after($metadata, 'y='), '?!;')
let $width    := substring-before(substring-after($metadata, 'width='), '?!;')
let $height   := substring-before(substring-after($metadata, 'height='), '?!;')

(: create rect- tag :)
let $rect-tag :=
        <rect id="{ $annotation:zone-id }" x="{ $x }" y="{ $y }" width="{ $width }" height="{ $height }" style="stroke:red;stroke-width:2;fill-opacity:0;" onClick="javascript:jQuery(document).imageTool.showMetadata('{ $annotation:zone-id }');"/>

(: insert rect- tag into SVG- file XML :)
let $exist-rect-tag  := $svg-file//*:rect
let $insert-svg       := 
                        if(empty($exist-rect-tag))then
                          update insert $rect-tag following $svg-file//*:image
                        else
                          let $exist-major-rect := $svg-file//*:rect[xs:integer(@width) gt xs:integer($width) or xs:integer(@height) gt xs:integer($height)]
                          return
                            if(empty($exist-major-rect))then
                              update insert $rect-tag preceding $svg-file//*:image/*:rect[1]
                            else
                              update insert $rect-tag following $exist-major-rect[last()]
return
    $svg-file
};

(: create new svg file :)
declare function annotation:create-new-svg-file($metadata, $collection-id as xs:string) as item()* {
(: POST- params :)
let $width       := substring-before(substring-after($metadata, 'width='), '?!;')
let $height      := substring-before(substring-after($metadata, 'height='), '?!;')
let $src         := substring-before(substring-after($metadata, 'src='), '?!;')
let $viewport    := concat("0 0 ", $width, " ", $height)

(: create basis svg file :)
let $svg-file := 
  <atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
    <atom:id>{ concat("tag:www.monasterium.net,2011:/svg/", $collection-id, "/", $annotation:charter, "/", $annotation:svg-id) }</atom:id>
    <atom:title/>
    <atom:published></atom:published>
    <atom:updated></atom:updated>
    <atom:author>
        <atom:email/>
    </atom:author>
    <app:control xmlns:app="http://www.w3.org/2007/app">
        <app:draft>no</app:draft>
    </app:control>
    <atom:content type="application/xml">
      <svg xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns="http://www.w3.org/2000/svg" xmlns:svg="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:cc="http://creativecommons.org/ns#" id="{ $annotation:svg-id }" class="zoomable" style="width:100%;height:100%;" version="1.0" viewBox="{ $viewport }" preserveAspectRatio="xMinYMin slice">
          <image id="svg_img" x="0" y="0" width="100%" height="100%" xlink:href="{ $src }">
              <title>{ $annotation:svg-id }</title>
          </image>
      </svg>
    </atom:content>
  </atom:entry>
return  
    $svg-file
};

(: delete annotation rect in svg file :)
declare function annotation:delete-rect-svg() as item()* {
  (: get svg- file :)
  let $svg-file :=  collection($annotation:collection-base-path-svg)//*:svg[@id = xs:string($annotation:svg-id)]
  return 
    update delete $svg-file//*:rect[@id=$annotation:zone-id]
};

(: crop annotation :)
declare function annotation:crop-annotation($metadata, $collection-id as xs:string) as item()* {
(: POST- params :)
let $x                    := substring-before(substring-after($metadata, 'x='), '?!;')
let $y                    := substring-before(substring-after($metadata, 'y='), '?!;')
let $width                := substring-before(substring-after($metadata, 'width='), '?!;')
let $height               := substring-before(substring-after($metadata, 'height='), '?!;')
let $pathToBinaryResource := replace(substring-before(substring-after($metadata, 'imgUrl='), '?!;'), " ", "%20")

(: get image file :)
let $img := httpclient:get(xs:anyURI($pathToBinaryResource), true(), <headers><header name="User-Agent" value="User-Agent: Mozilla/4.0"/></headers>)
(: crop image :)
let $cropped-image := image:crop($img/*[2]/text(), (xs:integer($x), xs:integer($y), xs:integer($height), xs:integer($width)), 'image/jpeg')
(: create file of cropped image :)
let $cropped-image-file :=
  <atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
    <atom:id>{ concat("tag:www.monasterium.net,2011:/annotation-image/", $collection-id, "/", $annotation:charter, "/", $annotation:zone-id) }</atom:id>
    <atom:title/>
    <atom:published></atom:published>
    <atom:updated></atom:updated>
    <atom:author>
        <atom:email/>
    </atom:author>
    <app:control xmlns:app="http://www.w3.org/2007/app">
        <app:draft>no</app:draft>
    </app:control>
    <atom:content type="application/xml">
      <xrx:annotation id="{$annotation:zone-id}">
         <xrx:img>{ concat('data:image/jpeg;base64,', $cropped-image) }</xrx:img>
      </xrx:annotation>
    </atom:content>
  </atom:entry>
return 
  $cropped-image-file
};

(: get binding of tag :)
declare function annotation:get-binding($node-path as xs:string, $index as xs:string) as item()* {
(: ************************************  

   binding construct because of editor elements
   <repeat> repeating elements bool- value
   <bind>   binding for input field
   <ref>    reference elment for repeating element
   <index>  index of repeating element

  ToDo: export to resource element which is used in XML- editor and this function

   ************************************ :)
  let $binding :=
     if(contains($node-path, "cei:idno"))then
       <binding>
        <repeat>false</repeat>
        <bind>{ xs:string('bidno') }</bind>
       </binding>
     else if(contains($node-path, "cei:abstract"))then
       <binding>
        <repeat>false</repeat>
        <bind>{ xs:string('babstract') }</bind>
       </binding>
     else if(contains($node-path, "cei:issued") and contains($node-path, "cei:dateRange"))then
       <binding>
        <repeat>false</repeat>
        <bind>{ xs:string('bissued-date-range') }</bind>
       </binding>
     else if(contains($node-path, "cei:issued") and contains($node-path, "cei:placeName"))then
       <binding>
        <repeat>false</repeat>
        <bind>{ xs:string('bissued-place') }</bind>
       </binding>
     else if(contains($node-path, "cei:tenor"))then
       <binding>
        <repeat>false</repeat>
        <bind>{ xs:string('btenor') }</bind>
       </binding>
     else if(contains($node-path, "cei:sourceDescVolltext"))then
       <binding>
        <repeat>true</repeat>
        <bind>{ xs:string('bsource-desc-tenor') }</bind>
        <ref>{ xs:string('/child::cei:bibl') }</ref>
        <index>{ $index }</index>
       </binding>
     else if(contains($node-path, "cei:sourceDescRegest"))then
       <binding>
        <repeat>true</repeat>
        <bind>{ xs:string('bsource-desc-abstract') }</bind>
        <ref>{ xs:string('/child::cei:bibl') }</ref>
        <index>{ $index }</index>
       </binding>
     else if(contains($node-path, "cei:witnessOrig") and contains($node-path, "cei:figure"))then
       <binding>
        <repeat>true</repeat>
        <bind>{ xs:string('borig') }</bind>
        <ref>{ xs:string('/child::cei:figure') }</ref>
        <index>{ $index }</index>
       </binding>
     else if(contains($node-path, "cei:witnessOrig") and contains($node-path, "cei:nota"))then
       <binding>
        <repeat>true</repeat>
        <bind>{ xs:string('borig') }</bind>
        <ref>{ xs:string('/child::cei:nota') }</ref>
        <index>{ $index }</index>
       </binding>
     else if(contains($node-path, "cei:witnessOrig") and contains($node-path, "cei:traditioForm"))then
       <binding>
        <repeat>false</repeat>
        <bind>{ xs:string('borig-traditio-form') }</bind>
       </binding>
     else if(contains($node-path, "cei:witnessOrig") and contains($node-path, "cei:archIdentifier"))then
       <binding>
        <repeat>false</repeat>
        <bind>{ xs:string('borig-arch-identifier') }</bind>
       </binding>
    else if(contains($node-path, "cei:witnessOrig") and contains($node-path, "cei:material"))then
       <binding>
        <repeat>false</repeat>
        <bind>{ xs:string('borig-material') }</bind>
       </binding>
    else if(contains($node-path, "cei:witnessOrig") and contains($node-path, "cei:dimensions"))then
       <binding>
        <repeat>false</repeat>
        <bind>{ xs:string('borig-dimensions') }</bind>
       </binding>
    else if(contains($node-path, "cei:witnessOrig") and contains($node-path, "cei:condition"))then
       <binding>
        <repeat>false</repeat>
        <bind>{ xs:string('borig-condition') }</bind>
       </binding>
    else if(contains($node-path, "cei:witnessOrig") and contains($node-path, "cei:sealDesc"))then
       <binding>
        <repeat>false</repeat>
        <bind>{ xs:string('borig-seal-desc') }</bind>
       </binding>
    else if(contains($node-path, "cei:witnessOrig") and contains($node-path, "cei:notariusDesc"))then
       <binding>
        <repeat>false</repeat>
        <bind>{ xs:string('borig-notarius-desc') }</bind>
       </binding>
    else if(contains($node-path, "cei:witListPar") and contains($node-path, "cei:figure"))then
       <binding>
        <repeat>true</repeat>
        <bind>{ xs:string('bpar') }</bind>
        <ref>{ xs:string('/child::cei:figure') }</ref>
        <index>{ $index }</index>
       </binding>
    else if(contains($node-path, "cei:witListPar") and contains($node-path, "cei:nota"))then
       <binding>
        <repeat>true</repeat>
        <bind>{ xs:string('bpar') }</bind>
        <ref>{ xs:string('/child::cei:nota') }</ref>
        <index>{ $index }</index>
       </binding>
    else if(contains($node-path, "cei:witListPar") and contains($node-path, "cei:traditioForm"))then
       <binding>
        <repeat>false</repeat>
        <bind>{ xs:string('bpar-traditio-form') }</bind>
       </binding>
    else if(contains($node-path, "cei:witListPar") and contains($node-path, "cei:archIdentifier"))then
       <binding>
        <repeat>false</repeat>
        <bind>{ xs:string('bpar-arch-identifier') }</bind>
       </binding>
    else if(contains($node-path, "cei:witListPar") and contains($node-path, "cei:material"))then
       <binding>
        <repeat>false</repeat>
        <bind>{ xs:string('bpar-material') }</bind>
       </binding>
    else if(contains($node-path, "cei:witListPar") and contains($node-path, "cei:dimensions"))then
       <binding>
        <repeat>false</repeat>
        <bind>{ xs:string('bpar-dimensions') }</bind>
       </binding>
    else if(contains($node-path, "cei:witListPar") and contains($node-path, "cei:condition"))then
       <binding>
        <repeat>false</repeat>
        <bind>{ xs:string('bpar-condition') }</bind>
       </binding>
    else if(contains($node-path, "cei:witListPar") and contains($node-path, "cei:sealDesc"))then
       <binding>
        <repeat>false</repeat>
        <bind>{ xs:string('bpar-seal-desc') }</bind>
       </binding>
    else if(contains($node-path, "cei:witListPar") and contains($node-path, "cei:notariusDesc"))then
       <binding>
        <repeat>false</repeat>
        <bind>{ xs:string('bpar-notarius-desc') }</bind>
       </binding>
    else if(contains($node-path, "cei:witListPar") and contains($node-path, "cei:notariusDesc"))then
       <binding>
        <repeat>false</repeat>
        <bind>{ xs:string('bpar-notarius-desc') }</bind>
       </binding>
    else if(contains($node-path, "cei:diplomaticAnalysis") and contains($node-path, "cei:p"))then
       <binding>
        <repeat>true</repeat>
        <bind>{ xs:string('bdiplomaticAnalysis') }</bind>
        <ref>{ xs:string('/child::cei:p') }</ref>
        <index>{ $index }</index>
       </binding>
    else if(contains($node-path, "cei:diplomaticAnalysis") and contains($node-path, "cei:nota"))then
       <binding>
        <repeat>true</repeat>
        <bind>{ xs:string('bdiplomaticAnalysis') }</bind>
        <ref>{ xs:string('/child::cei:nota') }</ref>
        <index>{ $index }</index>
       </binding>
    else if(contains($node-path, "cei:diplomaticAnalysis") and contains($node-path, "cei:listBibl") and contains($node-path, "cei:bibl"))then
       <binding>
        <repeat>true</repeat>
        <bind>{ xs:string('blistBibl') }</bind>
        <ref>{ xs:string('/child::cei:bibl') }</ref>
        <index>{ $index }</index>
       </binding>
    else if(contains($node-path, "cei:diplomaticAnalysis") and contains($node-path, "cei:listBiblEdition") and contains($node-path, "cei:bibl"))then
       <binding>
        <repeat>true</repeat>
        <bind>{ xs:string('blistBiblEdition') }</bind>
        <ref>{ xs:string('/child::cei:bibl') }</ref>
        <index>{ $index }</index>
       </binding>
    else if(contains($node-path, "cei:diplomaticAnalysis") and contains($node-path, "cei:listBiblRegest") and contains($node-path, "cei:bibl"))then
       <binding>
        <repeat>true</repeat>
        <bind>{ xs:string('blistBiblRegest') }</bind>
        <ref>{ xs:string('/child::cei:bibl') }</ref>
        <index>{ $index }</index>
       </binding>
    else if(contains($node-path, "cei:diplomaticAnalysis") and contains($node-path, "cei:listBiblFaksimile") and contains($node-path, "cei:bibl"))then
       <binding>
        <repeat>true</repeat>
        <bind>{ xs:string('blistBiblFaksimile') }</bind>
        <ref>{ xs:string('/child::cei:bibl') }</ref>
        <index>{ $index }</index>
       </binding>
    else if(contains($node-path, "cei:diplomaticAnalysis") and contains($node-path, "cei:listBiblErw") and contains($node-path, "cei:bibl"))then
       <binding>
        <repeat>true</repeat>
        <bind>{ xs:string('blistBiblErw') }</bind>
        <ref>{ xs:string('/child::cei:bibl') }</ref>
        <index>{ $index }</index>
       </binding>
    else if(contains($node-path, "cei:diplomaticAnalysis") and contains($node-path, "cei:quoteOriginaldatierung"))then
       <binding>
        <repeat>false</repeat>
        <bind>{ xs:string('bquoteOriginaldatierung') }</bind>
       </binding> 
    else if(contains($node-path, "cei:back") and contains($node-path, "cei:divNotes"))then
       <binding>
        <repeat>true</repeat>
        <bind>{ xs:string('bdiv-notes') }</bind>
        <ref>{ xs:string('/child::cei:note') }</ref>
        <index>{ $index }</index>
       </binding>
    else if(contains($node-path, "cei:back") and contains($node-path, "cei:persName"))then
       <binding>
        <repeat>true</repeat>
        <bind>{ xs:string('bback') }</bind>
        <ref>{ xs:string('/child::cei:persName') }</ref>
        <index>{ $index }</index>
       </binding>
    else if(contains($node-path, "cei:back") and contains($node-path, "cei:placeName"))then
       <binding>
        <repeat>true</repeat>
        <bind>{ xs:string('bback') }</bind>
        <ref>{ xs:string('/child::cei:placeName') }</ref>
        <index>{ $index }</index>
       </binding>
    else if(contains($node-path, "cei:back") and contains($node-path, "cei:index"))then
       <binding>
        <repeat>true</repeat>
        <bind>{ xs:string('bback') }</bind>
        <ref>{ xs:string('/child::cei:index') }</ref>
        <index>{ $index }</index>
       </binding>
    else if(contains($node-path, "cei:lang_MOM"))then
       <binding>
        <repeat>false</repeat>
        <bind>{ xs:string('blang-mom') }</bind>
       </binding> 
    else
       xs:string('no-binding')
  return
      $binding
};

(: get html binding of tag :)
declare function annotation:get-html-binding($node-path as xs:string) as item()* {
  (: define binding because of charter widget :)
  let $binding :=
     if(contains($node-path, "cei:idno"))then
       <binding>{ xs:string('idno-num') }</binding>
     else if(contains($node-path, "cei:abstract"))then
       <binding>{ xs:string('abstract') }</binding>
     else if(contains($node-path, "cei:issued"))then
       <binding>{ xs:string('abstract') }</binding>
     else if(contains($node-path, "cei:tenor"))then
       <binding>{ xs:string('tenor') }</binding>
     else if(contains($node-path, "cei:sourceDescVolltext"))then
       <binding>{ xs:string('tenor') }</binding>
     else if(contains($node-path, "cei:sourceDescRegest"))then
       <binding>{ xs:string('abstract') }</binding>
     else if(contains($node-path, "cei:witnessOrig") or contains($node-path, "cei:witListPar"))then
       <binding>{ xs:string('witList') }</binding>
    else if(contains($node-path, "cei:diplomaticAnalysis"))then
       <binding>{ xs:string('diplomaticAnalysis') }</binding>
    else if(contains($node-path, "cei:back") and contains($node-path, "cei:divNotes"))then
       <binding>{ xs:string('index') }</binding>
    else if(contains($node-path, "cei:lang_MOM"))then
       <binding>{ xs:string('diplomaticAnalysis') }</binding> 
    else
       xs:string('no-binding')
  return
      $binding
};

(: get jsax path of annotation tag :)
declare function annotation:get-jsax-path($xpath-to-node as xs:string) as item()* {
  let $base-string      := substring-after($xpath-to-node, "cei:body/")
  let $single-elements  := tokenize($base-string, "/") 
  let $cleaned-elements := 
      for $single-element in $single-elements
      return
        if(contains($single-element, "["))then
          concat("/child::", substring-before($single-element, "["))
        else
          concat("/child::", $single-element)
  let $joined-string    := string-join($cleaned-elements)
  let $jsax-path        := concat("/descendant::cei:body", $joined-string)
  return
    $jsax-path
};

(: extract charter id from atom:id :)
declare function annotation:get-charter-id($atom-id as xs:string) as item()*{
  let $tokens := local:object-uri-tokens($atom-id)
  return
    $tokens[2]
};

(: extract metadata of selected cropped image (annotation) and create response :)
declare function annotation:create-cropped-image-metadata($cropped-anno as node()*, $side as xs:string, $number as xs:string) as item()*{
let $anno-id           := xs:string($cropped-anno//xrx:annotation/@id)
let $atomid            := $cropped-anno/atom:id/text()
let $charter           := annotation:get-charter-id($atomid)
let $image             := $cropped-anno//xrx:annotation/xrx:img/text()
let $charter-file      := collection($annotation:collection-base-path-charter)//atom:id[ends-with(., $charter)]/parent::atom:entry
(: search for anno ID in facs attribut :)
let $searched-tag      := $charter-file//cei:*[@facs = $anno-id]
let $metadata          :=
    if(empty($searched-tag))then 
       <metadata>
         <relationStatus>{ xs:string("broken") }</relationStatus>
         <annoId>{ $anno-id }</annoId>
       </metadata>
    else
       (: get metadata content of annotation :)
       let $content           := $searched-tag/text()
       let $searched-tag-name := node-name($searched-tag)
       let $desc              := $charter-file//cei:zone[@id = $anno-id]/cei:desc/text()
       return                      
          <metadata>
             <relationStatus>{ xs:string("ok") }</relationStatus>
             <annoId>{ $anno-id }</annoId>
             <related>{ $searched-tag-name }</related>
             <content>{ $content }</content>
             <desc>{ $desc }</desc>
         </metadata>
return
  if(fn:compare($side,"left")=0) then
    <data><img src="{ $image }" id="collection-leftImg" alt="{ $number }" class="img"/>{ $metadata }</data>
  else 
    <data><img src="{ $image }" id="collection-rightImg" alt="{ $number }" class="img"/>{ $metadata }</data>
};

(: Helper- function to analyze atomID :)
declare function local:object-uri-tokens($atom-id as xs:string) as xs:string* {
    let $object-uri := substring-after($atom-id, conf:param('atom-tag-name'))
    let $object-uri-tokens := tokenize($object-uri, '/')
    return
    subsequence($object-uri-tokens, 3)
};
