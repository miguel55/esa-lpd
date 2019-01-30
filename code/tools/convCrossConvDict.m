%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Title: Efficient Scale Adaptive License Plate Detection System
% Journal: IEEE Transactions on Intelligent Transportation Systems
% Author: Molina-Moreno, Miguel and González-Díaz Iván and Díaz-de-María, Fernando
% Multimedia Processing Group, Universidad Carlos III, 28911 Leganés
% email: mmolina@tsc.uc3m.es
% doi: 10.1109/TITS.2018.2859035
% August 2018; Last revision: 28-01-2019
% Code based on the Torralba et al. cronvCrossConv.m script available at:
% http://people.csail.mit.edu/torralba/shortCourseRLOC/boosting/boosting.html
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = convCrossConvDict(img, filters, patches)
% out = convCrossConv(img, filters, patches, locations) 
%
%  z =  (|img * filter| ** patch) * location

[nrows, ncols, nc] = size(img);
Nfilters = length(filters);

out = zeros([nrows ncols Nfilters], 'single'); % This only works with Matlab 7. You have to remove 'single' to make it work on older versions.
for f = 1:Nfilters
        tmp = abs(conv2(double(img), filters{f}, 'same'));
        out(:,:,f) = conv2(tmp, [1 2 1; 2 4 2; 1 2 1]/16, 'same');
end
out = zeroBoundary(out, 1); % sets to zero one pixel at the image boundary

% 2) Normalized correlation (template matching) with each patch
for f = 1:Nfilters
    [n, m] = size(patches{f});
    if ((size(img,1)>n)&&(size(img,2)>m))
        tmp = normxcorr2(patches{f}, double(out(:,:,f)));
        tmp = tmp(fix(n/2)+1:end-ceil(n/2)+1, fix(m/2)+1:end-ceil(m/2)+1);
        out(:,:,f) = zeroPad(single(tmp), [nrows ncols]);
    else
        out(:,:,f)=zeros(size(img));
    end
end