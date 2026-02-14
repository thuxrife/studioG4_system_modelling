%% ZV Input Shaper: Fully Time-Synced (Aligned Ends at 3.0s)
clear; clc; close all;

% --- 1. ข้อมูลทางกายภาพ ---
m_g = 165; L_mm = 99; r_com_mm = 28.81; Izz_g_mm2 = 151977.27;
m = m_g/1000; L = L_mm/1000; r_com = r_com_mm/1000; Izz = Izz_g_mm2/10^9;
r_arm = 0.5; theta_total = 2*pi; zeta = 0.02; g = 9.81;

% เกณฑ์ Tolerance: 0.975 mm @ 0.5 m (0.1117 องศา)
phi_limit_deg = rad2deg(0.975 / (r_arm * 1000)); 

% Dynamics
wn = sqrt((m * g * r_com) / Izz);
wd = wn * sqrt(1 - zeta^2); 
K = exp(-zeta * pi / sqrt(1 - zeta^2)); 

% --- 2. ZV Shaper Logic ---
T_delay = pi / wd; 
A1 = 1 / (1 + K); A2 = K / (1 + K);

% ตั้งเป้าหมาย: ทั้งสองระบบต้องหยุดนิ่งสมบูรณ์ที่ 3.0 วินาที
Tw_limit = 3.0; 
Tw_move_actual = Tw_limit - T_delay; % เวลาที่ใช้ในการเคลื่อนที่จริง

% แบ่งช่วงเวลา (ta, tc, td)
ta = Tw_move_actual / 3; tc = ta; td = ta; 
alpha_max = theta_total / (ta * (ta + tc));

% --- 3. Simulation Setup ---
dt = 0.001;
t = 0:dt:Tw_limit + 1.0; 
N = length(t);

% สร้าง Raw Command (เลื่อนจุดเริ่มเพื่อให้จบที่ 3.0s พร้อมกับ Shaped)
cmd_raw = zeros(size(t));
idx_start_offset = round(T_delay / dt); % เลื่อนจุดเริ่มของเส้นประ
for i = 1:N
    t_shifted = t(i) - T_delay; % อ้างอิงฐานเวลาเดียวกัน
    if t_shifted >= 0 && t_shifted <= ta
        cmd_raw(i) = alpha_max;
    elseif t_shifted > ta && t_shifted <= (ta + tc)
        cmd_raw(i) = 0;
    elseif t_shifted > (ta + tc) && t_shifted <= Tw_move_actual
        cmd_raw(i) = -alpha_max;
    end
end

% สร้าง ZV Shaped Command (เริ่มต้นที่ t=0 และจบที่ t=3.0)
% โดยนำคำสั่งพื้นฐาน (ที่เริ่มที่ t=0) มาผ่านกระบวนการ Shaping
cmd_base = zeros(size(t));
for i = 1:N
    if t(i) <= ta
        cmd_base(i) = alpha_max;
    elseif t(i) > ta && t(i) <= (ta + tc)
        cmd_base(i) = 0;
    elseif t(i) > (ta + tc) && t(i) <= Tw_move_actual
        cmd_base(i) = -alpha_max;
    end
end

idx_d = round(T_delay / dt);
cmd_shaped = A1 * cmd_base;
shifted_part = [zeros(1, idx_d), cmd_base(1:end-idx_d)];
cmd_shaped = cmd_shaped + A2 * shifted_part;

% --- 4. Simulation & RPM ---
omega_raw = cumtrapz(t, cmd_raw);
omega_shaped = cumtrapz(t, cmd_shaped);
rpm_raw = omega_raw * (60 / (2 * pi));
rpm_shaped = omega_shaped * (60 / (2 * pi));

sys = tf([-(m * r_arm * r_com)], [Izz, 2*zeta*wn*Izz, (m*g*r_com)]);
[phi_raw, ~] = lsim(sys, cmd_raw, t);
[phi_shaped, ~] = lsim(sys, cmd_shaped, t);

% --- 5. Visualization ---
figure('Color', 'w', 'Position', [100 100 1000 850]);

subplot(3,1,1); % Velocity Sync
plot(t, rpm_raw, 'k:', 'LineWidth', 1.5); hold on;
plot(t, rpm_shaped, 'r', 'LineWidth', 1.5);
xline(Tw_limit, 'r--', '3.0s Stop Point');
grid on; ylabel('Arm Velocity (RPM)'); title('Fully Synced Velocity Profile');
legend('Standard (Shifted Start)', 'ZV Shaped');

subplot(3,1,2); % Accel Sync
plot(t, cmd_raw, 'k:', 'LineWidth', 1.5); hold on;
plot(t, cmd_shaped, 'r', 'LineWidth', 1.5);
xline(Tw_limit, 'r--', '3.0s End');
grid on; ylabel('Accel (rad/s^2)'); title('Acceleration Sync: Both end at 3.0s');

subplot(3,1,3); % Response Sync
plot(t, rad2deg(phi_raw), 'k:', 'LineWidth', 1); hold on;
plot(t, rad2deg(phi_shaped), 'b', 'LineWidth', 2);
patch([0 t(end) t(end) 0], [-phi_limit_deg -phi_limit_deg phi_limit_deg phi_limit_deg], [0.8 1 0.8], 'FaceAlpha', 0.5, 'EdgeColor', 'none');
xline(Tw_limit, 'r--', 'LineWidth', 2);
grid on; ylabel('Rod Swing (Deg)'); xlabel('Time (s)');
title('Residual Vibration Sync'); xlim([0 4.0]);
legend('Raw Oscillation', 'Shaped Oscillation', 'Tolerance Zone');

% Check Results
idx_3s = find(t >= 3.0, 1);
fprintf('Error at 3.0s (Raw):    %.4f deg\n', abs(rad2deg(phi_raw(idx_3s))));
fprintf('Error at 3.0s (Shaped): %.4f deg\n', abs(rad2deg(phi_shaped(idx_3s))));