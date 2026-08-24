% Gompertz模型
clear; clc; close all;

%% 1. 全量数据（1998-2023）
t = 0:25;
year = 1998:2023;
x = [7.85, 8.1, 8.6, 8.9, 9.5, 11, 15.2, 20, 26.2, 33.27, 43.41, 62.06, ...
     101.72, 131.15, 170.73, 217.69, 296.39, 400.5, 457.12, 559.11, 609.76, 642.66, ...
     204.17, 472.58, 300.67, 549.15];

%% 2. 定义Gompertz解析解模型
x0 = x(1);
gompertz_fun = @(params, t) params(1) * exp( log(x0/params(1)) * exp(-params(2)*t) );
%% 3. 非线性最小二乘拟合
params0 = [700, 0.1];  % 合理初始值：xm=700亿，λ=0.1
params_fit = lsqcurvefit(gompertz_fun, params0, t, x);
xm_fit = params_fit(1);
lambda_fit = params_fit(2);

% 拟合优度R²
x_fit = gompertz_fun(params_fit, t);
y_mean = mean(x);
SS_res = sum((x - x_fit).^2);
SS_tot = sum((x - y_mean).^2);
R2 = 1 - SS_res / SS_tot;

fprintf('===== 非线性最小二乘Gompertz模型参数=====\n');
fprintf('饱和上限 xm = %.2f 亿元\n', xm_fit);
fprintf('固有增长率 λ = %.4f\n', lambda_fit);
fprintf('拟合优度 R² = %.4f\n\n', R2);

%% 4. 预测2024-2030
t_pred = 26:32;
year_pred = 2024:2030;
x_pred = gompertz_fun(params_fit, t_pred);

%% 5. 绘图
figure('Color','w','Position',[100,100,1000,600]);
ax = gca;
ax.YAxis.Exponent = 0;  6
plot(year, x, 'bo-', 'LineWidth',1.5, 'MarkerSize',6, 'DisplayName','历史票房（1998-2023）');
hold on;
plot(year, x_fit, 'r--', 'LineWidth',2, 'DisplayName','Gompertz拟合曲线');
plot(year_pred, x_pred, 'gs-', 'LineWidth',2, 'MarkerSize',8, 'DisplayName','2024-2030预测票房');
yline(xm_fit, 'k:', 'LineWidth',1.5, 'DisplayName',sprintf('饱和上限 x_m=%.2f亿元',xm_fit));

xlabel('年份','FontSize',12,'FontWeight','bold');
ylabel('中国电影总票房（亿元）','FontSize',12,'FontWeight','bold');
title('Gompertz模型：中国电影票房拟合与预测','FontSize',14,'FontWeight','bold');
legend('Location','best','FontSize',11);
grid on; grid minor;
xlim([1997,2031]);
ylim([0, xm_fit*1.1]);

% 输出预测结果
fprintf('===== 2024-2030年票房预测=====\n');
for i = 1:length(year_pred)
    fprintf('%d年：%.2f 亿元\n', year_pred(i), x_pred(i));
end