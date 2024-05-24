function colors = loadMarsAtlasColorMap(path)
%LOADMARSATLASCOLORMAP Summary of this function goes here
    T = readtable(path, 'Filetype', 'text', 'Delimiter',{'(', ',', ')'});
    % remove first col
    T = T(:, 2:end);
    colors = T{2:end, :};
end

