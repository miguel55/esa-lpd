%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Title: Efficient Scale Adaptive License Plate Detection System
% Journal: IEEE Transactions on Intelligent Transportation Systems
% Author: Molina-Moreno, Miguel and González-Díaz Iván and Díaz-de-María, Fernando
% Multimedia Processing Group, Universidad Carlos III, 28911 Leganés
% email: mmolina @tsc.uc3m.es
% doi: 10.1109/TITS.2018.2859035
% August 2018; Last revision: 28-01-2019
% Code based on the Torralba et al. trainDetector.m script available at:
% http://people.csail.mit.edu/torralba/shortCourseRLOC/boosting/boosting.html
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function []=trainDetector

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Train the detector by means of the GentleBoost algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run('initPath');
run('parameters');

% Load precomputed features for training and test
load (['../../data/trainDB',BBDD])

% Total number of samples (objects and background)
Nsamples = length(data.class);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Obtain training samples (every one)
trainingImages = unique(data.image);
trainingSamples = find(ismember(data.image, trainingImages));

% % Plot number of background and object training samples
% figure
% hist(data.class(trainingSamples), [-1 1]);
% title('Number of background and object training samples')
% drawnow

featuresTrain = data.features(trainingSamples, :)';
classesTrain  = data.class(trainingSamples)';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TRAINING THE DETECTOR:

NweakClassifiers = 200; 
classifier = gentleBoost(featuresTrain, classesTrain, NweakClassifiers);

data.detector = classifier;
data.trainingSamples = trainingSamples;
data.trainingImages = trainingImages;

save (['../../data/detectors/proposedSAEC-',BBDD], 'data')
