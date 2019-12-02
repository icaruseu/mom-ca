xquery version "3.0";
module namespace platform-oai='http://www.monasterium.net/NS/platform-oai';

declare namespace cei="http://www.monasterium.net/NS/cei";
declare namespace xrx="http://www.monasterium.net/NS/xrx";
declare namespace oai="http://www.openarchives.org/OAI/2.0/";
declare namespace europeana="http://www.europeana.eu/schemas/ese/";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace eag="http://www.archivgut-online.de/eag";
declare namespace ead="urn:isbn:1-931666-22-9";
declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace oei="http://www.monasterium.net/NS/oei";
declare namespace util="http://exist-db.org/xquery/util";

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../xrx/conf.xqm";

declare variable $platform-oai:atom-tag-name := conf:param('atom-tag-name');
(: URI for DB :)
declare variable $platform-oai:platform-base-uri := conf:param('xrx-platform-db-base-uri');


(:  output has to be XML :)
declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=no";

(: produce the headers and content of oai record:)
declare function platform-oai:transform($verb as xs:string, $document as node()*, $metadata-prefix as xs:string) as node()*{
    (: XSLT for content transformation :)
    let $content-xsl := 
                        if(fn:compare($metadata-prefix,"oai_dc")=0)then
                            collection($platform-oai:platform-base-uri)//xsl:stylesheet[@id ='cei2oaidc']
                        else if(fn:compare($metadata-prefix,"ese")=0)then
                            collection($platform-oai:platform-base-uri)//xsl:stylesheet[@id ='cei2ese']
                        else collection($platform-oai:platform-base-uri)//xsl:stylesheet[@id ='cei2oaidc']
    (: XSLT for header transformation :)
    let $header-xsl := collection($platform-oai:platform-base-uri)//xsl:stylesheet[@id ='cei2oaiheader']
    (: define data provider and image URL (in addiction to archive/ collection/ fonds) :)
    let $data-provider := local:search-for-data-provider($document//atom:entry/atom:id/text())
    let $fondid := local:object-uri-tokens($document//atom:entry/atom:id/text())[2]
    let $base-image-url := local:search-for-image-url($document//atom:entry/atom:id/text())
    (: specific params for XSLT Transformation :)
    let $xsl-content-params := <parameters>
                                      <param name="platform-id" value="{ $conf:project-name }"/>
                                      <param name="data-provider" value="{ $data-provider }"/>
                                      <param name="base-image-url" value="{ $base-image-url}"/>
                                      <param name="fond-id" value="{ $fondid }"/>
                               </parameters> 
    let $xsl-header-params := <parameters>
                                      <param name="platform-id" value="{ $conf:project-name }"/>
                              </parameters>
    (: transform document to metadata format :)
    let $transformed-object :=
                         if($verb = "ListRecords" or $verb = "GetRecord")then
                            <oai:record>
                                {(transform:transform($document, $header-xsl, $xsl-header-params),
                                 transform:transform($document, $content-xsl, $xsl-content-params))}
                             </oai:record>
                          else
                             transform:transform($document, $header-xsl, $xsl-header-params)
    return     
         $transformed-object   
};

(: search for DataProvider because of the atom- ID:)
declare function local:search-for-data-provider($atom-id as xs:string){
let $tokens := local:object-uri-tokens($atom-id)
(: define archive :)
let $archive :=
    if(count($tokens) = 3) then
       collection(xmldb:encode-uri(
            xmldb:decode(
                concat(
                conf:param('atom-db-base-uri'),
                '/metadata.archive.public/',
                $tokens[1]))))//eag:autform
    else()
(: define fond/ collection :)
let $fond := 
    if(count($tokens) = 3) then
       collection(xmldb:encode-uri(
            xmldb:decode(
                concat(
                conf:param('atom-db-base-uri'),
                '/metadata.fond.public/',
                $tokens[1],
                '/',
                $tokens[2]))))//ead:unittitle
    else
       collection(xmldb:encode-uri(
            xmldb:decode(
                concat(
                conf:param('atom-db-base-uri'),
                '/metadata.collection.public/',
                $tokens[1]))))//cei:teiHeader/cei:fileDesc/cei:titleStmt/cei:p
(: concat DataProvider informations :)
let $data-provider := if(count($tokens) = 3) then
                       concat('Archive: ', $archive/text(), ' Fond: ', $fond/text() )
                     else 
                       concat('Collection: ', $fond/text())
return
    $data-provider
};

(: search for ImageUrl because of atom- ID :)
declare function local:search-for-image-url($atom-id as xs:string){
let $tokens := local:object-uri-tokens($atom-id)
(: distinguish between fond and collection :)
let $image-url := 
    if(count($tokens) = 3) then
       concat(collection(xmldb:encode-uri(
            xmldb:decode(
                concat(
                conf:param('atom-db-base-uri'),
                '/metadata.fond.public/',
                $tokens[1],
                '/',
                $tokens[2]))))/xrx:preferences/xrx:param[@name='image-server-base-url']/text(), 
                '/')
    else
       concat(collection(xmldb:encode-uri(
              xmldb:decode(
                concat(
                conf:param('atom-db-base-uri'),
                '/metadata.collection.public/',
                $tokens[1]))))//cei:text/cei:front/cei:image_server_address,
                '/',
              collection(xmldb:encode-uri(
              xmldb:decode(
                concat(
                conf:param('atom-db-base-uri'),
                '/metadata.collection.public/',
                $tokens[1]))))//cei:text/cei:front/cei:image_server_folder,
                '/')

(: Für Europeana alle images.monasterium.net Images über IIIF schleifen:)

let $image-url := if(contains($image-url, "http://images.monasterium.net")) then
    let $rest := substring-after($image-url,"http://images.monasterium.net/")
    let $encoded := encode-for-uri($rest)
    return concat("http://images.icar-us.eu/iiif/2/", $encoded)
else $image-url


return
    $image-url
};

(: Helper- function to analyze atomID - ToDo in eXist 2.0: use charter:- functions directly!  :)
declare function local:object-uri-tokens($atom-id as xs:string) as xs:string* {
    let $object-uri := substring-after($atom-id, $platform-oai:atom-tag-name)
    let $object-uri-tokens := tokenize($object-uri, '/')
    return
    subsequence($object-uri-tokens, 3)
};

(: enable a DataProvider as archive/ fond :)
declare function platform-oai:enable-fond($overview as node()*, $fond-id as xs:string) {
    let $enabled-fond := 
            if(exists($overview//oei:fond[xmldb:encode(./text()) = $fond-id]))then
                platform-oai:update-fond($overview, $fond-id, 'enable')
            else local:add-fond($overview, $fond-id)
    return
        $enabled-fond
};

(: update a DataProvider as collection - enable/disable :)
declare function platform-oai:update-collection($element as element(), $update-value as xs:string) {
        element {node-name($element)}
      {$element/@*,
          for $child in $element/node()
              return
               if ($child instance of element())
                 then
                    if(xs:string(fn:node-name($child)) = "oei:collection")then
                        <oei:collection status="{$update-value}" id='{xs:string($child/@id)}'>
                            {
                            let $all-objects := $child//oei:harvester
                                for $object in $all-objects
                                    return
                                    platform-oai:update-collection($object, $update-value)
                            }
                        </oei:collection>
                    else
                        platform-oai:update-collection($child, $update-value)
                 else $child
      }
};

(: update a DataProvider as archive/ fond - enable/disable  :)
declare function platform-oai:update-fond($element as element(), $fond-id as xs:string, $update-value as xs:string) as element() {
    element {node-name($element)}
      {$element/@*,
          for $child in $element/node()
              return
               if ($child instance of element())
                 then
                    if(xs:string(fn:node-name($child)) = "oei:fond" and compare(xmldb:encode($child/text()), $fond-id)=0)then
                       <oei:fond status="{$update-value}">{$fond-id}</oei:fond>
                    else
                       platform-oai:update-fond($child, $fond-id, $update-value)
                 else $child
      }
};

(: add fond to DataProvider- overview :)
declare function local:add-fond($element as element(), $fond-id as xs:string) as element() {
    element {node-name($element)}
      {$element/@*,
          for $child in $element/node()
              return
               if ($child instance of element())
                 then
                    if(xs:string(fn:node-name($child)) = "oei:archive")then
                        <oei:archive id="{xs:string($child/@id)}">
                            {
                            (<oei:fond status="enable">{$fond-id}</oei:fond>,
                            let $all-objects := $child//oei:fond | $child//oei:harvester
                                for $object in $all-objects
                                    return
                                    local:add-fond($object, $fond-id))
                            }
                        </oei:archive>
                    else
                        local:add-fond($child, $fond-id)
                 else $child
      }
};

(: add harvester to DataProvider- overview :)
declare function platform-oai:add-harvester($element as element(), $context as xs:string, $harvester as xs:string) as element() {
    element {node-name($element)}
      {$element/@*,
          for $child in $element/node()
              return
               if ($child instance of element())
                 then
                    if($context = 'archive')then
                        if(xs:string(fn:node-name($child)) = "oei:archive")then
                        <oei:archive id='{xs:string($child/@id)}'>
                            {
                            (
                            let $all-objects := $child//oei:fond | $child//oei:harvester
                                for $object in $all-objects
                                    return
                                    platform-oai:add-harvester($object, $context, $harvester),
                            <oei:harvester>{$harvester}</oei:harvester>)
                            }
                         </oei:archive>
                        else
                            platform-oai:add-harvester($child, $context, $harvester)
                   else
                        if(xs:string(fn:node-name($child)) = "oei:collection")then
                        <oei:collection status='{xs:string($child/@status)}' id='{xs:string($child/@id)}'>
                            {
                            (
                            let $all-objects := $child//oei:harvester
                                for $object in $all-objects
                                    return
                                    platform-oai:add-harvester($object, $context, $harvester),
                            <oei:harvester>{$harvester}</oei:harvester>)
                            }
                         </oei:collection>
                        else
                            platform-oai:add-harvester($child, $context, $harvester)
                 else $child
      }
};

(: remove harvester to DataProvider- overview :)
declare function platform-oai:remove-harvester($element as element(), $harvester as xs:string) as element() {
    element {node-name($element)}
      {$element/@*,
          for $child in $element/node()
              return
               if ($child instance of element())
                 then
                    if(xs:string(fn:node-name($child)) = "oei:harvester" and compare(xmldb:encode($child/text()), $harvester)=0)then
                        ()
                    else
                        platform-oai:remove-harvester($child, $harvester)
               else $child
      }
};

(: check for enabled fonds of archive :)
declare function platform-oai:check-provider($element as element()) as xs:string {
    let $response := 
                    if(count($element//oei:fond[@status = 'enable'])>0)then
                        xs:string('true')
                    else
                        xs:string('false')    
    return
        $response
};

(: check for enabled fonds of archive :)
declare function platform-oai:check-harvester($element as element()) {
    let $response := 
                    if(count($element//oei:harvester)>0)then
                       true()
                    else
                       false()   
    return
        $response
};

(: define context of request- URL - archive, collection or error :)
declare function platform-oai:get-context($object-id as xs:string) as xs:string {
    let $archive-or-collection := 
            if(exists(doc(concat(conf:param('data-db-base-uri'), 'metadata.archive.public/', $object-id, '/oai.xml'))//oei:archive))then
                if(exists(doc(concat(conf:param('data-db-base-uri'), 'metadata.archive.public/', $object-id, '/oai.xml'))//oei:archive[xmldb:encode(string(./@id)) = $object-id]/oei:fond[./@status = 'enable']))then
                  xs:string('archive')
                else
                  xs:string('noMatch')
            else if(exists(doc(concat(conf:param('data-db-base-uri'), 'metadata.collection.public/', $object-id, '/oai.xml'))//oei:collection))then
                if(exists(doc(concat(conf:param('data-db-base-uri'), 'metadata.collection.public/', $object-id, '/oai.xml'))//oei:collection[xmldb:encode(string(./@id)) = $object-id][./@status = 'enable']))then
                  xs:string('collection')
                 else
                  xs:string('noMatch')
            else    
                xs:string('noMatch')
    return
        $archive-or-collection
};

(: get all enabled fonds of an archive :)
declare function platform-oai:get-fonds($overview as node()*, $object-id as xs:string) {
    let $fonds := $overview//oei:archive[xmldb:encode(string(./@id)) = $object-id]//oei:fond[@status = 'enable']/text()
    for $fond-encoded in $fonds
        return
            xmldb:encode($fond-encoded)
};

(: create the oai- file of an archive :)
declare function platform-oai:create-file($object-id as xs:string, $context as xs:string) {
     <atom:entry>
        <atom:id>tag:www.monasterium.net,2011:/oai/DataProvider/{$object-id}</atom:id>
        <atom:title/>
        <atom:published>{ current-dateTime() }</atom:published>
        <atom:updated></atom:updated>
        <atom:author>
            <atom:email></atom:email>
        </atom:author>
        <app:control xmlns:app="http://www.w3.org/2007/app">
            <app:draft>no</app:draft>
        </app:control>
        <atom:content type="application/xml">
            <oei:oei xmlns:oei="http://www.monasterium.net/NS/oei">
                <oei:DataProvider>
                    {
                    if($context = 'archive')then
                        <oei:archive id="{ $object-id }">
                        </oei:archive>
                    else
                        <oei:collection status="enable" id="{ $object-id }">
                        </oei:collection>
                    }
                </oei:DataProvider>
            </oei:oei>
        </atom:content>
    </atom:entry>
};

(: if archive/fond has not been released yet and a user is trying to request data, a error message will be shown :)
declare function platform-oai:error-message($base-url as xs:string) {
    let $message :=
                (: OAI- PMH informations - have to be defined:)
                <OAI_PMH xmlns="http://www.openarchives.org/OAI/2.0/" 
                     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                     xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/
                     http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">
                <responseDate>{current-dateTime()}</responseDate>
                <request> {(for $parameter in request:get-parameter-names()
                            return
                                attribute {$parameter}{request:get-parameter(string($parameter),0)})
                            ,$base-url}</request>
                 <error code="noRecordsMatch">Base- URL has not been released yet! Please check your URL or contact the metadata manager of the archive!</error>
                 </OAI_PMH> 
        return
            $message
};
