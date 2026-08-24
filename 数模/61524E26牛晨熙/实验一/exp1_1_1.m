% Newton迭代法求解f(x)=x^5+x-16的正根
clear;clc;
% 定义目标函数与导函数
f = @(x) x^5 + x - 16;
df = @(x) 5*x^4 + 1;
% 迭代参数设置
x0 = 1.5;          % 初始迭代值
tol = 1e-10;       % 精度要求：小数点后10位
max_iter = 100;    % 最大迭代次数
x_prev = x0;
iter = 0;

% 迭代过程输出
fprintf('Newton迭代过程:\n');
fprintf('迭代次数\t迭代值\t\t\t函数值绝对误差\n');
while iter < max_iter
    f_val = f(x_prev);
    df_val = df(x_prev);
    if abs(df_val) < 1e-15
        error('导数趋近于0，迭代无法继续');
    end
    x_new = x_prev - f_val / df_val;
    iter = iter + 1;
    fprintf('%d\t\t%.12f\t%.2e\n',iter,x_new,abs(f_val));
    if abs(x_new - x_prev) < tol
        break;
    end
    x_prev = x_new;
end

% 结果输出
fprintf('=====================================\n');
fprintf('Newton迭代收敛结果：x=%.12f\n',x_new);
fprintf('达到精度要求的迭代次数：%d\n',iter);