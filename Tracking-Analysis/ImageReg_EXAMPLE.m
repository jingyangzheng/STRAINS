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

clearvars
folder = 'D:\Jingyang\Cartilage\Confocal_Images\';
date = '22_04_29';
mkdir(strcat(folder, date, '\pos1_reg\'));
num_frames = 840;

LongPath = strcat(folder, date, '\pos1\long'); % this is where the images for the 'long' tracking are stored
WritePath = strcat(folder, date, '\pos1_reg\images\'); % this is where the registered images should be saved
mkdir(WritePath);

% load image
% Obtain info from image
info = imfinfo(fullfile(folder,date,'\pos1.tif')); % gives info about tiff stack
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
    temp_tiff = imread(fullfile(folder,date,'\pos1.tif'), k);
    stack_red(:,:,k) = temp_tiff(:,:,1);
    stack_green(:,:,k) = temp_tiff(:,:,2);
    stack_blue(:,:,k) = temp_tiff(:,:,3);
    stack1(:,:,k) = temp_tiff(:,:,1)+temp_tiff(:,:,2)+temp_tiff(:,:,3);
end

load(strcat(folder,date,'\pos1\pos1_locs.mat'));
fixedpts = NaN(size(filled_long,2)/2,2);
movingpts = NaN(size(filled_long,2)/2,2);

for i = 1:(size(filled_long,2)/2)
    fixedpts(i,1) = filled_long(1,i*2-1);
    fixedpts(i,2) = filled_long(1,i*2);
end

% initialize registered arrays
blue_reg = zeros(512,512,num_frames,'uint8');
red_reg = zeros(512,512,num_frames,'uint8');
green_reg = zeros(512,512,num_frames,'uint8');
total_reg = zeros(512,512,3,num_frames,'uint8');

% % read first image in long tracking
I = imread(fullfile(LongPath,strcat('pos1_filled1.tif')));
% % write images
% imwrite(I,fullfile(WritePath,strcat(video_type,'_tform.tif')));
imwrite(stack_blue(:,:,1),fullfile(WritePath,'pos1_tform_blue.tif'));
imwrite(stack_green(:,:,1),fullfile(WritePath,'pos1_tform_green.tif'));
imwrite(stack_red(:,:,1),fullfile(WritePath,'pos1_tform_red.tif'));

% apply imwarp and save as an array instead of writing it
for j = 1:num_frames
    warning('off','all')
    J = imread(fullfile(LongPath,strcat('pos1_filled',num2str(j),'.tif')));
    for i = 1:(size(filled_long,2)/2)
        movingpts(i,1) = filled_long(j,i*2-1);
        movingpts(i,2) = filled_long(j,i*2);
    end
    tform = fitgeotrans(movingpts,fixedpts,'lwm',15);
    blue_reg(:,:,j) = imwarp(stack_blue(:,:,j),tform,'OutputView',imref2d(size(I)));
    imwrite(blue_reg(:,:,j),fullfile(WritePath,'pos1_tform_blue.tif'),'Writemode','append');
    green_reg(:,:,j) = imwarp(stack_green(:,:,j),tform,'OutputView',imref2d(size(I)));
    imwrite(green_reg(:,:,j),fullfile(WritePath,'pos1_tform_green.tif'),'Writemode','append');
    red_reg(:,:,j) = imwarp(stack_red(:,:,j),tform,'OutputView',imref2d(size(I)));
    imwrite(red_reg(:,:,j),fullfile(WritePath,'pos1_tform_red.tif'),'Writemode','append');
    total_reg(:,:,1,j) = red_reg(:,:,j);
    total_reg(:,:,2,j) = green_reg(:,:,j);
    total_reg(:,:,3,j) = blue_reg(:,:,j);
    imwrite(red_reg(:,:,j),fullfile(WritePath,'pos1_tform_total.tif'),'Writemode','append');
end

% save matrices
save(fullfile(WritePath,'pos1_blue_reg.mat'),'blue_reg');
save(fullfile(WritePath,'pos1_green_reg.mat'),'green_reg');
save(fullfile(WritePath,'pos1_red_reg.mat'),'red_reg');