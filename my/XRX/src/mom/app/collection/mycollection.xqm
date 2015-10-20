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

declare variable $mycollection:editor-controls := template:get("tag:www.monasterium.net,2011:/mom/template/mycollection-charter-editor");

declare variable $mycollection:editor-fieldsets := template:get("tag:www.monasterium.net,2011:/mom/template/mycollection-charter-editor-fieldset");

declare variable $mycollection:editormodus := request:get-parameter('mode', 'full');

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

 (: Load Charter and check, if all necessary Nodes from the Template are available
  ~ deprecated! 14.Sept. 2015 StMa
  ~ Deprecation revoked 22. September 2015
 :)
 declare function mycollection:checkUpdateCharter($charter as element())  {

    (: Iterate through Template
    ~ and look, if every Node inside the Template is present inside the charter.
    ~ If not, add node to parent.
    :)
  
    let $return := 
        for $node in $mycollection:template//*
            (: Get last existing parent from given Node :)
            let $parent := mycollection:returnLastExistendNode($charter, $node)
            
            (: Does current Node from the Template exists inside the Charter:)
            let $Current_Node := mycollection:node-exists($charter, $node)

            let $updateinsert :=
                (: If Node not found, copy Node from template and put it into the charter :)
                if(string($Current_Node) = "false" ) then
                    update insert $node into $parent
                else
                    ()
                    
            return
                $updateinsert
    return ()
 };
 
(: Check, if all Nodes from a Template exist inside in an another Document
~   Deprecated since 15. September 2015
~   Deprecation revoked 22. September 2015
:)
declare function mycollection:node-exists ($nodeSet as node(), $nodeToFind as node() )  as xs:boolean* {

    let $return := if(local-name($nodeToFind) ="graphic") then true() else
      
      (: Get all Nodes from the submitted Nodeset ($charter) 
      ~  Iterate through all Nodes and check, if current path of node is the same as the given node
      :)
      let $curSearch := mycollection:getNode($nodeSet, $nodeToFind)
      
      (: If Nodes are present, return True() otherwise False() :)
      let $test := if(exists($curSearch)) then true() else false()
      return
        $test
        
    return
      $return

 } ;
 
 (: Iterate through all Parentnodes until there is a match :)
 declare function mycollection:returnLastExistendNode($nodeSet as element(), $nodeToFind as element() ) as element() {
  (: Get given Node from Nodeset :)
  let $node := mycollection:getNode($nodeSet, $nodeToFind)
  (: If node wasn't found, call function recursive with parent of the given node :)
  let $return := if(exists($node)) then $node else mycollection:returnLastExistendNode($nodeSet, $nodeToFind/..)
  
  return
    $return[last()]
 };
 
 (: Get Node via Path-matching :)
 declare function mycollection:getNode($nodeSet as element(), $nodeToFind as element() ) as element()* {
  (: Build Path of given Node :)
  let $path := $nodeToFind/string-join(ancestor-or-self::cei:*/name(.), '/')
  (: Iterate through Nodeset until the given Node was found :)
  for $node in $nodeSet//*
    (: Get Path from current node :)
    let $path_node := $node/string-join(ancestor-or-self::cei:*/name(.), '/')
    let $try :=
      (: If path of the Node is Part of the Charter, return Node else next:)
      if($path_node = $path) then
        $node else ()
  return $try
 };
 
 (: Get occurences of Node :)
declare function mycollection:return-node-with-names($charter as element(), $nodename as xs:string, $parent as xs:string) as element()? {
    (: To ensure that multiple nodes are inside the same hierarchy, search within parent/child_to_test :)
    let $parent_ := $charter//*[xs:string(node-name(.)) = $parent]
    let $tes :=   $parent_//*[xs:string(node-name(.)) = $nodename]
    
    (: Return Node as Element; Return just 1 Entity :)
    return
        $tes[1]
};
 
 
 (: Get occurences of Node :)
declare function mycollection:get-counter($charter as element(), $node_to_test as element()?) as xs:string {
    
    (: To ensure that multiple nodes are inside the same hierarchy, search within completed Path inside the Charter :)
    let $path := $node_to_test/string-join(ancestor-or-self::cei:*/name(.), '/')
    
    (: Get Node from original Charter :)
    let $node := mycollection:dynamic-path($charter, concat("atom:content/", $path) )
    
    (: Return Occurency as String:)
    return
        string(count($node))
};

(: Build Name for Bindings :)
declare function mycollection:buildNodeName($charter as element(), $pos as xs:string, $node_path as xs:string) as xs:string {
                
  (: Get Node from Charter:)
  let $node_orig := mycollection:returnNode($charter, $node_path)
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
    for $node at $pos in $nodes//*
            
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
    ~ Parent-Token is [last()-1] because of an empty sequence before the first "/"
    :)
    let $parent_token := $token[last()-1]
    (: Get Main Token:)
    let $main_token := $token[last()]
    (: extract Parent cei-Tag-Name :)
    let $parent := substring-after($parent_token, "::")
    (: extract Main cei-Tag-Name :)
    let $main := substring-after($main_token, "::")
    
    (: Returnvalue in dependence of calling:)  
    return
      switch($deep)
      case "parent" return $parent
      case "main" return $main
      case "main_token" return $main_token
      case "parent_token" return $parent_token
      default return ""
    
};

