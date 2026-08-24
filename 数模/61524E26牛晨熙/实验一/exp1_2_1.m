% 计算n=3~50的随机一致性指标RI
clear;clc;
format shortG;
rng(0); 
%% 1. 参数设置
n_start = 3;      % 起始阶数
n_end = 50;       % 终止阶数
N = 100000;       % 每个n的随机矩阵样本量
RI_values = zeros(n_end - n_start + 1, 1); % 存储计算的RI

%% 2. 预定义完整1-9标度集合（17个值，均匀随机选取）
scale_set = [1/9, 1/8, 1/7, 1/6, 1/5, 1/4, 1/3, 1/2, ...
             1, 2, 3, 4, 5, 6, 7, 8, 9];
scale_num = length(scale_set); % 17个标度

%% 3. Saaty 2008版标准RI值（n=3~10）
Saaty_2008_RI = [0.52, 0.89, 1.11, 1.25, 1.35, 1.40, 1.45, 1.49];

%% 4. 循环计算每个n的RI
fprintf('正在计算n=3~50的RI值，样本量N=%d，请稍候...\n', N);
for n = n_start:n_end
    CI_sum = 0;
    parfor k = 1:N % 并行循环加速
        % 步骤1：生成n阶标准随机正互反矩阵
        A = eye(n);
        for i = 1:n
            for j = i+1:n
                % 从17个标度中均匀随机选1个
                rand_idx = randi(scale_num);
                A(i,j) = scale_set(rand_idx);
                A(j,i) = 1 / A(i,j); % 严格满足正互反性
            end
        end
        
        % 步骤2：计算最大特征值
        eig_vals = eig(A);
        lambda_max = max(real(eig_vals));
        
        % 步骤3：计算CI并累加
        CI = (lambda_max - n) / (n - 1);
        CI_sum = CI_sum + CI;
    end
    
    % 步骤4：计算当前n的RI
    RI_values(n - n_start + 1) = CI_sum / N;
    fprintf('已完成n=%d的计算，RI=%.4f\n', n, RI_values(n - n_start + 1));
end

%% 5. 输出n=3~50的RI完整表格
fprintf('\n==================== n=3~50的随机一致性指标RI表格 ====================\n');
fprintf('阶数n\tRI值\t\t阶数n\tRI值\t\t阶数n\tRI值\n');
for i = 1:length(RI_values)
    n = n_start + i - 1;
    if mod(i,3) == 0
        fprintf('%d\t%.4f\n', n, RI_values(i));
    else
        fprintf('%d\t%.4f\t\t', n, RI_values(i));
    end
end

%% 6. 与Saaty 2008版RI对比（n=3~10）
fprintf('\n==================== n=3~10的RI值对比（与Saaty 2008版） ====================\n');
fprintf('阶数n\t本次计算RI\tSaaty 2008版RI\t相对误差\n');
for i = 1:8
    n = 2 + i;
    calc_RI = RI_values(i);
    standard_RI = Saaty_2008_RI(i);
    rel_error = abs(calc_RI - standard_RI) / standard_RI * 100;
    fprintf('%d\t%.4f\t\t%.4f\t\t%.2f%%\n', n, calc_RI, standard_RI, rel_error);
end

