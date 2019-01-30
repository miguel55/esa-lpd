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
function []=createDictionary

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create dictionary of visual words
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run('initPath');
run('parameters');

% Load database struct
load (['../../data/train',BBDD]);
data.databaseStruct = D;

% Dictionary images: the sampleFromImages first ones
jc=1:sampleFromImages;

% Initialize patch counts
nd = 0;
% Loop for extracting patches to build the dictionary
for i = 1:sampleFromImages
    img = LMimread(D, jc(i), HOMEIMAGES);
    img = uint8(mean(double(img),3));
    annotation = D(jc(i)).annotation;
    jo = LMobjectindex(annotation, objects);
    for m = 1:length(jo)
        ann = annotation;
        ann.object = ann.object([jo(m) setdiff(jo,jo(m))]);

        % Get tight crop of the centered object to extract patches:
        [newannotation, newimg, crop, scaling, err, msg] = LMcookimage_modified(ann, img, ...
            'objectname', objects, 'objectsize', [0,0], 'objectlocation', 'centered', 'maximagesize', [135 180]);

        [nrows, ncols] = size(newimg);
        % If there is no error
        if (err == 0)
            % Get object polygon and object center coordinates
            [X,Y] = LMobjectpolygon(newannotation, objects); % get object polygon

            % Object center
            cx = round((min(X{1})+max(X{1}))/2);
            cy = round((min(Y{1})+max(Y{1}))/2);
            tamX=str2num(D(jc(i)).annotation.object(1,1).polygon.pt(3).x)-str2num(D(jc(i)).annotation.object(1,1).polygon.pt(1).x);
            tamY=str2num(D(jc(i)).annotation.object(1,1).polygon.pt(3).y)-str2num(D(jc(i)).annotation.object(1,1).polygon.pt(1).y);
            % The patch size depends on the scale, the scale is stored in 
            % sca. The scale definition can change depending on the
            % problem. The patch size can increase depending on the
            % problem, leading to better results.
            sca=max([discretize(tamX,scales_X),discretize(tamY,scales_Y)]);
            patchSize=patchSizes(sca);
%             if ((tamX<scales_X(1))&&(tamY<scales_Y(1)))
%                 patchSize=9;
%                 sca=1;
%             elseif ((tamX<100)&&(tamY<35))
%                 patchSize=13; 
%                 sca=2;
%             elseif ((tamX<120)&&(tamY<45))
%                 patchSize=17;  
%                 sca=3;
%             else
%                 patchSize=21; 
%                 sca=4;
%             end
            % segmentation mask
            [x,y] = meshgrid(1:ncols, 1:nrows);
            mask = logical(inpolygon(x, y, X{1}, Y{1}));
            % Sample points from edges within the object mask:
            edgemap = edge(newimg,'canny', [0.001 .01]);
            [yo, xo] = find(edgemap.*mask);
            rng(100*sum(clock),'twister')
            no = randperm(length(xo(:))); no = no(1:patchesFromExample); % random sampling on edge points
            disp(no(1:3));
            xo = xo(no); yo = yo(no);

            % keep coordinates within image size:
            xo = max(xo, max(patchSize+1)/2+1);
            yo = max(yo, max(patchSize+1)/2+1);
            xo = min(xo, ncols - max(patchSize+1)/2);
            yo = min(yo, nrows - max(patchSize+1)/2);

            % Get patches from filtered image:
            out = convCrossConv(double(newimg), filters);

            % Crop patches: all filter outputs from each location
            for lp = 1:patchesFromExample
                for lf = 1:Nfilters
                    p = patchSize-1; % random patch size
                    patch  = double(out(yo(lp)-p/2:yo(lp)+p/2, xo(lp)-p/2:xo(lp)+p/2, lf));
                    patch  = (patch - mean(patch(:))) / std(patch(:));
                    nd = nd+1; % counter of elements in the dictionary

                    % Store parameters in dictionary
                    dictionary.filter{nd} = filters{lf}; % Filter (feature)
                    dictionary.patch{nd}  = patch;       % Patch (template)
                    dictionary.location{nd}{1}  = xo(lp)-cx;    % Location (part location)
                    dictionary.location{nd}{2}  = yo(lp)-cy;
                    dictionary.imagendx(nd)  = jc(i);    % Index of image source
                    dictionary.score{nd}=1;
                    dictionary.tamX(nd)=tamX;
                    dictionary.tamY(nd)=tamY;
                    dictionary.scale{nd}=sca;
                end
            end
        end
    end
end
data.dictionary = dictionary;

% SAVE DICTIONARY
save (['../../data/trainDB',BBDD], 'data')



