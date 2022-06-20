% save labels for each position by order of CellID

function PositionLabels(folder, date, positions, categories)
    load(strcat(folder, date, '\total_sorting_manual.mat'));
    for j = 1:length(positions)
        templabels = cell(1500,2);
        for k = 1:length(categories)
            pos_cat = total_sorting_bgsub.(categories{k})(cellfun(@(x) x == positions(j), {total_sorting_bgsub.(categories{k}).Position}));
            if ~isempty(pos_cat) 
                pos_cat_cellnum = extractfield(pos_cat, 'CellNum')';
                templabels(pos_cat_cellnum, 1) = categories(k);
                templabels(pos_cat_cellnum, 2) = {k};
            end
        end
        pos_labels = templabels(~cellfun('isempty', templabels));
        % save individual position labels
        save_labels = pos_labels(1:size(pos_labels,1)/2);
        save(strcat(folder, date, '\pos', num2str(j), '\pos', num2str(j), '_labels.mat'), 'save_labels');
    end
end