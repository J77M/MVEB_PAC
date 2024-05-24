function [MNI_V, labels]= volume2MNI(Volume, transform)
    V_size = size(Volume);
    [X, Y, Z] = ndgrid(1:V_size(1), 1:V_size(2), 1:V_size(3));
    coordinates_indices = [X(:), Y(:), Z(:)];
    % get atlas labels for each coordinate
    labels = zeros(1, length(coordinates_indices));
    for c=1:length(coordinates_indices)
        coord = coordinates_indices(c, :);
        labels(c) = Volume(coord(1), coord(2), coord(3));
    end
    % remove zeros (no label)
    coordinates_indices = coordinates_indices(labels ~= 0, :);
    labels = labels(labels ~= 0).';
    
%     transform (only offset)
%     MNI_V = coordinates_indices - ones(size(coordinates_indices)) + transform(:, 4).';

%       % offset
      coordinates_indices = coordinates_indices - ones(size(coordinates_indices));
      MNI_V = transform(:, 1:3)*coordinates_indices.' + transform(:, 4);
      MNI_V = MNI_V.';
end