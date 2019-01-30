%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Title: Efficient Scale Adaptive License Plate Detection System
% Journal: IEEE Transactions on Intelligent Transportation Systems
% Author: Molina-Moreno, Miguel and González-Díaz Iván and Díaz-de-María, Fernando
% Multimedia Processing Group, Universidad Carlos III, 28911 Leganés
% email: mmolina@tsc.uc3m.es
% doi: 10.1109/TITS.2018.2859035
% August 2018; Last revision: 28-01-2019
% Code based on the Torralba et al. parameters.m script available at:
% http://people.csail.mit.edu/torralba/shortCourseRLOC/boosting/boosting.html
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Parameters

% Database folders
% Define the root folder for the images and annotations for train and test:
BBDD='AOLP'; % AOLP, Stills&Caltech, or your database
HOMEIMAGES = 'PATH_TO_BBDD_TRAIN_IMAGES';
HOMEANNOTATIONS = 'PATH_TO_BBDD_TRAIN_ANNOTATIONS'; 
HOMEIMAGESTEST = 'PATH_TO_BBDD_TEST_IMAGES';
HOMEANNOTATIONSTEST = 'PATH_TO_BBDD_TEST_ANNOTATIONS'; 

% Target class
objects='lp';

% Detector
detector='proposedSAEC';


% Filters: normalized Sobel filters definition
sob3x3 =1/8*[ 1 2 1 ]' * [1 0 -1];
sob5x5 = 1/16*conv2( [ 1 2 1 ]' * [1 2 1], sob3x3 );
sob7x7 = 1/16*conv2( [ 1 2 1 ]' * [1 2 1], sob5x5 );
sob9x9 = 1/16*conv2( [ 1 2 1 ]' * [1 2 1], sob7x7 );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dictionary 
% From each dictionary sample we extract 10 patches taking into account its
% scale and filter them with 13 filters.
% The scale space definition is:
% Scale    Height limits (pixels)     Width limits (pixels)
%   1              <25                        <80
%   2             [25,35)                    [80,100)
%   3             [35,45)                    [100,120)
%   4               >45                       >120
% Store indices of images used for building the dictionary
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set of filters
filters = {[1], ...                         % original image
    sob3x3', ...                            % y derivative 3x3
    sob3x3, ...                             % x derivative 3x3 
    1/9*[-1 -1 -1; -1 8 -1; -1 -1 -1], ...; % Laplacian 3x3
    sob5x5',...                             % y derivative 5x5
    sob5x5,...                              % x derivative 5x5
    1/25*[-1 -1 -1 -1 -1; -1 -1 -1 -1 -1; -1 -1 24 -1 -1; -1 -1 -1 -1 -1; -1 -1 -1 -1 -1],... % Laplacian 5x5
    sob7x7',...                             % y derivative 7x7
    sob7x7,...                              % x derivative 7x7
    1/49*[-1 -1 -1 -1 -1 -1 -1; -1 -1 -1 -1 -1 -1 -1; -1 -1 -1 -1 -1 -1 -1; -1 -1 -1 48 -1 -1 -1; -1 -1 -1 -1 -1 -1 -1; -1 -1 -1 -1 -1 -1 -1; -1 -1 -1 -1 -1 -1 -1],... % Laplacian 7x7
    sob9x9',...                             % y derivative 9x9
    sob9x9,...                              % x derivative 9x9
    1/81*[-1 -1 -1 -1 -1 -1 -1 -1 -1; -1 -1 -1 -1 -1 -1 -1 -1 -1; -1 -1 -1 -1 -1 -1 -1 -1 -1; -1 -1 -1 -1 -1 -1 -1 -1 -1; -1 -1 -1 -1 80 -1 -1 -1 -1; -1 -1 -1 -1 -1 -1 -1 -1 -1; -1 -1 -1 -1 -1 -1 -1 -1 -1; -1 -1 -1 -1 -1 -1 -1 -1 -1; -1 -1 -1 -1 -1 -1 -1 -1 -1]}; % Laplacian 9x9

% Number of images used to build the dictionary of patches. The images 
% selected will not be used for training or test
sampleFromImages = 24; 
% Number of patches to be extracted from every image (if the results are
% not similar between executions, increase this value, although it
% increases the computational complexity at training stage)
patchesFromExample = 10;

% Scale-space definition
scales_X=[0,80,100,120,158]; % 158 is the maximum size
scales_Y=[0,25,35,45,55];
patchSizes=[9,13,17,21];
min_detectable_object_size=[11 33];

if (strcmp(BBDD,'Stills&Caltech'))
    Nscales=3;  % Depending on the database
else
    Nscales=4;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Training
trainingImageSize = [600 600];   % To avoid excessive computation
negativeSamplesPerImage = 30;    % number of background samples extracted from each image

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute some common variables:
Nfilters = length(filters);
Npatches = patchesFromExample * Nfilters;