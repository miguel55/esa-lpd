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

% Create database from training images
run('initPath');
run('parameters');
IMGdir=[HOMEIMAGES,'/'];         % Training image folder
ANNdir=[HOMEANNOTATIONS,'/'];    % Training annotation folder
im=dir([IMGdir,'*.jpg']);
d=dir([ANNdir,'*.txt']);
sI=BBDD;
sA='PASCAL';
source=struct('sourceImage', sI, 'sourceAnnotation', sA);
folder='';
name='lp';
deleted='0';
verified='1';
date=date;
delete='';
% List all training images (they include the dictionary ones)
for i=1:length(d)
    record=PASreadrecord([ANNdir,d(i).name]);
    index=0;
    for j=1:size(record.objects,2)
         pt1=struct('x',num2str(record.objects(j).bbox(1)),'y',num2str(record.objects(j).bbox(2)));
         pt2=struct('x',num2str(record.objects(j).bbox(1)),'y',num2str(record.objects(j).bbox(4)));
         pt3=struct('x',num2str(record.objects(j).bbox(3)),'y',num2str(record.objects(j).bbox(4)));
         pt4=struct('x',num2str(record.objects(j).bbox(3)),'y',num2str(record.objects(j).bbox(2)));
         pt5=struct('x',num2str(record.objects(j).bbox(1)),'y',num2str(record.objects(j).bbox(2)));
         polygon=struct('pt',[pt1 pt2 pt3 pt4 pt5]);
         index=index+1;
         object(index)=struct('name',name,'deleted',deleted,'verified',verified,'date', date, 'polygon', polygon, 'delete', delete);
    end
    annotation=struct('filename', im(i).name,'folder', folder, 'source', source, 'object', object);
    clear object;
    D(1,i)=struct('annotation',annotation);
end
save (['../../data/train',BBDD], 'D')

% Create database from test images
clear all;
run('initPath');
run('parameters');
IMGdir=[HOMEIMAGESTEST,'/'];         % Test image folder
ANNdir=[HOMEANNOTATIONSTEST,'/'];    % Test annotation folder
im=dir([IMGdir,'*.jpg']);
d=dir([ANNdir,'*.txt']);
sI=BBDD;
sA='PASCAL';
source=struct('sourceImage', sI, 'sourceAnnotation', sA);
folder='';
name='lp';
deleted='0';
verified='1';
date=date;
delete='';
% List all test images
for i=1:length(d)
    record=PASreadrecord([ANNdir,d(i).name]);
    index=0;
    for j=1:size(record.objects,2)
         pt1=struct('x',num2str(record.objects(j).bbox(1)),'y',num2str(record.objects(j).bbox(2)));
         pt2=struct('x',num2str(record.objects(j).bbox(1)),'y',num2str(record.objects(j).bbox(4)));
         pt3=struct('x',num2str(record.objects(j).bbox(3)),'y',num2str(record.objects(j).bbox(4)));
         pt4=struct('x',num2str(record.objects(j).bbox(3)),'y',num2str(record.objects(j).bbox(2)));
         pt5=struct('x',num2str(record.objects(j).bbox(1)),'y',num2str(record.objects(j).bbox(2)));
         polygon=struct('pt',[pt1 pt2 pt3 pt4 pt5]);
         index=index+1;
         object(index)=struct('name',name,'deleted',deleted,'verified',verified,'date', date, 'polygon', polygon, 'delete', delete);
    end
    annotation=struct('filename', im(i).name,'folder', folder, 'source', source, 'object', object);
    clear object;
    D(1,i)=struct('annotation',annotation);
end
save (['../../data/test',BBDD], 'D')