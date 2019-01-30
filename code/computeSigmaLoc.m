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
function [] = computeSigmaLoc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute the complete location vector (scale + empirical parts) for each 
% one of the visual words 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run('initPath');
run('parameters');

load (['../../data/trainDB',BBDD])
dictionary = data.dictionary;
D = data.databaseStruct;
Nfeatures = length(dictionary.filter);
% Remove dictionary samples from the training images: they have the string
% dict in their name
[Dc, dictionarySamples]  = LMquery(D, 'filename', 'dict');
trainImage=setdiff(1:length(D), dictionarySamples);
ns=1;
threshold=0.8;

i = 0; 
while i < length(trainImage)
    i = i+1;
    img = LMimread(D, trainImage(i), HOMEIMAGES);
    img = uint8(mean(double(img),3));
    annotation = D(trainImage(i)).annotation;
    jo = LMobjectindex(annotation, objects);

    % Loop on the number of instances present in each image
    imageUsed = 0;
    for m = 1:length(jo)
        ann = annotation;
        ann.object = ann.object([jo(m) setdiff(jo,jo(m))]);
        [X,Y] = LMobjectpolygon(ann, objects); % get object polygon
        newimg=img(Y{1,1}(1,1):Y{1,1}(3,1),X{1,1}(1,1):X{1,1}(3,1));
        % Compute normalized correlation between dictionary license plates 
        % and training images
        out = convCrossConvDict(single(newimg),dictionary.filter,dictionary.patch);
        for j=1:Nfeatures
            % Obtain regional maxima above threshold
            aux=imregionalmax(out(:,:,j));
            aux2=aux.*out(:,:,j);
            f=find(aux2>threshold);
            [y,x]=ind2sub(size(aux2),f);
            cy=round(size(aux2,1)/2);
            cx=round(size(aux2,2)/2);
            % Add obtained locations to location vector and score vector
            dictionary.location{j}{1}=[dictionary.location{j}{1}; x-cx];
            dictionary.location{j}{2}=[dictionary.location{j}{2}; y-cy];
            scores=zeros(length(y),1);
            for k=1:length(y)
                scores(k)=aux2(y(k),x(k));
            end
            dictionary.score{j}=[dictionary.score{j}; scores];
            sca=max([discretize(size(aux2,2),scales_X),discretize(size(aux2,1),scales_Y)]);
            dictionary.scale{j} = [dictionary.scale{j}; sca*ones(length(y),1)];
        end
        ns = ns+1;
    end
end
data.databaseStruct = D;
data.dictionary = dictionary;

muXW=zeros(1,Nfeatures);    % Weighted by score
stXW=zeros(1,Nfeatures);
muYW=zeros(1,Nfeatures);
stYW=zeros(1,Nfeatures);
lim=17;                     % To consider only relevant samples
for j=1:Nfeatures
    muXW(j)=sum(data.dictionary.location{1,j}{1,1}(data.dictionary.score{1,j}>threshold).*data.dictionary.score{1,j}(data.dictionary.score{1,j}>threshold)/sum(data.dictionary.score{1,j}(data.dictionary.score{1,j}>threshold)));
    muYW(j)=mean(data.dictionary.location{1,j}{1,2}(data.dictionary.score{1,j}>threshold).*data.dictionary.score{1,j}(data.dictionary.score{1,j}>threshold));
    selectedX1=abs(data.dictionary.location{1,j}{1,1}-data.dictionary.location{1,j}{1,1}(1,1))<lim;
    selectedS=data.dictionary.score{1,j}>threshold;
    selectedX=logical(selectedX1.*selectedS);
    selectedY1=abs(data.dictionary.location{1,j}{1,2}-data.dictionary.location{1,j}{1,2}(1,1))<lim;
    selectedY=logical(selectedY1.*selectedS);
    stXW(j)=sqrt(var(data.dictionary.location{1,j}{1,1}(selectedX)-data.dictionary.location{1,j}{1,1}(1,1),data.dictionary.score{1,j}(selectedX)));
    stYW(j)=sqrt(var(data.dictionary.location{1,j}{1,2}(selectedY)-data.dictionary.location{1,j}{1,2}(1,1),data.dictionary.score{1,j}(selectedY)));
end  
data.dictionary.muXW=muXW;
data.dictionary.muYW=muYW;
data.dictionary.stXW=stXW;
data.dictionary.stYW=stYW;

% Adapt empirical standard deviations to range [5,11] (which is
% appropriated to GentleBoost)
data.dictionary.stXW(data.dictionary.stXW(:)<5)=5;
data.dictionary.stYW(data.dictionary.stYW(:)<5)=5;
data.dictionary.stXW(data.dictionary.stXW(:)>11)=11;
data.dictionary.stYW(data.dictionary.stYW(:)>11)=11;

data.dictionary.score=[];
for j=1:Nfeatures
    % Only store original location and scale
    data.dictionary.scale{1,j}=data.dictionary.scale{1,j}(1,1);
    data.dictionary.location{1,j}{1,1}=data.dictionary.location{1,j}{1,1}(1,1);
    data.dictionary.location{1,j}{1,2}=data.dictionary.location{1,j}{1,2}(1,1);
	% Build Gaussian location distributions
    Lx=scales_X(data.dictionary.scale{1,j});
    Ly=scales_Y(data.dictionary.scale{1,j});
    % For patches located in the border, enlarge distributions (it has no
    % effect over the results)
    Lx=Lx+10;
    Ly=Ly+10;
    % Gaussian location distribution in x-direction
    gx = zeros(1, Lx); 
    gx(round(Lx/2+data.dictionary.location{1,j}{1,1}(1,1))) = 1;
    % Fix standard deviation due to scale
    sigmaSC=5+2*(data.dictionary.scale{1,j}-1);
    % Empirical standard deviation
    sigmaEmp=data.dictionary.stXW(j);
    sigmaT=(sigmaSC+sigmaEmp)/2;
    locSigmaX=exp(-(-sigmaT:sigmaT).^2/((sigmaT)^2));
    locSigmaX(isnan(locSigmaX))=1;
    gx = conv(gx, locSigmaX,'same');
    if (sum(gx)~=0)
        gx = gx/sum(gx); 
    end
    data.dictionary.locG{1,j}{1,1}=gx;
    % Gaussian location distribution in y-direction
    gy = zeros(1, Ly);
    gy(round(Ly/2+data.dictionary.location{1,j}{1,2}(1,1))) = 1; 
    sigmaEmp=data.dictionary.stYW(j);
    sigmaT=(sigmaSC+sigmaEmp)/2;
    locSigmaY=exp(-(-sigmaT:sigmaT).^2/((sigmaT)^2));
    locSigmaY(isnan(locSigmaY))=1;
    gy = conv(gy, locSigmaY,'same');
    if (sum(gy)~=0)
        gy = gy/sum(gy); 
    end            
    data.dictionary.locG{1,j}{1,2}=gy;
end

save (['../../data/train',BBDD], 'data')

