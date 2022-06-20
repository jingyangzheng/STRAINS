%% decision tree code
% decision tree parameters can be individually tuned here

function DecisionTree(folder, date, position, categories)
    % load cell attributes
    load(strcat(folder,date,'\pos', position,'\feature_extraction\cell_attributes.mat'));

    %% check each cell individually
    for i = 1:length(cell_attributes)
        if cell_attributes(i).blue_max_frame < 7 && cell_attributes(i).blue_max > 20
            cell_attributes(i).category = 'blue_starts_high';
        elseif ~isempty(cell_attributes(i).blue_cp) % does have blue changepoint
            if length(cell_attributes(i).blue_cp) > 3 % may need to remove this part
                cell_attributes(i).category = 'blue_multiple steps'; % change this to check if they're far apart?
    %         if cell_attributes(i).blue_range < 20 && cell_attributes(i).blue_mean > 20
    %             cell_attributes(i).category = 'blue_starts_high';
            elseif cell_attributes(i).red_blue_meandiff > 20 % red is high 
                cell_attributes(i).category = 'red_high_blue_changes';
                % if at the changepoint, red is higher than blue
                % if the average of red is higher than the average of blue
            elseif ~isempty(cell_attributes(i).green_peaks) % does have green peak
                if cell_attributes(i).blue_cp(1) + 20 < cell_attributes(i).green_peaks(1) 
                    % if blue is already high (some buffer area if they rise at the same time)
                    cell_attributes(i).category = 'blue_high_green_signal';
                    % should be something like if green increases any time after blue increases
                    % include green cp
                else % if blue rises after
                    cell_attributes(i).category = 'green_signal_then_blue';
                end

            % 120 and 100
            elseif cell_attributes(i).blue_max_frame > 120 && cell_attributes(i).blue_cp(1) > 100
                if ~isempty(cell_attributes(i).green_cp)
                    cell_attributes(i).category = 'green_drop_then_blue';
                else
                    cell_attributes(i).category = 'blue_rises_late';
                end
    %         elseif cell_attributes(i).blue_range_after_max > 8 
    %             cell_attributes(i).category = 'blue_rise_fall';
            elseif ~isempty(cell_attributes(i).blue_peaks) % has blue peaks
                cell_attributes(i).category = 'blue_rises_and_falls';
            elseif cell_attributes(i).blue_range_after_max <= 8
                cell_attributes(i).category = 'blue_rises'; % this counts some of blue starts high

            else
                cell_attributes(i).category = 'blue_starts_high'; %'uncategorized_blue';


    %         elseif cell_attributes(i).blue_max_frame < 2 && cell_attributes(i).blue_max > 20 % test this
    %             cell_attributes(i).category = 'blue_starts_high';
            end
        else % doesn't have blue changepoint
            if ~isempty(cell_attributes(i).green_peaks) % does have green peak
                cell_attributes(i).category = 'green_signal';
                % include green cp near the end
            elseif cell_attributes(i).blue_range > 10
                cell_attributes(i).category = 'blue_rises';
            else % doesn't have green peak
                if cell_attributes(i).red_mean_end < 6 %&& something about green being low too
                    cell_attributes(i).category = 'everything_low';
                else % low red
                    cell_attributes(i).category = 'normal';
                end  
            end
        end

    end

    % re-save cell attributes with new decision tree results
    save(strcat(folder,date,'\pos', position,...
        '\feature_extraction\cell_attributes.mat'), 'cell_attributes');

    
    %% accuracy tests

    % total accuracy
    num_accurate = 0;
    for i = 1:length(cell_attributes)
        if strcmp(cell_attributes(i).true_label,cell_attributes(i).category) == 1
            num_accurate = num_accurate + 1;
        end
    end

    category_accuracy = cell(size(categories, 2)+1,4);
    for i = 1:length(categories)
        category_accuracy(i,1) = {categories(i)};
        % get substructure of each actual category
        tempcat = cell_attributes(cellfun(@(x) strcmp(categories(i),x), {cell_attributes.true_label}));
        cat_accurate = 0;
        for j = 1:length(tempcat)
            if strcmp(tempcat(j).true_label,tempcat(j).category) == 1
                cat_accurate = cat_accurate + 1;
            end
        end
        category_accuracy(i,2) = {cat_accurate/length(tempcat)};
        category_accuracy(i,3) = {cat_accurate};
        category_accuracy(i,4) = {length(tempcat)};
    end
    
    category_accuracy(end,1) = {'total'};
    category_accuracy(end,2) = {num_accurate/size(cell_attributes,2)};
    category_accuracy(end,3) = {num_accurate};
    category_accuracy(end,4) = {size(cell_attributes,2)};
    
    save(strcat(folder,date,'\pos', position,...
        '\feature_extraction\category_accuracy.mat'), 'category_accuracy');

    %% get individual structures
    % if you want specific structures, then use this type of code to find them

%     blue_high_green_signal = cell_attributes(cellfun(@(x) strcmp('blue_high_green_signal',x), {cell_attributes.category}));
%     blue_multiple_steps = cell_attributes(cellfun(@(x) strcmp('blue_multiple_steps',x), {cell_attributes.category}));
%     blue_rises = cell_attributes(cellfun(@(x) strcmp('blue_rises',x), {cell_attributes.category}));
%     blue_rises_and_falls = cell_attributes(cellfun(@(x) strcmp('blue_rises_and_falls',x), {cell_attributes.category}));
%     blue_rises_late = cell_attributes(cellfun(@(x) strcmp('blue_rises_late',x), {cell_attributes.category}));
%     blue_starts_high = cell_attributes(cellfun(@(x) strcmp('blue_starts_high',x), {cell_attributes.category}));
%     everything_low = cell_attributes(cellfun(@(x) strcmp('everything_low',x), {cell_attributes.category}));
%     green_drop_then_blue = cell_attributes(cellfun(@(x) strcmp('green_drop_then_blue',x), {cell_attributes.category}));
%     green_signal = cell_attributes(cellfun(@(x) strcmp('green_signal',x), {cell_attributes.category}));
%     green_signal_then_blue = cell_attributes(cellfun(@(x) strcmp('green_signal_then_blue',x), {cell_attributes.category}));
%     normal = cell_attributes(cellfun(@(x) strcmp('normal',x), {cell_attributes.category}));
%     red_high_blue_changes = cell_attributes(cellfun(@(x) strcmp('red_high_blue_changes',x), {cell_attributes.category}));

%    % save all of them to folder
%     mkdir([strcat(folder,date,'\pos', position,'\feature_extraction\') 'category_structs\']);
%     structsavepath = strcat(folder,date,'\pos', position,'\feature_extraction\category_structs\');
% 
%     % lists all structures in the workspace
%     S = whos;
%     S = S(strcmp({S.class}, 'struct'));
%     % save all structures
%     for i = 1:length(S)
%         thisfield = S(i).name;
%         outfile = fullfile(structsavepath, [thisfield, '.mat']);
%         save(outfile, thisfield);
%     end
%     clear S %otherwise when you run it again it saves S since it's a struct

end