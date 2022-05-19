#!/bin/bash

#***************************************************************#
#                            picard.sh                          #
#                  written by Kerensa McElroy                   #
#                          May 17, 2018                         #
#                                                               #
#            analyse alignment quality using picard             #
#***************************************************************#

#--------------------------sbatch header------------------------#

#SBATCH --job-name=picard
#SBATCH --time=01:00:00
#SBATCH --ntasks=1
#SBATCH --mem=16GB
#SBATCH --output=logs/slurm/picard_%A_%a.out


#------------------------project variables----------------------#
IN_DIR=${BIG}/analysis/${REF%.*}/bwa
OUT_DIR=${IN_DIR}/picard

#---------------------------------------------------------------#

module add picard/2.9.2 
module add samtools/0.1.19

MeanQualityByCycle --version logs/${TODAY}_main.log

IN_LIST=( $(tail -n +2 ${METADATA} | cut -f 1 | sed "s/_R[12].*//" | sort -u) );

mkdir -p ${OUT_DIR}

if [ ! -z "$SLURM_ARRAY_TASK_ID" ]
    then
     STEM=${IN_LIST["$SLURM_ARRAY_TASK_ID"]}
     java -jar -Xmx15g /apps/picard/2.9.2/picard.jar MeanQualityByCycle \
        VALIDATION_STRINGENCY=$VALIDATION \
        R=$REF \
        INPUT=$IN_DIR/${STEM}.bam \
        OUTPUT=$OUT_DIR/${STEM}_MQBC.txt \
        CHART_OUTPUT=$OUT_DIR/${STEM}_MQBC.pdf \
        TMP_DIR=/OSM/CBR/NRCA_FINCHGENOM/temp/picard.temp \
        MAX_RECORDS_IN_RAM=$MAX_REC 2> ${OUT_DIR}/${STEM}_MQBC.log
    wait

     java -jar -Xmx15g /apps/picard/2.9.2/picard.jar CollectAlignmentSummaryMetrics \
         VALIDATION_STRINGENCY=SILENT \
         MAX_RECORDS_IN_RAM=5000000 \
         R=${BIG}/data/${REF%.*} \
         INPUT=$IN_DIR/${STEM}_fixmate_sort.bam \
         OUTPUT=$OUT_DIR/${STEM}_CASM.txt 2> ${OUT_DIR}/${STEM}_CASM.log
     wait

    java -jar -Xmx15g -Djava.io.tmpdir=/OSM/CBR/NRCA_FINCHGENOM/temp /apps/picard/1.138/picard.jar QualityScoreDistribution \
        VALIDATION_STRINGENCY=$VALIDATION \
	STEM=${IN_LIST["$SLURM_ARRAY_TASK_ID"]}
	        VALIDATION_STRINGENCY=$VALIDATION \
        R=$REF \
        INPUT=$IN_DIR/${STEM}.bam \
        OUTPUT=$OUT_DIR/${STEM}_QSD.txt \
        CHART=$OUT_DIR/${STEM}_QSD.pdf \
        TMP_DIR=$TMP/picard.temp \
        MAX_RECORDS_IN_RAM=$MAX_REC
    wait

    java -jar -Xmx15g -Djava.io.tmpdir=/OSM/CBR/NRCA_FINCHGENOM/temp /apps/picard/1.138/picard.jar CollectInsertSizeMetrics \
        VALIDATION_STRINGENCY=$VALIDATION \
        R=$REF \
        INPUT=$IN_DIR/${STEM}.bam \
        OUTPUT=$OUT_DIR/${STEM}_CISM.txt \
        HISTOGRAM_FILE=$OUT_DIR/${STEM}_CISM.pdf \
        TMP_DIR=$TMP/picard.temp \
        MAX_RECORDS_IN_RAM=$MAX_REC
    wait

     java -jar -Xmx15g /apps/picard/2.9.2/picard.jar CollectWgsMetrics \
         VALIDATION_STRINGENCY=SILENT \
         MAX_RECORDS_IN_RAM=5000000 \
         R=${BIG}/data/${REF%.*} \
         INPUT=$IN_DIR/${STEM}_fixmate_sort.bam \
         OUTPUT=$OUT_DIR/${STEM}_WGS.txt 2> ${OUT_DIR}/${STEM}_WGS.log
     wait

    java -jar -Xmx15g -Djava.io.tmpdir=/OSM/CBR/NRCA_FINCHGENOM/temp /apps/picard/1.138/picard.jar CollectGcBiasMetrics \
        VALIDATION_STRINGENCY=$VALIDATION \
        R=$REF \
        INPUT=$IN_DIR/${STEM}.bam \
        OUTPUT=$OUT_DIR/${STEM}_CGcBM.txt \
        CHART=$OUT_DIR/${STEM}_CGcBM.pdf \
        SUMMARY_OUTPUT=$OUT_DIR/${STEM}_CGcBM_summary.txt \
        WINDOW_SIZE=$WIN \
        TMP_DIR=$TMP/picard.temp \
        MAX_RECORDS_IN_RAM=$MAX_REC
    wait

    java -jar -Xmx15g -Djava.io.tmpdir=/OSM/CBR/NRCA_FINCHGENOM/temp /apps/picard/1.138/picard.jar EstimateLibraryComplexity \
        VALIDATION_STRINGENCY=$VALIDATION \
        R=$REF \
        INPUT=$IN_DIR/${STEM}.bam \
        OUTPUT=$OUT_DIR/${STEM}_ELC.txt \
        TMP_DIR=$TMP/picard.temp \
        MAX_RECORDS_IN_RAM=$MAX_REC

	
    else
        echo "Error: Missing array index as SLURM_ARRAY_TASK_ID"
fi

mv ${BIG}/logs/slurm/picard_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.out $BIG/logs/${TODAY}_picard_slurm/


