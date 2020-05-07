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

module namespace bookmark="http://www.monasterium.net/NS/bookmark";

declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace ev="http://www.w3.org/2001/xml-events";
declare namespace xrx="http://www.monasterium.net/NS/xrx";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

declare function bookmark:atomids($user-xml as element(xrx:user)) as xs:string*{

    $user-xml//xrx:bookmark/text()
};

declare function bookmark:is-bookmarked($user-xml as element(xrx:user)?, $atomid as xs:string) {

    exists($user-xml//xrx:bookmark[.=$atomid])
};

declare function bookmark:create-bookmark-note($note as xs:string, $atomid as xs:string) as element() {
    
    <xrx:bookmark_note>
        <xrx:bookmark>{ $atomid }</xrx:bookmark>
        <xrx:note>{ $note }</xrx:note>
    </xrx:bookmark_note>
};

declare function bookmark:model($request-root as xs:string) as element() {

    <xf:model id="mbookmark">
    
        <xf:instance>
            <xrx:data xmlns:xrx="http://www.monasterium.net/NS/xrx">
                <xrx:bookmark/>
                <xrx:bookmarkNote/>
            </xrx:data>
        </xf:instance>
        
        <xf:submission id="sadd-bookmark" 
            action="{ $request-root }service/add-bookmark" 
            method="post" 
            replace="none">
            <xf:header>
                <xf:name>userid</xf:name>
                <xf:value>{ sm:id()//sm:username/text() }</xf:value>
            </xf:header>
        </xf:submission>
        
        <xf:submission id="sremove-bookmark" 
            action="{ $request-root }service/remove-bookmark" 
            method="post" 
            replace="none">
            <xf:header>
                <xf:name>userid</xf:name>
                <xf:value>{ sm:id()//sm:username/text() }</xf:value>
            </xf:header>
        </xf:submission>
        
        <xf:submission id="ssave-note" 
            action="{ $request-root }service/save-note" 
            method="post" 
            replace="none">
            <xf:header>
                <xf:name>userid</xf:name>
                <xf:value>{ sm:id()//sm:username/text() }</xf:value>
            </xf:header>
        </xf:submission>
      
    </xf:model>
};

declare function bookmark:trigger($is-bookmarked as xs:boolean, $atomid as xs:string, $num as xs:integer, $request-root as xs:string, $add-bookmark-message as element(xhtml:span), $remove-bookmark-message as element(xhtml:span)) as element() {

    let $case-add-bookmark := 
        <xf:case id="cadd-bookmark-{ $num }">
            <xf:trigger appearance="minimal">
                <xf:label>{ $add-bookmark-message }</xf:label>
                <xf:action ev:event="DOMActivate">
                    <xf:setvalue ref="//xrx:bookmark"
                        value="'{ $atomid }'" />
                    <xf:toggle case="cremove-bookmark-{ $num }"/>
                    <xf:send submission="sadd-bookmark" />
                    <script type="text/javascript">document.getElementById('noteBobble-{$num}').style.display = 'block';document.getElementById('note-textarea-{$num}-value').value = '';</script>
                </xf:action>
            </xf:trigger>
        </xf:case>
        
    let $case-remove-bookmark := 
        <xf:case id="cremove-bookmark-{ $num }">
            <img src="{ $request-root }resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/button_bookmarkAdd"/>
            <xf:trigger appearance="minimal">
                <xf:label>{ $remove-bookmark-message }</xf:label>
                <xf:action ev:event="DOMActivate">
                    <xf:setvalue ref="//xrx:bookmark"
                        value="'{ $atomid }'" />
                    <xf:toggle case="cadd-bookmark-{ $num }"/>
                    <xf:send submission="sremove-bookmark" />
                    <script type="text/javascript">document.getElementById('note-field-{$num}').style.display = 'none';document.getElementById('noteBobble-{$num}').style.display = 'none';</script>
                </xf:action>
            </xf:trigger>
        </xf:case>
        
    return
    
    <xf:group model="mbookmark">
        <xf:switch>
        
            {
            if($is-bookmarked) then ($case-remove-bookmark, $case-add-bookmark)
            else ($case-add-bookmark, $case-remove-bookmark)
            }
        
        </xf:switch>
    </xf:group>
};