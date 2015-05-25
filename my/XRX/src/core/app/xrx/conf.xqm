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

module namespace conf="http://www.monasterium.net/NS/conf";

declare namespace xrx="http://www.monasterium.net/NS/xrx";
declare namespace exist="http://exist.sourceforge.net/NS/exist";

declare variable $conf:project-name := /xrx:conf/xrx:param[@name='project-name'][1]/string();
declare variable $conf:xrx-live-collection-name := /xrx:conf/xrx:param[@name='xrx-live-collection-name'][1]/string();
declare variable $conf:db-base-collection-path := concat('/db/', $conf:xrx-live-collection-name, '/', $conf:project-name);
declare variable $conf:db-base-collection := collection($conf:db-base-collection-path);

(:
    configuration files of all projects
    found in the database
:)
declare variable $conf:conf := 
    $conf:db-base-collection//xrx:conf;

(:
    function which returns a parameter
    value by its name
:)
declare function conf:param($name as xs:string) {

    let $param := $conf:conf//xrx:param[@name=$name]
    return
    if($param/*) then $param/*
    else $param/text()
};