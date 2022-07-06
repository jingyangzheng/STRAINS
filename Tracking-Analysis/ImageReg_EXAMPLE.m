%% example code snippet for image registration
% Run for all frames and write to tif
% need movingpoints to only include ones that are tracked the whole time
% this is not used in analysis, placed here for reference
% used to generate connections between impact and pos1 data
% in the GUI analysis files, pos1_reg is an example of this


% dependencies:
% requires Crocker & Grier particle tracking code found here: https://site.physics.georgetown.edu/matlab/
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



LongPath = ''; % this is where the images for the 'long' tracking are stored
WritePath = ''; % this is where the registered images should be saved

fixedpts = NaN(size(track_array,2)/2,2);
movingpts = NaN(size(track_array,2)/2,2);

for i = 1:(size(track_array,2)/2)
    fixedpts(i,1) = track_array(1,i*2-1);
    fixedpts(i,2) = track_array(1,i*2);
end

% initialize registered arrays
blue_reg = zeros(512,512,num_frames,'uint8');
red_reg = zeros(512,512,num_frames,'uint8');
green_reg = zeros(512,512,num_frames,'uint8');

% % read first image in long tracking
I = imread(fullfile(LongPath,strcat(video_type,'_filled1.tif')));
% % write images
% imwrite(I,fullfile(WritePath,strcat(video_type,'_tform.tif')));
imwrite(stack_blue(:,:,1),fullfile(WritePath,strcat(video_type,'_tform_clean_blue.tif')));
imwrite(stack_red(:,:,1),fullfile(WritePath,strcat(video_type,'_tform_clean_red.tif')));
imwrite(stack_green(:,:,1),fullfile(WritePath,strcat(video_type,'_tform_clean_green.tif')));

% apply imwarp and save as an array instead of writing it
for j = 1:num_frames
    warning('off','all')
    J = imread(fullfile(LongPath,strcat(video_type,'_filled',num2str(j),'.tif')));
    for i = 1:(size(track_array,2)/2)
        movingpts(i,1) = track_array(j,i*2-1);
        movingpts(i,2) = track_array(j,i*2);
    end
    tform = fitgeotrans(movingpts,fixedpts,'lwm',15);
    blue_reg(:,:,j) = imwarp(stack_blue(:,:,j),tform,'OutputView',imref2d(size(I)));
    imwrite(blue_reg(:,:,j),fullfile(WritePath,strcat(video_type,'_tform_clean_blue.tif')),'Writemode','append');
    green_reg(:,:,j) = imwarp(stack_green(:,:,j),tform,'OutputView',imref2d(size(I)));
    imwrite(green_reg(:,:,j),fullfile(WritePath,strcat(video_type,'_tform_clean_green.tif')),'Writemode','append');
    red_reg(:,:,j) = imwarp(stack_red(:,:,j),tform,'OutputView',imref2d(size(I)));
    imwrite(red_reg(:,:,j),fullfile(WritePath,strcat(video_type,'_tform_clean_red.tif')),'Writemode','append');
end

% save matrices
save(fullfile(WritePath,strcat(video_type,'_blue_reg.mat')),'blue_reg');
save(fullfile(WritePath,strcat(video_type,'_green_reg.mat')),'green_reg');
save(fullfile(WritePath,strcat(video_type,'_red_reg.mat')),'red_reg');