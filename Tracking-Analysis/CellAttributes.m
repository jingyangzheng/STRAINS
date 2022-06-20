% calculate cell attributes

function CellAttributes(folder, date, position, feature_params, manual)
    % feature_params go as: [green prominence, green ratio, green threshold, blue prominence,
    % blue ratio, blue threshold]


    % load data and smooth
    load(strcat(folder, date, '\pos', position,'\pos', position, '_intensity.mat'));
    % load coordinates
    load(strcat(folder, date, '\pos', position,'\pos', position, '_locs.mat'));

    % load the structures specifically
    
    
    % green peaks
    load(strcat(folder,date,'\pos', position,'\feature_extraction\green_peaks\prom',...
        num2str(feature_params(1)),'_ratio',num2str(feature_params(2)),'\peaks\green_peaks_processed.mat'));
    % green changepoints
    load(strcat(folder,date,'\pos', position,'\feature_extraction\green_changepts\lin_thresh',...
        num2str(feature_params(3)),'\haschangepoint\green_changept.mat'));
    % blue peaks
    load(strcat(folder,date,'\pos', position,'\feature_extraction\blue_peaks\prom',...
        num2str(feature_params(4)),'_ratio',num2str(feature_params(5)),'\peaks\blue_peaks_processed.mat'));
    % blue changepoints
    load(strcat(folder,date,'\pos', position,'\feature_extraction\blue_changepts\lin_thresh',...
        num2str(feature_params(6)),'\haschangepoint\blue_changept.mat'));
    
    

    intensity_mat(:,1) = []; % remove time column
    red_all = smoothdata(intensity_mat(:,1:3:end),'movmean',20);
    green_all = smoothdata(intensity_mat(:,2:3:end),'movmean',20);
    blue_all = smoothdata(intensity_mat(:,3:3:end),'movmean',20);
    locs(:,1) = filled_long(1,1:2:end);
    locs(:,2) = filled_long(1,2:2:end);
    timeserieslength = size(intensity_mat, 1);

    num_cells = size(intensity_mat, 2)/3;
    frames = linspace(1,timeserieslength,timeserieslength)';
    SetFigureDefaults(timeserieslength);

    % load pre-labeled data
    if manual == true
        load(strcat(folder, date, '\pos', position, '\pos', position, '_labels.mat'));
    end

    %% create structure
    cell_attributes = struct;

    for i = 1:num_cells
        if manual == true
            cell_attributes(i).true_label = save_labels(i,1);
        else
            cell_attributes(i).true_label = [];
        end
        cell_attributes(i).category = [];
        cell_attributes(i).cellnum = i;
        cell_attributes(i).coord = [round(locs(i,1)) round(locs(i,2))];
        cell_attributes(i).green_peaks = peaks_processed(i).peaktime;
        cell_attributes(i).green_cp = green_changept(i).ipt;
        cell_attributes(i).blue_cp = blue_changept(i).ipt;
        cell_attributes(i).blue_peaks = blue_peaks_processed(i).peaktime;
        cell_attributes(i).red_range = max(red_all(:,i)) - min(red_all(:,i));
        cell_attributes(i).blue_range = max(blue_all(:,i)) - min(blue_all(:,i));
        cell_attributes(i).blue_mean = mean(blue_all(:,i));
        cell_attributes(i).red_max = max(red_all(:,i));
        [cell_attributes(i).blue_max, cell_attributes(i).blue_max_frame] = max(blue_all(:,i));
        cell_attributes(i).blue_range_after_max = range(blue_all(cell_attributes(i).blue_max_frame:end,i));
        cell_attributes(i).red_mean = mean(red_all(:,i));
        cell_attributes(i).red_mean_end = mean(red_all(100:end,i));
        cell_attributes(i).blue_total_slope = (blue_all(1,i)-blue_all(length(frames),i))/length(frames);
        cell_attributes(i).red_blue_meandiff = cell_attributes(i).red_mean - cell_attributes(i).blue_mean;
    end
    
    save(strcat(folder,date,'\pos', position,...
        '\feature_extraction\cell_attributes.mat'), 'cell_attributes');
    
    % how to get one column
    % cell_attributes1 = struct('category', {cell_attributes(1:1419).category});
    
end