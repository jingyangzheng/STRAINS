# -*- coding: utf-8 -*-
"""
Created on Tue Jun  7 11:29:56 2022

@author: Jingyang
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