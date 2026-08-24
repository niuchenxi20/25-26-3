% 1. 改造后的不动点迭代
clear;clc;
phi = @(x) (16 - x)^(1/5);  % 收敛的不动点迭代函数
x0 = 1.5;                   % 初始迭代值
tol = 1e-10;                % 精度要求
max_iter = 200;             % 最大迭代次数
x_prev = x0;
iter = 0;

% 不动点迭代过程
fprintf('不动点迭代过程:\n');
fprintf('迭代次数\t迭代值\t\t\t相邻迭代误差\n');
while iter < max_iter
    x_new = phi(x_prev);
    iter = iter + 1;
    err = abs(x_new - x_prev);
    fprintf('%d\t\t%.12f\t%.2e\n',iter,x_new,err);
    if err < tol
        break;
    end
    x_prev = x_new;
end

% 不动点迭代结果输出
fprintf('=====================================\n');
fprintf('不动点迭代收敛结果：x=%.12f\n',x_new);
fprintf('达到精度要求的迭代次数：%d\n',iter);

% 2. 加速迭代
fprintf('\n=====================================\n');
fprintf('加速迭代过程:\n');
x_prev_ait = x0;
iter_ait = 0;
eps_denominator = 1e-15;  

while iter_ait < max_iter
    % 步骤1：计算两次不动点迭代
    x1 = phi(x_prev_ait);
    x2 = phi(x1);
    
    % 步骤2：计算分母并判断是否趋近于0
    denominator = x2 - 2*x1 + x_prev_ait;
    if abs(denominator) < eps_denominator
        fprintf('迭代终止：分母趋近于0，当前迭代次数=%d\n', iter_ait+1);
        x_new_ait = x1;  % 直接使用x1作为最终结果（已收敛）
        break;
    end
    
    % 步骤3：Aitken加速公式计算新值
    x_new_ait = x_prev_ait - (x1 - x_prev_ait)^2 / denominator;
    iter_ait = iter_ait + 1;
    
    % 步骤4：计算误差并输出
    err_ait = abs(x_new_ait - x_prev_ait);
    fprintf('%d\t\t%.12f\t%.2e\n',iter_ait,x_new_ait,err_ait);
    
    % 步骤5：判断收敛（双重条件：误差达标 或 函数值达标）
    if err_ait < tol || abs(phi(x_new_ait) - x_new_ait) < tol
        break;
    end
    
    x_prev_ait = x_new_ait;
end

% Aitken加速结果输出
fprintf('=====================================\n');
fprintf('Aitken加速迭代收敛结果：x=%.12f\n',x_new_ait);
fprintf('达到精度要求的迭代次数：%d\n',iter_ait);