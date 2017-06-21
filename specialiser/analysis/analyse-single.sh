#!/bin/bash
DIR="$(echo `readlink -fn $0` | sed 's/ /\\ /g')"
SCRIPT_DIR=`dirname "$DIR"`


if [[ `pwd` != *"logs"* ]];then
    echo "are you in a logs (sub) folder?"
    exit 1
fi


FULLCOMMAND="$0 $@"
. ${SCRIPT_DIR}/../lib/shflags

#define the flags
DEFINE_string 'iterations' '1000000' 'Number of iterations' 'i'

# Parse the flags
FLAGS "$@" || exit 1
eval set -- "${FLAGS_ARGV}"


echo counts
bash "${SCRIPT_DIR}/counts.sh" --iterations ${FLAGS_iterations}

echo pucks
bash "${SCRIPT_DIR}/pucks.sh"

echo count-offspring
bash "${SCRIPT_DIR}/count-offspring.sh"

echo analyse-pressure
bash "${SCRIPT_DIR}/analyse-pressure.sh"

echo ages
bash "${SCRIPT_DIR}/ages.sh"

echo pucks-vs-age
bash "${SCRIPT_DIR}/pucks-vs-age.sh"

# echo calc_ratios
# bash ${SCRIPT_DIR}/calc_ratios.sh --iterations ${FLAGS_iterations}

bash "${SCRIPT_DIR}/count-inseminations.sh" --iterations ${FLAGS_iterations}

echo plot plot-pucks-ratio
gnuplot "${SCRIPT_DIR}/plot-pucks-ratio"

echo plot plot-pucks-counts
gnuplot "${SCRIPT_DIR}/plot-pucks-counts"
gnuplot "${SCRIPT_DIR}/plot-pucks-counts-total"

echo plot plot-histograms
gnuplot -e "set terminal pngcairo enhanced font 'Helvetica,11' size 1024, 1024;set output 'greenratio-histogram.png'" "${SCRIPT_DIR}/plot-histograms.gpl"

echo plot plot-hexbin-puckcounts
awk '999000 < $1 {print $3,$4}' *.collected | gnuplot -e "set output 'hexbin-puckcounts.png'" "${SCRIPT_DIR}/plot-hexbin-puckcounts.gnuplot"

echo plot-inseminations
gnuplot "${SCRIPT_DIR}/plot-inseminations"

# for i in *png
# do 
#   DEST=`readlink -f $i | sed 's|'${SCRIPT_DIR}'/||' | sed -e 's/\//./g'`
#   cp $i ${SCRIPT_DIR}/summary/${DEST}
# done
