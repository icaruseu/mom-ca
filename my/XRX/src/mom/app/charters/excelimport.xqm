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

module namespace excelimport="http://www.monasterium.net/NS/excelimport";

declare namespace cei="http://www.monasterium.net/NS/cei";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace xs="http://www.w3.org/2001/XMLSchema";

import module namespace data="http://www.monasterium.net/NS/data"
    at "../data/data.xqm";
import module namespace xrx="http://www.monasterium.net/NS/xrx"
    at "../xrx/xrx.xqm";
import module namespace i18n="http://www.monasterium.net/NS/i18n"
    at "../i18n/i18n.xqm";
import module namespace charter="http://www.monasterium.net/NS/charter"
    at "../charter/charter.xqm";
import module namespace template="http://www.monasterium.net/NS/template"
    at "../xrx/template.xqm";
import module namespace assertion="http://www.monasterium.net/NS/assertion"
    at "../xrx/assertion.xqm";
import module namespace excel="http://exist-db.org/xquery/excel";

declare variable $excelimport:schema :=  $xrx:live-project-db-base-collection/xs:schema[@id='cei'];

declare variable $excelimport:message-missing-idno := "Missing charter signature";
declare variable $excelimport:message-wrong-date-format := "Wrong date format (YYYYMMDD expected)";
declare variable $excelimport:message-wrong-column-name := "Wrong column name";
declare variable $excelimport:message-expected-column-names := "Expected column names are: ";
declare variable $excelimport:xslt :=  $xrx:live-project-db-base-collection/xsl:stylesheet[@id='excel2cei'];
declare variable $excelimport:template := template:get('tag:www.monasterium.net,2011:/mom/template/excelimport', false());
declare variable $excelimport:xsl-add-namespace :=
    <xsl:stylesheet 
    xmlns="http://www.monasterium.net/NS/cei"
    xmlns:cei="http://www.monasterium.net/NS/cei" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">
        <xsl:template match="/">
            <xsl:apply-templates/>
        </xsl:template>
        <xsl:template match="*">
            <xsl:param name="n" select="local-name(.)"/>
            <xsl:element name="{{$n}}" namespace="http://www.monasterium.net/NS/cei">
              <xsl:apply-templates/>
            </xsl:element>
        </xsl:template>
        <xsl:template match="@*">
            <xsl:copy>
                <xsl:apply-templates select="@*|node()" />
            </xsl:copy>
        </xsl:template>
    </xsl:stylesheet>;


declare function excelimport:workbookinfo($url) {

    try { excel:workbookinfo($url) } catch * { <excel:error>{$err:code} {$err:description}</excel:error> }
};

declare function excelimport:chooserow($chooserow as xs:string) {

    try {
        util:eval(replace($chooserow, '-', ' to '))
    }
    catch * {
        -1
    }
};

