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
build.utiml <- function(parameters){
  
  parameters = parameters
  
  f = 1
  build.paralel.ecc <- foreach(f = 1:parameters$Number.Folds) %dopar%{
    # while(f<=parameters$Number.Folds){
    
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
    
    Folder.Best.Partition.Split = paste(parameters$Folders$folderBestPartitions, 
                                        "/Split-", f, sep="")
    
    Folder.Tested.Split = paste(parameters$Folders$folderTested,
                                "/Split-", f, sep="")
    if(dir.create(Folder.Tested.Split)==FALSE){dir.create(Folder.Tested.Split)}
    
    Folder.BP = paste(parameters$Folders$folderBestPartitions, 
                      "/", parameters$Dataset.Name, sep="")
    
    Folder.BPF = paste(Folder.BP, "/Split-", f, sep="")
    
    Folder.BPGP = paste(Folder.BPF, "/Partition-", best.part.info.f$num.part, 
                        sep="")
    
    ########################################################################
    cat("\nOpening TRAIN file")
    train.name.file.csv = paste(parameters$Folders$folderCVTR, 
                                "/", parameters$Dataset.Name, 
                                "-Split-Tr-", f, ".csv", sep="")
    train.file = data.frame(read.csv(train.name.file.csv))
    
    
    #####################################################################
    cat("\nOpening VALIDATION file")
    val.name.file.csv = paste(parameters$Folders$folderCVVL, 
                              "/", parameters$Dataset.Name, 
                              "-Split-Vl-", f, ".csv", sep="")
    val.file = data.frame(read.csv(val.name.file.csv))
    
    
    ########################################################################
    cat("\nOpening TEST file")
    test.name.file.csv = paste(parameters$Folders$folderCVTS,
                               "/", parameters$Dataset.Name, 
                               "-Split-Ts-", f, ".csv", sep="")
    test.file = data.frame(read.csv(test.name.file.csv))
    
    
    ########################################################################
    cat("\nJoint Train and Validation")
    train.file.final = rbind(train.file, val.file)
    
    #######################################################################
    cat("\nGetting the instance space for train and test sets")
    arquivo.ts.att = test.file[, parameters$Dataset.Info$AttStart:parameters$Dataset.Info$AttEnd]
    arquivo.tr.att = train.file.final[, parameters$Dataset.Info$AttStart:parameters$Dataset.Info$AttEnd]
    
    #######################################################################
    cat("\nGetting the Y TRUE for train and test sets")
    ts.labels.true = test.file[, parameters$Dataset.Info$LabelStart:parameters$Dataset.Info$LabelEnd]
    tr.labels.true = train.file.final[, parameters$Dataset.Info$LabelStart:parameters$Dataset.Info$LabelEnd]
    
    ####################################################################################
    FolderSplit = paste(parameters$Folders$folderGlobal, "/Split-", f, sep="")
    if(dir.create(FolderSplit)==FALSE){dir.create(FolderSplit)}
    
    #######################################################################
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
    
    
    ##############################################################
    # DO PRIMEIRO ATÉ O ÚLTIMO CLUSTER FAÇA
    g = 1
    while(g<=best.part.info.f$num.group){
      
      cat("\n\n\t#================================================#")
        cat("\n\t# CLUSTER [", g, "]                              #")
        cat("\n\t#================================================#\n\n")
      
      #########################################################################
      cat("\n\tCreating folder")
      Folder.Test.Cluster = paste(Folder.Tested.Split, "/Group-", g, sep="")
      if(dir.exists(Folder.Test.Cluster)== FALSE){dir.create(Folder.Test.Cluster)}
      
      #########################################################################
      cat("\n\tSpecific Cluster")
      all.total.labels.g = data.frame(filter(all.total.labels.f, group == g))
      #build.datasets.g = data.frame(filter(build.datasets.f, num.cluster == g))
      cluster.specific = data.frame(filter(partition, group == g))
      cluster = cluster.specific$group
      labels = cluster.specific$label
      
      cat("\n\n\t#===============================================#")
        cat("\n\t# LABELS [", all.total.labels.g$totalLabels, "] #" )
        cat("\n\t#===============================================#\n\n")
      
      #########################################################################
      # se este for o cluster de número 1 então não tem labels para serem
      # agregados, apenas rodar normamente - mas se for composto por um 
      # único rótulo, deve ser executado o J48
      if(g==1){
        
        ################################################################
        # BUILDING TRAIN THE DATASET                                   #
        # Por ser o primeiro cluster não precisa adicionar rótulos de  #
        # outros clusters                                              #
        ################################################################
        
        cat("\n\tTRAIN: Build Cluster")
        train.attributes = train.file.final[parameters$Dataset.Info$AttStart:parameters$Dataset.Info$AttEnd]
        train.classes = select(train.file.final, cluster.specific$label)
        train.dataset = cbind(train.attributes, train.classes)
        
        cat("\n\tTEST: Build Cluster")
        test.attributes = test.file[parameters$Dataset.Info$AttStart:parameters$Dataset.Info$AttEnd]
        test.classes = select(test.file, cluster.specific$label)
        test.dataset = cbind(test.attributes, test.classes)
        
        cat("\n\tTEST: Getting Y True")
        setwd(Folder.Test.Cluster)
        write.csv(test.classes, "y_true.csv", row.names = FALSE)
        
        
        ################################################################
        cat("\n\tSaving info from cluster")
        
        fold = f
        cluster = g
        attr.start = 1
        attr.end = ncol(train.attributes) 
        new.attr.end = attr.end
        lab.att.start = 0
        lab.att.end = 0
        label.start = attr.end + 1
        label.end = ncol(train.dataset)
        labels.per.cluster = ncol(train.classes)
        label.as.attr = 0
        
        info.clusters = data.frame(fold, cluster, labels.per.cluster,
                                   attr.start, attr.end, new.attr.end, 
                                   lab.att.start, lab.att.end, 
                                   label.start, label.end,
                                   label.as.attr)
        
        all.info.clusters = rbind(all.info.clusters, info.clusters)
        
        
        #######################################################################
        # se o número de rótulos dentro do grupo for igual a 1 rodar o BR
        # caso contrário rodar o ECC
        # por ser o primeiro cluster não precisa mudar nada!
        #######################################################################
        if(all.total.labels.g$totalLabels==1){
          
          cat("\n\n\t#========================================#")
          cat("\n\t# Cluster ", g, " has only one label.    #")
          #cat("\n\t# Running J48 from RWeka.                #")
          cat("\n\t#========================================#\n\n")
          
          # separando os rótulos verdadeiros
          y_true = test.dataset[,parameters$Dataset.Info$LabelStart:parameters$Dataset.Info$LabelEnd]
          
          # gerando indices
          number = seq(parameters$Dataset.Info$LabelStart, parameters$Dataset.Info$LabelEnd, by=1)
          
          C50::C5.0(test.dataset)
          
          # transformando treino em mldr
          ds_train = mldr_from_dataframe(train.dataset, labelIndices = number)
          
          # transformando test em mldr
          ds_test = mldr_from_dataframe(test.dataset, labelIndices = number)
          
          # aplicando modelo br
          eccmodel = ecc(train.file, "C5.0", seed=123, attr.space=1.0)
          
          # testando modelo br
          predict <- predict(eccmodel, ds_test)
          
          # Apply a threshold
          thresholds <- scut_threshold(predict, ds_test, cores = number_cores)
          new.test <- fixed_threshold(predict, thresholds)
          
          new.test2 = as.matrix(new.test)
          y_predict = data.frame(new.test2)
          
          setwd(FolderSplit)
          write.csv(y_predict, "y_predict.csv", row.names = FALSE)
          write.csv(y_true, "y_true.csv", row.names = FALSE)
          
          
          cat("\n\n\t#==============================================#")
          cat("\n\t# END Cluster [", g, "]                       #")
          cat("\n\t#==============================================#\n\n")
          
        } else {
          
          cat("\n\n\t#==============================================#")
          cat("\n\t# Cluster [", g, "] has more than one label    #")
          cat("\n\t#==============================================#\n\n")
          
          
          # separando os rótulos verdadeiros
          y_true = test.file[,ds$LabelStart:ds$LabelEnd]
          
          # gerando indices
          number = seq(ds$LabelStart, ds$LabelEnd, by=1)
          
          # transformando treino em mldr
          ds_train = mldr_from_dataframe(train.file, labelIndices = number)
          
          # transformando test em mldr
          ds_test = mldr_from_dataframe(test.file, labelIndices = number)
          
          # aplicando modelo br
          eccmodel = ecc(train.file, "C5.0", seed=123, attr.space=1.0)
          
          # testando modelo br
          predict <- predict(eccmodel, ds_test)
          
          # Apply a threshold
          thresholds <- scut_threshold(predict, ds_test, cores = number_cores)
          new.test <- fixed_threshold(predict, thresholds)
          
          new.test2 = as.matrix(new.test)
          y_predict = data.frame(new.test2)
          
          setwd(FolderSplit)
          write.csv(y_predict, "y_predict.csv", row.names = FALSE)
          write.csv(y_true, "y_true.csv", row.names = FALSE)
          
          
          
          cat("\n\n\t#==============================================#")
          cat("\n\t# END Cluster [", g, "]                       #")
          cat("\n\t#==============================================#\n\n")
          
        }
        
        
      } else {
        
        # cat("\n\n\t#=================================#")
        #  cat("\n\t# SECOND AND SO ON CLUSTERS       #")
        #  cat("\n\t#=================================#\n")
        
        ################################################################
        # BUILDING TRAIN THE DATASET                                   #
        # Como este é o segundo cluster, então tem que adicionar os    #
        # rótulos do cluster anterior como atributos                   #
        ################################################################
        
        cat("\n\tGetting Label-Atrributes")
        nome = paste(Folder.Tested.Split, "/label-att-", g, ".csv", sep="")
        lab.att.config = data.frame(read.csv(nome))
        
        cat("\n\tTRAIN: Build Cluster")
        train.attributes.original = train.file.final[parameters$Dataset.Info$AttStart:parameters$Dataset.Info$AttEnd]
        
        cat("\n\tTRAIN: selecting label-atrributes with atrributes")
        labels.att = select(train.file.final, lab.att.config$label) 
        nomes = names(labels.att)
        nomes.2 = paste(nomes, "-att", sep="")
        names(labels.att) = nomes.2
        
        cat("\n\tTRAIN: joing label-atrributes with atrributes")
        train.attributes = cbind(train.attributes.original, labels.att)
        
        cat("\n\tTRAIN: getting classes")
        train.classes = select(train.file.final, cluster.specific$label)
        
        cat("\n\tTRAIN: build the final train dataset")
        train.dataset = cbind(train.attributes, train.classes)
        
        
        ################################################################
        fold = f
        cluster = g
        attr.start = 1
        attr.end = ncol(train.attributes.original)
        new.attr.end = ncol(train.attributes)
        lab.att.start = 1 + attr.end
        lab.att.end = new.attr.end
        label.start = 1 + new.attr.end
        label.end = ncol(train.dataset)
        labels.per.cluster = ncol(train.classes)
        label.as.attr = ncol(labels.att)
        
        info.clusters = data.frame(fold, cluster, labels.per.cluster,
                                   attr.start, attr.end, new.attr.end, 
                                   lab.att.start, lab.att.end, 
                                   label.start, label.end,
                                   label.as.attr)
        
        all.info.clusters = rbind(all.info.clusters, info.clusters)
        
        
        preds.as.att = data.frame(apagar=c(0))
        i = 2
        while(i<=all.total.labels.g$group){
          b = i - 1
          # cat("\n\tCluster Preds: ", b)
          Folder.Up.Group = paste(Folder.Tested.Split, "/Group-", b, sep="")
          preds = data.frame(read.csv(paste(Folder.Up.Group, "/y_pred.csv", sep=""))) 
          preds.as.att = cbind(preds.as.att, preds)
          i = i + 1
          gc(0)
        }
        
        
        ###################################################################
        # Se o número de colunas do resultado das predições for igual a 2 #
        # então significa que só há UM RÓTULO para ser adicionado         #
        ###################################################################
        if(ncol(preds.as.att)==2){ 
          cat("\n\tTEST: Only one prediction")
          nomes.1 = colnames(preds.as.att)
          nomes.2 = paste(colnames(preds.as.att), "-att", sep="")
          
          test.attributes = test.file[parameters$Dataset.Info$AttStart:parameters$Dataset.Info$AttEnd]
          
          test.attributes = cbind(test.attributes, preds.as.att[,2])
          ultima = ncol(test.attributes)
          colnames(test.attributes)[ultima] = nomes.2[2]
          
          test.classes = select(test.file, cluster.specific$label)
          test.dataset = cbind(test.attributes, test.classes)
          end.test.dataset = ncol(test.dataset)
          
        } else {
          cat("\n\tTEST: More than one prediction")
          preds.as.att = preds.as.att[,-1]
          test.attributes = test.file[parameters$Dataset.Info$AttStart:parameters$Dataset.Info$AttEnd]
          
          nomes = names(preds.as.att)
          nomes.2 = paste(nomes, "-att", sep="")
          names(preds.as.att) = nomes.2
          
          test.attributes = cbind(test.attributes, preds.as.att)
          test.classes = select(test.file, cluster.specific$label)
          test.dataset = cbind(test.attributes, test.classes)
          end.test.dataset = ncol(test.dataset)
        }
        
        
        
        ###################################################################
        # Se o número de rotulos do grupo for igual a 1 então precisa     #
        # rodar o Br. Nesse caso, tenho que juntar todos os rótulos       #
        # do dataset pois o pacote trabalha assim                         #
        ###################################################################
        if(all.total.labels.g$totalLabels==1){
          
          cat("\n\n\t#========================================#")
          cat("\n\t# Cluster ", g, " has only one label.    #")
          cat("\n\t#========================================#\n\n")
          
          
          cat("\n\n\t#==============================================#")
          cat("\n\t# END Cluster [", g, "]                        #")
          cat("\n\t#==============================================#\n\n")
          
        } else {
          
          cat("\n\n\t#==============================================#")
          cat("\n\t# Cluster [", g, "] has more than one label    #")
          cat("\n\t#==============================================#\n\n")
          
          
          cat("\n\n\t#==============================================#")
          cat("\n\t# END Cluster [", g, "]                        #")
          cat("\n\t#==============================================#\n\n")
          
        }
        
        cat("\n")
        
      }
      
      setwd(Folder.Tested.Split)
      name = paste("info-cluster-", f, ".csv", sep="")
      write.csv(all.info.clusters[-1,], name, row.names = FALSE)
      
      g = g + 1
      gc()
      cat("\n")
    } # fim do grupo
    
    # f = f + 1
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
# FUNCTION GATHER PREDICTIONS - BUILD CONFUSION MATRIX                       #
#   Objective                                                                #
#   Parameters                                                               #
##############################################################################
gather.predicts.utiml <- function(parameters){
  
  f = 1
  gatherR <- foreach(f = 1:parameters$Number.Folds) %dopar%{
    #while(f<=parameters$index.dataset.Folds){
    
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
    
    ################################################################
    apagar = c(0)
    y_true = data.frame(apagar)
    y_pred = data.frame(apagar)
    
    # GROUP
    g = 1
    while(g<=best.part.info.f$num.group){
      
      cat("\n#=========================================================")
      cat("\n# Group = ", g)
      cat("\n#=========================================================")
      
      FolderTestGroup = paste(Folder.Tested.Split, "/Group-", g, sep="")
      
      #######################################################
      nome = paste(Folder.Tested.Split, "/label-att-", g, ".csv", sep="")
      unlink(nome)
      
      #######################################################
      #cat("\nSpecific Group: ", g, "\n")
      cluster.specific = filter(partition, group == g)
      
      #cat("\n\nGather y_true ", g)
      setwd(FolderTestGroup)
      #setwd(FolderTG)
      y_true_gr = data.frame(read.csv("y_true.csv"))
      y_true = cbind(y_true, y_true_gr)
      
      setwd(FolderTestGroup)
      #setwd(FolderTG)
      #cat("\n\nGather y_predict ", g)
      y_pred_gr = data.frame(read.csv("y_pred.csv"))
      y_pred = cbind(y_pred, y_pred_gr)
      
      # cat("\n\nDeleting files")
      # unlink("y_true.csv", recursive = TRUE)
      # unlink("y_pred.csv", recursive = TRUE)
      unlink("inicioFimRotulos.csv", recursive = TRUE)
      
      g = g + 1
      gc()
    } # FIM DO GRUPO
    
    #cat("\n\nSave files ", g, "\n")
    setwd(Folder.Tested.Split)
    y_pred = y_pred[,-1]
    y_true = y_true[,-1]
    write.csv(y_pred, "y_predict.csv", row.names = FALSE)
    write.csv(y_true, "y_true.csv", row.names = FALSE)
    
    #f = f + 1
    gc()
  } # fim do foreach
  
  gc()
  cat("\n###############################################################")
  cat("\n# Gather Predicts: END                                        #")
  cat("\n###############################################################")
  cat("\n\n\n\n")
  
} # fim da função


##############################################################################
# FUNCTION EVALUATE TESTED HYBRID PARTITIONS                                 #
#   Objective                                                                #
#   Parameters                                                               #
##############################################################################
evaluate.mulan <- function(parameters){
  
  f = 1
  avalParal <- foreach(f = 1:parameters$Number.Folds) %dopar%{
    #while(f<=parameters$/dataset.Folds){
    
    
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
    # unlink("y_true.csv", recursive = TRUE)
    # unlink("y_predict.csv", recursive = TRUE)
    
    #f = f + 1
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
gather.evaluated.mulan <- function(parameters){
  
  
  ##########################################################################
  apagar = c(0)
  avaliado.final = data.frame(apagar)
  nomes = c("")
  
  # from fold = 1 to index.dataset_folders
  f = 1
  while(f<=parameters$Number.Folds){
    
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
