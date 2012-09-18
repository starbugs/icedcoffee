#!/bin/bash

bdocs_path=~/Projects/beautifuldocs
bdocs_bin="ruby bdocs.rb"
ios_doc_conf=doc-ios.bdocs.config.json
osx_doc_conf=doc-osx.bdocs.config.json
script_pwd=${PWD}

pushd $bdocs_path
$bdocs_bin -c $script_pwd/../$ios_doc_conf
$bdocs_bin -c $script_pwd/../$osx_doc_conf
popd