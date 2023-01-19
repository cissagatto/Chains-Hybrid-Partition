cat("\n\n###########################################################")
  cat("\n# START: CHAINS OF HYBRID PARTITIONS                       #")
  cat("\n###########################################################\n\n")


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
# Ferrandin | Prof. Dr. Celine Vens | PhD Felipe Nakano Kenji                #
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


##############################################################################
# Set Workspace                                                              #
##############################################################################
FolderRoot = "~/Chains-Hybrid-Partition"
FolderScripts = "~/Chains-Hybrid-Partition/R"


##############################################################################
# LOAD R SCRIPTS                                                             #
##############################################################################
setwd(FolderScripts)
source("libraries.R")

setwd(FolderScripts)
source("utils.R")

setwd(FolderScripts)
source("run.R")



###############################################################################
# R Options Configuration                                                     #
###############################################################################
options(java.parameters = "-Xmx64g")  # Java Options
options(show.error.messages = TRUE)   # Error Messages
options(scipen=20)                    # Number of places after the comma



###############################################################################
# Reading the "datasets-original.csv" file to get dataset information         #
# for code execution!                                                         #
###############################################################################
setwd(FolderRoot)
datasets <- data.frame(read.csv("datasets-original.csv"))



###############################################################################
# ARGS COMMAND LINE                                                           #
###############################################################################
cat("\n##########################################")
cat("\n# START: Get arguments from command line #")
cat("\n##########################################\n\n")
args <- commandArgs(TRUE)



###############################################################################
# FIRST ARGUMENT: /getting specific dataset information being processed        #
# from csv file                                                               #
###############################################################################

# config_file = "~/Chains-Hybrid-Partition/config-files/ecc/jaccard-3/ecc-j3-GpositiveGO.csv"
# config_file = "~/Chains-Hybrid-Partition/config-files/clus/jaccard-3/clus-j3-GpositiveGO.csv"


config_file <- args[1]


if(file.exists(config_file)==FALSE){
  cat("\n##############################################################")
  cat("\n# START: Missing Config File! Verify the following path:     #")
  cat("\n# ", config_file, "                                          #")
  cat("\n##############################################################\n\n")
  break
} else {
  cat("\n##############################################")
  cat("\n# START: Properly loaded configuration file! #")
  cat("\n##############################################\n\n")
}



cat("\n######################################################################")
cat("\n# START: Read Parameters                                           #\n")
config = data.frame(read.csv(config_file))
print(config)
cat("\n##################################################################\n\n")


parameters = list()


# DATASET_PATH
dataset_path = toString(config$Value[1])
dataset_path = str_remove(dataset_path, pattern = " ")
parameters$Path.Dataset = dataset_path

# TEMPORARTY_PATH
folderResults = toString(config$Value[2])
folderResults = str_remove(folderResults, pattern = " ")
parameters$Folder.Results = folderResults

# PARTITIONS_PATH
Partitions_Path = toString(config$Value[3])
Partitions_Path = str_remove(Partitions_Path, pattern = " ")
parameters$Path.Partitions = Partitions_Path

# Classificador
classificador = toString(config$Value[4])
classificador = str_remove(classificador, pattern = " ")
parameters$classificador = classificador

# SIMILARITY
similarity = toString(config$Value[5])
similarity = str_remove(similarity, pattern = " ")
parameters$Similarity = similarity

# DATASET_NAME
dataset_name = toString(config$Value[6])
dataset_name = str_remove(dataset_name, pattern = " ")
parameters$Dataset.Name = dataset_name

# DATASET_NUMBER
number_dataset = as.numeric(config$Value[7])
parameters$Number.Dataset = number_dataset

# NUMBER_FOLDS
number_folds = as.numeric(config$Value[8])
parameters$Number.Folds = number_folds

# NUMBER_CORES
number_cores = as.numeric(config$Value[9])
parameters$Number.Cores = number_cores

# DATASET_INFO
ds = datasets[number_dataset,]
parameters$Dataset.Info = ds



