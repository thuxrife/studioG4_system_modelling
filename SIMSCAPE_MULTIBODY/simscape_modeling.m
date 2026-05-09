%% Robot Simulation Initialization Script
% Author: Gemini
% Model: 5-State DC Motor + Flexible/Pendulum Arm
% States: x = [theta; theta_dot; phi; phi_dot; i]

clear; clc;

%% 1. Sampling Times
% Match these to your Discrete PID or Solver settings
sampling_time_pos = 0.01;  % 100Hz Position Loop
sampling_time_vel = 0.001; % 1kHz Velocity Loop (and Kalman Filter)

%% 2. Physical Constants (Motor & Gearbox)
Rm = 2.5;       % Resistance (Ohm)
Lm = 0.01;      % Inductance (H)
Ke = 0.05;      % Back-EMF constant
Km = 0.05;      % Motor torque constant
n_total = 100;  % Gear ratio
Beq = 0.1;      % Equivalent damping
Jeq = 0.005;    % Equivalent inertia of drivetrain

%% 3. Robot Arm Physical Properties (The 10.28kg Load)
g = 9.81;
r_arm = 0.2;      % Pivot radius (m)
m_pole = 10.28;   % Mass from your SolidWorks data (kg)
L_COR = 1.0;      % Distance to Center of Mass (m)
L_pole = 2.0;     % Total length of arm (m)

% Moment of Inertia for a rod rotating about its end
J_pole = (1/3) * m_pole * L_pole^2; 

%% 4. Mass Matrix & Determinant (Kramer's Rule for Acceleration)
% Equation: M(q)*q_ddot + C*q_dot + G = Tau
a11 = Jeq + m_pole * r_arm^2;
a12 = m_pole * r_arm * L_COR;
a21 = a12;
a22 = J_pole + m_pole * L_COR^2;

delta = (a11 * a22) - (a12 * a21); % Determinant of the Mass Matrix

%% 5. State-Space Coefficients
% Acceleration of the Arm (theta_ddot)
A1 = (n_total * Km * a22) / delta;
A2 = (-Beq * a22) / delta;
A3 = (m_pole * g * L_COR * a12) / delta;

% Acceleration of the Internal State (phi_ddot)
B1 = (-m_pole * g * L_COR * a11) / delta;
B2 = (Beq * a21) / delta;
B3 = (n_total * Km * -a12) / delta;

%% 6. System Matrices (Plant & Reference Feed-Forward)
% Row 2 is theta_ddot, Row 4 is phi_ddot, Row 5 is i_dot
A = [0,  1,  0,  0,  0;
     0, A2, A3,  0, A1; 
     0,  0,  0,  1,  0;
     0, B2, B1,  0, B3; 
     0, -(n_total * Ke / Lm), 0, 0, -(Rm / Lm)];

B = [0; 0; 0; 0; 1/Lm];
C = [1, 0, 0, 0, 0]; % Measuring only theta (Angle)
D = 0;

% Reference Feed Forward (RFF) uses the same plant model
A_rff = A; B_rff = B; C_rff = C; D_rff = D;

%% 7. Kalman Filter Block Parameters
% Initial state estimate [theta, theta_dot, phi, phi_dot, i]
x0 = zeros(5,1); 

% Q: Process Noise Covariance (How much we trust the model)
% High value = less trust in model equations
Q_mat = diag([1e-6, 1e-4, 1e-6, 1e-4, 1e-3]); 

% R: Measurement Noise Covariance (12-bit Encoder)
% Resolution = 2*pi / 4096. Noise is typically (Resolution^2)
R_mat = (2*pi/4096)^2; 

% N: Cross-covariance (Set to zero)
N_mat = 0;

%% 8. Trajectory Parameters (Trapezoidal Profile)
Max_Vel = 2.0;    % rad/s
Max_Accel = 5.0;  % rad/s^2

disp('-------------------------------------------');
disp('Robot Simulation Variables Loaded:');
disp(['Arm Mass: ', num2str(m_pole), ' kg']);
disp(['Encoder Resolution: ', num2str(4096), ' bits']);
disp('-------------------------------------------');