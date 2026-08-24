%% ================== 物价指数拟合（最终修正版·无异常曲线）==================
clear; clc; close all;

%% 1. 数据定义
price = [100.0,101.7,106.1,108.7,109.8,111.1,113.2,109.8,111.0,113.2,115.2,116.9,...
         119.9,121.9,124.3,134.4,137.2,138.5,139.4,140.5,142.3,143.6,144.2,146.0,...
         147.9,149.6];
x = 1:length(price);          % 原始时间 1-26
x_pred = 27:31;               % 预测时间 27-31
x_full = 1:31;                % 全时间轴（完整拟合曲线）

% 时间标签
time_str = {'2024.1','2024.2','2024.3','2024.4','2024.5','2024.6','2024.7','2024.8','2024.9','2024.10','2024.11','2024.12',...
            '2025.1','2025.2','2025.3','2025.4','2025.5','2025.6','2025.7','2025.8','2025.9','2025.10','2025.11','2025.12',...
            '2026.1','2026.2'};
time_pred = {'2026.3','2026.4','2026.5','2026.6','2026.7'};
time_full = [time_str, time_pred];

%% ================== 2. 四种拟合/预测方法（最终修正版·无异常） ==================
% ----------------- 方法1：线性拟合（匀速上涨，无异常）-----------------
p1 = polyfit(x, price, 1);
fit1 = polyval(p1, x_full);   % 全周期拟合+预测
fprintf('方法1：线性拟合 → y=%.3fx+%.3f\n',p1(1),p1(2));

% ----------------- 方法2：二次多项式拟合（加速上涨，无异常）-----------------
p2 = polyfit(x, price, 2);
fit2 = polyval(p2, x_full);   % 全周期拟合+预测
fprintf('方法2：二次拟合 → y=%.4fx²+%.3fx+%.3f\n',p2(1),p2(2),p2(3));

% ----------------- 方法3：霍尔特双参数指数平滑（Holt，优化初始值）-----------------
alpha = 0.8;  % 水平平滑系数（侧重近期水平）
beta = 0.2;   % 趋势平滑系数（侧重近期趋势）
L = zeros(size(price)); % 水平项
b = zeros(size(price)); % 趋势项
% 优化初始值：用前3个月的平均趋势初始化，避免初始偏差
L(1) = price(1);
b(1) = mean(diff(price(1:3))); % 用前3个月的平均环比作为初始趋势
for i = 2:length(price)
    L(i) = alpha * price(i) + (1 - alpha) * (L(i-1) + b(i-1)); % 更新水平
    b(i) = beta * (L(i) - L(i-1)) + (1 - beta) * b(i-1);       % 更新趋势
end
% 预测：未来k期 = L(end) + k*b(end)
fit3 = zeros(size(x_full));
fit3(1:length(price)) = L; % 历史拟合值（水平项，更贴合原始数据）
for k = 1:length(x_pred)
    fit3(length(price)+k) = L(end) + k * b(end); % 预测值（带趋势）
end
fprintf('方法3：霍尔特指数平滑（α=%.1f, β=%.1f），最终趋势=%.3f/月\n',alpha,beta,b(end));

% ----------------- 方法4：滚动加权移动平均+趋势外推（彻底修正初始化）-----------------
weights = [0.1, 0.3, 0.6]; % 近3个月权重（和为1，越近权重越高）
wma_hist = zeros(size(price));
% 修正1：前2个月用原始数据填充，避免0值
wma_hist(1:2) = price(1:2);
% 修正2：从第3个月开始，用3个月的加权和计算滚动WMA
for i = 3:length(price)
    wma_hist(i) = sum(price(i-2:i) .* weights);
end
% 用最后3个月的WMA计算趋势（斜率，每月平均变化）
trend_wma = (wma_hist(end) - wma_hist(end-2)) / 2;
% 预测：未来k期 = wma_hist(end) + k*trend_wma
fit4 = zeros(size(x_full));
fit4(1:length(price)) = wma_hist; % 历史WMA（无异常）
for k = 1:length(x_pred)
    fit4(length(price)+k) = wma_hist(end) + k * trend_wma; % 带趋势预测
end
fprintf('方法4：滚动加权移动平均，最终趋势=%.3f/月\n',trend_wma);

%% 3. 提取预测结果
pred1 = fit1(x_pred);
pred2 = fit2(x_pred);
pred3 = fit3(x_pred);
pred4 = fit4(x_pred);

%% 4. 输出预测结果对比
fprintf('\n========== 2026年3-7月 最终预测结果 ==========\n');
fprintf('时间\t线性拟合\t二次拟合\t霍尔特平滑\t滚动WMA\n');
for i = 1:length(x_pred)
    fprintf('%s\t%.2f\t\t%.2f\t\t%.2f\t\t%.2f\n',...
        time_pred{i},pred1(i),pred2(i),pred3(i),pred4(i));
end

%% ================== 5. 绘制完整拟合曲线（无异常·全贴合） ==================
figure('Position',[100,100,1200,600]);
hold on; grid on; box on;

% 原始数据（黑色空心圆，和原图一致）
plot(x, price, 'ko', 'LineWidth',2,'MarkerSize',8,'DisplayName','原始数据');

% 完整拟合曲线（无异常）
plot(x_full, fit1, 'r-', 'LineWidth',2.5, 'DisplayName','线性拟合曲线');
plot(x_full, fit2, 'b-', 'LineWidth',2.5, 'DisplayName','二次拟合曲线');
plot(x_full, fit3, 'g-', 'LineWidth',2.5, 'DisplayName','霍尔特指数平滑曲线');
plot(x_full, fit4, 'm--', 'LineWidth',2, 'DisplayName','滚动加权移动平均');

% 图表样式优化
title('物价指数全周期拟合曲线（最终修正版·2024.1-2026.7）','FontSize',16);
xlabel('时间','FontSize',14); ylabel('物价指数','FontSize',14);
xticks(x_full); xticklabels(time_full); xtickangle(45);
legend('Location','northwest','FontSize',12);
set(gca,'FontSize',12);

%% 6. 环比同比图（保留实验要求）
figure('Position',[100,100,1000,400]);
mom = NaN(size(price)); mom(2:end) = price(2:end)./price(1:end-1)*100;
yoy = NaN(size(price)); yoy(13:end) = price(13:end)./price(1:end-12)*100;
plot(x, mom, 'r-o', x, yoy, 'g-s','LineWidth',1.5);
title('环比/同比物价指数','FontSize',14);
xlabel('时间','FontSize',12); ylabel('指数(%)','FontSize',12);
legend('环比指数','同比指数','FontSize',12); xtickangle(45); grid on;