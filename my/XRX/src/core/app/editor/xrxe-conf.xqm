xquery version "3.0";

module namespace xrxe-conf='http://www.monasterium.net/NS/xrxe-conf';

(:configured modules used in functions of this xrxe-conf module:)
import module namespace i18n="http://www.monasterium.net/NS/i18n" at "../i18n/i18n.xqm";
import module namespace upd="http://www.monasterium.net/NS/upd"  at "../xrx/upd.xqm";

(:get files that are used in this module:)
declare variable $xrxe-conf:text := doc('/db/XRX.src/core/app/editor/xrxe-ui-texts.xml')[1];


(:### can be overwritten in xrxe:set-conf ###:)

(:Ajust this URL when not having installed eXist or XRXEditor with standard configuration:)
(:declare variable $xrxe-conf:default-services := concat('http://localhost:',conf:param('jetty-port'), "/rest/db/apps/xrxeditor/xrxe-services.xql");:)
declare variable $xrxe-conf:default-services := concat('http://localhost:8181/rest/db/apps/xrxeditor/xrxe-services.xql');
(:Send the save-submission with the 'post'- or the 'put'- method:)
declare variable $xrxe-conf:default-save-method := 'post';

(:Place the Save trigger on top, on tbottom or both of the editor ('top', 'bottom', 'top-and-bottom'):)
declare variable $xrxe-conf:default-place-triggers := 'top-and-bottom';

(:XPath that describes the Wrapper Element within a valid document can be found:)
declare variable $xrxe-conf:default-wrapper := '/atom:entry/atom:content';

(:true() or false() If false, only elements annotated as relevant in the XSD are used, if true all elements are used only not if annotated as not relevant in the XSD:)
declare variable $xrxe-conf:default-element-relevant := true();

(:true() or false() If false, only attributes annotated as relevant in the XSD are used, if true all attributes are used only not if annotated as not relevant in the XSD:)
declare variable $xrxe-conf:default-attribute-relevant := false();

(:true() or false() If false, only attribute-groups annotated as relevant in the XSD are used, if true all attribute-groupss are used only not if annotated as not relevant in the XSD:)
declare variable $xrxe-conf:default-attribute-group-relevant := true();

(:true() or false() If false, only groups annotated as relevant in the XSD are used, if true all groupss are used only not if annotated as not relevant in the XSD:)
declare variable $xrxe-conf:default-group-relevant := true();

(:xs:int numbers of rows for a annotationControl if not overwritten in XSD for specific nodes:)

declare variable $xrxe-conf:default-max-depth := 10;

declare variable $xrxe-conf:default-content-control := 'input';

declare variable $xrxe-conf:default-rows := 1;

declare variable $xrxe-conf:default-menu-item :=
    <menu-item>
        {$xrxe-conf:text//text[@id="select-annotation"][1]}
    </menu-item>;


(:### Only change this when betterFORM-Bugs are solved ###:)

(:tabContainer currently causes rendering issue ; use only if betterFORM has solved bug:)
declare variable $xrxe-conf:switch-type := 'plain'; (:default:plain , tabContainer :)

(: fn:true doesn't create any dialogs for attribute-editing :)
declare variable $xrxe-conf:default-direct-attribute-editing := fn:true();



(:### Only exist for debugging reason ###:)

(: fn:true directly deletes the elements without a dialog:)
declare variable $xrxe-conf:default-direct-delete-nodes := fn:false();

declare variable $xrxe-conf:default-min-occur := 1;

declare variable $xrxe-conf:default-max-occur := 1;

declare variable $xrxe-conf:default-attribute-min-occur := 0;

(:...:)

declare variable $xrxe-conf:unbounded := 999;



(:#### MOM/VDU specific ####:)

declare variable $xrxe-conf:default-search-id-in := '/db';















declare variable $xrxe-conf:insert-trigger-label := $xrxe-conf:text//text[@name="insert-trigger-label"][1];
declare variable $xrxe-conf:delete-trigger-label := $xrxe-conf:text//text[@name="delete-trigger-label"][1];
declare variable $xrxe-conf:insert-after-trigger-label := $xrxe-conf:text//text[@name="insert-after-trigger-label"][1];
declare variable $xrxe-conf:insert-before-trigger-label := $xrxe-conf:text//text[@name="insert-before-trigger-label"][1];
declare variable $xrxe-conf:insert-copy-trigger-label := $xrxe-conf:text//text[@name="insert-copy-trigger-label"][1];
declare variable $xrxe-conf:move-first-trigger-label := $xrxe-conf:text//text[@name="move-first-trigger-label"][1];
declare variable $xrxe-conf:move-up-trigger-label := $xrxe-conf:text/text[@name="move-up-trigger-label"][1];
declare variable $xrxe-conf:move-down-trigger-label := $xrxe-conf:text//text[@name=":move-down-trigger-label"][1];
declare variable $xrxe-conf:move-last-trigger-label := $xrxe-conf:text/text[@name="move-last-trigger-label"][1];
declare variable $xrxe-conf:attribute-trigger-label := $xrxe-conf:text//text[@name="attribute-trigger-label"][1];
declare variable $xrxe-conf:doublecheck-delete := $xrxe-conf:text//text[@name="doublecheck-delete"][1];
declare variable $xrxe-conf:cancal := $xrxe-conf:text//text[@name="cancal"][1];
declare variable $xrxe-conf:ok := $xrxe-conf:text//text[@name="ok"][1];
declare variable $xrxe-conf:delete := $xrxe-conf:text//text[@name="delete"][1];
declare variable $xrxe-conf:attributes := $xrxe-conf:text//text[@name="attributes"][1];
declare variable $xrxe-conf:save := $xrxe-conf:text//text[@name="save"][1];
declare variable $xrxe-conf:save-and-close := $xrxe-conf:text//text[@name="save-and-close"][1];
declare variable $xrxe-conf:document-saved := $xrxe-conf:text//text[@name="document-saved"][1];
declare variable $xrxe-conf:save-error:= $xrxe-conf:text//text[@name="save-error"][1];
declare variable $xrxe-conf:loading :=  $xrxe-conf:text//text[@name="loading"][1];
declare variable $xrxe-conf:unescape-submit-error := $xrxe-conf:text//text[@name="unescape-submit-error"][1];
declare variable $xrxe-conf:post-error := $xrxe-conf:text//text[@name="post-error"][1];
declare variable $xrxe-conf:not-valid := $xrxe-conf:text//text[@name="not-valid"][1];
declare variable $xrxe-conf:xsd-not-found := 'XSD not found';

(:xforms id strings:)

declare variable $xrxe-conf:pre-string-model := 'm-';
declare variable $xrxe-conf:pre-string-instance := 'i-';
declare variable $xrxe-conf:pre-string-bind := 'b-';
declare variable $xrxe-conf:pre-string-trigger := 't-';
declare variable $xrxe-conf:pre-string-dialog := 'd-';
declare variable $xrxe-conf:pre-string-submission := 's-';
declare variable $xrxe-conf:pre-string-repeat := 'r-';
declare variable $xrxe-conf:pre-string-group := 'p-';
declare variable $xrxe-conf:pre-string-switch := 'sw-';

declare variable $xrxe-conf:post-string-document := '-document';
declare variable $xrxe-conf:post-string-load := '-load';
declare variable $xrxe-conf:post-string-unescape := '-unescape';
declare variable $xrxe-conf:post-string-save := '-save';
declare variable $xrxe-conf:post-string-data := '-data';
declare variable $xrxe-conf:post-string-insert := '-insert';
declare variable $xrxe-conf:post-string-delete := '-delete';
declare variable $xrxe-conf:post-string-new := '-new';
declare variable $xrxe-conf:post-string-validate := '-validate';
declare variable $xrxe-conf:post-string-post := '-post';
declare variable $xrxe-conf:post-string-case := '-case';
declare variable $xrxe-conf:post-string-attributes := '-attributes';
declare variable $xrxe-conf:post-string-child-elements := '-child-elements';

declare function  xrxe-conf:translate($node){
    if($node instance of node()) then
        i18n:translate-xml($node)
    else
        $node
};

declare function xrxe-conf:insert-into-as-first($node-info, $annotations){
    upd:insert-into-as-first($node-info, $annotations)
};

declare function xrxe-conf:insert-attributes($node-info, $attributes){
    upd:insert-attributes($node-info, $attributes)
};

declare function xrxe-conf:insert-into-as-last($node-info, $type){
    upd:insert-into-as-last($node-info, $type)
};
