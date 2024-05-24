clc; clear;
%% LOAD DATA
data_path = "/home/jur0/project_iEEG/code/data/marsAtlas.csv";

T = readtable(data_path);
T.LeftIndex