#!/bin/bash

#***************************************************************#
#                            genotype.sh                        #
#                  written by Kerensa McElroy                   #
#                          June 6, 2018                         #
#                                                               #
#                       run gatk's genotype gvcf		#
#***************************************************************#

#--------------------------sbatch header------------------------#

#SBATCH --job-name=geno
#SBATCH --time=1:00:00
#SBATCH --ntasks=1
#SBATCH --mem=5GB
#SBATCH -p m512gb
#SBATCH --output=logs/slurm/geno_%A_%a.out


#------------------------project variables----------------------#
IN_DIR=${BIG}/analysis/${REF%.*}/haplo
OUT_DIR=${BIG}/analysis/${REF%.*}/geno

#---------------------------------------------------------------#

module add gatk/4.0.4.0

#run gatk's genotypeGVCF on individual gvcf files by chromosome

mkdir -p ${OUT_DIR}

cd ${IN_DIR}

ls *.vcf.gz > gvcf.list

IN_LIST=( $(grep '>' ${BIG}/data/${REF} | cut -d'.' -f1 | cut -d'>' -f2) );

if [ ! -z "$SLURM_ARRAY_TASK_ID" ]
    then
        gatk --java-options "-Xmx20g" CombineGVCFs \
            -R ${BIG}/data/${REF%.*} \
            -L ${IN_LIST["$SLURM_ARRAY_TASK_ID"]} \
            --variant gvcf.list \
            -O ${OUT_DIR}/${PROJECT}.g.vcf
        
        gatk --java-options "-Xmx20g" GenotypeGVCFs \
            -R ${BIG}/data/${REF%.*} \
            -L ${IN_LIST["$SLURM_ARRAY_TASK_ID"]} \
            --variant ${OUT_DIR}/${PROJECT}.g.vcf \
            -O ${OUT_DIR}/${PROJECT}.vcf \
            --annotate-with-num-discovered-alleles true \
            --use-new-qual-calculator
        
mv ${BIG}/logs/slurm/genotype_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.out $BIG/logs/${TODAY}_genotype_slurm/


