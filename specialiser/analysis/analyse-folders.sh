for d in `ls -d */` 
do
    echo "handeling $d"
    ( cd $d && ../../specialiser/analysis/analyse-single.sh )
done
