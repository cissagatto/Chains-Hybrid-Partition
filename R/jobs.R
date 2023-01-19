rm(list = ls())

##############################################################################

# Copyright (C) 2022                                                       #
#                                                                            #
# This code is free software: you can redistribute it and/or modify it under #
# the terms of the GNU General Public License as published by the Free       #
# Software Foundation, either version 3 of the License, or (at your option)  #
# any later version. This code is distributed in the hope that it will be    #
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of     #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General   #
# Public License for more details.                                           #
#                                                                            #
# Elaine Cecilia Gatto | Prof. Dr. Ricardo Cerri | Prof. Dr. Mauri           #
# Ferrandin | Federal University of Sao Carlos                               #
# (UFSCar: https://www2.ufscar.br/) Campus Sao Carlos | Computer Department  #
# (DC: https://site.dc.ufscar.br/) | Program of Post Graduation in Computer  #
# Science (PPG-CC: http://ppgcc.dc.ufscar.br/) | Bioinformatics and Machine  #
# Learning Group (BIOMAL: http://www.biomal.ufscar.br/)                      #
#                                                                            #
##############################################################################


###############################################################################
# SET WORK SPACE                                                              #
###############################################################################
FolderRoot = "~/Chains-Hybrid-Partition"
FolderScripts = "~/Chains-Hybrid-Partition/R"



###########################################################################
# LOAD LIBRARY/PACKAGE                                                    #
###########################################################################
library(stringr)


#############################################################################
# READING DATASET INFORMATION FROM DATASETS-ORIGINAL.CSV                    #
#############################################################################
setwd(FolderRoot)
datasets = data.frame(read.csv("datasets-original.csv"))
n = nrow(datasets)

###############################################################################
#
###############################################################################
similarity = c("jaccard-3", "rogers-2")
sim = c("j3", "ro2")


###############################################################################
#
###############################################################################
pacote = c("clus", "mulan", "utiml")


###############################################################################
# CREATING FOLDER TO SAVE CONFIG FILES                                        #
###############################################################################
FolderJobs = paste(FolderRoot, "/jobs", sep="")
if(dir.exists(FolderJobs)==FALSE){dir.create(FolderJobs)}


