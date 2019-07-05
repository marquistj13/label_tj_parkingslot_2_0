function slot = estimateSlot(im, firstKP, secKP, type, idealExemplarForSlantedPS,...
                             LongSideMin, parallelPSSideLength, verticalPSSideLength)

   slot = [];
   im = single(im);
   x1 = firstKP(1);
   y1 = firstKP(2);
   x2 = secKP(1);
   y2 = secKP(2);
   distance = sqrt((x1-x2)^2 + (y1-y2)^2);   
   %根据先验知识估计库位深度，目前只有2类，长的平行库位和短库位
   %LongSideMin是平行长库位的库位入口线长度的最小可能值
   if distance < LongSideMin %说明是短库位
      sideLength = verticalPSSideLength;
   else %说明是平行长库位
      sideLength = parallelPSSideLength;
   end
   
   if type == 1%直角库位
       slantAngleInRadians = 90/180*pi;
       vec = firstKP(1:2)-secKP(1:2);
       vec = vec*[cos(slantAngleInRadians) -sin(slantAngleInRadians); sin(slantAngleInRadians) cos(slantAngleInRadians)];
       vec = vec / norm(vec);
       thirdP = secKP(1:2) + vec * sideLength;
       fourthP = firstKP(1:2) + vec * sideLength;
   elseif type == 2 %right upward slanted ps
       if round(y1)-23<1 || round(y1)+23>416 || round(x1)-23<1 ||round(x1)+23>416 ||...
          round(y2)-23<1 || round(y2)+23>416 || round(x2)-23<1 ||round(x2)+23>416
          return;
       end
       
       vecFromSecToFirst = firstKP(1:2) - secKP(1:2);
       angle = atan2(-vecFromSecToFirst(2),vecFromSecToFirst(1));
       exemplarStart = 1; %实现生成的template matrix，1~41片存储的是30~70夹角的模板
       exemplarEnd = 41;
       exemplarMat = zeros(47,47,exemplarEnd-exemplarStart+1);
       
       for exemplarIndex = exemplarStart:exemplarEnd %exemplars correspond to left-upward patterns
           exemplar = idealExemplarForSlantedPS(:,:,exemplarIndex);
           rotatedEemplar = imrotate(exemplar,angle/pi*180,'bilinear', 'crop');
           exemplarMat(:,:,exemplarIndex-exemplarStart+1) = rotatedEemplar;
       end
       
       patchFirstKP = im(round(y1)-23:round(y1)+23, round(x1)-23:round(x1)+23);
       patchFirstKP = (patchFirstKP - mean2(patchFirstKP))/(0.000001+std(patchFirstKP(:)));
       
       patchSecKP = im(round(y2)-23:round(y2)+23, round(x2)-23:round(x2)+23);
       patchSecKP = (patchSecKP - mean2(patchSecKP))/(0.000001+std(patchSecKP(:)));
       
       patchMat = repmat(patchFirstKP + patchSecKP,[1,1,exemplarEnd-exemplarStart+1]);
       
       res = sum(sum(exemplarMat.* patchMat));
      
       [~,maxIndex] = max(res,[],3);
       thisSlantAngle = 30 + maxIndex-1; %夹角从30开始

       slantAngle = thisSlantAngle;
       
%        
%        %then, we need to check whether it is correctly classified
%        mostMatchedExemplar = exemplarMat(:,:,maxIndex);
%        res1 = sum(sum(patchFirstKP.* mostMatchedExemplar));
%        res2 = sum(sum(patchSecKP.* mostMatchedExemplar));
%        if res1<5 || res2<5
%            return;
%        end
       slantAngleInRadians = slantAngle/180*pi;
       vec = firstKP(1:2)-secKP(1:2);
       vec = vec*[cos(slantAngleInRadians) -sin(slantAngleInRadians); sin(slantAngleInRadians) cos(slantAngleInRadians)];
       vec = vec / norm(vec);
       thirdP = secKP(1:2) + vec * sideLength;
       fourthP = firstKP(1:2) + vec * sideLength;
   elseif type == 3 %left upward slanted ps
       %to decide the orientation of the slanted slot, we use several
       %template patterns having different angles; test their response to
       %the two key-point patches
       %To test whether the underlying entrance-line really is belong to
       %type 2, we use the selected pattern and judge its response to the
       %two KP patterns; only when both of them are large enough, we deem
       %that this entrance-line really is of type 2
       if round(y1)-23<1 || round(y1)+23>416 || round(x1)-23<1 ||round(x1)+23>416 ||...
          round(y2)-23<1 || round(y2)+23>416 || round(x2)-23<1 ||round(x2)+23>416
          return;
       end
       
       vecFromSecToFirst = firstKP(1:2) - secKP(1:2);
       angle = atan2(-vecFromSecToFirst(2),vecFromSecToFirst(1));
       
       exemplarStart = 42;
       exemplarEnd = 82;
       exemplarMat = zeros(47,47,exemplarEnd-exemplarStart+1);
       
       for exemplarIndex = exemplarStart:exemplarEnd %exemplars correspond to left-upward patterns
           exemplar = idealExemplarForSlantedPS(:,:,exemplarIndex);
           rotatedEemplar = imrotate(exemplar,angle/pi*180,'bilinear', 'crop');
           exemplarMat(:,:,exemplarIndex-exemplarStart+1) = rotatedEemplar;
       end
       
       patchFirstKP = im(round(y1)-23:round(y1)+23, round(x1)-23:round(x1)+23);
       patchFirstKP = (patchFirstKP - mean2(patchFirstKP))/(0.000001+std(patchFirstKP(:)));
       
       patchSecKP = im(round(y2)-23:round(y2)+23, round(x2)-23:round(x2)+23);
       patchSecKP = (patchSecKP - mean2(patchSecKP))/(0.000001+std(patchSecKP(:)));
       
       patchMat = repmat(patchFirstKP + patchSecKP,[1,1,exemplarEnd-exemplarStart+1]);
       
       res = sum(sum(exemplarMat.* patchMat));
      
       [~,maxIndex] = max(res,[],3);
       thisSlantAngle = 110 + maxIndex-1;
     
       slantAngle = thisSlantAngle;
    
%         slantAngle = thisSlantAngle;
        %then, we need to check whether it is correctly classified
%        mostMatchedExemplar = exemplarMat(:,:,maxIndex);
%        res1 = sum(sum(patchFirstKP.* mostMatchedExemplar));
%        res2 = sum(sum(patchSecKP.* mostMatchedExemplar));
%        if res1<5 || res2<5
%            return;
%        end

       slantAngleInRadians = slantAngle/180*pi;
       vec = firstKP(1:2)-secKP(1:2);
       vec = vec*[cos(slantAngleInRadians) -sin(slantAngleInRadians); sin(slantAngleInRadians) cos(slantAngleInRadians)];
       vec = vec / norm(vec);
       thirdP = secKP(1:2) + vec * sideLength;
       fourthP = firstKP(1:2) + vec * sideLength;
   end
   %for each slot, the four corners is in a clock-wise form and the first
   %and the last two corners are the end-points of the entrance-line
   if type == 2||type == 3
       slot = [secKP(1:2) thirdP fourthP firstKP(1:2) thisSlantAngle];
   else
       slot = [secKP(1:2) thirdP fourthP firstKP(1:2) 0];
   end
    
