#!/bin/bash

#***************************************************************#
#                         bwa_index.sh                          #
#                  written by Kerensa McElroy                   #
#                         May 3, 2018                           #
#                                                               #
#                   generate indexed reference                  #
#***************************************************************#

#--------------------------sbatch header------------------------#

#SBATCH --job-name=bwa_index
#SBATCH --time=02:00:00
#SBATCH --ntasks=1
#SBATCH --mem=5GB
#SBATCH --output=logs/slurm/bwa_index_%A.out


#------------------------project variables----------------------#
IN_DIR=${BIG}/data

#---------------------------------------------------------------#

module add bwa/0.7.17

bwa | head -5 >> ${BIG}/logs/${TODAY}_main.log
echo '' >> ${BIG}/logs/${TODAY}_main.log

bwa index -a ${ALG} -p ${IN_DIR}/${REF%.*}  ${IN_DIR}/${REF} 

mv ${BIG}/logs/slurm/* $BIG/logs/${TODAY}_bwa_index_slurm/


