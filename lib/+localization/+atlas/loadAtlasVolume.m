function [Volume,transform] = loadAtlasVolume(marsAtlasPath)
%LOADATLASVOLUME Summary of this function goes here
%   Detailed explanation goes here

    % load atlas .nii
    % using Image Processing and Computer Vision
    info = niftiinfo(marsAtlasPath);
    Volume = niftiread(marsAtlasPath);
    % https://nifti.nimh.nih.gov/nifti-1/documentation/nifti1fields/nifti1fields_pages/qsform.html/document_view
    % https://meca-brain.org/software/marsatlas-colin27/
    
    srow_x = info.raw.srow_x;
    srow_y = info.raw.srow_y;
    srow_z = info.raw.srow_z;
    transform = [srow_x; srow_y;srow_z];
end

