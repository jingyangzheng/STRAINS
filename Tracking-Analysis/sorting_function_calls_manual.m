%% manual sorting and data compilation for manually sorted data

folder = 'D:\Jingyang\Cartilage\Confocal_Images\';
date = '19_09_26_test';
positions = ['1', '2', '3', '4', '5', '6'];

%% make folders for hand sorting

categories = {'blue_high_green_signal','blue_multiple_steps','blue_rises','blue_rises_and_falls','blue_rises_late',...
    'blue_starts_high','everything_low','green_drop_then_blue','green_signal',...
    'green_signal_then_blue','normal','red_high_blue_changes'};

for i = 1:length(positions)
    sortingdir = strcat(folder, date, '\pos',num2str(i),'\intensity_sort\');
    mkdir(sortingdir);
    for j = 1:length(categories)
        mkdir(strcat(sortingdir, categories{j}));
    end
end

%% saving manually sorted data
% if manually sorting behaviors, use this section

for i = 1:length(positions)
    ManualDataCompilation(folder, date, positions(i), categories);
end

% save labels for each position from manually sorted data
PositionLabels(folder, date, positions, categories);

%% compile cell attributes for each location and run decision tree
% if no manual sorting, then accuracy counts are going to be wrong (this is okay)

load(strcat(folder,date,'\feature_extraction_params.mat'),'fe_params');

feature_params = [fe_params.g_minpeakprom, fe_params.g_wpratio, fe_params.g_threshold, ...
    fe_params.b_minpeakprom, fe_params.b_wpratio, fe_params.b_threshold];

for i = 1:length(positions)
    CellAttributes(folder, date, positions(i), feature_params, true);
    DecisionTree(folder, date, positions(i), categories);
end

%% saving peak/nopeak data

peak_param = [fe_params.g_minpeakprom, fe_params.g_wpratio];

SplitPeaksDataCompilation(folder, date, positions, peak_param);
