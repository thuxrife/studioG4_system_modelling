%% Final Custom Proof: Pin Rod Dynamics with New Tolerance & RPM
clear; clc; close all;

% --- 1. Constant Times (Locked Trapezoidal Profile: 0.8s each) ---
ta = 1; tc = 1; td = 1;
Tw = ta + tc + td; 

% --- 2. Data from SolidWorks (g, mm, g*mm^2) ---
m_g = 165;              
L_mm = 99;              
r_com_mm = 28.81;       
Izz_g_mm2 = 151977.27;  

% --- Conversion to SI Units (kg, m, kg*m^2) ---
m = m_g / 1000;          
L = L_mm / 1000;         
r_com = r_com_mm / 1000; 
Izz = Izz_g_mm2 / 10^9; 

% --- 3. Other Parameters ---
r_arm = 0.5;            % แขนหุ่นยนต์ยาว 0.5 m
theta_total = 2 * pi;   % Worst Case: หมุน 360 องศา
zeta = 0.02;            % Damping Ratio
g = 9.81;

% NEW: เกณฑ์ Tolerance ล่าสุด (0.975 mm @ 0.5 m)
linear_tol_mm = 0.975;
phi_limit_deg = rad2deg(linear_tol_mm / (r_arm * 1000)); % 0.1117 องศา

% --- 4. Trajectory & Dynamics Calculation ---
alpha_max = theta_total / (ta * (ta + tc)); 
wn = sqrt((m * g * r_com) / Izz); 
dt = 0.001; 
t = 0:dt:Tw + 10; % ขยายเวลาดูการแกว่งยาวขึ้น

alpha_t = zeros(size(t));
for i = 1:length(t)
    if t(i) <= ta
        alpha_t(i) = alpha_max;
    elseif t(i) > ta && t(i) <= (ta + tc)
        alpha_t(i) = 0;
    elseif t(i) > (ta + tc) && t(i) <= Tw
        alpha_t(i) = -alpha_max;
    else
        alpha_t(i) = 0;
    end
end

% NEW: คำนวณความเร็วเชิงมุมและแปลงเป็น RPM
omega_t = cumtrapz(t, alpha_t);
rpm_t = omega_t * (60 / (2 * pi));

% --- 5. Transfer Function Simulation ---
b = 2 * zeta * wn * Izz;
num = [-(m * r_arm * r_com)];
den = [Izz, b, (m * g * r_com)];
sys = tf(num, den);
[phi, t_out] = lsim(sys, alpha_t, t);
phi_deg = rad2deg(phi);

% --- 6. Analysis Calculation ---
idx_stop = find(t >= Tw, 1);
phi_at_stop_deg = phi_deg(idx_stop);
linear_error_at_stop = abs(phi(idx_stop) * L * 1000); % mm

% --- 7. Visualization (Added RPM & New Tolerance) ---
fig = figure('Color', 'w', 'Position', [100 100 1000 800]);

% กราฟ 1: Velocity Profile (RPM)
subplot(3,1,1);
plot(t, rpm_t, 'r', 'LineWidth', 1.5); grid on;
ylabel('Arm Velocity (RPM)');
title(sprintf('Robot Arm Velocity Profile (Peak: %.2f RPM)', max(rpm_t)));
xlim([0 Tw + 5]);

% กราฟ 2: Acceleration
subplot(3,1,2);
plot(t, alpha_t, 'k', 'LineWidth', 1.5); grid on;
ylabel('Accel (rad/s^2)');
title(['Input: Robot Arm Acceleration (Worst Case: 360^\circ, \alpha_{max} = ', num2str(alpha_max, '%.2f'), ')']);
xlim([0 Tw + 5]);

% กราฟ 3: Rod Response
subplot(3,1,3);
plot(t, phi_deg, 'b', 'LineWidth', 1.5); hold on;

% พื้นที่ยอมรับตามเกณฑ์ใหม่ (0.1117 องศา)
patch([0 t(end) t(end) 0], [-phi_limit_deg -phi_limit_deg phi_limit_deg phi_limit_deg], ...
      [0.8 1 0.8], 'FaceAlpha', 0.5, 'EdgeColor', 'none');

% เส้นสีแดงแสดงจุดที่หุ่นยนต์หยุด
y_limit = max(abs(phi_deg)) * 1.3;
line([Tw Tw], [-y_limit y_limit], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 2);

grid on; ylabel('Rod Swing (deg)'); xlabel('Time (seconds)');
title(['Output: Rod Oscillation (New Tolerance: ', num2str(phi_limit_deg, '%.4f'), '^\circ)']);
xlim([0 Tw + 5]); ylim([-y_limit y_limit]);
legend('Rod Swing', 'Tolerance Zone (0.975mm@0.5m)', 'Robot Stop');

% --- 8. Display Results in Command Window ---
fprintf('\n================ ANALYSIS SUMMARY (360 DEG CASE) ================\n');
fprintf('Peak Velocity:      %.2f RPM\n', max(rpm_t));
fprintf('Alpha Max:          %.4f rad/s^2\n', alpha_max);
fprintf('Target Tolerance:   +/- %.4f degrees\n', phi_limit_deg);
fprintf('Final Angle Error:  %.4f degrees\n', phi_at_stop_deg);
fprintf('Error Ratio:        %.1f times over limit\n', abs(phi_at_stop_deg)/phi_limit_deg);

if abs(phi_at_stop_deg) > phi_limit_deg
    fprintf('STATUS:             FAILED\n');
else
    fprintf('STATUS:             PASSED\n');
end
fprintf('==================================================================\n');