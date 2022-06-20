
% this is the same as split peaks data compilation but for data that has not been manually labeled


function SplitPeaksDataCompilationNoLabels(folder, date, positions, peak_param)

    % initialize some matrices
    df0_peaks = {};
    df1_peaks = {};
    df0_nopeaks = {};
    df1_nopeaks = {};
    
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

        % split intensity data between peaks and no peaks
        red_nopeaks = red_all(:,nopeakind);
        green_nopeaks = green_all(:,nopeakind);
        blue_nopeaks = blue_all(:,nopeakind);
        red_peaks = red_all(:,peakind);
        green_peaks = green_all(:,peakind);
        blue_peaks = blue_all(:,peakind);

        % initialize temp variables for current position
        temptsnopeaks = cell(length(nopeakind),3);
        tempconcatnopeaks = cell(length(nopeakind),1);
        temptspeaks = cell(length(peakind),3);
        tempconcatpeaks = cell(length(peakind),1);

        % fill in cell arrays
        for j = 1:length(nopeakind)
            temptsnopeaks{j,1} = red_nopeaks(:,j);
            temptsnopeaks{j,2} = green_nopeaks(:,j);
            temptsnopeaks{j,3} = blue_nopeaks(:,j);
            tempconcatnopeaks{j,1} = vertcat(red_nopeaks(:,j),green_nopeaks(:,j),blue_nopeaks(:,j));
        end

        % fill in cell arrays
        for k = 1:length(peakind)
            temptspeaks{k,1} = red_peaks(:,k);
            temptspeaks{k,2} = green_peaks(:,k);
            temptspeaks{k,3} = blue_peaks(:,k);
            tempconcatpeaks{k,1} = vertcat(red_peaks(:,k),green_peaks(:,k),blue_peaks(:,k));
        end

        % concatenate to total sample data
        df0_nopeaks = vertcat(df0_nopeaks, temptsnopeaks);
        df1_nopeaks = vertcat(df1_nopeaks, tempconcatnopeaks);
        df0_peaks = vertcat(df0_peaks, temptspeaks);
        df1_peaks = vertcat(df1_peaks, tempconcatpeaks);

        
    end
        
    % save as separate structures
    save(strcat(folder, date, '\fe_nopeaks.mat'), 'df0_nopeaks');
    save(strcat(folder, date, '\fe_concat_nopeaks.mat'), 'df1_nopeaks');
    save(strcat(folder, date, '\fe_peaks.mat'), 'df0_peaks');
    save(strcat(folder, date, '\fe_concat_peaks.mat'), 'df1_peaks');

end