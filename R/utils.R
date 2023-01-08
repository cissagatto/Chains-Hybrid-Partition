##############################################################################

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
# Ferrandin | Federal University of Sao Carlos                               #
# (UFSCar: https://www2.ufscar.br/) Campus Sao Carlos | Computer Department  #
# (DC: https://site.dc.ufscar.br/) | Program of Post Graduation in Computer  #
# Science (PPG-CC: http://ppgcc.dc.ufscar.br/) | Bioinformatics and Machine  #
# Learning Group (BIOMAL: http://www.biomal.ufscar.br/)                      #
#                                                                            #
##############################################################################



###########################################################################
#
###########################################################################
FolderRoot = "~/Chains-Hybrid-Partition"
FolderScripts = "~/Chains-Hybrid-Partition/R"




#########################################################################
# FUNCTION DIRECTORIES                                   
#   Objective:                                           
#      Creates all the necessary folders for the project.
#   Parameters:                                          
#      dataset_name: name of the dataset                 
#      folderResults: path to save process the algorithm. 
#               Example: "/dev/shm/birds", "/scratch/birds", 
#            "/home/usuario/birds", "/C:/Users/usuario/birds"
#   Return:                                                              
#      All path directories                                              
#########################################################################
directories <- function(dataset_name, folderResults, similarity){
  
  FolderRoot = "~/Chains-Hybrid-Partition"
  FolderScripts = "~/Chains-Hybrid-Partition/R"
  
  retorno = list()
  
  #############################################################################
  # RESULTS FOLDER:                                                           #
  # Parameter from command line. This folder will be delete at the end of the #
  # execution. Other folder is used to store definitely the results.          #
  # Example: "/dev/shm/res"                                                   #
  #############################################################################
  if(dir.exists(folderResults) == TRUE){
    setwd(folderResults)
    dir_folderResults = dir(folderResults)
    n_folderResults = length(dir_folderResults)
  } else {
    dir.create(folderResults)
    setwd(folderResults)
    dir_folderResults = dir(folderResults)
    n_folderResults = length(dir_folderResults)
  }
  retorno$folderResults = folderResults
  
  #############################################################################
  #
  #############################################################################
  folderUtils = paste(FolderRoot, "/Utils", sep="")
  if(dir.exists(folderUtils ) == TRUE){
    setwd(folderUtils)
    dir_folderUtils = dir(folderUtils)
    n_folderUtils  = length(dir_folderUtils)
  } else {
    dir.create(folderUtils)
    setwd(folderUtils)
    dir_folderUtils = dir(folderUtils)
    n_folderUtils  = length(dir_folderUtils)
  }
  retorno$folderUtils = folderUtils
  
  #############################################################################
  # DATASETS FOLDER:                                                          #
  # Get the information within DATASETS folder that already exists in the     #
  # project. This folder store the files from cross-validation and will be    #
  # use to get the label space to modeling the label correlations and         #
  # compute silhouete to choose the best hybrid partition.                    #
  # "/home/[user]/Partitions-Kohonen/datasets"                                #
  #############################################################################
  folderDatasets = paste(folderResults, "/Datasets", sep="")
  if(dir.exists(folderDatasets) == TRUE){
    setwd(folderDatasets)
    dir_folderDatasets = dir(folderDatasets)
    n_folderDatasets = length(dir_folderDatasets)
  } else {
    dir.create(folderDatasets)
    setwd(folderDatasets)
    dir_folderDatasets = dir(folderDatasets)
    n_folderDatasets = length(dir_folderDatasets)
  }
  retorno$folderDatasets = folderDatasets
  
  
  #############################################################################
  # SPECIFIC DATASET FOLDER:                                                  #
  # Path to the specific dataset that is runing. Example: with you are        # 
  # running this code for EMOTIONS dataset, then this get the path from it    #
  # "/home/[user]/Partitions-Kohonen/datasets/birds"                          #
  #############################################################################
  folderSpecificDataset = paste(folderDatasets, "/", dataset_name, sep="")
  if(dir.exists(folderSpecificDataset) == TRUE){
    setwd(folderSpecificDataset)
    dir_folderSpecificDataset = dir(folderSpecificDataset)
    n_folderSpecificDataset = length(dir_folderSpecificDataset)
  } else {
    dir.create(folderSpecificDataset)
    setwd(folderSpecificDataset)
    dir_folderSpecificDataset = dir(folderSpecificDataset)
    n_folderSpecificDataset = length(dir_folderSpecificDataset)
  }
  retorno$folderSpecificDataset = folderSpecificDataset
  
  
  #############################################################################
  # LABEL SPACE FOLDER:                                                       #
  # Path to the specific label space from the dataset that is runing.         #
  # This folder store the label space for each FOLD from the cross-validation #
  # which was computed in the Cross-Validation Multi-Label code.              #
  # In this way, we don't need to load the entire dataset into the running    #
  # "/home/elaine/Partitions-Kohonen/datasets/birds/LabelSpace"               #
  #############################################################################
  folderLabelSpace = paste(folderSpecificDataset, "/LabelSpace", sep="")
  if(dir.exists(folderLabelSpace) == TRUE){
    setwd(folderLabelSpace)
    dir_folderLabelSpace = dir(folderLabelSpace)
    n_folderLabelSpace = length(dir_folderLabelSpace)
  } else {
    dir.create(folderLabelSpace)
    setwd(folderLabelSpace)
    dir_folderLabelSpace = dir(folderLabelSpace)
    n_folderLabelSpace = length(dir_folderLabelSpace)
  }
  retorno$folderLabelSpace = folderLabelSpace
  
  
  #############################################################################
  # NAMES LABELS FOLDER:                                                      #
  # Get the names of the labels from this dataset. This will be used in the   #
  # code to create the groups for each partition. Is a way to guarantee the   #
  # use of the correct names labels.                                          #
  # "/home/[user]/Partitions-Kohonen/datasets/birds/NamesLabels"              #
  #############################################################################
  folderNamesLabels = paste(folderSpecificDataset, "/NamesLabels", sep="")
  if(dir.exists(folderNamesLabels) == TRUE){
    setwd(folderNamesLabels)
    dir_folderNamesLabels = dir(folderNamesLabels)
    n_folderNamesLabels = length(dir_folderNamesLabels)
  } else {
    dir.create(folderNamesLabels)
    setwd(folderNamesLabels)
    dir_folderNamesLabels = dir(folderNamesLabels)
    n_folderNamesLabels = length(dir_folderNamesLabels)
  }
  retorno$folderNamesLabels = folderNamesLabels
  
  
  #############################################################################
  # CROSS VALIDATION FOLDER:                                                  #
  # Path to the folders and files from cross-validation for the specific      # 
  # dataset                                                                   #
  # "/home/[user]/Partitions-Kohonen/datasets/birds/CrossValidation"          #
  #############################################################################
  folderCV = paste(folderSpecificDataset, "/CrossValidation", sep="")
  if(dir.exists(folderCV) == TRUE){
    setwd(folderCV)
    dir_folderCV = dir(folderCV)
    n_folderCV = length(dir_folderCV)
  } else {
    dir.create(folderCV)
    setwd(folderCV)
    dir_folderCV = dir(folderCV)
    n_folderCV = length(dir_folderCV)
  }
  retorno$folderCV = folderCV
  
  
  #############################################################################
  # TRAIN CROSS VALIDATION FOLDER:                                            #
  # Path to the train files from cross-validation for the specific dataset    #                                                                   #
  # "/home/[user]/Partitions-Kohonen/datasets/birds/CrossValidation/Tr"       #
  #############################################################################
  folderCVTR = paste(folderCV, "/Tr", sep="")
  if(dir.exists(folderCVTR) == TRUE){
    setwd(folderCVTR)
    dir_folderCVTR = dir(folderCVTR)
    n_folderCVTR = length(dir_folderCVTR)
  } else {
    dir.create(folderCVTR)
    setwd(folderCVTR)
    dir_folderCVTR = dir(folderCVTR)
    n_folderCVTR = length(dir_folderCVTR)
  }
  retorno$folderCVTR = folderCVTR
  
  
  #############################################################################
  # TEST CROSS VALIDATION FOLDER:                                             #
  # Path to the test files from cross-validation for the specific dataset     #                                                                   #
  # "/home/[user]/Partitions-Kohonen/datasets/birds/CrossValidation/Ts"       #
  #############################################################################
  folderCVTS = paste(folderCV, "/Ts", sep="")
  if(dir.exists(folderCVTS) == TRUE){
    setwd(folderCVTS)
    dir_folderCVTS = dir(folderCVTS)
    n_folderCVTS = length(dir_folderCVTS)
  } else {
    dir.create(folderCVTS)
    setwd(folderCVTS)
    dir_folderCVTS = dir(folderCVTS)
    n_folderCVTS = length(dir_folderCVTS)
  }
  retorno$folderCVTS = folderCVTS
  
  
  #############################################################################
  # VALIDATION CROSS VALIDATION FOLDER:                                       #
  # Path to the validation files from cross-validation for the specific       #
  # dataset                                                                   #                                                           
  # "/home/[user]/Partitions-Kohonen/datasets/birds/CrossValidation/Vl"       #
  #############################################################################
  folderCVVL = paste(folderCV, "/Vl", sep="")
  if(dir.exists(folderCVVL) == TRUE){
    setwd(folderCVVL)
    dir_folderCVVL = dir(folderCVVL)
    n_folderCVVL = length(dir_folderCVVL)
  } else {
    dir.create(folderCVVL)
    setwd(folderCVVL)
    dir_folderCVVL = dir(folderCVVL)
    n_folderCVVL = length(dir_folderCVVL)
  }
  retorno$folderCVVL = folderCVVL
  
  
  #############################################################################
  #
  #############################################################################
  folderBestPartitions = paste(folderResults, "/Best-Partitions", sep="")
  if(dir.exists(folderBestPartitions) == TRUE){
    setwd(folderBestPartitions)
    dir_folderBestPartitions = dir(folderBestPartitions)
    n_folderBestPartitions = length(dir_folderBestPartitions)
  } else {
    dir.create(folderBestPartitions)
    setwd(folderBestPartitions)
    dir_folderBestPartitions = dir(folderBestPartitions)
    n_folderBestPartitions = length(dir_folderBestPartitions)
  }
  retorno$folderBestPartitions = folderBestPartitions
  
  
  #############################################################################
  #
  #############################################################################
  folderTested = paste(folderResults, "/Tested", sep="")
  if(dir.exists(folderTested) == TRUE){
    setwd(folderTested)
    dir_folderTested = dir(folderTested)
    n_folderTested = length(dir_folderTested)
  } else {
    dir.create(folderTested)
    setwd(folderTested)
    dir_folderTested = dir(folderTested)
    n_folderTested = length(dir_folderTested)
  }
  retorno$folderTested = folderTested
  
  # 
  # #############################################################################
  # #
  # #############################################################################
  # folderTestedClus = paste(folderTested, "/Clus", sep="")
  # if(dir.exists(folderTestedClus) == TRUE){
  #   setwd(folderTestedClus)
  #   dir_folderTestedClus = dir(folderTestedClus)
  #   n_folderTestedClus = length(dir_folderTestedClus)
  # } else {
  #   dir.create(folderTestedClus)
  #   setwd(folderTestedClus)
  #   dir_folderTestedClus = dir(folderTestedClus)
  #   n_folderTestedClus = length(dir_folderTestedClus)
  # }
  # retorno$folderTestedClus = folderTestedClus
  # 
  # 
  # #############################################################################
  # #
  # #############################################################################
  # folderTestedECC = paste(folderTested, "/ECC", sep="")
  # if(dir.exists(folderTestedECC) == TRUE){
  #   setwd(folderTestedECC)
  #   dir_folderTestedECC = dir(folderTestedECC)
  #   n_folderTestedECC = length(dir_folderTestedECC)
  # } else {
  #   dir.create(folderTestedECC)
  #   setwd(folderTestedECC)
  #   dir_folderTestedECC = dir(folderTestedECC)
  #   n_folderTestedECC = length(dir_folderTestedECC)
  # }
  # retorno$folderTestedECC = folderTestedECC
  
  #############################################################################
  #
  #############################################################################
  folderBPR = paste(FolderRoot, "/Best-Partitions", sep="")
  if(dir.exists(folderBPR) == TRUE){
    setwd(folderBPR)
    dir_folderBPR = dir(folderBPR)
    n_folderBPR = length(dir_folderBPR)
  } else {
    dir.create(folderBPR)
    setwd(folderBPR)
    dir_folderBPR = dir(folderBPR)
    n_folderBPR = length(dir_folderBPR)
  }
  retorno$folderBPR = folderBPR
  
  #############################################################################
  #
  #############################################################################
  folderBPRS = paste(folderBPR, "/", similarity, sep="")
  if(dir.exists(folderBPRS) == TRUE){
    setwd(folderBPRS)
    dir_folderBPRS = dir(folderBPRS)
    n_folderBPRS = length(dir_folderBPRS)
  } else {
    dir.create(folderBPRS)
    setwd(folderBPRS)
    dir_folderBPRS = dir(folderBPRS)
    n_folderBPRS = length(dir_folderBPRS)
  }
  retorno$folderBPRS = folderBPRS
  
  
  return(retorno)
  gc()
}



