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
Implementation = c("clus", "utiml", "mulan", "python")


###############################################################################
# CREATING FOLDER TO SAVE CONFIG FILES                                        #
###############################################################################
FolderCF = paste(FolderRoot, "/config-files", sep="")
if(dir.exists(FolderCF)==FALSE){dir.create(FolderCF)}



###############################################################################
#
###############################################################################
g = 1 
while(g<=length(Implementation)){
  
  FolderImplementation = paste(FolderCF, "/", Implementation[g], sep="")
  if(dir.exists(FolderImplementation)==FALSE){dir.create(FolderImplementation)}
  
  s = 1
  while(s<=length(similarity)){
    
    FolderSimilarity = paste(FolderImplementation, "/", similarity[s], sep="")
    if(dir.exists(FolderSimilarity)==FALSE){dir.create(FolderSimilarity)}
    
    d = 1
    while(d<=n){
      
      # specific dataset
      ds = datasets[d,]
      
      cat("\n\n=================================================")
      cat("\nImplementation: \t", Implementation[g])
      cat("\nSimilarity: \t\t", similarity[s])
      cat("\nDataset: \t\t", ds$Name)
      
      name = paste(Implementation[g], "-", sim[s], "-", ds$Name, sep="")
      
      # temp.folder = paste("/scratch/", name, sep="")
      temp.folder = paste("/dev/shm/", name, sep="")
      
      # code.folder = paste("/scratch/", name, 
      #                    "/Chains-Hybrid-Partition", sep="")
      
      code.folder = paste("~/Chains-Hybrid-Partition", sep="")
      
      # config.name = paste(code.folder , "/", Implementation[g], 
      #                    "/", name,".csv", sep="")
      
      config.name.2 = paste(FolderSimilarity, "/", name, ".csv", sep="")
      
      # sh.name = paste(code.folder, "/", name, ".sh", sep="")
      
      # Starts building the configuration file
      output.file <- file(config.name.2, "wb")
      
      # Config file table header
      write("Config, Value", file = output.file, append = TRUE)
      
      # Absolute path to the folder where the dataset's "tar.gz" is stored
      
      # write("Dataset_Path, \"/home/u704616/Datasets\"",
      #       file = output.file, append = TRUE)
      
      # write("Dataset_Path, /home/elaine/Datasets",
      #      file = output.file, append = TRUE)
      
      write("Dataset_Path, /home/biomal/Datasets", file = output.file, append = TRUE)
      

      # Absolute path to the folder where temporary processing will be done.
      # You should use "scratch", "tmp" or "/dev/shm", it will depend on the
      # cluster model where your experiment will be run.
      
      str.0 = paste("Temporary_Path, ", temp.folder, sep="")
      write(str.0,file = output.file, append = TRUE)
      
      
      # # str.1 = paste("/home/elaine/Best-Partitions/", similarity[s], sep="")
      # str.1 = paste("/home/u704616/Best-Partitions/", similarity[s], sep="")
      str.1 = paste("/home/biomal/Best-Partitions/", similarity[s], sep="")
      str.2 = paste("Partitions_Path, ", str.1,  sep="")
      write(str.2, file = output.file, append = TRUE)
      
      
      str.3 = paste("Implementation, ", Implementation[g], sep="")
      write(str.3, file = output.file, append = TRUE)
      
      
      str.4 = paste("Similarity, ", similarity[s], sep="")
      write(str.4, file = output.file, append = TRUE)
      
      
      str.5 = paste("Dataset_name, ", ds$Name, sep="")
      write(str.5, file = output.file, append = TRUE)
      
      
      str.6 = paste("Number_dataset, ", ds$Id, sep="")
      write(str.6, file = output.file, append = TRUE)
      
      
      write("Number_folds, 10", file = output.file, append = TRUE)
      
      write("Number_cores, 1", file = output.file, append = TRUE)
      
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