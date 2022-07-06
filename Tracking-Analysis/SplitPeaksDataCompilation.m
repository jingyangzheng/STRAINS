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

% requires mapping toolbox
function SplitPeaksDataCompilation(folder, date, positions, peak_param)

    % initialize some matrices
    df0_peaks = {};
    df1_peaks = {};
    y_peaks = {};
    df0_nopeaks = {};
    df1_nopeaks = {};
    y_nopeaks = {};
    
    for i = 1:length(positions)
    
        % load position data
        load(strcat(folder, date, '\pos',positions(i),'\pos', positions(i), '_locs.mat'));
        locs = [];
        locs(:,1) = filled_long(1,1:2:end);
        locs(:,2) = filled_long(1,2:2:end);
        % load timeseries data
        load(strcat(folder, date, '\pos',...
            positions(i),'\pos', positions(i), '_intensity.mat'));
        intensity_mat(:,1) = []; % remove time column
        red_all = smoothdata(intensity_mat(:,1:3:end),'movmean',20);
        green_all = smoothdata(intensity_mat(:,2:3:end),'movmean',20);
        blue_all = smoothdata(intensity_mat(:,3:3:end),'movmean',20);

        % separate cells with peaks
        % load peak data
        load(strcat(folder,date,'\pos', positions(i),'\feature_extraction\green_peaks\prom',...
            num2str(peak_param(1)),'_ratio',num2str(peak_param(2)),'\peaks\green_peaks_processed.mat'));
        % find indices of cells with peaks (= cell ID)
        peakind = find(~cellfun(@isempty,{peaks_processed.peaks}))';
        % find indices of cells without peaks
        nopeakind = find(cellfun(@isempty,{peaks_processed.peaks}))';

        % load cell attributes file to get labels from decision tree
        load(strcat(folder,date,'\pos', positions(i),'\feature_extraction\cell_attributes.mat'));
        full_labels = extractfield(cell_attributes, 'true_label')'; % requires mapping toolbox
        % split labels between peaks and no peaks
        peakslabels = full_labels(peakind);
        nopeakslabels = full_labels(nopeakind);

        % split intensity data between peaks and no peaks
        red_nopeaks = red_all(:,nopeakind);
        green_nopeaks = green_all(:,nopeakind);
        blue_nopeaks = blue_all(:,nopeakind);
        red_peaks = red_all(:,peakind);
        green_peaks = green_all(:,peakind);
        blue_peaks = blue_all(:,peakind);

        % initialize temp variables for current position
        temptsnopeaks = cell(length(nopeakslabels),3);
        tempconcatnopeaks = cell(length(nopeakslabels),1);
        temptspeaks = cell(length(peakslabels),3);
        tempconcatpeaks = cell(length(peakslabels),1);

        % fill in cell arrays
        for j = 1:length(nopeakslabels)
            temptsnopeaks{j,1} = red_nopeaks(:,j);
            temptsnopeaks{j,2} = green_nopeaks(:,j);
            temptsnopeaks{j,3} = blue_nopeaks(:,j);
            tempconcatnopeaks{j,1} = vertcat(red_nopeaks(:,j),green_nopeaks(:,j),blue_nopeaks(:,j));
        end

        % fill in cell arrays
        for k = 1:length(peakslabels)
            temptspeaks{k,1} = red_peaks(:,k);
            temptspeaks{k,2} = green_peaks(:,k);
            temptspeaks{k,3} = blue_peaks(:,k);
            tempconcatpeaks{k,1} = vertcat(red_peaks(:,k),green_peaks(:,k),blue_peaks(:,k));
        end

        % concatenate to total sample data
        df0_nopeaks = vertcat(df0_nopeaks, temptsnopeaks);
        df1_nopeaks = vertcat(df1_nopeaks, tempconcatnopeaks);
        y_nopeaks = vertcat(y_nopeaks, nopeakslabels);
        df0_peaks = vertcat(df0_peaks, temptspeaks);
        df1_peaks = vertcat(df1_peaks, tempconcatpeaks);
        y_peaks = vertcat(y_peaks, peakslabels);
        
    end
        
    % save as separate structures
    save(strcat(folder, date, '\fe_nopeaks.mat'), 'df0_nopeaks');
    save(strcat(folder, date, '\fe_concat_nopeaks.mat'), 'df1_nopeaks');
    save(strcat(folder, date, '\fe_labels_nopeaks.mat'), 'y_nopeaks');
    save(strcat(folder, date, '\fe_peaks.mat'), 'df0_peaks');
    save(strcat(folder, date, '\fe_concat_peaks.mat'), 'df1_peaks');
    save(strcat(folder, date, '\fe_labels_peaks.mat'), 'y_peaks');

end