%% This function performs the hybrid L1-L0 decomposition

function [D,B]= L1L0(S,lambda1,lambda2)

iter = 15;
[hei,wid] = size(S);

fx = [1, -1];   % 表示梯度算子，x 和 y 方向的
fy = [1; -1];
otfFx = psf2otf(fx,[hei,wid]);    % 为 fft(▽x)
otfFy = psf2otf(fy,[hei,wid]);   % 为 fft(▽y)
DxDy = abs(otfFy).^2 + abs(otfFx).^2;

B = S;   % 对应于文中的b
C = zeros(hei,wid*2);   % 文中的c1
E = zeros(hei,wid*2);   % 文中的c2
L1 = zeros(hei,wid*2);   % 文中的y1
L2 = zeros(hei,wid*2);   % 文中的y2
ro1 = 1;   
ro2 = 1;   % ro1==ro2 ，对应文中的ρ
DiffS = [-imfilter(S,fx,'circular'),-imfilter(S,fy,'circular')];   %  ▽S 
for i = 1:iter
    
    % 为什么这样初始化c1，c2
    CL = C + L1./ro1;
    EL = DiffS - E - L2./ro2;
    %% for B   （1）
    C1L1 = CL(:,1:wid);
    C2L2 = CL(:,1+wid:end);
    E1L3 = EL(:,1:wid);
    E2L4 = EL(:,1+wid:end);
    
    Nomi = fft2(S) + ro1.*conj(otfFx).*fft2(C1L1) + ro1.*conj(otfFy).*fft2(C2L2) ...
        + ro2.*conj(otfFx).*fft2(E1L3) + ro2.*conj(otfFy).*fft2(E2L4);
    Denomi = 1 + (ro1 + ro2) .* DxDy;
    B_new = real(ifft2(Nomi./Denomi));
    DiffB = [-imfilter(B_new,fx,'circular'),-imfilter(B_new,fy,'circular')];   % ▽b
    
    %% for C11，C12  （2）
    BL = DiffB - L1./ro1;
    C_new = sign(BL) .* max(abs(BL) - lambda1./ro1 ,0);
    
    %% for C21，C22  （3）分段函数求解
    BL = DiffS - DiffB - L2./ro2;
    E_new = BL;
    % 根据条件把某些像素置0
    temp = BL.^2;
    t = temp < 2.*lambda2./ro2;
    E_new(t) = 0;
    
    %% for Li,i=1,2,3,4 （4） yi  
    L1_new = L1 + ro1 * (C_new - DiffB);
    L2_new = L2 + ro2 * (E_new - DiffS + DiffB);
    
    %% for ro  （5）update
    ro1 = ro1 *4;
    ro2 = ro2 *4;
    
    %% update
    B = B_new;
    C = C_new;
    E = E_new;
    L1 = L1_new;
    L2 = L2_new;

end

D = S - B;


end
