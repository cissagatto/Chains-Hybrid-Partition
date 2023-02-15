## ECC with internal and external chaining
import numpy as np
import pandas as pd
from ecc import ECC
from sklearn.base import clone
from sklearn.multioutput import ClassifierChain

class ECCExin:
    def __init__(self,
                 model,
                 n_chains = 10,
                 ):
       self.model = model
       self.n_chains = n_chains
       self.chains = None ## one ECC per cluster
        
    def fit(self,
            x, ## dataframe
            y,
            clusters,
            ):
        self.clusters = self.__preprocessClustersName(clusters,y)
        self.chains = []
        self.orderLabelsDataset = y.columns

        chain_x = x.copy()       
        for c in self.clusters:
            ecc = ECC(self.model,self.n_chains)
            chain_y = y[y.columns[c]]    
            ecc.fit(chain_x,chain_y)
            ecc.labelName_ = y.columns[c]
            self.chains.append(ecc)
            chain_x = pd.concat([chain_x, chain_y],axis=1)
                
    def predict(self,
                x):
        predictions = pd.concat([self.__predictChain(x) for i in range(self.n_chains)],axis=0)
        return predictions.groupby(predictions.index).apply(np.mean)

    def __predictChain(self,
                x
                ):
        if self.chains is None:
            raise Exception('Oh no no no no!', 'Model has not been fitted yet.')
        
        chain_x = x.copy()
        predictions = pd.DataFrame([])
       #print(self.chains)
        for model in self.chains:
            predictionsChain = pd.DataFrame(model.predict(chain_x), columns = model.labelName_ )
            predictions[model.labelName_] = predictionsChain
            chain_x = pd.concat([chain_x, predictionsChain], axis=1)
        predictions = predictions[self.orderLabelsDataset]
        return predictions            

    def __preprocessClustersName(self,
            clusters,
            y):       ### transform clusters names to integers
        clustersIndexes = [[y.columns.get_loc(l) for l in labels] for labels in clusters ]
        return clustersIndexes