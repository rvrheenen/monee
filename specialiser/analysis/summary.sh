#!/bin/bash

# Extracts all the useful stuff out of the subfolders in the logs folder.
# Run in logs folder, assumes all log files are split into seperate subfolders

if [[ "`pwd`" != *logs ]]; then
    echo "ERROR script must be run in the logs folder."
    exit 1
fi

mkdir -p summary # make sure summary folder exists.

for d in `ls -d */ -I summary | grep -v summary` 
do
    echo "handeling ${d%/}"
    (
        cd $d && 
        for f in `find * -size +0 -type f -iname "*.png" -o -iname "*.stats" | grep -v \* | grep -vE '[0-9]{5}'`
        do
            cp "${f}" "../summary/${d%/}_$f"
        done
    )
done