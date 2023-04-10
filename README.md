# STRAINS

This repository contains the code associated with the paper 'STRAINS: A Big Data Method for Classifying Cellular Response to Stimuli at the Tissue Scale', authored by Jingyang Zheng, Thomas Wyse Jackson, Lisa A. Fortier, Lawrence J. Bonassar, Michelle L. Delco, and Itai Cohen. This paper can be found at: https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0278626

The contents of this repository include: tracking and intensity analysis MATLAB codes, a MATLAB graphical user interface for analyzing videos, and time series classification codes written in Python to make use of the sktime library (found here: https://www.sktime.org/en/latest/).

Due to github's file size constraints, example data for running these codes, along with an example video of the GUI in action can be found at the Cornell eCommons repository here: https://doi.org/10.7298/3kwt-pm43

#### Author Information  
Principal Investigator Contact Information  
Name: Jingyang Zheng  
Institution: Cornell University  
Address: C7 Clark Hall  
Email: jz848@cornell.edu  

#### Associate or Co-investigator Contact Information  
Name: Itai Cohen  
Institution: Cornell University  
Address: 509 Clark Hall  
Email: itai.cohen@cornell.edu  

### SHARING/ACCESS INFORMATION
#### Licenses/restrictions placed on the data: MIT License  
Copyright 2022 Jingyang Zheng  
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:   
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.  
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  
Recommended citation for this dataset: attribution to the copyright holder (Jingyang Zheng) and citation of the associated publication (https://www.biorxiv.org/content/10.1101/2022.06.12.495830v2). The authors would appreciate if any users could email the copyright holder (jz848@cornell.edu) so that the copyright holder can share and cite examples of adaptations.  


### DATA & FILE OVERVIEW

#### STRAINS GUI
cellGUI_preMATLAB2019: older version of the app that uses a workaround for click detection, not recommended  
STRAINS_GUI: present version of the GUI, requires MATLAB 2019a or newer  

#### Matlab Codes
all_tracking_function_calls: demonstration of function call usage, all parameter are input here and example parameters are included  
CellAttributes: compiles the attributes of each cell (peaks, changepoints, etc)  
DecisionTree: the actual if-else statements that make up the decision tree  
FeatureExtraction: gets changepoints and peaks from each cell  
ImageReg_EXAMPLE: example code for image registration, useful for connecting pos1 and impact data  
ManualDataCompilation: scrapes category names from folders after manual sorting  
PositionLabels: save labels for each position by order of CellID (number given by Crocker & Grier)  
SetFigureDefaults: sets figure defaults for plotting  
sorting_function_calls_manual and sorting_function_calls_nomanual: function calls for sorting the data, split between whether or not the data was manually sorted  
SplitPeaksDataCompilation and SplitPeaksDataCompilationNoLabels: compiles data information depending on whether or not manual labels exist  
TrackImpact and TrackPostImpact: tracking code for impact or post-impact videos (impact = 1 channel, post-impact = RGB), outputs intensity information  
###### Dependencies
requires Crocker & Grier particle tracking code found here: https://site.physics.georgetown.edu/matlab/  
requires export_fig from the Matlab Fileshare found here: https://www.mathworks.com/matlabcentral/fileexchange/23629-export_fig  
requires Matlab Signal Processing Toolbox

#### Python Classification Codes
classifier_function_calls: example code for how to use the functions  
classifier_functions: all functions associated with the time series classifications in this publication  
###### Dependencies
requires sktime
	
#### METHODOLOGICAL INFORMATION
A detailed description can be found in the methods section and supplementary documents of the publication associated with this code, which can be found at: https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0278626 or https://www.biorxiv.org/content/10.1101/2022.06.12.495830v2  
Slidebook images (.sld) were converted into .tiff files and then either 8-bit (impact image) or RGB color (all other images) in ImageJ/Fiji before the MATLAB code is run