cat("\n#####################################################################\n")
cat("\n# DATASET PATH: \t", dataset_path)
cat("\n# TEMPORARY PATH: \t", folderResults)
cat("\n# PARTITIONS PATH: \t", Partitions_Path)
cat("\n# SIMILARITY:  \t", similarity)
cat("\n# DATASET NAME:  \t", dataset_name)
cat("\n# NUMBER DATASET: \t", number_dataset)
cat("\n# NUMBER X-FOLDS CROSS-VALIDATION: \t", number_folds)
cat("\n# NUMBER CORES: \t", number_cores)
cat("\n###################################################################\n\n")



cat("\n################################################################\n")
print(ds)
cat("\n################################################################\n")



###############################################################################
# Creating temporary processing folder                                        #
###############################################################################
if (dir.exists(folderResults) == FALSE) {dir.create(folderResults)}



###############################################################################
# Creating all directories that will be needed for code processing            #
###############################################################################
cat("\n#############################")
cat("\n# START: Get directories    #")
cat("\n#############################\n\n/")
diretorios <- directories(dataset_name, folderResults, similarity)


#####################################
parameters$Folders = diretorios
#####################################


###############################################################################
# Copying datasets from ROOT folder on server                                 #
###############################################################################

cat("\n####################################################################")
cat("\n# START: Checking the dataset tar.gz file                          #")
cat("\n####################################################################\n\n")
str00 = paste(dataset_path, "/", ds$Name,".tar.gz", sep = "")
str00 = str_remove(str00, pattern = " ")

if(file.exists(str00)==FALSE){

  cat("\n##########################################################################")
  cat("\n# START: The tar.gz file for the dataset to be processed does not exist! #")
  cat("\n# Please pass the path of the tar.gz file in the configuration file!     #")
  cat("\n# The path entered was: ", str00, "                                      #")
  cat("\n######################################################################\n\n")
  break

} else {

  cat("\n####################################################################")
  cat("\n# START: tar.gz file of the DATASET loaded correctly!              #")
  cat("\n####################################################################\n\n")

  # COPIANDO
  str01 = paste("cp ", str00, " ", diretorios$folderDatasets, sep = "")
  res = system(str01)
  if (res != 0) {
    cat("\nError: ", str01)
    break
  }

  # DESCOMPACTANDO
  str02 = paste("tar xzf ", diretorios$folderDatasets, "/", ds$Name,
                ".tar.gz -C ", diretorios$folderDatasets, sep = "")
  res = system(str02)
  if (res != 0) {
    cat("\nError: ", str02)
    break
  }

  #APAGANDO
  str03 = paste("rm ", diretorios$folderDatasets, "/", ds$Name,
                ".tar.gz", sep = "")
  res = system(str03)
  if (res != 0) {
    cat("\nError: ", str03)
    break
  }

}



###############################################################################
# Copying PARTITIONS from ROOT folder on server                               #
###############################################################################

cat("\n####################################################################")
cat("\n# START: Checking the PARTITIONS tar.gz file                       #")
cat("\n####################################################################\n\n")
str00 = paste(Partitions_Path, "/", ds$Name,".tar.gz", sep = "")
str00 = str_remove(str00, pattern = " ")

if(file.exists(str00)==FALSE){

  cat("\n##########################################################################")
  cat("\n# START: The tar.gz file for the partitions to be processed does not exist! #")
  cat("\n# Please pass the path of the tar.gz file in the configuration file!     #")
  cat("\n# The path entered was: ", str00, "                                      #")
  cat("\n##########################################################################\n\n")
  break

} else {

  cat("\n##################################################################")
  cat("\n# START: tar.gz file of the PARTITION loaded correctly!          #")
  cat("\n##################################################################\n\n")

  # COPIANDO
  str01 = paste("cp ", str00, " ", diretorios$folderBestPartitions, sep = "")
  res = system(str01)
  if (res != 0) {
    cat("\nError: ", str01)
    break
  }

  # DESCOMPACTANDO
  str02 = paste("tar xzf ", diretorios$folderBestPartitions, "/", ds$Name,
                ".tar.gz -C ", diretorios$folderBestPartitions, sep = "")
  res = system(str02)
  if (res != 0) {
    cat("\nError: ", str02)
    break
  }

  #APAGANDO
  str03 = paste("rm ", diretorios$folderBestPartitions, "/", ds$Name,
                ".tar.gz", sep = "")
  res = system(str03)
  if (res != 0) {
    cat("\nError: ", str03)
    break
  }

}



