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
# SET WORKSAPCE                                                               #
###############################################################################
FolderRoot = "~/Chains-Hybrid-Partition"
FolderScripts = "~/Chains-Hybrid-Partition/R"



##############################################################################
# FUNCTION BUILD AND TEST SELECTED HYBRID PARTITION                          #
#   Objective                                                                #
#   Parameters                                                               #
##############################################################################
build.python <- function(parameters){
  
  parameters = parameters
  
  f = 1
  build.paralel.ecc <- foreach(f = 1:parameters$number.folds) %dopar%{
  # while(f<=parameters$number.folds){
    
    
    cat("\n\n\n#===================================================#")
    cat("\n# FOLD [", f, "]                                      #")
    cat("\n#====================================================#\n\n\n")
    
    
    ########################################################################
    cat("\nWorkSpace")
    FolderRoot = "~/Chains-Hybrid-Partition"
    FolderScripts = "~/Chains-Hybrid-Partition/R"
    
    ########################################################################
    cat("\nLoad Scripts")
    setwd(FolderScripts)
    source("utils.R")
    
    setwd(FolderScripts)
    source("libraries.R")
    
    setwd(FolderScripts)
    source("misc.R")
    
    
    ########################################################################
    cat("\nGetting information about clusters")
    best.part.info = data.frame(parameters$All.Partitions$best.part.info)
    all.partitions.info = data.frame(parameters$All.Partitions$all.partitions.info )
    all.total.labels = data.frame(parameters$All.Partitions$all.total.labels)
    
    best.part.info.f = data.frame(filter(best.part.info, num.fold==f))
    all.total.labels.f = data.frame(filter(all.total.labels, num.fold==f))
    # build.datasets.f = data.frame(filter(parameters$Labels.Attr$all.info, num.fold==f))
    
    # partição específica
    partition = data.frame(filter(all.partitions.info, num.fold==f))
    
    ##########################################################################
    cat("\nCreating Folders from Best Partitions and Splits Tests")
    
    Folder.Best.Partition.Split = paste(parameters$Folders$folderBPSC, 
                                        "/", parameters$dataset.name,
                                        "/Split-", f, sep="")
    
    Folder.Tested.Split = paste(parameters$Folders$folderTested,
                                "/Split-", f, sep="")
    if(dir.create(Folder.Tested.Split)==FALSE){dir.create(Folder.Tested.Split)}
    
    Folder.BP = paste(parameters$Folders$folderBPSC, 
                      "/", parameters$Dataset.Name, sep="")
    
    Folder.BPF = paste(Folder.BP, "/Split-", f, sep="")
    
    Folder.BPGP = paste(Folder.BPF, "/Partition-", best.part.info.f$num.part, 
                        sep="")
    
    ########################################################################
    cat("\nOpening TRAIN file")
    train.name.file.csv = paste(parameters$Folders$folderCVTR, 
                                "/", parameters$dataset.name, 
                                "-Split-Tr-", f, ".csv", sep="")
    train.file = data.frame(read.csv(train.name.file.csv))
    
    
    #####################################################################
    cat("\nOpening VALIDATION file")
    val.name.file.csv = paste(parameters$Folders$folderCVVL, 
                              "/", parameters$dataset.name, 
                              "-Split-Vl-", f, ".csv", sep="")
    val.file = data.frame(read.csv(val.name.file.csv))
    
    
    ########################################################################
    cat("\nOpening TEST file")
    test.name.file.csv = paste(parameters$Folders$folderCVTS,
                               "/", parameters$dataset.name, 
                               "-Split-Ts-", f, ".csv", sep="")
    test.file = data.frame(read.csv(test.name.file.csv))
    
    
    ########################################################################
    cat("\nJoint Train and Validation")
    train.file.final = rbind(train.file, val.file)
    
    #######################################################################
    cat("\nGetting the instance space for train and test sets")
    arquivo.ts.att = test.file[, parameters$dataset.info$AttStart:parameters$dataset.info$AttEnd]
    arquivo.tr.att = train.file.final[, parameters$dataset.info$AttStart:parameters$dataset.info$AttEnd]
    
    cat("\nGetting the Y TRUE for train and test sets")
    ts.labels.true = test.file[, parameters$dataset.info$LabelStart:parameters$dataset.info$LabelEnd]
    tr.labels.true = train.file.final[, parameters$dataset.info$LabelStart:parameters$dataset.info$LabelEnd]
    
    ####################
    # /dev/shm/python-j3-GpositiveGO/Best-Partitions/GpositiveGO/
    # Split-1/Partition-2
    partition.csv.name = paste(Folder.Best.Partition.Split, 
                               "/Partition-", 
                               best.part.info.f$num.part, 
                               "/partition-", best.part.info.f$num.part, 
                               ".csv", sep="")
    
    # file.exists(partition.csv.name)
    
    ##############################
    fold = c(0)
    cluster = c(0)
    attr.start = c(0)
    attr.end = c(0)
    new.attr.end = c(0)
    lab.att.start = c(0)
    lab.att.end = c(0)
    label.start = c(0)
    label.end = c(0)
    labels.per.cluster = c(0)
    label.as.attr = c(0)
    all.info.clusters = data.frame(fold, cluster, labels.per.cluster,
                                   attr.start, attr.end, new.attr.end, 
                                   lab.att.start, lab.att.end, 
                                   label.start, label.end,
                                   label.as.attr)
    
    setwd(Folder.Tested.Split)
    write.csv(all.info.clusters,
              paste("info-cluster-", f, ".csv", sep=""),
              row.names = FALSE)
    
    ##################################################################
    # EXECUTE ECC PYTHON
    str.execute = paste("python3 ",parameters$Folders$folderEccPython, 
                        "/main.py ", 
                        train.name.file.csv, " ",
                        val.name.file.csv,  " ",
                        test.name.file.csv, " ", 
                        partition.csv.name, " ", 
                        Folder.Tested.Split, 
                        sep="")
    
    # EXECUTA
    res = print(system(str.execute))
    
    str = paste("rm -rf ",Folder.Tested.Split, "/Group-*", sep="")
    system(str)
    
    str = paste("rm -rf ",Folder.Tested.Split, "/label-att-*", sep="")
    system(str)
    
    # str.1 = paste("mv ", FolderScripts, "/y_pred.csv ", Folder.Tested.Split, sep="")
    # str.2 = paste("mv ", FolderScripts, "/y_true.csv ", Folder.Tested.Split, sep="")
    # print(system(str.1))
    # print(system(str.2))
    
    setwd(Folder.Tested.Split)
    y_preds = data.frame(read.csv("y_pred.csv"))
    y_trues = data.frame(read.csv("y_true.csv"))
    
    #####################################################################
    cat("\n\tUTIML Threshold\n")
    utiml.threshold <- scut_threshold(y_preds, test.file)
    final.predictions <- data.frame(as.matrix(fixed_threshold(y_preds, 
                                                              utiml.threshold)))
    
    setwd(Folder.Tested.Split)
    write.csv(final.predictions, "y_predict.csv", row.names = FALSE)
    
    
    #####################################################################
    cat("\n\tSave original and pruned predictions\n")
    pred.o = paste(colnames(y_preds), "-pred-ori", sep="")
    names(y_preds) = pred.o
    
    pred.c = paste(colnames(final.predictions), "-pred-cut", sep="")
    names(final.predictions) = pred.c
    
    true.labels = paste(colnames(y_trues), "-true", sep="")
    names(y_trues) = true.labels
    
    all.predictions = cbind(y_preds, final.predictions, y_trues)
    setwd(Folder.Tested.Split)
    write.csv(all.predictions, "folder-predictions.csv", row.names = FALSE)
    
    unlink("y_pred.csv")
    
    #f = f + 1
    gc()
    cat("\n")
  } # fim do for each
  
  gc()
  cat("\n##################################################")
  cat("\n# TEST: Build and Test Hybrid Partitions End     #")
  cat("\n##################################################")
  cat("\n\n\n\n")
}



