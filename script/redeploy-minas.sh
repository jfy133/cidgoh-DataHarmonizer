#!/usr/bin/env bash

## Author: James Fellows Yates (@jfy133)
## License: CC0 1.0 Universal (CC0 1.0) Public Domain Dedication
## Description: This script does a quick deploy of the MInAS variant of DataHarmonizer .
## It assumes you are already in an environment with all necessary dependencies installed.

##  - yarn (with corepack configured)

##
## It also assumes you have the MInAS DataHarmonizer repository cloned and are in the root directory of that repository.

# USAGE: bash ./script/redeploy-minas.sh

## Remove old files
rm -r docs/{dist-schemas/,images/,scripts/,templates/,index.html,main.html}

## Build
yarn build:web
cp -r web/dist/* docs/
cp -r web/templates/mixs-minas/schema.yml docs/templates/mixs-minas/schema.yml

##
echo '[redeploy-minas.sh] LOG: Done! Please commit and push!'
