#!/bin/bash

#***************************************************************#
#                            fastqc.sh                          #
#                  written by Kerensa McElroy                   #
#                         January 31, 2018                      #
#                                                               #
#             runs fastqc on gzipped raw data files             #
#***************************************************************#

#--------------------------sbatch header------------------------#


#------------------------project variables----------------------#
cd ~/working
export WORK=`pwd -P`
export INDIR=$WORK/data/$PROJECT
export OUTDIR=$WORK/analysis/$PROJECT/fastqc

#---------------------------------------------------------------#

module add fastqc

mkdir -p $OUTDIR

IN_FILE_LIST = ( $(cut -s -f 1 ${METADATA}))
IN_SAMP_LIST = ( $(cut -s -f 2 ${METADATA}))

if [ ! -z "$SLURM_ARRAY_TASK_ID" ]
    then
        i=$SLURM_ARRAY_TASK_ID
        CMD='fastqc ${IN_FILE_LIST[$i]} --noextract -f fastq -o ${OUTDIR} dosomething --input=${INFILES[$i]} --output=${SAMPLES[$i]}.result.txt
    else
        echo "Error: Missing array index as SLURM_ARRAY_TASK_ID"
fi

cat ~/scripts/fastqc.sh >> ~/$PROJECT/logs/main_${TODAY}.log

fastqc -v >> ~/$PROJECT/logs/main_${TODAY}.log

function run_fastqc {
    file=$1
    CMD="fastqc $file --noextract -f fastq -o $OUTDIR"
    echo -e "\n$CMD" >> ~/${PROJECT}/logs/main_$TODAY.log
    $CMD
}

export -f run_fastqc

ls ${INDIR}/${IN_PATH}/${SUBSET}*${EXT} | parallel -j ${CORES} run_fastqc
