% --- Parameter Definitions --- (แทนที่เลขสมมติเหล่านี้ด้วยค่าจริงของคุณ)
Rm = 2.5;       % Resistance (Ohm)
Lm = 0.01;      % Inductance (H)
Ke = 0.05;      % Back-EMF constant
Km = 0.05;      % Motor torque constant
n_total = 100;  % Gear ratio
Beq = 0.1;      % Equivalent damping
Jeq = 0.005;    % Equivalent inertia ของระบบขับเคลื่อน
r_arm = 0.2;    % รัศมีของแขนหุ่นยนต์ (m)

m_pole = 165e-3; % 0.165 kg
L_COR = 28.81e-3; % 0.02881 m
g = 9.81;
L_pole = 99e-3;
J_pole = (1/3)*m_pole*L_pole^2;

% --- Mass Matrix Elements ---
a11 = Jeq + m_pole * r_arm^2;
a12 = m_pole * r_arm * L_COR;
a21 = m_pole * L_COR * r_arm;
a22 = J_pole + m_pole * L_COR^2;
delta = a11 * a22 - a12 * a21; % Determinant ของ Mass Matrix

% --- A and B Coefficients ---
A1 = (n_total * Km * a22) / delta;
A2 = (-Beq * a22) / delta;
A3 = (m_pole * g * L_COR * a12) / delta;
B1 = (-m_pole * g * L_COR * a11) / delta;
B2 = (Beq * a21) / delta;
B3 = (n_total * Km * -a12) / delta;

% State: [theta, theta_dot, phi, phi_dot, I]
A = [0, 1, 0, 0, 0;
     0, A2, A3, 0, A1; % theta_ddot
     0, 0, 0, 1, 0;
     0, B2, B1, 0, B3; % phi_ddot
     0, -(n_total * Ke / Lm), 0, 0, -(Rm / Lm)]; % I_dot

B = [0; 0; 0; 0; 1/Lm];
C = [1, 0, 0, 0, 0]; % วัดเฉพาะตำแหน่ง theta
D = 0;

sys_plant = ss(A, B, C, D);

% Q matrix (5x5): [theta, theta_dot, phi, phi_dot, I]
Q = diag([1e4, 1, 1e5, 1, 0.1]); % เน้นคุม phi (ลูกตุ้ม) และ theta
R = 1; % น้ำหนักของ Voltage
K = lqr(A, B, Q, R); % จะได้ Matrix 1x5

% Covariance matrices
W = eye(5) * 1e-3; % Process noise (ความไม่แน่นอนของ Model)
V = 1e-4; % Measurement noise (ความละเอียด Encoder)

% สร้าง Kalman Filter
[kf_sys, L, P] = kalman(ss(A, [B eye(5)], C, [0 0 0 0 0 0]), W, V);
% L คือ Matrix 5x1 สำหรับ Correction Step

% Feedforward สำหรับชดเชย Back-EMF และ Resistance
Kv = (Rm * Beq / (n_total * Km)) + n_total * Ke;
Ka = (Rm * Jeq / (n_total * Km)); % ชดเชย Inertia