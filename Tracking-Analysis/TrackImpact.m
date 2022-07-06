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


% 8-bit image input, not RGB

function TrackImpact(folder, date, params, print)

    % imput parameters
    video_type = 'impact';
        
    % run_track
    % Obtain pathnames and make directory for long trajectories
    image_name = strcat(video_type,'.tif');
    ImPath = strcat(folder,date,'\');
    WritePath = strcat(ImPath, video_type);
    mkdir([ ImPath  video_type ])
    TrackPath = strcat(WritePath, '\track');
    mkdir([ WritePath '\track' ])
    LongPath = strcat(WritePath, '\long');
    mkdir([ WritePath '\long' ])
    IntensityPath = strcat(WritePath, '\intensity');
    mkdir([ WritePath '\intensity' ])

    % Obtain info from image
    info = imfinfo(fullfile(ImPath,image_name)); % gives info about tiff stack
    rowdim = info.Height;
    coldim = info.Width;
    total_imgs = numel(info);
    num_frames = total_imgs;

    % read in tiff stack, save to stack1
    stack1 = zeros(rowdim, coldim, num_frames, 'uint8');
    for k = 1 : total_imgs
        temp_tiff = imread(fullfile(ImPath,strcat(video_type,'.tif')), k);
        stack1(:,:,k) = temp_tiff;
    end

    % load time data
    load(strcat(folder,date,'\time.mat'), 'time');
    time = time(1:num_frames);

    %% Run particle tracking code
    
    warning('off','all')
    positionstack = [0,0,0]; % intialize positionstack as something

    % Implement codes and write results
    % implement bpass code for each slice
    bpass_stack = zeros(rowdim, coldim, num_frames);
    for i = 1:num_frames
        bpass_stack(:,:,i) = bpass(stack1(:,:,i),params.bpass.lnoise,...
            params.bpass.lobject,params.bpass.threshold);
    end

    % implement pkfnd and cntrd code for each slice
    for i = 1:num_frames
        pkfnd_temp = pkfnd(bpass_stack(:,:,i),params.pkfnd.th,params.pkfnd.sz);
        cntrd_temp = cntrd(bpass_stack(:,:,i),pkfnd_temp,params.cntrd.win);
        templist(:,1) = cntrd_temp(:,1);
        templist(:,2) = cntrd_temp(:,2);
        templist(:,3) = (i);
        positionstack = vertcat(positionstack,templist);
        templist = [];
    end

    % implement track
    positionstack(1,:) = []; % delete the first row of zeros from positionstack
    tot_traj = track(positionstack,params.track.maxdisp,params.track.param);

    % save results as an excel spreadsheet, save parameters as .mat file
    result_filename = fullfile(WritePath,strcat(video_type,'_result.mat'));
    save(result_filename,'tot_traj');
    param_filename = fullfile(WritePath,strcat(video_type,'_param.mat'));
    save(param_filename,'params');

    %% track all
    % Read trajectories file
    id = tot_traj(:,4); % id number of each tracked trajectory
    tid = tot_traj(:,3); % times
    len = length(tot_traj);
    num_traj = tot_traj(len,4); % total number of trajectories
    sortedx = NaN(total_imgs,num_traj);
    sortedy = NaN(total_imgs,num_traj);

    % sort into columns where each column is a separate time
    % i.e. 10s, 20s, 30s, etc
    % split into separate x and y matrices
    xbyt = NaN(num_traj,num_frames);
    ybyt = NaN(num_traj,num_frames);
    for i = 1:total_imgs
        timeind = find(tid == i);
        for j = 1:length(timeind)
            xbyt(j,i) = tot_traj(timeind(j),1);
            ybyt(j,i) = tot_traj(timeind(j),2);
        end
    end
    f1loc_filename = fullfile(WritePath,strcat(video_type,'_f1loc.mat'));
    % if isfile(f1loc_filename)
    %     recycle on % Send to recycle bin instead of permanently deleting.
    %     delete(f1loc_filename); % Delete (send to recycle bin).
    % end
    f1loc = horzcat(xbyt(:,1),ybyt(:,1));
    save(f1loc_filename,'f1loc');

    % sort trajectories, separate columns are separate trajectories
    for i = 1:num_traj
        temp_id = find(id == i);
        for j = 1:length(temp_id)
            sortedx(j,i) = tot_traj(temp_id(j),1);
            sortedy(j,i) = tot_traj(temp_id(j),2);
        end
    end
    sortall_filename = fullfile(WritePath,strcat(video_type,'_sorted_all.mat'));
    % if isfile(sortall_filename)
    %     recycle on % Send to recycle bin instead of permanently deleting.
    %     delete(sortall_filename); % Delete (send to recycle bin).
    % end
    sorted_all = horzcat(sortedx,sortedy);
    save(sortall_filename,'sorted_all');

    %% Plotting for all trajectories
    % plot first figure on top of first frame in tiff stack
    
    if strcmp(print, 'on') == 1
        c = figure;
        set(gcf,'Visible', 'off');
        imshow(stack1(:,:,1));
        truesize(c,[rowdim coldim]);
        hold on
        scatter(xbyt(:,1),ybyt(:,1),'Marker','.','MarkerEdgeColor','m');
        A = export_fig(fullfile(TrackPath,'impact_track_1.tif'),'-tiff','-transparent'); %export_fig is a code from Matlab Fileshare
        imwrite(A,fullfile(TrackPath,'impact_track.tif'));
        close(c);

        % plot remaining images and append to tiff stack
        for k = 2:num_frames
            c = figure;
            set(gcf,'Visible', 'off');
            imshow(stack1(:,:,k-1));
            truesize(c,[rowdim coldim]);
            hold on
            scatter(xbyt(:,k-1),ybyt(:,k-1),'Marker','.','MarkerEdgeColor','m');
            tempimg = export_fig(fullfile(TrackPath,strcat('impact_track_',num2str(k),'.tif')),'-tiff','-transparent'); %export_fig is a code from Matlab Fileshare
            imwrite(tempimg,fullfile(TrackPath,'impact_track.tif'),'Writemode','append');
            close(c);
        end
    else
        disp('Not printing images to file');
    end

    %% Track long
    % keep only trajectories that have been tracked for longer than params.length_filter
    % firsttrackframe is not really used here
    id = tot_traj(:,4); % id number of each tracked trajectory
    len = length(tot_traj);
    num_traj = tot_traj(len,4); % total number of trajectories

    long_traj = zeros(1,4);
    track_array = zeros(num_frames,1);
    track_with_time = zeros(num_frames,1);
    num_long = 0;
    firsttrackframe = 1;
    for i = 1:num_traj
        temp_id = find(id == i);
        if temp_id(1,1) >= firsttrackframe && length(temp_id) >= params.length_filter
            for j = 1:length(temp_id)
                tempvec(j,:) = tot_traj(temp_id(j),:);
            end
            long_traj = vertcat(long_traj,tempvec);
            num_long = num_long + 1;
            track_array = pad_cat(track_array,tempvec(:,1:2),2);
            track_with_time = pad_cat(track_with_time,tempvec(:,1:3),2);
        end
        tempvec = [];
        temp_id = [];
    end
    long_traj(1,:) = [];
    track_array(:,1) = [];
    track_with_time(:,1) = [];
    save(fullfile(WritePath,strcat(video_type,'_long.mat')),'long_traj');
    save(fullfile(WritePath,strcat(video_type,'_sorted.mat')),'track_array');
    save(fullfile(WritePath,strcat(video_type,'_sorted_with_time.mat')),'track_with_time');

    % fill in untracked frames 
    sorted_long = NaN(num_frames,num_long*2);
    temp = NaN(num_frames,num_long*2);
    % fill in zeros for untracked frames
    for i = 1:num_long
        temp = track_with_time(:,(i*3-2):(i*3));
        temp = temp(all(~isnan(temp),2),:);
        % remove nan row or column
        % out = A(all(~isnan(A),2),:); % for nan - rows
        % out = A(:,all(~isnan(A)));   % for nan - columns
        for j = 1:num_frames
            tempind = find(temp(:,3) == j);
            if isempty(tempind)
                sorted_long(j,i*2-1) = 0;
                sorted_long(j,i*2) = 0;
            else
                sorted_long(j,i*2-1) = temp(tempind,1);
                sorted_long(j,i*2) = temp(tempind,2);
            end
        end
    end
    % interpolate and fill in ends
    filled_long = NaN(num_frames,num_long*2);
    for i = 1:num_long*2
        % interpolate
        temp2 = sorted_long(:,i);
        zeroind = find(temp2(:,1) == 0);
        x = 1:length(temp2);
        xi = 1:length(temp2);
        temp2(zeroind) = [];
        x(zeroind) = [];
        temp2_interp = interp1(x,temp2,xi)';
        temp2_interp = fillmissing(temp2_interp,'nearest');
        filled_long(:,i) = temp2_interp;
    end
    save(fullfile(WritePath,strcat(video_type,'_locs.mat')),'filled_long');

    % sort into columns where each column is a separate time
    % i.e. 10s, 20s, 30s, etc
    % split into separate x and y matrices
    xbyt_long = NaN(num_long,num_frames);
    ybyt_long = NaN(num_long,num_frames);
    tid_long = long_traj(:,3);
    for ii = 1:total_imgs
        timeind = find(tid_long == ii); 
        for jj = 1:length(timeind)
                xbyt_long(jj,ii) = long_traj(timeind(jj),1);
                ybyt_long(jj,ii) = long_traj(timeind(jj),2);
        end
    end
    save(fullfile(WritePath,strcat(video_type,'_xbyt_long.mat')),'xbyt_long');
    save(fullfile(WritePath,strcat(video_type,'_ybyt_long.mat')),'ybyt_long');

    %% tracking check
    xbyt_filled = NaN(num_long,num_frames);
    ybyt_filled = NaN(num_long,num_frames);
    xbyt_temp = filled_long(:,1:2:end);
    ybyt_temp = filled_long(:,2:2:end);
    for i = 1:num_frames
        xbyt_filled(:,i) = xbyt_temp(i,:)';
        ybyt_filled(:,i) = ybyt_temp(i,:)';
    end

    
    if strcmp(print, 'on') == 1
        c = figure;
        set(gcf,'Visible', 'off');
        imshow(stack1(:,:,1));
        truesize(c,[rowdim coldim]);
        hold on
        scatter(xbyt_filled(:,1),ybyt_filled(:,1),'Marker','.','MarkerEdgeColor','m');
        A = export_fig(fullfile(LongPath,'impact_filled1.tif'),...
            '-tiff','-transparent'); %export_fig is a code from Matlab Fileshare
        imwrite(A,fullfile(LongPath,'impact_filled.tif'));
        close(c);

        % plot remaining images and append to tiff stack
        for k = 2:num_frames
            c = figure;
            set(gcf,'Visible', 'off');
            imshow(stack1(:,:,k-1));
            truesize(c,[rowdim coldim]);
            hold on
            scatter(xbyt_filled(:,k-1),ybyt_filled(:,k-1),'Marker','.','MarkerEdgeColor','m');
            tempimg = export_fig(fullfile(LongPath,strcat('impact_filled',num2str(k),'.tif')),...
                '-tiff','-transparent'); %export_fig is a code from Matlab Fileshare
            imwrite(tempimg,fullfile(LongPath,'impact_filled.tif'),'Writemode','append');
            close(c);
        end
    else
        disp('Not printing images to file');
    end

    %% Determine intensity information
    % read trajectories in sorted format and extract intensity information
    smooth_window = 20;
    min_peak_prominence = 10;

    num_curves = size(filled_long,2)/2;
    int_curves = NaN(total_imgs,num_curves);
    temp_coord = zeros(total_imgs,2);
    for j = 1:num_curves
        % intialize for each curve
        onecurve = zeros(total_imgs,3,'double');
        ag = zeros(3,3);
        temp_coord(:,1) = filled_long(:,j*2-1);
        temp_coord(:,2) = filled_long(:,j*2);
        % for each coordinate, take average of selected pixel + 8 surrounding
        % pixels, rounding occurs for pixel location
        for i = 1:length(temp_coord)
            xtemp = round(temp_coord(i,2));
            ytemp = round(temp_coord(i,1));
            if isnan(xtemp)
                break
            end
            frame = i;
            ag(1,1) = double(stack1(xtemp+1,ytemp+1,frame));
            ag(1,2) = double(stack1(xtemp+1,ytemp,frame));
            ag(1,3) = double(stack1(xtemp+1,ytemp-1,frame));
            ag(2,1) = double(stack1(xtemp,ytemp+1,frame));
            ag(2,2) = double(stack1(xtemp,ytemp,frame));
            ag(2,3) = double(stack1(xtemp,ytemp-1,frame));
            ag(3,1) = double(stack1(xtemp-1,ytemp+1,frame));
            ag(3,2) = double(stack1(xtemp-1,ytemp,frame));
            ag(3,3) = double(stack1(xtemp-1,ytemp-1,frame));
            avg_val_g = mean(mean(ag));
            onecurve(i,1) = avg_val_g;
        end
        int_curves(:,j) = onecurve(:,1);
    end

    intensity_filename = fullfile(WritePath,strcat(video_type,'_intensity.mat'));
    intensity_mat = horzcat(time,int_curves);
    save(intensity_filename,'intensity_mat');
    smooth_int = smoothdata(int_curves,'movmean',smooth_window); % smooth to moving average with window size smooth_window
    smooth_filename = fullfile(WritePath,strcat(video_type,'_smooth.mat'));
    smooth_mat = horzcat(time,smooth_int);
    save(smooth_filename,'smooth_mat');

    %% Save intensity plots
    for i = 1:num_curves
        figure
        set(gcf,'Visible', 'off');
        hold on
        ax = gca;
        ax.YLim = [0 256];
        ax.TickLabelInterpreter = 'LaTeX';
        ax.FontName = 'LaTeX';
        ax.FontSize = 14;
        ax.Title.Interpreter = 'LaTeX';
        ax.XLabel.Interpreter = 'LaTeX';
        ax.YLabel.Interpreter = 'LaTeX';
        ax.XLabel.String = 'Time (min)';
        ax.YLabel.String = 'Intensity (arbitrary units)';
        plot(time,smooth_int(:,i),'LineWidth',2,'Color','g');
        legend(strcat(num2str(round(track_array(1,i*2-1))),',',num2str(round(track_array(1,i*2)))));
        pkfig = export_fig(fullfile(IntensityPath,strcat(video_type,'_curves_',num2str(i),'.png')),'-png','-transparent'); %export_fig is a code from Matlab Fileshare
        close(gcf);
    end

end