cat("\n####################################################################")
cat("\n# START: EXECUTE                                                   #")
cat("\n####################################################################\n\n")
timeFinal <- system.time(results <- executa(parameters))
print(timeFinal)
result_set <- t(data.matrix(timeFinal))
setwd(diretorios$folderTested)
write.csv(result_set, "Runtime-Final.csv")


cat("\n####################################################################")
cat("\n# START: DELETING DATASETS AND PARTITIONS FOLDERS                  #")
cat("\n####################################################################\n\n")
print(system(paste("rm -r ", diretorios$folderDatasets, sep="")))
print(system(paste("rm -r ", diretorios$folderBestPartitions, sep="")))


# cat("\n####################################################################")
# cat("\n# Compress folders and files                                       #")
# cat("\n####################################################################\n\n")
# str_a <- paste("tar -zcf ", diretorios$folderResults, "/", dataset_name,
#                "-", similarity, "-results-bps-e.tar.gz ",
#                diretorios$folderResults, sep = "")
# print(system(str_a))




if(parameters$classificador == "ecc"){

  cat("\n####################################################################")
  cat("\n# START: COPY TO GOOGLE DRIVE                                      #")
  cat("\n####################################################################\n\n")
  origem = diretorios$folderTested
  destino = paste("nuvem:ECC/Chains/", similarity, "/", dataset_name, sep="")
  comando1 = paste("rclone -P copy ", origem, " ", destino, sep="")
  cat("\n", comando1, "\n")
  a = print(system(comando1))
  a = as.numeric(a)
  if(a != 0) {
    stop("Erro RCLONE")
    quit("yes")
  }

  # cat("\n####################################################################")
  # cat("\n# Copy to root folder                                              #")
  # cat("\n####################################################################\n\n")
  # 
  # folderO = paste(FolderRoot, "/Output", sep="")
  # if(dir.exists(folderO)==FALSE){dir.create(folderO)}
  # 
  # folderC = paste(folderO, "/Ecc", sep="")
  # if(dir.exists(folderC)==FALSE){dir.create(folderC)}
  # 
  # folderS = paste(folderC, "/", similarity, sep="")
  # if(dir.exists(folderS)==FALSE){dir.create(folderS)}
  # 
  # str_b <- paste("cp -r ", diretorios$folderResults, " ", folderS, sep = "")
  # print(system(str_b))
  
  
} else {
  
  
  cat("\n####################################################################")
  cat("\n# START: COPY TO GOOGLE DRIVE                                      #")
  cat("\n####################################################################\n\n")
  origem = diretorios$folderTested
  destino = paste("nuvem:Clus/Chains/", similarity, "/", dataset_name, sep="")
  comando1 = paste("rclone -P copy ", origem, " ", destino, sep="")
  cat("\n", comando1, "\n")
  a = print(system(comando1))
  a = as.numeric(a)
  if(a != 0) {
    stop("Erro RCLONE")
    quit("yes")
  }
  
  # cat("\n####################################################################")
  # cat("\n# Copy to root folder                                              #")
  # cat("\n####################################################################\n\n")
  # 
  # folderO = paste(FolderRoot, "/Output", sep="")
  # if(dir.exists(folderO)==FALSE){dir.create(folderO)}
  # 
  # folderC = paste(folderO, "/Clus", sep="")
  # if(dir.exists(folderC)==FALSE){dir.create(folderC)}
  # 
  # folderS = paste(folderC, "/", similarity, sep="")
  # if(dir.exists(folderS)==FALSE){dir.create(folderS)}
  # 
  # str_b <- paste("cp -r ", diretorios$folderResults, " ", folderS, sep = "")
  # print(system(str_b))
}



cat("\n####################################################################")
cat("\n# START: DELETE                                                    #")
cat("\n####################################################################\n\n")
str_c = paste("rm -r ", diretorios$folderResults, sep="")
print(system(str_c))

rm(list = ls())
gc()


 cat("\n\n############################################################")
   cat("\n# START: CHAINS OF HYBRID PARTITION END                    #")
   cat("\n############################################################")
cat("\n\n")


#############################################################################
# Please, any errors, contact us: elainececiliagatto@gmail.com              #
# Thank you very much!                                                      #
#############################################################################
