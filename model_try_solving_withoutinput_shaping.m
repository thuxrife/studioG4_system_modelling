%% Final Feasibility Study: Fully Time-Synced Settling Analysis (Fixed Syntax)
clear; clc; close all;

% --- 1. ข้อมูลทางกายภาพ (Immutable Physical Data) ---
m_g = 165; L_mm = 99; r_com_mm = 28.81; Izz_g_mm2 = 151977.27;
m = m_g/1000; L = L_mm/1000; r_com = r_com_mm/1000; Izz = Izz_g_mm2/10^9;
r_arm = 0.5;                
theta_total = 2*pi;         
zeta = 0.02; g = 9.81;

% เกณฑ์ Tolerance: 0.975 mm @ 0.5 m (0.1117 องศา)
linear_tol_mm = 0.975;
phi_limit_deg = rad2deg(linear_tol_mm / (r_arm * 1000)); 

% ระบบพลศาสตร์
wn = sqrt((m * g * r_com) / Izz);
b = 2 * zeta * wn * Izz;
num = [-(m * r_arm * r_com)];
den = [Izz, b, (m * g * r_com)];
sys = tf(num, den);

% --- 2. การค้นหาชุดเวลา (Optimized Search) ---
Tw_limit = 3.0; 
res = 0.05;     
best_ts = inf;
best_params = [0, 0, 0];
t_sim_end = 40; 
dt = 0.01; 
t_sim = 0:dt:t_sim_end;

fprintf('วิเคราะห์หา Settling Time ที่ดีที่สุด (Time-Synced at 3.0s)...\n');

for ta = 0.1 : res : 1.2
    for tc = 0.1 : res : (Tw_limit - ta - 0.1)
        td = Tw_limit - ta - tc;
        
        alpha_acc = theta_total / (0.5*ta^2 + ta*tc + 0.5*ta*td);
        alpha_dec = -(alpha_acc * ta) / td;
        
        % สร้าง Input Profile แบบ Sync
        mask_acc = (t_sim <= ta);
        mask_dec = (t_sim > (ta + tc) & t_sim <= Tw_limit);
        input_t = (mask_acc * alpha_acc) + (mask_dec * alpha_dec);
        
        [phi, ~] = lsim(sys, input_t, t_sim);
        phi_d = rad2deg(abs(phi));
        
        % แก้ไขจุดที่ใช้เครื่องหมาย ? เป็น if-else
        idx_last_exit = find(phi_d > phi_limit_deg, 1, 'last');
        if isempty(idx_last_exit)
            current_ts = 0;
        else
            current_ts = t_sim(idx_last_exit);
        end
        
        if current_ts < best_ts
            best_ts = current_ts;
            best_params = [ta, tc, td];
        end
    end
end

% --- 3. การสร้างข้อมูล Final เปรียบเทียบ ---
t_f = 0:0.005:t_sim_end;

% กรณี Optimized
ta_f = best_params(1); tc_f = best_params(2); td_f = best_params(3);
a_acc_f = theta_total / (0.5*ta_f^2 + ta_f*tc_f + 0.5*ta_f*td_f);
a_dec_f = -(a_acc_f * ta_f) / td_f;

acc_opt = ((t_f <= ta_f) * a_acc_f) + ((t_f > (ta_f + tc_f) & t_f <= Tw_limit) * a_dec_f);

% กรณี Standard (เลื่อนให้จบที่ 3.0s พร้อมกัน)
ta_std = 0.8; tc_std = 0.8; td_std = 0.8;
Tw_std = ta_std + tc_std + td_std; 
std_offset = Tw_limit - Tw_std; 
a_std = theta_total / (ta_std * (ta_std + tc_std));

acc_std = ((t_f > std_offset & t_f <= (std_offset + ta_std)) * a_std) + ...
          ((t_f > (std_offset + ta_std + tc_std) & t_f <= Tw_limit) * (-a_std));

% --- 4. Simulation & RPM Calculation ---
rpm_std = cumtrapz(t_f, acc_std) * (60 / (2*pi));
rpm_opt = cumtrapz(t_f, acc_opt) * (60 / (2*pi));

[phi_std, ~] = lsim(sys, acc_std, t_f);
[phi_opt, ~] = lsim(sys, acc_opt, t_f);

% --- 5. Visualization (Synced Plots) ---
figure('Color', 'w', 'Position', [100 100 1000 850]);

subplot(3,1,1);
plot(t_f, rpm_std, 'k:', 'LineWidth', 1.2); hold on;
plot(t_f, rpm_opt, 'r', 'LineWidth', 1.5);
xline(Tw_limit, 'r--', '3.0s Stop Point');
grid on; ylabel('Velocity (RPM)'); title('Synced Velocity Profile (All stop at 3.0s)');
legend('Standard (Shifted)', 'Optimized'); xlim([0 5]);

subplot(3,1,2);
plot(t_f, acc_std, 'k:', 'LineWidth', 1.2); hold on;
plot(t_f, acc_opt, 'k', 'LineWidth', 1.5);
xline(Tw_limit, 'r--', '3.0s End');
grid on; ylabel('Acc (rad/s^2)'); title('Acceleration Profile Sync');
xlim([0 5]);

subplot(3,1,3);
plot(t_f, rad2deg(phi_std), 'k:', 'LineWidth', 1); hold on;
plot(t_f, rad2deg(phi_opt), 'b', 'LineWidth', 2);
patch([0 t_sim_end t_sim_end 0], [-phi_limit_deg -phi_limit_deg phi_limit_deg phi_limit_deg], ...
      [0.8 1 0.8], 'FaceAlpha', 0.5, 'EdgeColor', 'none');
xline(Tw_limit, 'r--', 'LineWidth', 2);
if best_ts < t_sim_end
    scatter(best_ts, 0, 80, 'filled', 'MarkerFaceColor', 'm');
end
grid on; ylabel('Swing Angle (Deg)'); xlabel('Time (s)');
title(['Settling Time Analysis (Best Ts = ', num2str(best_ts, '%.2f'), ' s)']);
xlim([0 t_sim_end]); ylim([-40 40]);
legend('Standard Osc.', 'Optimized Osc.', 'Tolerance Zone');

% สรุปผล
fprintf('\n================== SYNCED FEASIBILITY REPORT ==================\n');
fprintf('Target Tolerance:       +/- %.4f degrees\n', phi_limit_deg);
fprintf('Best Settling Time:     %.2f seconds\n', best_ts);
fprintf('Conclusion: ');
if best_ts > 3.0
    fprintf('UNFEASIBLE (Wait %.2f s extra)\n', best_ts - 3.0);
else
    fprintf('FEASIBLE\n');
end
fprintf('==============================================================\n');