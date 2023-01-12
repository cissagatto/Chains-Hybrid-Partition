#!/bin/bash
#SBATCH -J j2-derisi
#SBATCH -o %j.out
#SBATCH -n 1
#SBATCH -c 10
#SBATCH -t 128:00:00
#SBATCH --mem-per-cpu=35GB
#SBATCH --mail-user=elainegatto@estudante.ufscar.br
#SBATCH --mail-type=ALL

local_job="/scratch/j2-derisi"
function clean_job(){
 echo "CLEANING ENVIRONMENT..."
 rm -rf "${local_job}"
}
trap clean_job EXIT HUP INT TERM ERR

set -eE
umask 077

echo ===========================================================
echo Sbatch == j2-derisi == Start!!!
echo ===========================================================

echo DELETING THE FOLDER
rm -rf /scratch/clus-j2-derisi

echo CREATING THE FOLDER
mkdir /scratch/clus-j2-derisi

echo COPYING CONDA ENVIRONMENT
cp /home/u704616/miniconda3.tar.gz /scratch/clus-j2-derisi
 
echo UNPACKING MINICONDA
tar xzf /scratch/clus-j2-derisi/miniconda3.tar.gz -C /scratch/clus-j2-derisi
 
echo DELETING MINICONDA TAR.GZ
rm -rf /scratch/clus-j2-derisi/miniconda3.tar.gz
 
echo SOURCE
source /scratch/clus-j2-derisi/miniconda3/etc/profile.d/conda.sh 
 
echo ACTIVATING MINICONDA 
conda activate GattoEnv
 
echo RUNNING
Rscript /home/u704616/Chains-Hybrid-Partition/R/start.R "~/Chains-Hybrid-Partition/config-files/clus/jaccard-2/j2-derisi.csv"
 
echo DELETING JOB FOLDER
rm -rf /scratch/clus-j2-derisi

echo ===========================================================
echo Sbatch == j2-derisi == Ended Successfully!!!
echo ===========================================================
