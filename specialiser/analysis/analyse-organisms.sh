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
RESULTS="organisms"

# Generate timestep column
seq 0 $BINSIZE $ITERATIONS > ${RESULTS}.counts
seq 0 $BINSIZE $ITERATIONS > ${RESULTS}.sizes
seq 0 $BINSIZE $ITERATIONS > ${RESULTS}.stddev
echo "#born age" > organisms.lives

# Temp file for paste results
PASTE_BUFFER=`mktemp`
ORGAN_BUFFER=`mktemp`

# Collect data
for f in *.organism-sizes.log.bz2 
do
    echo "Analysing $f ..."
    
    # Count how many there are per time step
    bzcat $f | tail -n +2 | python3 ${SCRIPT_DIR}/process_organism-sizes.py ${BINSIZE} ${ITERATIONS} counts > ${ORGAN_BUFFER}
    awk '{print $2}' ${ORGAN_BUFFER} | paste ${RESULTS}.counts - > ${PASTE_BUFFER}
    mv ${PASTE_BUFFER} ${RESULTS}.counts
    
    bzcat $f | tail -n +2 | python3 ${SCRIPT_DIR}/process_organism-sizes.py ${BINSIZE} ${ITERATIONS} sizes > ${ORGAN_BUFFER}
    awk '{print $2}' ${ORGAN_BUFFER} | paste ${RESULTS}.sizes - > ${PASTE_BUFFER}
    mv ${PASTE_BUFFER} ${RESULTS}.sizes

    bzcat $f | tail -n +2 | python3 ${SCRIPT_DIR}/process_organism-sizes.py ${BINSIZE} ${ITERATIONS} stddev > ${ORGAN_BUFFER}
    awk '{print $2}' ${ORGAN_BUFFER} | paste ${RESULTS}.stddev - > ${PASTE_BUFFER}
    mv ${PASTE_BUFFER} ${RESULTS}.stddev

done

# Summarise puck counts
awk -v skip=1 -v prepend=true -f ${SCRIPT_DIR}/moments-per-line.awk $RESULTS.counts > ${RESULTS}.counts.stats
awk -v skip=1 -v prepend=true -f ${SCRIPT_DIR}/moments-per-line.awk $RESULTS.sizes > ${RESULTS}.sizes.stats
awk -v skip=1 -v prepend=true -f ${SCRIPT_DIR}/moments-per-line.awk $RESULTS.stddev > ${RESULTS}.stddev.stats

# add average mean to sizes.stats
cat ${RESULTS}.stddev.stats | awk '{$6 = ($6 == "mean" ? "std_dev_mean" : $6)} 1' | awk '{print $6}' | paste ${RESULTS}.sizes.stats - > ${PASTE_BUFFER}
mv ${PASTE_BUFFER} ${RESULTS}.sizes.stats
rm ${RESULTS}.stddev ${RESULTS}.stddev.stats


# Get time lived per organism
for f in *.organisms.log.bz2
do
    bzcat $f | awk '{print $4" "$6- $4}' >> ${RESULTS}.lives
done
