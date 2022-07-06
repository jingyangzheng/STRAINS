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


% ensure that all tifs are rgb format before using this code
% when switching from slidebook, r and b may need to be flipped. Do this in imageJ

function TrackPostImpact(folder, date, position, params, print, movement_end)
   
    % Obtain pathnames and make directory for long trajectories
    image_name = strcat('pos',position,'.tif');
    ImPath = strcat(folder,date,'\');
    WritePath = strcat(ImPath, 'pos',position);
    mkdir([ ImPath  strcat('pos',position) ])
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
    stack_red = zeros(rowdim, coldim, num_frames, 'uint8');
    stack_green = zeros(rowdim, coldim, num_frames, 'uint8');
    stack_blue = zeros(rowdim, coldim, num_frames, 'uint8');
    for k = 1 : total_imgs
        temp_tiff = imread(fullfile(ImPath,image_name), k);
        stack_red(:,:,k) = temp_tiff(:,:,1);
        stack_green(:,:,k) = temp_tiff(:,:,2);
        stack_blue(:,:,k) = temp_tiff(:,:,3);
        stack1(:,:,k) = temp_tiff(:,:,1)+temp_tiff(:,:,2)+temp_tiff(:,:,3);
    end
    
    % load time data
    load(strcat(folder,date,'\time.mat'), 'time');
    time = time((size(time,1)-num_frames+1):end,1);

    %% Run particle tracking code
    % Fill in parameters needed for tracking functions
    warning('off','all')
    % just changed this from 4
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
    result_filename = fullfile(WritePath,strcat('pos',position,'_result.mat'));
    save(result_filename,'tot_traj');
    param_filename = fullfile(WritePath,strcat('pos',position,'_param.mat'));
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

    f1loc = horzcat(xbyt(:,1),ybyt(:,1));
    save(fullfile(WritePath,strcat('pos',position,'_f1loc.mat')),'f1loc');
    save(fullfile(WritePath,strcat('pos',position,'_xbyt.mat')),'xbyt');
    save(fullfile(WritePath,strcat('pos',position,'_ybyt.mat')),'ybyt');

    % sort trajectories, separate columns are separate trajectories
    for i = 1:num_traj
        temp_id = find(id == i);
        for j = 1:length(temp_id)
            sortedx(j,i) = tot_traj(temp_id(j),1);
            sortedy(j,i) = tot_traj(temp_id(j),2);
        end
    end

    sorted_all = horzcat(sortedx,sortedy);
    save(fullfile(WritePath,strcat('pos',position,'_sorted_all.mat')),'sorted_all');

    %% Plotting for all trajectories
    % plot first figure on top of first frame in tiff stack
    if strcmp(print, 'on') == 1
        c = figure;
        set(gcf,'Visible', 'off');
        imshow(stack1(:,:,1));
        truesize(c,[rowdim coldim]);
        hold on
        scatter(xbyt(:,1),ybyt(:,1),'Marker','.','MarkerEdgeColor','m');
        A = export_fig(fullfile(TrackPath,strcat('pos',position,'_track_1.tif')),'-tiff','-transparent'); %export_fig is a code from Matlab Fileshare
        imwrite(A,fullfile(TrackPath,strcat('pos',position,'_track.tif')));
        close(c);

        % plot remaining images and append to tiff stack
        for k = 2:num_frames
            c = figure;
            set(gcf,'Visible', 'off');
            imshow(stack1(:,:,k-1));
            truesize(c,[rowdim coldim]);
            hold on
            scatter(xbyt(:,k-1),ybyt(:,k-1),'Marker','.','MarkerEdgeColor','m');
            tempimg = export_fig(fullfile(TrackPath,strcat('pos',position,'_track_',num2str(k),'.tif')),'-tiff','-transparent'); %export_fig is a code from Matlab Fileshare
            imwrite(tempimg,fullfile(TrackPath,strcat('pos',position,'_track.tif')),'Writemode','append');
            close(c);
        end
    else
        disp('Not printing images to file');
    end
    %% Track long
    % keep only trajectories that have been tracked for longer than the length_filter parameter
    id = tot_traj(:,4); % id number of each tracked trajectory
    len = length(tot_traj);
    num_traj = tot_traj(len,4); % total number of trajectories

    long_traj = zeros(1,4);
    track_array = zeros(num_frames,1);
    track_with_time = zeros(num_frames,1);
    num_long = 0;
    %firsttrackframe = 1;
    for i = 1:num_traj
        temp_id = find(id == i);
        if length(temp_id) >= params.length_filter %&& tot_traj(temp_id(1),3) <= firsttrackframe
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
    save(fullfile(WritePath,strcat('pos',position,'_long.mat')),'long_traj');
    save(fullfile(WritePath,strcat('pos',position,'_sorted.mat')),'track_array');
    save(fullfile(WritePath,strcat('pos',position,'_sorted_with_time.mat')),'track_with_time');

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
    save(fullfile(WritePath,strcat('pos',position,'_locs.mat')),'filled_long');

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
    save(fullfile(WritePath,strcat('pos',position,'_xbyt_long.mat')),'xbyt_long');
    save(fullfile(WritePath,strcat('pos',position,'_ybyt_long.mat')),'ybyt_long');

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
        A = export_fig(fullfile(LongPath,strcat('pos',position,'_filled1.tif')),...
            '-tiff','-transparent'); %export_fig is a code from Matlab Fileshare
        imwrite(A,fullfile(LongPath,strcat('pos',position,'_filled.tif')));
        close(c);

        % plot remaining images and append to tiff stack
        for k = 2:num_frames
            c = figure;
            set(gcf,'Visible', 'off');
            imshow(stack1(:,:,k-1));
            truesize(c,[rowdim coldim]);
            hold on
            scatter(xbyt_filled(:,k-1),ybyt_filled(:,k-1),'Marker','.','MarkerEdgeColor','m');
            tempimg = export_fig(fullfile(LongPath,strcat('pos',position,'_filled',num2str(k),'.tif')),...
                '-tiff','-transparent'); %export_fig is a code from Matlab Fileshare
            imwrite(tempimg,fullfile(LongPath,strcat('pos',position,'_filled.tif')),'Writemode','append');
            close(c);
        end
    else
        disp('Not printing images to file');
    end

    %% background subtraction

    grid_size = 8; % how many splits across one axis (i.e. 8x8 grid)
    min_count = 20; % how many of the minimum pixels within each grid area to average over

    % Obtain pathnames and make directory for long trajectories
    BGWritePath = strcat(folder,date,'\pos', position,...
        '\intensity_bgsub_', num2str(min_count),'\');
    mkdir([ strcat(folder,date,'\pos', position, '\') ...
        strcat('\intensity_bgsub_', num2str(min_count),'\') ])

    % initialize matrices to store background values
    blue_bg = zeros(grid_size, grid_size, num_frames);
    green_bg = zeros(grid_size, grid_size, num_frames);
    red_bg = zeros(grid_size, grid_size, num_frames);

    % initialize matrices for background subtracted images
    stack_new = zeros(rowdim, coldim, 3, num_frames, 'uint8');

    pixelsplit = rowdim/grid_size;


    % get background
    for i = 1:num_frames
        to_sub_r = zeros(rowdim, coldim, 'uint8');
        to_sub_g = zeros(rowdim, coldim, 'uint8');
        to_sub_b = zeros(rowdim, coldim, 'uint8');
        for m = 1:grid_size
            for n = 1:grid_size
                tempr = stack_red((m-1)*pixelsplit + 1 : m*pixelsplit, ...
                    (n-1)*pixelsplit + 1 : n*pixelsplit, i);
                tempg = stack_green((m-1)*pixelsplit + 1 : m*pixelsplit, ...
                    (n-1)*pixelsplit + 1 : n*pixelsplit, i);
                tempb = stack_blue((m-1)*pixelsplit + 1 : m*pixelsplit, ...
                    (n-1)*pixelsplit + 1 : n*pixelsplit, i);

                red_bg(m, n, i) = round(mean(mink(sort(tempr), min_count), 'all'));
                green_bg(m, n, i) = round(mean(mink(sort(tempg), min_count), 'all'));
                blue_bg(m, n, i) = round(mean(mink(sort(tempb), min_count), 'all'));

                to_sub_r((m-1)*pixelsplit + 1 : m*pixelsplit, (n-1)*pixelsplit + 1 : n*pixelsplit)...
                    = red_bg(m, n, i);
                to_sub_g((m-1)*pixelsplit + 1 : m*pixelsplit, (n-1)*pixelsplit + 1 : n*pixelsplit)...
                    = green_bg(m, n, i);
                to_sub_b((m-1)*pixelsplit + 1 : m*pixelsplit, (n-1)*pixelsplit + 1 : n*pixelsplit)...
                    = blue_bg(m, n, i);

                tempr = [];
                tempg = [];
                tempb = [];

            end
        end

        stack_new(:,:,1,i) = stack_red(:,:,i) - to_sub_r;
        stack_new(:,:,2,i) = stack_green(:,:,i) - to_sub_g;
        stack_new(:,:,3,i) = stack_blue(:,:,i) - to_sub_b;
    end

    % smooth background with surrounding frames

    save(fullfile(BGWritePath, strcat('red_bg_', num2str(min_count),'.mat')), 'red_bg');
    save(fullfile(BGWritePath, strcat('green_bg_', num2str(min_count),'.mat')), 'green_bg');
    save(fullfile(BGWritePath, strcat('blue_bg_', num2str(min_count),'.mat')), 'blue_bg');

    % imwrite(im1,'myMultipageFile.tif')
    % imwrite(im2,'myMultipageFile.tif','WriteMode','append')
    imwrite(stack_new(:,:,:,1), fullfile(BGWritePath,strcat('pos', position,'_bgsub', num2str(min_count),'.tif')));
    for i = 2:num_frames
        imwrite(stack_new(:,:,:,i), fullfile(BGWritePath,strcat('pos', position,'_bgsub', num2str(min_count),'.tif')), 'WriteMode', 'append');
    end

    save(fullfile(BGWritePath,strcat('pos', position,'_bgsub', num2str(min_count),'.mat')), 'stack_new');

    % reasssign names for next section
    stack_red = stack_new(:,:,1,:);
    stack_green = stack_new(:,:,2,:);
    stack_blue = stack_new(:,:,3,:);

    %% get intensity information - combined
    
    filled_locs = filled_long;
    % if movement ends early, then stop changing locations for tracked cells
    if nargin == 6 % movement end specified
        for i = movement_end+1:num_frames
            filled_locs(i,:) = filled_locs(movement_end,:);
        end
    end

    smooth_window = 20;
    temp_coord = NaN(num_frames,1);
    num_curves = size(filled_locs,2)/2;
    int_curves = NaN(total_imgs,3*num_curves);
    for j = 1:num_curves
        % intialize for each curve
        onecurve = zeros(total_imgs,3,'double');
        ar = zeros(3,3);
        ag = zeros(3,3);
        ab = zeros(3,3);
        temp_coord(:,1) = filled_locs(:,j*2-1);
        temp_coord(:,2) = filled_locs(:,j*2);
        % for each coordinate, take average of selected pixel + 8 surrounding
        % pixels, rounding occurs for pixel location
        for i = 1:length(temp_coord)
            rowtemp = round(temp_coord(i,2));
            coltemp = round(temp_coord(i,1));
            if isnan(rowtemp)
                break
            end
            frame = i;
            ar(1,1) = double(stack_red(rowtemp+1,coltemp+1,frame));
            ar(1,2) = double(stack_red(rowtemp+1,coltemp,frame));
            ar(1,3) = double(stack_red(rowtemp+1,coltemp-1,frame));
            ar(2,1) = double(stack_red(rowtemp,coltemp+1,frame));
            ar(2,2) = double(stack_red(rowtemp,coltemp,frame));
            ar(2,3) = double(stack_red(rowtemp,coltemp-1,frame));
            ar(3,1) = double(stack_red(rowtemp-1,coltemp+1,frame));
            ar(3,2) = double(stack_red(rowtemp-1,coltemp,frame));
            ar(3,3) = double(stack_red(rowtemp-1,coltemp-1,frame));
            avg_val_r = mean(mean(ar));
            onecurve(i,1) = avg_val_r;
            ag(1,1) = double(stack_green(rowtemp+1,coltemp+1,frame));
            ag(1,2) = double(stack_green(rowtemp+1,coltemp,frame));
            ag(1,3) = double(stack_green(rowtemp+1,coltemp-1,frame));
            ag(2,1) = double(stack_green(rowtemp,coltemp+1,frame));
            ag(2,2) = double(stack_green(rowtemp,coltemp,frame));
            ag(2,3) = double(stack_green(rowtemp,coltemp-1,frame));
            ag(3,1) = double(stack_green(rowtemp-1,coltemp+1,frame));
            ag(3,2) = double(stack_green(rowtemp-1,coltemp,frame));
            ag(3,3) = double(stack_green(rowtemp-1,coltemp-1,frame));
            avg_val_g = mean(mean(ag));
            onecurve(i,2) = avg_val_g;
            ab(1,1) = double(stack_blue(rowtemp+1,coltemp+1,frame));
            ab(1,2) = double(stack_blue(rowtemp+1,coltemp,frame));
            ab(1,3) = double(stack_blue(rowtemp+1,coltemp-1,frame));
            ab(2,1) = double(stack_blue(rowtemp,coltemp+1,frame));
            ab(2,2) = double(stack_blue(rowtemp,coltemp,frame));
            ab(2,3) = double(stack_blue(rowtemp,coltemp-1,frame));
            ab(3,1) = double(stack_blue(rowtemp-1,coltemp+1,frame));
            ab(3,2) = double(stack_blue(rowtemp-1,coltemp,frame));
            ab(3,3) = double(stack_blue(rowtemp-1,coltemp-1,frame));
            avg_val_b = mean(mean(ab));
            onecurve(i,3) = avg_val_b;
        end
        int_curves(:,j*3-2) = onecurve(:,1);
        int_curves(:,j*3-1) = onecurve(:,2);
        int_curves(:,j*3) = onecurve(:,3);
    end

    intensity_mat = horzcat(time,int_curves);
    save(fullfile(WritePath,strcat('pos',position,'_intensity.mat')),'intensity_mat');
    % smooth to moving average with window size smooth_window
    smooth_mat = horzcat(time,smoothdata(int_curves,'movmean',smooth_window));
    save(fullfile(WritePath,strcat('pos',position,'_smooth.mat')),'smooth_mat');
    save(fullfile(WritePath,strcat('pos',position,'_workspace.mat')));
    
    
    %% export data to csv
    DataPath = strcat(WritePath, '\csvdata');
    mkdir([ WritePath '\csvdata' ])

    for i = 1:num_long
        % format: time, x, y, Ca2+, MT, death
        tempcsv = horzcat(time(:,1), filled_long(:,i*2-1), filled_long(:,i*2),...
            int_curves(:,i*3-1), int_curves(:,i*3-2), int_curves(:,i*3));
        writematrix(tempcsv,fullfile(DataPath,strcat('pos',position,'_data',num2str(i),'.csv')));
    end

    totaldata = zeros(size(int_curves,1)*num_long,7);
    for i = 1:num_long
        tempcellnum = zeros(size(time,1),1);
        tempcellnum(1:end) = i;
        totaldata((i*num_frames-(num_frames-1)):i*num_frames,:) = horzcat(tempcellnum,time(:,1), ...
            filled_long(:,i*2-1), filled_long(:,i*2), int_curves(:,i*3-1), ...
            int_curves(:,i*3-2), int_curves(:,i*3));
    end
    writematrix(totaldata,fullfile(DataPath,strcat('pos',position,'_totaldata.csv')));

    %% save intensity plots
    for i = 1:num_curves
        figure('Position', [200 200 800 600])
        %figure('Color',[0 0 0],'InvertHardcopy','off');
        set(gcf,'Visible', 'off');
        hold on
        ax2 = gca;
        ax2.XLim = [0 max(time)];
        ax2.YLim = [0 256];
        ax2.TickLabelInterpreter = 'LaTeX';
        ax2.FontName = 'LaTeX';
        ax2.FontSize = 14;
        ax2.Title.Interpreter = 'LaTeX';
        ax2.XLabel.Interpreter = 'LaTeX';
        ax2.YLabel.Interpreter = 'LaTeX';
        ax2.XLabel.String = 'Time (min)';
        ax2.YLabel.String = 'Intensity (arbitrary units)';
    %     ax.XColor = 'white';
    %     ax.YColor = 'white';
    %     ax.Color = 'black';
        plot(time,smoothdata(int_curves(:,i*3-2),'movmean',15),'LineWidth',4,'Color','r');
        plot(time,smoothdata(int_curves(:,i*3-1),'movmean',15),'LineWidth',4,'Color','g');
        plot(time,smoothdata(int_curves(:,i*3),'movmean',15),'LineWidth',4,'Color','b');
        legend(strcat(num2str(round(track_array(1,i*2-1))),',',...
            num2str(round(track_array(1,i*2)))));
        pkfig = export_fig(fullfile(IntensityPath,strcat('pos',position,'_curves_',...
            num2str(i),'.png')),'-png','-transparent'); %export_fig is a code from Matlab Fileshare
        close(gcf);
    end
end