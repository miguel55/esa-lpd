%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Title: Efficient Scale Adaptive License Plate Detection System
% Journal: IEEE Transactions on Intelligent Transportation Systems
% Author: Molina-Moreno, Miguel and González-Díaz Iván and Díaz-de-María, Fernando
% Multimedia Processing Group, Universidad Carlos III, 28911 Leganés
% email: mmolina@tsc.uc3m.es
% doi: 10.1109/TITS.2018.2859035
% August 2018; Last revision: 28-01-2019
% Code based on the Torralba et al. computeFeatures.m script available at:
% http://people.csail.mit.edu/torralba/shortCourseRLOC/boosting/boosting.html
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[]=runDetector

run('initPath');
run('parameters');

% Load detector parameters:
load (['../../data/detectors/',detector,'-',BBDD])
NweakClassifiers = 60;
% Load test database
load(['../../data/test',BBDD]);
[Dc, testImages]  = LMquery(D, 'object.name',objects);
NtestImages = length(testImages);
% To store the scores and classes for the bounding boxes, to calculate the
% precision-recall measurements
scores=[];
classes=[];
% Number of retrieved bounding boxes, relevant license plates in the image
% and detected ones 
RET=zeros(NtestImages,1);
REL=zeros(NtestImages,1);
RETREL=zeros(NtestImages,1);

% Loop on test images
for i = 1:NtestImages
    if (strcmp(BBDD,'AOLP')) % Images are in different directories
        Img=imread([HOMEIMAGESTEST,D(testImages(i)).annotation.filename]);
    else
        % Read image and ground truth
        Img = LMimread(D, testImages(i), HOMEIMAGESTEST);
    end
    annotation = D(testImages(i)).annotation;

    % Run scale adaptive detector:
    [Score, boundingBox, boxScores] = scaleAdaptiveBoostedDetector(double(mean(Img,3)), data, Nscales, NweakClassifiers);

    % Evaluate performace looking at precision-recall:
    [RET(i), REL(i), RETREL(i),class_object] = LMprecisionRecall_modified(boundingBox(boxScores>0,:), annotation, objects, min_detectable_object_size);
    scores=[scores; boxScores];
    classes=[classes; class_object'];
end
% Some license plates may not be detected
not_detected=sum(REL-RETREL);
scores=[scores; -inf(not_detected,1)];
classes=[classes;ones(not_detected,1)];
classes(classes==0)=-1;
% Precision-recall Vlfeat curve
figure; vl_pr(classes,scores);