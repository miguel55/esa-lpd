%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Title: Efficient Scale Adaptive License Plate Detection System
% Journal: IEEE Transactions on Intelligent Transportation Systems
% Author: Molina-Moreno, Miguel and González-Díaz Iván and Díaz-de-María, Fernando
% Multimedia Processing Group, Universidad Carlos III, 28911 Leganés
% email: mmolina@tsc.uc3m.es
% doi: 10.1109/TITS.2018.2859035
% August 2018; Last revision: 28-01-2019
% Code based on the Torralba et al. singleScaleBoostedDetector.m script available at:
% http://people.csail.mit.edu/torralba/shortCourseRLOC/boosting/boosting.html
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [imMax, boundingBox, boxScores] = scaleAdaptiveBoostedDetector(img, data, Nscales, NweakClassifiers)
% Test the boosting detector
%   img             : input gray image
%   data            : struct containing the detector
%   Nscales         : number of scales to be used 
%   NweakClassifiers: number of weak-learners to use

%   imMax           : score image
%   boundingBox     : resulting bounding boxes
%   boxScores       : bounding box scores

% Number of weak detectors:
if nargin < 4
    NweakClassifiers = length(data.detector);
end

% Initialize variables
BW=zeros(size(img,1),size(img,2),Nscales);

% Compute all features and reweight features
for j = 1:NweakClassifiers
    % select feature index
    k  = data.detector(j).featureNdx;
    % evaluate feature (weak detector)
    feature = convCrossConv(img, data.dictionary.filter(k), data.dictionary.patch(k), data.dictionary.locG(k));
    % compute regression stump
    weakDetector = (data.detector(j).a * (feature > data.detector(j).th) + data.detector(j).b);
    scale=data.dictionary.scale{1,k}(1,1);
    BW(:,:,scale) = BW(:,:,scale)+weakDetector;
end

% Look at local maximum of output score and output a set of detected object
% bounding boxes.
imMax=sum(BW,3);
s=double(sum(BW,3)>0);
s = conv2(hamming(50),hamming(150),s,'same');
BW1 = imregionalmax(s);
% Linear interpolation for bounding box sizes
percSc=(BW-min(BW(:)))./repmat(sum(BW-min(BW(:)),3),1,1,Nscales);
[y, x] = find(BW1.*s);

D = dist([x y]'); D = D + 1000*eye(size(D));
% To ensure the correct detection
while min(D(:))<10
    N = length(x);
    [i,j] = find(D==min(D(:)));
    x(i(1)) = round((x(i(1)) + x(j(1)))/2);
    y(i(1)) = round((y(i(1)) + y(j(1)))/2);
    x = x(setdiff(1:N,j(1)));
    y = y(setdiff(1:N,j(1)));
    D = dist([x y]'); D = D + 1000*eye(size(D));
end
nDetections = length(x);
boundingBox = zeros(nDetections, 4);
for n=1:nDetections
    scalesE=percSc(y(n),x(n),:);
    % The linear interpolation needs to be adapted to each problem
    if (Nscales==4)
        tam=scalesE(1)*[20 60]+scalesE(2)*[30 90]+scalesE(3)*[40 110]+scalesE(4)*[50 130];
    elseif (Nscales==3)
        tam=scalesE(1)*[20 60]+scalesE(2)*[30 90]+scalesE(3)*[40 110];
    end
    boundingBox(n,:)=round([x(n)-tam(2)/2, x(n)+tam(2)/2, y(n)-tam(1)/2, y(n)+tam(1)/2]);
end

ind = sub2ind(size(s), y, x);
boxScores = s(ind);

