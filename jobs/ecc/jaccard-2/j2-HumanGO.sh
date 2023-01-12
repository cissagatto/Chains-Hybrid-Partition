#!/bin/bash
#SBATCH -J j2-HumanGO
#SBATCH -o %j.out
#SBATCH -n 1
#SBATCH -c 10
#SBATCH -t 128:00:00
#SBATCH --mem-per-cpu=35GB
#SBATCH --mail-user=elainegatto@estudante.ufscar.br
#SBATCH --mail-type=ALL

local_job="/scratch/j2-HumanGO"
function clean_job(){
 echo "CLEANING ENVIRONMENT..."
 rm -rf "${local_job}"
}
trap clean_job EXIT HUP INT TERM ERR

set -eE
umask 077

echo ===========================================================
echo Sbatch == j2-HumanGO == Start!!!
echo ===========================================================

echo DELETING THE FOLDER
rm -rf /scratch/ecc-j2-HumanGO

echo CREATING THE FOLDER
mkdir /scratch/ecc-j2-HumanGO

echo COPYING CONDA ENVIRONMENT
cp /home/u704616/miniconda3.tar.gz /scratch/ecc-j2-HumanGO
 
echo UNPACKING MINICONDA
tar xzf /scratch/ecc-j2-HumanGO/miniconda3.tar.gz -C /scratch/ecc-j2-HumanGO
 
echo DELETING MINICONDA TAR.GZ
rm -rf /scratch/ecc-j2-HumanGO/miniconda3.tar.gz
 
echo SOURCE
source /scratch/ecc-j2-HumanGO/miniconda3/etc/profile.d/conda.sh 
 
echo ACTIVATING MINICONDA 
conda activate GattoEnv
 
echo RUNNING
Rscript /home/u704616/Chains-Hybrid-Partition/R/start.R "~/Chains-Hybrid-Partition/config-files/ecc/jaccard-2/j2-HumanGO.csv"
 
echo DELETING JOB FOLDER
rm -rf /scratch/ecc-j2-HumanGO

echo ===========================================================
echo Sbatch == j2-HumanGO == Ended Successfully!!!
echo ===========================================================
