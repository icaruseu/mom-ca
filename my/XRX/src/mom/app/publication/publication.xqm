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

module namespace publication="http://www.monasterium.net/NS/publication";
import module namespace momathon="http://www.monasterium.net/NS/momathon" at "xmldb:exist:///db/XRX.live/mom/app/momathon/momathon.xqm";
declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace ev="http://www.w3.org/2001/xml-events";
declare namespace xrx="http://www.monasterium.net/NS/xrx";
declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace bfc="http://betterform.sourceforge.net/xforms/controls";

declare function publication:writeMomLog($atomid as xs:string) {
    let $log := momathon:WriteMomLog($atomid)
    return ()
};

(: Build URL from ATOM-Tag :)
declare function publication:build-url($atomid as xs:string) as xs:string? {

    let $mode := if(request:get-parameter("mode","") != "") then request:get-parameter("mode","") else "full"

    let $token := tokenize($atomid, "/")
    let $sub := subsequence($token, 3, count($token) - 2)
    let $context := if(count($sub) = 2) then "collection" else "fond"
    let $objectid := $sub[last()]
    let $archiveid := $sub[1]
    let $fondid := $sub[2]
    let $collectionid := $sub[1]
    let $url := if($context = "collection") then concat($collectionid, "/", $objectid, "/edit?mode=", $mode) else concat($archiveid, "/", $fondid, "/", $objectid, "/edit?mode=", $mode)
    
    
    
    return
          $url
};

