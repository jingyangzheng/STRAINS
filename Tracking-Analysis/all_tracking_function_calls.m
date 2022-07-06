% run tracking codes for all files 

% Written by Jingyang Zheng jz848@cornell.edu

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
%% 
clearvars
folder = 'D:\Jingyang\Cartilage\Confocal_Images\';
date = '19_09_26_test';
positions = ['1', '2', '3', '4', '5'];

%% time calculation
% use input from slidebook files

num_impact = 1000; % number of impact frames
impact_spf = 0.084; % impact seconds per frame
impact_mpf = impact_spf/60; % impact minutes per frame
num_post = 750; % number of postimpact frames
postimpact_spf = 22; % postimpact seconds per frame
postimpact_mpf = postimpact_spf/60; % postimpact minutes per frame
timegap = 0.2; % estimated gap between impact and post-impact videos (in min)

time = vertcat(linspace(0,impact_mpf*num_impact,num_impact)',...
    linspace(impact_mpf*num_impact+timegap,impact_mpf*num_impact+timegap+...
    postimpact_mpf*num_post,num_post)');
save(strcat(folder,date,'\time.mat'),'time');

%% impact tracking and intensity

impact_params = struct;
% Fill in parameters needed for tracking functions create a structure in which to save parameters
% This is for the Crocker % Grier code   
% for bpass
%   lnoise: Characteristic lengthscale of noise in pixels. Additive noise averaged 
%           over this length should vanish. May assume any positive floating value. 
%   lobject: Integer length in pixels somewhat larger than a typical object
%   threshold: By default, after the convolution,any negative pixels are reset to 0.  
%               Threshold changes the threshhold for setting pixels to 0.  Positive values may be 
%               useful for removing stray noise or small particles.
impact_params.bpass.lnoise = 1;
impact_params.bpass.lobject = 8; % optional 7
impact_params.bpass.threshold = 5; % optional, changed from 5

% for pkfnd
%   th: the minimum brightness of a pixel that might be local maxima. 
%       (NOTE: Make it big and the code runs faster
%       but you might miss some particles.  Make it small and you'll get
%       everything and it'll be slow.)
%   sz:  if your data's noisy, (e.g. a single particle has multiple local
%       maxima), then set this optional keyword to a value slightly larger than the diameter of your blob.  if
%       multiple peaks are found withing a radius of sz/2 then the code will keep
%       only the brightest.  Also gets rid of all peaks within sz of boundary
impact_params.pkfnd.th = 10; % formerly 10
impact_params.pkfnd.sz = 8; % optional, formerly 8

% for cntrd
%   sz: diamter of the window over which to average to calculate the centroid.  
%       should be big enough to capture the whole particle but not so big that it captures others.  
%       if initial guess of center (from pkfnd) is far from the centroid, the
%       window will need to be larger than the particle size.  RECOMMENDED
%       size is the long lengthscale used in bpass plus 2.
%       (sz+1)/2 MUST BE AN INTEGER
%       POSSIBLE VALUES ARE: 5,7,9,11
impact_params.cntrd.win = 7; 

% for track
%   param.mem: this is the number of time steps that a particle can be
%           'lost' and then recovered again.  If the particle reappears
%           after this number of frames has elapsed, it will be
%           tracked as a new particle. The default setting is zero.
%           this is useful if particles occasionally 'drop out' of the data.
impact_params.track.param = struct('mem',6,'dim',2,'good',0,'quiet',0);
impact_params.track.maxdisp = 5; % 7 is generally the max, changing it means the code won't run

impact_params.length_filter = 700; %minimum number of tracked frames to keep cell
TrackImpact(folder, date, impact_params, 'on');

%% post-impact tracking and intensity

% for bpass
%   lnoise: Characteristic lengthscale of noise in pixels. Additive noise averaged 
%           over this length should vanish. May assume any positive floating value. 
%   lobject: Integer length in pixels somewhat larger than a typical object
%   threshold: By default, after the convolution,any negative pixels are reset to 0.  
%               Threshold changes the threshhold for setting pixels to 0.  Positive values may be 
%               useful for removing stray noise or small particles.
postimpact_params.bpass.lnoise = 1;
postimpact_params.bpass.lobject = 8; % optional 7
postimpact_params.bpass.threshold = 5; % optional

% for pkfnd
%   th: the minimum brightness of a pixel that might be local maxima. 
%       (NOTE: Make it big and the code runs faster
%       but you might miss some particles.  Make it small and you'll get
%       everything and it'll be slow.)
%   sz:  if your data's noisy, (e.g. a single particle has multiple local
%       maxima), then set this optional keyword to a value slightly larger than the diameter of your blob.  if
%       multiple peaks are found withing a radius of sz/2 then the code will keep
%       only the brightest.  Also gets rid of all peaks within sz of boundary
postimpact_params.pkfnd.th = 10; % formerly 10
postimpact_params.pkfnd.sz = 7; % optional, formerly 8

% for cntrd
%   sz: diamter of the window over which to average to calculate the centroid.  
%       should be big enough to capture the whole particle but not so big that it captures others.  
%       if initial guess of center (from pkfnd) is far from the centroid, the
%       window will need to be larger than the particle size.  RECOMMENDED
%       size is the long lengthscale used in bpass plus 2.
%       (sz+1)/2 MUST BE AN INTEGER
%       POSSIBLE VALUES ARE: 5,7,9,11
postimpact_params.cntrd.win = 7; % formerly 7 

% for track
%   param.mem: this is the number of time steps that a particle can be
%           'lost' and then recovered again.  If the particle reappears
%           after this number of frames has elapsed, it will be
%           tracked as a new particle. The default setting is zero.
%           this is useful if particles occasionally 'drop out' of the data.
postimpact_params.track.param = struct('mem',6,'dim',2,'good',0,'quiet',0); % mem formerly 6
postimpact_params.track.maxdisp = 5; % 7 is generally the max, changing it means the code won't run

postimpact_params.length_filter = 250; %minimum number of tracked frames to keep cell

for i = 1:length(positions)
    TrackPostImpact(folder, date, positions(i), postimpact_params, 'on', 100);
    % last parameter here optional, sets where you think the cells stop moving within the image
end

%% feature extraction

fe_params = struct;
% fill in feature extraction parameters
% green channel (calcium) peak detection
fe_params.g_minpeakprom = 3; % minimum peak prominence
fe_params.g_wpratio = 7; % width to prominence ratio
fe_params.g_early_peak_height_filter = 100; % height filter for very early peaks to remove
% green channel (calcium) changepoint detection
fe_params.g_threshold = 500; % threshold value for findchangepts
fe_params.g_slopedif = 0.09; % difference in slope to remove changepoint (not necessarily used)
                             % this can be lowered when the background subtraction is good
% blue channel (nuclear membrane permeability) peak detection
fe_params.b_minpeakprom = 8;
fe_params.b_wpratio = 30;
% blue channel (nuclear membrane permeability) changepoint detection
fe_params.b_threshold = 200;
fe_params.b_slopedif = 0.09;

for i = 1:length(positions)
    FeatureExtraction(folder, date, positions(i), fe_params, 'on')
end

save(strcat(folder,date,'\feature_extraction_params.mat'),'fe_params');


% for manually sorted data go to: sorting_function_calls_manual
% for unsorted data go to: sorting_function_calls_nomanual


