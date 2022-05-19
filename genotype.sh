#!/bin/bash

#***************************************************************#
#                            genotype.sh                        #
#                  written by Kerensa McElroy                   #
#                          June 6, 2018                         #
#                                                               #
#                       run gatk's genotype gvcf		#
#***************************************************************#

#--------------------------sbatch header------------------------#

#SBATCH --job-name=genotype
#SBATCH --time=160:00:00
#SBATCH --ntasks=1
#SBATCH --mem=500GB
#SBATCH -p m512gb
#SBATCH --output=logs/slurm/genotype_%A_%a.out


#------------------------project variables----------------------#
IN_DIR=${BIG}/analysis/haplo
OUT_DIR=${BIG}/analysis/geno

#---------------------------------------------------------------#

module add gatk/4.0.4.0

#run gatk's genotypeGVCF on individual gvcf files

mkdir -p ${OUT_DIR}

cd ${IN_DIR}

ls *.vcf.gz > gvcf.list

gatk --java-options "-Xmx495g" CombineGVCFs \
    -R ${BIG}/data/${REF%.*} \
    --variant gvcf.list \
    -O ${OUT_DIR}/${PROJECT}.g.vcf

#gatk --java-options "-Xmx20g" GenotypeGVCFs \
#    -R ${BIG}/data/${REF%.*} \
#    --variant ${OUT_DIR}/${PROJECT}.g.vcf \
#    -O ${OUT_DIR}/${PROJECT}.vcf \
#    --annotate-with-num-discovered-alleles true \
#    --use-new-qual-calculator
    
mv ${BIG}/logs/slurm/genotype_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.out $BIG/logs/${TODAY}_genotype_slurm/


