#!/bin/bash

# create tmp directory
mkdir tmp
mkdir lib

# echo "###################################"
# echo "#                                 #"
# echo "# Install Closure Library         #"
# echo "#                                 #"
# echo "###################################"
# rm -rf closure-library
# cd tmp
# wget https://closure-library.googlecode.com/files/closure-library-20130212-95c19e7f0f5f.zip
# cd ..
# unzip ./tmp/closure-library-20130212-95c19e7f0f5f.zip -d ./closure-library/

# echo "###################################"
# echo "#                                 #"
# echo "# Install CodeMirror              #"
# echo "#                                 #"
# echo "###################################"
# rm -rf ./lib/codemirror
# cd tmp
# wget http://codemirror.net/codemirror.zip
# cd ..
# unzip ./tmp/codemirror.zip -d ./lib/


# echo "###################################"
# echo "#                                 #"
# echo "# Install XQuery Testsuite        #"
# echo "#                                 #"
# echo "###################################"
# cd tmp
# wget http://dev.w3.org/2011/QT3-test-suite/releases/QT3_1_0.zip
# cd ..
# rm -rf QT3_1_0
# unzip ./tmp/QT3_1_0.zip


# echo "###################################"
# echo "#                                 #"
# echo "# Install Closure Linter          #"
# echo "#                                 #"
# echo "###################################"
# cd tmp
# sudo easy_install http://closure-linter.googlecode.com/files/closure_linter-latest.tar.gz
# cd ..



# remove temporary files
rm -rf tmp


