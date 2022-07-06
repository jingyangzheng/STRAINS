% feature detection function
% gets green peaks, green changepoints, blue peaks, blue changepoints


% dependencies:
% requires export_fig from the Matlab Fileshare found here: https://www.mathworks.com/matlabcentral/fileexchange/23629-export_fig
% requires Matlab Signal Processing Toolbox and Mapping Toolbox

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



function FeatureExtraction(folder, date, position, params, print)
    % load data and smooth
    load(strcat(folder, date, '\pos',position,'\pos', position, '_intensity.mat'));
    intensity_mat(:,1) = []; % remove time column
    red_all = smoothdata(intensity_mat(:,1:3:end),'movmean',30);
    green_all = smoothdata(intensity_mat(:,2:3:end),'movmean',30);
    blue_all = smoothdata(intensity_mat(:,3:3:end),'movmean',30);

    num_cells = size(intensity_mat, 2)/3;

    timeserieslength = size(red_all,1);
    SetFigureDefaults(timeserieslength);

    % make feature extraction folder
    fe_folder = strcat(folder, date, '\pos', position, '\feature_extraction\');
    mkdir(fe_folder);

    %% green - calcium
    % peak detection
    
    mkdir(strcat(fe_folder, 'green_peaks\'));
    g_peakparentpath = strcat(fe_folder, 'green_peaks\prom',num2str(params.g_minpeakprom),...
        '_ratio', num2str(params.g_wpratio),'\');
    mkdir(g_peakparentpath);
    g_peaksavepath = strcat(g_peakparentpath,'\peaks\');
    mkdir(g_peaksavepath);
    g_nopeaksavepath = strcat(g_peakparentpath,'\nopeaks\');
    mkdir(g_nopeaksavepath);
    g_removedsavepath = strcat(g_peakparentpath,'\removed_peaks\');
    mkdir(g_removedsavepath);    

    green_peaks = struct;
    peaks_processed = struct;
    for i = 1:num_cells
        cellfilename = strcat('cell_',num2str(i),'.png');
        
        [green_peaks(i).peaks, green_peaks(i).peaktime, green_peaks(i).width, ...
            green_peaks(i).prominence] = findpeaks(green_all(:,i),'MinPeakProminence', params.g_minpeakprom);

        % divide width by prominence to get a shape ratio
        green_peaks(i).width_prom_ratio = green_peaks(i).width ./ green_peaks(i).prominence;

        % if there are multiple peaks, and if there are any in the array with ratio higher than set amount then
        if sum(green_peaks(i).width_prom_ratio > params.g_wpratio) > 0
            % check for multiples where one peak is valid and the other not
            tuple = find(green_peaks(i).width_prom_ratio < params.g_wpratio);
            if isempty(tuple)
                peaks_processed(i).peaks = [];
                peaks_processed(i).peaktime = [];
                peaks_processed(i).width = [];
                peaks_processed(i).prominence = [];
                peaks_processed(i).width_prom_ratio = [];
                if strcmp(print, 'on') == 1
                    figure
                    set(gcf,'Visible', 'off');
                    findpeaks(green_all(:,i),'MinPeakProminence', params.g_minpeakprom, 'Annotate', 'extents');
                    ax = gca;
                    ax.YLim = [0 256];
                    ax.XLabel.String = 'Frame';
                    ax.YLabel.String = 'Intensity';
                    pkfig = export_fig(strcat(g_removedsavepath,cellfilename),'-png','-transparent'); %export_fig is a code from Matlab Fileshare
                    close(gcf);
                end
            else
                peaks_processed(i).peaks = green_peaks(i).peaks(tuple);
                peaks_processed(i).peaktime = green_peaks(i).peaktime(tuple);
                peaks_processed(i).width = green_peaks(i).width(tuple);
                peaks_processed(i).prominence = green_peaks(i).prominence(tuple);
                peaks_processed(i).width_prom_ratio = green_peaks(i).width_prom_ratio(tuple);
                if strcmp(print, 'on') == 1
                    figure
                    set(gcf,'Visible', 'off');
                    findpeaks(green_all(:,i),'MinPeakProminence', params.g_minpeakprom, 'Annotate', 'extents');
                    ax = gca;
                    ax.YLim = [0 256];
                    ax.XLabel.String = 'Frame';
                    ax.YLabel.String = 'Intensity';
                    pkfig = export_fig(strcat(g_peaksavepath,cellfilename),'-png','-transparent'); %export_fig is a code from Matlab Fileshare
                    close(gcf);
                end
            end
        elseif green_peaks(i).peaks > params.g_early_peak_height_filter & ...
                green_peaks(i).peaktime < params.g_early_peak_height_filter
            peaks_processed(i).peaks = [];
            peaks_processed(i).peaktime = [];
            peaks_processed(i).width = [];
            peaks_processed(i).prominence = [];
            peaks_processed(i).width_prom_ratio = [];
            if strcmp(print, 'on') == 1
            figure
                set(gcf,'Visible', 'off');
                findpeaks(green_all(:,i),'MinPeakProminence', params.g_minpeakprom, 'Annotate', 'extents');
                ax = gca;
                ax.YLim = [0 256];
                ax.XLabel.String = 'Frame';
                ax.YLabel.String = 'Intensity';
                pkfig = export_fig(strcat(g_removedsavepath,cellfilename),'-png','-transparent'); %export_fig is a code from Matlab Fileshare
                close(gcf);
            end
        elseif isempty(green_peaks(i).peaks) % if there are no peaks
            peaks_processed(i).peaks = [];
            peaks_processed(i).peaktime = [];
            peaks_processed(i).width = [];
            peaks_processed(i).prominence = [];
            peaks_processed(i).width_prom_ratio = [];
            if strcmp(print, 'on') == 1
                figure
                set(gcf,'Visible', 'off');
                findpeaks(green_all(:,i),'MinPeakProminence', params.g_minpeakprom, 'Annotate', 'extents');
                ax = gca;
                ax.YLim = [0 256];
                ax.XLabel.String = 'Frame';
                ax.YLabel.String = 'Intensity';
                pkfig = export_fig(strcat(g_nopeaksavepath,cellfilename),'-png','-transparent'); %export_fig is a code from Matlab Fileshare
                close(gcf);
            end
        else % there are peaks
            peaks_processed(i).peaks = green_peaks(i).peaks;
            peaks_processed(i).peaktime = green_peaks(i).peaktime;
            peaks_processed(i).width = green_peaks(i).width;
            peaks_processed(i).prominence = green_peaks(i).prominence;
            peaks_processed(i).width_prom_ratio = green_peaks(i).width_prom_ratio;
            if strcmp(print, 'on') == 1
                figure
                set(gcf,'Visible', 'off');
                findpeaks(green_all(:,i),'MinPeakProminence', params.g_minpeakprom, 'Annotate', 'extents');
                ax = gca;
                ax.YLim = [0 256];
                ax.XLabel.String = 'Frame';
                ax.YLabel.String = 'Intensity';
                pkfig = export_fig(strcat(g_peaksavepath,cellfilename),'-png','-transparent'); %export_fig is a code from Matlab Fileshare
                close(gcf);
            end
        end

    end
    save(strcat(g_peaksavepath,'green_peaks.mat'),'green_peaks');
    save(strcat(g_peaksavepath,'green_peaks_processed.mat'),'peaks_processed');

    %% green changepoints

    mkdir(strcat(fe_folder, 'green_changepts\'));
    g_cpparentpath = strcat(fe_folder, 'green_changepts\lin_thresh', ...
        num2str(params.g_threshold),'\');
    mkdir(g_cpparentpath);
    g_cpsavepath = strcat(g_cpparentpath,'\haschangepoint\');
    mkdir(g_cpsavepath);
    g_nocpsavepath = strcat(g_cpparentpath,'\nochangepoint\');
    mkdir(g_nocpsavepath);
    g_cppeakspath = strcat(g_cpparentpath,'\peaks\');
    mkdir(g_cppeakspath); 
    
    load(strcat(g_peaksavepath, '\green_peaks_processed.mat'));

    green_changept = struct;
    for i = 1:num_cells
        cellfilename = strcat('cell_',num2str(i),'.png');
        
        [green_changept(i).ipt, green_changept(i).resid] = ...
            findchangepts(green_all(:,i), 'Statistic', 'linear', 'MinThreshold', params.g_threshold);
        if isempty(peaks_processed(i).peaks) == 0 % if there is a previously detected peak
            % make the figure but put it in peaks
            if strcmp(print, 'on') == 1
                figure
                set(gcf,'Visible', 'off');
                findchangepts(green_all(:,i), 'Statistic', 'linear', 'MinThreshold', params.g_threshold);
                ax = gca;
                ax.YLim = [0 256];
                ax.XLabel.String = 'Frame';
                ax.YLabel.String = 'Intensity';
                pkfig = export_fig(strcat(g_cppeakspath,cellfilename),'-png','-transparent'); %export_fig is a code from Matlab Fileshare
                close(gcf);
            end
        elseif isempty(green_changept(i).ipt) == 0 % if there is a changepoint
            if strcmp(print, 'on') == 1
                figure
                set(gcf,'Visible', 'off');
                findchangepts(green_all(:,i), 'Statistic', 'linear', 'MinThreshold', params.g_threshold);
                ax = gca;
                ax.XLabel.String = 'Frame';
                ax.YLabel.String = 'Intensity';
                pkfig = export_fig(strcat(g_cpsavepath,cellfilename),'-png','-transparent'); %export_fig is a code from Matlab Fileshare
                close(gcf);
            end
            
            % calculate slopes
            slopes = zeros(length(green_changept(i).ipt),2);
            % for the length of the change point array plus one, find slopes
            for j = 1:length(green_changept(i).ipt)+1
                slopeends = vertcat(1,green_changept(i).ipt,timeserieslength);
                slopes(j,:) = polyfit(linspace(slopeends(j),slopeends(j+1),(slopeends(j+1)-slopeends(j)+1))',...
                    green_all(slopeends(j):slopeends(j+1),i),1);
            end
            green_changept(i).slopes = slopes(:,1);

        else % if there is no changepoint
            green_changept(i).slopes = [];
            if strcmp(print, 'on') == 1
                figure
                set(gcf,'Visible', 'off');
                findchangepts(green_all(:,i), 'Statistic', 'linear', 'MinThreshold', params.g_threshold);
                ax = gca;
                ax.XLabel.String = 'Frame';
                ax.YLabel.String = 'Intensity';
                pkfig = export_fig(strcat(g_nocpsavepath,cellfilename),'-png','-transparent'); %export_fig is a code from Matlab Fileshare
                close(gcf);
            end

        end

    end

    save(strcat(g_cpsavepath,'green_changept.mat'),'green_changept');


    % get slopes before/after changepoints
    % don't do this for cells with peaks, the slope doesn't get calculated for those
    
    g_cpprocessedpath = strcat(g_cpsavepath,'\slopedif',num2str(params.g_slopedif*100),'\');
    mkdir(g_cpprocessedpath);

    green_processed = struct;
    for i = 1:num_cells
        cellfilename = strcat('cell_',num2str(i),'.png');
        % if there are change points and there are no peaks
        if isempty(green_changept(i).ipt) == 0 && isempty(peaks_processed(i).peaks)
            % first copy over all of the info
            green_processed(i).ipt = green_changept(i).ipt;
            % initialize a temporary array to calculate slope differences
            tempdif = zeros(length(green_changept(i).ipt)-1,1);
            % check slope differences
            for j = 1:length(green_changept(i).ipt)
                tempdif(j) = abs(green_changept(i).slopes(j+1)-green_changept(i).slopes(j));
            end
            % remove the points if the slope differences are smaller than the
            % predetermined value
            green_processed(i).ipt(find(tempdif < params.g_slopedif)) = [];
            % now check to see if there is still a changepoint and plot if
            % there is
            if isempty(green_processed(i).ipt) == 0 && strcmp(print, 'on') == 1
                figure
                set(gcf,'Visible', 'off');
                hold on
                plot(linspace(1,750,750)',green_all(:,i));
                plot(green_processed(i).ipt,green_all(green_processed(i).ipt,i),'Marker','v');
                ax = gca;
                ax.XLabel.String = 'Frame';
                ax.YLabel.String = 'Intensity';
                pkfig = export_fig(strcat(g_cpprocessedpath,cellfilename),'-png','-transparent'); %export_fig is a code from Matlab Fileshare
                hold off
                close(gcf);
            end
        else
            green_processed(i).ipt = [];
        end
    end
    save(strcat(g_cpprocessedpath,'green_processed.mat'),'green_processed');



    %% blue peaks
    
    mkdir(strcat(fe_folder, 'blue_peaks\'));
    b_peakparentpath = strcat(fe_folder, 'blue_peaks\prom',num2str(params.b_minpeakprom),...
        '_ratio', num2str(params.b_wpratio),'\');
    mkdir(b_peakparentpath);
    b_peaksavepath = strcat(b_peakparentpath,'\peaks\');
    mkdir(b_peaksavepath);
    b_nopeaksavepath = strcat(b_peakparentpath,'\nopeaks\');
    mkdir(b_nopeaksavepath);
    b_removedsavepath = strcat(b_peakparentpath,'\removed_peaks\');
    mkdir(b_removedsavepath);
    
    blue_peaks = struct;
    blue_peaks_processed = struct;
    for i = 1:num_cells
        cellfilename = strcat('cell_',num2str(i),'.png');
        [blue_peaks(i).peaks, blue_peaks(i).peaktime, blue_peaks(i).width, ...
            blue_peaks(i).prominence] = findpeaks(blue_all(:,i),'MinPeakProminence', params.b_minpeakprom);

        % divide width by prominence to get a shape ratio
        blue_peaks(i).width_prom_ratio = blue_peaks(i).width ./ blue_peaks(i).prominence;

        % if there are multiple peaks, and if there are any in the array with ratio higher than set amount then
        if sum(blue_peaks(i).width_prom_ratio > params.b_wpratio) > 0
            % check for multiples where one peak is valid and the other not
            tuple = find(blue_peaks(i).width_prom_ratio < params.b_wpratio);
            if isempty(tuple)
                blue_peaks_processed(i).peaks = [];
                blue_peaks_processed(i).peaktime = [];
                blue_peaks_processed(i).width = [];
                blue_peaks_processed(i).prominence = [];
                blue_peaks_processed(i).width_prom_ratio = [];
                if strcmp(print, 'on') == 1
                    figure
                    set(gcf,'Visible', 'off');
                    findpeaks(blue_all(:,i),'MinPeakProminence', params.b_minpeakprom, 'Annotate', 'extents');
                    ax = gca;
                    ax.YLim = [0 256];
                    ax.XLabel.String = 'Frame';
                    ax.YLabel.String = 'Intensity';
                    pkfig = export_fig(strcat(b_removedsavepath,cellfilename),'-png','-transparent'); %export_fig is a code from Matlab Fileshare
                    close(gcf);
                end
            else
                blue_peaks_processed(i).peaks = blue_peaks(i).peaks(tuple);
                blue_peaks_processed(i).peaktime = blue_peaks(i).peaktime(tuple);
                blue_peaks_processed(i).width = blue_peaks(i).width(tuple);
                blue_peaks_processed(i).prominence = blue_peaks(i).prominence(tuple);
                blue_peaks_processed(i).width_prom_ratio = blue_peaks(i).width_prom_ratio(tuple);
                if strcmp(print, 'on') == 1
                    figure
                    set(gcf,'Visible', 'off');
                    findpeaks(blue_all(:,i),'MinPeakProminence', params.b_minpeakprom, 'Annotate', 'extents');
                    ax = gca;
                    ax.YLim = [0 256];
                    ax.XLabel.String = 'Frame';
                    ax.YLabel.String = 'Intensity';
                    pkfig = export_fig(strcat(b_peaksavepath,cellfilename),'-png','-transparent'); %export_fig is a code from Matlab Fileshare
                    close(gcf);
                end
            end
        elseif isempty(blue_peaks(i).peaks) % if there are no peaks
            blue_peaks_processed(i).peaks = [];
            blue_peaks_processed(i).peaktime = [];
            blue_peaks_processed(i).width = [];
            blue_peaks_processed(i).prominence = [];
            blue_peaks_processed(i).width_prom_ratio = [];
            if strcmp(print, 'on') == 1
                figure
                set(gcf,'Visible', 'off');
                findpeaks(blue_all(:,i),'MinPeakProminence', params.b_minpeakprom, 'Annotate', 'extents');
                ax = gca;
                ax.YLim = [0 256];
                ax.XLabel.String = 'Frame';
                ax.YLabel.String = 'Intensity';
                pkfig = export_fig(strcat(b_nopeaksavepath,cellfilename),'-png','-transparent'); %export_fig is a code from Matlab Fileshare
                close(gcf);
            end
        else % there are peaks
            blue_peaks_processed(i).peaks = blue_peaks(i).peaks;
            blue_peaks_processed(i).peaktime = blue_peaks(i).peaktime;
            blue_peaks_processed(i).width = blue_peaks(i).width;
            blue_peaks_processed(i).prominence = blue_peaks(i).prominence;
            blue_peaks_processed(i).width_prom_ratio = blue_peaks(i).width_prom_ratio;
            if strcmp(print, 'on') == 1
                figure
                set(gcf,'Visible', 'off');
                findpeaks(blue_all(:,i),'MinPeakProminence', params.b_minpeakprom, 'Annotate', 'extents');
                ax = gca;
                ax.YLim = [0 256];
                ax.XLabel.String = 'Frame';
                ax.YLabel.String = 'Intensity';
                pkfig = export_fig(strcat(b_peaksavepath,cellfilename),'-png','-transparent'); %export_fig is a code from Matlab Fileshare
                close(gcf);
            end
        end

    end
    save(strcat(b_peaksavepath,'blue_peaks.mat'),'blue_peaks');
    save(strcat(b_peaksavepath,'blue_peaks_processed.mat'),'blue_peaks_processed');


    %% blue changepoints
    mkdir(strcat(fe_folder, 'blue_changepts\'));
    b_cpparentpath = strcat(fe_folder, 'blue_changepts\lin_thresh', ...
        num2str(params.b_threshold),'\');
    mkdir(b_cpparentpath);
    b_cpsavepath = strcat(b_cpparentpath,'\haschangepoint\');
    mkdir(b_cpsavepath);
    b_nocpsavepath = strcat(b_cpparentpath,'\nochangepoint\');
    mkdir(b_nocpsavepath);
    b_cppeakspath = strcat(b_cpparentpath,'\peaks\');
    mkdir(b_cppeakspath); 
    
    load(strcat(b_peaksavepath, '\blue_peaks_processed.mat'));
    
    blue_changept = struct;
    for i = 1:num_cells
        cellfilename = strcat('cell_',num2str(i),'.png');
        [blue_changept(i).ipt, blue_changept(i).resid] = ...
            findchangepts(blue_all(:,i), 'Statistic', 'linear', 'MinThreshold', params.b_threshold);
        if isempty(blue_changept(i).ipt) == 0 % if there is a changepoint
            if strcmp(print, 'on') == 1
                figure
                set(gcf,'Visible', 'off');
                findchangepts(blue_all(:,i), 'Statistic', 'linear', 'MinThreshold', params.b_threshold);
                ax = gca;
                ax.XLabel.String = 'Frame';
                ax.YLabel.String = 'Intensity';
                ax.YLim = [0 75];
                pkfig = export_fig(strcat(b_cpsavepath,cellfilename),'-png','-transparent'); %export_fig is a code from Matlab Fileshare
                close(gcf);
            end

            % calculate slopes
            slopes = zeros(length(blue_changept(i).ipt),2);
            % for the length of the change point array plus one, find slopes
            for j = 1:length(blue_changept(i).ipt)+1
                slopeends = vertcat(1,blue_changept(i).ipt,timeserieslength);
                slopes(j,:) = polyfit(linspace(slopeends(j),slopeends(j+1),(slopeends(j+1)-slopeends(j)+1))',...
                    blue_all(slopeends(j):slopeends(j+1),i),1);
            end
            blue_changept(i).slopes = slopes(:,1);

        else % if there is no changepoint
            blue_changept(i).slopes = [];
            if strcmp(print, 'on') == 1
                figure
                set(gcf,'Visible', 'off');
                findchangepts(blue_all(:,i), 'Statistic', 'linear', 'MinThreshold', params.b_threshold);
                ax = gca;
                ax.XLabel.String = 'Frame';
                ax.YLabel.String = 'Intensity';
                ax.YLim = [0 75];
                pkfig = export_fig(strcat(b_nocpsavepath,cellfilename),'-png','-transparent'); %export_fig is a code from Matlab Fileshare
                close(gcf);
            end
        end

    end
    save(strcat(b_cpsavepath,'blue_changept.mat'),'blue_changept');

    
    
    b_cpprocessedpath = strcat(b_cpsavepath,'\slopedif',num2str(params.b_slopedif*100),'\');
    mkdir(b_cpprocessedpath);

    blue_processed = struct;
    for i = 1:num_cells
        cellfilename = strcat('cell_',num2str(i),'.png');
        % if there are change points
        if isempty(blue_changept(i).ipt) == 0
            % first copy over all of the info
            blue_processed(i).ipt = blue_changept(i).ipt;
            % initialize a temporary array to calculate slope differences
            tempdif = zeros(length(blue_changept(i).ipt)-1,1);
            % check slope differences
            for j = 1:length(blue_changept(i).ipt)
                tempdif(j) = abs(blue_changept(i).slopes(j+1)-blue_changept(i).slopes(j));
            end
            % remove the points if the slope differences are smaller than the
            % predetermined value
            blue_processed(i).ipt(find(tempdif < params.b_slopedif)) = [];
            % now check to see if there is still a changepoint and plot if
            % there is
            if isempty(blue_processed(i).ipt) == 0 && strcmp(print, 'on') == 1
                figure
                set(gcf,'Visible', 'off');
                hold on
                plot(linspace(1,750,750)',blue_all(:,i));
                plot(blue_processed(i).ipt,blue_all(blue_processed(i).ipt,i),'Marker','v');
                ax = gca;
                ax.XLabel.String = 'Frame';
                ax.YLabel.String = 'Intensity';
                pkfig = export_fig(strcat(b_cpprocessedpath,cellfilename),'-png','-transparent'); %export_fig is a code from Matlab Fileshare
                hold off
                close(gcf);
            end
        else
            blue_processed(i).ipt = [];
        end
    end
    save(strcat(b_cpprocessedpath,'blue_processed.mat'),'blue_processed');


    save(strcat(fe_folder,'params.mat'),'params');

end
