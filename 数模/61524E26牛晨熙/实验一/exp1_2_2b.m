% 层次分析法(AHP)实现：手机品牌选购决策
format shortG;

%% 1. 输入判断矩阵
% 目标层-准则层判断矩阵A (6阶)
A = [1,    3,      3,      2,      2,      4;
     1/3,  1,      1/2,    1/2,    1/3,    2;
     1/3,  2,      1,      1,      1/2,    2;
     1/2,  2,      1,      1,      1/2,    2;
     1/2,  3,      2,      2,      1,      3;
     1/4,  1/2,    1/2,    1/2,    1/3,    1];

% 准则层-方案层判断矩阵
B{1} = [1,    2,      2,      1/2;    % B1-硬件性能
        1/2,  1,      1,      1/3;
        1/2,  1,      1,      1/3;
        2,    3,      3,      1];

B{2} = [1,    1/2,    1/2,    3;      % B2-价格性价比
        2,    1,      1,      4;
        2,    1,      1,      4;
        1/3,  1/4,    1/4,    1];

B{3} = [1,    2,      3,      1;      % B3-影像拍照能力
        1/2,  1,      2,      1/2;
        1/3,  1/2,    1,      1/3;
        1,    2,      3,      1];

B{4} = [1,    1/2,    1/2,    3;      % B4-续航与快充
        2,    1,      1,      4;
        2,    1,      1,      4;
        1/3,  1/4,    1/4,    1];

B{5} = [1,    3,      3,      1/2;    % B5-系统与生态体验
        1/3,  1,      1,      1/4;
        1/3,  1,      1,      1/4;
        2,    4,      4,      1];

B{6} = [1,    2,      2,      1/2;    % B6-外观与品控
        1/2,  1,      1,      1/3;
        1/2,  1,      1,      1/3;
        2,    3,      3,      1];

% 高精度RI表
RI_table = [0, 0, 0.5203, 0.8911, 1.1107, 1.2504, 1.3498, 1.4005, 1.4497, 1.4902];

%% 2. AHP计算子函数
function [weight, lambda_max, CI, CR, is_pass] = ahp_calc(matrix, RI_table)
    n = size(matrix, 1); % 获取判断矩阵阶数
    % 处理特征值虚部问题：仅取实部计算
    eig_vals = eig(matrix);
    lambda_max = max(real(eig_vals)); 
    % 计算特征向量并归一化权重
    [V, D] = eig(matrix);
    idx = find(diag(D) == lambda_max, 1); % 精准匹配最大特征值对应列
    weight_vec = V(:, idx);
    weight = real(weight_vec) / sum(real(weight_vec)); % 确保权重为实数且归一化
    % 一致性检验
    if n == 1 || n == 2
        CI = 0; CR = 0; is_pass = true; % 1/2阶矩阵天然一致
    else
        CI = (lambda_max - n) / (n - 1);
        RI = RI_table(n); % 按阶数n索引对应RI值
        CR = CI / RI;
        is_pass = CR < 0.1;
    end
end

%% 3. 目标层-准则层计算
[weight_A, lambda_A, CI_A, CR_A, pass_A] = ahp_calc(A, RI_table);

%% 4. 准则层-方案层计算
weight_B = cell(6,1);
CR_B = zeros(6,1); % 存储各准则层矩阵的CR值，验证一致性
for j = 1:6
    [w_j, lambda_j, CI_j, CR_j, pass_j] = ahp_calc(B{j}, RI_table);
    weight_B{j} = w_j;
    CR_B(j) = CR_j;
end

%% 5. 层次总排序
brand_name = {'华为','小米','荣耀','苹果'};
total_weight = zeros(4,1);
for i = 1:4
    for j = 1:6
        total_weight(i) = total_weight(i) + weight_A(j) * weight_B{j}(i);
    end
end
[weight_sorted, sort_idx] = sort(total_weight, 'descend');

%% 6. 结果输出（完整可视化输出）
fprintf('==================== 目标层-准则层计算结果 ====================\n');
fprintf('判断矩阵阶数：%d\n', size(A,1));
fprintf('最大特征值λ_max：%.4f\n', lambda_A);
fprintf('一致性指标CI：%.4f\n', CI_A);
fprintf('一致性比例CR：%.4f\n', CR_A);
% 修正第98行：一致性检验结果输出
if pass_A
    fprintf('一致性检验结果：通过\n');
else
    fprintf('一致性检验结果：未通过\n');
end
fprintf('准则层权重（B1-B6）：\n');
fprintf('硬件性能\t价格性价比\t影像拍照\t续航快充\t系统生态\t外观品控\n');
fprintf('%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n', weight_A');

fprintf('\n==================== 准则层-方案层一致性检验 ====================\n');
fprintf('准则B1-B6的CR值：\n');
fprintf('%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n', CR_B');
if all(CR_B < 0.1)
    fprintf('所有准则层矩阵一致性检验：全部通过\n');
else
    fprintf('所有准则层矩阵一致性检验：部分未通过\n');
end

fprintf('\n==================== 方案层综合排序结果 ====================\n');
fprintf('排名\t品牌\t综合权重\n');
for k = 1:4
    fprintf('%d\t%s\t%.4f\n', k, brand_name{sort_idx(k)}, weight_sorted(k));
end