
% figure defaults

function SetFigureDefaults(frames)
    
    set(groot, 'DefaultTextFontName', 'LaTeX');
    set(groot, 'defaultUicontrolFontName', 'LaTeX');
    set(groot, 'defaultUitableFontName', 'LaTeX');
    set(groot, 'defaultUipanelFontName', 'LaTeX');
    set(groot, 'DefaultAxesFontName', 'LaTeX');
    set(0, 'DefaultAxesTickLabelInterpreter', 'LaTex');
    set(0, 'DefaultAxesFontSize', 12);
    set(0, 'DefaultAxesFontWeight', 'bold');
    set(groot, 'DefaultAxesXLimMode', 'manual');
    set(groot, 'DefaultAxesXLim', [0 frames]);
    set(groot, 'DefaultAxesYLimMode', 'manual');
    set(groot, 'DefaultAxesYLim', [0 256]);

end


% https://www.mathworks.com/help/matlab/ref/matlab.graphics.axis.axes-properties.html
% to remove any of these:
% set(groot,'defaultSurfaceEdgeColor','remove')

% in regards to default labels matlab says:
% These text objects are not contained in the axes Children property, cannot be returned by findobj, and do not use default values defined for text objects.