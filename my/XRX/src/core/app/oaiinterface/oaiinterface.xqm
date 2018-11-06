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

module namespace oaiinterface="http://www.monasterium.net/NS/oaiinterface";

(: declaration of required namespaces:)
declare namespace oai="http://www.openarchives.org/OAI/2.0/";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace util="http://exist-db.org/xquery/util";
(: declaration of platform specific namespace :)
declare namespace atom="http://www.w3.org/2005/Atom";

(: import module :)
import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../xrx/conf.xqm";
    
(: ----- params from OAI-PMH spec ---------- :)
declare variable $oaiinterface:verb                := request:get-parameter("verb","0");
declare variable $oaiinterface:identifier          := request:get-parameter("identifier","0");
declare variable $oaiinterface:resumption-token     := request:get-parameter("resumptionToken","0");
declare variable $oaiinterface:metadata-prefix      := if(fn:compare($oaiinterface:resumption-token,"0")=0)then
                                                        request:get-parameter("metadataPrefix","0")
                                                      else
                                                        substring-before(substring-after($oaiinterface:resumption-token, "\"), "\"); 
declare variable $oaiinterface:set                 := request:get-parameter("set","0");
declare variable $oaiinterface:from                := request:get-parameter("from","0");
declare variable $oaiinterface:until               := request:get-parameter("until","0");
declare variable $oaiinterface:parameters          := request:get-parameter-names();
(: ---------------------------------------- :)

(: ------------- platform specific params ---------- :)
(: Variable to identify and validate resumptionToken :)
declare variable $oaiinterface:resumption-token-prefix := if (fn:compare($conf:project-name, "mom")=0)then
                                                            "oai:MoM:"
                                                        else
                                                            "oai:VdU:";
(: platform specific variables for verb "Identify":)                                                            
declare variable $oaiinterface:admin-email := "andre.streicher@uni-koeln.de";
declare variable $oaiinterface:repository-name := if (fn:compare($conf:project-name, "mom")=0)then
                                                    "Monasterium.net"
                                                 else
                                                    "VdU - Virtuelles deutsches Urkundennetzwerk";
declare variable $oaiinterface:delete-records := "no";
declare variable $oaiinterface:protocol-version := "2.0";
(: Date variables - datePattern is used to compare until/from- dates :)
declare variable $oaiinterface:granularity := "YYYY-MM-DDThh:mm:ssZ";
declare variable $oaiinterface:date-pattern := "^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z){0,1}$";
(: available metadataFormats :)
declare variable $oaiinterface:metadata-formats :=
            <oai:ListMetadataFormats>
                <oai:metadataFormat>
                    <oai:metadataPrefix>oai_dc</oai:metadataPrefix>
                    <oai:schema>http://www.openarchives.org/OAI/2.0/oai_dc.xsd</oai:schema>
                    <oai:metadataNamespace>http://www.openarchives.org/OAI/2.0/oai_dc/</oai:metadataNamespace>
                </oai:metadataFormat>
                <oai:metadataFormat>
                    <oai:metadataPrefix>ese</oai:metadataPrefix>
                    <oai:schema>http://www.europeana.eu/schemas/ese/ESE-V3.2.xsd</oai:schema>
                    <oai:metadataNamespace>http://www.europeana.eu/schemas/ese/</oai:metadataNamespace>
                </oai:metadataFormat>
            </oai:ListMetadataFormats>;
(: Tag of the document to compare the from/until parameters :)            
declare variable $oaiinterface:tag-to-compare-date := "atom:updated";
(: Tag of the document to compare the identifier parameter :)
declare variable $oaiinterface:tag-to-compare-id := "atom:id";
(: Maximum number of documents before resumptionToken is returned :)
declare variable $oaiinterface:number-to-export := 100;
(: URIs for DB - platform-base-uri is only used for headerXSL and contentXSL :)
declare variable $oaiinterface:db-base-uri := conf:param('data-db-base-uri');
(: ---------------------------------------- :)

(:  output has to be XML :)
declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=no"; 

(: validate both dates:)
declare function local:validate-dates() {
    let $oaiinterface:from-len     := string-length($oaiinterface:from)
    let $oaiinterface:until-len    := string-length($oaiinterface:until)
    return
        if ($oaiinterface:from-len > 0 and $oaiinterface:until-len > 0 and $oaiinterface:from-len != $oaiinterface:until-len) then
            false()
        else
            matches($oaiinterface:from, $oaiinterface:date-pattern) and matches($oaiinterface:until, $oaiinterface:date-pattern)
};

(: validate 'from'- dates:)
declare function local:validate-from-date() {
    let $oaiinterface:from-len     := string-length($oaiinterface:from)
    return
        if ($oaiinterface:from-len = 0) then
            false()
        else
            matches($oaiinterface:from, $oaiinterface:date-pattern)
};

(: validate 'until'- dates:)
declare function local:validate-until-date() {
    let $oaiinterface:until-len     := string-length($oaiinterface:until)
    return
        if ($oaiinterface:until-len = 0) then
            false()
        else
            matches($oaiinterface:until, $oaiinterface:date-pattern)
};

(: validate metadataPrefix:)
declare function local:validate-metadata-prefix() {
    let $formats-available := $oaiinterface:metadata-formats//oai:metadataPrefix/text()
    return
       if(empty(index-of($formats-available, $oaiinterface:metadata-prefix))) then
               true() 
       else false()
};

(: validate resumption token:)
declare function local:validate-res-token() {
    let $res-tok-len   := string-length($oaiinterface:resumption-token)
    return
        if ($res-tok-len = 0) then
            false()
        else
            starts-with($oaiinterface:resumption-token, $oaiinterface:resumption-token-prefix) 
};

(: define earliest datestamp :)
declare function local:find-earliest-datestamp($oai-collections as xs:string*) {
    (: collect all digital objects :)
    let $all-documents := 
                    for $oai-collection in $oai-collections
                    return
                        collection(concat($oaiinterface:db-base-uri, $oai-collection))
    let $all-dates := 
                        for $document in $all-documents
                            return
                               $document//node()[xs:string(fn:node-name(.)) = $oaiinterface:tag-to-compare-date]/text() cast as xs:dateTime
    let $earliest-datestamp := min($all-dates)
        return
            $earliest-datestamp
};

(: validate parameters :)
declare function local:validate-params($oai-collections as xs:string*, $base-url as xs:string, $function-pointer ) as node()*{

let $errors :=

if(not(fn:compare($oaiinterface:set,"0")=0)) then <error code="noSetHierarchy">No set structure available</error> 

else if((fn:compare($oaiinterface:resumption-token,"0")!=0)) then
    if(not(local:validate-res-token()))then 
        <error code="badResumptionToken">Resumption Token is not valid</error>
    else()

else if($oaiinterface:verb  = "ListSets") then <error code="noSetHierarchy">No set structure available</error>

else if($oaiinterface:verb  = "ListIdentifiers" or $oaiinterface:verb  ="ListRecords") then
      let $earliest-datestamp := local:find-earliest-datestamp($oai-collections)
      return
        if(fn:compare($oaiinterface:metadata-prefix,"0")=0) then <error code="badArgument">The parameter metadataPrefix is required</error>
        else if(local:validate-metadata-prefix()) then <error code="cannotDisseminateFormat">Metadata format is not available</error> 
        else if(fn:compare($oaiinterface:from,"0")!=0 and fn:compare($oaiinterface:until,"0")!=0) then
             if(not(local:validate-dates())) then <error code="badArgument">No valid date format</error>
             else if($oaiinterface:until cast as xs:dateTime < $earliest-datestamp)
                  then <error code="noRecordsMatch">date of until parameter is lower than the earliest datestamp</error>
             else if($oaiinterface:from cast as xs:dateTime > current-dateTime() cast as xs:dateTime)
                  then <error code="noRecordsMatch">date of from- parameter is a future date</error>
             else()
        else if(fn:compare($oaiinterface:from,"0")!=0 and fn:compare($oaiinterface:until,"0")=0) then 
             if(not(local:validate-from-date())) then <error code="badArgument">No valid from- date format</error>
             else if($oaiinterface:from cast as xs:dateTime > current-dateTime() cast as xs:dateTime)
                  then <error code="noRecordsMatch">date of from- parameter is a future date</error>
             else()
        else if(fn:compare($oaiinterface:from,"0")=0 and fn:compare($oaiinterface:until,"0")!=0) then 
             if(not(local:validate-until-date())) then <error code="badArgument">No valid until- date format</error>
             else if($oaiinterface:until cast as xs:dateTime < $earliest-datestamp)
                  then <error code="noRecordsMatch">date of until parameter is lower than the earliest datestamp</error>
             else()
        else ()
      
else if($oaiinterface:verb  ="Identify") then
        if(count($oaiinterface:parameters)>1) then <error code="badArgument">No further arguments allowed</error> 
        else()
        
else if($oaiinterface:verb  ="ListMetadataFormats") then
         if (count($oaiinterface:parameters)>1)then 
                if(fn:compare($oaiinterface:identifier,"0")=0) then <error code="badArgument">Argument is not allowed</error>
                else()
         else()

else if($oaiinterface:verb  ="GetRecord")then
      if(fn:compare($oaiinterface:metadata-prefix,"0")=0) then <error code="badArgument">The parameter metadataPrefix is required</error>
      else if(local:validate-metadata-prefix()) then <error code="cannotDisseminateFormat">Metadata format is not available</error>
      else if(fn:compare($oaiinterface:identifier,"0")=0) then <error code="badArgument">The parameter identifier is required</error>
      else()
      
else <error code="badVerb">No valid request type</error>
return
    if(empty($errors)) then
         (: handle parameters to produce a response:)
         local:response($oai-collections, $base-url, $function-pointer)
    else
        $errors
};

(: transform digital objects to metadata prefix format :)
declare function local:oai-transform($oai-from as xs:string, $oai-until as xs:string, $oai-collections as xs:string*, $function-pointer  ) as node()*{
(: index for resumptionToken :)
let $index := 
              if(fn:compare($oaiinterface:resumption-token,"0")=0)then
                    0
              else local:search-res-point($oai-collections)
(: collect all digital objects :)
let $all-documents := 
                    for $oai-collection in $oai-collections
                    return
                        collection(concat($oaiinterface:db-base-uri, $oai-collection))
return
    (: validate index of resumptionToken :)
    if(empty($index))then <error code="badResumptionToken">Resumption Token is not valid</error>
    else
        for $document at $number in $all-documents
        return
                (: export only defined number of documents :)
                if($number >= $index and $number < $index+$oaiinterface:number-to-export)
                then
                    let $date-string := $document//*[xs:string(fn:node-name(.)) = $oaiinterface:tag-to-compare-date]/text()  cast as xs:dateTime
                    return
                        (: compare date variables :)
                        if(fn:compare($oai-from,"0")!=0 or fn:compare($oai-until,"0")!=0) 
                        then
                             if(fn:compare($oai-from,"0")!=0 and fn:compare($oai-until,"0")!=0) 
                             then
                                 let $oai-from := $oai-from cast as xs:dateTime
                                 let $oai-until := $oai-until cast as xs:dateTime
                                 return
                                     if($oai-from <= $date-string and $oai-until >= $date-string) 
                                     then
                                            (: call function to transform :)
                                            util:call($function-pointer, $oaiinterface:verb, $document, $oaiinterface:metadata-prefix)
                                     else()  
                             else if(fn:compare($oai-from,"0")!=0 and fn:compare($oai-until,"0")=0) 
                             then
                                    if($oai-from <= $date-string)
                                    then
                                        (: call function to transform :)
                                        util:call($function-pointer, $oaiinterface:verb, $document, $oaiinterface:metadata-prefix)
                                    else()  
                             else if(fn:compare($oai-from,"0")=0 and fn:compare($oai-until,"0")!=0)
                             then                                   
                                    if($oai-until >= $date-string)
                                    then
                                        (: call function to transform :)
                                        util:call($function-pointer, $oaiinterface:verb, $document, $oaiinterface:metadata-prefix)  
                                    else()
                             else()                                  
                        else 
                            (: call function to transform :)
                            util:call($function-pointer, $oaiinterface:verb, $document, $oaiinterface:metadata-prefix) 
              (: max number of exported objects reached? - then produce a resumptionToken :)
              else if($number = ($index+$oaiinterface:number-to-export)) then
                   <oai:resumptionToken>{$oaiinterface:resumption-token-prefix}\{$oaiinterface:metadata-prefix}\{$document//*[xs:string(fn:node-name(.)) = $oaiinterface:tag-to-compare-id]/xmldb:encode(./text())}\{$oaiinterface:from}\{$oaiinterface:until}</oai:resumptionToken>
              else()            
};

(: Search for identfier of the resumption token in the list of records:)
declare function local:search-res-point($oai-collections as xs:string*) as xs:integer*{
    (: extract the identifier :)
    let $res-identity := substring-before(substring-after(substring-after($oaiinterface:resumption-token, "\"), "\"), "\")
    (: collect all digital objects :)
    let $all-documents := 
                    for $oai-collection in $oai-collections
                    return
                        collection(concat($oaiinterface:db-base-uri, $oai-collection))
    (: search for identifier :)
    for $document at $number in util:eval(concat('$all-documents//', $oaiinterface:tag-to-compare-id))
    return
       if ($document[. = $res-identity]) then $number
       else() 
};

(: handle parameters to produce a response:)
declare function local:response($oai-collections as xs:string*, $base-url as xs:string, $function-pointer  ) as node()*{ 
    if($oaiinterface:verb  ="Identify")
       then
            let $earliest-datestamp := local:find-earliest-datestamp($oai-collections)
                return
                (: identify the data provider:)
                <oai:Identify>
                    <oai:repositoryName>{$oaiinterface:repository-name}</oai:repositoryName>
                    <oai:baseURL>{$base-url}</oai:baseURL>
                    <oai:protocolVersion>{$oaiinterface:protocol-version}</oai:protocolVersion>
                    <oai:adminEmail>{$oaiinterface:admin-email}</oai:adminEmail>
                    <oai:earliestDatestamp>{$earliest-datestamp}</oai:earliestDatestamp>
                    <oai:deletedRecord>{$oaiinterface:delete-records}</oai:deletedRecord>
                    <oai:granularity>{$oaiinterface:granularity}</oai:granularity>
                </oai:Identify>
            
    else if($oaiinterface:verb  ="ListMetadataFormats")
        then
        if (count($oaiinterface:parameters)=1)
            then
            (: list the metadata format, currently vdu/mom only uses the ese format :)
            $oaiinterface:metadata-formats
           (: placeholder for more metadata formats in database - check the identifier:) 
         else 
            let $record := local:search-identifier($oai-collections)
            return
                if(not(empty($record)))then
                    $oaiinterface:metadata-formats
                else <error code="idDoesNotExist">Identifier does not exist</error>

    else if($oaiinterface:verb  = "ListRecords" or $oaiinterface:verb  = "ListIdentifiers")
    then 
            (: List records (in addiction to the until/ from parameter) :)
            let $hits := 
                    if(fn:compare($oaiinterface:resumption-token,"0")=0) then
                        local:oai-transform($oaiinterface:from, $oaiinterface:until, $oai-collections, $function-pointer)
                    else 
                         let $oaiinterface:metadata-prefix := substring-before(substring-after($oaiinterface:resumption-token, "\"), "\")
                         let $res-from := substring-before(substring-after(substring-after(substring-after($oaiinterface:resumption-token, "\"), "\"), "\"), "\")
                         let $res-until := substring-after(substring-after(substring-after(substring-after($oaiinterface:resumption-token, "\"), "\"), "\"), "\")
                         return
                         local:oai-transform($res-from, $res-until, $oai-collections, $function-pointer)
             return
                  if(empty($hits/child::*))then 
                        if(fn:compare($oaiinterface:resumption-token,"0")=0) then
                            <error code="noRecordsMatch">No records match</error>
                         else
                            <error code="badResumptionToken">Resumption Token is not valid</error>
                  else
                        if($oaiinterface:verb  = "ListRecords")then
                            <oai:ListRecords>{$hits}</oai:ListRecords> 
                        else
                            <oai:ListIdentifiers>{$hits}</oai:ListIdentifiers>                        
                          
    else if($oaiinterface:verb  ="GetRecord")
    then
        let $record := local:search-identifier($oai-collections)
        return
            (: Get a single record with the identifier parameter :)
            if(not(empty($record)))then
                <oai:GetRecord>
                   <oai:record>
                     (: call function to transform :)
                     {util:call($function-pointer, $oaiinterface:verb, $record, $oaiinterface:metadata-prefix)}
                   </oai:record>
               </oai:GetRecord>
            else <error code="idDoesNotExist">Identifier does not exist</error>
        else <error code="badVerb">No valid request type</error>
};

(: search identifier in collections :)
declare function local:search-identifier($oai-collections as xs:string*){
let $record := 
    for $oai-collection in $oai-collections
        return
            root(collection(concat($oaiinterface:db-base-uri, $oai-collection))//node()[xs:string(fn:node-name(.)) = $oaiinterface:tag-to-compare-id][xmldb:encode(./text()) = xmldb:encode($oaiinterface:identifier)])
return
    $record
};

(: main function as starting point of the response- process :)
(: Param $oai-collection as specific path to recources in DB/ Param $base-url as baseURL of the OAI- Interface:)
declare function oaiinterface:main($oai-collections as xs:string*, $base-url as xs:string, $function-pointer  ){
    (: OAI- PMH informations - have to be defined:)
    <OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/" 
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/
         http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">
    <responseDate>{current-dateTime()}</responseDate>
    <request> {(for $parameter in $oaiinterface:parameters
                return
                    attribute {$parameter}{request:get-parameter(string($parameter),0)})
                ,$base-url}</request>
    {
    (: check parameters and produce a response:)
    local:validate-params($oai-collections, $base-url, $function-pointer)
    }
     </OAI-PMH>
};