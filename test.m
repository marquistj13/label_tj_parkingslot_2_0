ShortSideMin = 86;
ShortSideMax = 139;
LongSideMin = 160;
LongSideMax = 279;
parallelPSSideLength = 83;
verticalPSSideLength = 195;
idealExemplarForSlantedPS = load('idealExemplars.mat');
idealExemplarForSlantedPS = idealExemplarForSlantedPS.idealExemplars;
% % trainging 
% datafolder =  'D:\software files ori\parking slot\ps2.0\';
% subFolderName = 'training';

% testing
datafolder = 'D:\software files ori\parking slot\ps2.0\testing\';
% subFolderName = 'all';
% subFolderName = 'indoor-parking lot';
% subFolderName = 'outdoor-normal daylight';
% subFolderName = 'outdoor-rainy';
% subFolderName = 'outdoor-shadow';
% subFolderName = 'outdoor-slanted';
subFolderName = 'outdoor-street light';

results_mat_save_folder = strcat('slot_results','/', subFolderName);
if ~exist(results_mat_save_folder, 'dir')
  mkdir(results_mat_save_folder);
end
testImgFiles = dir([datafolder subFolderName '/*.jpg']);
for index = 1:length(testImgFiles)
%for index = 1:1 
  %index=1800
  %display(index);
  currentFileName = testImgFiles(index).name;
  %display(currentFileName)
  tmp = strsplit(testImgFiles(index).name, ".");
  currentFileName_no_ext = tmp{1};
  ori_img = imread([datafolder subFolderName '/' currentFileName]);
  resultImage = ori_img;
  resizedImg = imresize(ori_img,[416 416], 'method', 'bilinear');
  test_data = load([datafolder subFolderName '/' currentFileName_no_ext '.mat']);
  slots=[];
  if ~isempty(test_data.slots)
    for slot_index = 1 : size(test_data.slots, 1)
      slot = test_data.slots(slot_index,:);  
      % note: the point sequence is essential to get the correct labeling
      secKP  = test_data.marks(slot(1),:) * 416 /600;
      firstKP = test_data.marks(slot(2),:) * 416 /600;
      slotType = slot(3);
      thisSlot=  estimateSlot(resizedImg, firstKP, secKP, slotType, idealExemplarForSlantedPS, LongSideMin, parallelPSSideLength, verticalPSSideLength);


      if ~isempty(thisSlot)
        slot = thisSlot(1:8) * 600 / 416;
        slots = [slots; slot];       
        %resultImage = insertShape(resultImage,'Polygon',slot,'Color','blue','linewidth',4);
      end
    end
    save_mat_name = strcat(results_mat_save_folder,'/',currentFileName_no_ext,'.mat');
    save(save_mat_name, 'slots');
  end
  %imshow(resultImage) 
end