declare function publication:is-saved($user-xml as element(xrx:user)*, $atomid as xs:string) as xs:boolean {
	exists($user-xml//xrx:saved[xrx:id=$atomid])
};

declare function publication:saved-by-user($user-xml as element(xrx:user)*, $atomid as xs:string*) as xs:string? {

    $user-xml//xrx:saved[xrx:id=$atomid]/ancestor::xrx:user/xrx:email/text()
};

declare function publication:model($request-root as xs:string) as element() {

    <xf:model id="msaved">
    
        <xf:instance>
            <data xmlns="">
                <atomid/>
                <mode/>
            </data>
        </xf:instance>
        
        <xf:instance id="itest">
            <data xmlns=""/>
        </xf:instance>
        
        <xf:submission id="ssave-charter" 
            action="{ $request-root }service/save-charter" 
            method="post" 
            replace="none">
            <xf:action ev:event="xforms-submit-error"><xf:message level="ephemeral">ERROR</xf:message></xf:action>
            <xf:header>
              <xf:name>userid</xf:name>
              <xf:value>{ xmldb:get-current-user() }</xf:value>
            </xf:header>
        </xf:submission>
        
        <xf:submission id="srelease-charter" 
            action="{ $request-root }service/release-charter" 
            method="post" 
            replace="none">
            <xf:header>
              <xf:name>userid</xf:name>
              <xf:value>{ xmldb:get-current-user() }</xf:value>
            </xf:header>
        </xf:submission>
        
        <xf:submission id="sremove-charter" 
            action="{ $request-root }service/remove-charter" 
            method="post" 
            replace="none">
            <xf:header>
              <xf:name>userid</xf:name>
              <xf:value>{ xmldb:get-current-user() }</xf:value>
            </xf:header>
        </xf:submission>

        <xf:submission id="spublish-charter" 
            action="{ $request-root }service/publish-charter" 
            method="post" 
            replace="instance"
            instance="itest">
            <!--xf:action ev:event="xforms-submit-error">
                <xf:message level="ephemeral">ERROR</xf:message>
            </xf:action>
            <xf:action ev:event="xforms-submit-done">
                <xf:message level="ephemeral">OK</xf:message>
            </xf:action-->
            <xf:header>
              <xf:name>userid</xf:name>
              <xf:value>{ xmldb:get-current-user() }</xf:value>
            </xf:header>
        </xf:submission>
                           
    </xf:model>

};


declare function publication:momathon-trigger(
    $atomid as xs:string,
    $num as xs:integer,
    $request-root as xs:string,
    $widget-key as xs:string,
    $save-charter-message as element(xhtml:span)) {

    if(matches($widget-key, '^(fond|collection|search|saved-charters|charter|bookmarks|mom-ca)$')) then
    <div>
        <xf:trigger appearance="minimal">
            <xf:label>{ $save-charter-message }</xf:label>
            <xf:action ev:event="DOMActivate">
                <xf:setvalue ref="//atomid" value="'{ $atomid }'"/>
                <xf:setvalue ref="//mode" value="momathon"/>
                <xf:recalculate/>
                <xf:send submission="ssave-charter"/>
                <xf:load show="new" resource ="{ $request-root }/{publication:build-url($atomid)}"/>
              
            </xf:action>
        </xf:trigger>
    </div>
    else
    <div/>
};

declare function publication:save-trigger(
    $atomid as xs:string,
    $num as xs:integer,
    $request-root as xs:string,
    $widget-key as xs:string,
    $save-charter-message as element(xhtml:span)) {

    if(matches($widget-key, '^(fond|collection|search|saved-charters|charter|bookmarks|mom-ca)$')) then
    <div>
        <xf:trigger appearance="minimal">
            <xf:label>{ $save-charter-message }</xf:label>
            <xf:action ev:event="DOMActivate">
                <xf:setvalue ref="//atomid" value="'{ $atomid }'"/>
                <xf:recalculate/>
                <xf:send submission="ssave-charter"/>
                <xf:toggle case="cedit-charter-{ $num }"/>
            </xf:action>
        </xf:trigger>
    </div>
    else
    <div/>
};

declare function publication:edit-trigger(
    $atomid as xs:string,
    $num as xs:integer,
    $request-root as xs:string,
    $is-moderator as xs:boolean,
    $widget-key as xs:string,
    $edit-charter-message as element(xhtml:span),
    $edit-mode as xs:string) {

    if($is-moderator and (matches($widget-key,'charters-to-publish'))) then
    <div>
        <img src="{ $request-root }resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/button_edit"/>
        <xf:trigger appearance="minimal">
            <xf:label>{ $edit-charter-message }</xf:label>
            <xf:action ev:event="DOMActivate">
              <xf:load show="replace">
                <xf:resource value="'{ $request-root }revise-charter?id={ $atomid }'"/>
              </xf:load>
            </xf:action>
        </xf:trigger>
    </div>
    else if(matches($widget-key, '^(fond|collection|search|saved-charters|charter|charters-to-publish|bookmarks|mom-ca)$')) then
    <div>
        <img src="{ $request-root }resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/button_edit"/>
        <xf:trigger appearance="minimal">
            <xf:label>{ $edit-charter-message }</xf:label>
            <xf:action ev:event="DOMActivate">
            {
              if ($edit-mode = "editmom3" or $widget-key="mom-ca") then
                  <xf:load show="new">
                    <xf:resource value="'{ $request-root }/{publication:build-url($atomid)}'"/> 
                  </xf:load>
              else
                  <xf:load show="replace">
                      <xf:resource value="'{ $request-root }edit-charter?id={ $atomid }'"/>
                  </xf:load>
              }
            </xf:action>
        </xf:trigger>
    </div>
    else
    <div/>
};

declare function publication:publish-trigger(
    $atomid as xs:string,
    $num as xs:integer,
    $request-root as xs:string,
    $widget-key as xs:string,
    $publish-charter-message as element(xhtml:span)) {

    if(matches($widget-key, '(saved-charters|charters-to-publish)')) then
    <div>
        <img src="{ $request-root }resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/export"/>
        <xf:trigger appearance="minimal">
            <xf:label>{ $publish-charter-message }</xf:label>
            <bfc:show dialog="publish-dialog-{ $num }" ev:event="DOMActivate"></bfc:show>
        </xf:trigger>
        <bfc:dialog id="publish-dialog-{ $num }">
            <xf:label>{ $publish-charter-message }?</xf:label>
            <div style="width:200px">
                <table style="float:right">
                    <tr>
                        <td>
                            <xf:trigger>
                                <xf:label>Cancel</xf:label>
                                <bfc:hide dialog="publish-dialog-{ $num }" ev:event="DOMActivate"></bfc:hide>
                            </xf:trigger>
                        </td>
                        <td>
                            <xf:trigger style="float:left;margin-right:4px;">
                                <xf:label>OK</xf:label>
                                <xf:action ev:event="DOMActivate">
                                    <xf:setvalue ref="//atomid" value="'{ $atomid }'"/>
                                    <xf:recalculate/>
                                    <xf:send submission="spublish-charter"/>
                                    <script type="text/javascript">dojo.style('ch{ $num }', 'display', 'none')</script>
                                    <xf:message level="ephemeral">OK</xf:message>
                                </xf:action>
                                <bfc:hide dialog="publish-dialog-{ $num }" ev:event="DOMActivate"></bfc:hide>
                            </xf:trigger>
                        </td>
                    </tr>
                </table>
            </div>
        </bfc:dialog>
    </div>
    else
    <div/>
};

declare function publication:release-trigger(
    $atomid as xs:string,
    $num as xs:integer,
    $request-root as xs:string,
    $widget-key as xs:string,
    $release-charter-message as element(xhtml:span)) {

    if(matches($widget-key, '^(saved-charters)$')) then
    <div>
        <img src="{ $request-root }resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/export"/>
        <xf:trigger appearance="minimal">
            <xf:label>{ $release-charter-message }</xf:label>
            <bfc:show dialog="release-dialog-{ $num }" ev:event="DOMActivate"></bfc:show>
        </xf:trigger>
        <bfc:dialog id="release-dialog-{ $num }">
            <xf:label>{ $release-charter-message }?</xf:label>
            <div style="width:150px">
                <table style="float:right">
                    <tr>
                        <td>
                            <xf:trigger>
                                <xf:label>Cancel</xf:label>
                                <bfc:hide dialog="release-dialog-{ $num }" ev:event="DOMActivate"></bfc:hide>
                            </xf:trigger>
                        </td>
                        <td>
                            <xf:trigger style="float:left;margin-right:4px;">
                                <xf:label>OK</xf:label>
                                <xf:action ev:event="DOMActivate">
                                    <xf:setvalue ref="//atomid" value="'{ $atomid }'"/>
                                    <xf:recalculate/>
                                    <xf:send submission="srelease-charter"/>
                                    <script type="text/javascript">dojo.style('ch{ $num }', 'display', 'none')</script>
                                    <xf:message level="ephemeral">OK</xf:message>
                                </xf:action>
                                <bfc:hide dialog="release-dialog-{ $num }" ev:event="DOMActivate"></bfc:hide>
                            </xf:trigger>
                        </td>
                    </tr>
                </table>
            </div>
        </bfc:dialog>
    </div>
    else
    <div/>
};

declare function publication:remove-trigger(    
    $atomid as xs:string,
    $num as xs:integer,
    $request-root as xs:string,
    $widget-key as xs:string,
    $remove-charter-message as element(xhtml:span)) {

    if($widget-key = 'saved-charters' or $widget-key = 'charters-to-publish') then    
    <div>
        <img src="{ $request-root }resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/remove"/>
        <xf:trigger appearance="minimal">
            <xf:label>{ $remove-charter-message }</xf:label>
            <bfc:show dialog="remove-dialog-{ $num }" ev:event="DOMActivate"></bfc:show>
        </xf:trigger>
        <bfc:dialog id="remove-dialog-{ $num }">
            <xf:label>{ $remove-charter-message }?</xf:label>
            <div style="width:150px">
                <table style="float:right">
                    <tr>
                        <td>
                            <xf:trigger>
                                <xf:label>Cancel</xf:label>
                                <bfc:hide dialog="remove-dialog-{ $num }" ev:event="DOMActivate"></bfc:hide>
                            </xf:trigger>
                        </td>
                        <td>
                            <xf:trigger style="float:left;margin-right:4px;">
                                <xf:label>OK</xf:label>
                                <xf:action ev:event="DOMActivate">
                                    <xf:setvalue ref="//atomid" value="'{ $atomid }'"/>
                                    <xf:recalculate/>
                                    <xf:send submission="sremove-charter"/>
                                    <script type="text/javascript">dojo.style('ch{ $num }', 'display', 'none')</script>
                                    <xf:message level="ephemeral">OK</xf:message>
                                    { if($widget-key = 'saved-charters') then <xf:toggle case="csave-charter-{ $num }"/> else() }
                                </xf:action>
                                <bfc:hide dialog="remove-dialog-{ $num }" ev:event="DOMActivate"></bfc:hide>
                            </xf:trigger>
                        </td>
                    </tr>
                </table>
            </div>
        </bfc:dialog>
    </div>
    else
    <div/>
};

declare function publication:moderator-actions(
    $atomid as xs:string,
    $num as xs:integer,
    $request-root as xs:string,
    $revise-editions-message as element(xhtml:span),
    $publish-charter-message as element(xhtml:span),
    $discard-editions-message as element(xhtml:span)) {

    let $case-publish-charter :=
    <xf:case id="cpublish-charter-{ $num }">
        <div>
            <img src="{ $request-root }resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/button_edit"/>
            <xf:trigger appearance="minimal">
                <xf:label>{ $revise-editions-message }</xf:label>
                <xf:action ev:event="DOMActivate">
                  <xf:load show="replace">
                    <xf:resource value="'{ $request-root }revise-charter?id={ $atomid }'"/>
                  </xf:load>
                </xf:action>
            </xf:trigger>
        </div>
        { publication:publish-trigger($atomid,$num,$request-root,'',$publish-charter-message) }
        <div>
            <img src="{ $request-root }resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/remove"/>
            <xf:trigger appearance="minimal">
                <xf:label>{ $discard-editions-message }</xf:label>
                <bfc:show dialog="discard-dialog-{ $num }" ev:event="DOMActivate"></bfc:show>
            </xf:trigger>
            <bfc:dialog id="discard-dialog-{ $num }">
                <xf:label>{ $discard-editions-message }?</xf:label>
                <div style="width:200px">
                    <table style="float:right">
                        <tr>
                            <td>
                                <xf:trigger>
                                    <xf:label>Cancel</xf:label>
                                    <bfc:hide dialog="discard-dialog-{ $num }" ev:event="DOMActivate"></bfc:hide>
                                </xf:trigger>
                            </td>
                            <td>
                                <xf:trigger style="float:left;margin-right:4px;">
                                    <xf:label>OK</xf:label>
                                    <xf:action ev:event="DOMActivate">
                                        <xf:setvalue ref="//atomid" value="'{ $atomid }'"/>
                                        <xf:recalculate/>
                                        <xf:send submission="sremove-charter"/>
                                        <script type="text/javascript">dojo.style('ch{ $num }', 'display', 'none')</script>
                                        <xf:message level="ephemeral">OK</xf:message>
                                    </xf:action>
                                    <bfc:hide dialog="discard-dialog-{ $num }" ev:event="DOMActivate"></bfc:hide>
                                </xf:trigger>
                            </td>
                        </tr>
                    </table>
                </div>
            </bfc:dialog>
        </div>
    </xf:case>
    
    return
    
    <xf:group model="msaved">
        <xf:switch>{ $case-publish-charter }</xf:switch>
    </xf:group>    

};

declare function publication:user-actions(
    $saved-by-current-user as xs:boolean, 
    $saved-by-any-user as xs:boolean, 
    $atomid as xs:string, 
    $num as xs:integer, 
    $request-root as xs:string,
    $is-moderator as xs:boolean,
    $widget-key as xs:string,
    $save-charter-message as element(xhtml:span), 
    $edit-charter-message as element(xhtml:span), 
    $charter-in-use-message as element(xhtml:span), 
    $release-charter-message as element(xhtml:span),
    $remove-charter-message as element(xhtml:span),
    $publish-charter-message as element(xhtml:span)) as element() {

    let $editmom3msg :=           <span>Edit with EditMOM 3 beta</span>
    
    (: MOMathon-Trigger :)
    let $case-momathon-charter :=
    <xf:case id="cmom-charter-{ $num }">
        { publication:momathon-trigger($atomid,$num,$request-root,$widget-key,publication:change-element-ns($editmom3msg, "http://www.w3.org/1999/xhtml", "xhtml")) }
    </xf:case>
    
    (: charter is saved by current user :)
    let $case-save-charter :=
    <xf:case id="csave-charter-{ $num }">
        { publication:save-trigger($atomid,$num,$request-root,$widget-key,$save-charter-message) }
    </xf:case>
    
    (: charter is free to edit :)
    let $case-edit-charter :=
    <xf:case id="cedit-charter-{ $num }">
        { publication:edit-trigger($atomid,$num,$request-root,$is-moderator,$widget-key,$edit-charter-message, "") }
        { if($widget-key = "saved-charters") then publication:edit-trigger($atomid,$num,$request-root,$is-moderator,$widget-key,publication:change-element-ns($editmom3msg, "http://www.w3.org/1999/xhtml", "xhtml"), "editmom3") else ""}
        {
        if($is-moderator) then 
            publication:publish-trigger($atomid,$num,$request-root,$widget-key,$publish-charter-message)
        else
            publication:release-trigger($atomid,$num,$request-root,$widget-key,$release-charter-message)
        }
        { publication:remove-trigger($atomid,$num,$request-root,$widget-key,$remove-charter-message) }
    </xf:case>    

    (: charter is in use by another user :)
    let $case-charter-in-use :=
    <xf:case id="ccharter-in-use">
        {
        if(matches($widget-key, '^(fond|collection|search|charter)$')) then
        <div>{ $charter-in-use-message }</div>
        else 
        <div/>
        }
    </xf:case>
    
    return

    <xf:group model="msaved">
        <xf:switch>
            {
            if($widget-key = 'charters-to-publish') then ($case-edit-charter)
            else if($saved-by-current-user) then ($case-edit-charter, $case-save-charter)
            else if($saved-by-any-user) then $case-charter-in-use
            else if($widget-key = "mom-ca") then ($case-momathon-charter) 
            else ($case-save-charter, $case-edit-charter)
            }
        </xf:switch>
    </xf:group>
};
declare function publication:change-element-ns
  ( $elements as element()* ,
    $newns as xs:string ,
    $prefix as xs:string )  as element()? {

   for $element in $elements
   return
   element {QName ($newns,
                      concat($prefix,
                                if ($prefix = '')
                                then ''
                                else ':',
                                local-name($element)))}
           {$element/@*, $element/node()}
 } ;