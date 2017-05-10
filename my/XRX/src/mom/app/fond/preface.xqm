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

module namespace preface="http://www.monasterium.net/NS/preface";

declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace ead="urn:isbn:1-931666-22-9";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";

import module namespace xrx="http://www.monasterium.net/NS/xrx"
    at "../xrx/xrx.xqm";


declare variable $preface:xsl := $xrx:live-project-db-base-collection/xsl:stylesheet[@id='eadp2html'];
declare variable $preface:params := (); 


declare function preface:preface($c){

let $intros := $c/ead:odd[./@type="intro"]
let $preface-items := ($c/ead:bioghist | $c/ead:custodhist | $c/ead:bibliography | $c/ead:odd[not(./@type="intro")] | $c/ead:otherfindaid)

return
    (
    preface:logo($c)
    ,
    preface:link-menu($preface-items, $intros)
    ,
    preface:content($c, $preface-items, $intros)
    )

};

declare function preface:logo($c){
      if ($c/ead:did/ead:dao) then
          element img {
          
          (
          attribute style {'float:right;margin:15px;'},
          
          if($c/ead:did/ead:dao/@xlink:href) then
              attribute src {$c/ead:did/ead:dao/@xlink:href}
          else ()
          ,
          if($c/ead:did/ead:dao/ead:desc) then
          attribute title {$c/ead:did/ead:dao/ead:desc}
          else ()
          )
          }				   
      else 
         ()
};

declare function preface:link-menu($preface-items, $intros){
    let $preface-heads := $preface-items/ead:head/text()
    return
    
    
    if(count($preface-heads) gt 1) then
 		<div id="preface-navi-div"> 		    
            <ol class="content-navi">
            {                            
            for $preface-item in $intros[./ead:head/text()]
               return
               <li>
                 <a href="#{ $preface-item/ead:head/text() }"> 
                 { 
                      $preface-item/ead:head/text() 
                 }
                 </a>
               </li>
            }           
            {                            
            for $preface-item in $preface-items[./ead:head/text()]
               return
               <li>
                 <a href="#{ $preface-item/ead:head/text() }"> 
                 { 
                      $preface-item/ead:head/text() 
                 }
                 </a>
               </li>
            }                            
            </ol>  	 
 		</div>
        
     else 
            ()
 };
 
declare function preface:content($c, $preface-items, $intros){
<div id="preface-content-div">
    {(
    preface:content-items($preface-items, $intros)
    ,
    preface:author($c)
    )}
</div>
};

declare function preface:content-items($preface-items, $intros){

 if (count(($preface-items[.//text()], $intros[.//text()])) gt 1) then
    <ol class="content">
        {preface:process-content-items($preface-items, $intros)}                        
    </ol>
else 
    preface:process-content-items($preface-items, $intros)
};

declare function preface:process-content-items($preface-items, $intros){                           
(
for $preface-item in $intros[.//text()]
return
     preface:content-item($preface-item, $preface-items)
,
     for $preface-item in $preface-items[.//text()]
return
     preface:content-item($preface-item, $preface-items)
)     
    
};

declare function preface:content-item($preface-item, $preface-items){
    <span>
                 {
                 if ($preface-item/ead:head/text() and count($preface-items[.//text()]) gt 1) then
                 <li>
                     <a name="{ $preface-item/ead:head/text() }"/>
                     {preface:item-head($preface-item)}
                 </li>
                else  
                    preface:item-head($preface-item)
                 }                             
                 {
                 let $preface-item-contents := $preface-item/ead:p | $preface-item/ead:bibref | $preface-item/ead:extref | $preface-item/ead:note | $preface-item/ead:dao
                 for $preface-item-content in $preface-item-contents
                     return
                        transform:transform($preface-item-content, $preface:xsl, $preface:params)
                 }

            </span>
};

declare function preface:item-head($preface-item){
    <b>
         <u>{ $preface-item/ead:head/text() }</u>
    </b>
};

declare function  preface:author($c){
     if($c/../../../ead:eadheader/ead:filedesc/ead:titlestmt/ead:author/text()) then
        <div class="author">{$c/../../../ead:eadheader/ead:filedesc/ead:titlestmt/ead:author/text()}</div>
    else ()
};


