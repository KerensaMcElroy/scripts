#!/bin/bash

#***************************************************************#
#                            tassel.sh                          #
#                  written by Kerensa McElroy                   #
#                         August 12, 2020                       #
#                                                               #
#                 final tassel step                             #
#***************************************************************#

#--------------------------sbatch header------------------------#

#SBATCH --job-name=tassel
#SBATCH --time=1-00:00:00
#SBATCH --ntasks=1
#SBATCH --mem=15GB
#SBATCH --output=/scratch1/mce03b/2020-02-28_GWAS/tassel_%A_%a.out



module add tassel/5.2.63
module add vcflib/20170116
module add bamtools/2.5.1
module add bcftools/1.10.2
module add bwa/0.7.17

# run tassel on all differentials separately

mkdir -p /scratch1/mce03b/2020-02-28_GWAS/analysis/freebayes/12SD80/nine/diff_$SLURM_ARRAY_TASK_ID/

IN_LIST=( $(ls /scratch1/mce03b/2020-02-28_GWAS/data/phenos/*nine*) )

if [ ! -z "$SLURM_ARRAY_TASK_ID" ]
    then
        run_pipeline.pl -Xmx10g -Xms10g -fork1 -importGuess /scratch1/mce03b/2020-02-28_GWAS/analysis/freebayes/12SD80/12SD80_all.biallelic.maf_missing.filter.sorted.vcf -fork2 -importGuess ${IN_LIST["$SLURM_ARRAY_TASK_ID"]} -fork3 -importGuess /scratch1/mce03b/2020-02-28_GWAS/analysis/freebayes/12SD80/12SD80_all1.txt -combine4 -input1 -input2 -input3 -intersect -fork5 -importGuess /scratch1/mce03b/2020-02-28_GWAS/analysis/freebayes/12SD80/12SD80_all.biallelic.maf_missing.filter.sorted.txt -combine6 -input5 -input4 -mlm -mlmVarCompEst EachMarker -mlmCompressionLevel None -export /scratch1/mce03b/2020-02-28_GWAS/analysis/freebayes/12SD80/nine/diff_$SLURM_ARRAY_TASK_ID/mlm_nocomp
    else
        echo "Error: Missing array index as SLURM_ARRAY_TASK_ID"
fi



