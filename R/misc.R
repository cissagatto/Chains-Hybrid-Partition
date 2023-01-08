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



#########################################################################
# Function to correctly convert CSV in ARFF
converteArff <- function(arg1, arg2, arg3){
  str = paste("java -jar ", parameters$Folders$folderUtils,
              "/R_csv_2_arff.jar ", arg1, " ", arg2, " ", arg3, sep="")
  print(system(str))
  cat("\n")
}



##############################################################################
#
##############################################################################
get.all.partitions <- function(parameters){
  
  retorno = list()
  
  pasta.best = paste(parameters$Folders$folderBestPartitions, 
                     "/", parameters$Dataset.Name, 
                     "/", parameters$Dataset.Name, 
                     "-Best-Silhouete.csv", sep="")
  best = data.frame(read.csv(pasta.best))
  
  num.fold = c(0)
  num.part = c(0)
  num.group = c(0)
  best.part.info = data.frame(num.fold, num.part, num.group)
  
  all.partitions.info = data.frame()
  all.total.labels = data.frame()
  
  f = 1
  while(f<=parameters$Number.Folds){
    
    best.fold = best[f,]
    num.fold = best.fold$fold
    num.part = best.fold$part
    
    Pasta = paste(parameters$Folders$folderBestPartitions, 
                  "/", parameters$Dataset.Name, "/Split-", 
                  f, sep="")
    pasta.groups = paste(Pasta, "/fold-", f, 
                         "-groups-per-partition.csv", sep="")
    groups = data.frame(read.csv(pasta.groups))
    groups.fold = filter(groups, partition == num.part)
    
    num.group = groups.fold$num.groups
    best.part.info = rbind(best.part.info, 
                           data.frame(num.fold, num.part, num.group))
    
    nome = paste(Pasta, "/Partition-", num.part, 
                 "/partition-", num.part, ".csv", sep="")
    partitions = data.frame(read.csv(nome))
    partitions = data.frame(num.fold, num.part, partitions)
    partitions = arrange(partitions, group)
    
    all.partitions.info = rbind(all.partitions.info, partitions)
    
    nome.2 = paste(Pasta, "/Partition-", num.part,
                   "/fold-", f, "-labels-per-group-partition-", 
                   num.group, ".csv", sep="")
    labels = data.frame(read.csv(nome.2))
    labels = data.frame(num.fold, labels)
    all.total.labels = rbind(all.total.labels , labels)
    
    f = f + 1
    gc()
  } # fim do fold
  
  setwd(parameters$Folders$folderTested)
  write.csv(best.part.info, "best-part-info.csv", row.names = FALSE)
  write.csv(all.partitions.info, "all.partitions.info.csv", row.names = FALSE)
  write.csv(all.total.labels, "all.total.labels.csv", row.names = FALSE)
  
  retorno$best.part.info = best.part.info[-1,]
  retorno$all.partitions.info = all.partitions.info
  retorno$all.total.labels = all.total.labels
  return(retorno)
  
}

compute.labels.attributes <-function(parameters){
  
  retorno = list()
  nomes = c("")
  
  num.fold = c(0)
  num.cluster = c(0)
  num.att = c(0)
  num.labels = c(0)
  label.att = c(0)
  att.start = c(0)
  att.end  = c(0)
  label.start  = c(0)
  label.end = c(0)
  all.info = data.frame(num.fold, num.cluster, num.att, num.labels, label.att, 
                        att.start, att.end, label.start, label.end)
  
  resultado = get.all.partitions(parameters)
  best.part.info = data.frame(resultado$best.part.info)
  all.partitions.info = data.frame(resultado$all.partitions.info)
  all.total.labels = data.frame(resultado$all.total.labels)
  
  f = 1
  while(f<=parameters$Number.Folds){
    
    FolderSplit = paste(parameters$Folders$folderTested, "/Split-", f, sep="")
    if(dir.exists(FolderSplit)==FALSE){dir.create(FolderSplit)}
    
    best.part.info.f = filter(best.part.info, num.fold == f)
    all.total.labels.f = filter(all.total.labels, num.fold == f)
    all.partitions.info.f = filter(all.partitions.info, num.fold == f)
    all.partitions.info.f = arrange(all.partitions.info.f, group)
    
    aumenta.atributos = 0 
    labels.aumentados = c()
    res.2 = data.frame()
    todos = data.frame()
    
    g = 1
    while(g<=best.part.info.f$num.group){
      
      cat("\nFOLD = ", f, " GRUPO = ", g)
      
      FolderGroup = paste(FolderSplit, "/Group-", g, sep="")
      if(dir.exists(FolderGroup)==FALSE){dir.create(FolderGroup)}
      
      num.cluster = g
      num.fold = f
      
      all.partitions.info.g = filter(all.partitions.info.f, group == g)
      all.total.labels.g = filter(all.total.labels.f, group == g)
      
      num.att = parameters$Dataset.Info$Attributes + aumenta.atributos
      att.start = parameters$Dataset.Info$AttStart
      att.end = parameters$Dataset.Info$AttEnd + aumenta.atributos
      label.start = parameters$Dataset.Info$LabelStart + aumenta.atributos
      label.end = label.start + all.total.labels.g$totalLabels - 1
      num.labels = all.total.labels.g$totalLabels
      
      label.att = aumenta.atributos
      
      all.info = rbind(all.info, data.frame(num.fold, num.cluster, num.att, 
                                            num.labels, label.att, att.start, 
                                            att.end, label.start, label.end))
      
      aumenta.atributos = aumenta.atributos + num.labels
      
      g = g + 1
      
      #labels.aumentados = c(all.partitions.info.g$label, labels.aumentados)
      
      cluster = g
      label = all.partitions.info.g$label
      res = data.frame(cluster, label)
      res.2 = rbind(res.2, res)
      res.2$cluster = g
      
      setwd(FolderSplit)
      nome = paste("label-att-", g, ".csv", sep="")
      write.csv(res.2, nome, row.names = FALSE)
      
      gc()
    }
    cat("\n")
    
    f = f + 1
    gc()
  }
  
  all.info = all.info[-1,]
  retorno$all.info = all.info
  
  setwd(parameters$Folders$folderTested)
  write.csv(all.info, "info-build-datasets.csv", row.names = FALSE)
  
  return(retorno)
  
} # fim da função