##############################################################################
# FUNCTION EVALUATE TESTED HYBRID PARTITIONS                                 #
#   Objective                                                                #
#   Parameters                                                               #
##############################################################################
evaluate.python <- function(parameters){
  
  f = 1
  avalParal <- foreach(f = 1:parameters$number.folds) %dopar%{
  # while(f<=parameters$number.folds){
    
    
    cat("\n\n\n#======================================================")
    cat("\n# Fold: ", f)
    cat("\n#======================================================\n\n\n")
    
    
    ########################################################################
    cat("\nDefinindo diretório de trabalho")
    FolderRoot = "~/Chains-Hybrid-Partition"
    FolderScripts = "~/Chains-Hybrid-Partition/R"
    
    ########################################################################
    cat("\nCarregando scripts")
    setwd(FolderScripts)
    source("utils.R")
    
    setwd(FolderScripts)
    source("libraries.R")
    
    setwd(FolderScripts)
    source("misc.R")
    
    
    ########################################################################
    cat("\nObtendo informações dos clusters para construir os datasets")
    best.part.info = data.frame(parameters$All.Partitions$best.part.info)
    all.partitions.info = data.frame(parameters$All.Partitions$all.partitions.info )
    all.total.labels = data.frame(parameters$All.Partitions$all.total.labels)
    
    best.part.info.f = data.frame(filter(best.part.info, num.fold==f))
    all.total.labels.f = data.frame(filter(all.total.labels, num.fold==f))
    build.datasets.f = data.frame(filter(parameters$Labels.Attr$all.info, num.fold==f))
    
    # partição específica
    partition = data.frame(filter(all.partitions.info, num.fold==f))
    
    ##########################################################################
    # "/dev/shm/ej3-GpositiveGO/Tested/Split-1"
    Folder.Tested.Split = paste(parameters$Folders$folderTested,
                                "/Split-", f, sep="")
    
    ##########################################################################
    #cat("\nData frame")
    apagar = c(0)
    confMatPartitions = data.frame(apagar)
    partitions = c()
    
    #cat("\nGet the true and predict lables")
    setwd(Folder.Tested.Split)
    y_true = data.frame(read.csv("y_true.csv"))
    y_pred = data.frame(read.csv("y_predict.csv"))
    
    
    #cat("\nCompute measures multilabel")
    y.true = data.frame(sapply(y_true, function(x) as.numeric(as.character(x))))
    y_true3 = mldr_from_dataframe(y.true , labelIndices = seq(1,ncol(y.true )), name = "y.true")
    y_pred2 = sapply(y_pred, function(x) as.numeric(as.character(x)))
    
    #cat("\nSave Confusion Matrix")
    setwd(Folder.Tested.Split)
    salva3 = paste("Conf-Mat-Fold-", f, ".txt", sep="")
    sink(file=salva3, type="output")
    confmat = multilabel_confusion_matrix(y_true3, y_pred2)
    print(confmat)
    sink()
    
    #cat("\nCreating a data frame")
    confMatPart = multilabel_evaluate(confmat)
    confMatPart = data.frame(confMatPart)
    names(confMatPart) = paste("Fold-", f, sep="")
    namae = paste("Split-", f, "-Evaluated.csv", sep="")
    setwd(Folder.Tested.Split)
    write.csv(confMatPart, namae)
    
    cat("\nDelete files")
    setwd(Folder.Tested.Split)
    unlink("y_true.csv", recursive = TRUE)
    unlink("y_predict.csv", recursive = TRUE)
    
    f = f + 1
    gc()
  } # fim do for each
  
  gc()
  cat("\n###################################################")
  cat("\n# TEST: Evaluation Folds END                      #")
  cat("\n###################################################")
  cat("\n\n")
}



