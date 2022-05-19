#!/bin/bash

#***************************************************************#
#                            gzip.sh                            #
#                  written by Kerensa McElroy                   #
#                         June 26, 2018                         #
#                                                               #
#                   batch script to gzip files                  #
#***************************************************************#

#--------------------------sbatch header------------------------#

#SBATCH --job-name=gzip
#SBATCH --time=00:20:00
#SBATCH --mem=6GB

#-------------------------commands-------------------------#

IN_FILE_LIST=(*${IN_EXT})
echo ${IN_EXT}

if [ ! -z "$SLURM_ARRAY_TASK_ID" ]
    then
        IN_FILE=${IN_FILE_LIST["$SLURM_ARRAY_TASK_ID"]}
	gzip $IN_FILE
    else
        echo "Error: Missing array index as SLURM_ARRAY_TASK_ID"
fi

