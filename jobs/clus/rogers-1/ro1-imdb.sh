#!/bin/bash
#SBATCH -J ro1-imdb
#SBATCH -o %j.out
#SBATCH -n 1
#SBATCH -c 10
#SBATCH -t 128:00:00
#SBATCH --mem-per-cpu=35GB
#SBATCH --mail-user=elainegatto@estudante.ufscar.br
#SBATCH --mail-type=ALL

local_job="/scratch/ro1-imdb"
function clean_job(){
 echo "CLEANING ENVIRONMENT..."
 rm -rf "${local_job}"
}
trap clean_job EXIT HUP INT TERM ERR

set -eE
umask 077

echo ===========================================================
echo Sbatch == ro1-imdb == Start!!!
echo ===========================================================

echo DELETING THE FOLDER
rm -rf /scratch/clus-ro1-imdb

echo CREATING THE FOLDER
mkdir /scratch/clus-ro1-imdb

echo COPYING CONDA ENVIRONMENT
cp /home/u704616/miniconda3.tar.gz /scratch/clus-ro1-imdb
 
echo UNPACKING MINICONDA
tar xzf /scratch/clus-ro1-imdb/miniconda3.tar.gz -C /scratch/clus-ro1-imdb
 
echo DELETING MINICONDA TAR.GZ
rm -rf /scratch/clus-ro1-imdb/miniconda3.tar.gz
 
echo SOURCE
source /scratch/clus-ro1-imdb/miniconda3/etc/profile.d/conda.sh 
 
echo ACTIVATING MINICONDA 
conda activate GattoEnv
 
echo RUNNING
Rscript /home/u704616/Chains-Hybrid-Partition/R/start.R "~/Chains-Hybrid-Partition/config-files/clus/rogers-1/ro1-imdb.csv"
 
echo DELETING JOB FOLDER
rm -rf /scratch/clus-ro1-imdb

echo ===========================================================
echo Sbatch == ro1-imdb == Ended Successfully!!!
echo ===========================================================
