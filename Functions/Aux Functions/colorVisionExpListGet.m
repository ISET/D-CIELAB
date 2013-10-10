function expList = colorVisionExpListGet(subjectInfo)
%% function colorVisionExpListGet
%    Get color vision experiment list. The list contains experiment name,
%    description and main entrance function to be executed for the
%    experiment
%
%  (HJ) Oct, 2013

expList{1}.expName = 'Color Match TAFC';
expList{1}.expDesc = 'Two interval force choice color match experiment';
expList{1}.expFunc = 'colorMatchTAFC(subjectInfo)';

expList{2}.expName = 'Color Direction Test';
expList{2}.expDesc = ['Use arrow keys to change color to' ...
                      'find least visible one'];
expList{2}.expFunc = 'cbDirectionOnCircle';

expList{3}.expName = 'Color Detection';
expList{3}.expDesc = '';
expList{3}.expFunc = 'colorDetection(subjectInfo)';
end