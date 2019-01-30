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
function [] = computeSigmaScale

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute location vector for each one of the visual words only with scale
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run('initPath');
run('parameters');

load (['../../data/trainDB',BBDD])
Nfeatures = length(data.dictionary.filter);

for j=1:Nfeatures
    % Only store original location and scale
    data.dictionary.scale{1,j}=data.dictionary.scale{1,j}(1,1);
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
    locSigmaX=exp(-(-sigmaSC:sigmaSC).^2/((sigmaSC)^2));
    locSigmaX(isnan(locSigmaX))=1;
    gx = conv(gx, locSigmaX,'same');
    if (sum(gx)~=0)
        gx = gx/sum(gx); 
    end
    data.dictionary.locG{1,j}{1,1}=gx;
    % Gaussian location distribution in y-direction
    gy = zeros(1, Ly);
    gy(round(Ly/2+data.dictionary.location{1,j}{1,2}(1,1))) = 1; 
    locSigmaY=exp(-(-sigmaSC:sigmaSC).^2/((sigmaSC)^2));
    locSigmaY(isnan(locSigmaY))=1;
    gy = conv(gy, locSigmaY,'same');
    if (sum(gy)~=0)
        gy = gy/sum(gy); 
    end            
    data.dictionary.locG{1,j}{1,2}=gy;
end

save (['../../data/trainDB',BBDD], 'data')