(: Get Node from a Nodeset and a Path:)
declare function mycollection:returnNode($charter as element(), $querynode as xs:string) as element() {

    (: Clean Path from Descendant- and Child-Infos :)
    let $node_name := replace($querynode, "descendant::", "")
    let $node_name := replace($node_name, "child::", "")
    let $node_name := concat("atom:content", $node_name)
    
    (: Get Node from original charter :)
    let $node_main := mycollection:dynamic-path($charter, $node_name)

    return
      (: Return the 1 occurence:)
        $node_main[1]
};
 
(: Automatically generate Bindungs from File :)
declare function mycollection:makeBindings($charter as element(), $mappings as element()*) as element()* {
    
    (: Build Binding-Div :)
    let $return := 
      element div {
      attribute class {"xrx-binds"},
      attribute style {"display:none"},
      
      (: Iterate through all distinct mappings :)
      for $node at $pos in $mappings
      
          (: Extract Node-Name from Path-String :)
          let $node_name := mycollection:getParentName($node/path, "main")

          (: Extract Parent-Node-Name from Path-String :)
          let $node_name_par := mycollection:getParentName($node/path, "parent")
          
          (: Get Mapping information from Editor-Template:)
          let $node_editor := $mycollection:editor-controls//.[id = xs:string($node_name)]
          
          (: If multiple Entrys are found, walk through axis to find matching parent:)
          let $node_editor := if (count($node_editor) > 1) then
            for $node_entry in $node_editor
              let $entity := if(contains($node/path, $node_entry/parent)) then $node_entry else ()
              return 
                $entity
            else
              $node_editor
          
          let $work := if (exists($node_editor)) then
          
            (: Get path from mapping item :)
            let $path_orig := $node/path
            
            (: Get occurence from mapping item :)
            let $occurences := $node_editor/mult_occurence
            
            (: Get Taget-Field if available :)
            let $target := $node_editor/target_field
            
            (: Build Binding-Name:)
            let $nodename_complete := mycollection:buildNodeName($charter, string($pos), $path_orig)
             
            (: If the node has multiple occurences, build path to node individualy 
            ~ Node exists only once -> path complete /descendant::cei:issued/child::cei:date
            ~ Node exists multiple times -> just /descendant::cei:issued
            ~ It is important for handling the bindings and the "<xrx:repeat>"
            :)
            
            let $path :=
              if($occurences = "true") then
                if($target != "") then
                    $path_orig
                  else
                    mycollection:path-to-string($path_orig, false())
              else
                $path_orig
            
            (:
            (: Get Original Node from Charter and check for Occurence :)
            let $path_node :=  mycollection:path-to-string($path_orig, true())
            let $path_node := replace($path_node, "descendant::", "")
            let $path_node := replace($path_node, "child::", "")
            let $path_node := concat("atom:content/cei:text", $path_node)
            
            let $log := util:log("ERROR", $path_node)
            
            let $orig_node := mycollection:dynamic-path($charter, $path_node)
            
            
            let $path_parent :=  mycollection:path-to-string($path_orig, false())
            let $path_parent := replace($path_parent, "descendant::", "")
            let $path_parent := replace($path_parent, "child::", "")
            let $path_parent:= concat("atom:content/cei:text", $path_parent)
            let $parent_node := mycollection:dynamic-path($charter, $path_parent)
            (: Get Occurence of the orig. Node and check if multiple occurences :)
            let $counter := count($orig_node)
            let $counter_parent := count($parent_node)
            
            let $temp := if($occurences = "false" and $counter > 1) then $counter else
              if($occurences = "true" and $counter > 1 and $target != "") then $counter else
                if($occurences = "true" and $counter_parent > 1 and $target = "") then $counter else 1 :)
            
             
            (: Just take the first occurence of Witnesses; has to be replaced by dynamically approach :)
            let $path := if(count($charter//cei:witness) > 1 ) then 
              if(contains($path, "/child::cei:witness/") ) then replace($path, "/child::cei:witness/", "/child::cei:witness[1]/") else if(ends-with($path, "/child::cei:witness")) then replace($path, "/child::cei:witness", "/child::cei:witness[1]") else $path
              else $path
            
            (: single div :)
            let $div := (:if($temp = 1) then:)                 
                element div {
                    attribute class {"xrx-bind"},
                    attribute id {$nodename_complete},
                    attribute data-xrx-nodeset {$path}
    
                }  (:
                else
                  for $i in (1 to $temp) 
                  return
                  element div {
                    attribute class {"xrx-bind"},
                    attribute id {concat($nodename_complete, "-", $i)},
                    attribute data-xrx-nodeset {concat($path, "[", xs:string($i), "]" )}
    
                }  :)
            
            return
              $div
              (: build div-element for the binding-section:)

          else
            ()
          return
            $work
       }
       
    (: Return all new bindings :)
    return
       $return
};

(: Returnvalue = return all existing Nodes which are covered by the Editor-Template 
~ is called inside my-collection-charter-edit.widget.xml
~ returns all non present nodes
:)
declare function mycollection:return-existend-nodes ( $charter_ as element() ) as node()* {
    
    (: Load Charter :)
    let $charter := $charter_/atom:content/cei:text
    
    (: Iterate through charter :)
    let $return := <return>
      {
        for $node in $charter//*
            
            let $config_ := $mycollection:editor-controls//.[id = xs:string(node-name($node))][./groups/group = $mycollection:editormodus]
            (: Does current Node from the Template exists inside the Charter?
            ~  If $config contains <target>, check if charter includes this target. Otherwise next Node 
            :)
            let $path := $node/string-join(ancestor-or-self::cei:*/name(.), '/')
            
            let $isPresent_item := 
              (: Itereate through all available Fields for this TabPage:)
              for $config in $config_
                let $test :=
                  (: If Config exists and Parent-Field is inside the context :)
                  if(exists($config) and contains($path, $config/parent/text() ) ) then
                    (: Check, if Target [for xrx:repeat] exists:)
                    if($config/target_field/text() != "")  then
                        (: If Target exists, take Node. Otherwise next :)
                        if (exists($node//.[xs:string(node-name(.)) = $config/target_field/text()]) ) then
                          $config
                        else
                          () 
                    else
                      $config (: If target isnt filled :) 
                  else 
                  () (: if Config wasn't found or Parent not inside the Path :)
                return
                  $test
            
            return
              $isPresent_item
      }
      </return>
    return
        $return
    
};
(: Returnvalue = false if some node is missing inside the template 
~ is called from my-collection-charter-edit.widget.xml
~ Deprecaded since 15.September 2015
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

(:  Make Fieldset-Output with individual Controls for the specific Fields :)
declare function mycollection:makeFieldsets ( $charter as element()*, $nodes-there as element()*, $distincts as element()*, $elements-tabPage as element()*, $elements-Fieldset as element()* ) as element()* {

  let $flSets :=
    (: Iterate through Fieldsets to get all relevant Fields :)
    for $fs in $elements-Fieldset
      (: Just all the fields which are inside the Fieldset :)
      let $fields := $elements-tabPage/.[id = $fs//field/text()]
      (: Make just those Controls which are accepted for this FieldSet :)
      let $controls := mycollection:makeControlls($charter, $nodes-there, $distincts, $fields, <fields/>)
      (: Make Element Fieldset with Legend and Controls just if at least 1 controls is there :)
      let $set := if(count($controls) > 0 ) then
        element fieldset {
          element legend {
              mycollection:createMessages($fs/legend)
            },
            $controls
          }
          else  ()
      (: Return of the Fieldset :)
      return
        $set

return
  $flSets
};

(: Check if field is inside given Fieldset :)
declare function mycollection:isFieldInsideFieldset($fieldname as xs:string, $fieldset as element()) as xs:boolean {
  (: Check, if given Name is inside the Fieldset :)
  let $field := $fieldset//.[field/text() = $fieldname]
  (: Return boolean value from fn:exists:)
  let $return := exists($field)
  
  return
    $return
};

(: Make Controlls and returns them to the calling Widget 
~ is called my-collection-charter-edit.widget.xml
:)
declare function mycollection:makeControlls ( $charter as element()*, $nodes-there as element()*, $distincts as element()*, $elements-tabPage as element()*, $elements-fieldset as element()? ) as element()* {

    (: Build Controls :)
    let $return :=
        for $mapped_item at $pos in $distincts
            
            (: remove Inheritance-Information :)
            let $path := replace($mapped_item/path,"descendant::", "")
            let $path := replace($path,"child::", "")
            
            (: $nodes-there contains all nodes which are allowed within this tabPage
            ~ Every node from the Charter must be checked explicit against their individual Parts.
            ~ e.g. cei:p can contain cei:persName
            ~ cei:persName is not allowed for tabPag6. Its an own field for tabPage 7.
            ~ thats why the complete path have to be checked against the allowed Fields
            ~ $path contains a leading "/". It has to be removed! (functX)
            :)
            
            let $nodes := if ($nodes-there/string-join(ancestor-or-self::cei:*/name(.), '/') = mycollection:replace-first($path, "/", "") ) then
                
                (: Generate Binding Name:)
                let $bindingname := mycollection:buildNodeName($charter, string($pos), $mapped_item/path)
                
                (: Get Name from mapped_idem:)
                let $name_from_path := mycollection:getParentName($mapped_item/path, "main")

                (: Get Name from mapped_idem:)
                let $name_from_path_parent := mycollection:getParentName($mapped_item/path, "parent")
                
                (: If name contains "child:", remove this :)
                let $name_from_path_parent := if (contains($name_from_path_parent, "child::")) then replace ($name_from_path_parent, "child::", "") else $name_from_path_parent
                
                (: Get Control for the Name :)
                let $item := $elements-tabPage//.[id =  $name_from_path]
                    
                (: Get local name:)
                let $local_name := replace($name_from_path, "cei:", "")
                
                (: Get Path from Mapped Item:)
                let $path := mycollection:replace-first($path, "/", "")
                
                (: Node from Charter via Path:)
                let $orig-node := mycollection:dynamic-path($charter/atom:content, $path)
                
                (: get Occurence of original Node :)
                let $count := count($orig-node)
                
                (:
                let $path_parent :=  mycollection:path-to-string($path_orig, true())
                let $path_parent := replace($path_parent, "descendant::", "")
                let $path_parent := replace($path_parent, "child::", "")
                let $path_parent:= concat("atom:content/cei:text", $path_parent)
                let $parent_node := mycollection:dynamic-path($charter,  $path_parent)
                
                (: Get Occurence of the orig. Node and check if multiple occurences :)
                let $counter := count($orig_node)
                let $counter_parent := count($parent_node)
                
          
                let $temp := if($occurences = "false" and $counter > 1) then $counter else
                  if($occurences = "true" and $counter > 1 and $target != "") then $counter else
                    if($occurences = "true" and $counter_parent > 1 and $target = "") then $counter else 1
                
                :)
                
                (: Create Textarea in dependency of Occurence; Return Control :)
                let $control := if(exists($item)) then
                                  (: Field must be outside of a Fieldset :)
                                  if(not(mycollection:isFieldInsideFieldset($name_from_path, $elements-fieldset) ) ) then
                                    (: If a target is configured for a Field, check if there :)
                                    if($item/target_field/text() != "" ) then 
                                      (: If target_field available, create controll:)
                                      if(exists($orig-node//.[xs:string(node-name(.)) = $item/target_field/text()])) then
                                        mycollection:createControl($bindingname, $local_name, $mapped_item/path, $item[last()])
                                      else 
                                        () (: Target-Field isnt there :)
                                    else
                                      (: No target specified -> create control. No further checks neccessary :)
                                      mycollection:createControl($bindingname, $local_name, $mapped_item/path, $item[last()])
                                  else
                                    ()
                                else ()
                                
                return
                  $control
              else
                ()
            return
              $nodes

    (: To Do: Output to individuell Tabpage defined into Editor-Template :)
    return
      $return 

};

(: Prepare Creation of Textarea with Bindings or References :)
declare function mycollection:createControl($bindname as xs:string, $localname as xs:string, $mapping_element as xs:string, $editor_item as element()) as element()* {

  (: Get Path of mapped Item :)
  let $path := $mapping_element
  (: Get Occurence of mapped Item :)
  let $occur := $editor_item/mult_occurence
  (: Get Parent-Token :)
  let $parent := concat("/", mycollection:getParentName($path, "parent_token") )
  
  (: Build Visual-XML statement 
  ~ ToDo: Reconstruction of CreateTextarea
  ~ If occures multiple Times, insert Ref- elmse Bind-Attribute
  :)
  let $targetname := $editor_item/target_field
  
  let $binding := if($occur = "false") then
      $bindname
    else
      if($targetname != "") then
        concat("/child::",$targetname )
      else
        concat("/child::",$editor_item/id)
  
  (: Build Element to Create all the Controls :)
  let $xrx :=
     if($occur = "false") then
      <xrx:visualxml bind="{$bindname}"/>
     else
      <xrx:visualxml ref="{$binding}"/>
  
  (: extract Field-Name for i18n:)
  let $name := if($occur = "false") then 
      replace(mycollection:getParentName($path, "main"), "cei:", "")
    else
      (: If occurs multiple times, take Info which Field should be taken for the i18n :)
      if($editor_item/message = "self") then
        replace($editor_item/id, "cei:", "")
      else
        if($editor_item/message = "target") then
            replace($targetname, "cei:", "")
          else
            if($editor_item/message = "parent") then
              replace($editor_item/parent, "cei:", "")
            else
              replace(mycollection:getParentName($path, "main"), "cei:", "")
  return
  
    (: Call Creation of Textarea :)
    mycollection:createTextarea($xrx, $name, $occur, $bindname)
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
    if($occur = "false") then 
      ($elem, $text) 
    else 
      ($elem, $text_multiple)
  return
    $return

};

(: Get Message from i18n-Module:)
declare function mycollection:createMessages($name as xs:string) as xs:string {
 
 (: Check, if name contains "cei_". If not, concat to $name :)
 let $field := if(contains($name, "cei_")) then $name else concat("cei_", $name)
 (: Get Message from cei_[Localname]-Item 
 ~ in dependency of the current language
 :) 
 let $msg := i18n:value($field, request:get-parameter('lang', $xrx:lang))
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

(: Return Bool=True if Items for relevant Fieldsets are available :)
declare function mycollection:isFieldsetRelevant($tabPage as xs:string) as xs:boolean {
  let $item := mycollection:filteredTabContent($tabPage)
  let $return := if(count($item) > 0 ) then true() else false()
  
  return
    $return
};

(:  Get Fieldset for the TabPage from File :)
declare function mycollection:filteredFieldsetContent($tabPage as xs:string) as element()* {
  let $return := $mycollection:editor-fieldsets//.[tab_page = $tabPage]
  
  return
    $return
};

(: Return Bool=True if Items for relevant TabPage are available :)
declare function mycollection:isTabRelevant($tabPage as xs:string) as xs:boolean {
  let $item := mycollection:filteredTabContent($tabPage)
  let $return := if(count($item) > 0 ) then true() else false()
  
  return
    $return
};

(:  Just get this Fields from Definitionfile which are relevant for this TabPage
    Filter for TabPage and Editormodus (Request-Parm)
:)
declare function mycollection:filteredTabContent($tabPage as xs:string) as element()* {
  let $return := $mycollection:editor-controls//.[tab_page = $tabPage][./groups/group = $mycollection:editormodus]
  
  return
    $return
};

(:  Read all Fields for individual TabPages and display them  
    is called inside the my-collection-charter-edit.widget.xml
    Returns Controls per TabPage
:)

declare function mycollection:returnTabPageContent($tabPage as xs:string, $entry as element(), $distincts as element()*) as element() {

let $tab := $tabPage
return
switch ($tab)
   case "1" return <div data-demoid="c0ca5834-6e65-4b0a-bd53-c1ecdfd5ee2f" id="tab-1">{mycollection:createTabContent("1", $entry, $distincts)}</div>
   case "2" return <div data-demoid="e120c2c9-beef-4f0d-857f-a3d07291ec23" id="tab-2">{mycollection:createTabContent("2", $entry, $distincts)}</div>
   case "3" return <div data-demoid="f50ce1ea-340f-4e99-9a6a-d49e6254e690" id="tab-3">{mycollection:createTabContent("3", $entry, $distincts)}</div>
   case "4" return <div data-demoid="92749a8b-b697-4f54-8cc4-21a54bca510f" id="tab-4">{mycollection:createTabContent("4", $entry, $distincts)}</div>
   case "5" return <div data-demoid="85cbe1bb-7c1c-4cde-9fff-48db5bb01569" id="tab-5">{mycollection:createTabContent("5", $entry, $distincts)}</div>
   case "6" return <div data-demoid="819ee757-c834-49f2-a696-1a4e133055ac" id="tab-6">{mycollection:createTabContent("6", $entry, $distincts)}</div>
   case "7" return <div data-demoid="c46aa058-3b4d-48eb-958a-905652a5754b" id="tab-7">{mycollection:createTabContent("7", $entry, $distincts)}</div>
   case "8" return <div data-demoid="0a11e85c-34fc-11e5-a151-feff819cdc9f" id="tab-8">{mycollection:createTabContent("8", $entry, $distincts)}</div>
   default return <div id="tab-0"/>


};

(: Get available Controls and return the Node :)
declare function mycollection:getContentFromControlls($entry as element(), $tabPageControls as element()*) as element()* {

  (: Get all Entries from Definition-File which are suitable for this tabPage :)
  let $return := 
    for $editControl in $tabPageControls
      let $Nodes := mycollection:return-node-with-names($entry, $editControl/id, $editControl/parent)
      return
        $Nodes
  return
    $return
};

(: Check if selected TabPage contains any Content :)
declare function mycollection:containsTabContent($entry as element(),$tabPage as xs:string) as xs:boolean {
  let $controls-as-tabPage := mycollection:filteredTabContent($tabPage)
  let $content := mycollection:getContentFromControlls($entry, $controls-as-tabPage)
  let $return := if(count($content) > 0 ) then true() else false()
  return
    $return
};

(: Create TabContent; Contains only the Controls for the specific TabPage :)
declare function mycollection:createTabContent($tabPage as xs:string, $entry as element(), $distincts as element()*){
  
  let $fieldsets := mycollection:filteredFieldsetContent($tabPage)
  let $sets := <fields>{$fieldsets}</fields>
  let $controls-as-tabPage := mycollection:filteredTabContent($tabPage)
  
  (: Get all Entries from Definition-File which are suitable for this tabPage :)
  let $return := mycollection:getContentFromControlls($entry, $controls-as-tabPage)
  
  (: At first, Create all Fieldsets:)
  let $fieldset := mycollection:makeFieldsets($entry, $return, $distincts, $controls-as-tabPage, $fieldsets)
  
  (: then Create all Controls for the Rest :)
  let $controls := mycollection:makeControlls($entry, $return, $distincts, $controls-as-tabPage, $sets)
  
  (: Return Controls and Fieldsets :)
  let $back := ( $controls, $fieldset)
  return
    $back

};

(:  Serialize Element to String because Widget does not accept XPATH-Query 
    Just a Helper. Will be erased if deprecated
:)
declare function mycollection:helper-to-string($elem as element()) as xs:string {
  let $params := <output:serialization-parameters xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
  <output:omit-xml-declaration value="yes"/>
</output:serialization-parameters>

  return
    serialize($elem, $params)
};

(: Build individual string from path :)
declare function mycollection:path-to-string ( $node_path as xs:string , $complete as xs:boolean)  as xs:string* {

  (: Build clean path :)
  let $path := replace($node_path, "child::", "")
  let $path_token := tokenize($node_path, "/")
  
  
  (: Remove Atom-Tag-Informations :)
  let $path := replace($path, $path_token[1], "")
  let $path := replace($path, $path_token[2], "") 
  let $path := replace($path,"//", "")
  
  let $path := replace($path,"/", "/child::") 
  
  (: If Flag $complete is set to false, return the path without the last Path-Element
  ~   e.g. /cei:text/cei:chDesc/cei:witListPar
  ~   complete = false
  ~   return /cei:text/cei:chDesc else /cei:text/cei:chDesc/cei:witListPar
  ~
  ~   is neccessary for building the Path-Strings for repeatable Bindings
  :)
  let $path_to_node :=
         if($complete) then
          $path
         else
          replace($path, concat("/",$path_token[last()]), "")
    
  let $path_to_node := concat("/descendant::", $path_to_node)
  return
        $path_to_node
};

 (: functx - Funktion - Path to Node 
 ~  modified by Stephan Makowski
 :)
declare function mycollection:path-to-node ( $nodes as node()* , $complete as xs:boolean)  as xs:string* {

  let $path := $nodes/string-join(ancestor-or-self::*/name(.), '/')
  
  let $path_to_node := mycollection:path-to-string($path, $complete)
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
 
 (: functx-Function :)
 declare function mycollection:replace-first
  ( $arg as xs:string? ,
    $pattern as xs:string ,
    $replacement as xs:string )  as xs:string {

   replace($arg, concat('(^.*?)', $pattern),
             concat('$1',$replacement))
 } ;
  (: functx-Function :)
declare function mycollection:substring-after-if-contains
  ( $arg as xs:string? ,
    $delim as xs:string )  as xs:string? {

   if (contains($arg,$delim))
   then substring-after($arg,$delim)
   else $arg
 } ;
  (: functx-Function :)
declare function mycollection:name-test
  ( $testname as xs:string? ,
    $names as xs:string* )  as xs:boolean {

$testname = $names
or
$names = '*'
or
mycollection:substring-after-if-contains($testname,':') =
   (for $name in $names
   return substring-after($name,'*:'))
or
substring-before($testname,':') =
   (for $name in $names[contains(.,':*')]
   return substring-before($name,':*'))
 } ;
  (: functx-Function :)
declare function mycollection:substring-before-if-contains
  ( $arg as xs:string? ,
    $delim as xs:string )  as xs:string? {

   if (contains($arg,$delim))
   then substring-before($arg,$delim)
   else $arg
 } ;
  (: functx-Function :)
declare function mycollection:dynamic-path
  ( $parent as node() ,
    $path as xs:string )  as item()* {

  let $nextStep := mycollection:substring-before-if-contains($path,'/')
  let $restOfSteps := substring-after($path,'/')
  for $child in
    ($parent/*[mycollection:name-test(name(),$nextStep)],
     $parent/@*[mycollection:name-test(name(),
                              substring-after($nextStep,'@'))])
  return if ($restOfSteps)
         then mycollection:dynamic-path($child, $restOfSteps)
         else $child
 } ;
 