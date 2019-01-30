%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Title: Efficient Scale Adaptive License Plate Detection System
% Journal: IEEE Transactions on Intelligent Transportation Systems
% Author: Molina-Moreno, Miguel and González-Díaz Iván and Díaz-de-María, Fernando
% Multimedia Processing Group, Universidad Carlos III, 28911 Leganés
% email: mmolina@tsc.uc3m.es
% doi: 10.1109/TITS.2018.2859035
% August 2018; Last revision: 28-01-2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function []=main

%% 0. Create training and test databases from JPG images 
createDatabase;

%% 1. Create dictionary of visual words from dictionary images (whose name includes the 'dict' string)
createDictionary;

%% 2. Obtain the standard deviation value of the location of each feature
computeSigmaScale;

%% 3. Compute feature values over training images
computeFeatures;

%% 4. Train the detector
trainDetector;

%% 5. Run the detector
runDetector;