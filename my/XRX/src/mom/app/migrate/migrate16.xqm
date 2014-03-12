xquery version "3.0";

module namespace migrate16="http://www.monasterium.net/NS/migrate16";

declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace cei="http://www.monasterium.net/NS/cei";

declare function migrate16:transform($meta-xml as element(atom:entry)) as element() {

    let $image-base-url := 
        concat('http://', $meta-xml//cei:image_server_address/text(), '/', $meta-xml//cei:image_server_folder/text())
    let $fondid :=
        $meta-xml//cei:provenance/@pid/string()
    let $fondname :=
        $meta-xml//cei:provenance/text()
    let $preface :=
        util:parse-html($meta-xml//cei:div[@type='preface']/node())
    let $preface-as-text := 
        string-join(
            $preface//text(),
            ' '
        )
    return
    <atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
        <atom:id/>
        <atom:title/>
        <atom:published/>
        <atom:updated/>
        <atom:author>
            <atom:email/>
        </atom:author>
        <app:control xmlns:app="http://www.w3.org/2007/app">
            <app:draft>no</app:draft>
        </app:control>
        <atom:content type="application/xml">
            <ead:ead xmlns:ead="urn:isbn:1-931666-22-9">
                <ead:eadheader>
                    <ead:eadid />
                    <ead:filedesc>
                        <ead:titlestmt>
                            <ead:titleproper/>
                            <ead:author/>
                        </ead:titlestmt>
                    </ead:filedesc>
                </ead:eadheader>
                <ead:archdesc level="otherlevel">
                    <ead:did>
                        <ead:abstract/>
                    </ead:did>
                    <ead:dsc>
                        <ead:c level="fonds" xml:base="{ $image-base-url }">
                            <ead:did>
                                <ead:unitid identifier="{ $fondid }" />
                                <ead:unittitle>{ $fondname }</ead:unittitle>
                            </ead:did>
                            <ead:bioghist>
                                <ead:head/>
                                <ead:p/>
                            </ead:bioghist>
                            <ead:custodhist>
                                <ead:head/>
                                <ead:p/>
                            </ead:custodhist>
                            <ead:bibliography>
                                <ead:bibref />
                            </ead:bibliography>
                            <ead:odd>
                                <ead:head/>
                                <ead:p>{ $preface-as-text }</ead:p>
                            </ead:odd>
                        </ead:c>
                    </ead:dsc>
                </ead:archdesc>
            </ead:ead>
        </atom:content>
    </atom:entry>
};