#/bin/bash

# remove ppn, less than 5 min time: test node
# Settings of PBS (do NOT uncomment these lines)
#--------------------------------------------------------------------------------------------------#
#PBS -lnodes=1
#PBS -lwalltime=00:04:59
#--------------------------------------------------------------------------------------------------#

DIR="$(echo `readlink -fn $0` | sed 's/ /\\ /g')"
SCRIPT_DIR=`dirname "$DIR"`

FULLCOMMAND="$0 $@"
. ${SCRIPT_DIR}/../lib/shflags

BASEDIR=$HOME/monee/results

awk -v col=3 -f ${SCRIPT_DIR}/pucks-vs-age.awk *.pressure-stats | sort -n -k 1 | awk -v skip=1 -v prepend=true -f ${SCRIPT_DIR}/moments-per-line.awk > pucks-vs-age.0
awk -v col=4 -f ${SCRIPT_DIR}/pucks-vs-age.awk *.pressure-stats | sort -n -k 1 | awk -v skip=1 -v prepend=true -f ${SCRIPT_DIR}/moments-per-line.awk > pucks-vs-age.1

# for i in $@
# do
#   pushd $i
#   (
#     awk -v col=3 -f ${SCRIPT_DIR}/pucks-vs-age.awk *.pressure-stats | sort -n -k 1 | awk -v skip=1 -v prepend=true -f ${SCRIPT_DIR}/awk/moments-per-line.awk > pucks-vs-age.0
#     awk -v col=4 -f ${SCRIPT_DIR}/pucks-vs-age.awk *.pressure-stats | sort -n -k 1 | awk -v skip=1 -v prepend=true -f ${SCRIPT_DIR}/awk/moments-per-line.awk > pucks-vs-age.1
#   )&
 	
#   popd
# done

# wait
