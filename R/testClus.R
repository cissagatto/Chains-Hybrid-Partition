###############################################################################

# Copyright (C) 2022
#
# This code is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option)
# any later version. This code is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
# Public License for more details.
#
# Elaine Cecilia Gatto | Prof. Dr. Ricardo Cerri | Prof. Dr. Mauri Ferrandin
# Federal University of Sao Carlos (UFSCar: https://www2.ufscar.br/) Campus
# Sao Carlos Computer Department (DC: https://site.dc.ufscar.br/)
# Program of Post Graduation in Computer Science
# (PPG-CC: http://ppgcc.dc.ufscar.br/)
# Bioinformatics and Machine Learning Group
# (BIOMAL: http://www.biomal.ufscar.br/)
#
###############################################################################


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
build.clus <- function(parameters){
  
  parameters = parameters
  
  f = 1
  buildParalel <- foreach(f = 1:parameters$Number.Folds) %dopar%{
  # while(f<=parameters$Number.Folds){
    
    cat("\n\n\n#======================================================")
    cat("\n# Fold: ", f)
    cat("\n#======================================================\n\n\n")
    
    
    ########################################################################
    cat("\nDefinindo diretório de trabalho")
    FolderRoot = "~/Chains-Hybrid-Partition"
    FolderScripts = "~/Chains-Hybrid-Partition/R"
    
    ########################################################################
    # cat("\nCarregando scripts")
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
    cat("\nCreating Folders from Best Partitions and Splits Tests")
    
    # "/dev/shm/ej3-GpositiveGO/Best-Partitions/Split-1"
    Folder.Best.Partition.Split = paste(parameters$Folders$folderBestPartitions, 
                                        "/Split-", f, sep="")
    
    # "/dev/shm/ej3-GpositiveGO/Tested/Split-1"
    Folder.Tested.Split = paste(parameters$Folders$folderTested,
                                "/Split-", f, sep="")
    if(dir.create(Folder.Tested.Split)==FALSE){dir.create(Folder.Tested.Split)}
    
    # "/dev/shm/ej3-GpositiveGO/Best-Partitions/GpositiveGO"
    Folder.BP = paste(parameters$Folders$folderBestPartitions, 
                      "/", parameters$Dataset.Name, sep="")
    
    # cat("\nGet the number of groups for this partition in this fold \n")
    Folder.BPF = paste(Folder.BP, "/Split-", f, sep="")
    
    # "/dev/shm/ej3-GpositiveGO/Best-Partitions/GpositiveGO/Split-1/Partition-2"
    Folder.BPGP = paste(Folder.BPF, "/Partition-", best.part.info.f$num.part, 
                        sep="")
    
    ########################################################################
    cat("\nOpening TRAIN file")
    train_name_file_csv = paste(parameters$Folders$folderCVTR, 
                                "/", parameters$Dataset.Name, "-Split-Tr-", f,
                                ".csv", sep="")
    train_file = data.frame(read.csv(train_name_file_csv))
    
    
    #####################################################################
    cat("\nOpening VALIDATION file")
    val_name_file_csv = paste(parameters$Folders$folderCVVL, 
                              "/", parameters$Dataset.Name, "-Split-Vl-", f,
                              ".csv", sep="")
    val_file = data.frame(read.csv(val_name_file_csv))
    
    
    ########################################################################
    # "/dev/shm/ej3-GpositiveGO/Datasets/GpositiveGO/CrossValidation/Ts/GpositiveGO-Split-Ts-1.csv"
    cat("\nOpening TEST file")
    test_name_file_csv = paste(parameters$Folders$folderCVTS,
                               "/", parameters$Dataset.Name, "-Split-Ts-", f,
                               ".csv", sep="")
    test_file = data.frame(read.csv(test_name_file_csv))
    
    
    ########################################################################
    cat("\nJuntando treino com validação")
    train_file_final = rbind(train_file, val_file)
    
    ########################################################################
    cat("\nRodando o BR")
    
    # gerando indices
    number = seq(parameters$Dataset.Info$LabelStart,
                 parameters$Dataset.Info$LabelEnd, by=1)
    
    # transformando treino em mldr
    ds_train = mldr_from_dataframe(train_file_final, labelIndices = number)
    br_train = mldr_transform(ds_train, type = "BR")
    
    # transformando test em mldr
    ds_test = mldr_from_dataframe(test_file, labelIndices = number)
    br_test = mldr_transform(ds_test, type = "BR")
    
    # separando os atributos
    arquivo.ts.att = test_file[, parameters$Dataset.Info$AttStart:parameters$Dataset.Info$AttEnd]
    arquivo.tr.att = train_file_final[, parameters$Dataset.Info$AttStart:parameters$Dataset.Info$AttEnd]
    
    # separando os rótulos verdadeiros
    # y_true = arquivo_ts[,ds$LabelStart:ds$LabelEnd]
    arquivo.ts.labels = test_file[, parameters$Dataset.Info$LabelStart:parameters$Dataset.Info$LabelEnd]
    arquivo.tr.labels = train_file_final[, parameters$Dataset.Info$LabelStart:parameters$Dataset.Info$LabelEnd]
    
    # aplicando modelo br
    brmodel = br(ds_train, "C5.0", seed=123, cores = parameters$Number.Cores)
    
    # testando modelo br
    predict_tbr <- predict(brmodel, ds_test, cores=parameters$Number.Cores)
    
    # Apply a threshold
    thresholds_br <- scut_threshold(predict_tbr, ds_test,
                                    cores = parameters$Number.Cores)
    new.ts.br <- fixed_threshold(predict_tbr, thresholds_br)
    new.ts.br2 = as.matrix(new.ts.br)
    new.ts.br3 = data.frame(new.ts.br2)
    
    g = 1
    while(g<=best.part.info.f$num.group){
      
      cat("\n\n#=======================================================")
      cat("\n# Group = ", g)
      cat("\n#=======================================================\n\n")
      
      #########################################################################
      cat("\ncreating folder")
      Folder.Test.Group = paste(Folder.Tested.Split, "/Group-", g, sep="")
      if(dir.exists(Folder.Test.Group)== FALSE){dir.create(Folder.Test.Group)}
      
      #########################################################################
      cat("\nPegando informações do grupo específico")
      all.total.labels.g = data.frame(filter(all.total.labels.f, group == g))
      build.datasets.g = data.frame(filter(build.datasets.f, num.cluster == g))
      
      grupoEspecifico = data.frame(filter(partition, group == g))
      cluster = grupoEspecifico$group
      labels = grupoEspecifico$label
      
      if(g==1){
        
        cat("\nEste é o primeiro cluster")
        
        ################################################################
        cat("\nTRAIN: Mount Group ", g, "\n")
        train_attributes = train_file_final[parameters$Dataset.Info$AttStart:parameters$Dataset.Info$AttEnd]
        train_classes = select(train_file_final, grupoEspecifico$label)
        train_group = cbind(train_attributes, train_classes)
        fim_tr = ncol(train_group)
        
        
        #####################################################################
        cat("\nTRAIN: Save Group", g, "\n")
        train_name_group_csv = paste(Folder.Test.Group, "/", parameters$Dataset.Name, 
                                     "-split-tr-", f, "-group-", g, ".csv", sep="")
        write.csv(train_group, train_name_group_csv, row.names = FALSE)
        
        
        #####################################################################
        cat("\nINICIO FIM TARGETS: ", g, "\n")
        start = parameters$Dataset.Info$LabelStart
        end = fim_tr
        ifr = data.frame(start, end)
        #setwd(Folder.Test.Group)
        #write.csv(ifr, "inicioFimRotulos.csv", row.names = FALSE)
        
        
        ####################################################################
        cat("\nTRAIN: Convert Train CSV to ARFF ", g , "\n")
        train_name_group_arff = paste(Folder.Test.Group, "/", parameters$Dataset.Name, 
                                      "-split-tr-", f, "-group-", g, ".arff", sep="")
        arg1Tr = train_name_group_csv
        arg2Tr = train_name_group_arff
        arg3Tr = paste(start, "-", end, sep="")
        str = paste("java -jar ", parameters$Folders$folderUtils,
                    "/R_csv_2_arff.jar ", arg1Tr, " ", arg2Tr, " ",
                    arg3Tr, sep="")
        print(system(str))
        
        
        ##################################################################
        cat("\nTRAIN: Verify and correct {0} and {1} ", g , "\n")
        str0 = paste("sed -i 's/{0}/{0,1}/g;s/{1}/{0,1}/g' ", arg2Tr, sep="")
        print(system(str0))
        
        ##############################################
        cat("\nApagando arquivo csv")
        setwd(Folder.Test.Group)
        unlink(train_name_group_csv)
        
        
        ################################################################
        cat("\nTRAIN: Mount Group ", g, "\n")
        test_attributes = test_file[parameters$Dataset.Info$AttStart:parameters$Dataset.Info$AttEnd]
        test_classes = select(test_file, grupoEspecifico$label)
        test_group = cbind(test_attributes, test_classes)
        fim_ts = ncol(test_group)
        
        
        ################################################################
        cat("\nSALVANDO OS Y TRUE")
        setwd(Folder.Test.Group)
        write.csv(test_classes, "y_true.csv", row.names = FALSE)
        
        
        #####################################################################
        cat("\nTRAIN: Save Group", g, "\n")
        test_name_group_csv = paste(Folder.Test.Group, "/", parameters$Dataset.Name, 
                                    "-split-ts-", f, "-group-", g, ".csv", sep="")
        write.csv(test_group, test_name_group_csv, row.names = FALSE)
        
        
        #####################################################################
        cat("\nINICIO FIM TARGETS: ", g, "\n")
        start = parameters$Dataset.Info$LabelStart
        end = fim_ts
        ifr = data.frame(start, end)
        #setwd(Folder.Test.Group)
        #write.csv(ifr, "inicioFimRotulos.csv", row.names = FALSE)
        
        
        ####################################################################
        cat("\nTRAIN: Convert Train CSV to ARFF ", g , "\n")
        test_name_group_arff = paste(Folder.Test.Group, "/", parameters$Dataset.Name, 
                                     "-split-ts-", f, "-group-", g, ".arff", sep="")
        arg1Ts = test_name_group_csv
        arg2Ts = test_name_group_arff
        arg3Ts = paste(start, "-", end, sep="")
        str = paste("java -jar ", parameters$Folders$folderUtils,
                    "/R_csv_2_arff.jar ", arg1Ts, " ", arg2Ts, " ",
                    arg3Ts, sep="")
        print(system(str))
        
        
        ##################################################################
        cat("\nTRAIN: Verify and correct {0} and {1} ", g , "\n")
        str0 = paste("sed -i 's/{0}/{0,1}/g;s/{1}/{0,1}/g' ", arg2Ts, sep="")
        print(system(str0))
        
        
        ##############################################
        cat("\nApagando arquivo csv")
        setwd(Folder.Test.Group)
        unlink(test_name_group_csv)
        
        
        #####################################################################
        #cat("\nCreating .s file for clus")
        if(start == end){
          
          nome_config = paste(parameters$Dataset.Name, "-split-", f, "-group-",
                              g, ".s", sep="")
          sink(nome_config, type = "output")
          
          cat("[General]")
          cat("\nCompatibility = MLJ08")
          
          cat("\n\n[Data]")
          cat(paste("\nFile = ", train_name_group_arff, sep=""))
          cat(paste("\nTestSet = ", test_name_group_arff, sep=""))
          
          cat("\n\n[Attributes]")
          cat("\nReduceMemoryNominalAttrs = yes")
          
          cat("\n\n[Attributes]")
          cat(paste("\nTarget = ", end, sep=""))
          cat("\nWeights = 1")
          
          cat("\n")
          cat("\n[Tree]")
          cat("\nHeuristic = VarianceReduction")
          cat("\nFTest = [0.001,0.005,0.01,0.05,0.1,0.125]")
          
          cat("\n\n[Model]")
          cat("\nMinimalWeight = 5.0")
          
          cat("\n\n[Output]")
          cat("\nWritePredictions = {Test}")
          cat("\n")
          sink()
          
          ###################################################################
          cat("\nExecute CLUS: ", g , "\n")
          nome_config2 = paste(Folder.Test.Group, "/", nome_config, sep="")
          str = paste("java -jar ", parameters$Folders$folderUtils,
                      "/Clus.jar ", nome_config2, sep="")
          print(system(str))
          cat("\n")
          
        } else {
          
          nome_config = paste(parameters$Dataset.Name, "-split-", f, "-group-",
                              g, ".s", sep="")
          sink(nome_config, type = "output")
          
          cat("[General]")
          cat("\nCompatibility = MLJ08")
          
          cat("\n\n[Data]")
          cat(paste("\nFile = ", train_name_group_arff, sep=""))
          cat(paste("\nTestSet = ", test_name_group_arff, sep=""))
          
          cat("\n\n[Attributes]")
          cat("\nReduceMemoryNominalAttrs = yes")
          
          cat("\n\n[Attributes]")
          cat(paste("\nTarget = ", start, "-", end, sep=""))
          cat("\nWeights = 1")
          
          cat("\n")
          cat("\n[Tree]")
          cat("\nHeuristic = VarianceReduction")
          cat("\nFTest = [0.001,0.005,0.01,0.05,0.1,0.125]")
          
          cat("\n\n[Model]")
          cat("\nMinimalWeight = 5.0")
          
          cat("\n\n[Output]")
          cat("\nWritePredictions = {Test}")
          cat("\n")
          sink()
          
          cat("\nExecute CLUS: ", g , "\n")
          nome_config2 = paste(Folder.Test.Group, "/", nome_config, sep="")
          str = paste("java -jar ", parameters$Folders$folderUtils,
                      "/Clus.jar ", nome_config2, sep="")
          print(system(str))
          cat("\n")
          
        }
        
        ##################################################################
        #cat("\n\nOpen predictions")
        nomeDoArquivo = paste(Folder.Test.Group, "/", parameters$Dataset.Name,
                              "-split-", f,"-group-", g,
                              ".test.pred.arff", sep="")
        predicoes = data.frame(foreign::read.arff(nomeDoArquivo))
        
        
        #####################################################################
        #cat("\nS\nPLIT PREDICTIS")
        if(start == end){
          #cat("\n\nOnly one label in this group")
          
          ###################################################################
          #cat("\n\nSave Y_true")
          setwd(Folder.Test.Group)
          classes = data.frame(predicoes[,1])
          names(classes) = colnames(predicoes)[1]
          write.csv(classes, "y_true.csv", row.names = FALSE)
          
          #################################################################
          #cat("\n\nSave Y_true")
          rot = paste("Pruned.p.", colnames(predicoes)[1], sep="")
          pred = data.frame(predicoes[,rot])
          names(pred) = colnames(predicoes)[1]
          setwd(Folder.Test.Group)
          write.csv(pred, "y_pred.csv", row.names = FALSE)
          
          ####################################################################
          rotulos = c(colnames(classes))
          n_r = length(rotulos)
          gc()
          
        } else {
          
          ##############################################################
          #cat("\n\nMore than one label in this group")
          comeco = 1+(end - start)
          
          
          ####################################################################
          cat("\n\nSave Y_true")
          classes = data.frame(predicoes[,1:comeco])
          setwd(Folder.Test.Group)
          write.csv(classes, "y_true.csv", row.names = FALSE)
          
          
          ##################################################################
          cat("\n\nSave Y_true")
          rotulos = c(colnames(classes))
          n_r = length(rotulos)
          nomeColuna = c()
          t = 1
          while(t <= n_r){
            nomeColuna[t] = paste("Pruned.p.", rotulos[t], sep="")
            t = t + 1
            gc()
          }
          pred = data.frame(predicoes[nomeColuna])
          names(pred) = rotulos
          setwd(Folder.Test.Group)
          write.csv(pred, "y_pred.csv", row.names = FALSE)
          gc()
        } # FIM DO ELSE
        
        # deleting files
        um = paste(parameters$Dataset.Name, "-split-", f, "-group-", g, ".model", sep="")
        dois = paste(parameters$Dataset.Name, "-split-", f, "-group-", g, ".s", sep="")
        tres = paste(parameters$Dataset.Name, "-split-tr-", f, "-group-", g, ".arff", sep="")
        quatro = paste(parameters$Dataset.Name, "-split-ts-", f, "-group-", g, ".arff", sep="")
        sete = paste(parameters$Dataset.Name, "-split-", f, "-group-", g, ".out", sep="")
        oito = paste("Variance_RHE_1.csv")
        
        setwd(Folder.Test.Group)
        unlink(um, recursive = TRUE)
        unlink(dois, recursive = TRUE)
        unlink(tres, recursive = TRUE)
        unlink(quatro, recursive = TRUE)
        unlink(sete, recursive = TRUE)
        unlink(oito, recursive = TRUE)
        
      } else {
        
        cat("\n=================================")
        cat("\nSECOND AND SO ON CLUSTERS")
        cat("\n=================================\n")
        
        ################################################################
        cat("\nObtendo os rótulos-atributos")
        nome = paste(Folder.Tested.Split, "/label-att-", g, ".csv", sep="")
        lab.att = data.frame(read.csv(nome))
        
        ################################################################
        cat("\nTRAIN: Mount Group ", g, "\n")
        train_attributes_0 = train_file_final[parameters$Dataset.Info$AttStart:parameters$Dataset.Info$AttEnd]
        fim.train.attr = ncol(train_attributes_0)
        
        cat("\nTRAIN: obtendo os rótulos que se tornarão atributos")
        labels.att = select(train_file_final, lab.att$label) 
        
        cat("\nTRAIN: juntando rótulos-atributos com atributos")
        train_attributes = cbind(train_attributes_0, labels.att)
        fim.attr = ncol(train_attributes)
        
        cat("\nTRAIN: obtendo classes")
        train_classes = select(train_file_final, grupoEspecifico$label)
        
        cat("\nTRAIN: montando o dataset final")
        train_group = cbind(train_attributes, train_classes)
        fim.group = ncol(train_group)
        
        
        #####################################################################
        cat("\nCONVERTENDO NUMÉRICO PARA BINÁRIO ", g, "\n")
        start.2 = parameters$Dataset.Info$AttEnd + 1
        end.2 = fim.group
        ifr = data.frame(start.2, end.2)
        # setwd(Folder.Test.Group)
        # write.csv(ifr, "inicioFimRotulos.csv", row.names = FALSE)
        
        
        #####################################################################
        cat("\nTRAIN:: Save Group", g, "\n")
        train_name_group_csv = paste(Folder.Test.Group, "/", parameters$Dataset.Name, 
                                     "-split-tr-", f, "-group-", g, ".csv", sep="")
        write.csv(train_group, train_name_group_csv, row.names = FALSE)
        
        
        ####################################################################
        cat("\nTRAIN: Convert Train CSV to ARFF ", g , "\n")
        train_name_group_arff = paste(Folder.Test.Group, "/", parameters$Dataset.Name, 
                                      "-split-tr-", f, "-group-", g, ".arff", sep="")
        arg1Tr = train_name_group_csv
        arg2Tr = train_name_group_arff
        arg3Tr = paste(start.2, "-", end.2, sep="")
        str.10 = paste("java -jar ", parameters$Folders$folderUtils,
                       "/R_csv_2_arff.jar ", arg1Tr, " ", arg2Tr, " ",
                       arg3Tr, sep="")
        # cat("\n", str.10, "\n")
        print(system(str.10))
        
        
        ##################################################################
        cat("\nTRAIN: Verify and correct {0} and {1} ", g , "\n")
        str0 = paste("sed -i 's/{0}/{0,1}/g;s/{1}/{0,1}/g' ", arg2Tr, sep="")
        print(system(str0))
        
        
        ##############################################
        cat("\nApagando arquivo csv")
        setwd(Folder.Test.Group)
        unlink(train_name_group_csv)
        
        ##############################################
        preds.as.att = data.frame(apagar=c(0))
        i = 2
        while(i<=all.total.labels.g$group){
          b = i - 1
          cat("\nPredições do Grupo: ", b)
          Folder.Up.Group = paste(Folder.Tested.Split, "/Group-", b, sep="")
          preds = data.frame(read.csv(paste(Folder.Up.Group, "/y_pred.csv", sep=""))) 
          preds.as.att = cbind(preds.as.att, preds)
          i = i + 1
          gc(0)
        }
        
        if(ncol(preds.as.att)==2){ 
          
          nomes = colnames(preds.as.att)
          
          ################################################################
          cat("\nTEST: Mount Group ", g, "\n")
          test_attributes = test_file[parameters$Dataset.Info$AttStart:parameters$Dataset.Info$AttEnd]
          nomes.2 = colnames(test_attributes)
          
          test_attributes = cbind(test_attributes, preds.as.att[,2])
          ultima = ncol(test_attributes)
          names(test_attributes)[ultima] = nomes[2]
          
          test_classes = select(test_file, grupoEspecifico$label)
          test_group = cbind(test_attributes, test_classes)
          fim.ts = ncol(test_group)
          
        } else {
          preds.as.att = preds.as.att[,-1]
          
          ################################################################
          cat("\nTEST: Mount Group ", g, "\n")
          test_attributes = test_file[parameters$Dataset.Info$AttStart:parameters$Dataset.Info$AttEnd]
          test_attributes = cbind(test_attributes, preds.as.att)
          test_classes = select(test_file, grupoEspecifico$label)
          test_group = cbind(test_attributes, test_classes)
          fim.ts = ncol(test_group)
        }
      
        
        ################################################################
        cat("\nTEST: SALVANDO OS Y TRUE")
        setwd(Folder.Test.Group)
        write.csv(test_classes, "y_true.csv", row.names = FALSE)
        
        
        #####################################################################
        cat("\nTEST: Save Group", g, "\n")
        test_name_group_csv = paste(Folder.Test.Group, "/", parameters$Dataset.Name, 
                                    "-split-ts-", f, "-group-", g, ".csv", sep="")
        write.csv(test_group, test_name_group_csv, row.names = FALSE)
        
        
        ####################################################################
        cat("\nTEST: Convert Train CSV to ARFF ", g , "\n")
        test_name_group_arff = paste(Folder.Test.Group, "/", parameters$Dataset.Name, 
                                     "-split-ts-", f, "-group-", g, ".arff", sep="")
        arg1Ts = test_name_group_csv
        arg2Ts = test_name_group_arff
        arg3Ts = paste(start.2, "-", end.2, sep="")
        str.11 = paste("java -jar ", parameters$Folders$folderUtils,
                       "/R_csv_2_arff.jar ", arg1Ts, " ", arg2Ts, " ",
                       arg3Ts, sep="")
        cat("\n", str.11, "\n")
        print(system(str.11))
        
        
        ##################################################################
        cat("\nTEST: Verify and correct {0} and {1} ", g , "\n")
        str0 = paste("sed -i 's/{0}/{0,1}/g;s/{1}/{0,1}/g' ", arg2Ts, sep="")
        print(system(str0))
        
        
        ##############################################
        cat("\nTEST: Apagando arquivo csv")
        setwd(Folder.Test.Group)
        unlink(test_name_group_csv)
        
        
        #####################################################################
        #cat("\nCreating .s file for clus")
        if(build.datasets.g$num.labels == 1){
          
          nome_config = paste(parameters$Dataset.Name, "-split-", f, "-group-",
                              g, ".s", sep="")
          sink(nome_config, type = "output")
          
          cat("[General]")
          cat("\nCompatibility = MLJ08")
          
          cat("\n\n[Data]")
          cat(paste("\nFile = ", train_name_group_arff, sep=""))
          cat(paste("\nTestSet = ", test_name_group_arff, sep=""))
          
          cat("\n\n[Attributes]")
          cat("\nReduceMemoryNominalAttrs = yes")
          
          cat("\n\n[Attributes]")
          cat(paste("\nTarget = ", build.datasets.g$label.end, sep=""))
          cat("\nWeights = 1")
          
          cat("\n")
          cat("\n[Tree]")
          cat("\nHeuristic = VarianceReduction")
          cat("\nFTest = [0.001,0.005,0.01,0.05,0.1,0.125]")
          
          cat("\n\n[Model]")
          cat("\nMinimalWeight = 5.0")
          
          cat("\n\n[Output]")
          cat("\nWritePredictions = {Test}")
          cat("\n")
          sink()
          
          ###################################################################
          cat("\nExecute CLUS: ", g , "\n")
          nome_config2 = paste(Folder.Test.Group, "/", nome_config, sep="")
          str = paste("java -jar ", parameters$Folders$folderUtils,
                      "/Clus.jar ", nome_config2, sep="")
          print(system(str))
          cat("\n")
          
        } else {
          
          nome_config = paste(parameters$Dataset.Name, "-split-", f, "-group-",
                              g, ".s", sep="")
          sink(nome_config, type = "output")
          
          cat("[General]")
          cat("\nCompatibility = MLJ08")
          
          cat("\n\n[Data]")
          cat(paste("\nFile = ", train_name_group_arff, sep=""))
          cat(paste("\nTestSet = ", test_name_group_arff, sep=""))
          
          cat("\n\n[Attributes]")
          cat("\nReduceMemoryNominalAttrs = yes")
          
          cat("\n\n[Attributes]")
          cat(paste("\nTarget = ", build.datasets.g$label.start, "-", 
                    build.datasets.g$label.end, sep=""))
          cat("\nWeights = 1")
          
          cat("\n")
          cat("\n[Tree]")
          cat("\nHeuristic = VarianceReduction")
          cat("\nFTest = [0.001,0.005,0.01,0.05,0.1,0.125]")
          
          cat("\n\n[Model]")
          cat("\nMinimalWeight = 5.0")
          
          cat("\n\n[Output]")
          cat("\nWritePredictions = {Test}")
          cat("\n")
          sink()
          
          cat("\nExecute CLUS: ", g , "\n")
          nome_config2 = paste(Folder.Test.Group, "/", nome_config, sep="")
          str = paste("java -jar ", parameters$Folders$folderUtils,
                      "/Clus.jar ", nome_config2, sep="")
          print(system(str))
          cat("\n")
          
        }
        
        ##################################################################
        #cat("\n\nOpen predictions")
        nomeDoArquivo = paste(Folder.Test.Group, "/", parameters$Dataset.Name,
                              "-split-", f,"-group-", g,
                              ".test.pred.arff", sep="")
        predicoes = data.frame(foreign::read.arff(nomeDoArquivo))
        
        
        #####################################################################
        #cat("\nS\nPLIT PREDICTIS")
        if(build.datasets.g$num.labels == 1){
          #cat("\n\nOnly one label in this group")
          
          ###################################################################
          #cat("\n\nSave Y_true")
          setwd(Folder.Test.Group)
          classes = data.frame(predicoes[,1])
          names(classes) = colnames(predicoes)[1]
          write.csv(classes, "y_true.csv", row.names = FALSE)
          
          #################################################################
          #cat("\n\nSave Y_true")
          rot = paste("Pruned.p.", colnames(predicoes)[1], sep="")
          pred = data.frame(predicoes[,rot])
          names(pred) = colnames(predicoes)[1]
          setwd(Folder.Test.Group)
          write.csv(pred, "y_pred.csv", row.names = FALSE)
          
          ####################################################################
          rotulos = c(colnames(classes))
          n_r = length(rotulos)
          gc()
          
        } else {
          
          ##############################################################
          #cat("\n\nMore than one label in this group")
          comeco = 1+(build.datasets.g$label.end - build.datasets.g$label.start)
          
          
          ####################################################################
          cat("\n\nSave Y_true")
          classes = data.frame(predicoes[,1:comeco])
          setwd(Folder.Test.Group)
          write.csv(classes, "y_true.csv", row.names = FALSE)
          
          
          ##################################################################
          cat("\n\nSave Y_true")
          rotulos = c(colnames(classes))
          n_r = length(rotulos)
          nomeColuna = c()
          t = 1
          while(t <= n_r){
            nomeColuna[t] = paste("Pruned.p.", rotulos[t], sep="")
            t = t + 1
            gc()
          }
          pred = data.frame(predicoes[nomeColuna])
          names(pred) = rotulos
          setwd(Folder.Test.Group)
          write.csv(pred, "y_pred.csv", row.names = FALSE)
          gc()
        } # FIM DO ELSE
        
        # deleting files
        um = paste(parameters$Dataset.Name, "-split-", f, "-group-", g, ".model", sep="")
        dois = paste(parameters$Dataset.Name, "-split-", f, "-group-", g, ".s", sep="")
        tres = paste(parameters$Dataset.Name, "-split-tr-", f, "-group-", g, ".arff", sep="")
        quatro = paste(parameters$Dataset.Name, "-split-ts-", f, "-group-", g, ".arff", sep="")
        sete = paste(parameters$Dataset.Name, "-split-", f, "-group-", g, ".out", sep="")
        oito = paste("Variance_RHE_1.csv")
        
        setwd(Folder.Test.Group)
        unlink(um, recursive = TRUE)
        unlink(dois, recursive = TRUE)
        unlink(tres, recursive = TRUE)
        unlink(quatro, recursive = TRUE)
        unlink(sete, recursive = TRUE)
        unlink(oito, recursive = TRUE)
        
      }
      
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
gather.predicts.clus <- function(parameters){
  
  f = 1
  gatherR <- foreach(f = 1:parameters$Number.Folds) %dopar%{
    #while(f<=parameters$Number.Folds){
  
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
      #cat("\nSpecific Group: ", g, "\n")
      grupoEspecifico = filter(partition, group == g)
      
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
      
      #cat("\n\nDeleting files")
      unlink("y_true.csv", recursive = TRUE)
      unlink("y_predict.csv", recursive = TRUE)
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
evaluate.clus <- function(parameters){
  
  f = 1
  avalParal <- foreach(f = 1:parameters$Number.Folds) %dopar%{
    #while(f<=parameters$Number.Folds){
    
    
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
    y_true2 = data.frame(sapply(y_true, function(x) as.numeric(as.character(x))))
    y_true3 = mldr_from_dataframe(y_true2 , labelIndices = seq(1,ncol(y_true2 )), name = "y_true2")
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
gather.evaluated.clus <- function(parameters){
  
  
  ##########################################################################
  apagar = c(0)
  avaliado.final = data.frame(apagar)
  nomes = c("")
  
  # from fold = 1 to number_folders
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
  write.csv(media, "Mean10Folds.csv", row.names = FALSE)
  
  mediana = data.frame(apply(avaliado.final[,-1], 1, median))
  mediana = cbind(measures, mediana)
  names(mediana) = c("Measures", "Median10Folds")
  write.csv(mediana, "Median10Folds.csv", row.names = FALSE)
  
  dp = data.frame(apply(avaliado.final[,-1], 1, sd))
  dp = cbind(measures, dp)
  names(dp) = c("Measures", "SD10Folds")
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