#######################################################################
# FUNCTION LABEL SPACE                                               
#   Objective                                                        
#       Separates the label space from the rest of the data to be used
#     as input for calculating correlations
#   Parameters                             
#       ds: specific dataset information   
#       dataset_name: dataset name. It is used to save files.
#       number_folds: number of folds created                
#       folderResults: folder where to save results          
#   Return:                                                  
#       Training set labels space                            
#############################################################
labelSpace <- function(parameters){
  
  retorno = list()
  
  # return all fold label space
  classes = list()
  
  # from the first FOLD to the last
  k = 1
  while(k<=parameters$Number.Folds){
    
    # cat("\n\tFold: ", k)
    
    # enter folder train
    setwd(parameters$Folders$folderCVTR)
    
    # get the correct fold cross-validation
    nome_arquivo = paste(parameters$Dataset.Name, "-Split-Tr-", k, ".csv", sep="")
    
    # open the file
    arquivo = data.frame(read.csv(nome_arquivo))
    
    # split label space from input space
    classes[[k]] = arquivo[,ds$LabelStart:ds$LabelEnd]
    
    # get the names labels
    namesLabels = c(colnames(classes[[k]]))
    
    # increment FOLD
    k = k + 1
    
    # garbage collection
    gc()
    
  } # End While of the 10-folds
  
  # return results
  retorno$NamesLabels = namesLabels
  retorno$Classes = classes
  return(retorno)
  
  gc()
  cat("\n################################################################")
  cat("\n# FUNCTION LABEL SPACE: END                                    #")
  cat("\n################################################################")
  cat("\n\n\n\n")
}



