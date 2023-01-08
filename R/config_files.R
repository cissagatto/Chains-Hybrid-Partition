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
# Ferrandin | Federal University of Sao Carl/os                               #
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
similarity = c("jaccard-2", "jaccard-3", "rogers-1", "rogers-2",
               "random-1", "random-2")
sim = c("j2", "j3", "ro1", "ro2", "ra1", "ra2")


###############################################################################
#
###############################################################################
classificador = c("clus", "ecc")


###############################################################################
# CREATING FOLDER TO SAVE CONFIG FILES                                        #
###############################################################################
FolderCF = paste(FolderRoot, "/config-files", sep="")
if(dir.exists(FolderCF)==FALSE){dir.create(FolderCF)}



###############################################################################
#
###############################################################################
g = 1 
while(g<=length(classificador)){
  
  FolderClassifier = paste(FolderCF, "/", classificador[g], sep="")
  if(dir.exists(FolderClassifier)==FALSE){dir.create(FolderClassifier)}
  
  s = 1
  while(s<=length(similarity)){
    
    FolderSimilarity = paste(FolderClassifier, "/", similarity[s], sep="")
    if(dir.exists(FolderSimilarity)==FALSE){dir.create(FolderSimilarity)}
    
    d = 1
    while(d<=n){
      
      # specific dataset
      ds = datasets[d,]
      
      cat("\n\n=================================================")
      cat("\nClassifier: \t", classificador[g])
      cat("\nSimilarity: \t", similarity[s])
      cat("\nDataset: \t", ds$Name)
      
      # Confi File Name
      file_name = paste(FolderSimilarity, "/", sim[s], 
                        "-", ds$Name, ".csv", sep="")
      
      # Starts building the configuration file
      output.file <- file(file_name, "wb")
      
      # Config file table header
      write("Config, Value",
            file = output.file, append = TRUE)
      
      # Absolute path to the folder where the dataset's "tar.gz" is stored
      
      write("Dataset_Path, \"/home/u704616/Datasets\"",
            file = output.file, append = TRUE)
      
      # write("Dataset_Path, ~/Chains-Hybrid-Partition/Datasets",
      #      file = output.file, append = TRUE)
      
      # job name
      job_name = paste(sim[s], "-", ds$Name, sep = "")
      
      
      # folder_name = paste("\"/scratch/", job_name, "\"", sep = "")
      folder_name = paste("/scratch/", job_name, sep = "")
      # folder_name = paste("~/tmp/", job_name, sep = "")
      # folder_name = paste("/dev/shm/", classificador[g], "-", job_name, sep = "")
      
      # Absolute path to the folder where temporary processing will be done.
      # You should use "scratch", "tmp" or "/dev/shm", it will depend on the
      # cluster model where your experiment will be run.
      
      str1 = paste("Temporary_Path, ", folder_name, sep="")
      write(str1,file = output.file, append = TRUE)
      
      # str = paste("~/Chains-Hybrid-Partition/Best-Partitions/", 
      #            similarity[s], sep="")
      
      str = paste("/home/u704616/Best-Partitions", similarity[s], sep="")
      
      str2 = paste("Partitions_Path, ", str,  sep="")
      write(str2, file = output.file, append = TRUE)
      
      
      str4 = paste("classifier, ", classificador[g], sep="")
      write(str4, file = output.file, append = TRUE)
      
      str5 = paste("similarity, ", similarity[s], sep="")
      write(str5, file = output.file, append = TRUE)
      
      # dataset name
      str3 = paste("dataset_name, ", ds$Name, sep="")
      write(str3, file = output.file, append = TRUE)
      
      # Dataset number according to "datasets-original.csv" file
      str2 = paste("number_dataset, ", ds$Id, sep="")
      write(str2, file = output.file, append = TRUE)
      
      # Number used for X-Fold Cross-Validation
      write("number_folds, 10", file = output.file, append = TRUE)
      
      # Number of cores to use for parallel processing
      write("number_cores, 10", file = output.file, append = TRUE)
      
      # finish writing to the configuration file
      close(output.file)
      
      d = d + 1
      gc()
    } # DATASET END
    
    s = s + 1
    gc()
  } # SIMILARITY END
  
  g = g + 1
  gc()
}


rm(list = ls())

###############################################################################
# Please, any errors, contact us: elainececiliagatto@gmail.com                #
# Thank you very much!                                                        #                                #
###############################################################################