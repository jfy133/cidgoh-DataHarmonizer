#!/usr/bin/env bash

## Author: James Fellows Yates (@jfy133)
## License: CC0 1.0 Universal (CC0 1.0) Public Domain Dedication
## Description: This script does a quick re-generation of MInAS DataHarmonizer files.
## It assumes you are already in an environment with all necessary dependencies installed.
##  - curl
##  - yarn (with corepack configured)
##  - linkml
##  - linkml-toolkit
##
## It also assumes you have the MInAS DataHarmonizer repository cloned and are in the root directory of that repository.

# USAGE: bash ./script/regenerate-minas.sh <minas_version, e.g. 0.7.0>

## Input
minas_ver=$1
workdir=$(pwd)

echo '[regenerate-minas.sh] LOG: Cleaning up old version.'
rm -r web/templates/menu.json
rm -r web/templates/mixs-minas/mixs-minas.yaml
rm -r web/templates/mixs-minas/schema.yml
rm -r web/templates/mixs-minas/schema.json

echo '[regenerate-minas.sh] LOG: Downloading requested version of MInAS schema.'
curl -o $workdir/web/templates/mixs-minas/mixs-minas.yaml "https://raw.githubusercontent.com/MIxS-MInAS/MInAS/refs/tags/v$minas_ver/src/mixs/schema/mixs-minas.yaml"

echo '[regenerate-minas.sh] LOG: Subsetting to MInAS combinations, and making DH compatible.'
minas_combs=$(grep 'Ancient:' "$workdir"/web/templates/mixs-minas/mixs-minas.yaml | sed 's/://g' | xargs | tr ' ' ',')
lmtk subset --schema "$workdir"/web/templates/mixs-minas/mixs-minas.yaml --output "$workdir"/web/templates/mixs-minas/schema.yml --classes MixsCompliantData,"$minas_combs"
sed -i '/^classes:/r dh_class_text.txt' "$workdir/web/templates/mixs-minas/schema.yml"

## Generate the DataHarmonizer JSON version
echo '[regenerate-minas.sh] LOG: Generating DataHarmonizer JSON from LinkML schema, and updating menu.json.'
cd "$workdir"/web/templates/mixs-minas/ || exit
python ../../../script/linkml.py -i $workdir/web/templates/mixs-minas/schema.yml -m mixs-minas
sed -i "/[a-zA-Z]Ancient\"\,/{N;N;s/false/true/g}" ../menu.json
cd "$workdir" || exit

## Bump versions
echo '[regenerate-minas.sh] LOG: Bumping version numbers in index.html.'
sed -i "s/MInAS version: [0-9].[0-9].[0-9]/MInAS version: $minas_ver/g" web/index.html

echo '[regenerate-minas.sh] LOG: Done! Remove non-Ancient templates from menu.json, then test with `yarn dev`'