##############################################################################
# FUNCTION GATHER EVALUATION                                                 #
#   Objective                                                                #
#   Parameters                                                               #
##############################################################################
gather.evaluated.python <- function(parameters){
  
  
  ##########################################################################
  apagar = c(0)
  avaliado.final = data.frame(apagar)
  nomes = c("")
  
  # from fold = 1 to index.dataset_folders
  f = 1
  while(f<=parameters$number.folds){
    
    cat("\n#======================================================")
    cat("\n# Fold: ", f)
    cat("\n#======================================================\n")
    
    # vector with names
    measures = c("accuracy","average-precision","clp","coverage","F1",
                 "hamming-loss","macro-AUC", "macro-F1","macro-precision",
                 "macro-recall","margin-loss","micro-AUC","micro-F1",
                 "micro-precision","micro-recall","mlp","one-error",
                 "precision","ranking-loss", "recall","subset-accuracy","wlp")
    
    ##########################################################################
    # "/dev/shm/ej3-GpositiveGO/Tested/Split-1"
    Folder.Tested.Split = paste(parameters$Folders$folderTested,
                                "/Split-", f, sep="")
    
    
    ######################################################################
    setwd(Folder.Tested.Split)
    str = paste("Split-", f, "-Evaluated.csv", sep="")
    avaliado = data.frame(read.csv(str))
    avaliado.final= cbind(avaliado.final, avaliado[,2])
    nomes[f] = paste("Fold-", f, sep="")
    
    f = f + 1
    gc()
    
  } # end folds
  
  
  avaliado.final = avaliado.final[,-1]
  names(avaliado.final) = nomes
  avaliado.final = cbind(measures, avaliado.final)

  setwd(Folder.Tested.Split)
  write.csv(avaliado, paste("Evaluated-Fold-", f, ".csv", sep=""),
            row.names = FALSE)
  
  # calculando a média dos 10 folds para cada medida
  media = data.frame(apply(avaliado.final[,-1], 1, mean))
  media = cbind(measures, media)
  names(media) = c("Measures", "Mean10Folds")
  
  setwd(parameters$Folders$folderTested)
  write.csv(media, "Mean10Folds.csv", row.names = FALSE)
  
  mediana = data.frame(apply(avaliado.final[,-1], 1, median))
  mediana = cbind(measures, mediana)
  names(mediana) = c("Measures", "Median10Folds")
  
  setwd(parameters$Folders$folderTested)
  write.csv(mediana, "Median10Folds.csv", row.names = FALSE)
  
  dp = data.frame(apply(avaliado.final[,-1], 1, sd))
  dp = cbind(measures, dp)
  names(dp) = c("Measures", "SD10Folds")
  
  setwd(parameters$Folders$folderTested)
  write.csv(dp, "desvio-padrão-10-folds.csv", row.names = FALSE)
  
  
  gc()
  cat("\n######################################################")
  cat("\n# TEST: Gather Evaluations End                       #")
  cat("\n######################################################")
  cat("\n\n\n\n")
  
}




#########################################################################
# Please, any errors, contact us: elainececiliagatto@gmail.com
# Thank you very much!
#########################################################################
