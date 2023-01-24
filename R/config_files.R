rm(list = ls())

##############################################################################
# CHAINS OF HYBRID PARTITIONS                                                #
# Copyright (C) 2022                                                         #
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
# Ferrandin | Prof. Dr. Celine Vens | Dr. Felipe Nakano Kenji                #
#                                                                            #
# Federal University of São Carlos - UFSCar - https://www2.ufscar.br         #
# Campus São Carlos - Computer Department - DC - https://site.dc.ufscar.br   #
# Post Graduate Program in Computer Science - PPGCC                          # 
# http://ppgcc.dc.ufscar.br - Bioinformatics and Machine Learning Group      #
# BIOMAL - http://www.biomal.ufscar.br                                       #
#                                                                            #
# Katholieke Universiteit Leuven Campus Kulak Kortrijk Belgium               #
# Medicine Department - https://kulak.kuleuven.be/                           #
# https://kulak.kuleuven.be/nl/over_kulak/faculteiten/geneeskunde            #
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
similarity = c("jaccard-3","rogers-2")
sim = c("j3", "ro2")


###############################################################################
#
###############################################################################
pacote = c("clus", "utiml", "mulan", "python")


###############################################################################
# CREATING FOLDER TO SAVE CONFIG FILES                                        #
###############################################################################
FolderCF = paste(FolderRoot, "/config-files", sep="")
if(dir.exists(FolderCF)==FALSE){dir.create(FolderCF)}



###############################################################################
#
###############################################################################
g = 1 
while(g<=length(pacote)){
  
  FolderClassifier = paste(FolderCF, "/", pacote[g], sep="")
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
      cat("\nClassifier: \t", pacote[g])
      cat("\nSimilarity: \t", similarity[s])
      cat("\nDataset: \t", ds$Name)
      
      name = paste(pacote[g], "-", sim[s], "-", ds$Name, sep="")
      
      temp.folder = paste("/scratch/", name, sep="")
      
      code.folder = paste("/scratch/", name, 
                          "/Chains-Hybrid-Partition", sep="")
      
      config.name = paste(code.folder , "/", pacote[g], 
                          "/", name,".csv", sep="")
      
      config.name.2 = paste(FolderSimilarity, "/", name, ".csv", sep="")
      
      sh.name = paste(FolderSimilarity, "/", name, ".sh", sep="")
      
      # Starts building the configuration file
      output.file <- file(config.name.2, "wb")
      
      # Config file table header
      write("Config, Value",
            file = output.file, append = TRUE)
      
      # Absolute path to the folder where the dataset's "tar.gz" is stored
      
      write("Dataset_Path, \"/home/u704616/Datasets\"",
            file = output.file, append = TRUE)
      
      # write("Dataset_Path, /home/elaine/Datasets",
      #      file = output.file, append = TRUE)
      
      # write("Dataset_Path, ~/Chains-Hybrid-Partition/Datasets",
      #     file = output.file, append = TRUE)
      

      # Absolute path to the folder where temporary processing will be done.
      # You should use "scratch", "tmp" or "/dev/shm", it will depend on the
      # cluster model where your experiment will be run.
      
      str1 = paste("Temporary_Path, ", temp.folder, sep="")
      write(str1,file = output.file, append = TRUE)
      
      # str = paste("/home/elaine/Best-Partitions/", similarity[s], sep="")
      str = paste("/home/u704616/Best-Partitions/", similarity[s], sep="")
      # str = paste("~/Chains-Hybrid-Partition/Best-Partitions/", 
      #             similarity[s], sep="")
      
      str2 = paste("Partitions_Path, ", str,  sep="")
      write(str2, file = output.file, append = TRUE)
      
      
      str4 = paste("classifier, ", pacote[g], sep="")
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
      write("number_cores, 1", file = output.file, append = TRUE)
      
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