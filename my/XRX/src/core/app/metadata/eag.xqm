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

module namespace eag="http://www.archivgut-online.de/eag";

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../conf/conf.xqm";

declare variable $eag:db-base-uri := '/metadata.archive/';

(:
    get all EAG documents by handing over
    a country code
    
    @param countrycode
    @param the metadata scope (e.g. draft, public, private)
    @param obligatory configuration file
    @return 0 - n EAG root elements
:)
declare function eag:documents-by-country($countrycode as xs:string, $metadata-scope) as element()* {
  
    for $autform in $metadata-scope//eag:autform[root(.)//eag:repositorid[@countrycode=$countrycode]]
    order by $autform collation "?lang=de"
    return
    $autform/ancestor::eag:eag
};


(:
    get all EAG documents by handing over
    a region code
    
    @param regioncode
    @param the metadata scope (e.g. draft, public, private)
    @param obligatory configuration file
    @return 0 - n EAG root elements
:)
declare function eag:documents-by-region($regioncode as xs:string, $metadata-scope) as element()* {

    for $firstdem in $metadata-scope//eag:firstdem[.=$regioncode]
    order by $firstdem collation "?lang=de"
    return
    $firstdem/ancestor::eag:eag    
};