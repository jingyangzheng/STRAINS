% MIT License
    % Copyright 2022 Jingyang Zheng
    % Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
    % documentation files (the "Software"), to deal in the Software without restriction, including without limitation 
    % the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
    % and to permit persons to whom the Software is furnished to do so, subject to the following conditions: 
    % The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
    % THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO 
    % THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
    % THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
    % TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

% Citation
    % Attribution to the copyright holder (Jingyang Zheng) and citation of the associated publication 
    % (https://www.biorxiv.org/content/10.1101/2022.06.12.495830v2). The authors would appreciate if any users 
    % could email the copyright holder (jz848@cornell.edu) so that the copyright holder can share and cite examples of adaptations.

% requires export_fig from the Matlab Fileshare found here: https://www.mathworks.com/matlabcentral/fileexchange/23629-export_fig
% requires Matlab Signal Processing Toolbox and Mapping Toolbox
    
%% for data that has not been manually sorted
% decision tree and splitting

folder = 'D:\Jingyang\Cartilage\Confocal_Images\';
date = '19_09_26_test';
positions = ['1', '2', '3', '4', '5'];

categories = {'blue_high_green_signal','blue_multiple_steps','blue_rises','blue_rises_and_falls','blue_rises_late',...
    'blue_starts_high','everything_low','green_drop_then_blue','green_signal',...
    'green_signal_then_blue','normal','red_high_blue_changes'};


%% compile cell attributes for each location and run decision tree
% if no manual sorting, then accuracy counts are going to be wrong (this is okay)

load(strcat(folder,date,'\feature_extraction_params.mat'),'fe_params');

feature_params = [fe_params.g_minpeakprom, fe_params.g_wpratio, fe_params.g_threshold, ...
    fe_params.b_minpeakprom, fe_params.b_wpratio, fe_params.b_threshold];

for i = 1:length(positions)
    CellAttributes(folder, date, positions(i), feature_params, false);
    DecisionTree(folder, date, positions(i), categories);
end

%% saving peak/nopeak data

peak_param = [fe_params.g_minpeakprom, fe_params.g_wpratio];

SplitPeaksDataCompilationNoLabels(folder, date, positions, peak_param);