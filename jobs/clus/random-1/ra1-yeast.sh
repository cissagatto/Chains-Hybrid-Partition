#!/bin/bash
#SBATCH -J ra1-yeast
#SBATCH -o %j.out
#SBATCH -n 1
#SBATCH -c 10
#SBATCH -t 128:00:00
#SBATCH --mem-per-cpu=35GB
#SBATCH --mail-user=elainegatto@estudante.ufscar.br
#SBATCH --mail-type=ALL

local_job="/scratch/ra1-yeast"
function clean_job(){
 echo "CLEANING ENVIRONMENT..."
 rm -rf "${local_job}"
}
trap clean_job EXIT HUP INT TERM ERR

set -eE
umask 077

echo ===========================================================
echo Sbatch == ra1-yeast == Start!!!
echo ===========================================================

echo DELETING THE FOLDER
rm -rf /scratch/clus-ra1-yeast

echo CREATING THE FOLDER
mkdir /scratch/clus-ra1-yeast

echo COPYING CONDA ENVIRONMENT
cp /home/u704616/miniconda3.tar.gz /scratch/clus-ra1-yeast
 
echo UNPACKING MINICONDA
tar xzf /scratch/clus-ra1-yeast/miniconda3.tar.gz -C /scratch/clus-ra1-yeast
 
echo DELETING MINICONDA TAR.GZ
rm -rf /scratch/clus-ra1-yeast/miniconda3.tar.gz
 
echo SOURCE
source /scratch/clus-ra1-yeast/miniconda3/etc/profile.d/conda.sh 
 
echo ACTIVATING MINICONDA 
conda activate GattoEnv
 
echo RUNNING
Rscript /home/u704616/Chains-Hybrid-Partition/R/start.R "~/Chains-Hybrid-Partition/config-files/clus/random-1/ra1-yeast.csv"
 
echo DELETING JOB FOLDER
rm -rf /scratch/clus-ra1-yeast

echo ===========================================================
echo Sbatch == ra1-yeast == Ended Successfully!!!
echo ===========================================================
