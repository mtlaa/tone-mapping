function [D1,D2,B2] = Layer_decomp(img,lambda1,lambda2,lambda3)

%% first scale decomposition
[hei,wid,~] = size(img);
[D1,B1] = L1L0(img,lambda1,lambda2);

% figure,imshow(B1); 
%% second scale decomposition
% 这里可以考虑改进：更改插值的方法、更改滤波的方法、更改层分解的方法、不进行缩小等。。

% L1层分解，只施加l1稀疏项使B2分段平滑
scale = 4;
B1_d = imresize(B1,[round(hei/scale),round(wid/scale)],'bilinear'); % 以双线性插值的方法把B1缩小到原来的1/4
[~,B2_d] = L1(B1_d,lambda3);   % 用低分辨率的 B1_d 来处理，可以实现加速，只施加l1的层分解
B2_r = imresize(B2_d,[hei,wid],'bilinear');  % 以双线性插值的方法恢复到原来的分辨率

% 由于上述缩小、处理、放大 得到的B2_r图像中的边缘比较模糊，
% 所以以原始B1作为引导图像对B2_r进行快速联合双边滤波，得到清晰的边界信息
B2 = bilateralFilter(B2_r,nor(B1),0,1,min(wid,hei)/100,0.05); 

% figure,imshow(B2_d); % 低分辨率
% figure,imshow(B2_r); % 模糊
% figure,imshow(B2); % 清晰
D2 = B1 - B2; 


% D1上施加了结构先验（分段恒定，去除了一些非边缘的细节），B2施加了两次l1 边缘先验（分段平滑，保留了边缘）
% D2主要包含一些非边缘细节
end