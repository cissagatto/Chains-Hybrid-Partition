#!/bin/bash
#SBATCH -J ro2-tmc-2007
#SBATCH -o %j.out
#SBATCH -n 1
#SBATCH -c 10
#SBATCH -t 128:00:00
#SBATCH --mem-per-cpu=35GB
#SBATCH --mail-user=elainegatto@estudante.ufscar.br
#SBATCH --mail-type=ALL

local_job="/scratch/ro2-tmc-2007"
function clean_job(){
 echo "CLEANING ENVIRONMENT..."
 rm -rf "${local_job}"
}
trap clean_job EXIT HUP INT TERM ERR

set -eE
umask 077

echo ===========================================================
echo Sbatch == ro2-tmc-2007 == Start!!!
echo ===========================================================

echo DELETING THE FOLDER
rm -rf /scratch/clus-ro2-tmc-2007

echo CREATING THE FOLDER
mkdir /scratch/clus-ro2-tmc-2007

echo COPYING CONDA ENVIRONMENT
cp /home/u704616/miniconda3.tar.gz /scratch/clus-ro2-tmc-2007
 
echo UNPACKING MINICONDA
tar xzf /scratch/clus-ro2-tmc-2007/miniconda3.tar.gz -C /scratch/clus-ro2-tmc-2007
 
echo DELETING MINICONDA TAR.GZ
rm -rf /scratch/clus-ro2-tmc-2007/miniconda3.tar.gz
 
echo SOURCE
source /scratch/clus-ro2-tmc-2007/miniconda3/etc/profile.d/conda.sh 
 
echo ACTIVATING MINICONDA 
conda activate GattoEnv
 
echo RUNNING
Rscript /home/u704616/Chains-Hybrid-Partition/R/start.R "~/Chains-Hybrid-Partition/config-files/clus/rogers-2/ro2-tmc-2007.csv"
 
echo DELETING JOB FOLDER
rm -rf /scratch/clus-ro2-tmc-2007

echo ===========================================================
echo Sbatch == ro2-tmc-2007 == Ended Successfully!!!
echo ===========================================================
