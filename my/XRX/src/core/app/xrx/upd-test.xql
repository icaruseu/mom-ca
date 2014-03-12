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

import module namespace upd="http://www.monasterium.net/NS/upd"
at "../../upd.xqm";

let $test := 
    <a id="a">
        <b id="b" class="b">
            //b/text()[1] (1)
            <c id="c">//c/text()[1] (2)</c>
            //b/text()[2] (3)
            <d id="d">
                <e id="e">//e/text()[1] (4)</e>
                //d/text()[1] (5)
            </d>
            //b/text()[3] (6)
        </b>
        //a/text() (7)
    </a>

return
(
    <lb/>,<!-- # upd:insertBefore -->,
    <test operation="upd:insert-before($target as node(), $content as node()+)">
        <lb/>
        <!-- insert element before element -->
    { 
        upd:insert-before($test//b, <insertElementBeforeElement/>) 
    }
        <lb/>
        <!-- insert element before root element -->
    { 
        upd:insert-before($test//a, <insertElementBeforeRootElement/>) 
    }
        <lb/>
        <!-- insert text node before element -->
    {
        upd:insert-before($test//b, text { 'insert text before element 2' })
    }
        <lb/>
        <!-- insert text before text -->
    {
        upd:insert-before($test//b/text()[2], text { 'insert text before text' })
    }
        <lb/>
        <!-- insert element before text -->
    {
        upd:insert-before($test//e/text(), <insertElementBeforeText/>)
    }
        <lb/>
        <!-- insert mixed content before text -->
    {
        upd:insert-before($test//b/text()[3], (<insertMixedContentAfterText1/>, text { 'mixed' }, <insertMixedContentAfterText2/>))
    }
    </test>,
    
    
    <lb/>,<!-- # upd:insertAfter -->,
    <test operation="upd:insert-after($target as node(), $content as node()+)">
        <lb/><!-- insert element after element -->
    { 
        upd:insert-after($test//b, <insertElementAfterElement/>) 
    }
        <lb/><!-- insert text after element -->
    { 
        upd:insert-after($test//b, text { 'insert text after element' }) 
    }
        <lb/>
        <!-- insert text after text -->
    {
        upd:insert-after($test//b/text()[2], text { 'insert text after text' })
    }
        <lb/>
        <!-- insert element after text -->
    {
        upd:insert-after($test//e/text(), <insertElementAfterText/>)
    }
        <lb/>
        <!-- insert mixed content after text -->
    {
        upd:insert-after($test//b/text()[3], (<insertMixedContentAfterText1/>, text { 'mixed' }, <insertMixedContentAfterText2/>))
    }
    </test>,
    
    <lb/>,<!-- # upd:insertInto -->,
    <test operation="upd:insert-into($target as node(), $content as node()+)">
        <lb/>
        <!-- insert element into element -->
    { 
        upd:insert-into($test//b, <insertElementIntoElement/>) 
    }
        <lb/><!-- insert element into root element -->
    { 
        upd:insert-into(root($test)/a, <insertElementIntoRootElement/>) 
    }
        <lb/><!-- insert element into document node -->
    { 
        upd:insert-into(root($test), <insertElementIntoDocumentNode/>) 
    }
        <lb/>
        <!-- insert element into element as first -->
    { 
        upd:insert-into-as-first($test//b, <insertElementIntoElementAsFirst/>) 
    }
        <lb/>
        <!-- insert element into root element as first -->
    { 
        upd:insert-into-as-first($test//a, <insertElementIntoRootElementAsFirst/>) 
    }
        <lb/>
        <!-- insert element into element as last -->
    { 
        upd:insert-into-as-last($test//b, <insertElementIntoElementAsLast/>) 
    }
        <lb/>
        <!-- insert element into root element as last -->
    { 
        upd:insert-into-as-last($test//a, <insertElementIntoRootElementAsLast/>) 
    }
        <lb/>
        <!-- insert mixed content into root element -->
    {
        upd:insert-into(root($test)/a, (<insertMixedIntoRootElement1/>, text { 'mixed' }, <insertMixedIntoRootElement/>))
    }
    </test>,
    
    
    <lb/>,<!-- # upd:insertAttributes -->,
    <test operation="upd:insert-attributes($target as element(), $content as attribute()+)">
        <lb/><!-- insert attributes into element -->
    { 
        upd:insert-attributes($test//b, (attribute insertAttribute1 { '1' }, attribute insertAttribute2 { '2' })) 
    }
        <lb/><!-- insert attributes into root element -->
    { 
        upd:insert-attributes($test//a, (attribute insertAttribute1 { '1' }, attribute insertAttribute2 { '2' })) 
    }
    </test>,
    
    <lb/>,<!-- # upd:delete -->,
    <test operation="upd:delete($target as node())">
        <lb/><!-- delete element -->
    { 
        upd:delete($test//c) 
    }
        <lb/><!-- delete root element -->
    { 
        upd:delete($test//a) 
    }
        <lb/><!-- delete attribute -->
    { 
        upd:delete($test//b/@class) 
    }
        <lb/><!-- delete text -->
    { 
        upd:delete($test//b/text()[3]) 
    }
    </test>,
    
    
    <lb/>,<!-- # upd:replace-node -->,
    <test operation="upd:replace-node($target as node(), $replacement as node()*)">
        <lb/>
        <!-- replace attribute with attribute -->
    { 
        upd:replace-node($test//b/@class, attribute replaceAttributeNode { 'test' }) 
    }
        <lb/>
        <!-- replace element with element -->
    { 
        upd:replace-node($test//c, <replaceElementNode/>) 
    }
        <lb/>
        <!-- replace element with text -->
    { 
        upd:replace-node($test//c, text { 'replace element with text' }) 
    }
        <lb/>
        <!-- replace text with text -->
    { 
        upd:replace-node($test//d/text(), text { 'replace text with text' }) 
    }
        <lb/>
        <!-- replace text with element -->
    { 
        upd:replace-node($test//b/text()[2], <replaceTextWithElement/>) 
    }
    </test>,
    
    
    <lb/>,<!-- # upd:replace-value -->,
    <test operation="upd:replace-value($target as node(), $string-value as xs:string)">
        <lb/>
        <!-- replace text value-->
    { 
        upd:replace-value($test//c/text(), 'replace text value') 
    }
        <lb/>
        <!-- replace attribute value -->
    { 
        upd:replace-value($test//c/@id, 'replace attribute value') 
    }
    </test>,
    
    
    <lb/>,<!-- # upd:replaceElementContent -->,
    <test operation="upd:replace-element-content($target as element(), $text as text()?)">
        <lb/>
        <!-- replace element content -->
    { 
        upd:replace-element-content($test//d, text { 'replaceElementContent' }) 
    }
        <lb/>
        <!-- replace root element content -->
    { 
        upd:replace-element-content(root($test)/a, text { 'replaceRootElementContent' }) 
    }
    </test>,
    
    <lb/>,<!-- # upd:rename -->,   
    <test operation="upd:rename($target as node(), $new-name as xs:QName)">
        <lb/>
        <!-- rename element -->
    { 
        upd:rename($test//b, xs:QName('testRenameElement')) 
    }
        <lb/>
        <!-- rename root element -->
    { 
        upd:rename(root($test)/a, xs:QName('testRenameRootElement')) 
    }
        <lb/>
        <!-- rename attribute -->
    { 
        upd:rename(root($test)//c/@id, xs:QName('testRenameAttribute')) 
    }
        <lb/>
        <!-- rename attribute of root element -->
    { 
        upd:rename(root($test)/a/@id, xs:QName('testRenameAttributeOfRootElement')) 
    }
    </test>
)
