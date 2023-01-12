#!/bin/bash
#SBATCH -J ro1-Wiki10-31K
#SBATCH -o %j.out
#SBATCH -n 1
#SBATCH -c 10
#SBATCH -t 128:00:00
#SBATCH --mem-per-cpu=35GB
#SBATCH --mail-user=elainegatto@estudante.ufscar.br
#SBATCH --mail-type=ALL

local_job="/scratch/ro1-Wiki10-31K"
function clean_job(){
 echo "CLEANING ENVIRONMENT..."
 rm -rf "${local_job}"
}
trap clean_job EXIT HUP INT TERM ERR

set -eE
umask 077

echo ===========================================================
echo Sbatch == ro1-Wiki10-31K == Start!!!
echo ===========================================================

echo DELETING THE FOLDER
rm -rf /scratch/clus-ro1-Wiki10-31K

echo CREATING THE FOLDER
mkdir /scratch/clus-ro1-Wiki10-31K

echo COPYING CONDA ENVIRONMENT
cp /home/u704616/miniconda3.tar.gz /scratch/clus-ro1-Wiki10-31K
 
echo UNPACKING MINICONDA
tar xzf /scratch/clus-ro1-Wiki10-31K/miniconda3.tar.gz -C /scratch/clus-ro1-Wiki10-31K
 
echo DELETING MINICONDA TAR.GZ
rm -rf /scratch/clus-ro1-Wiki10-31K/miniconda3.tar.gz
 
echo SOURCE
source /scratch/clus-ro1-Wiki10-31K/miniconda3/etc/profile.d/conda.sh 
 
echo ACTIVATING MINICONDA 
conda activate GattoEnv
 
echo RUNNING
Rscript /home/u704616/Chains-Hybrid-Partition/R/start.R "~/Chains-Hybrid-Partition/config-files/clus/rogers-1/ro1-Wiki10-31K.csv"
 
echo DELETING JOB FOLDER
rm -rf /scratch/clus-ro1-Wiki10-31K

echo ===========================================================
echo Sbatch == ro1-Wiki10-31K == Ended Successfully!!!
echo ===========================================================
