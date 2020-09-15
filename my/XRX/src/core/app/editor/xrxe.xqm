xquery version "3.0";


module namespace xrxe='http://www.monasterium.net/NS/xrxe';

import module namespace qxrxe="http://www.monasterium.net/NS/qxrxe" at "../editor/qxrxe.xqm";
import module namespace qxsd="http://www.monasterium.net/NS/qxsd" at "../editor/qxsd.xqm";
import module namespace xrxe-conf="http://www.monasterium.net/NS/xrxe-conf" at "../editor/xrxe-conf.xqm";

declare namespace bf="http://betterform.sourceforge.net/xforms";
declare namespace bfc="http://betterform.sourceforge.net/xforms/controls";
declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace ev="http://www.w3.org/2001/xml-events";
declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare namespace xsi="http://www.w3.org/2001/XMLSchema-instance";
declare namespace functx = "http://www.functx.com";

(: ##################################################### START CONSTRUCTORS #####################################################################:)

(: ### public constructor for a document-editor ### :)
(: ### a document-editor is an xforms-application that provides the functionalities to load, edit and save an xml-document ### :)
(: ### the parameter $param contains a element describing the spezial configuration of the editor. This configuration might override the default configuration in ./xrxe-conf.xqm ### :)
(: ### a document-editor contains on or more node-editors defined with $param/@node-set or $param//xrxe:node-editor ### :)

declare function xrxe:editor($param){

        let $xsd := xrxe:get-xsd($param)

        return
            xrxe-conf:translate(
                if($xsd) then
                    let $conf := xrxe:set-conf($param)
                    return
                        xrxe:create-document-editor-widget($xsd, $conf)
                else
                    <div>{$xrxe-conf:xsd-not-found}</div>
            )
};

(: ### public constructor for a node-editor ### :)
(: ### a node-editor is an xforms-application that provides the functionalities to edit the data of an xml-node and its descendents ### :)
(: ### the parameter $param contains an element describing the spezial configuration of the node-editor. This configuration might override the default configuration in ./xrxe-conf.xqm ### :)

declare function xrxe:subeditor($param){

        let $xsd := xrxe:get-xsd($param)
        return
            xrxe-conf:translate(
                if($xsd) then
                    let $conf := xrxe:set-conf($param)
                    return
                    xrxe:create-node-editor-widget($xsd, $conf)
                else
                    <div>{$xrxe-conf:xsd-not-found}</div>
            )
};

(: ##################################################### END CONSTRUCTORS #####################################################################:)

(: ##################################################### START XSD #####################################################################:)


(: ### function to get the xsd i.e. xs:schema node ### :)
(: ### $param/@xsd contains the absolute db-path or the uri of the xsd  ### :)
declare function xrxe:get-xsd($param){

    let $xsd :=
        (:do not use $param/xrxe:xsd:)
        if($param/xrxe:xsd[1]/element()) then
                $param/xrxe:xsd[1]/element()
        (:this is the way it should be done:)
        else if($param/@xsd) then
                xs:string($param/@xsd)
        else()
    return  qxsd:xsd($xsd)
};

(: ##################################################### END XSD #####################################################################:)

(: ##################################################### START CONFIGURATION #####################################################################:)

(:### function that creates the conf-element with is used and passed through the whole script ###:)
(:### the conf-element $conf contains information from the param-element and from ./xrxe-conf-xqm ###:)
(:### information of ./xrxe-conf-xqm can be overwritten by attributes from the param-element ###:)
declare function xrxe:set-conf($param){

        (:the root element of the xml-document:)
        let $document := xrxe:set-doc($param)

        let $wrapper :=
            if ($param/@wrapper and string($param/@wrapper)!='') then
                 xs:string($param/@wrapper)
            else
                 $xrxe-conf:default-wrapper

        (:if the node-path is not defined in $param it is the xpath-expression from the document-node to the root-element:)
        let $node-path :=
            if($param/@node-path) then
                $param/@node-path
            else
                let $fake-document-node :=
                <doc-node>
                    {$document}
                </doc-node>

                let $get-root-node := concat('$fake-document-node', $wrapper, '/element()[1]')
                let $root := util:eval($get-root-node)
                return
                    concat('/', name($root))


        (:create the conf-elemet:)
        let $conf  :=  element conf {

                if($node-path) then
                    attribute node-path {string($node-path)}
                else()
                ,

               (:### definies the uri where to save a xml document (for example http://localhost:8080/exist/rest/db/data/my.xml) ###:)
                let $save :=
                if ($param/@save and string($param/@save)!='') then
                     $param/@save
                else
                     ()
               return
                    if($save) then
                         attribute save {string($save)}
                    else ()
                ,

               (:### if availabe a [save and continue]-Button is rendered that triggers the save submission first and than loads the spezified uri of save-and-close ###:)
               let $save-close :=
                    if ($param/@save-close and string($param/@save-close)!='') then
                        $param/@save-close
                    else
                        ()
               return
                    if($save-close) then
                         attribute save-close {string($save-close)}
                    else ()
               ,

               (:################################ OVERWRITE XRXE-CONF ################################################:)


                (:### definies the uri of the ajax-services used by xrxe (normally the url of ./xrxe-services.xql) ###:)
                let $services :=
                     if ($param/@services and string($param/@services)!='') then
                         $param/@services
                     else
                          $xrxe-conf:default-services
                return
                     if($services) then
                          attribute services {string($services)}
                     else ()
               ,

                (:### definies with method is used when sending the submission to save the document (put or post) ###:)
                (:### VdU/VRET needs to have POST ###:)
                let $save-method  :=
                    if ($param/@save-method and (string($param/@save-method)='post' or string($param/@save-method)='put')) then
                        xs:string($param/@save-method)
                    else
                        $xrxe-conf:default-save-method
                return
                    if($save-method) then
                         attribute save-method {string($save-method)}
                    else ()
               ,

               (:### definies where to place the document-editor's triggers like [save] or [save and continue] ###:)
               (:### values are 'bottom, 'top', or  top-and-bottom to display the triggers twice ###:)
               let $place-triggers  :=
                    if ($param/@place-triggers and (string($param/@place-triggers)='bottom' or string($param/@place-triggers)='top' or string($param/@place-triggers)='top-and-bottom') or string($param/@place-triggers)='no' ) then
                        xs:string($param/@place-triggers)
                    else
                        $xrxe-conf:default-place-triggers
               return
                    if($place-triggers) then
                         attribute place-triggers {string($place-triggers)}
                    else ()
               ,

               (:### if a document is wrapped into another document, the whole document is officially no document of the xsd ###:)
               (:### definies the xpath-expression from the document-node to the node that is the root node according to the used xsd ###:)
               if($wrapper) then
                        attribute wrapper {string($wrapper)}
                   else ()
               ,

                (:### if true all elements are relevant for the editor except those that are declared irrelevant in the xsd by xrxe:relevant/text()=false ###:)
                (:### if false all elements are irrelevant for the editor except those that are declared relevant in the xsd by xrxe:relevant/text()=true ###:)
                let $element-relevant :=
                    if ($param/@element-relevant and (string($param/@element-relevant)='true' or string($param/@element-relevant)='false')) then
                         xs:boolean($param/@element-relevant)
                    else
                         $xrxe-conf:default-element-relevant
               return
                   if($element-relevant) then
                        attribute element-relevant {string($element-relevant)}
                   else ()
               ,

                (:### if true all attributes are relevant for the editor except those that are declared irrelevant in the xsd by xrxe:relevant/text()=false ###:)
                (:### if false all attributes are irrelevant for the editor except those that are declared relevant in the xsd by xrxe:relevant/text()=true ###:)
                let $attribute-relevant :=
                    if ($param/@attribute-relevant and (string($param/@attribute-relevant)='true' or string($param/@attribute-relevant)='false')) then
                         xs:boolean($param/@attribute-relevant)
                    else
                         $xrxe-conf:default-attribute-relevant
               return
                   if($attribute-relevant) then
                        attribute attribute-relevant {string($attribute-relevant)}
                   else ()
               ,
               (:### if true all attribute-groups are relevant for the editor except those that are declared irrelevant in the xsd by xrxe:relevant/text()=false ###:)
               (:### if false all attribute-groups are irrelevant for the editor except those that are declared relevant in the xsd by xrxe:relevant/text()=true ###:)
               let $attribute-group-relevant :=
                    if ($param/@attribute-group-relevant and (string($param/@attribute-group-relevant)='true' or string($param/@attribute-group-relevant)='false')) then
                xs:boolean($param/@attribute-group-relevant)
                    else
                         $xrxe-conf:default-attribute-group-relevant
               return
                   if($attribute-group-relevant) then
                        attribute attribute-group-relevant {string($attribute-group-relevant)}
                   else ()
               ,
               (:### if true all groups are relevant for the editor except those that are declared irrelevant in the xsd by xrxe:relevant/text()=false ###:)
               (:### if false all groups are irrelevant for the editor except those that are declared relevant in the xsd by xrxe:relevant/text()=true ###:)
               let $group-relevant :=
                    if ($param/@group-relevant and (string($param/@group-relevant)='true' or string($param/@group-relevant)='false')) then
                         xs:boolean($param/@group-relevant)
                    else
                         $xrxe-conf:default-group-relevant
               return
                   if($group-relevant) then
                        attribute group-relevant {string($group-relevant)}
                   else ()
               ,
               (:### depth as an xs:int to stop querying the xsd if schema may be infinitely deep ###:)
               let $max-depth :=
                    if ($param/@max-depth) then
                         xs:int($param/@max-depth)
                    else
                         $xrxe-conf:default-max-depth
               return
                   if($max-depth) then
                        attribute max-depth {string($max-depth)}
                   else ()
               ,

               (:### how many rows for textannoation-control of not overwritten by the xrxe:row for a specific element in xsd ###:)
               let $rows :=
                    if ($param/@rows) then
                         xs:int($param/@rows)
                    else
                         $xrxe-conf:default-rows
               return
                   if($rows) then
                        attribute rows {string($rows)}
                   else ()
               ,

               (:### the localtion where the used xsd can be fould ###:)
               let $xsdloc :=
                    if ($param/@xsd and string($param/@xsd)!='') then
                        $param/@xsd
                    else
                        ()
               return
                    if($xsdloc) then
                         attribute xsdloc {string($xsdloc)}
                    else ()
               ,

               (:### the localtion where the used xsd can be fould ###:)
               (:### not used###:)
               let $docloc :=
                    if ($param/@doc and string($param/@doc)!='') then
                        $param/@doc
                    else
                        ()
               return
                    if($docloc) then
                         attribute docloc {string($docloc)}
                    else ()
               ,


               (:### contains the document (root element of the document) ###:)
                if($document) then
                     element xrxe:doc {$document}
                else ()
               ,

               (:### user definied template of the document-editor to manipulate the structur of the editor when not conductable from the xsd ###:)
               let $ui-template := xrxe:get-ui-template($param)
               return
                    if($ui-template) then
                         element xrxe:ui-template {$ui-template/node()}
                    else ()

        }
    return $conf
};




(:### function to get the document (root-element) when inserting it into $conf ###:)
(:### the document can be included in $param/xrxe:doc or located by $param/@docloc ###:)
declare function xrxe:set-doc($param){
    let $doc :=
        if($param/xrxe:doc[1]/element()) then
            $param/xrxe:doc[1]/element()
        else if($param/@doc) then
             qxsd:find(xs:string($param/@doc))
        else()
    let $declare-namespaces := xrxe:declare-namespaces($doc)
    return $doc


};

(:### function to be sure to get an element ###:)
(:### if a element is decriebed by a document uri or is an document-node return the root element ###:)
(:### else return the element ###:)
declare function xrxe:get($something){
    if($something instance of xs:string) then
        if (exists(doc($something))) then
            doc($something)/element()
        else if (collection($xrxe-conf:default-search-id-in)/*[@id=$something]) then
            collection($xrxe-conf:default-search-id-in)/*[@id=$something]
        else ()

    else if ($something instance of node()) then
        if($something instance of document-node()) then
            $something/element()
        else
            $something
    else
        ()
};


(:### function to get the user defined ui-template from $param and store it in $conf ###:)
declare function xrxe:get-ui-template($param){

        let $param-ui-template :=
             if($param/xrxe:ui-template[1]) then
                 $param/xrxe:ui-template[1]
             else if($param/@ui-template) then
                 string($param/@ui-template)
             else()
        return  xrxe:get($param-ui-template)

};

(: ##################################################### END CONFIGURATION #####################################################################:)

(: ##################################################### START NAMESPACES #####################################################################:)


(:###  function to dynamically definie all namespaces that appear in a node ###:)
declare function xrxe:declare-namespaces($node){

for $xmlns in  xrxe:get-all-xmlns($node)
    let $prefix := xs:string($xmlns/@prefix)
    order by $prefix
    return util:declare-namespace($prefix, xs:anyURI($xmlns/@namespace))

};

(:### helper function to create a node storing a prefix namespace map ###:)
declare function xrxe:get-all-xmlns ($node){
    for $node in $node//element() | $node//attribute()
        let $prefix := prefix-from-QName(node-name($node))
        let $namespace := namespace-uri-from-QName(node-name($node))
            return
                if($prefix and $namespace and $prefix!='xml') then
                    <xmlns prefix="{$prefix}" namespace="{$namespace}" />
                else ()
 } ;

(:### helper function to create a node storing a prefix namespace map ###:)
 declare function xrxe:get-xmlns($nodes) {
  let $all-xmlns :=
    for $node in $nodes
        return xrxe:get-all-xmlns ($node)

  for $prefix in distinct-values($all-xmlns/@prefix)
     return
     <xmlns prefix="{$prefix}" namespace="{subsequence($all-xmlns[@prefix=$prefix]/@namespace, 1, 1)}"/>
};

(: ##################################################### END NAMESPACES #####################################################################:)

(: ##################################################### START WIDGET ##################################################################### :)

(:### function that creates a div that contains the xforms-application of the document editor ###:)
(:### this div contains all xmlns that are used for the editor, to let the xform-processor direktly know the namespaces ###:)
(:### a dummy-attribute for each namespace is set so that the xmlns is kept within this element  on this level ###:)
declare function xrxe:create-document-editor-widget($xsd, $conf){
    util:eval(
        let $before:= '<div class="xrxeDocumentEditor"'
        let $namespaces := xrxe:create-xmlns-string($conf/xrxe:doc/element())

        let $after :=  ">{(xrxe:create-document-editor($xsd, $conf))}</div>"
        return concat($before, $namespaces, $after)
    )
};

(: ### function to create a div containig the xforms-application of a node-editor ### :)
declare function xrxe:create-node-editor-widget($xsd, $conf) {

    let $template := xrxe:get-template($xsd, $conf)
    return
        util:eval(
            let $before:= '<div class="xrxeNodeEditor"'
            let $namespaces := xrxe:create-xmlns-string($template)
            let $after := ">{(xrxe:create-node-editor($template, $xsd, $conf))}</div>"
            return concat($before, $namespaces, $after)
    )
};

(: ### function that creates a string of all xmlns declaration and dummy attributes to keep the namespaces available for the xforms-processor ### :)
declare function xrxe:create-xmlns-string($nodes){

    let $xmlns-string :=
        string-join(
        for $xmlns  in xrxe:get-xmlns($nodes)
            let $pre := $xmlns/@prefix
            let $ns := $xmlns/@namespace
            return  concat('xmlns:' , $pre , '="' , $ns, '"')
    ,
    ' ')

     let $dummy-string :=
     string-join(
        for $xmlns  in xrxe:get-xmlns($nodes)
            let $pre := xs:string($xmlns/@prefix)
                return concat($pre, ':dummy="prevent xmlns in this element"')
    ,
    ' ')
    return concat($xmlns-string, ' ',  $dummy-string)
};

(: ##################################################### END WIDGET ##################################################################### :)


(: ##################################################### START DOCUMENT EDITOR ##################################################################### :)

(: ### function that creates the xfoms-application for the document-editor ### :)
declare function xrxe:create-document-editor($xsd, $conf){
    (
     xrxe:create-document-model($conf)
     ,
     xrxe:create-document-view($xsd, $conf)
     )
};


(:######################## *** DOCUMENT MODEL *** ############################:)

(: ### function to create the xfoms-model for the document-editor ### :)
declare function xrxe:create-document-model($conf){
        <xf:model id="{xrxe:document-model-id($conf)}">
                {(
                xrxe:create-document-instances($conf)
                ,
                xrxe:create-document-submissions($conf)
                )}
         </xf:model>
};

(: ### function to create all xforms instances for the document-editor ### :)
declare function xrxe:create-document-instances($conf){
    (
    xrxe:create-document-instance($conf)
    ,
    if($conf/xrxe:ui-template) then
        xrxe:create-document-helper-instances($conf)
    else ()
    )
};

(:######################## *** DOCUMENT INSTANCE *** ############################:)

(: ### function to create the xforms instance of the editable xml-document  ### :)
declare function xrxe:create-document-instance($conf){
   <xf:instance id="{xrxe:document-instance-id($conf)}">
        <document xmlns="">
            {$conf/xrxe:doc/element()[1]}
        </document>
    </xf:instance>
};

(: ### function to create  helper instances for user definied ui-templates  ### :)
declare function xrxe:create-document-helper-instances($conf){
    (
    xrxe:create-load-instance($conf)
    ,
    xrxe:create-ui-template-instance($conf)
    )
};

(: ### function to create a instance to remember which node-editors (subeditors) are allready loaded ### :)
declare function xrxe:create-load-instance($conf){
    (
    <xf:instance id="{xrxe:load-instance-id($conf)}">
        <load xmlns="">
        {
            for $node-editor-id in $conf/xrxe:ui-template/xrxe:ui//xrxe:node-editor/@id
                return element {xs:string($node-editor-id)} {true()}
        }
        </load>
    </xf:instance>
    ,
    <xf:action ev:event="xforms-ready">
        {xrxe:load-first-ui-case($conf)}
    </xf:action>
    )

};

(: ### function to create a instance to store the template of a ui-template to have conneting nodes for embedded node-editors ### :)
(: ### this is not well-designed and has to be revised ###:)
declare function xrxe:create-ui-template-instance($conf){
    <xf:instance id="i-ui-template">
            <ui-template xmlns="">
            {
                $conf/xrxe:ui-template/xrxe:template/element()
            }
            </ui-template>
        </xf:instance>
};

(: ### function to create all submission needed by the document editor ### :)
declare function xrxe:create-document-submissions($conf){
    (
    xrxe:create-save-document-submission($conf)
    ,
    xrxe:create-unescape-document-submission($conf)
    )
};

(: ### function to create a submission that unescapes the document's escaped data using the unescape service definied the services ### :)
(: ### function is triggering the save submission by submission chain when done:)
declare function xrxe:create-unescape-document-submission($conf){
    <xf:submission id="{xrxe:unescape-document-submission-id($conf)}" resource="{xs:string($conf/@services)}?service=unescape-mixed-content"  ref="{xrxe:document-instance-string($conf)}" method="POST" instance="{xrxe:document-instance-id($conf)}" replace="instance">
       {(
       xrxe:create-submission-message('xforms-submit-error', $xrxe-conf:unescape-submit-error)
       ,
       xrxe:create-submission-chain('xforms-submit-done', xrxe:save-document-submission-id($conf))

       )}
    </xf:submission>
};

(: ### function to create a submission to save the xml-document ### :)
declare function xrxe:create-save-document-submission($conf){
    <xf:submission id="{xrxe:save-document-submission-id($conf)}" replace="none" ref="{xrxe:document-instance-string($conf)}/child::element()[1]" method="{$conf/@save-method}" resource="{$conf/@save}">
       {(
       xrxe:create-submission-message('xforms-submit-done', $xrxe-conf:document-saved)
       ,
       xrxe:create-submission-message('xforms-submit-error', $xrxe-conf:save-error)
       )}
    </xf:submission>
};

(:######################## *** DOCUMENT VIEW *** ############################:)

(: ### function to create the view (all ui-controls) of the document-editor ### :)
declare function xrxe:create-document-view($xsd, $conf){

<xf:group model="{xrxe:document-model-id($conf)}" class="xrxeDocumentEditor">
    {(
       xrxe:create-document-header($conf)
        ,
       xrxe:create-document-content($xsd, $conf)
        ,
       xrxe:create-document-footer($conf)
    )}
</xf:group>
};

(: ### function to create the header of the document-editor ### :)
(: ### the header can contain button like [save] etc.### :)
declare function xrxe:create-document-header($conf){
    <xf:group class="xrxeDocumentEditorHeader">{
        if(xs:string($conf/@place-triggers)='top' or xs:string($conf/@place-triggers)='top-and-bottom') then
             xrxe:create-document-triggers($conf, 'header')
        else
            ()
    }</xf:group>

};

(: ### function to create the footer of the document-editor ### :)
(: ### the footer can contain button like [save] etc.### :)
declare function xrxe:create-document-footer($conf){
    <xf:group class="xrxeDocumentEditorFooter">{
        if(xs:string($conf/@place-triggers)='bottom' or xs:string($conf/@place-triggers)='top-and-bottom') then
            xrxe:create-document-triggers($conf, 'footer')
        else
            ()
    }</xf:group>

};

(: ### function to create the content (main-part) of the document-editor ### :)
(: ###  the content can directly be a node-editor or a user defined ui noramlly containing one or more node-editors ### :)
declare function xrxe:create-document-content($xsd, $conf){
    <xf:group class="xrxeDocumentEditorContent">{
        if($conf/xrxe:ui-template) then
            xrxe:create-document-ui($xsd, $conf)
        else
            xrxe:create-node-editor-widget($xsd, $conf)
    }</xf:group>

};

(: ###  creates the triggers of the document-editor for exaple the [save]-Button ### :)
declare function xrxe:create-document-triggers($conf, $place){

    <xf:group class="xrxeDocumentEditorTriggers">
    {
        (
        if ($conf/@save) then
            xrxe:create-save-trigger($conf)
        else
            ()
        ,
        if ($conf/@save-close) then
            xrxe:create-save-close-trigger($conf)
        else
            ()

        )
    }
    </xf:group>
};

(:### function that creates a trigger to save the xml-document ###:)
declare function xrxe:create-save-trigger($conf){
        <xf:trigger class="xrxeTrigger xrxeSaveTrigger" title="save">
            <xf:label class="xrxeSaveTriggerLabel">{$xrxe-conf:save}</xf:label>
            {xrxe:create-save-actions($conf)}
        </xf:trigger>
};

(:### function that definies the actions performed when the document is saved ###:)
declare function xrxe:create-save-actions($conf){
    (
    xrxe:send-unecape-document-submission($conf)
    ,
    xrxe:skipshutdown('true')
    )
};

(:### function that creates a trigger to save the xml-document and imediatly load another document definied by $conf/@save-close###:)
declare function xrxe:create-save-close-trigger($conf){

        <xf:trigger class="xrxeTrigger xrxeSaveCloseTrigger">
            <xf:label class="xrxeSaveCloseTriggerLabel">{$xrxe-conf:save-and-close}</xf:label>
            {xrxe:create-save-actions($conf)}
            <xf:action>
	          <xf:load
	            resource="{$conf/@save-close}"
	            show="replace" />
	        </xf:action>
        </xf:trigger>
};

(:### function to create the send-action to use the unescape-submission ###:)
declare function xrxe:send-unecape-document-submission($conf){
    <xf:send submission="{xrxe:unescape-document-submission-id($conf)}" />
};


(:### function to create the send-action to use the save-submission ###:)
(:### currently not used becuase xrxe:send-unecape-document-submission is saving by submission chain ###:)
(:### DEPREACTED ??? ###:)
declare function xrxe:send-save-document-submission($conf){
    <xf:send submission="{xrxe:save-document-submission-id($conf)}" />
};

(:######################## *** TEMPLATE EDITOR   *** ############################:)

(:### function to create an xforms-application off the user-defined ui-template ###:)
(:### currenty supports only switch ###:)
(:### Maybe the ui-template should be xforms code that is just used and only the xrxe:node-editors are transformed ###:)
declare function xrxe:create-document-ui($xsd, $conf){
let $ui := $conf/xrxe:ui-template/xrxe:ui
return
    <xf:group class="xrxeTemplateEditor">{
        for $switch in $ui/xrxe:switch
            return
            xrxe:create-switch-ui($switch, $xsd, $conf)
    }</xf:group>
};

(:### crates a tab-switch-xforms-application ###:)
declare function xrxe:create-switch-ui($switch, $xsd, $conf){
    (
    xrxe:create-ui-triggers($switch, $xsd, $conf)
    ,
    xrxe:create-ui-switch($switch, $xsd, $conf)
    )
};

(:### creates hidden div for tag triggers in  betterforms tabContainer-switch ###:)
declare function xrxe:create-ui-triggers($switch, $xsd, $conf){
    (:tabConatiner doesn't render correctly in betterFORM springBud yet : style="display:none;":)
    <div>
    {
    if($xrxe-conf:switch-type='tabContainer') then
        attribute style {"display:none;"}
    else
        ()
    }
    {
    for $tab in $switch/xrxe:tab
        return
        xrxe:create-ui-trigger($tab, $xsd, $conf)
    }
    </div>
};

(:### creates a trigger for a user defined switch ###:)
declare function xrxe:create-ui-trigger($tab, $xsd, $conf){
    let $tab-name := $tab/xrxe:trigger/text()
    return
    <xf:trigger id="t-{$tab-name}-case" class="xrxeTemplateTrigger">
        <xf:label>{$tab-name}</xf:label>
        <xf:toggle case="{$tab-name}-case" />
         {
        if(count($tab//xrxe:node-editor/@embed[data(.)="true"]) gt 0) then
             xrxe:load-node-editors($tab/xrxe:case, $conf)
         else
             ()
        }
        (:only for Demonstrator of MOM/VDU:)
        <script>editorDemoMode();</script>
     </xf:trigger>
};

declare function xrxe:load-first-ui-case($conf){
   let $ui := $conf/xrxe:ui-template/xrxe:ui
   let $tab := $ui/xrxe:switch/xrxe:tab[1]
    return

    if(count($tab//xrxe:node-editor/@embed[data(.)="true"]) gt 0) then
         xrxe:load-node-editors($tab/xrxe:case, $conf)
    else
       ()
};


(:### creates actions to load node-editor contained in the user defined ui ###:)
declare function xrxe:load-node-editors($case, $conf){
   for $node-editor in $case/xrxe:node-editor
        return
            xrxe:load-node-editor($node-editor, $conf)
};

(:### creates an action to load node-editor contained in the user defined ui ###:)
declare function xrxe:load-node-editor($node-editor, $conf){

    let $id := xs:string($node-editor/@id)
    return
        (
        <xf:action if="{xrxe:load-instance-string($conf)}/{$id}!=0">
            {(
                xrxe:set-ui-tab-loaded($conf, $id)
                ,
                xrxe:ensure-node-exists($conf, $node-editor)
                ,
                xrxe:embed-node-editor($conf, $node-editor)
            )}
        </xf:action>
        )
};

(:### creates an action remember that the node-editor is allready loaded using the helper insatnce ###:)
declare function xrxe:set-ui-tab-loaded($conf, $id){
    <xf:setvalue ref="{xrxe:load-instance-string($conf)}/{$id}" value="0"/>
};

(:### creates an action that ensures that the node of the node-editor is existing within the document to be able to post it. If not, the action first creates the node within the document ###:)
declare function xrxe:ensure-node-exists($conf, $node-editor){
    (
    let $node-path := concat(xrxe:absolute-path($conf), $node-editor/@node-path)

    let $context := concat(xrxe:document-instance-string($conf), functx:substring-before-last($node-path, '/'))
    return
    <xf:action if="not(exists({xrxe:document-instance-string($conf)}{$node-path}))">
        <xf:insert  nodeset="{$context}/element()" position="after" context="{$context}" origin="instance('i-ui-template'){$node-path}"/>
    </xf:action>
    )
};

(:### action that loads an embedded node-editor to the user-defined ui###:)
declare function xrxe:embed-node-editor($conf, $node-editor){

let $node-path := concat(xrxe:absolute-path($conf), $node-editor/@node-path)
return
<xf:action if="exists({xrxe:document-instance-string($conf)}{$node-path})">
    <xf:load show="embed" targetid="d-{$node-path}">
        {
        let $xsd-context-path := xrxe:xsd-context-path($conf) (:xs:string($node-editor/@xsd-context-path):)

        let $template-path := xs:string($node-editor/@template-path)
        let $url :=
        if ($node-editor/@url) then
            xs:string($node-editor/@url)
        else
            let $xsd-context-path := xrxe:xsd-context-path($conf) (: xs:string($node-editor/@xsd-context-path) :)

            let $template-path := xs:string($node-editor/@template-path)
            return
            concat($conf/@services, '?service=get-subeditor&amp;doc=', $conf/@docloc, '&amp;services=', $conf/@services, '&amp;xsd=', $conf/@xsdloc, '&amp;node-path=', $node-path, '&amp;xsd-context-path=', $xsd-context-path, '&amp;template-path=', $template-path)

        return
            <xf:resource value="'{$url}'"/>

        }
    </xf:load>
</xf:action>

};

(:###  creates the switch of the user defined ui ###:)
declare function xrxe:create-ui-switch($switch, $xsd, $conf){
    (:tabConatiner doesn't render correctly in betterFORM springBud yet : appearance="dijit:TabContainer":)
    <xf:switch id="s-ui"  class="xrxeTemplateSwitch">
    {
    if($xrxe-conf:switch-type='tabContainer') then
        attribute appearance {"dijit:TabContainer"}
    else
        ()
    }
    {
         for $tab at $i in $switch/xrxe:tab
            return
               xrxe:create-ui-case($tab, $xsd, $conf, $i)
    }
    </xf:switch>
};

(:###  creates the cases of the  user defined ui ###:)
declare function xrxe:create-ui-case($tab, $xsd, $conf, $i){
   let $tab-name := $tab/xrxe:trigger/text()
   let $selected :=
    if($i=1) then
        true()
    else
        false()
   return
    <xf:case id="{$tab-name}-case" class="xrxeTemplateCase" selected="{$selected}">
         <xf:action ev:event="xforms-focus">
               <xf:message>xform-select</xf:message>
         </xf:action>
        <xf:label class="xrxeUICaseLabel">{$tab-name}</xf:label>
        {xrxe:create-ui-case-content($tab/xrxe:case, $xsd, $conf)}
    </xf:case>
};

(:###  creates the content  of the  cases in the user defined ui ###:)
(:### currently only supports embedded node editors###:)
(:### TODO: Non embedded subeditors ###:)
declare function xrxe:create-ui-case-content($case, $xsd, $conf){
   for $node-editor in $case/xrxe:node-editor
        return
        if(xs:string($node-editor/@embed)="true" and $node-editor/@url) then
            <div id="d-{concat(xrxe:absolute-path($conf), $node-editor/@node-path)}">
                <div align="center">
                    {$xrxe-conf:loading}
                     <br/>
                     <img src="/bfResources/images/indicator.gif"/>
                </div>
            </div>
        else
            (:TODO Not embeded Subeditors here. :)
            ()
};

(: ##################################################### END DOCUMENT EDITOR ##################################################################### :)

(: ##################################################### START NODE EDITOR ##################################################################### :)

(: ### creates a node-editor i.e. an xforms-application that provides the functionalities to edit the data of an xml-node and its descendents ### :)
declare function xrxe:create-node-editor($template, $xsd, $conf){

         (
         xrxe:create-node-model($template, $xsd, $conf)
         (:,
         xrxe:create-xsd($xsd, $conf):)
         ,
         xrxe:create-node-view($template, $xsd, $conf)
         )
};

(:### function to get a copy of the template stored in $conf/xrxe:template ###:)
(:### the template has to be copied because the pathes of the nodes used for the editor may not cotain steps of the conf-element ###:)
(:declare function xrxe:get-template($conf){
    qxrxe:copy($conf/xrxe:template/element())
};:)

declare function xrxe:get-template($xsd, $conf){

        let $template := qxrxe:get-node-template(xrxe:root-xsd-path($conf), $xsd)
        let $declare-namespaces :=  xrxe:declare-namespaces($template)
        return $template
};

(: ######################################## START NODE MODEL ################################################ :)


(:### function to create a xforms-model for a node editor ###:)
(:TODO: add schema to model:)
declare function xrxe:create-node-model($template, $xsd, $conf){
        <xf:model id="{xrxe:model-id($template, $conf)}">
                {(
                xrxe:create-node-instances($template, $xsd, $conf)
                ,
                xrxe:create-nodesets-binds($template, (), $xsd, $conf)
                ,
                xrxe:create-node-actions($conf)
                ,
                xrxe:create-node-submissions($template, $conf)
                )}
         </xf:model>
};

(:######################## *** NODE MODEL INSTANCES *** ############################:)

(:### function to create all xforms-instances for a node-editor ###:)
declare function xrxe:create-node-instances($template, $xsd, $conf){
        let $instances := ''
        return
            (
            xrxe:create-data-instance($template, $xsd, $conf)
            ,
            xrxe:create-new-instance($template, $conf)
            )
};

(:### function to create an xforms-instance of the actual node-data. This data will be inserted into the document  ###:)
declare function xrxe:create-data-instance($template, $xsd, $conf){

    <xf:instance id="{xrxe:data-instance-id($template, $conf)}" >
        <data xmlns="">
            {xrxe:get-node-data($template, $xsd, $conf)}
        </data>
    </xf:instance>
};

(:### function to get the Node out of the Document stored in $conf###:)
(:TODO: revise an split to more functions:)
declare function xrxe:get-node-data($template, $xsd, $conf){

    let $doc := $conf/xrxe:doc
    let $declare-namespaces := xrxe:declare-namespaces($doc/node())



    let $get-node := concat('$doc' , xrxe:absolute-path($conf), '[1]')
    let $node := util:eval($get-node)

    let $node :=
        if($node) then
            qxrxe:copy($node)
        else
            element {name($template)} {} (: Dummy to handle non existing data nodes :)

    return xrxe:pre-transform($node, $template, $conf, $xsd)
};

(: ##################################################### START ESCAPE #####################################################################:)

(:### function to  preprocess the node for example to escape mixed content###:)
declare function xrxe:pre-transform($node, $template, $conf, $xsd){
    xrxe:escape-mixed-content($node, $template, $conf, $xsd)
};

(:### function to escape mixed content ###:)
declare function xrxe:escape-mixed-content($node, $template, $conf, $xsd){
     let $escape-method :="xquery"

     let $node :=
        if($escape-method ="xslt") then
            xrxe:escape-mixed-content-xslt($node, $template)
        else
            xrxe:escape-mixed-content-xquery($node, $conf, $xsd)


    return $node
};

(:### DEPRECATED ###:)
declare function xrxe:escape-mixed-content-xslt($node, $template){
    let $escape-xslt := xrxe:create-escape-mixed-content-xslt($template)
    return
        if($escape-xslt) then
            transform:transform($node, $escape-xslt, ())
        else
            $node
};


declare function xrxe:escape-mixed-content-xquery($node, $conf, $xsd){

        if($node instance of element()) then
            let $node-info := qxrxe:get-node-info(xrxe:node-info-path($node, (), $conf), () , $xsd)
            return
                element {name($node)} {
                    (
                    $node/@*,
                    if(qxrxe:is-mixed($node-info, $xsd)) then
                        xrxe:mask-content($node)
                    else
                        for $child-nodes in ($node/element() | $node/text())
                        return xrxe:escape-mixed-content-xquery($child-nodes, $conf, $xsd)
                    )
            }
        else
            $node



    (:let $path := xrxe:xsd-path($node, $conf)
    let $traversed:= <traverse>{$path}</traverse>
    let $child-nodes :=
        for $child-node in  ($node/element() | $node/attribute())
            return xrxe:traverse($child-node, $xsd, $conf)
    return ($traversed, $child-nodes)
    :)
};

declare function xrxe:mask-content($node){
    string-join(
        for $child in $node/element() | $node/text()
            return
            xrxe:mask-node($child)
        , '')
};

declare function xrxe:mask-node($node){
    if($node instance of element()) then
        xrxe:mask-element($node)
    else if($node instance of text()) then
        data($node)
    else
        ()
};

declare function xrxe:mask-element($element){
    (xrxe:starttag($element),  xrxe:mask-content($element), xrxe:endtag($element))
};

declare function xrxe:starttag($element){
    concat ('<', node-name($element), xrxe:mask-xmlns($element), xrxe:mask-attributes($element), '>')
};

declare function xrxe:mask-xmlns($element){
  string-join((xrxe:mask-element-xmlns($element), xrxe:mask-attributes-xmlns($element)), '')
};

declare function xrxe:mask-element-xmlns($element){
    let $prefix := qxsd:get-prefix(name($element))
    let $prefix-xmlns-string :=
        if($prefix) then
            concat(':', $prefix)
        else ''
    return
    concat(' xmlns', $prefix-xmlns-string ,'="', namespace-uri($element), '"')
};

declare function xrxe:mask-attributes($element){
    let $attribute-strings :=
    for $attribute in $element/attribute()
        return xrxe:mask-attribute($attribute)
    return fn:string-join($attribute-strings, '')

};

declare function xrxe:mask-attributes-xmlns($element){
 for $attribute in $element/attribute()
 let $namespace := namespace-uri($attribute)
 return
   if($namespace) then
      let $prefix := substring-before(xs:string(node-name($attribute)), ':')
      return
      concat(' xmlns:',  $prefix ,'="' , $namespace, '"')
   else ()
};

declare function xrxe:mask-attribute($attribute){
  concat(' ', node-name($attribute), '="', data($attribute), '"')
};

declare function xrxe:endtag($element){
concat ('</', node-name($element), '>')
};

(:DEPRECATED:)

declare function xrxe:create-escape-mixed-content-xslt($template){

let $escape-match:= xrxe:get-leaf-nodes-to-escape-match($template)
return


            <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cei="http://www.monasterium.net/NS/cei" xmlns:ead="urn:isbn:1-931666-22-9" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:p="http://vdu.www.uni-koeln.de/ns/person">
                <xsl:template match="{$escape-match}">
                    <xsl:param name="escape"/>
                    <xsl:choose>
                        <xsl:when test="$escape='true'">
                            <xsl:call-template name="writeEscapedNode">
                                <xsl:with-param name="escape">true</xsl:with-param>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="leaveNode">
                                <xsl:with-param name="escape">true</xsl:with-param>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:template>
                <xsl:template match="*">
                    <xsl:param name="escape"/>
                    <xsl:choose>
                        <xsl:when test="$escape='true'">
                            <xsl:call-template name="writeEscapedNode">
                                <xsl:with-param name="escape" select="$escape"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="leaveNode">
                                <xsl:with-param name="escape" select="$escape"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:template>
                <xsl:template name="leaveNode">
                    <xsl:param name="escape"/>
                    <xsl:copy>
                        <xsl:copy-of select="./@*"/>
                        <xsl:apply-templates>
                            <xsl:with-param name="escape" select="$escape"/>
                        </xsl:apply-templates>
                    </xsl:copy>
                </xsl:template>
                <xsl:template name="writeEscapedNode">
                    <xsl:param name="escape"/>
                    <xsl:call-template name="escapedStartTag"/>
                    <xsl:apply-templates>
                        <xsl:with-param name="escape" select="$escape"/>
                    </xsl:apply-templates>
                    <xsl:call-template name="escapedEndTag"/>
                </xsl:template>
                <xsl:template name="escapedStartTag">
                    <xsl:text>&lt;</xsl:text>
                    <xsl:value-of select="name(.)"/>
                    <xsl:for-each select="./@*">
                        <xsl:call-template name="escapedAttribute"/>
                    </xsl:for-each>
                    <xsl:text>&gt;</xsl:text>
                </xsl:template>
                <xsl:template name="escapedAttribute">
                    <xsl:text>&#x20;</xsl:text>
                    <xsl:value-of select="name(.)"/>
                    <xsl:text>="</xsl:text>
                    <xsl:value-of select="."/>
                    <xsl:text>"</xsl:text>
                </xsl:template>
                <xsl:template name="escapedEndTag">
                    <xsl:text>&lt;/</xsl:text>
                    <xsl:value-of select="name(.)"/>
                    <xsl:text>&gt;</xsl:text>
                </xsl:template>
            </xsl:stylesheet>

};

(:creates a string used by the xslt containing all pathes of the leafs of the templated joined by  | to identify possible mixed content nodes:)
declare function xrxe:get-leaf-nodes-to-escape-match($template){
        let $leafs := functx:leaf-elements($template)
        let $leaf-paths :=
            for $leaf in $leafs
            return
                xrxe:data-path($leaf)

        let $escape-match := string-join($leaf-paths, ' | ')
        return $escape-match
};



(: ##################################################### END ESCAPE #####################################################################:)

(:### function that creates an instance storing all (empty) elements and attributes that can be inserted into the node ###:)
(:### the elements to insert are currently only empty elements. They should be the elements that allready contain obligatory descendants ###:)
(:### TODO: create the filled emelemnts dynamically on demand ###:)
declare function xrxe:create-new-instance($template, $conf){
    let $all-element-names :=
        for $element in $template/descendant::element()
            return name($element)

    let $all-attribute-names :=
        for $attribute in $template/descendant-or-self::element()/attribute::*
            return name($attribute)

    let $instance :=
    <xf:instance id="{xrxe:new-instance-id($template, $conf)}">
        <new xmlns="">
            {(
            for $name in fn:distinct-values($all-element-names)
            return
                element {$name} {}
            ,
            element attribute {
                for $attribute in fn:distinct-values($all-attribute-names)
                return attribute {$attribute} {''}
            }
            )}
        </new>
    </xf:instance>
    return $instance
};

(:######################## *** NODE MODEL BINDS *** ############################:)


(:###  prototype function to traverse the template. Not realy used ###:)
declare function xrxe:traverse($node, $xsd, $conf){

    let $path := xrxe:xsd-path($node, $conf)
    let $traversed:= <traverse>{$path}</traverse>
    let $child-nodes :=
        for $child-node in  ($node/element() | $node/attribute())
            return xrxe:traverse($child-node, $xsd, $conf)
    return ($traversed, $child-nodes)

};


(:### traverses template recusivly to bind every nodeset to specific XSD restrictions ###:)
(:### TODO: don't use template, traverse XSD ###:)
declare function xrxe:create-nodesets-binds($node, $parent-info, $xsd, $conf){

    let $node-info := qxrxe:get-node-info(xrxe:node-info-path($node, $parent-info, $conf), $parent-info , $xsd)

    let $binds := xrxe:create-nodeset-binds($node, $node-info, $xsd, $conf)

    let $child-nodes-binds :=
        for $child-node in ($node/element() | $node/attribute())
            return xrxe:create-nodesets-binds($child-node, $node-info, $xsd, $conf)

    return ((:<node-info>{$node-info}</node-info>, :)$binds, $child-nodes-binds)

};

(: Include  xrxe:create-data-bind :)
declare function xrxe:create-nodeset-binds($node, $node-info, $xsd, $conf){
    (
    xrxe:create-data-bind($node, $node-info, $xsd, $conf)
    )
};

(:### creates a xforms bind for a nodeset defining the properties of the nodeset described in the xsd ###:)
(:### TODO: bind type of all simpleTypes ###:)
declare function xrxe:create-data-bind($node, $node-info, $xsd, $conf){
    let $type := xrxe:bind-type($node-info, $xsd, $conf)
    return
    element
        xf:bind
        {
            xrxe:create-attribute('id', xrxe:data-bind-id($node, $conf))
            ,
            xrxe:create-attribute('nodeset', concat(xrxe:get-data-instance-string($conf), xrxe:data-path($node)))
            ,
            $type
            ,
            xrxe:create-attribute('constraint', qxrxe:get-constraint($node-info, $xsd))
            ,
            xrxe:create-attribute('required', ())
            ,
            xrxe:create-attribute('relevant', ())
            ,
            xrxe:create-attribute('readonly', ())
            ,
            xrxe:create-attribute('calculate', ())
        }
};

declare function xrxe:bind-type($node-info, $xsd, $conf){
let $type-name := qxrxe:type-name($node-info, $xsd, $conf)
return
    if($type-name instance of xs:string) then
         xrxe:create-attribute('type', $type-name)
    else ()




(:TODO handle simple non-named types:)
(:TODO handle complexType with simpleContent (doen't work in betterFORM):)
};



(:######################## *** NODE MODEL ACTIONS *** ############################:)

(:### function that creates all actions used by the node-editor###:)
declare function xrxe:create-node-actions($conf){
    (
        xrxe:create-validate-action($conf)
    )
};

(:### function that creates a validation action every time the node-editor-model is refrehed ###:)
(:### Is there a better event to handle that action? ###:)
declare function xrxe:create-validate-action($conf){
<xf:action ev:event="xforms-refresh">
      <xf:send submission="{xrxe:get-validate-submission-id($conf)}" />
</xf:action>
};

(:######################## *** NODE MODEL SUBMISSIONS *** ############################:)

(:### function that creates all submissions used by the node-editor###:)
declare function xrxe:create-node-submissions($template, $conf){
    (
        xrxe:create-post-submisssion($template, $conf)
        ,
        xrxe:create-validate-submisssion($template, $conf)
    )
};

(:### creates a submissions to post the node of the node-editor into the document of the document-editor ###:)
declare function xrxe:create-post-submisssion($template, $conf){
    <xf:submission id="{xrxe:get-post-submission-id($conf)}" ref="{concat(xrxe:get-data-instance-string($conf), '/', xrxe:data-path($template))}"  replace="none" method="post" resource="model:{xrxe:document-model-id($conf)}#{ xrxe:document-instance-string($conf)}/document{xrxe:absolute-path($conf)}">
       <xf:action ev:event="xforms-submit-done">
       </xf:action>
       <xf:action ev:event="xforms-submit-error">
           {
           <xf:message>{$xrxe-conf:post-error}</xf:message>
           }
       </xf:action>
   </xf:submission>
};

(:### creates a submissions to validate the node against its binds ###:)
declare function xrxe:create-validate-submisssion($template, $conf){

         <xf:submission id="{xrxe:get-validate-submission-id($conf)}" validate="true" replace="none" method="get" resource="model:{xrxe:get-model-id($conf)}#{xrxe:get-data-instance-string($conf)}/data">
            <xf:action ev:event="xforms-submit" />
            <xf:action ev:event="xforms-submit-done">
                <xf:send if="exists(bf:instanceOfModel('{xrxe:document-model-id($conf)}', '{xrxe:document-instance-id($conf)}'){xrxe:absolute-path($conf)})" submission="{xrxe:get-post-submission-id($conf)}" />
            </xf:action>
            <xf:action ev:event="xforms-submit-error">
               <xf:message>{name($template)}{$xrxe-conf:not-valid}</xf:message>
            </xf:action>
        </xf:submission>
};


(: ######################################## END NODE MODEL ################################################ :)

(: ######################################## START NODE VIEW ################################################ :)

(: ### function to create the view (all ui-controls) of the node-editor ### :)
declare function xrxe:create-node-view($template, $xsd, $conf){

        (:### get the information of the nodeset decribed in the xsd ###:)
        let $node-info := qxrxe:get-node-info(xrxe:node-info-path($template, (), $conf), () , $xsd)

        return
        <xf:group model="{xrxe:get-model-id($conf)}" class="xrxeNodeEditorGroup">
        {(
            xrxe:create-nodeset-controls($template, $node-info, $xsd, $conf)
            ,
            xrxe:create-notesets-dialogs($template, $node-info, $xsd, $conf)
        )}
        </xf:group>
};

 (:########################  *** NODESET CONTROLS ***  ############################:)

(: ### function to all ui-controls for the current nodeset (except) the dialogs ### :)
declare function xrxe:create-nodeset-controls($node, $node-info, $xsd, $conf){

        <xf:group class="xrxeNodeset">{
         (
         if(xrxe:root($node)) then
              xrxe:group-nodeset($node, $node-info, $xsd, $conf)
         else
             xrxe:create-repeat-nodeset($node, $node-info, $xsd, $conf)
         ,
         if(fn:not(xrxe:root($node))) then
            xrxe:create-insert-node-trigger($node, $node-info, $xsd, $conf)
         else
            ()
         )
        }</xf:group>
};

(: ### function to create a xforms group for non repeatable nodes (only used for the root node of the node-editors node) ### :)
declare function xrxe:group-nodeset($node, $node-info, $xsd, $conf){
        (
        <xf:group ref="{xrxe:indexed-nodeset-path($node, $xsd, $conf)}" class="xrxeRootNode">
            {xrxe:create-node-control($node, $node-info, $xsd, $conf)}
        </xf:group>
        )
};

(: ### function to create a xforms repat for the current nodeset ### :)
(: ### for every nodeset (except root node of the node-editors node) the controls of the nodes are repated by a repat structure ###:)
declare function xrxe:create-repeat-nodeset($node, $node-info, $xsd, $conf){
    (
    xrxe:create-nodeset-label($node, $node-info, $xsd, $conf)
   (: ,
    xrxe:debug-count-nodeset($node, $node-info, $xsd, $conf)   :)
    ,
    <xf:repeat nodeset="{xrxe:relative-child-path($node, $node-info, $xsd, $conf)}" id="{xrxe:repeat-id($node, $conf)}" class="xrxeRepeat xrxeNodesetRepeat">
        {xrxe:create-node-control($node, $node-info, $xsd, $conf)}
    </xf:repeat>
    )
};

(:### If a special label for the plural of the nodes is availabe in the xsd this label is rendered on top of the repatead nodes###:)
declare function xrxe:create-nodeset-label($node, $node-info, $xsd, $conf){
    let $plural-label := qxrxe:get-plural-label($node-info, $xsd)
    return
    if($plural-label) then
        <xf:label class="xrxeNodesetLabel">{$plural-label}</xf:label>
    else
        ()
};

(:### creates a trigger to insert a node into its nodeset at the end of the nodeset. ###:)
(:### This trigger is also available if the nodeset is empty ###:)
declare function xrxe:create-insert-node-trigger($node, $node-info, $xsd, $conf){
let $label := qxrxe:get-label($node-info, $xsd)
let $max := qxrxe:max-occurs($node-info, $xsd)
return
    (
    <xf:trigger class="xrxeInsertNodeTrigger" >
        {
        if($max) then
            attribute ref {
                concat('.[count(', xrxe:relative-child-path($node, $node-info, $xsd, $conf), ') lt ', $max, ']')
            }
        else
            ()
        }

        <xf:label class="xrxeLabel xrxeTriggerLabel xrxeInsertNodeTriggerLabel">{$xrxe-conf:insert-trigger-label}{' '}{$label}</xf:label>
        {xrxe:insert-node-action($node, $node-info, $xsd, $conf)}
    </xf:trigger>
    )
};

(:### creates an action to insert a node after done some preparation###:)
declare function xrxe:insert-node-action($node, $node-info, $xsd, $conf){
    <xf:action>
    {
    (:This is not neccassary as soon as the insered instance is created dynamically:)
    xrxe:set-default-node-value($node, $node-info, $xsd, $conf)
    ,
    xrxe:insert-node($node, $node-info, $xsd, $conf)
    }
    </xf:action>
};

(:### if a default value of the node is defined within the xsd this value is set to the node before inserting it into its nodeset ###:)
declare function xrxe:set-default-node-value($node, $node-info, $xsd, $conf){
    let $default-value := qxrxe:get-default-value($node-info, $xsd)

    let $node-path :=
        if(qxrxe:is-xs-attribute($node-info)) then
            concat('attribute/@', name($node))
        else
             name($node)

    return
    (
    if($default-value) then
        <xf:setvalue ref="{xrxe:get-new-instance-string($conf)}/{$node-path}" value="{$default-value}"/>
    else
        ()
     )
};

(:### action that inserst a node into a context ###:)
declare function xrxe:insert-node($node, $node-info, $xsd, $conf){
    if (qxrxe:is-xs-element($node-info)) then
        (
        <xf:insert context="{xrxe:indexed-node-path($node/parent::*, $xsd, $conf)}" origin="{concat(xrxe:get-new-instance-string($conf), '/', name($node))}"  nodeset="{xrxe:indexed-nodeset-path($node, $xsd, $conf)}"/>
        )
    else if(qxrxe:is-xs-attribute($node-info)) then
        (:<xf:message><xf:output value="name({xrxe:indexed-node-path($node/parent::*, $xsd, $conf)})" /></xf:message>:)
        <xf:insert context="{xrxe:indexed-node-path($node/parent::*, $xsd, $conf)}" origin="{concat(xrxe:get-new-instance-string($conf), '/attribute/@', name($node))}"  />
    else ()
};


(:######################## *** NODE CONTROLS ***  ############################:)

(:### function to create all ui-controls for one node (element or attribute) ###:)
declare function xrxe:create-node-control($node, $node-info, $xsd, $conf){
    <xf:group class="xrxeNode">
    {(

     xrxe:create-node-header($node, $node-info, $xsd, $conf)
     ,
     (:temp here. integrate with children:)
     if (qxrxe:is-xs-element($node-info)) then
        xrxe:create-attributes($node, $node-info, $xsd, $conf)
     else
        ()
     ,
     if(qxrxe:get-type-type($node-info, $xsd)='complexType' and qxrxe:is-mixed($node-info, $xsd)!=true()) then
        xrxe:create-children-container($node, $node-info, $xsd, $conf)
     else
        xrxe:create-node-content-control($node, $node-info, $xsd, $conf)
     )}
     </xf:group>
};

(:### creates a header for every node containing its label and triggers for its actions (functions) ###:)
declare function xrxe:create-node-header($node, $node-info, $xsd, $conf){
    <xf:group class="xrxeNodeHeader">{(
     xrxe:create-node-label($node, $node-info, $xsd, $conf)
     ,
     xrxe:create-node-functions($node, $node-info, $xsd, $conf)
    )}</xf:group>
};

(:### creates an xforms label for a node ###:)
declare function xrxe:create-node-label($node, $node-info, $xsd, $conf){
    (:<xf:label>{xrxe:indexed-node-path($node, $xsd, $conf)}</xf:label>:)
    <xf:label class="xrxeNodeLabel">{qxrxe:get-label($node-info, $xsd) }</xf:label>
};


(:######################## *** CHILDREN CONTAINER ***############################:)

(:### creates an xforms container control containing the node's child-elements ###:)
declare function xrxe:create-children-container($node, $node-info, $xsd, $conf){

    let $children-control :=  qxrxe:get-children-control($node-info, $xsd)
    return
        if($children-control='switch') then
            xrxe:create-switch-children($node, $node-info, $xsd, $conf)
        else if($children-control='dialog') then
            xrxe:create-dialog-children($node, $node-info, $xsd, $conf)
        else if($children-control='group') then
            xrxe:create-group-children($node, $node-info, $xsd, $conf)
        else
            xrxe:create-list-children($node, $node-info, $xsd, $conf)
};

(:DEPRECATED:)
(:declare function xrxe:create-tab-switch-children($node, $node-info, $xsd, $conf){
    (
    <div style="display:none;">
        {xrxe:create-child-elements-switch-triggers($node, $node-info, $xsd, $conf)}
    </div>
    ,
    <xf:switch appearance="dijit:TabContainer" id="{xrxe:get-switch-children-id($node, $conf)}" class="xrxeTabContainer">
        {xrxe:create-child-elements-switch-cases($node, $node-info, $xsd, $conf)}
    </xf:switch>
    )
};:)

(:### creates an trigger-switch-case control as container for the node's child-elements ###:)
declare function xrxe:create-switch-children($node, $node-info, $xsd, $conf){
        (
        <div>
        {
            if($xrxe-conf:switch-type='tabContainer') then
                attribute style {"display:none;"}
            else
                ()
        }
        {xrxe:create-child-elements-switch-triggers($node, $node-info, $xsd, $conf)}
        </div>
        ,
        <xf:switch  id="{xrxe:get-switch-children-id($node, $conf)}" class="xrxeSwitch">
        {
             if($xrxe-conf:switch-type='tabContainer') then
                attribute appearance {"dijit:TabContainer"}
             else
                ()
        }
            {xrxe:create-child-elements-switch-cases($node, $node-info, $xsd, $conf)}
        </xf:switch>
        )
};

(:### creates the case controls for all child elementset ###:)
declare function xrxe:create-child-elements-switch-cases($node, $node-info, $xsd, $conf){
    for $child-element in xrxe:get-relevant-element-children($node, $node-info, $xsd, $conf)
        let $child-element-info :=  qxrxe:get-node-info(xrxe:node-info-path($child-element, $node-info, $conf), $node-info , $xsd)
        return
            xrxe:create-node-case($child-element, $child-element-info, $xsd, $conf)
};

(:### creates the triggers to toggle the cases of every child elementset ###:)
declare function xrxe:create-child-elements-switch-triggers($node, $node-info, $xsd, $conf){
    <xf:group class="xrxeSwitchTriggers">
    {
    for $child-element in xrxe:get-relevant-element-children($node, $node-info, $xsd, $conf)
    let $child-element-info :=  qxrxe:get-node-info(xrxe:node-info-path($child-element, $node-info, $conf), $node-info , $xsd)
    return
        <xf:trigger id="{xrxe:get-trigger-case-id($child-element, $conf)}" class="xrxeSwitchTrigger">
            <xf:label>{xrxe:get-tab-label($child-element, $child-element-info, $xsd, $conf)}</xf:label>
            <xf:toggle case="{xrxe:get-case-id($child-element, $conf)}" />
            <script>editorDemoMode();</script>
        </xf:trigger>
   }
   </xf:group>
};

(:### creates a case control for every child elementset ###:)
declare function xrxe:create-node-case($node, $node-info, $xsd, $conf){
     <xf:case id="{xrxe:get-case-id($node, $conf)}" class="xrxeSwitchCase">
        {(
        <xf:label>{xrxe:get-tab-label($node, $node-info, $xsd, $conf)}</xf:label>
        ,
        xrxe:create-nodeset-controls($node, $node-info, $xsd, $conf)
        )}
    </xf:case>
};

(:### function to get the label of the tab ###:)
(:### if a plural label for the nodeset is availabe that use the plural label ###:)
declare function xrxe:get-tab-label($node, $node-info, $xsd, $conf){
    let $plural-label:= qxrxe:get-plural-label($node-info, $xsd)
    return
     if ($plural-label) then
         $plural-label
     else
         qxrxe:get-label($node-info, $xsd)
};


declare function xrxe:create-dialog-children($node, $node-info, $xsd, $conf){
        ()(:
        xrxe:create-child-elements-dialog-triggers($node, $node-info, $xsd, $conf)
        ,
        xrxe:create-child-elements-dialogs($node, $node-info, $xsd, $conf)
        :)
};

(:
declare function xrxe:create-child-elements-dialog-triggers($node, $node-info, $xsd, $conf){
    for $child-element in xrxe:get-relevant-element-children($node, $node-info, $xsd, $conf)
    let $child-element-info := qxrxe:get-element-info(xrxe:xsd-path($child-element, $conf), $xsd)
    return
        <xf:trigger id="{xrxe:get-trigger-case-id($child-element, $conf)}" class="xrxeDialogTrigger">
            <xf:label>{qxrxe:get-label($child-element-info, xrxe:xsd-path( $child-element, $conf), $xsd)}</xf:label>
            <xf:toggle dialog="{xrxe:dialog-id($child-element, $conf)}" />
        </xf:trigger>
};

declare function xrxe:create-child-elements-dialogs($node, $node-info, $xsd, $conf){
    for $child-element in xrxe:get-relevant-element-children($node, $node-info, $xsd, $conf)
        let $child-element-info := qxrxe:get-element-info(xrxe:xsd-path($child-element, $conf), $xsd)
        return
            xrxe:create-node-dialog($child-element, $child-element-info, $xsd, $conf)
};

declare function xrxe:create-node-dialog($node, $node-info, $xsd, $conf){
    <bfc:dialog  id="{xrxe:dialog-id($node, $conf)}" class="xrxeDialog">
        {(
        <xf:label>{qxrxe:get-label($node-info, xrxe:xsd-path($node, $conf), $xsd)}</xf:label>
        ,
        xrxe:create-nodeset-controls($node, $node-info, $xsd, $conf)
        )}
    </bfc:dialog>
};:)


(:### creates a group-control as container for the node's child-elements ###:)
declare function xrxe:create-group-children($node, $node-info, $xsd, $conf){
    for $child in xrxe:get-relevant-element-children($node, $node-info, $xsd, $conf)
    return
         let $child-element-info := qxrxe:get-node-info(xrxe:node-info-path($child, $node-info, $conf), $node-info , $xsd)
         return
         <xf:group id="{xrxe:get-group-children-id($node, $conf)}">
         {
         xrxe:create-nodeset-controls($child, $child-element-info, $xsd, $conf)
         }
         </xf:group>
};

(:### processes the node's child-elements without using a container###:)
declare function xrxe:create-list-children($node, $node-info, $xsd, $conf){
    for $child in xrxe:get-relevant-element-children($node, $node-info, $xsd, $conf)
        return
         let $child-element-info := qxrxe:get-node-info(xrxe:node-info-path($child, $node-info, $conf), $node-info , $xsd)
         return
            xrxe:create-nodeset-controls($child, $child-element-info, $xsd, $conf)
};

(:returns the child-elements of the node:)
(:### Use this Function when removing the template and query the xsd ###:)
declare function xrxe:get-relevant-element-children($node, $node-info, $xsd, $conf){
    $node/child::element()
};

(:######################## *** NODE CONTENT CONTROL ***  ############################:)

(:### creates a control for the content of the node (.i.e /text() or data())###:)
declare function xrxe:create-node-content-control($node, $node-info, $xsd, $conf){

    let $content-control :=  qxrxe:get-content-control($node-info, $xsd)
    return
        if($content-control) then
            xrxe:create-declared-node-content-control($node, $content-control, $node-info, $xsd, $conf)
        else
            xrxe:choose-node-content-control($node, $node-info, $xsd, $conf)
};

(:### creates the control that is explicitly defined bey xrxe:content-control within the xsd ###:)
declare function  xrxe:create-declared-node-content-control($node, $content-control, $node-info, $xsd, $conf){
    let $control :=
        if ($content-control='annotation') then
            xrxe:create-annotation-control($node, $node-info, $conf, $xsd)
        else if($content-control='textarea') then
            xrxe:create-textarea-control($node-info,$xsd)
        else if($content-control='input') then
            xrxe:create-input-control($node-info,$xsd)
        else if($content-control='empty') then
            ()
        else
            xrxe:create-input-control($node-info,$xsd)
    return $control
};

(:### function that chooses the content control when not explicitly defined in xsd by type ###:)

declare function xrxe:choose-node-content-control($node, $node-info, $xsd, $conf){
    if(qxrxe:is-enum($node-info, $xsd)) then
        xrxe:create-select1-control($node-info, $xsd)
    else if(qxrxe:is-mixed($node-info, $xsd)=true()) then
        xrxe:create-annotation-control($node, $node-info, $conf, $xsd)
    else
        xrxe:create-input-control($node-info, $xsd)
};


(:### creates an input control for the nodes content ###:)
(:### use ./text()???###:)
declare function xrxe:create-input-control($node-info, $xsd){
    (:incremental="true":)
    <xf:input ref="." class="{xrxe:get-content-control-classes('Input', $node-info)}">
        {(xrxe:get-xforms-control-children($node-info, $xsd))}
    </xf:input>
};

(:### creates an textarea control for the nodes content ###:)
(:### use ./text()???###:)
declare function xrxe:create-textarea-control($node-info, $xsd){
    (:incremental="true":)
    <xf:textarea ref="." class="{xrxe:get-content-control-classes('Textarea', $node-info)}">
        {(xrxe:get-xforms-control-children($node-info, $xsd))}
    </xf:textarea>
};

(:### creates an annotation control for the nodes content ###:)
(:### use ./text()???###:)
declare function xrxe:create-annotation-control($node, $node-info, $conf, $xsd){
    (
    <xf:textarea ref="." mediatype="text/xml" nodepath="{xrxe:xsd-path($node, $conf)}" namespace="{namespace-uri($node)}" nodename="{name($node)}" xsdloc="{$conf/@xsdloc}" services="{$conf/@services}" class="{xrxe:get-content-control-classes('Annotation', $node-info)}" rows="{qxrxe:get-rows($node-info, $xsd)}">
            {(xrxe:get-xforms-control-children($node-info, $xsd))}
    </xf:textarea>
    )
};

(:### creates an select1 for the nodes content ###:)
(:### use ./text()???###:)
declare function xrxe:create-select1-control($node-info, $xsd){
    <xf:select1 ref="." class="{xrxe:get-content-control-classes('Select1', $node-info)}">
        {(
        xrxe:create-items($node-info, $xsd)
        ,
        xrxe:get-xforms-control-children($node-info, $xsd)
        )}
    </xf:select1>
};

(:### function that creates the items of a select1 or select control off the enumaerations within the xsd-typ###:)
declare function xrxe:create-items($node-info, $xsd){
    for $enumeration in qxrxe:get-enums($node-info, $xsd)
        return
            xrxe:create-item($enumeration, $xsd)
};

(:### function that creates one of a select1 or select control off the enumaeration within the xsd-typ###:)
declare function xrxe:create-item($enumeration, $xsd){
    let $label :=
        if(qxrxe:get-label($enumeration, $xsd)) then
            qxrxe:get-label($enumeration, $xsd)
        else
           xs:string($enumeration/@value)


    return
    <xf:item>
        <xf:label>{$label}</xf:label>
        <xf:value>{xs:string($enumeration/@value)}</xf:value>
    </xf:item>
};

(:### function that creates classes for css styling ###:)
(:### revise ###:)
declare function xrxe:get-content-control-classes($control, $node-info){
    let $node-type := concat(upper-case(substring(qxrxe:get-node-type($node-info), 1, 1)), substring(qxrxe:get-node-type($node-info), 2))
    let $class1 := concat('xrxe', $node-type, $control)
    let $class2 := concat('xrxe', $node-type, 'ContentControl')
    let $class3 := concat('xrxe', 'Node',  $control)
    let $class4 := concat('xrxe', 'Node',  'ContentControl')
    let $class5 := concat('xrxe', $control)
    return string-join(($class1, $class2, $class3, $class4, $class5), ' ')
};

(:### function the children of a xforms control ###:)
declare function xrxe:get-xforms-control-children($node-info, $xsd){
     (
     xrxe:get-hint($node-info, $xsd)
     ,
     xrxe:get-help($node-info, $xsd)
     ,
     xrxe:get-alert($node-info, $xsd)
     ,
     xrxe:value-changed-action()
     )
};

(:### if the value of a control is changed this is remembered to warn the user when leaving the page without saving ###:)
declare function xrxe:value-changed-action(){
 <xf:action ev:event="xforms-value-changed">
    {xrxe:skipshutdown('false')}
  </xf:action>
};

(:### add a hint to the control if available in the xsd ###:)
declare function xrxe:get-hint($node-info, $xsd){
 let $hint := qxrxe:get-hint($node-info, $xsd)
 return
        if($hint) then
                 <xf:hint>{$hint}</xf:hint>
              else
                 ()
};

(:### add help to the control if available in the xsd ###:)
declare function xrxe:get-help($node-info, $xsd){
 let $help := qxrxe:get-help($node-info, $xsd)
   return
        if($help) then
                 <xf:help>{$help}</xf:help>
              else
                 ()
};

(:### add an alert to the control if available in the xsd ###:)
declare function xrxe:get-alert($node-info, $xsd){
 let $alert := qxrxe:get-alert($node-info, $xsd)
    return
        if($alert) then
                 <xf:alert>{$alert}</xf:alert>
              else
                 ()

};

(:########################  *** NODE FUNCTIONS ***  ############################:)

(:### function that adds a group conatining triggers to actions to the node / its nodeset ###:)
declare function xrxe:create-node-functions($node, $node-info, $xsd, $conf){
    <xf:group appearance="minimal" class="xrxeGroup xrxeNodeFunctions">
        {(
        if(xrxe:root($node)) then
            ()
        else
            if (qxrxe:is-xs-element($node-info)) then
                xrxe:create-element-functions($node, $node-info, $xsd, $conf)
            else if(qxrxe:is-xs-attribute($node-info)) then
                xrxe:create-attribute-functions($node, $node-info, $xsd, $conf)
            else ()
        )}
    </xf:group>
};

(:### function that create the triggers to actions to the node / its nodeset ###:)
(:### TODO:use $conf/@direct-attribute-editing for attribute trigger again### :)
declare function xrxe:create-element-functions($node, $node-info, $xsd, $conf){
    (
    xrxe:create-insert-after-trigger($node, $node-info, $xsd, $conf)
    ,
    xrxe:create-delete-trigger($node, $node-info, $xsd, $conf)
    (:,
    xrxe:create-insert-before-trigger($node, $node-info, $xsd, $conf)
    ,
    xrxe:create-insert-copy-trigger($node, $node-info, $xsd, $conf):)

    (:xrxe:create-move-first-trigger($node, $node-info, $xsd, $conf) :)
    (:,
    xrxe:create-move-up-trigger($node, $node-info, $xsd, $conf)
    ,
    xrxe:create-move-down-trigger($node, $node-info, $xsd, $conf):)
    (:,
    xrxe:create-move-last-trigger($node, $node-info, $xsd, $conf)
    ,:)

    )
};

(:### adding a trigger to show the dialog containing the current elements attributes ###:)
declare function xrxe:create-attribute-functions($node, $node-info, $xsd, $conf){
   xrxe:create-delete-trigger($node, $node-info, $xsd, $conf)
};

(:### adding a trigger triggering a inserting of a node after the current node ###:)
declare function xrxe:create-insert-after-trigger($node, $node-info, $xsd, $conf){

     let $label := qxrxe:get-label($node-info, $xsd)
     let $max := qxrxe:max-occurs($node-info, $xsd)
     return
        <xf:trigger class="xrxeTrigger xrxeFunctionTrigger xrxeInsertElementAfterTrigger"  title="Insert {data($label)}">
           {
           if($max) then
                attribute ref {
                    concat('.[count(', xrxe:relative-self-path($node, $node-info, $xsd, $conf), ') lt ', $max, ']')
                }
            else
                ()
            }

           <xf:label>{$xrxe-conf:insert-after-trigger-label}</xf:label>
           {xrxe:insert-after-action($node, $node-info, $xsd, $conf)}
        </xf:trigger>
};

(:### action to insert a node after the another node after setting a default value ###:)
declare function xrxe:insert-after-action($node, $node-info, $xsd, $conf){
    <xf:action>
    {
    xrxe:set-default-node-value($node, $node-info, $xsd, $conf)
    ,
    xrxe:insert-after($node, $node-info, $xsd, $conf)
    }
    </xf:action>
};

(:### adding a trigger triggering a inserting of a node before the current node ###:)
declare function xrxe:create-insert-before-trigger($node, $node-info, $xsd, $conf){

     let $label := qxrxe:get-label($node-info, $xsd)
     let $max := qxrxe:max-occurs($node-info, $xsd)
     return
        <xf:trigger class="xrxeTrigger xrxeFunctionTrigger xrxeInsertElementBeforeTrigger"  title="Insert {data($label)}">
           {
           if($max) then
                attribute ref {
                    concat('.[count(', xrxe:relative-self-path($node, $node-info, $xsd, $conf), ') lt ', $max, ']')
                }
            else
                ()
            }

           <xf:label class="xrxeInsertElementTriggerLabel">{$xrxe-conf:insert-before-trigger-label}</xf:label>
           {xrxe:insert-before-action($node, $node-info, $xsd, $conf)}
        </xf:trigger>

};

(:### action to insert a node befor the another node after setting a default value ###:)
declare function xrxe:insert-before-action($node, $node-info, $xsd, $conf){
    <xf:action>
    {
    xrxe:set-default-node-value($node, $node-info, $xsd, $conf)
    ,
    xrxe:insert-before($node, $node-info, $xsd, $conf)
    }
    </xf:action>
};

(:### Not used yet###:)
(:### Only works on loweset level for exaple ead:p works ead:odd just inserts an empty odd ###:)
declare function xrxe:create-insert-copy-trigger($node, $node-info, $xsd, $conf){

     let $label := qxrxe:get-label($node-info, $xsd)
     let $max := qxrxe:max-occurs($node-info, $xsd)
     return
        <xf:trigger class="xrxeTrigger xrxeFunctionTrigger xrxeInsertElementAfterTrigger"  title="Insert {data($label)}">
           {
           if($max) then
                attribute ref {
                    concat('.[count(', xrxe:relative-self-path($node, $node-info, $xsd, $conf), ') lt ', $max, ']')
                }
            else
                ()
           }
           <xf:label class="xrxeLabel xrxeTriggerLabel xrxeFunctionTrigger">{$xrxe-conf:insert-copy-trigger-label}</xf:label>
           {xrxe:insert-copy($node, $node-info, $xsd, $conf)}
        </xf:trigger>
};


(:### Not used yet###:)
declare function xrxe:create-move-first-trigger($node, $node-info, $xsd, $conf){

     let $label := qxrxe:get-label($node-info, $xsd)
     return
        <xf:trigger class="xrxeTrigger xrxeFunctionTrigger xrxeMoveFirstTrigger"  title="Move {data($label)} to first position" >
           <xf:label class="xrxeLabel xrxeTriggerLabel xrxeFunctionTrigger">{$xrxe-conf:move-first-trigger-label}</xf:label>
           {xrxe:move-first($node, $node-info, $xsd, $conf)}
        </xf:trigger>
};


(:### Not used yet###:)
 declare function xrxe:create-move-up-trigger($node, $node-info, $xsd, $conf){

     let $label := qxrxe:get-label($node-info, $xsd)
     return
        <xf:trigger class="xrxeTrigger xrxeFunctionTrigger xrxeMoveUpTrigger"  title="Move {data($label)} up" >
           <xf:label class="xrxeLabel xrxeTriggerLabel xrxeFunctionTrigger">{$xrxe-conf:move-up-trigger-label}</xf:label>
           {xrxe:move-up($node, $node-info, $xsd, $conf)}
        </xf:trigger>
};


(:### Not used yet###:)
 declare function xrxe:create-move-down-trigger($node, $node-info, $xsd, $conf){

     let $label := qxrxe:get-label($node-info, $xsd)
     return
        <xf:trigger class="xrxeTrigger xrxeFunctionTrigger xrxeMoveDownTrigger"  title="Move {data($label)} up" >
           <xf:label class="xrxeLabel xrxeTriggerLabel xrxeFunctionTrigger">{$xrxe-conf:move-down-trigger-label}</xf:label>
           {xrxe:move-down($node, $node-info, $xsd, $conf)}
        </xf:trigger>
};


(:### Not used yet ###:)
declare function xrxe:create-move-last-trigger($node, $node-info, $xsd, $conf){

     let $label := qxrxe:get-label($node-info, $xsd)
     return
        <xf:trigger class="xrxeTrigger xrxeFunctionTrigger xrxeMoveLastTrigger"  title="Move {data($label)} to last position" >
           <xf:label class="xrxeLabel xrxeTriggerLabel xrxeFunctionTrigger">{$xrxe-conf:move-last-trigger-label}</xf:label>
           {xrxe:move-last($node, $node-info, $xsd, $conf)}
        </xf:trigger>
};

(:### adding a trigger triggering a removeing of the node ###:)
declare function xrxe:create-delete-trigger($node, $node-info, $xsd, $conf){
    let $label := qxrxe:get-label($node-info, $xsd)
    let $min := qxrxe:min-occurs($node-info, $xsd)
    return
        (
        <xf:trigger class="xrxeTrigger xrxeFunctionTrigger xrxeDeleteTrigger xrxeNodeTrigger"  title="Delete {data($label)}" >
           {
           if($min) then
                attribute ref {
                concat('.[count(', xrxe:relative-self-path($node, $node-info, $xsd, $conf) , ') gt ', $min, ']')
                }
           else
                ()
           }
           <xf:label>{$xrxe-conf:delete-trigger-label}</xf:label>
           {xrxe:create-delete-trigger-action($node, $node-info, $xsd, $conf)}
        </xf:trigger>
        )
};

(:### action to perform when clicking on [X]-Button###:)
declare function xrxe:create-delete-trigger-action($node, $node-info, $xsd, $conf){
    if($xrxe-conf:default-direct-delete-nodes) then
        xrxe:delete($node, $node-info, $xsd, $conf)
    else
        xrxe:show-dialog(xrxe:delete-dialog-id($node, $conf))
};

(:########################  *** NODESET ACTIONS  ***  ############################:)

(:### action that inserts a node into a nodeset###:)
declare function xrxe:insert($node, $node-info, $xsd, $conf){
    <xf:action>
        <xf:insert nodeset="{xrxe:indexed-nodeset-path($node, $xsd, $conf)}" origin="{concat(xrxe:get-new-instance-string($conf), '/', name($node))}" context="{xrxe:indexed-node-path($node/parent::*, $xsd, $conf)}" />
    </xf:action>
};

(:### action that inserts a node into a nodeset after a node###:)
declare function xrxe:insert-after($node, $node-info, $xsd, $conf){
    <xf:action>
        <xf:insert nodeset="{xrxe:indexed-nodeset-path($node, $xsd, $conf)}" origin="{concat(xrxe:get-new-instance-string($conf), '/', name($node))}" context="{xrxe:indexed-node-path($node/parent::*, $xsd, $conf)}"  position="after" at="index('{xrxe:repeat-id($node, $conf)}')"/>
    </xf:action>
};

(:### action that inserts a node into a nodeset befor a node###:)
declare function xrxe:insert-before($node, $node-info, $xsd, $conf){
    <xf:action>
        <xf:insert nodeset="{xrxe:indexed-nodeset-path($node, $xsd, $conf)}" origin="{concat(xrxe:get-new-instance-string($conf), '/', name($node))}" context="{xrxe:indexed-node-path($node/parent::*, $xsd, $conf)}"  position="before" at="index('{xrxe:repeat-id($node, $conf)}')"/>
    </xf:action>
};


declare function xrxe:move-first($node, $node-info, $xsd, $conf){
    <xf:action while="index('{xrxe:repeat-id($node, $conf)}') > 1">
        <xf:insert context="{xrxe:indexed-node-path($node/parent::*, $xsd, $conf)}" origin="{xrxe:indexed-node-path($node, $xsd, $conf)}" nodeset="{xrxe:indexed-nodeset-path($node, $xsd, $conf)}" position="before" at="index('{xrxe:repeat-id($node, $conf)}') - 1" />
        <xf:delete nodeset="{xrxe:indexed-nodeset-path($node, $xsd, $conf)}" at="index('{xrxe:repeat-id($node, $conf)}') + 2" />
    </xf:action>
};

declare function xrxe:move-up($node, $node-info, $xsd, $conf){
    <xf:action if="index('{xrxe:repeat-id($node, $conf)}') > 1">
        <xf:insert context="{xrxe:indexed-node-path($node/parent::*, $xsd, $conf)}" origin="{xrxe:indexed-node-path($node, $xsd, $conf)}" nodeset="{xrxe:indexed-nodeset-path($node, $xsd, $conf)}" position="before" at="index('{xrxe:repeat-id($node, $conf)}') - 1" />
        <xf:delete nodeset="{xrxe:indexed-nodeset-path($node, $xsd, $conf)}" at="index('{xrxe:repeat-id($node, $conf)}') + 2" />
    </xf:action>
};

declare function xrxe:move-down($node, $node-info, $xsd, $conf){
    <xf:action if="index('{xrxe:repeat-id($node, $conf)}') lt count({xrxe:indexed-nodeset-path($node, $xsd, $conf)})">
        <xf:insert context="{xrxe:indexed-node-path($node/parent::*, $xsd, $conf)}" origin="{xrxe:indexed-node-path($node, $xsd, $conf)}" nodeset="{xrxe:indexed-nodeset-path($node, $xsd, $conf)}" position="after" at="index('{xrxe:repeat-id($node, $conf)}') + 1" />
        <xf:delete nodeset="{xrxe:indexed-nodeset-path($node, $xsd, $conf)}" at="index('{xrxe:repeat-id($node, $conf)}') - 2" />
    </xf:action>
};

declare function xrxe:move-last($node, $node-info, $xsd, $conf){
    <xf:action while="index('{xrxe:repeat-id($node, $conf)}') lt count({xrxe:indexed-nodeset-path($node, $xsd, $conf)})">
        <xf:insert context="{xrxe:indexed-node-path($node/parent::*, $xsd, $conf)}" origin="{xrxe:indexed-node-path($node, $xsd, $conf)}" nodeset="{xrxe:indexed-nodeset-path($node, $xsd, $conf)}" position="after" at="index('{xrxe:repeat-id($node, $conf)}') + 1" />
        <xf:delete nodeset="{xrxe:indexed-nodeset-path($node, $xsd, $conf)}" at="index('{xrxe:repeat-id($node, $conf)}') - 2" />
    </xf:action>
};

(:### action that inserts a copy of a node###:)
declare function xrxe:insert-copy($node, $node-info, $xsd, $conf){
    <xf:action>
        <xf:insert context="{xrxe:indexed-node-path($node/parent::*, $xsd, $conf)}" origin="{xrxe:indexed-node-path($node, $xsd, $conf)}" nodeset="{xrxe:indexed-nodeset-path($node, $xsd, $conf)}" position="after" at="index('{xrxe:repeat-id($node, $conf)}')"/>
    </xf:action>
};

(:### action that deletes a node from a nodeset###:)
declare function xrxe:delete($node, $node-info, $xsd, $conf){
    <xf:action>
        <!--xf:message>Index <xf:output value="index('{xrxe:repeat-id($node, $conf)}')"/></xf:message>
        <xf:message>Nodeset Count <xf:output value="count({xrxe:indexed-nodeset-path($node, $xsd, $conf)})"/></xf:message-->
        <!--xf:delete ref="{xrxe:indexed-node-path($node, $xsd, $conf)}" at="index('{xrxe:repeat-id($node, $conf)}')"/-->

        <!--xf:setvalue ref="{xrxe:indexed-node-path($node, $xsd, $conf)}" value="Deleted" /-->
        <xf:delete nodeset="{xrxe:indexed-nodeset-path($node, $xsd, $conf)}" at="index('{xrxe:repeat-id($node, $conf)}')" />


    </xf:action>
};

(:zzz:)

(:######################## *** ATTRIBUTES  *** ############################:)

(:DESTROY:)
declare function xrxe:create-attributes($node, $node-info, $xsd, $conf) {
    if($xrxe-conf:default-direct-attribute-editing) then
        xrxe:create-attributes-controls($node, $node-info, $xsd, $conf)
    else
        xrxe:create-attributes-trigger($node, $xsd, $conf)
};

declare function xrxe:create-attributes-controls($node, $node-info, $xsd, $conf){
   <xf:group class="xrxeAttributes">
    {
        for $attribute in xrxe:get-relevant-attribute-children($node, $node-info, $xsd, $conf)
        let $attribute-info := qxrxe:get-node-info(xrxe:node-info-path($attribute, $node-info, $conf), $node-info , $xsd)
        return
            xrxe:create-nodeset-controls($attribute, $attribute-info, $xsd, $conf)
    }
    </xf:group>
};

(:Use this Function when removing the template and query the xsd:)
declare function xrxe:get-relevant-attribute-children($node, $node-info, $xsd, $conf){
    $node/attribute::*
};

(:### creates an attribute trigger for one element-node ###:)
declare function xrxe:create-attributes-trigger($node, $xsd, $conf){
        if(count($node/attribute::*)>0) then
            <xf:trigger class="xrxeAttributeTrigger">
                   <xf:label class="xrxeAttributeTriggerLabel">
                       { $xrxe-conf:attribute-trigger-label }
                   </xf:label>
                   {xrxe:show-dialog(xrxe:attributes-dialog-id($node, $conf))}
            </xf:trigger>
         else ()
};

(:######################## *** DIALOGS  *** ############################:)

declare function xrxe:create-notesets-dialogs($node, $node-info, $xsd, $conf){

    let $dialogs := xrxe:create-nodeset-dialogs($node, $node-info, $xsd, $conf)
    let $child-nodes-dialogs :=
        for $child-node in ($node/element() | $node/attribute())
            let $child-node-info := qxrxe:get-node-info(xrxe:node-info-path($child-node, $node-info, $conf), $node-info , $xsd)
            return
            xrxe:create-notesets-dialogs($child-node,  $child-node-info, $xsd, $conf)
    return ($dialogs, $child-nodes-dialogs)

};

declare function xrxe:create-nodeset-dialogs($node, $node-info, $xsd, $conf){
    (
        if($xrxe-conf:default-direct-attribute-editing) then
            ()
        else
            xrxe:create-attributes-dialog($node, $node-info, $xsd, $conf)
        ,
        xrxe:create-delete-dialog($node, $node-info, $xsd, $conf)
    )
};

(:######################## *** DELETE DIALOGS  *** ############################:)

declare function xrxe:create-delete-dialog($node, $node-info, $xsd, $conf){
    let $label := qxrxe:get-label($node-info, $xsd)
    return
    <bfc:dialog id="{xrxe:delete-dialog-id($node, $conf)}" class="xrxeDialog xrxeDeleteDialog">
        <xf:label class="xrxeLabel xrxeDialogLabel xrxeDeleteDialogLabel">{$xrxe-conf:delete, ' ', $label}</xf:label>
        {
        (
        <xf:group ref="{xrxe:indexed-node-path($node, $xsd, $conf)}" class="xrxeGroup xrxeDialogGroup xrxeDeleteDialogGroup">
            {xrxe:create-delete-dialog-content($node, $node-info, $xsd, $conf)}
        </xf:group>
        )
        }
    </bfc:dialog>
};

declare function xrxe:create-delete-dialog-content($node, $node-info, $xsd, $conf){
    let $label := qxrxe:get-label($node-info, $xsd)
    return
    (
    <xf:output ref="." class="xrxeOutput xrxeDialogOutput xrxeDeleteDialogOutput">
        <xf:label class="xrxeLabel xrxeOutputLabel xrxeDeleteDialogOutputLabel">{$xrxe-conf:doublecheck-delete, $label}</xf:label>
    </xf:output>
    ,
    <xf:trigger style="float:left;margin-right:4px;" class="xrxeTrigger xrxeDeleteTrigger">
        <xf:label class="xrxeLabel xrxeTriggerLabel xrxeDeleteTriggerLabel">{$xrxe-conf:delete}</xf:label>
        {
        xrxe:hide-dialog(xrxe:delete-dialog-id($node, $conf))
        ,
        xrxe:delete($node, $node-info, $xsd, $conf)
        }
    </xf:trigger>
    ,
    <xf:trigger class="xrxeDeleteDialogCancalTrigger">
        <xf:label class="xrxeLabel xrxeTriggerLabel xrxeHideDialogTriggerLabel">{$xrxe-conf:cancal}</xf:label>
       {xrxe:hide-dialog(xrxe:delete-dialog-id($node, $conf))}
    </xf:trigger>
    )
};

(:######################## *** ATTRIBUTES DIALOGS  *** ############################:)

declare function xrxe:create-attributes-dialog($node, $node-info, $xsd, $conf){
     if(count($node/attribute::*)>0) then
        let $label := qxrxe:get-label($node-info, $xsd)
        return
        <bfc:dialog id="{xrxe:attributes-dialog-id($node, $conf)}"  class="xrxeDialog xrxeAttributeDialog">
            <xf:label class="xrxeLabel xrxeDialogLabel xrxeAttributesDialogLabel">
                {($label, ' ',  $xrxe-conf:attributes)}
            </xf:label>
            <xf:group ref="{xrxe:indexed-node-path($node, $xsd, $conf)}" class="xrxeGroup xrxeAttributeGroup xrxeAttributeDialogGroup">
                {xrxe:create-attributes-dialog-content($node, $node-info, $xsd, $conf)}
            </xf:group>
        </bfc:dialog>
     else ()
};

declare function xrxe:create-attributes-dialog-content($node, $node-info, $xsd, $conf){
    (
    xrxe:create-attributes-controls($node, $node-info, $xsd, $conf)
    ,
    xrxe:create-attributes-close-trigger($node, $xsd, $conf)
    )
};

declare function xrxe:create-attributes-close-trigger($node, $xsd, $conf){
    <xf:trigger class="xrxeTrigger xrxeHideTrigger">
            <xf:label class="xrxeDeleteDialogCancalTriggerLabel">{$xrxe-conf:ok}</xf:label>
           {xrxe:hide-dialog(xrxe:attributes-dialog-id($node, $conf))}
     </xf:trigger>
};

(: ######################################## END NODE VIEW ################################################ :)

(: ##################################################### END NODE EDITOR ##################################################################### :)

(:######################## *** IDS *** ############################:)

(:######################## *** DOCUMENT IDS *** ############################:)

declare function xrxe:document-instance-string($conf){
    xrxe:create-instance-sting(xrxe:document-instance-id($conf))
};

declare function xrxe:document-model-id($conf){
    concat($xrxe-conf:pre-string-model, xrxe:document-id($conf))
};

declare function xrxe:save-document-submission-id($conf){
    concat(xrxe:document-submission-id($conf), $xrxe-conf:post-string-save)
};

declare function xrxe:exist-validate-save-document-submission-id($conf){
    concat(xrxe:document-submission-id($conf), 'exist-validation-save')
};

declare function xrxe:exist-validate-document-submission-id($conf){
    concat(xrxe:document-submission-id($conf), 'exist-validation')
};

declare function xrxe:unescape-document-submission-id($conf){
    concat(xrxe:document-submission-id($conf), $xrxe-conf:post-string-unescape)
};

declare function xrxe:document-submission-id($conf){
    concat($xrxe-conf:pre-string-submission, xrxe:document-id($conf))
};

declare function xrxe:document-instance-id($conf){
    concat($xrxe-conf:pre-string-instance, xrxe:document-id($conf))
};

declare function xrxe:document-id($conf){
    xrxe:clean-id(concat(name($conf/xrxe:doc/node()), $xrxe-conf:post-string-document))
};

(:######################## *** UI IDS *** ############################:)

(:DEPRECATED LOAD IS IN DOCUMENT MODEL:)
declare function xrxe:load-model-id($conf){
    concat($xrxe-conf:pre-string-model, xrxe:load-id($conf))
};

declare function xrxe:load-id($conf){
    xrxe:clean-id(concat(name($conf/xrxe:doc/node()), $xrxe-conf:post-string-load))
};

declare function xrxe:load-instance-id($conf){
    concat($xrxe-conf:pre-string-instance, xrxe:load-id($conf))
};

declare function xrxe:load-instance-string($conf){
    xrxe:create-instance-sting(xrxe:load-instance-id($conf))
};


(:######################## *** MODEL IDS *** ############################:)

(:Create a model id for the models node:)
declare function xrxe:model-id($node, $conf){
    xrxe:clean-id(concat($xrxe-conf:pre-string-model, xrxe:xsd-path($node, $conf)))
};

(:Get the id of the model from everywhere:)
declare function xrxe:get-model-id($conf){
    xrxe:clean-id(concat($xrxe-conf:pre-string-model, xrxe:root-xsd-path($conf)))
};

(:######################## *** INSTANCE IDS *** ############################:)

declare function xrxe:data-instance-id($node, $conf){
    concat(xrxe:instance-id($node, $conf), $xrxe-conf:post-string-data)
};

declare function xrxe:insert-instance-id($node, $conf){
    concat(xrxe:instance-id($node, $conf), $xrxe-conf:post-string-insert)
};

declare function xrxe:delete-instance-id($node, $conf){
    concat(xrxe:instance-id($node, $conf), $xrxe-conf:post-string-delete)
};

declare function xrxe:new-instance-id($node, $conf){
    concat(xrxe:instance-id($node, $conf), $xrxe-conf:post-string-new)
};

declare function xrxe:instance-id($node, $conf){
    xrxe:clean-id(concat($xrxe-conf:pre-string-instance, xrxe:xsd-path($node, $conf)))
};

(:model-ids and instance ids may not contain '/':)
declare function xrxe:clean-id($path){
    replace($path, '/', '_')
};

declare function xrxe:get-data-instance-id($conf){
    xrxe:clean-id(concat($xrxe-conf:pre-string-instance, xrxe:root-xsd-path($conf), $xrxe-conf:post-string-data))
};

declare function xrxe:get-insert-instance-id($conf){
    xrxe:clean-id(concat($xrxe-conf:pre-string-instance, xrxe:root-xsd-path($conf), $xrxe-conf:post-string-insert))
};

declare function xrxe:get-delete-instance-id($conf){
    xrxe:clean-id(concat($xrxe-conf:pre-string-instance, xrxe:root-xsd-path($conf), $xrxe-conf:post-string-delete))
};

declare function xrxe:get-new-instance-id($conf){
    xrxe:clean-id(concat($xrxe-conf:pre-string-instance, xrxe:root-xsd-path($conf), $xrxe-conf:post-string-new))
};

declare function xrxe:get-data-instance-string($conf){
    xrxe:create-instance-sting(xrxe:get-data-instance-id($conf))
};

declare function xrxe:get-insert-instance-string($conf){
    xrxe:create-instance-sting(xrxe:get-insert-instance-id($conf))
};

declare function xrxe:get-delete-instance-string($conf){
    xrxe:create-instance-sting(xrxe:get-delete-instance-id($conf))
};

declare function xrxe:get-new-instance-string($conf){
    xrxe:create-instance-sting(xrxe:get-new-instance-id($conf))
};

declare function xrxe:create-instance-sting($id){
    concat("instance('", $id, "')")
};

(:######################## *** BIND IDS *** ############################:)

declare function xrxe:data-bind-id($node, $conf){
    concat(xrxe:bind-id($node, $conf), $xrxe-conf:post-string-data)
};

declare function xrxe:insert-bind-id($node, $conf){
    concat(xrxe:bind-id($node, $conf), $xrxe-conf:post-string-insert)
};

declare function xrxe:delete-bind-id($node, $conf){
    concat(xrxe:bind-id($node, $conf), $xrxe-conf:post-string-delete)
};

declare function xrxe:bind-id($node, $conf){
    concat($xrxe-conf:pre-string-bind, xrxe:xsd-path($node, $conf))
};


(:######################## *** SUBMISSION IDS *** ############################:)

declare function xrxe:get-validate-submission-id($conf){
    xrxe:clean-id(concat($xrxe-conf:pre-string-submission, xrxe:root-xsd-path($conf), $xrxe-conf:post-string-validate))
};

declare function xrxe:get-post-submission-id($conf){
    xrxe:clean-id(concat($xrxe-conf:pre-string-submission, xrxe:root-xsd-path($conf), $xrxe-conf:post-string-post))
};

(:######################## *** CHILDREN CONTAINER IDS *** ############################:)

declare function xrxe:get-switch-children-id($node, $conf){
    concat($xrxe-conf:pre-string-switch, xrxe:xsd-path($node, $conf), $xrxe-conf:post-string-child-elements)
};

declare function xrxe:get-group-children-id($node, $conf){
    concat($xrxe-conf:pre-string-group, xrxe:xsd-path($node, $conf), $xrxe-conf:post-string-child-elements)
};

(:######################## *** CASE IDS *** ############################:)

declare function xrxe:get-case-id($node, $conf){
    concat(xrxe:xsd-path($node, $conf), $xrxe-conf:post-string-case)
};

declare function xrxe:get-trigger-case-id($node, $conf){
    concat($xrxe-conf:pre-string-trigger, xrxe:xsd-path($node, $conf), $xrxe-conf:post-string-case)
};

(:######################## *** REPEAT IDS *** ############################:)

declare function xrxe:repeat-id($node, $conf){
    concat($xrxe-conf:pre-string-repeat, xrxe:xsd-path($node, $conf))
};

(:######################## *** DIALOG IDS *** ############################:)

declare function xrxe:delete-dialog-id($node, $conf){
    concat(xrxe:dialog-id($node, $conf), $xrxe-conf:post-string-delete)
};

declare function xrxe:attributes-dialog-id($node, $conf){
    concat(xrxe:dialog-id($node, $conf), $xrxe-conf:post-string-attributes)
};

declare function xrxe:dialog-id($node, $conf){
    concat($xrxe-conf:pre-string-dialog, xrxe:xsd-path($node, $conf))
};

(:######################## *** NEW PATHES *** ############################:)

(:/atom:entry/atom:content/ead:ead/ead:archdesc/ead:dsc/ead:c:)
(:/atom:entry/atom:content/cei:text:)
declare function xrxe:absolute-path($conf){
    if($conf/@node-path) then
        concat($conf/@wrapper, $conf/@node-path)
    else
        concat($conf/@wrapper, '/', name($conf/xrxe:doc/element()[1]))
};

(:/ead:ead/ead:archdesc/ead:dsc:)
(:'':)
declare function xrxe:xsd-context-path($conf){
    let $context-path := functx:substring-before-last(xrxe:absolute-path($conf), '/')
        return
        if($conf/@wrapper) then
            let $context-path := fn:substring-after($context-path, $conf/@wrapper)
            return
                if($context-path) then
                    $context-path
                else
                    ''
        else
            $context-path
};

(:/ead:ead/ead:archdesc/ead:dsc/ead:c:)
(:/cei:text:)
declare function xrxe:root-xsd-path($conf){
    concat(xrxe:xsd-context-path($conf), xrxe:root-path($conf))
};

(:/ead:c:)
(:/cei:text:)
declare function xrxe:root-path($conf){
    concat('/', xrxe:editor-node-name($conf))
};

(:ead:c:)
(:cei:text:)
declare function xrxe:editor-node-name($conf){
    functx:substring-after-last(xrxe:absolute-path($conf), '/')
};

declare function xrxe:xsd-path($path, $conf){
    concat(xrxe:xsd-context-path($conf) , $path)
};


declare function xrxe:xsd-path($node, $conf){
    concat(xrxe:xsd-context-path($conf) , xrxe:data-path($node))
};

(:######################## *** NEW PATHES *** ############################:)

(:######################## *** PATHES *** ############################:)

declare function xrxe:data-path($node)  as xs:string* {
    concat('/',
            string-join(
            for $ancestor-or-self in xrxe:ancestor-or-self($node)
            return
                xrxe:path($ancestor-or-self)
            , '/'
            )
        )
 } ;

(:*** returns the path for qxsd of the node TODO include path of supernodes for subeditors so subeditors need not all params:)
(:DEPRECATED:)
(:declare function xrxe:xsd-path($node, $conf){
    concat(xs:string($conf/@xsd-context-path), xrxe:data-path($node))
};:)

(:(:DEPRECATED:):)
(:declare function xrxe:root-xsd-path($conf){
    concat(xs:string($conf/@xsd-context-path), '/', name($conf/xrxe:template/element()))
};:)



 declare function xrxe:ancestor-or-self($node){
(:xpath's ancestor-or-self::*  doens't work with the root element and with attributes:)
let $parent := $node/parent::*
let $ancestor-of-parent:= $parent/ancestor::*
return($ancestor-of-parent, $parent, $node)
};

 declare function xrxe:path($node){
    if($node instance of attribute()) then
        concat('@', name($node))
    else if($node instance of element()) then
        name($node)
    else if($node instance of text()) then
        'text()'
    else
        ()
 };

declare function xrxe:relative-child-path($node, $node-info, $xsd, $conf){
    (:Use function when exists for instance of element(xs:attribute) :)
    if($node-info instance of element(xs:attribute)) then
            concat("./@", name($node))
    else
            concat("./", name($node))
};

declare function xrxe:relative-self-path($node, $node-info, $xsd, $conf){
    (:Use function when exists for instance of element(xs:attribute) :)
    if($node-info instance of element(xs:attribute)) then
            concat("../@", name($node))
    else
            concat("../", name($node))
};

declare function xrxe:node-info-path($node, $parent-info, $conf){
    if($parent-info) then
        xrxe:path($node)
    else
        xrxe:xsd-path($node, $conf)
 };

(:
declare function xrxe:path-to-node($node as node()* )  as xs:string* {
let $parent := $node/parent::*
let $ancestor-of-parent:= $parent/ancestor::*
let $ancestor-or-self := ($ancestor-of-parent, $parent, $node)
let $path :=
    string-join(
      for $ancestor in $ancestor-or-self(: $node/ancestor-or-self::* :)
        return
            if($ancestor instance of attribute()) then
                concat('@', name($ancestor))
            else if($ancestor instance of document-node()) then
                ()
            else
                let $name := name($ancestor)
                return
                if ($name='doc') then ()
                else $name
      , '/'
      )
return $path
 } ;
:)



(:######################## *** FUNCTX *** ############################:)

declare function functx:leaf-elements ( $root as node()? )  as element()* {
   $root/descendant-or-self::*[not(*)]
 } ;

declare function functx:substring-after-last
  ( $arg as xs:string? ,
    $delim as xs:string )  as xs:string {

   replace ($arg,concat('^.*',functx:escape-for-regex($delim)),'')
 } ;

 declare function functx:escape-for-regex
  ( $arg as xs:string? )  as xs:string {

   replace($arg,
           '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')
 } ;

 declare function functx:substring-before-last
  ( $arg as xs:string? ,
    $delim as xs:string )  as xs:string {

   if (matches($arg, functx:escape-for-regex($delim)))
   then replace($arg,
            concat('^(.*)', functx:escape-for-regex($delim),'.*'),
            '$1')
   else ''
 } ;

 (:######################## *** XRXE UTIL *** ############################:)

(:###  Tests if a node is the root-element. Attention fn:root() gives back the document-node ###:)
declare function xrxe:root($node){
    if (count($node/parent::*)>0) then
        fn:false()
    else
        fn:true()
};

 (:######################## *** XQUERY UTIL *** ############################:)

(:only create an attribute if a value exists:)
declare function xrxe:create-attribute($name, $value){
    if ($value) then
        attribute {$name} {$value}
    else ()
};

 (:########################  *** XRXE-SERVICES  ***  ############################:)

 (:### used by xrxe-services.xql to unescape all escaped charaters from the document and sanitize it ###:)
 declare function xrxe:get-unescape-mixed-content($data){
			let $serialize:= serialize($data, ())
	    	let $replace := replace(replace($serialize, '&amp;lt;', '&lt;'), '&amp;gt;', '&gt;')
	    	let $replace := replace($replace, 'xmlns:NS1=""', '')
	    	let $replace := replace($replace, 'NS1:', '')
	    	let $parse:= util:parse($replace)
	    	(:data is just a dummy element:)
	    	let $data := <data>{$parse}</data>
	    	return $data/element()
		};



(:########################  *** INDEXED PATHES  ***  ############################:)

declare function xrxe:indexed-node-path($node, $xsd, $conf)
{
    xrxe:indexed-path($node, $xsd, $conf, 'node')
};


declare function xrxe:indexed-nodeset-path($node, $xsd, $conf)
{
   xrxe:indexed-path($node, $xsd, $conf, 'nodeset')
};

declare function xrxe:indexed-path($node, $xsd, $conf, $switch)
{
    let $tokenize := subsequence(tokenize(xrxe:data-path($node), '/'), 2)
    let $paths := xrxe:rebuild-individual-pathes($tokenize)

    let $repeat-indexed-path := string-join(
        for $token at $pos in $tokenize
            return
            (:if the data-root is NOT in xf:repeat:)
            if($pos=1)then
                 concat($token, '[1]')
            else if(($pos = count($tokenize) and $switch='nodeset') or contains($tokenize, '@'))then
                 $token
            else
                concat($token, "[index('", $xrxe-conf:pre-string-repeat, xrxe:xsd-context-path($conf), '/',  $paths[$pos],"')]")

      , '/')

    let $repeat-indexed-instance-path := concat(xrxe:get-data-instance-string($conf), '/',  $repeat-indexed-path)
    return $repeat-indexed-instance-path
};

declare function xrxe:rebuild-individual-pathes($tokenize){
    let $individual-paths :=
        for $token at $pos in $tokenize

        let $path-parts :=
            for $i in 1 to $pos
                return $tokenize[$i]

        let $paths :=
            if(count($path-parts)=1)then
                ($path-parts)
            else
                string-join($path-parts, '/')
        return $paths
    return $individual-paths

};

(:######################## *** XFORMS MODEL UTIL *** ############################:)

declare function xrxe:create-submission-chain($event, $id){
    <xf:action ev:event="{$event}">
       <xf:send submission="{$id}" />
   </xf:action>
};


declare function xrxe:create-submission-message($event, $message){
    <xf:action ev:event="{$event}">
        <xf:message>{$message}</xf:message>
   </xf:action>
};

declare function xrxe:skipshutdown($skipshutdown){
    <script type="text/javascript">
      fluxProcessor.skipshutdown={$skipshutdown};
    </script>

};

(:### action to hide a dialog###:)
declare function xrxe:hide-dialog($id){
    <bfc:hide dialog="{$id}" ev:event="DOMActivate"></bfc:hide>
};

(:### action to show a dialog###:)
declare function xrxe:show-dialog($id){
    <bfc:show dialog="{$id}" ev:event="DOMActivate"></bfc:show>
};

(:TODO


 - change Templated UI to XFomrs Code without using own Framework
 - enrich the choose content-control for annotation and empty
 - insert xrxeAttribute and xrxeElement as class paralel to xrxeNode to differ styling (width)
 - include schema to model
 - bind type to native xs-types and all simple types
 - enable non embedded subeditors
 - create new-instances dynamically using qxsd or qxrxe
 - add validation with eXist?
 - handle xs:simpleContent xs:complexContent xs:restrictions xs:extentions
 - choice editor
 - sequence editor
 - all editor
 - handle sequence choice all (min and max adding and removing choice-> select)
 - make mix elements order possibel (head p head p)
 - add path to node-info
 - add namespace to node-info
 - improve relevant restrictions for xrxe:annotations
 - don't use the template
 - create node-editor service for subeditors
 - node editor only with doc-id
 - embed whole editor and load by script (the param has to be posted to the load-script ig foc is xml db/load.xql)
 - xs:any
 - xs:include



:)
