#!/bin/bash

#SBATCH --job-name=copy
#SBATCH --partition=io
#SBATCH --time=00:10:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=1GB

echo 'in script' >> /home/mce03b/2018-01-01_e-camal-assoc/src
