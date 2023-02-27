import sys
import pandas as pd
from eccCluster import EccCluster
from sklearn.ensemble import RandomForestClassifier

if __name__ == '__main__':
    
    n_chains = 10
    random_state = 0
    n_estimators = 200
    baseModel = RandomForestClassifier(n_estimators = n_estimators, random_state = random_state)
    
    train = pd.read_csv(sys.argv[1])
    valid = pd.read_csv(sys.argv[2])
    test = pd.read_csv(sys.argv[3])
    partitions = pd.read_csv(sys.argv[4])
    directory = sys.argv[5]

    train = pd.concat([train,valid],axis=0).reset_index(drop=True)
    clusters = partitions.groupby("group")["label"].apply(list)   
    allLabels = partitions["label"].unique()
    x_train = train.drop(allLabels, axis=1)
    y_train = train[allLabels]
    x_test = test.drop(allLabels, axis=1)
    
    ecc = EccCluster(baseModel,
            n_chains)
    ecc.fit(x_train,
            y_train,
            clusters
             )

    test_predictions = pd.DataFrame(ecc.predict(x_test))
    train_predictions = pd.DataFrame(ecc.predict(x_train))

    true = (directory + "/y_true.csv")
    pred = (directory + "/y_pred.csv")

    test_predictions.to_csv(pred, index=False)
    test[allLabels].to_csv(true, index=False)