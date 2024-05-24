function MNI = getChannelsMNI(CHANNELS)
%GETCHANNELSMNI extracts MNI coordinates from subject CHANNELS
%   return MNI matrix has size Nx3, where N is number of channels and each
%   row is an array of coordinates [x,y,z] 

    MNI = zeros(length(CHANNELS), 3);
    for ch=1:length(CHANNELS)
        MNI(ch, :) = [CHANNELS(ch).MNI_x, CHANNELS(ch).MNI_y, CHANNELS(ch).MNI_z];
    end
end

