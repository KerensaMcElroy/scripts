#!/bin/bash

#***************************************************************#
#                            copy.sh                            #
#                  written by Kerensa McElroy                   #
#                         Feburary 1, 2018                      #
#                                                               #
#               batch file copy including integrity check       #
#***************************************************************#

#--------------------------sbatch header------------------------#

#SBATCH --job-name=copy
#SBATCH --partition=io
#SBATCH --time=00:10:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=1GB

#-------------------------process input-------------------------#

#while getopts i:o: option
#do
#    case "${option}"
#    in
#    i) IN_FILE_LIST=${OPTARG};;
#    o) OUT_DIR=${OPTARG};;
#    esac
#done

#---------------------------commands----------------------------#

echo 'in script' >> /OSM/CBR/AG_FUTUREFOREST/home/Ktest.txt
#
#if [ ! -z "$SLURM_ARRAY_TASK_ID" ]
#    echo "$SLURM_ARRAY_TASK_ID" > test.txt
##    then
##	IN_FILE=${IN_FILE_LIST["$SLURM_ARRAY_TASK_ID"]}
##	STEM=$(basename ${IN_FILE})
##	echo $STEM
##	md5sum ${IN_FILE} > ${IN_FILE}.md5
##	cp -n --no-preserve=ownership ${IN_FILE} $OUT_DIR/${STEM}
##	md5sum -c $OUT_DIR/${STEM} >> $BIG_LOGS/${TODAY}_copy.log
##    else
##        echo "Error: Missing array index as SLURM_ARRAY_TASK_ID"
#fi
#
#
