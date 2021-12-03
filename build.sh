#!/bin/bash
set -x # Uncomment to Debug

instruqt track pull  
checksum=$(cat track.yml | grep checksum | awk '{print $2}')
echo $checksum
/usr/local/bin/md-tangle --force Readme.md
sed  -i ''  "s/.*checksum:.*/checksum: ${checksum}/" Readme.md
instruqt track push
