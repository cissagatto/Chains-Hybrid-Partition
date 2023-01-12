#!/bin/bash
#SBATCH -J ro1-bookmarks
#SBATCH -o %j.out
#SBATCH -n 1
#SBATCH -c 10
#SBATCH -t 128:00:00
#SBATCH --mem-per-cpu=35GB
#SBATCH --mail-user=elainegatto@estudante.ufscar.br
#SBATCH --mail-type=ALL

local_job="/scratch/ro1-bookmarks"
function clean_job(){
 echo "CLEANING ENVIRONMENT..."
 rm -rf "${local_job}"
}
trap clean_job EXIT HUP INT TERM ERR

set -eE
umask 077

echo ===========================================================
echo Sbatch == ro1-bookmarks == Start!!!
echo ===========================================================

echo DELETING THE FOLDER
rm -rf /scratch/ecc-ro1-bookmarks

echo CREATING THE FOLDER
mkdir /scratch/ecc-ro1-bookmarks

echo COPYING CONDA ENVIRONMENT
cp /home/u704616/miniconda3.tar.gz /scratch/ecc-ro1-bookmarks
 
echo UNPACKING MINICONDA
tar xzf /scratch/ecc-ro1-bookmarks/miniconda3.tar.gz -C /scratch/ecc-ro1-bookmarks
 
echo DELETING MINICONDA TAR.GZ
rm -rf /scratch/ecc-ro1-bookmarks/miniconda3.tar.gz
 
echo SOURCE
source /scratch/ecc-ro1-bookmarks/miniconda3/etc/profile.d/conda.sh 
 
echo ACTIVATING MINICONDA 
conda activate GattoEnv
 
echo RUNNING
Rscript /home/u704616/Chains-Hybrid-Partition/R/start.R "~/Chains-Hybrid-Partition/config-files/ecc/rogers-1/ro1-bookmarks.csv"
 
echo DELETING JOB FOLDER
rm -rf /scratch/ecc-ro1-bookmarks

echo ===========================================================
echo Sbatch == ro1-bookmarks == Ended Successfully!!!
echo ===========================================================
