#!/bin/bash

#***************************************************************#
#                            jellyfish.sh			#
#                  written by Kerensa McElroy                   #
#                          June 5, 2018                         #
#                                                               #
#                           kmer counting                       #
#***************************************************************#

#--------------------------sbatch header------------------------#

#SBATCH --job-name=jellyfish
#SBATCH --time=02:00:00
#SBATCH --ntasks=10
#SBATCH --mem=20GB
#SBATCH --output=jellyfish_%A_%a.out


#------------------------project variables----------------------#
IN_DIR=/OSM/CBR/NRCA_FINCHGENOM/analysis/2016-09-21_telomere/subsamples
OUT_DIR=/OSM/CBR/NRCA_FINCHGENOM/analysis/2016-09-21_telomere/jellyfish

#---------------------------------------------------------------#

module add jellyfish/2.2.6

jellyfish --version logs/${TODAY}_main.log

IN_LIST=(${IN_DIR}/*.fastq);

mkdir -p ${OUT_DIR}

if [ ! -z "$SLURM_ARRAY_TASK_ID" ]
    then
	    FILE=${IN_LIST["$SLURM_ARRAY_TASK_ID"]}
	    jellyfish count -m 18 -s 500M -t 10 -C ${FILE} -o ${FILE%.*}.jf
            telomeres=`jellyfish query ${FILE%.*}.jf CCCTAACCCTAACCCTAA`
	    echo "$(basename ${FILE%.*}) ${telomeres}" > ${FILE%.*}_telokmer_counts.txt
    else
        echo "Error: Missing array index as SLURM_ARRAY_TASK_ID"
fi



