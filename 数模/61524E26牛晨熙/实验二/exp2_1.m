clear;clc;close all;

%% ===================== 1. 输入原始数据 =====================
% x：时间序号，1=2024年1月，26=2026年2月
x = 1:26;
y = [100.0, 101.7, 106.1, 108.7, 109.8, 111.1, 113.2, 109.8, 111.0, 113.2, 115.2, 116.9, ...
     119.9, 121.9, 124.3, 134.4, 137.2, 138.5, 139.4, 140.5, 142.3, 143.6, 144.2, 146.0, ...
     147.9, 149.6];
% 待预测的时间点：27=2026.3 到 31=2026.7
x_pred = 27:31;
month_name = {'2026年3月','2026年4月','2026年5月','2026年6月','2026年7月'};
y_mean = mean(y);
SST = sum((y - y_mean).^2);  % 总平方和，用于拟合优度计算

%% ===================== 2. 差分法确定最优多项式阶数 =====================
fprintf('===== 差分法确定多项式最优阶数 =====\n');
max_order = 5;  % 最大测试阶数
diff_std = zeros(1, max_order); % 存储各阶差分的标准差

for k = 1:max_order
    diff_k = diff(y, k); % 计算k阶差分
    diff_std(k) = std(diff_k); % 计算差分的标准差，衡量波动
    fprintf('%d阶差分 标准差(波动)：%.4f\n', k, diff_std(k));
end

% 确定最优阶数：波动最小且最接近常数的阶数
[min_diff, best_order] = min(diff_std);
fprintf('最优拟合阶数：%d阶（差分波动最小）\n\n', best_order);

%% ===================== 3. 多项式拟合 (移除1阶，保留2阶、3阶、最优阶) =====================
% 方法1：2阶多项式拟合
p2 = polyfit(x, y, 2);
y2_fit = polyval(p2, x);
y2_pred = polyval(p2, x_pred);
SSE2 = sum((y - y2_fit).^2);
R2_2 = 1 - SSE2/SST;

% 方法2：3阶多项式拟合
p3 = polyfit(x, y, 3);
y3_fit = polyval(p3, x);
y3_pred = polyval(p3, x_pred);
SSE3 = sum((y - y3_fit).^2);
R2_3 = 1 - SSE3/SST;

% 方法3：差分法确定的最优阶数多项式拟合
p_best = polyfit(x, y, best_order);
y_best_fit = polyval(p_best, x);
y_best_pred = polyval(p_best, x_pred);
SSE_best = sum((y - y_best_fit).^2);
R2_best = 1 - SSE_best/SST;

%% ===================== 4. 非多项式拟合（指数拟合） =====================
% 指数模型：y = a * exp(b*x)，线性化处理：ln(y) = ln(a) + b*x
p_exp = polyfit(x, log(y), 1); 
b = p_exp(1);
a = exp(p_exp(2)); 

% 拟合值与预测值
y_exp_fit = a * exp(b * x);
y_exp_pred = a * exp(b * x_pred);

% 指数拟合优度
SSE_exp = sum((y - y_exp_fit).^2);
R2_exp = 1 - SSE_exp/SST;

%% ===================== 5. 预测结果与拟合优度输出 =====================
fprintf('===== 2026年3-7月物价指数预测结果 =====\n');
fprintf('月份\t\t2阶拟合\t\t3阶拟合\t%d阶最优拟合\t指数拟合\n', best_order);
for i = 1:5
    fprintf('%s\t%.2f\t\t%.2f\t\t%.2f\t\t%.2f\n', ...
        month_name{i}, y2_pred(i), y3_pred(i), y_best_pred(i), y_exp_pred(i));
end

fprintf('\n===== 各方法拟合优度R²（越接近1越好） =====\n');
fprintf('2阶多项式拟合R²：\t%.4f\n', R2_2);
fprintf('3阶多项式拟合R²：\t%.4f\n', R2_3);
fprintf('%d阶最优拟合R²：\t%.4f\n', best_order, R2_best);
fprintf('指数拟合R²：\t\t%.4f\n', R2_exp);

%% ===================== 6. 结果可视化（精简版，无1阶曲线） =====================
figure('Name','物价指数拟合与预测（精简优化版）','Color','w','Position',[100,100,1000,600]);
hold on; grid on; box on;

% 原始数据
plot(x, y, 'ko-', 'LineWidth',1.5, 'MarkerSize',7, 'DisplayName','原始物价指数');

% 拟合曲线（2阶、3阶、最优阶、指数）
plot(x, y2_fit, 'g--', 'LineWidth',1.5, 'DisplayName','2阶多项式拟合');
plot(x, y3_fit, 'b--', 'LineWidth',1.5, 'DisplayName','3阶多项式拟合');
plot(x, y_best_fit, 'm-', 'LineWidth',2.0, 'DisplayName',sprintf('%d阶最优拟合',best_order)); % 加粗最优线
plot(x, y_exp_fit, 'c-.', 'LineWidth',1.5, 'DisplayName','指数拟合');

% 预测值标记
plot(x_pred, y2_pred, 'gs', 'MarkerFaceColor','g', 'MarkerSize',8, 'DisplayName','2阶预测值');
plot(x_pred, y3_pred, 'bs', 'MarkerFaceColor','b', 'MarkerSize',8, 'DisplayName','3阶预测值');
plot(x_pred, y_best_pred, 'ms', 'MarkerFaceColor','m', 'MarkerSize',8, 'DisplayName','最优阶预测值');
plot(x_pred, y_exp_pred, 'cs', 'MarkerFaceColor','c', 'MarkerSize',8, 'DisplayName','指数预测值');

% 图表设置
xlabel('时间序号（1=2024年1月）','FontSize',12);
ylabel('物价指数','FontSize',12);
title('物价指数拟合与预测结果（多项式+指数非多项式拟合）','FontSize',14);
% 图例布局优化
legend('Location','southeast','FontSize',10,'NumColumns',2);
set(gca, 'XLim', [0 32], 'YLim', [95 170]);