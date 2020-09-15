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

module namespace chimport="http://www.monasterium.net/NS/chimport";

import module namespace charters="http://www.monasterium.net/NS/charters"
    at "../charters/charters.xqm";
import module namespace metadata="http://www.monasterium.net/NS/metadata"
    at "../metadata/metadata.xqm";
import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../xrx/conf.xqm";

declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace ev="http://www.w3.org/2001/xml-events";
declare namespace xrx="http://www.monasterium.net/NS/xrx";
declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace bfc="http://betterform.sourceforge.net/xforms/controls";
declare namespace sql="http://exist-db.org/xquery/sql";

declare variable $chimport:EXCEL := 'Excel';
declare variable $chimport:CEI := 'CEI';
declare variable $chimport:EAD := 'EAD';
declare variable $chimport:XML := 'XML';
declare variable $chimport:SQL := 'SQL';
declare variable $chimport:XQuery := 'XQuery';

(:~
  recently imported file
:)
declare function chimport:rinfo() as element()* {

    metadata:base-collection('charter', charters:ruri-tokens(), 'import')/xrx:import
};

declare function chimport:recent-filename($import-info as element(xrx:import)) {

    let $type := $import-info/xrx:type/text()
    let $filename := 
        if(charters:rcontext() = 'fond') then charters:rfondid() else charters:rcollectionid()
    let $suffix := 
        if($type = $chimport:EXCEL) then 'xls' else 'xml'
    return
    concat($filename, '.', $type, '.', $suffix)
};

declare function chimport:recent-file($import-info as element(xrx:import)) {

    let $path := concat(metadata:base-collection-path('charter', charters:ruri-tokens(), 'import.util'), chimport:recent-filename($import-info))
    let $type := $import-info/xrx:type/text()
    let $filename := $import-info/xrx:filename/text()
    return
    if($type != $chimport:EXCEL) then
      response:stream-binary(
        util:string-to-binary(serialize(doc($path), ())), 
        'application/octet-stream', 
        $filename
      )
    else
      response:stream-binary(
        util:binary-doc($path), 
        xmldb:get-mime-type($path), 
        $filename
      )
};

