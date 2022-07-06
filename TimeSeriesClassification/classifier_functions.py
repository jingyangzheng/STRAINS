# -*- coding: utf-8 -*-
"""
Created on Tue Jun 7 11:29:56 2022

Written by Jingyang Zheng jz848@cornell.edu

dependencies:
requires sktime and its dependencies
requires matplotlib, scipy.io, joblib, sklearn, pandas, and numpy
for additional requirements check the header in the classifier_functions file

MIT License
    Copyright 2022 Jingyang Zheng
    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
    documentation files (the "Software"), to deal in the Software without restriction, including without limitation 
    the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
    and to permit persons to whom the Software is furnished to do so, subject to the following conditions: 
    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO 
    THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
    THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Citation
    Attribution to the copyright holder (Jingyang Zheng) and citation of the associated publication 
    (https://www.biorxiv.org/content/10.1101/2022.06.12.495830v2). The authors would appreciate if any users 
    could email the copyright holder (jz848@cornell.edu) so that the copyright holder can share and cite examples of adaptations.

"""

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import pandas as pd
import scipy.io as sio
import pickle
import os
from scipy.io import loadmat
from joblib import dump, load
from collections import Counter
from sklearn import metrics
from sklearn.model_selection import train_test_split
  

def load_data(folder, date, ynpeaks):
    
    loaddata0 = loadmat(os.path.join(folder,date,('fe_'+ynpeaks+'.mat')))
    loadlabels = loadmat(os.path.join(folder,date,('fe_labels_'+ynpeaks+'.mat')))
    testdata0 = loaddata0['df0_'+ynpeaks]
    testlabels = loadlabels['y_'+ynpeaks]
    df0 = pd.DataFrame(testdata0,columns=['red', 'green', 'blue'])
    
    data = []
    for i in range(0, len(df0)):
        tempred = df0['red'].iloc[i]
        a = pd.Series(v[0] for v in tempred)
        tempgreen = df0['green'].iloc[i]
        b = pd.Series(v[0] for v in tempgreen)
        tempblue = df0['blue'].iloc[i]
        c = pd.Series(v[0] for v in tempblue)
        data.append([a, b, c])
        del a, b, c, tempred, tempgreen, tempblue
    
    df_orig = pd.DataFrame(data, columns=['red', 'green', 'blue'])
    # df_red = pd.DataFrame(df_orig['red'])
    # df_green = pd.DataFrame(df_orig['green'])
    # df_blue = pd.DataFrame(df_orig['blue'])

    # convert series to correct series for labels
    labels = pd.Series(v[0] for [[[v]]] in testlabels)
    
    return df_orig, labels


# can uncomment out the returns here if you want to mess with things
# they all get saved to .csv files

def trainCIF(savedir, timeseries, labels, estimators, intervals, rand=42):

    X_train, X_test, y_train, y_test = train_test_split(timeseries, labels, random_state=rand)
    from sktime.classification.interval_based import CanonicalIntervalForest
    clf = CanonicalIntervalForest(n_estimators=estimators, n_intervals = intervals)
    clf.fit(X_train, y_train)
    predicted = clf.predict(X_test)
    print("Accuracy: %2.3f" % metrics.accuracy_score(y_test, predicted))
    filename = 'cif_nest'+str(estimators)+'_nint'+str(intervals)
    pd.DataFrame(predicted).to_csv(os.path.join(savedir, filename + '.csv'))
    pd.DataFrame(y_test).to_csv(os.path.join(savedir, filename + '_ytest.csv'))
    dump(clf, os.path.join(savedir, filename))
    with open(os.path.join(savedir, filename + '_accuracy.txt'), 'w') as f:
        f.write("Accuracy: %2.3f" % metrics.accuracy_score(y_test, predicted))    
    #return predicted, y_test    
        
