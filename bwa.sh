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
#SBATCH --time=05:00:00
#SBATCH --ntasks=1
#SBATCH --mem=15GB
#SBATCH --output=logs/slurm/bwa_%A_%a.out


#------------------------project variables----------------------#
IN_DIR=${BIG}/data
OUT_DIR=${BIG}/analysis/${REF%.*}/bwa

#---------------------------------------------------------------#

module add bwa/0.7.17

# run bwa on all fastq files

mkdir -p $OUT_DIR

IN_LIST=( $(tail -n +2 ${METADATA} | cut -f 1 | sed "s/_R[12].*//" | sort -u) );

if [ ! -z "$SLURM_ARRAY_TASK_ID" ]
    then
	    STEM=${IN_LIST["$SLURM_ARRAY_TASK_ID"]}
	    SAMPLE=`grep "${STEM}*${READ_ONE}" $METADATA | cut -f2`
            INDEX=`grep "${STEM}*${READ_ONE}" $METADATA | cut -f3`
	    DATE=`grep "${STEM}*${READ_ONE}" $METADATA | cut -f4`
            PLATFORM=`grep "${STEM}*${READ_ONE}" $METADATA | cut -f10`
            LIBRARY="${SAMPLE}.${INDEX}.${DATE}"
	    CENTRE=`grep "${STEM}*${READ_ONE}" $METADATA | cut -f8`
	    SEQDATE=`grep "${STEM}*${READ_ONE}" $METADATA | cut -f9`
	    UNIT=`gzip -cd ${IN_DIR}/${STEM}*fastq.gz | head -1 | cut -d':' -f${UNIT_RX}` 
	    ID=`echo ${UNIT}.${INDEX} | sed s/:/./g`
	    echo "@RG\tID:${ID}\tCN:${CENTRE}\t"` \
	           `"DT:${SEQDATE}\tLB:${LIBRARY}\t"` \
	           `"PL:${PLATFORM}\tPU:${UNIT}\tSM:${SAMPLE}" > $OUT_DIR/${STEM}.log
	    if [ ! -f ${OUT_DIR}/${STEM}.sam ]
	    then
	        CMD="bwa mem ${IN_DIR}/${REF%.*} ${IN_DIR}/${STEM}*.fastq.gz"` \
	            `" -t 1"` \
	            `" -k $SEED"` \
                    `" -U $UNPAIRED"` \
	            `" -w $WIDTH"` \
	            `" -r $INTERNAL"` \
	            `" -T $SCORE"` \
	            `" -M"` \
	            `" -R @RG\tID:${ID}\tCN:${CENTRE}\tDT:${SEQDATE}\tLB:${LIBRARY}\tPL:${PLATFORM}\tPU:${UNIT}\tSM:${SAMPLE}" 
		echo -e "$CMD" >> $OUT_DIR/${STEM}.log
		${CMD} > ${OUT_DIR}/${STEM}.sam 2>> $OUT_DIR/${STEM}.log
	    fi
    else
        echo "Error: Missing array index as SLURM_ARRAY_TASK_ID"
fi

mv ${BIG}/logs/slurm/bwa_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.out $BIG/logs/${TODAY}_bwa_slurm/


