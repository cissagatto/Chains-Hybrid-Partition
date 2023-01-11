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
build.ecc <- function(parameters){
  
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
    
    cat("\nGetting the Y TRUE for train and test sets")
    ts.labels.true = test.file[, parameters$Dataset.Info$LabelStart:parameters$Dataset.Info$LabelEnd]
    tr.labels.true = train.file.final[, parameters$Dataset.Info$LabelStart:parameters$Dataset.Info$LabelEnd]
    
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
      
      cat("\n\n\t#==============================================#")
        cat("\n\t# LABELS [", all.total.labels.g$totalLabels, "] #" )
        cat("\n\t#==============================================#\n\n")
      
      #########################################################################
      # se este for o cluster de número 1 então não tem labels para serem
      # agregados, apenas rodar normamente - mas se for composto por um 
      # único rótulo, deve ser executado o binary relevance
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
        
        all.info.clusters = data.frame(fold, cluster, labels.per.cluster,
                                       attr.start, attr.end, new.attr.end, 
                                       lab.att.start, lab.att.end, 
                                       label.start, label.end,
                                       label.as.attr)
        
        all.info.clusters = rbind(all.info.clusters, info.cluster)
        
        ################################################################
        
        cat("\n\tTRAIN: Save Cluster as CSV")
        train.name.cluster.csv = paste(Folder.Test.Cluster, "/", 
                                       parameters$Dataset.Name, "-split-tr-", 
                                       f, "-group-", g, ".csv", sep="")
        write.csv(train.dataset, train.name.cluster.csv, row.names = FALSE)
        
        cat("\n\tTRAIN: Convert CSV to ARFF and Convert Numeric to Binary")
        train.name.cluster.arff = paste(Folder.Test.Cluster, "/", 
                                        parameters$Dataset.Name, 
                                        "-split-tr-", f, "-group-", g,
                                        "-1.arff", sep="")
        arg.csv = train.name.cluster.csv
        arg.arff = train.name.cluster.arff
        arg.targets = paste(info.cluster$label.start, "-", 
                            info.cluster$label.end, sep="")
        str.convert = paste("java -jar ", parameters$Folders$folderUtils,
                            "/R_csv_2_arff.jar ", arg.csv, " ", arg.arff, " ",
                            arg.targets, sep="")
        cat("\n")
        print(system(str.convert))
        cat("\n")
        
        cat("\n\tTRAIN: Verify and correct {0} and {1}")
        str.train = paste("sed -i 's/{0}/{0,1}/g;s/{1}/{0,1}/g' ", arg.arff, sep="")
        cat("\n")
        print(system(str.train))
        cat("\n")
        
        cat("\n\tTRAIN: Deleting CSV file\n")
        setwd(Folder.Test.Cluster)
        unlink(train.name.cluster.csv)
        
        
        ################################################################
        # BUILDING TEST THE DATASET                                    #
        ################################################################
        
        cat("\n\tTEST: Build Cluster")
        test.attributes = test.file[parameters$Dataset.Info$AttStart:parameters$Dataset.Info$AttEnd]
        test.classes = select(test.file, cluster.specific$label)
        test.dataset = cbind(test.attributes, test.classes)
        
        cat("\n\tTEST: Getting Y True")
        setwd(Folder.Test.Cluster)
        write.csv(test.classes, "y_true.csv", row.names = FALSE)
        
        cat("\n\tTEST: Save Cluster as CSV")
        test.name.cluster.csv = paste(Folder.Test.Cluster, "/", 
                                    parameters$Dataset.Name, 
                                    "-split-ts-", f, "-group-", g, 
                                    ".csv", sep="")
        write.csv(test.dataset, test.name.cluster.csv, row.names = FALSE)
        
        cat("\n\tTEST: Convert CSV to ARFF")
        test.name.cluster.arff = paste(Folder.Test.Cluster, "/", 
                                       parameters$Dataset.Name, 
                                       "-split-ts-", f, "-group-", 
                                       g, "-1.arff", sep="")
        arg.csv = test.name.cluster.csv
        arg.arff = test.name.cluster.arff
        arg.targets = paste(info.cluster$label.start, "-", 
                            info.cluster$label.end, sep="")
        str.convert = paste("java -jar ", parameters$Folders$folderUtils,
                            "/R_csv_2_arff.jar ", arg.csv, " ", arg.arff, " ",
                            arg.targets, sep="")
        cat("\n")
        print(system(str.convert))
        cat("\n")
        
        cat("\n\tTEST: Verify and correct {0} and {1}")
        str.test = paste("sed -i 's/{0}/{0,1}/g;s/{1}/{0,1}/g' ", arg.arff, sep="")
        cat("\n")
        print(system(str.test))
        cat("\n")
        
        cat("\n\tTEST: Deleting CSV file\n")
        setwd(Folder.Test.Cluster)
        unlink(test.name.cluster.csv)
        
        
        #######################################################################
        # se o número de rótulos dentro do grupo for igual a 1 rodar o BR
        # caso contrário rodar o ECC
        # por ser o primeiro cluster não precisa mudar nada!
        #######################################################################
        if(all.total.labels.g$totalLabels==1){
          
          cat("\n\n\t#=========================================#")
            cat("\n\t# Cluster ", g, " has only one label      #")
            cat("\n\t#=========================================#\n\n")
          
          cat("\n\tGenerate label index.dataset for whole dataset")
          index.dataset = c(seq(parameters$Dataset.Info$LabelStart,
                                parameters$Dataset.Info$LabelEnd, by=1))
          
          cat("\n\tTransform train in mldr for train and test sets")
          ds.train = mldr_from_dataframe(train.file.final, labelIndices = index.dataset)
          br.train = mldr_transform(ds.train, type = "BR")
          ds.test = mldr_from_dataframe(test.file, labelIndices = index.dataset)
          br.test = mldr_transform(ds.test, type = "BR")
          
          cat("\n\tTrain BR")
          br.model = br(ds.train, "C5.0", seed=123)
          
          cat("\n\tTest BR")
          br.predict <- predict(br.model, ds.test)
          
          cat("\n\tApply threshold")
          br.threshold <- scut_threshold(br.predict, ds.test)
          new.threshold.br <- data.frame(as.matrix(fixed_threshold(br.predict, br.threshold)))
          
          cat("\n\tSaving all predctions")
          br.predict = data.frame(as.matrix(br.predict))
          predicted = cbind(br.predict, new.threshold.br)
          setwd(Folder.Tested.Split)
          write.csv(predicted, "br-pred.csv", row.names = FALSE)
          
          cat("\n\tSaving Y Pred")
          y_pred = select(new.threshold.br, cluster.specific$label)
          setwd(Folder.Test.Cluster)
          write.csv(y_pred, "y_pred.csv", row.names = FALSE)
          
          cat("\n\tSaving Y True")
          y.true = select(ts.labels.true, cluster.specific$label)
          setwd(Folder.Test.Cluster)
          write.csv(y.true, "y_true.csv", row.names = FALSE)
          
        } else {
          
          cat("\n\n\t#==============================================#")
            cat("\n\t# Cluster [", g, "] has more than one label    #")
            cat("\n\t#==============================================#\n\n")
          
          ##############################################
          cat("\n\tSaving Y True")
          y.true = select(ts.labels.true, cluster.specific$label)
          setwd(Folder.Test.Cluster)
          write.csv(y.true, "y_true.csv", row.names = FALSE)
          
          #####################################################################
          cat("\n\tTRAIN: Transform into MLDR")
          str.train = paste(parameters$Dataset.Name, "-split-tr-", f, "-group-", g, 
                            "-weka.filters.unsupervised.attribute.NumericToNominal-R", 
                            info.cluster$label.start, "-", info.cluster$label.end, sep="")
          
          train.cluster.mldr <- mldr::mldr_from_dataframe(dataframe = train.dataset, 
                                                          labelIndices = seq(info.cluster$label.start, info.cluster$label.end, by=1), 
                                                          name = str.train)
          
          train.xml.name = paste(Folder.Test.Cluster, "/", parameters$Dataset.Name, 
                           "-split-tr-", f, "-group-", g, sep="")
          mldr::write_arff(train.cluster.mldr, train.xml.name, write.xml = T)
          
          
          #####################################################################
          cat("\n\tTEST: Transform into MLDR")
          str.test = paste(parameters$Dataset.Name, "-split-ts-", f, "-group-", g, 
                        "-weka.filters.unsupervised.attribute.NumericToNominal-R", 
                        info.cluster$label.start, "-", info.cluster$label.end, sep="")
          
          test.cluster.mldr <- mldr::mldr_from_dataframe(dataframe = test.dataset, 
                                                         labelIndices = seq(info.cluster$label.start, info.cluster$label.end, by=1), 
                                                         name = str.test)
          
          test.xml.name = paste(Folder.Test.Cluster, "/", parameters$Dataset.Name, 
                           "-split-ts-", f, "-group-", g, sep="")
          mldr::write_arff(test.cluster.mldr, test.xml.name, write.xml = T)
          
          
          #####################################################################
          cat("\n\tDeleting arff files generated by mulan")
          unlink(paste(test.xml.name, ".arff", sep=""))
          unlink(paste(train.xml.name, ".arff", sep=""))
          
          
          ##############################################
          cat("\n\tChanging the file names")
          train.name = paste(Folder.Test.Cluster, "/",
                             parameters$Dataset.Name, "-split-tr-", f,
                             "-group-", g, ".arff", sep="")
          
          test.name = paste(Folder.Test.Cluster, "/",
                            parameters$Dataset.Name, "-split-ts-", f,
                            "-group-", g, ".arff", sep="")
          
          system(paste("mv ", train.name.cluster.arff, " ", train.name))
          system(paste("mv ", test.name.cluster.arff, " ", test.name))
          
          
          #####################################################################
          cat("\n\tSet command line mulan config")
          mulan = paste("/usr/lib/jvm/java-1.8.0-openjdk-amd64/bin/java -Xmx8g -jar ", 
                        parameters$Folders$folderUtils, "/mymulanexec.jar", sep="")
          
          xml.name = paste(Folder.Test.Cluster, "/",
                           parameters$Dataset.Name, "-split-tr-", f,
                           "-group-", g, ".xml", sep="")
          
          mulan.str = paste(mulan, " -t ", train.name, " -T ", test.name, 
                            " -x ", xml.name, " -o out.csv -a ECC -c J48", 
                            sep = "")
          
          cat("\n\n\t#=========================================#")
           cat("\n\t# Execute ECC MULAN\n")
            system.time(res <- system(mulan.str))
          
          if(res!=0){
            cat("\n\tThere's some problem with ECC Mulan\n")
            break 
          } else {
            cat("\n\tECC Mulan executed with sucess!\n")
          }
            
          cat("\n\t#=========================================#\n\n")
          
          
          #####################################################################
          cat("\n\tGet Predictions")
          setwd(Folder.Test.Cluster)
          mulan.preds = data.frame(as.matrix(read.csv("pred_out.csv", header = FALSE)))
          colnames(mulan.preds) = labels
          
          
          #####################################################################
          cat("\n\tOpen test file")
          test.name.cluster = paste(Folder.Test.Cluster, "/", parameters$Dataset.Name, 
                                    "-split-ts-", f, "-group-", g, sep="")
          test.file.cluster <- mldr(test.name.cluster, force_read_from_file = T)
          
          
          #####################################################################
          cat("\n\tMULAN result")
          mulan.result <- multilabel_evaluate(test.file.cluster, mulan.preds, labels=TRUE)
          
          
          #####################################################################
          cat("\n\tUTIML Threshold")
          utiml.threshold <- scut_threshold(mulan.preds, test.file.cluster)
          final.predictions <- data.frame(as.matrix(fixed_threshold(mulan.preds, utiml.threshold)))
          
          
          #####################################################################
          cat("\n\tSave original and pruned predictions")
          all.predictions = cbind(mulan.preds, final.predictions)
          setwd(Folder.Test.Cluster)
          write.csv(all.predictions, "cluster-predictions.csv", row.names = FALSE)
          
          
          #####################################################################
          cat("\n\tSalvando os Y Predict")
          setwd(Folder.Test.Cluster)
          write.csv(final.predictions, "y_pred.csv", row.names = FALSE)
          
          
          #####################################################################
          setwd(Folder.Test.Cluster)
          unlink("pred_out.csv")
          
          
          #####################################################################
          cat("\n\tUTIML Confusion Matrix")
          confusion.matrix = multilabel_confusion_matrix(test.file.cluster, mulan.preds)
          name.file = paste(Folder.Test.Cluster, "/confusion.matrix.cluster", 
                            g, ".txt", sep="")
          sink(name.file, type = "output")
          print(confusion.matrix)
          cat("\n")
          sink()
          cat("\n")
          
          cat("\n\n\t#==============================================#")
            cat("\n\t# END Cluster [", g, "]                       #")
            cat("\n\t#==============================================#\n\n")
          
        }
        
        rm(info.cluster)
        
        # setwd(Folder.Test.Cluster)
        # unlink("out.csv")
        # unlink("pred_out.csv")
        # unlink("inicioFimRotulos.csv")
        # unlink(paste(parameters$Dataset.Name,"-split-ts-",f,"-group-",g,".xml", sep=""))
        # unlink(paste(parameters$Dataset.Name,"-split-tr-",f,"-group-",g,".xml", sep=""))
        # unlink(paste(parameters$Dataset.Name,"-split-ts-",f,"-group-",g,".arff", sep=""))
        # unlink(paste(parameters$Dataset.Name,"-split-tr-",f,"-group-",g,".arff", sep=""))
        
        
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
        
        cat("\n\tTRAIN: joing label-atrributes with atrributes")
        train.attributes = cbind(train.attributes.original, labels.att)
        
        cat("\n\tTRAIN: getting classes")
        train.classes = select(train.file.final, cluster.specific$label)
        
        cat("\n\tTRAIN: build the final train dataset")
        train.dataset = cbind(train.attributes, train.classes)
        
        cat("\n\tTRAIN: Save Cluster")
        train.name.cluster.csv = paste(Folder.Test.Cluster, "/", 
                                       parameters$Dataset.Name, "-split-tr-", 
                                       f, "-group-", g, ".csv", sep="")
        write.csv(train.dataset, train.name.cluster.csv, row.names = FALSE)
        
        
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
        
        all.info.clusters = data.frame(fold, cluster, labels.per.cluster,
                                       attr.start, attr.end, new.attr.end, 
                                       lab.att.start, lab.att.end, 
                                       label.start, label.end,
                                       label.as.attr)
        
        all.info.clusters = rbind(all.info.clusters, info.cluster)
        
        
        ################################################################
        
        cat("\n\tTRAIN: Convert CSV to ARFF and Convert Numeric in to Binary")
        train.name.cluster.arff = paste(Folder.Test.Cluster, "/", 
                                        parameters$Dataset.Name, "-split-tr-", 
                                        f, "-group-", g, "-1.arff", sep="")
        arg.csv = train.name.cluster.csv
        arg.arff = train.name.cluster.arff
        arg.targets = paste(info.cluster$lab.att.start, "-", label.end, sep="")
        str.convert = paste("java -jar ", parameters$Folders$folderUtils,
                            "/R_csv_2_arff.jar ", arg.csv, " ", arg.arff, " ",
                            arg.targets, sep="")
        cat("\n")
        print(system(str.convert))
        cat("\n")
        
        cat("\n\tTRAIN: Verify and correct {0} and {1} ", g , "\n")
        str.train = paste("sed -i 's/{0}/{0,1}/g;s/{1}/{0,1}/g' ", arg.arff, sep="")
        cat("\n")
        print(system(str.train))
        cat("\n")
        
        cat("\n\tDeleting CSV file")
        setwd(Folder.Test.Cluster)
        unlink(train.name.cluster.csv)
        
        
        ################################################################
        # BUILDING TEST THE DATASET                                    #
        ################################################################
        
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
          nomes = colnames(preds.as.att)
          
          test.attributes = test.file[parameters$Dataset.Info$AttStart:parameters$Dataset.Info$AttEnd]
          nomes.2 = colnames(test.attributes)
          
          test.attributes = cbind(test.attributes, preds.as.att[,2])
          ultima = ncol(test.attributes)
          names(test.attributes)[ultima] = nomes[2]
          
          test.classes = select(test.file, cluster.specific$label)
          test.dataset = cbind(test.attributes, test.classes)
          end.test.dataset = ncol(test.dataset)
          
        } else {
          cat("\n\tTEST: More than one prediction")
          preds.as.att = preds.as.att[,-1]
          test.attributes = test.file[parameters$Dataset.Info$AttStart:parameters$Dataset.Info$AttEnd]
          test.attributes = cbind(test.attributes, preds.as.att)
          test.classes = select(test.file, cluster.specific$label)
          test.dataset = cbind(test.attributes, test.classes)
          end.test.dataset = ncol(test.dataset)
        }
        
        cat("\n\tTEST: Saving Y True")
        setwd(Folder.Test.Cluster)
        write.csv(test.classes, "y_true.csv", row.names = FALSE)
        
        cat("\n\tTEST: Save Cluster as CSV")
        test.name.cluster.csv = paste(Folder.Test.Cluster, "/", parameters$Dataset.Name, 
                                    "-split-ts-", f, "-group-", g, ".csv", sep="")
        write.csv(test.dataset, test.name.cluster.csv, row.names = FALSE)
        
        cat("\n\tTEST: Convert CSV to ARFF ", g , "\n")
        test.name.cluster.arff = paste(Folder.Test.Cluster, "/", parameters$Dataset.Name, 
                                     "-split-ts-", f, "-group-", g, "-1.arff", sep="")
        arg.csv = test.name.cluster.csv
        arg.arff = test.name.cluster.arff
        arg.targets = paste(info.cluster$lab.att.start, "-", label.end, sep="")
        str.convert = paste("java -jar ", parameters$Folders$folderUtils,
                            "/R_csv_2_arff.jar ", arg.csv, " ", arg.arff, " ",
                            arg.targets, sep="")
        
        cat("\n")
        print(system(str.convert))
        cat("\n")
        
        cat("\n\tTEST: Verify and correct {0} and {1} ", g , "\n")
        str.test = paste("sed -i 's/{0}/{0,1}/g;s/{1}/{0,1}/g' ", arg.arff, sep="")
        cat("\n")
        print(system(str.test))
        cat("\n")
        
        cat("\n\tTEST: Deleting CSV file")
        setwd(Folder.Test.Cluster)
        unlink(test.name.cluster.csv)
        
        
        ###################################################################
        # Se o número de rotulos do grupo for igual a 1 então precisa     #
        # rodar o Br. Nesse caso, tenho que juntar todos os rótulos       #
        # do dataset pois o pacote trabalha assim                         #
        ###################################################################
        if(all.total.labels.g$totalLabels==1){
          
          cat("\n\n\t#=========================================#")
            cat("\n\t# Cluster [", g, "] has only one label    #")
            cat("\n\t#=========================================#\n\n")
          
          cat("\n\tSaving Y True")
          y.true = select(test.dataset, cluster.specific$label)
          setwd(Folder.Test.Cluster)
          write.csv(y.true, "y_true.csv", row.names = FALSE)
          
          cat("\n\tChanging names labels attributes")
          new.name.label = paste(lab.att.config$label, "-attr", sep="")
          train.attributes.2 = train.attributes
          test.attributes.2 = test.attributes
          names(train.attributes.2)[info.cluster$new.attr.end] = new.name.label
          names(test.attributes.2)[info.cluster$new.attr.end] = new.name.label
          
          # gather attributes labels and all labels because BR only works
          # with all labels in the data
          cat("\n\tJoining labels attributes")
          train.dataset = cbind(train.attributes.2, tr.labels.true)
          test.dataset = cbind(test.attributes.2, ts.labels.true)
          end.label = ncol(train.dataset)
          
          # Generate label index.dataset for whole dataset
          cat("\n\tGenerating label index")
          index.dataset = seq(info.cluster$label.start, end.label)
          
          cat("\n\tTransform train in mldr for train and test sets")
          ds.train = mldr_from_dataframe(train.dataset, labelIndices = index.dataset)
          br.train = mldr_transform(ds.train, type = "BR")
          ds.test = mldr_from_dataframe(test.dataset, labelIndices = index.dataset)
          br.test = mldr_transform(ds.test, type = "BR")
          
          cat("\n\tBR TRAIN")
          br.model = br(ds.train, "C5.0", seed=123)
          
          cat("\n\tBR TEST")
          br.predict <- predict(br.model, ds.test)
          
          cat("\n\tApply threshold")
          br.threshold <- scut_threshold(br.predict, ds.test)
          new.threshold.br <- data.frame(as.matrix(fixed_threshold(br.predict, br.threshold)))
          
          cat("\n\tSaving all predctions")
          br.predict = data.frame(as.matrix(br.predict))
          predicted = cbind(br.predict, new.threshold.br)
          setwd(Folder.Test.Cluster)
          write.csv(predicted, "br-pred.csv", row.names = FALSE)
          
          cat("\n\tSaving Y Pred")
          y_pred = select(new.threshold.br, cluster.specific$label)
          setwd(Folder.Test.Cluster)
          write.csv(y_pred, "y_pred.csv", row.names = FALSE)
          
        } else {
          
          cat("\n\n\t#==============================================#")
            cat("\n\t# Cluster [", g, "] has more than one label    #")
            cat("\n\t#==============================================#\n\n")
          
          ##############################################
          cat("\n\tTRAIN: Transform into MLD")
          str.train = paste(parameters$Dataset.Name, "-split-tr-", f, "-group-", g, 
                        "-weka.filters.unsupervised.attribute.NumericToNominal-R", 
                        info.cluster$label.start, "-", info.cluster$label.end, sep="")
          
          train.cluster.mldr <- mldr::mldr_from_dataframe(dataframe = train.dataset, 
                                                          labelIndices = seq(info.cluster$label.start, info.cluster$label.end), 
                                                          name = str.train)
          
          train.xml.name = paste(Folder.Test.Cluster, "/", parameters$Dataset.Name, 
                           "-split-tr-", f, "-group-", g, sep="")
          mldr::write_arff(train.cluster.mldr, train.xml.name, write.xml = T)
          
          
          ##############################################
          cat("\n\tTEST: Transform into mldr")
          str.test = paste(parameters$Dataset.Name, "-split-ts-", f, "-group-", g, 
                        "-weka.filters.unsupervised.attribute.NumericToNominal-R", 
                        info.cluster$label.start, "-", info.cluster$label.end, sep="")
          
          test.cluster.mldr <- mldr::mldr_from_dataframe(dataframe = test.dataset, 
                                                         labelIndices = seq(info.cluster$label.start, info.cluster$label.end), 
                                                         name = str.test)
          
          test.xml.name = paste(Folder.Test.Cluster, "/", parameters$Dataset.Name, 
                           "-split-ts-", f, "-group-", g, sep="")
          mldr::write_arff(test.cluster.mldr, test.xml.name, write.xml = T)
          
          
          #####################################################################
          cat("\n\tDeleting arff files generated by mulan")
          unlink(paste(test.xml.name, ".arff", sep=""))
          unlink(paste(train.xml.name, ".arff", sep=""))
          
          
          #####################################################################
          train.name = paste(train.xml.name, ".arff", sep="")
          test.name = paste(test.xml.name, ".arff", sep="")
          
          
          #####################################################################
          cat("\n\tChanging the file names")
          system(paste("mv ", train.name.cluster.arff, " ", train.name, sep=""))
          system(paste("mv ", test.name.cluster.arff, " ", test.name, sep=""))
          
          
          #####################################################################
          cat("\n\tSet command line mulan config")
          mulan = paste("/usr/lib/jvm/java-1.8.0-openjdk-amd64/bin/java -Xmx8g -jar ", 
                        parameters$Folders$folderUtils, "/mymulanexec.jar", sep="")
          
          xml.name = paste(Folder.Test.Cluster, "/",
                           parameters$Dataset.Name, "-split-tr-", f,
                           "-group-", g, ".xml", sep="")
          
          mulan.str = paste(mulan, " -t ", train.name, " -T ", 
                            test.name, " -x ", xml.name, 
                            " -o out.csv -a ECC -c J48", sep = "")
          
          cat("\n\n\t#=========================================#")
            cat("\n\t# Execute ECC MULAN                       #\n")
              system.time(res <- system(mulan.str))
          
          if(res!=0){
            cat("\n\tThere's some problem with ECC Mulan\n")
            break 
          } else {
            cat("\n\tECC Mulan executed with sucess!\n")
          }
              
          cat("\n\t#=========================================#\n\n")
          
          
          #####################################################################
          cat("\n\tGet Predictions")
          setwd(Folder.Test.Cluster)
          mulan.preds = data.frame(as.matrix(read.csv("pred_out.csv", header = FALSE)))
          colnames(mulan.preds) = labels
          
          
          #####################################################################
          cat("\n\tOpen test file")
          test.name.cluster = paste(Folder.Test.Cluster, "/", parameters$Dataset.Name, 
                                    "-split-ts-", f, "-group-", g, sep="")
          test.file.cluster <- mldr(test.name.cluster, force_read_from_file = T)
          
          
          #####################################################################
          cat("\n\tMULAN result")
          mulan.result <- multilabel_evaluate(test.file.cluster, mulan.preds, labels=TRUE)
          
          
          #####################################################################
          cat("\n\tUTIML Threshold")
          utiml.threshold <- scut_threshold(mulan.preds, test.file.cluster)
          final.predictions <- data.frame(as.matrix(fixed_threshold(mulan.preds, utiml.threshold)))
          
          
          #####################################################################
          cat("\n\tSave original and pruned predictions")
          all.predictions = cbind(mulan.preds, final.predictions)
          setwd(Folder.Test.Cluster)
          write.csv(all.predictions, "cluster-predictions.csv", row.names = FALSE)
          
          
          #####################################################################
          cat("\n\tSalvando os Y Predict")
          setwd(Folder.Test.Cluster)
          write.csv(final.predictions, "y_pred.csv", row.names = FALSE)
          
          
          #####################################################################
          setwd(Folder.Test.Cluster)
          unlink("pred_out.csv")
          
          
          #####################################################################
          cat("\n\tUTIML Confusion Matrix")
          confusion.matrix = multilabel_confusion_matrix(test.file.cluster, mulan.preds)
          name.file = paste(Folder.Test.Cluster, "/confusion.matrix.cluster", 
                            g, ".txt", sep="")
          sink(name.file, type = "output")
          print(confusion.matrix)
          cat("\n")
          sink()
          cat("\n")
          
          cat("\n\n\t#==============================================#")
            cat("\n\t# END Cluster [", g, "]                        #")
            cat("\n\t#==============================================#\n\n")
          
        }
        
        rm(info.cluster)
        
        
        # setwd(Folder.Test.Cluster)
        # #unlink("out.csv")
        # unlink("pred_out.csv")
        # unlink("inicioFimRotulos.csv")
        # unlink(paste(parameters$Dataset.Name,"-split-ts-",f,"-group-",g,".xml", sep=""))
        # unlink(paste(parameters$Dataset.Name,"-split-tr-",f,"-group-",g,".xml", sep=""))
        # unlink(paste(parameters$Dataset.Name,"-split-ts-",f,"-group-",g,".arff", sep=""))
        # unlink(paste(parameters$Dataset.Name,"-split-tr-",f,"-group-",g,".arff", sep=""))

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
gather.predicts.ecc <- function(parameters){
  
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
evaluate.ecc <- function(parameters){
  
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
gather.evaluated.ecc <- function(parameters){
  
  
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
