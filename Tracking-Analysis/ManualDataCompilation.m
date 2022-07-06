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


% takes in manually sorted data and organizes it with the assigned labels

function ManualDataCompilation(folder, date, positions, categories)


    c = cell(length(categories),1);
    total_sorting_manual = cell2struct(c,categories);
    df0 = {};
    df1 = {};
    y = {};
    
    %% load all data
    for j = positions
        SamplePath = strcat(folder, date, '\pos',num2str(j),'\intensity_sort\');
        % load position data
        load(strcat(folder, date, '\pos',num2str(j),'\pos', num2str(j), '_locs.mat'));
        locs = [];
        locs(:,1) = filled_long(1,1:2:end);
        locs(:,2) = filled_long(1,2:2:end);
        % load timeseries data
        load(strcat(folder, date, '\pos',...
            num2str(j),'\pos', num2str(j), '_intensity.mat'));
        intensity_mat(:,1) = []; % remove time column
        red_all = smoothdata(intensity_mat(:,1:3:end),'movmean',20);
        green_all = smoothdata(intensity_mat(:,2:3:end),'movmean',20);
        blue_all = smoothdata(intensity_mat(:,3:3:end),'movmean',20);

        for i = 1:length(categories)
            tempdir = dir(strcat(SamplePath, '\', categories{1,i}));
            % remove directories from filenames
            tempfilenames = {tempdir.name}';
            for k = 1:length(tempfilenames)
                if strcmp(tempfilenames{k,1},'.') == 1 || strcmp(tempfilenames{k,1},'..')
                    tempfilenames{k,1} = [];
                end
            end
            tempfilenames = tempfilenames(~cellfun(@isempty,tempfilenames));

            % split file names to scrape cell number
            % this temporary structure has all the data for one category at one
            % position
            tempcellnum = struct;
            temptimeseries = cell(length(tempfilenames),3);
            templabels = cell(length(tempfilenames),1);
            tempconcat = cell(length(tempfilenames),1);
            for m = 1:length(tempfilenames)
                namesplit = strsplit(tempfilenames{m,1},{'pos','_','.png'});
                tempcellnum(m).Position = j;
                tempcellnum(m).CellNum = str2double(namesplit{1,4});
                tempcellnum(m).x = locs(tempcellnum(m).CellNum,1);
                tempcellnum(m).y = locs(tempcellnum(m).CellNum,2);
                temptimeseries{m,1} = red_all(:,tempcellnum(m).CellNum);
                temptimeseries{m,2} = green_all(:,tempcellnum(m).CellNum);
                temptimeseries{m,3} = blue_all(:,tempcellnum(m).CellNum);
                tempconcat{m,1} = vertcat(red_all(:,tempcellnum(m).CellNum), ...
                    green_all(:,tempcellnum(m).CellNum), blue_all(:,tempcellnum(m).CellNum));
                templabels{m,1} = categories{1,i};
            end

            % add to total_sorting if not empty?
            if ~isempty(tempfilenames)
                total_sorting_manual.(categories{1,i}) = [total_sorting_manual.(categories{1,i}), tempcellnum];
                df0 = vertcat(df0, temptimeseries);
                df1 = vertcat(df1, tempconcat);
                y = vertcat(y, templabels);
            end
        end
    end

    %%
    save(strcat(folder, date, '\total_sorting_manual.mat'), 'total_sorting_manual');
    save(strcat(folder, date, '\alltimeseries.mat'), 'df0');
    save(strcat(folder, date, '\allconcat.mat'), 'df1');
    save(strcat(folder, date, '\alllabels.mat'), 'y');
end