#######################################################################
# FUNCTION INFO DATA SET                                               
#  Objective                                                           
#     Gets the information that is in the "datasets-hpmlk.csv" file.   
#  Parameters                                                          
#     dataset: the specific dataset                                    
#  Return                                                              
#     Everything in the "datasets-hpmlk.csv" file.                     
#######################################################################
infoDataSet <- function(dataset){
  
  retorno = list()
  
  retorno$id = dataset$ID
  retorno$name = dataset$Name
  retorno$instances = dataset$Instances
  retorno$inputs = dataset$Inputs
  retorno$labels = dataset$Labels
  retorno$LabelsSets = dataset$LabelsSets
  retorno$single = dataset$Single
  retorno$maxfreq = dataset$MaxFreq
  retorno$card = dataset$Card
  retorno$dens = dataset$Dens
  retorno$mean = dataset$Mean
  retorno$scumble = dataset$Scumble
  retorno$tcs = dataset$TCS
  retorno$attStart = dataset$AttStart
  retorno$attEnd = dataset$AttEnd
  retorno$labStart = dataset$LabelStart
  retorno$labEnd = dataset$LabelEnd
  retorno$distinct = dataset$Distinct
  retorno$xn = dataset$xn
  retorno$yn = dataset$yn
  retorno$gridn = dataset$gridn
  
  return(retorno)
  
  gc()
}




###########################################################################
# Please, any errors, contact us: elainececiliagatto@gmail.com            #
# Thank you very much!                                                    #
###########################################################################
