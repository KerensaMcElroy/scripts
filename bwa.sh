#!/bin/bash

#***************************************************************#
#                            bwa.sh                             #
#                  written by Kerensa McElroy                   #
#                         April 6, 2018                         #
#                                                               #
#                 align trimmed reads with bwa                  #
#***************************************************************#

#--------------------------sbatch header------------------------#

#SBATCH --job-name=bwa
#SBATCH --time=02:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12
#SBATCH --mem=2GB
#SBATCH --output=logs/slurm/bwa_%A_%a.out


#------------------------project variables----------------------#
IN_DIR=${BIG}/data
OUT_DIR=${BIG}/analysis/trim
ADAPTERS=~/adapters

#---------------------------------------------------------------#

module add bwa

bwa | head -5 >> logs/${TODAY}_main.log
echo '' >> logs/${TODAY}_main.log

mkdir -p $OUT_DIR

IN_LIST=( $(cut -f 1 ${METADATA} | sed "s/_R[12].*//" | sort -u) );

if [ ! -z "$SLURM_ARRAY_TASK_ID" ]
    then
	    STEM=${IN_LIST["$SLURM_ARRAY_TASK_ID"]}
	    SAMPLE=`grep "${STEM}*${READ_ONE}" $METADATA | cut -f2`
	    SPECIES=`grep "${STEM}*${READ_ONE}" $METADATA | cut -f6`
	    LIBRARY=`grep "${STEM}*${READ_ONE}" $METADATA | cut -f3`
	    CENTRE=`grep "${STEM}*${READ_ONE}" $METADATA | cut -f4`
	    SEQDATE=`grep "${STEM}*${READ_ONE}" $METADATA | cut -f5`
	    UNIT=`gzip -cd $WORK/data/$PROJECT/$file | head -1 | cut -d':' -f${UNIT_RX}` 
	    ID=`echo ${UNIT:1}_${SAMPLE}_${SPECIES} | sed s/:/_/g`
	    echo "@RG\tID:${ID}\tCN:${CENTRE}\t"` \
	           `"DT:${SEQDATE}\tLB:${SAMPLE}_${LIBRARY}\t"` \
	           `"PL:${PLATFORM}\tPU:${UNIT:1}\tSM:${SAMPLE}" > $OUT_DIR/${STEM}.log
	    if [ ! -f ${OUT_DIR}/${STEM}.sam ]
	    then
	        bwa mem $WORK/data/$PROJECT/${REF%.*} ${IN_DIR}${STEM}*p.fq.gz \
	            -t $THREADS \
	            -k $SEED \
	            -w $WIDTH \
	            -r $INTERNAL \
	            -T $SCORE \
	            -M \
	            -R "@RG\tID:${ID}\tCN:${CENTRE}\tDT:${SEQDATE}\tLB:${SAMPLE}_${LIBRARY}\tPL:${PLATFORM}\tPU:${UNIT:1}\tSM:${SAMPLE}" > ${OUT_DIR}/${STEM}.sam 2>> $OUT_DIR/${STEM}.log
	    fi
    else
        echo "Error: Missing array index as SLURM_ARRAY_TASK_ID"
fi

mv ${BIG}/logs/slurm/bwa_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.out $BIG/logs/${TODAY}_bwa_slurm/


