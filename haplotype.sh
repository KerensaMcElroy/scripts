#!/bin/bash

#***************************************************************#
#                            haplotype.sh                       #
#                  written by Kerensa McElroy                   #
#                          June 1, 2018                         #
#                                                               #
#                       run gatk's haplotype caller             #
#***************************************************************#

#--------------------------sbatch header------------------------#

#SBATCH --job-name=haplotype
#SBATCH --time=10:00:00
#SBATCH --ntasks=1
#SBATCH --mem=10GB
#SBATCH --output=logs/slurm/haplotype_%A_%a.out


#------------------------project variables----------------------#
IN_DIR=${BIG}/analysis/${REF%.*}/bwa
OUT_DIR=${BIG}/analysis/${REF%.*}/haplo

#---------------------------------------------------------------#

module add gatk/4.0.4.0

#run gatk's haplotype caller on sorted bam files

IN_LIST=( $(tail -n +2 ${METADATA} | cut -f 1 | sed "s/_R[12].*//" | sort -u) );


mkdir -p ${OUT_DIR}

if [ ! -z "$SLURM_ARRAY_TASK_ID" ]
    then
	STEM=${IN_LIST["$SLURM_ARRAY_TASK_ID"]}
        gatk --java-options "-Xmx9g" HaplotypeCaller \
            -R ${BIG}/data/${REF%.*} \
            -I ${IN_DIR}/${STEM}*fixmate_sort.bam \
            -O ${OUT_DIR}/${STEM}.g.vcf.gz \
            -ERC GVCF

    else
        echo "Error: Missing array index as SLURM_ARRAY_TASK_ID"
fi

mv ${BIG}/logs/slurm/haplotype_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.out $BIG/logs/${TODAY}_haplotype_slurm/


