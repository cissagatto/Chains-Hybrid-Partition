#!/bin/bash
#SBATCH -J j3-yahoo_education
#SBATCH -o %j.out
#SBATCH -n 1
#SBATCH -c 10
#SBATCH -t 128:00:00
#SBATCH --mem-per-cpu=35GB
#SBATCH --mail-user=elainegatto@estudante.ufscar.br
#SBATCH --mail-type=ALL

local_job="/scratch/j3-yahoo_education"
function clean_job(){
 echo "CLEANING ENVIRONMENT..."
 rm -rf "${local_job}"
}
trap clean_job EXIT HUP INT TERM ERR

set -eE
umask 077

echo ===========================================================
echo Sbatch == j3-yahoo_education == Start!!!
echo ===========================================================

echo DELETING THE FOLDER
rm -rf /scratch/ecc-j3-yahoo_education

echo CREATING THE FOLDER
mkdir /scratch/ecc-j3-yahoo_education

echo COPYING CONDA ENVIRONMENT
cp /home/u704616/miniconda3.tar.gz /scratch/ecc-j3-yahoo_education
 
echo UNPACKING MINICONDA
tar xzf /scratch/ecc-j3-yahoo_education/miniconda3.tar.gz -C /scratch/ecc-j3-yahoo_education
 
echo DELETING MINICONDA TAR.GZ
rm -rf /scratch/ecc-j3-yahoo_education/miniconda3.tar.gz
 
echo SOURCE
source /scratch/ecc-j3-yahoo_education/miniconda3/etc/profile.d/conda.sh 
 
echo ACTIVATING MINICONDA 
conda activate GattoEnv
 
echo RUNNING
Rscript /home/u704616/Chains-Hybrid-Partition/R/start.R "~/Chains-Hybrid-Partition/config-files/ecc/jaccard-3/j3-yahoo_education.csv"
 
echo DELETING JOB FOLDER
rm -rf /scratch/ecc-j3-yahoo_education

echo ===========================================================
echo Sbatch == j3-yahoo_education == Ended Successfully!!!
echo ===========================================================
