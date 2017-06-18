SCRIPT=`realpath -s $0`
SCRIPTPATH=`dirname $SCRIPT`
BASEDIR=$SCRIPTPATH/..

NUM_CORES=`nproc --all` # get number of cores

base_params="${SCRIPTPATH}/monee.sh --seed 0 --basedir ${BASEDIR} --templatedir ${BASEDIR}/template/ --iterations 1000000"
exp_params="--useSpecialiser true --spawnProtection true --spawnProtectDuration 120"

simulations[0]="${base_params}" #standard run

simulations[1]="${base_params} ${exp_params} --stealMargin 20 --stealAmount 40 --specialiserLifeCap 2000"
simulations[2]="${base_params} ${exp_params} --stealMargin 20 --stealAmount 40 --specialiserLifeCap 3000"
simulations[3]="${base_params} ${exp_params} --stealMargin 20 --stealAmount 40 --specialiserLifeCap 5000"

simulations[4]="${base_params} ${exp_params} --stealMargin 20 --stealAmount 40 --specialiserLifeCap 2000"
simulations[5]="${base_params} ${exp_params} --stealMargin 40 --stealAmount 40 --specialiserLifeCap 2000"
simulations[6]="${base_params} ${exp_params} --stealMargin 80 --stealAmount 40 --specialiserLifeCap 2000"

simulations[7]="${base_params} ${exp_params} --stealMargin 20 --stealAmount 40 --specialiserLifeCap 2000"
simulations[8]="${base_params} ${exp_params} --stealMargin 20 --stealAmount 80 --specialiserLifeCap 2000"
simulations[9]="${base_params} ${exp_params} --stealMargin 20 --stealAmount 120 --specialiserLifeCap 2000"

mkdir -p ${BASEDIR}/logs
rm -f ${BASEDIR}/logs/finished.progress
touch ${BASEDIR}/logs/running.progress

# Run the above determined jobs on the available cores using parallel:
parallel --progress --eta --bar --joblog ${BASEDIR}/logs/parallel_job_log_`date "+%Y%m%d.%Hh%Mm%Ss"` -j ${NUM_CORES} ::: "${simulations[@]}" ::: `seq 15`

mv ${BASEDIR}/logs/running.progress ${BASEDIR}/logs/finished.progress