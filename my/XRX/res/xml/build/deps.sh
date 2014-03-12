#!/bin/bash

echo "###################################"
echo "#                                 #"
echo "# Update XPath Dependency File    #"
echo "#                                 #"
echo "###################################"
cd src
../lib/closure-library/closure/bin/build/depswriter.py --root_with_prefix=". ../../../../src" > deps.js
cd ..