(:~
  is uploaded XML file well-formed?
:)
declare function chimport:is-wellformed($url) {

    try { doc($url)/* } catch * { <error>{ $err:description }</error> }
};

(:~
  transform uploaded XML file
  if transformation fails (XSLT script has errors) throw an error
:)
declare function chimport:transform($data-as-xml, $stylesheet) {

    try { transform:transform($data-as-xml, $stylesheet, ()) } catch * { <error>{ $err:description }</error> }
};

(:~
  import wizard
:)
declare function chimport:publish-charters-model(
    $request-root as xs:string,
    $xrx-import-xml as element(xrx:import)) as element() {

    <xf:model id="mpublish-charters">
    
        <xf:instance>{ $xrx-import-xml }</xf:instance>

        <xf:submission id="spublish-charters" 
            action="{ $request-root }service/publish-charters" 
            method="post" 
            replace="none">
            <xf:action ev:event="xforms-submit-error">
                <xf:message level="ephemeral">ERROR</xf:message>
            </xf:action>
            <xf:action ev:event="xforms-submit-done">
                <xf:message level="ephemeral">OK</xf:message>
            </xf:action>
        </xf:submission>
        
        <xf:action ev:event="xforms-ready">
          <script type="text/javascript">require(["dojo/dom-construct"], function(domConstruct){{domConstruct.place("bfLoading", "dialog-content", "first");}});</script>
        </xf:action>
    
    </xf:model>
};

declare function chimport:remove-charters-model(
    $request-root as xs:string,
    $xrx-import-xml as element(xrx:import),
    $imported-charters-cacheid as xs:string) as element() {

    <xf:model id="mremove-charters">
    
        <xf:instance>
        	<any_wrapper>
        		<cacheid>{ $imported-charters-cacheid }</cacheid>
        		<processid>pidremove-charters</processid>
        		{ $xrx-import-xml }
        	</any_wrapper>
        </xf:instance>

        <xf:submission id="sremove-charters" 
            action="{ $request-root }service/remove-charters" 
            method="post" 
            replace="none">
            <!--
            <xf:action ev:event="xforms-submit-error">
                <xf:message level="ephemeral">ERROR</xf:message>
            </xf:action>
            <xf:action ev:event="xforms-submit-done">
                <xf:message level="ephemeral">OK</xf:message>
            </xf:action>
            -->
        </xf:submission>
        
        <xf:action ev:event="xforms-ready">
          <script type="text/javascript">require(["dojo/dom-construct"], function(domConstruct){{domConstruct.place("bfLoading", "dialog-content", "first");}});</script>
        </xf:action>
    
    </xf:model>
};

declare function chimport:remove-charters-trigger(
    $remove-charters-message as element(xhtml:span),
    $context as xs:string,
    $imported-charters-cacheid) as element() {
    
    <xf:group model="mremove-charters">
        <xf:trigger appearance="minimal">
            <xf:label>
                <span>‣&#160;</span>
                { $remove-charters-message }
            </xf:label>
            <xf:action ev:event="DOMActivate">
              <script type="text/javascript">
                /* Using the import-progress service here, because service-wise it doesn't matter, if the progress is for import or remove. Functionality is the same. */
                jQuery('#progressbar-remove').progressbarRemove({{
                            serviceUrlRemoveProgress: "{ conf:param('request-root') }service/import-progress",
                            cacheId: "{ $imported-charters-cacheid }",
                            processId: "pidremove-charters"
                          }}).progressbar( "value", 0 ).progressbarRemove( "progress" );
              </script>
            </xf:action>
            <bfc:show dialog="remove-charters-dialog" ev:event="DOMActivate"/>
        </xf:trigger>
        <bfc:dialog id="remove-charters-dialog">
            <xf:label>
                { $remove-charters-message }
                <span>?</span>
            </xf:label>
            <div id="dialog-content" style="width:200px">
                <table style="float:right">
                    <tr>
                        <td>
                            <xf:trigger>
                                <xf:label>Cancel</xf:label>
                                <bfc:hide dialog="remove-charters-dialog" ev:event="DOMActivate"/>
                            </xf:trigger>
                        </td>
                        <td>
                            <xf:trigger style="float:left;margin-right:4px;">
                                <xf:label>OK</xf:label>
                                <xf:action ev:event="DOMActivate">
                                    <xf:send submission="sremove-charters"/>
                                    <xf:load show="replace">
                                      <xf:resource value="'{ $context }'"/>
                                    </xf:load>
                                </xf:action>
                            </xf:trigger>
                        </td>
                    </tr>
                    <tr>
                      <fieldset>
                        <legend>
                          Status
                        </legend>
                        <div data-demoid="e1a6f131-3aa1-49e9-bbd5-c0a28c2783c9" id="progressbar-remove"><div class="progress-label" data-demoid="66e8417d-6d6b-4829-b75e-4245bd95442a">0%</div></div>
                      </fieldset>
                    </tr>
                </table>
            </div>
        </bfc:dialog>                     
    </xf:group>    
};

declare function chimport:publish-charters-trigger(
    $publish-charters-message as element(xhtml:span),
    $context as xs:string) as element() {


    <xf:group model="mpublish-charters">
        <xf:trigger appearance="minimal">
            <xf:label>
                <span>‣&#160;</span>
                { $publish-charters-message }
            </xf:label>
            <bfc:show dialog="publish-charters-dialog" ev:event="DOMActivate"/>
        </xf:trigger>
        <bfc:dialog id="publish-charters-dialog">
            <xf:label>
                { $publish-charters-message }
                <span>?</span>
            </xf:label>
            <div id="dialog-content" style="width:200px">
                <table style="float:right">
                    <tr>
                        <td>
                            <xf:trigger>
                                <xf:label>Cancel</xf:label>
                                <bfc:hide dialog="publish-charters-dialog" ev:event="DOMActivate"/>
                            </xf:trigger>
                        </td>
                        <td>
                            <xf:trigger style="float:left;margin-right:4px;">
                                <xf:label>OK</xf:label>
                                <xf:action ev:event="DOMActivate">
                                    <xf:send submission="spublish-charters"/>
                                    <xf:load show="replace">
                                      <xf:resource value="'{ $context }'"/>
                                    </xf:load>
                                </xf:action>
                                <bfc:hide dialog="publish-charters-dialog" ev:event="DOMActivate"/>
                            </xf:trigger>
                        </td>
                    </tr>
                </table>
            </div>
        </bfc:dialog>                     
    </xf:group>    
};