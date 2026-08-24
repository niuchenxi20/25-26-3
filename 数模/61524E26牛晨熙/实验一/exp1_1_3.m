% 悬崖高度计算
clear all; clc;
format long;

% 1. 定义参数
g = 9.8;
k = 0.05;
vs = 340;
t_total = 4;
t0 = 0.2;
T = t_total - t0; % T=3.8

% 2. 定义F(h)
F = @(h) h - (g/(k^2)) * ( k*(T - h/vs) + exp(-k*(T - h/vs)) - 1 );

% 3. 定义dF(h)
dF = @(h) 1 + (g/(k*vs)) * ( 1 - exp(-k*(T - h/vs)) );

% 4. 迭代初始化
h_prev = 70;
tol = 1e-8;
iter = 0;

% 5. 迭代过程
fprintf('迭代过程:\n');
fprintf('次数\t高度(m)\t\tF(h)值\t\t相邻误差\n');
while iter < 5
    F_val = F(h_prev);
    dF_val = dF(h_prev);
    h_new = h_prev - F_val / dF_val;
    iter = iter + 1;
    err = abs(h_new - h_prev);
    fprintf('%d\t%.8f\t%.8e\t%.8e\n',iter,h_new,F_val,err);
    if err < tol
        break;
    end
    h_prev = h_new;
end

% 6. 最终结果
fprintf('====================\n');
fprintf('最终高度：%.4f m\n',h_new);
