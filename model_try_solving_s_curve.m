%% ZV Input Shaper: Realistic Non-linear Bearing Rod Dynamics
clear; clc; close all;

% --- 1. ข้อมูลทางกายภาพ (Immutable) ---
m_g = 165; L_mm = 99; r_com_mm = 28.81; Izz_g_mm2 = 151977.27;
m = m_g/1000; L = L_mm/1000; r_com = r_com_mm/1000; Izz = Izz_g_mm2/10^9;
r_arm = 0.5; theta_total = 2*pi; zeta = 0.02; g = 9.81;
phi_limit_deg = rad2deg(0.975 / (r_arm * 1000)); 

% Dynamics Properties (Linearized for Shaper Design)
wn = sqrt((m * g * r_com) / Izz);
wd = wn * sqrt(1 - zeta^2); 
T_delay = pi / wd; 
A1 = 1 / (1 + exp(-zeta*pi/sqrt(1-zeta^2)));
A2 = 1 - A1;

% --- 2. S-Curve & Timing ---
Tw_limit = 3.0; 
Tw_move = Tw_limit - T_delay; 
ta = Tw_move/3; tc = ta; td = ta;
alpha_max = theta_total / (ta * (ta + tc));

% --- 3. Profile Generation ---
dt = 0.001; t = 0:dt:Tw_limit + 1.5;
gen_scurve = @(time, t_start, a_max) ...
    (time >= t_start & time < t_start + ta) .* (a_max * 0.5 * (1 - cos(2*pi*(time-t_start)/ta))) + ...
    (time >= t_start + ta + tc & time < t_start + ta + tc + td) .* (-a_max * 0.5 * (1 - cos(2*pi*(time-(t_start+ta+tc))/td)));

cmd_shaped = A1 * gen_scurve(t, 0, alpha_max) + A2 * gen_scurve(t, T_delay, alpha_max);
omega_arm = cumtrapz(t, cmd_shaped); % Angular velocity of Robot Arm

% --- 4. Non-linear Simulation (The "Real" Physics) ---
% Equation: Izz*phi'' + b*phi' + m*g*r_com*sin(phi) = -m*a_tan*r_com*cos(phi) + m*(omega^2*r_arm)*r_com*sin(phi)
b = 2 * zeta * wn * Izz;

% ODE function: y(1) = phi, y(2) = phi_dot
ode_fun = @(ts, y) [y(2); 
    ( -b*y(2) - m*g*r_com*sin(y(1)) ... % Gravity & Damping
      -m*interp1(t, cmd_shaped, ts)*r_arm*r_com*cos(y(1)) ... % Tangential Accel (Input)
      +m*(interp1(t, omega_arm, ts)^2 * r_arm)*r_com*sin(y(1)) ... % Centrifugal effect
    ) / Izz];

[t_ode, y_ode] = ode45(ode_fun, t, [0; 0]);
phi_real_deg = rad2deg(y_ode(:,1));

% --- 5. Visualization ---
figure('Color', 'w', 'Position', [100 100 1000 500]);
plot(t_ode, phi_real_deg, 'b', 'LineWidth', 2); hold on;
patch([0 t(end) t(end) 0], [-phi_limit_deg -phi_limit_deg phi_limit_deg phi_limit_deg], [0.8 1 0.8], 'FaceAlpha', 0.5, 'EdgeColor', 'none');
xline(Tw_limit, 'r--', 'LineWidth', 2);
grid on; ylabel('Rod Angle (Deg)'); xlabel('Time (s)');
title('Non-linear Realistic Rod Dynamics (With Centrifugal Effect)');
legend('Realistic Rod Swing', 'Tolerance Zone');