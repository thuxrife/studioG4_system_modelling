%{  
This script for prepare data and parameters for parameter estimator.
1. Load your collected data to MATLAB workspace.
2. Run this script.
3. Follow parameter estimator instruction.
%}

% R and L from experiment
motor_R = 0.02903225806;
motor_L = 0.00001451612903;
% Optimization's parameters
motor_Eff = 1.0;
motor_Ke = 0.5;
motor_J = 0.001;
motor_B = 0.001;

fprintf('Motor parameters loaded. You can now run Simulink.\n');