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

module namespace mycollection="http://www.monasterium.net/NS/mycollection";


declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace xrx="http://www.monasterium.net/NS/xrx";
declare namespace cei="http://www.monasterium.net/NS/cei";
import module namespace i18n="http://www.monasterium.net/NS/i18n" 
    at "../i18n/i18n.xqm";
import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../xrx/conf.xqm";
import module namespace user="http://www.monasterium.net/NS/user"
    at "../user/user.xqm";
import module namespace template="http://www.monasterium.net/NS/template"
    at "../xrx/template.xqm";
import module namespace metadata="http://www.monasterium.net/NS/metadata"
    at "../metadata/metadata.xqm";
    
declare variable $mycollection:template := template:get("tag:www.monasterium.net,2011:/mom/template/mycollection-charter");
    
declare function mycollection:linked-fond-charter-base-collection($collection-base-collection) {

    let $linked-fonds-atomid := $collection-base-collection//cei:text[@type='fond']/@id/string()
    let $linked-fonds-fondid := 
        for $id in $linked-fonds-atomid 
        return 
        tokenize($id, '/')[last()]
    let $linked-fonds-archiveid :=
        for $id in $linked-fonds-atomid 
        return tokenize($id, '/')[last() - 1]
    let $linked-fond-charter-base-collection :=
        for $id at $pos in $linked-fonds-atomid 
        return metadata:base-collection('charter', ($linked-fonds-archiveid[$pos], $linked-fonds-fondid[$pos]), 'public')
    return
    $linked-fond-charter-base-collection
};