def trainDrCIF(savedir, timeseries, labels, estimators, intervals, rand=42):
    
    X_train, X_test, y_train, y_test = train_test_split(timeseries, labels, random_state=rand)
    from sktime.classification.interval_based import DrCIF
    clf = DrCIF(n_estimators=estimators, n_intervals = intervals)
    clf.fit(X_train, y_train)
    predicted = clf.predict(X_test)
    print("Accuracy: %2.3f" % metrics.accuracy_score(y_test, predicted))
    filename = 'drcif_nest'+str(estimators)+'_nint'+str(intervals)
    pd.DataFrame(predicted).to_csv(os.path.join(savedir, filename + '.csv'))
    pd.DataFrame(y_test).to_csv(os.path.join(savedir, filename + '_ytest.csv'))
    dump(clf, os.path.join(savedir, filename))
    with open(os.path.join(savedir, filename + '_accuracy.txt'), 'w') as f:
        f.write("Accuracy: %2.3f" % metrics.accuracy_score(y_test, predicted))    
    #return predicted, y_test    


def trainROCKET(savedir, timeseries, labels, kernels, rand=42):
    X_train, X_test, y_train, y_test = train_test_split(timeseries, labels, random_state=rand)
    from sktime.classification.kernel_based import ROCKETClassifier
    clf = ROCKETClassifier(num_kernels=kernels)
    clf.fit(X_train, y_train)
    predicted = clf.predict(X_test)
    print("Accuracy: %2.3f" % metrics.accuracy_score(y_test, predicted))
    filename = 'rocket_nker'+str(kernels)
    pd.DataFrame(predicted).to_csv(os.path.join(savedir, filename + '.csv'))
    pd.DataFrame(y_test).to_csv(os.path.join(savedir, filename + '_ytest.csv'))
    dump(clf, os.path.join(savedir, filename))
    with open(os.path.join(savedir, filename + '_accuracy.txt'), 'w') as f:
        f.write("Accuracy: %2.3f" % metrics.accuracy_score(y_test, predicted))    
    #return predicted, y_test    

def trainArsenal(savedir, timeseries, labels, kernels, estimators, rand=42):
    X_train, X_test, y_train, y_test = train_test_split(timeseries, labels, random_state=rand)
    from sktime.classification.kernel_based import Arsenal
    clf = Arsenal(num_kernels=kernels, n_estimators = estimators)
    clf.fit(X_train, y_train)
    predicted = clf.predict(X_test)
    print("Accuracy: %2.3f" % metrics.accuracy_score(y_test, predicted))
    filename = 'arsenal_nker'+str(kernels)+'_nest'+str(estimators)
    pd.DataFrame(predicted).to_csv(os.path.join(savedir, filename + '.csv'))
    pd.DataFrame(y_test).to_csv(os.path.join(savedir, filename + '_ytest.csv'))
    dump(clf, os.path.join(savedir, filename))
    with open(os.path.join(savedir, filename + '_accuracy.txt'), 'w') as f:
        f.write("Accuracy: %2.3f" % metrics.accuracy_score(y_test, predicted))
    #return predicted, y_test    
    
def loadCIF(loaddir, savedir, filename, timeseries):
    from sktime.classification.interval_based import CanonicalIntervalForest
    clf = load(os.path.join(loaddir, filename))
    predicted = clf.predict(timeseries)
    pd.DataFrame(predicted).to_csv(os.path.join(savedir, filename + '_predicted.csv'))
    #return predicted
    
def loadDrCIF(loaddir, savedir, filename, timeseries):
    from sktime.classification.interval_based import DrCIF
    clf = load(os.path.join(loaddir, filename))
    predicted = clf.predict(timeseries)
    pd.DataFrame(predicted).to_csv(os.path.join(savedir, filename + '_predicted.csv'))
    #return predicted
    
def loadROCKET(loaddir, savedir, filename, timeseries):
    from sktime.classification.kernel_based import ROCKETClassifier
    clf = load(os.path.join(loaddir, filename))
    predicted = clf.predict(timeseries)
    pd.DataFrame(predicted).to_csv(os.path.join(savedir, filename + '_predicted.csv'))
    #return predicted
    
def loadArsenal(loaddir, savedir, filename, timeseries):
    from sktime.classification.kernel_based import Arsenal
    clf = load(os.path.join(loaddir, filename))
    predicted = clf.predict(timeseries)
    pd.DataFrame(predicted).to_csv(os.path.join(savedir, filename + '_predicted.csv'))
    #return predicted
    
    