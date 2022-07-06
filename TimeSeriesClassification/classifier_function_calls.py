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


import os
# this is where the codes are stored
os.chdir('D:\Jingyang\Cartilage\Protocols\Python_codes\classification')
import classifier_functions as cf

    
# define directory where data is stored and create new directories to save to
# this is where the data is stored
parentdir = r'D:\Jingyang\Cartilage\Confocal_Images'
date = '19_09_26_test'
# made new directories to save data
savedir = os.path.join(parentdir, date, 'classification')
if not os.path.exists(savedir):
    os.mkdir(savedir)
peaksdir = os.path.join(parentdir, date, 'classification\\peaks')
if not os.path.exists(peaksdir):
    os.mkdir(peaksdir)
nopeaksdir = os.path.join(parentdir, date, 'classification\\nopeaks')
if not os.path.exists(nopeaksdir):
    os.mkdir(nopeaksdir)

# load peaks and no peaks data
df_peaks, labels_peaks = cf.load_data(parentdir, date, 'peaks')
df_nopeaks, labels_nopeaks = cf.load_data(parentdir, date, 'nopeaks')

# run each model for peaks and no peaks data
# this is going to take a long time, ~12-24hrs for each model depending on the
# number of points
# just make sure you prevent your computer from doing any auto-updates

cf.trainCIF(peaksdir, df_peaks, labels_peaks, 200, 100)


# example of loading a model and making predictions
cf.loadCIF(peaksdir, peaksdir, 'cif_nest200_nint100', df_peaks)