The hand-sorted data is used to train several time series classifiers. Data is loaded as a MATLAB .mat file, which is converted to a dataframe. All of the classifier functions are located within classifier_functions.py. In order to train models, labeled data is used, alongside the trainCIF, trainDrCIF, trainROCKET, and trainArsenal functions. These functions will save the models, alongside the accuracy of the model tested on a subset of the data. To use the trained models, the loadCIF, loadDrCIF, loadROCKET, and loadArsenal functions can be used. This will label new data. The model will not be trained exactly the same every time, due to random seeding. However, the accuracies should be very similar.

Dependencies of this code are listed within the functions file. Sktime can be found at https://www.sktime.org/en/latest/. 

Example data for this classification can be found here:
