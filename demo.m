clear;clc;
%% Parameters
lambda1 = 0.3;  
lambda2 = lambda1*0.01;
lambda3 = 0.1;

%% read files
hdr = hdrread('2.hdr');
hdr = double(hdr);
[hei,wid,channel] = size(hdr);
%%rbg=tonemap(hdr)
%%imshow(rbg)
tic;  %% 开始计时
%% transformation
hdr_h = rgb2hsv(hdr);  %% 将 RGB 颜色转换为 HSV
hdr_l = hdr_h(:,:,3);    %% hdr_l只包含 hdr_h的第三个通道 v：明暗，表示色彩的明亮程度
hdr_l = log(hdr_l+0.0001);    %% hdr_l=ln(hdr_l+0.0001)  通道V转化为对数域
hdr_l = nor(hdr_l);  %% （hdr_l-min）/(max-min)   nor()：归一化

%%  decomposition   lambda1,lambda2用于第一次分解
[D1,D2,B2] = Layer_decomp(hdr_l,lambda1,lambda2,lambda3);

% figure,imshow(D1);
% figure,imshow(D2);
% figure,imshow(B2);
%% Scaling
% 这里可以考虑改进：更改细节层增强的方法、增加降噪、更改基础层压缩的方法等

sigma_D1 = max(D1(:));
D1s = R_func(D1,0,sigma_D1,0.8,1);  % 用非线性拉伸函数增强细节层D1

% sigma_D2 = max(D2(:));
% D2s = R_func(D2,0,sigma_D2,0.9,1);   % D2的处理可选

B2_n= compress(B2,2.2,1);   % 使用伽马函数压缩基础层B2
hdr_lnn = 0.8*B2_n + D2 + 1.2*D1s;   % 分配权重合并

% figure,imshow(D1s);
% figure,imshow(D2s);
% figure,imshow(B2_n);
% figure,imshow(hdr_lnn);

%% postprocessing
% clampp将V值大小的前0.5%和后0.5%截断
hdr_lnn = nor(clampp(hdr_lnn,0.005,0.995));
% cat串联数组，把HSV三个通道串联。饱和通道S *0.6 防止过饱和
out_rgb = hsv2rgb((cat(3,hdr_h(:,:,1),hdr_h(:,:,2)*0.6,hdr_lnn)));
toc;   %% 结束计时

figure,imshow(out_rgb)
% imwrite(out_rgb,"enhD1.png");



