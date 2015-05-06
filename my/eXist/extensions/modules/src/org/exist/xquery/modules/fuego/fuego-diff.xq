xquery version "3.0";

import module namespace fuego="https://github.com/ept/fuego-diff";

let $base-version := <test><a/><b/><c/><e/></test>
let $modified-version := <test><f/></test>
let $parameters :=
  <parameters>
    <param name="test1" value="test1"/>
    <param name="test2" value="test2"/>
  </parameters>
return
  fuego:diff($base-version, $modified-version, 'xml', $parameters, true())