declare function mycollection:uuid($base-collection) as xs:string {

    let $uuid := util:uuid()
    return
    if(exists($base-collection//atom:id[ends-with(., $uuid)])) then mycollection:uuid($base-collection)
    else $uuid
};

declare function mycollection:is-public($entry as element(atom:entry)) as xs:boolean {

    xs:string($entry/xrx:sharing/xrx:visibility/text()) = 'public'
};

declare function mycollection:owner($entry as element(atom:entry)) as xs:string* {

    let $collection-name := util:collection-name($entry)
    let $userid := xmldb:decode(substring-before(substring-after($collection-name, 'xrx.user/'), '/'))
    return
    $userid
};

declare function mycollection:key($entry as element(atom:entry)) as xs:string* {

    let $atomid := $entry/atom:id/text()
    let $tokens := tokenize($atomid, '/')
    let $key := $tokens[3]
    return
    $key
};

declare function mycollection:link($entry as element(atom:entry)) as xs:string* {

    let $key := mycollection:key($entry)
    return
    concat(conf:param('request-root'), $key, '/mycollection')
};

declare function mycollection:charter-new-empty($atom-id as xs:string, $charter-id as xs:string, $charter-name) {

    let $template := template:get('tag:www.monasterium.net,2011:/mom/template/mycollection-charter', false())
    let $xslt := 
    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xrx="http://www.monasterium.net/NS/xrx"
        xmlns:cei="http://www.monasterium.net/NS/cei"
        xmlns:atom="http://www.w3.org/2005/Atom" version="1.0">
      <xsl:template match="//atom:id">
        <xsl:element name="atom:id">
          <xsl:text>{ $atom-id }</xsl:text>
        </xsl:element>
      </xsl:template>
      <xsl:template match="//cei:body/cei:idno">
        <xsl:element name="cei:idno">
          <xsl:attribute name="id">{ $charter-id }</xsl:attribute>
          <xsl:text>{ $charter-name }</xsl:text>
        </xsl:element>
      </xsl:template>
      <xsl:template match="@*|*" priority="-2">      
        <xsl:copy>
          <xsl:apply-templates select="@*|node()" />         
        </xsl:copy>
      </xsl:template>
    </xsl:stylesheet>
    return
    transform:transform($template, $xslt, ())
};

declare function mycollection:charter-new-version($atom-id as xs:string, $charter-id as xs:string, $charter-name as xs:string, $linked-charter-atomid as xs:string?) {

    let $template := template:get('tag:www.monasterium.net,2011:/mom/template/mycollection-charter', false())
    let $xslt := 
    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xrx="http://www.monasterium.net/NS/xrx"
        xmlns:cei="http://www.monasterium.net/NS/cei"
        xmlns:atom="http://www.w3.org/2005/Atom" 
        version="1.0">
      <xsl:template match="//atom:id">
        <xsl:element name="atom:id">
          <xsl:text>{ $atom-id }</xsl:text>
        </xsl:element>
      </xsl:template>
      <xsl:template match="//atom:content">
          <atom:link rel="versionOf" ref="{ $linked-charter-atomid }"/>
        <xsl:element name="atom:content">
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:template>
      <xsl:template match="//cei:body/cei:idno">
        <xsl:element name="cei:idno">
          <xsl:attribute name="id">{ $charter-id }</xsl:attribute>
          <xsl:text>{ $charter-name }</xsl:text>
        </xsl:element>
      </xsl:template>
      <xsl:template match="@*|*" priority="-2">
        <xsl:copy>
          <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
      </xsl:template>
    </xsl:stylesheet>
    return
    transform:transform($template, $xslt, ())
};

 (: Load Charter and check, if all necessary Nodes from the Template are available:)
 declare function mycollection:checkUpdateCharter($charter as element())  {

    (: Iterate through Template
    ~ and look, if every Node inside the Template is present inside the charter.
    ~ If not, add node to parent.
    :)
  
    let $return := 
        for $node in $mycollection:template//*
            
            (: Get Parent of the Template-Node inside the Charter :)
            let $parent := $charter//*[node-name(.) = node-name($node/..)]
            
            (: Does current Node from the Template exists inside the Charter:)
            let $Current_Node := mycollection:node-exists($charter, $node)

            let $updateinsert :=
                (: If Node not found, copy Node from template and put it into the charter :)
                if(not($Current_Node)) then
                    (   
                        update insert $node into $parent
                    )
                else
                    ()
                    
            return
                $updateinsert
    return ()
 };
 
(: Check, if all Nodes from a Template exist inside in an another Document :)
declare function mycollection:node-exists ($nodeSet as node(), $nodeToFind as node() )  as xs:boolean* {

    (: Get Parent of the Template-Node inside the Charter :)
    let $parent := $nodeSet//*[node-name(.) = node-name($nodeToFind/..)]
            
    (: Get all Nodes from the submited Node:)
    let $curSearch := $parent/*[node-name(.) = node-name($nodeToFind)]

    (: If Nodes are present, return True() otherwise False() :)
    let $test := if(exists($curSearch)) then true() else false()
      
    return
        $test
    
 } ;
 
(: Get occurences of Node :)
declare function mycollection:get-counter($charter as element(), $node as element()) as xs:string {
    (: To ensure that multiple nodes are inside the same hierarchy, search within grandparent/parent/child_to_test :)
    let $grandparent :=  $charter//*[node-name(.) = node-name($node/../..)]
    let $parent := $grandparent/*[node-name(.) = node-name($node/..)]
    let $tes :=   $parent/*[node-name(.) = node-name($node)]
    
    (: Return Occurency as String:)
    return
        string(count($tes))
};

(: Build Name for Bindings :)
declare function mycollection:buildNodeName($charter as element(), $pos as xs:string, $node as element()) as xs:string {
                
  (: Get Node from Charter:)
  let $node_orig := mycollection:returnNode($charter, mycollection:path-to-node($node, true())) 
  
  (: Get local name for parent
  ~ Nodename: cei:date
  ~ Localname: date
   :)
  let $nodename_parent := local-name($node_orig/..)
  
  (: Get local name for current Node:)
  let $nodename := local-name($node_orig)
  
  (: Build Binding-Name :)
  let $nodename_complete := concat("b-",$pos, "-", $nodename_parent, "-", $nodename)
  
  return
    $nodename_complete
};

(: Create a map of all non-existing nodes and return an Element of disting mappings with individual occurences 
    ~ Occurence and Path of the individual Node is inside the Object
    ~ <mappings>
    ~  <mapping>
    ~    <occurence></occurence>
    ~    <path></path>
    ~  </mapping>
    ~</mappings>
:)
declare function mycollection:disctinct-mappings($charter as element(), $nodes as element()*) as element()* {
  let $map := map:new()

  (: Build mapping structure
  ~  Item contains Path to Node and Occurence as string
  :)
  let $testmap :=
    <mappings> {
    (: Iterate through all Nodes which aren't available inside the Template:)
    for $node at $pos in $nodes
            
            (: Get Path to Node :)
            let $path_of_node := mycollection:path-to-node($node, true())
            (: Get Occurence of Node :)
            let $count := mycollection:get-counter($charter, $node)
            (: If not there, insert Item to map :)
            let $map := if(not(map:contains($map, $path_of_node ))) then
                    map:new(($map, map{$path_of_node := $count}))
                else
                    ()
            (: Build individual Mapping Item:)
        let $elements :=
        element mapping {
            element path {map:keys($map)}, 
            element occurence {$map($path_of_node)}
            }
        return
            $elements
    }
    </mappings>

    (: Make Map distinct 
    ~ e.g. Charter has two graphic-declarations
    ~ so missing-node-item contains cei:graphic twice
    ~ This function makes this mapping-item unique and returns the path & occurence
    :)
    let $return :=
        for $key in mycollection:distinct-deep($testmap/*)
            let $value := $map($key)
            group by $value
            return
                ($key, $value)  
                
    return
        $return
};

(: Return individual Token from the Path-String 
~ e.g. complete Path is /descendant::cei:issued/child::cei:date
~ if called with $deep =
~  "parent"       => Return is cei:issued
~  "main"         => Return is cei:date
~  "parent_token" => Return is descendant::cei:issued
~  "main_token"   => Return is child::cei:date
~ 
~ Needed for Building the Bindings and the Binds of the Textcontrols
:)
declare function mycollection:getParentName($querynode as xs:string, $deep as xs:string) as xs:string {
    (: Make Tokens of the Query-/Pathstring:)
    let $token := tokenize($querynode, "/")
    
    (: Get Parent Token 
    ~ Parent-Token is [2] because of an empty sequence before the first "/"
    :)
    let $parent_token := $token[2]
    (: Get Main Token:)
    let $main_token := $token[3]
    (: extract Parent cei-Tag-Name :)
    let $parent := substring-after($token[2], "::")
    (: extract Main cei-Tag-Name :)
    let $main := substring-after($main_token, "::")
    
    (: Returnvalue in dependence of calling:)
    let $return := 
      if($deep = "parent") then $parent 
      else 
        if ($deep = "main") then $main 
        else 
          if($deep = "main_token") then $main_token 
          else 
            if($deep= "parent_token") then $parent_token 
            else ()
      
    return
      $return
    
};

(: Get Node from a Nodeset and a Path:)
declare function mycollection:returnNode($charter as element(), $querynode as xs:string) as element() {

    (: Get Parent node from the charter via querystring:)
    let $node_par := $charter//*[node-name(.)=QName("http://www.monasterium.net/NS/cei", mycollection:getParentName($querynode, "parent"))]
    
    (: Get Node from the Parent via Querystring:) 
    let $node_main := $node_par/*[node-name(.)=QName("http://www.monasterium.net/NS/cei", mycollection:getParentName($querynode, "main")) ] 
    
    return
      (: Return the 1 occurence:)
        $node_main[1]
};
 
(: Automatically generate Bindungs from File :)
declare function mycollection:makeBindings($charter as element(), $nodes as element()*) as element()* {
    (: Make Disctinct Mappings :)
    let $mapping := mycollection:disctinct-mappings($charter, $nodes)
    
    (: Build Binding-Div :)
    let $return := 
      element div {
      attribute class {"xrx-binds"},
      attribute style {"display:none"},
      
      (: Iterate through all distinct mappings :)
      for $node at $pos in $mapping
          
          (: Get path from mapping item :)
          let $path_orig := $node/path
          
          (: Get occurence from mapping item :)
          let $occurences := $node/occurence
          
          (: Get original Node from the Charter with the Path from the Mapping Item :)
          let $node_orig := mycollection:returnNode($charter, $path_orig)
          
          (: Build Binding-Name:)
          let $nodename_complete := mycollection:buildNodeName($charter, string($pos), $node_orig)
           
          (: If the node has multiple occurences, build path to node individualy 
          ~ Node exists only once -> path complete /descendant::cei:issued/child::cei:date
          ~ Node exists multiple times -> just /descendant::cei:issued
          ~ It is important for handling the bindings and the "<xrx:repeat>"
          :)
          let $path :=
            if($occurences > 1) then
              mycollection:path-to-node($node_orig, false())
            else
              mycollection:path-to-node($node_orig, true())
  
          return
          
            (: build div-element for the binding-section:)
              element div {
                  attribute class {"xrx-bind"},
                  attribute id {$nodename_complete},
                  attribute data-xrx-nodeset {$path}
  
              }  
       }
       
    (: Return all new bindings :)
    return
       $return
};

(: Returnvalue = return all non existing Nodes 
~ is called inside my-collection-charter-edit.widget.xml
~ returns all non present nodes
:)
declare function mycollection:return-not-existend-nodes ( $charter_ as element() ) as element()* {
  
      (: Set Collection :)
    let $base-collection := metadata:base-collection('charter', 'saved')
    
    (: Load Charter :)
    let $charter := $charter_/atom:content/cei:text
    
    (: Iterate through charter :)
    let $return :=
        for $node in $charter//*
        
            (: Does current Node from the Template exists inside the Charter:)
            let $isNotPresent_item := if(not(mycollection:node-exists($mycollection:template, $node))) then $node else ()
            
            return
              $isNotPresent_item

    return
        $return
};
(: Returnvalue = false if some node is missing inside the template 
~ is called from my-collection-charter-edit.widget.xml
:)
declare function mycollection:check-if-all-nodes-there ( $charter as element() ) as xs:boolean {
    
    let $return :=
        for $node in $charter//*
        
            (: Does current Node from the Template exists inside the Charter:)
            let $isPresent := mycollection:node-exists($mycollection:template, $node)
            
            return
              $isPresent
    
    (: 
    ~ Iterate though all Nodes. node-exists returns false, if one Node isn't present inside the Template.
    ~ If string contains false, set false-flag for for ReturnValue
    ~Return:  false is one (or more) nodes are not inside the Template
    ~         true if all nodes are inside the Template
    :)
    let $value :=
        if(contains($return,"false")) then
            false()
        else
            true()
 (: Returnvalue = false if some node is missing inside the template :)   
    return
        $value
};

(: Make Controlls and returns them to the calling Widget 
~ is called my-collection-charter-edit.widget.xml
:)
declare function mycollection:MakeControlls ( $charter as element()*, $nodes-not-there as element()* ) as element()* {

    (: Get distinct Nodes :)
    let $mapping := mycollection:disctinct-mappings($charter, $nodes-not-there)
    
    (: Build Controls :)
    let $return :=
        for $mapped_item at $pos in $mapping
            
            (: Does current Node from the Template exists inside the Charter
            ~ if not, make Textcontrol :)
            let $node := mycollection:returnNode($charter, data($mapped_item/path))
            
            (: Generate Binding Name:)
            let $bindingname := mycollection:buildNodeName($charter, string($pos), $node)
            
            (: Create Textarea in dependency of Occurence; Return Control :)
            let $control := mycollection:createControl($bindingname, local-name($node), $mapped_item)
                            
            return
              $control

    return
      (: Insert Controls inside Tabpage-8:)
      <div data-demoid="0a11e85c-34fc-11e5-a151-feff819cdc9f" id="tab-8">
       { $return }
      </div>
};

(: Prepare Creation of Textarea with Bindings or References :)
declare function mycollection:createControl($bindname as xs:string, $localname as xs:string, $mapping_element as element()) as element()* {

  (: Get Path of mapped Item :)
  let $path := $mapping_element/path
  (: Get Occurence of mapped Item :)
  let $occur := $mapping_element//*[string(.) = $path/../occurence]
  (: Get Parent-Token :)
  let $parent := concat("/", mycollection:getParentName($path, "main_token") )
  
  (: Build Visual-XML statement 
  ~ ToDo: Reconstruction of CreateTextarea
  ~ If occures multiple Times, insert Ref- else Bind-Attribute
  :)
  let $xrx :=
     if($occur = "1") then
      <xrx:visualxml bind="{$bindname}"/>
     else
      <xrx:visualxml ref="{$parent}"/>
    
  return
  
    (: Call Creation of Textarea :)
    mycollection:createTextarea($xrx, $localname, $occur, $bindname)
};

(: Build and return Textarea-Controls:)
declare function mycollection:createTextarea($child as element(xrx:visualxml), $name as xs:string, $occur as xs:string, $bindingname as xs:string) as element()* {

  (: Make Label-Element :)
  let $elem :=
        element div {
          attribute class {"dlabel"},
          attribute data-demoid {"388b9531-459f-48b5-88fc-b466a2141592"},
          element span {
            attribute class {"dlabel-text"},
            (mycollection:createMessages($name))
          }
        }
  (: Build Textarea for single use only:)
  let $text := mycollection:buildTextarea($child)

  (: Build Textarea for multiple uses:)
  let $text_multiple := 
      element div {
          attribute class {"xrx-repeat"},
          attribute data-xrx-bind {$bindingname},
          mycollection:buildTextarea($child)
          }


  (: If Node exists only once, don't make repeat-section
  ~ otherwise build repeat-section
  ~ To Do - Make dynamically in dependency of Schema
  :)
  let $return :=
    if($occur = "1") then 
      ($elem, $text) 
    else 
      ($elem, $text_multiple)
  return
    $return

};

(: Get Message from i18n-Module:)
declare function mycollection:createMessages($name as xs:string) as xs:string {
 
 (: Get Message from cei_[Localname]-Item 
 ~ in dependency of the current language
 :)
 let $msg := i18n:value(concat("cei_", $name), request:get-parameter('lang', $xrx:lang))
 (: If Message is empty, take localname as Message :)
 let $i18n := if(string-length($msg) != 0) then
                $msg
              else
                $name
    
  return
   $i18n
};

(: Build Textelement :)
declare function mycollection:buildTextarea($child as element()) as element()* {
  (: Build xHTML Textarea-Tag:)
  let $return :=
          element textarea {
            attribute class {"xrx-visualxml"},
            if(exists($child/@attributes)) then attribute data-xrx-attributes { $child/@attributes/string() } else(), 
            if(exists($child/@elements)) then attribute data-xrx-elements { $child/@elements/string() } else() ,
            
            (: Build Binds or refs :)
            if(exists($child/@bind)) then 
                attribute data-xrx-bind { $child/@bind/string() } 
            else if(exists($child/@ref)) then
                attribute data-xrx-ref { $child/@ref/string() }
            else()
            }
   return
    $return
};

 (: functx - Funktion - Path to Node 
 ~  modified by Stephan Makowski
 :)
declare function mycollection:path-to-node ( $nodes as node()* , $complete as xs:boolean)  as xs:string* {

  let $path := $nodes/string-join(ancestor-or-self::*/name(.), '/')
  
  let $path_token := tokenize($path, "/")
  
  let $path_to_node :=
   if($complete) then
    concat("/descendant::", $path_token[last()-1] ,"/child::", $path_token[last()])
   else
    concat("/descendant::", $path_token[last()-1])
  
  return 
    $path_to_node
};

(: FunktX-Section 
~ To be replaced if functx is included to MOM
:)

 (:  functx-Function :)
declare function mycollection:is-node-in-sequence-deep-equal
  ( $node as node()? ,
    $seq as node()* )  as xs:boolean {

   some $nodeInSeq in $seq satisfies deep-equal($nodeInSeq,$node)
 } ;
 
(:  functx-Function :)
declare function mycollection:distinct-deep
  ( $nodes as node()* )  as node()* {

    for $seq in (1 to count($nodes))
    return $nodes[$seq][not(mycollection:is-node-in-sequence-deep-equal(
                          .,$nodes[position() < $seq]))]
 } ;