g = 1
while(g<=length(pacote)){
  
  FolderClassifier = paste(FolderJobs, "/", pacote[g], sep="")
  if(dir.exists(FolderClassifier)==FALSE){dir.create(FolderClassifier)}
  
  s = 1
  while(s<=length(similarity)){
    
    FolderSimilarity = paste(FolderClassifier, "/", similarity[s], sep="")
    if(dir.exists(FolderSimilarity)==FALSE){dir.create(FolderSimilarity)}
    
    Folder = paste(FolderClassifier, "/", similarity[s], sep="")
    if(dir.exists(FolderSimilarity)==FALSE){dir.create(FolderSimilarity)}
    
    d = 1
    while(d <= n) {
      
      # specific dataset
      ds = datasets[d,]
      
      FolderCF = paste(FolderRoot, "/config-files", sep="")
      FolderCF = paste(FolderCF, "/", pacote[g], sep="")
      FolderCF = paste(FolderCF, "/", similarity[s], sep="")
      
      name = paste(pacote[g], "-", sim[s], "-", ds$Name, sep="")
      
      temp.folder = paste("/scratch/", name, sep="")
      
      code.folder = paste("/scratch/", name, 
                          "/Chains-Hybrid-Partition", sep="")

      config.name = paste(code.folder , "/", pacote[g], 
                          "/", name,".csv", sep="")
      
      sh.name = paste(FolderSimilarity, "/", name, ".sh", sep="")
      
      cat("\n\n#===============================================")
      cat("\n# Classifier \t\t|", pacote[g])
      cat("\n# Similarity \t\t|", similarity[s])
      cat("\n# Dataset \t\t|", ds$Name)
      cat("\n# Name \t\t\t|", name)
      cat("\n===============================================\n\n")
      
      # start writing
      output.file <- file(sh.name, "wb")
      
      # bash parameters
      write("#!/bin/bash", file = output.file)
      
      str1 = paste("#SBATCH -J ", name, sep = "")
      write(str1, file = output.file, append = TRUE)
      
      write("#SBATCH -o %j.out", file = output.file, append = TRUE)
      
      # number of processors
      write("#SBATCH -n 1", file = output.file, append = TRUE)
      
      # number of cores
      write("#SBATCH -c 10", file = output.file, append = TRUE)
      
      # uncomment this line if you are using slow partition
      # write("#SBATCH --partition slow", file = output.file, append = TRUE)
      
      # uncomment this line if you are using slow partition
      # write("#SBATCH -t 720:00:00", file = output.file, append = TRUE)
      
      # comment this line if you are using slow partition
      write("#SBATCH -t 128:00:00", file = output.file, append = TRUE)
      
      # uncomment this line if you need to use all node memory
      # write("#SBATCH --mem=0", file = output.file, append = TRUE)
      
      # amount of node memory you want to use
      # comment this line if you are using -mem=0
      write("#SBATCH --mem-per-cpu=35GB", file = output.file, append = TRUE)
      
      # email to receive notification
      write("#SBATCH --mail-user=elainegatto@estudante.ufscar.br",
            file = output.file, append = TRUE)
      
      # type of notification
      write("#SBATCH --mail-type=ALL", file = output.file, append = TRUE)
      write("", file = output.file, append = TRUE)
      
      # FUNCTION TO CLEAN THE JOB
      str2 = paste("local_job=",  "\"/scratch/", name, "\"", sep = "")
      write(str2, file = output.file, append = TRUE)
      write("function clean_job(){", file = output.file, append = TRUE)
      str3 = paste(" echo", "\"CLEANING ENVIRONMENT...\"", sep = " ")
      write(str3, file = output.file, append = TRUE)
      str4 = paste(" rm -rf ", "\"${local_job}\"", sep = "")
      write(str4, file = output.file, append = TRUE)
      write("}", file = output.file, append = TRUE)
      write("trap clean_job EXIT HUP INT TERM ERR",
            file = output.file, append = TRUE)
      write("", file = output.file, append = TRUE)
      
      
      # MANDATORY PARAMETERS
      write("set -eE", file = output.file, append = TRUE)
      write("umask 077", file = output.file, append = TRUE)
      
      
      write("", file = output.file, append = TRUE)
      write("echo ===========================================================",
            file = output.file, append = TRUE)
      str30 = paste("echo Sbatch == ", name, " == Start!!!", sep="")
      write(str30,
            file = output.file, append = TRUE)
      write("echo ===========================================================",
            file = output.file, append = TRUE)
      
      
      
      write("", file = output.file, append = TRUE)
      write("echo DELETING THE FOLDER", file = output.file, append = TRUE)
      str11 = paste("rm -rf ", temp.folder, sep = "")
      write(str11, file = output.file, append = TRUE)
      
      
      write("", file = output.file, append = TRUE)
      write("echo CREATING THE FOLDER", file = output.file, append = TRUE)
      str11 = paste("mkdir ", temp.folder, sep = "")
      write(str11, file = output.file, append = TRUE)
      
      
      write("", file = output.file, append = TRUE)
      write("echo COPYING CONDA ENVIRONMENT", file = output.file, append = TRUE)
      str20 = paste("cp /home/u704616/miniconda3.tar.gz ", temp.folder, sep ="")
      write(str20 , file = output.file, append = TRUE)
      
      
      write("", file = output.file, append = TRUE)
      write("echo COPYING CODE", file = output.file, append = TRUE)
      str20 = paste("cp -r /home/u704616/Chains-Hybrid-Partition ", 
                    temp.folder, sep ="")
      write(str20 , file = output.file, append = TRUE)
      
      
      write(" ", file = output.file, append = TRUE)
      write("echo UNPACKING MINICONDA", file = output.file, append = TRUE)
      str22 = paste("tar xzf ", temp.folder, "/miniconda3.tar.gz -C ",
                    temp.folder, sep = "")
      write(str22 , file = output.file, append = TRUE)
      
      
      write(" ", file = output.file, append = TRUE)
      write("echo DELETING MINICONDA TAR.GZ", file = output.file, append = TRUE)
      str22 = paste("rm -rf ", temp.folder, "/miniconda3.tar.gz", sep = "")
      write(str22 , file = output.file, append = TRUE)
      
      
      write(" ", file = output.file, append = TRUE)
      write("echo ENTER FOLDER", file = output.file, append = TRUE)
      write("cd /scratch", file = output.file, append = TRUE)
      str = paste("cd ", name, sep="")
      write(str, file = output.file, append = TRUE)
      
      
      write(" ", file = output.file, append = TRUE)
      write("echo path antes de ativar", file = output.file, append = TRUE)
      write("echo $PATH", file = output.file, append = TRUE)
      
      write(" ", file = output.file, append = TRUE)
      write("echo EXPORT PATH", file = output.file, append = TRUE)
      str = paste("export PATH=",temp.folder, 
                  "/miniconda3/condabin/AmbienteTeste:$PATH", sep="")
      write(str, file = output.file, append = TRUE)
      
      
      write(" ", file = output.file, append = TRUE)
      write("echo SETANDO PKGS PATH", file = output.file, append = TRUE)
      str = paste("conda config --prepend pkgs_dirs ", 
                  temp.folder, "/miniconda3/.conda/pkgs", sep="")
      write(str, file = output.file, append = TRUE)
      
      
      write(" ", file = output.file, append = TRUE)
      write("echo SETANDO ENVS PATH", file = output.file, append = TRUE)
      str = paste("conda config --prepend envs_dirs ", 
                  temp.folder, "/miniconda3/.conda/envs", sep="")
      write(str, file = output.file, append = TRUE)
      
      
      write(" ", file = output.file, append = TRUE)
      write("echo SETANDO ENVS PATH", file = output.file, append = TRUE)
      write("which -a conda", file = output.file, append = TRUE)
      
      
      write(" ", file = output.file, append = TRUE)
      write("echo SOURCE", file = output.file, append = TRUE)
      str21 = paste("source ", temp.folder,
                    "/miniconda3/etc/profile.d/conda.sh ", sep = "")
      write(str21, file = output.file, append = TRUE)
      
      
      write(" ", file = output.file, append = TRUE)
      write("echo ACTIVATING MINICONDA ", file = output.file, append = TRUE)
      write("conda activate AmbienteTeste", file = output.file, append = TRUE)
      write(" ", file = output.file, append = TRUE)
      
      
      write(" ", file = output.file, append = TRUE)
      write("echo PWD DEPOIS DE ATIVAR", file = output.file, append = TRUE)
      write("pwd", file = output.file, append = TRUE)
      write(" ", file = output.file, append = TRUE)
      
      
      write("echo RUNNING", file = output.file, append = TRUE)
      str7 = paste("Rscript ", temp.folder,
                   "/Chains-Hybrid-Partition/R/start.R \"",
                   config.name, "\"", sep = "")
      write(str7, file = output.file, append = TRUE)
      write(" ", file = output.file, append = TRUE)
      
      
      write("echo DELETING JOB FOLDER", file = output.file, append = TRUE)
      str11 = paste("rm -rf ", temp.folder, sep = "")
      write(str11, file = output.file, append = TRUE)
      
      
      write(" ", file = output.file, append = TRUE)
      write("echo DESATIVANDO MINICONDA ", file = output.file, append = TRUE)
      write("conda deactivate", file = output.file, append = TRUE)
      write(" ", file = output.file, append = TRUE)
      
      
      write("", file = output.file, append = TRUE)
      write("echo ===========================================================",
            file = output.file, append = TRUE)
      str20 = paste("echo Sbatch == ", name,
                    " == Ended Successfully!!!", sep="")
      write(str20, file = output.file, append = TRUE)
      write("echo ===========================================================",
            file = output.file, append = TRUE)
      
      close(output.file)
      
      d = d + 1
      gc()
    } # fim do dataset
    
    s = s + 1
    gc()
  } # fim da similaridade
  
  g = g + 1
  gc()
} # FIM DO CLASSIFICADOR


###############################################################################
# Please, any errors, contact us: elainececiliagatto@gmail.com                #
# Thank you very much!                                                        #                                #
###############################################################################