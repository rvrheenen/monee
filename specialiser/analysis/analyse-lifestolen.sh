#!/bin/bash

DIR="$(echo `readlink -fn $0` | sed 's/ /\\ /g')"
SCRIPT_DIR=`dirname "$DIR"`

FULLCOMMAND="$0 $@"
. ${SCRIPT_DIR}/../lib/shflags

#define the flags
DEFINE_string 'iterations' '1000000' 'Number of iterations' 'i'

# Parse the flags
FLAGS "$@" || exit 1
eval set -- "${FLAGS_ARGV}"

BINSIZE=1000
ITERATIONS=${FLAGS_iterations}

# Output file
RESULTS="lifestolen"

# Generate timestep column
seq 0 $BINSIZE $ITERATIONS > ${RESULTS}.counts
echo "#born age" > organisms.lives

# Temp file for paste results
PASTE_BUFFER=`mktemp`
ORGAN_BUFFER=`mktemp`

# Collect data
for f in *.lifestolen 
do
    echo "Analysing $f ..."
    
    # Count how many there are per time step
    cat $f | python3 ${SCRIPT_DIR}/process_lifestolen.py ${BINSIZE} ${ITERATIONS} counts > ${ORGAN_BUFFER}
    awk '{print $2}' ${ORGAN_BUFFER} | paste ${RESULTS}.counts - > ${PASTE_BUFFER}
    mv ${PASTE_BUFFER} ${RESULTS}.counts
    
done

# Summarise puck counts
awk -v skip=1 -v prepend=true -f ${SCRIPT_DIR}/moments-per-line.awk $RESULTS.counts > ${RESULTS}.counts.stats
