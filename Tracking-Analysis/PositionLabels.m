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