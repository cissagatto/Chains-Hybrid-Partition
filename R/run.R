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



###############################################################################
# Runs for all datasets listed in the "datasets.csv" file
# n_dataset: number of the dataset in the "datasets.csv"
# number_cores: number of cores to paralell
# number_folds: number of folds for cross validation
# delete: if you want, or not, to delete all folders and files generated
########################################################################
executa <- function(parameters){

  ##########################################################################
  # Workspace
  FolderRoot = "~/Chains-Hybrid-Partition"
  FolderScripts = "~/Chains-Hybrid-Partition/R"
  
  ##########################################################################
  # LOAD LIBRARIES
  setwd(FolderScripts)
  source("libraries.R")

  setwd(FolderScripts)
  source("utils.R")
  
  setwd(FolderScripts)
  source("misc.R")
  
  
  ##########################################################################
  if(parameters$Number.Cores == 0){

    cat("\n\n############################################################")
      cat("\n# RUN: Zero is a disallowed value for number_cores. Please #")
      cat("\n# choose a value greater than or equal to 1.               #")
      cat("\n############################################################\n\n")

  } else {

    cl <- parallel::makeCluster(parameters$Number.Cores)
    doParallel::registerDoParallel(cl)
    print(cl)

    if(number_cores==1){
      cat("\n\n########################################################")
        cat("\n# RUN: Running Sequentially!                           #")
        cat("\n########################################################\n\n")
    } else {
      cat("\n\n######################################################################")
        cat("\n# RUN: Running in parallel with ", parameters$Number.Cores, " cores! #")
        cat("\n######################################################################\n\n")
    }
  }
  cl = cl

  retorno = list()

  cat("\n\n########################################################")
    cat("\n# RUN: Get labels                                      #")
    cat("\n########################################################\n\n")
  arquivo = paste(parameters$Folders$folderNamesLabels, "/" ,
                  dataset_name, "-NamesLabels.csv", sep="")
  namesLabels = data.frame(read.csv(arquivo))
  colnames(namesLabels) = c("id", "labels")
  namesLabels = c(namesLabels$labels)
  parameters$NamesLabels = namesLabels
  
  
  cat("\n\n###############################################################")
    cat("\n# RUN: Get the label space                                    #")
    cat("\n###############################################################\n\n")
  timeLabelSpace = system.time(resLS <- labelSpace(parameters))
  parameters$resLS = resLS
  
  
  cat("\n\n####################################################")
    cat("\n# RUN: Get all partitions                          #")
    cat("\n####################################################\n\n")
  timeAllPartitions = system.time(resAP <- get.all.partitions(parameters))
  parameters$All.Partitions = resAP
  
  
  cat("\n\n#####################################################")
    cat("\n# RUN: Compute Label Atributes                      #")
    cat("\n#####################################################\n\n")
  timeCLA = system.time(resCLA <- compute.labels.attributes(parameters))
  parameters$Labels.Attr = resCLA
  
  
  if(parameters$classificador=="ecc"){
    
    setwd(FolderScripts)
    source("testECC.R")
    
    cat("\n\n##############################################")
      cat("\n# RUN: build and test partitions             #")
      cat("\n##############################################\n\n")
    timeBuild = system.time(resBT <- build.ecc(parameters))
    
    
    cat("\n\n##############################################")
      cat("\n# RUN: Matrix Confusion                      #")
      cat("\n##############################################\n\n")
    timeSplit = system.time(resGather <- gather.predicts.ecc(parameters))
    
    
    cat("\n\n###############################################")
      cat("\n# RUN: Evaluation Fold                        #")
      cat("\n###############################################\n\n")
    timeAvalia = system.time(resEval <- evaluate.ecc(parameters))
    
    
    cat("\n\n##############################################")
      cat("\n# RUN: Gather Evaluation                     #")
      cat("\n##############################################\n\n")
    timeGather = system.time(resGE <- gather.evaluated.ecc(parameters))
    
    
    cat("\n\n##############################################")
      cat("\n# RUN: Save Runtime                          #")
      cat("\n##############################################\n\n")
    Runtime = rbind(timeBuild,
                    timeSplit,
                    timeAvalia,
                    timeGather)
    setwd(parameters$Folders$folderTested)
    write.csv(Runtime, paste(parameters$Dataset.Name,
                             "-test-runtime-ecc.csv", sep=""),
              row.names = FALSE)
    
  } else {
    
    setwd(FolderScripts)
    source("testClus.R")
    
    cat("\n\n##############################################")
    cat("\n# RUN: build and test partitions             #")
    cat("\n##############################################\n\n")
    timeBuild = system.time(resBT <- build.clus(parameters))
   
    cat("\n\n##############################################")
    cat("\n# RUN: Matrix Confusion                      #")
    cat("\n##############################################\n\n")
    timeSplit = system.time(resGather <- gather.predicts.clus(parameters))
    
    
    cat("\n\n###############################################")
    cat("\n# RUN: Evaluation Fold                        #")
    cat("\n###############################################\n\n")
    timeAvalia = system.time(resEval <- evaluate.clus(parameters))
    
    
    cat("\n\n##############################################")
    cat("\n# RUN: Gather Evaluation                     #")
    cat("\n##############################################\n\n")
    timeGather = system.time(resGE <- gather.evaluated.clus(parameters))
    
    
    cat("\n\n##############################################")
    cat("\n# RUN: Save Runtime                          #")
    cat("\n##############################################\n\n")
    Runtime = rbind(timeBuild,
                    timeSplit,
                    timeAvalia,
                    timeGather)
    setwd(parameters$Folders$folderTested)
    write.csv(Runtime, paste(parameters$Dataset.Name,
                             "-test-runtime-clus.csv", sep=""),
              row.names = FALSE)
    
  }


  cat("\n\n##########################################################")
    cat("\n# RUN: Stop Parallel                                     #")
    cat("\n##########################################################\n\n")
  parallel::stopCluster(cl)


  gc()
  cat("\n\n##########################################################")
    cat("\n# RUN: END                                               #")
    cat("\n##########################################################\n\n")

}


##########################################################################
# Please, any errors, contact us: elainececiliagatto@gmail.com           #
# Thank you very much!                                                   #
##########################################################################
