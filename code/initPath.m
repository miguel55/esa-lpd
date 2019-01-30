%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Title: Efficient Scale Adaptive License Plate Detection System
% Journal: IEEE Transactions on Intelligent Transportation Systems
% Author: Molina-Moreno, Miguel and González-Díaz Iván and Díaz-de-María, Fernando
% Multimedia Processing Group, Universidad Carlos III, 28911 Leganés
% email: mmolina@tsc.uc3m.es
% doi: 10.1109/TITS.2018.2859035
% August 2018; Last revision: 28-01-2019
% Code based on the Torralba et al. initPath.m script available at:
% http://people.csail.mit.edu/torralba/shortCourseRLOC/boosting/boosting.html
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Add paths to Matlab

% Common functions
addpath('PATH_TO_code/tools');

% boosting
addpath('PATH_TO_code/gentleBoost');

% PASCAL VOC software
addpath('PATH_TO_PASCAL_VOC_ANNOTATION_TOOL');

% Path for LabelMeToolbox
path_LabelMeToolbox='PATH_TO_LABELME_TOOLBOX';
addpath(path_LabelMeToolbox)
%Path for LabelMe functions
addpath([path_LabelMeToolbox '/querytools']);
addpath([path_LabelMeToolbox '/imagemanipulation']);
addpath([path_LabelMeToolbox '/utils']);
addpath([path_LabelMeToolbox '/main']);
addpath([path_LabelMeToolbox '/objectdetection']);

% Path to vl_feat
run('PATH_TO_VLFEAT/toolbox/vl_setup');
