#!/bin/bash


set -x # Uncomment to Debug

# The build.sh script pulls the latest checksum from Instruqt.
instruqt track pull  
checksum=$(cat track.yml | grep checksum | awk '{print $2}')
echo $checksum
# The latest checksum is replaced in the Readme.md
sed  -i ''  "s/.*checksum:.*/checksum: ${checksum}/" Readme.md

# All of the files in the Readme are tangled multiple instruqt files.
/usr/local/bin/md-tangle --force Readme.md

# The track is then pushed to Instruqt
instruqt track push