declare function excelimport:row2cei($row as element(excel:row), $sheet-labels as xs:string+) as element() {

    let $cell-elements := $row/excel:cell
    let $preprocess-row :=
        <excelSheet xmlns="">
        {
            for $label at $pos in $sheet-labels
            let $value := $cell-elements[ $pos ]/text()
            return
            if(contains($value, '&lt;')) then
                let $parse := try { util:parse(concat('<dummy>', $value, '</dummy>')) } catch * { <error label="{ $label }">{ $err:description }</error> }
                let $clean := if($parse/self::error) then $parse else transform:transform($parse, $excelimport:xsl-add-namespace, ())/node()
                let $log := util:log('error', $clean)
                return
                element { $label } { $clean }
            else if(matches($value, "\$\$")) then
                let $tokens := tokenize($value, "\$\$")
                for $token in $tokens 
                return
                element { $label } { $token }
            else
                element { $label } { $value }
        }
        </excelSheet>
  
    (: XSLT transformation:)
    let $transform-row := transform:transform($preprocess-row, $excelimport:xslt, ())
    
    (: validate CEI :)
    let $validation-report := data:validate($transform-row, $excelimport:schema)
    let $not-wellformed := exists($preprocess-row//error)
    let $is-valid := if($validation-report//status[.='valid']) then true() else false()
    
    return
    
    if($is-valid) then 
        $transform-row 
    else if($not-wellformed) then
        <report>
            <rownum>{ $row/@num/string() }</rownum>
            <idno>{ $transform-row//cei:body/cei:idno/text() }</idno>
            <message>Invalid markup in column: "{ $preprocess-row//error/@label/string() }"</message>
            <error>{ $preprocess-row//error/text() }</error>
        </report>        
    else
        let $messages := $validation-report//message/text()
        let $translated-messages :=
            for $message at $pos in $messages
            return
            assertion:translate($message)
        let $errors := 
            for $message in $messages
            return
            if(not(contains($message, 'i18n'))) then $message else ''
        return
        <report>
            <rownum>{ $row/@num/string() }</rownum>
            <idno>{ $transform-row//cei:body/cei:idno/text() }</idno>
            <message>{ for $message at $pos in $translated-messages return concat('(', xs:string($pos), ') ', $message) }</message>
            <error>{ string-join($errors, ' ') }</error>
        </report>
};

declare function excelimport:columnname($label as xs:string*) as xs:string {

    ($excelimport:template/excel:column[excel:altname=$label]/excel:name/text(), $label, 'dummy')[1]
};

declare function excelimport:sheet2cei($sheet as element(excel:sheet), $rows as xs:integer+, $cacheid as xs:string, $processid as xs:string) as element()+ {

    let $clear-grammar-cache := validation:clear-grammar-cache()
    let $sheet-labels := 
        for $cell in $sheet//excel:row[@num='1']/excel:cell
        return
        excelimport:columnname($cell/text())
    let $cei := 
        for $row-element at $pos in $sheet//excel:row
        let $progress := 
        <xrx:progress>
            <xrx:cacheid>{ $cacheid }</xrx:cacheid>
            <xrx:processid>{ $processid }</xrx:processid>
            <xrx:actual>{ $pos }</xrx:actual>
            <xrx:total>{ count($rows) + 1 }</xrx:total>
            <xrx:message></xrx:message>        
        </xrx:progress>
        let $cache := cache:put($cacheid, $processid, $progress)
        return
        if($pos = $rows and $pos gt 1) then excelimport:row2cei($row-element, $sheet-labels)
        else()
    let $is-valid := if(exists($cei//report)) then false() else true()
    let $clear-cache := cache:clear($cacheid)
    return
    
    if($is-valid) then <cei:cei>{ $cei }</cei:cei>
    else $cei//report
};

declare function excelimport:error($rownum as xs:string, $cellnum as xs:string, $message as xs:string, $value as xs:string) as element() {

    <excel:error rownum="{ $rownum }" cellnum="{ $cellnum }">{ $message }: '{ $value }'</excel:error>
};

declare function excelimport:validate-idno($sheet as element(excel:sheet)) as element()* {

    let $idno-cellnum := $sheet//excel:row[@num='1']/excel:cell[.='Signatur']/@num/string()
    
    let $wrong-idno :=
        for $idno at $rownum in $sheet//excel:row[@num!='1']/excel:cell[@num=$idno-cellnum]
        let $idno-value := $idno/text()
        return
        if(string-length($idno-value) != 0) then ()
        else excelimport:error(xs:string($rownum + 1), $idno-cellnum, $excelimport:message-missing-idno, $idno)
    
    return
    
    (
        $wrong-idno
    )
};

(: maybe there is something wrong with the dates :)
declare function excelimport:validate-date($sheet as element(excel:sheet)) as element()* {

    let $yearmonthday-cellnum := $sheet//excel:row[@num='1']/excel:cell[.='Einzeldatierung']/@num/string()
    let $year-cellnum := $sheet//excel:row[@num='1']/excel:cell[.='Jahr']/@num/string()
    let $month-cellnum := $sheet//excel:row[@num='1']/excel:cell[.='Monat']/@num/string()
    let $day-cellnum := $sheet//excel:row[@num='1']/excel:cell[.='Tag']/@num/string()
    
    (: wrong date format YYYYMMDD :)
    let $wrong-dateformat := 
        for $date at $rownum in $sheet//excel:row[@num!='1']/excel:cell[@num=$yearmonthday-cellnum]
        let $date-value := $date/text()
        return
        if(not($date-value)) then ()
        else if(string-length($date-value) = 8 and $date castable as xs:integer) then ()
        else excelimport:error(xs:string($rownum + 1), $yearmonthday-cellnum, $excelimport:message-wrong-date-format, $date-value)
    
    return
    
    (
        $wrong-dateformat
    )
};

(: maybe there is a wrong column name used :)
declare function excelimport:validate-columnnames($sheet as element(excel:sheet)) as element()* {

    let $sheet-columnnames := 
        for $label1 in $sheet//excel:row[@num='1']/excel:cell/text()
        return
        $label1
        
    let $wrong-columnames :=
        for $name at $cellnum in $sheet-columnnames
        return
        if($excelimport:template/excel:column[excel:name=$name or excel:altname=$name]) then ()
        else 
        excelimport:error('1', xs:string($cellnum), $excelimport:message-wrong-column-name, $name)
    
    let $expected-colums := 
        $excelimport:template//excel:column
        
    let $expected-column-names := 
        string-join(
            for $column in $expected-colums
            return 
            concat($column/excel:name/text(), ' (', string-join($column/excel:altname/text(), ', '), ')'),
            ', '
        )
    
    return
    
    (
        $wrong-columnames,
        if($wrong-columnames) then excelimport:error('1', ' ', $excelimport:message-expected-column-names, $expected-column-names) else()
    )
};

(: validate the excel sheet before we try to transform it into XML :)
declare function excelimport:validate-sheet($sheet as element(excel:sheet)) as element()* {

    let $validate-sheet :=
    (
        excelimport:validate-columnnames($sheet)
        (:excelimport:validate-date($sheet):)
        (:excelimport:validate-idno($sheet):)
    )
    return $validate-sheet
};