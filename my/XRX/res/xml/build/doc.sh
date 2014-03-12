#!/bin/bash

echo "###################################"
echo "#                                 #"
echo "# Generate JavaScript Doc         #"
echo "#                                 #"
echo "###################################"

# sudo apt-get install jsdoc-toolkit
jsdoc -r -d=./doc ./src

echo "done"

