%% DIAGNOSTIC TEST: IS EFFICIENCY THE CULPRIT? (FIXED DATA READ)
clc; close all;
model_name = 'Lab1_parameter_estimation_student'; 

% 1. Load the Parameters that "failed"
if ~isfile('Params_Ramp.mat')
    error('Please make sure Params_Ramp.mat is in the current folder.');
end
load('Params_Ramp.mat'); 

% 2. Load Ramp Data (Update path if needed)
% Note: Using the path from your previous error log context
base_path = 'PART2_studyV3_12V\part2_Ramp_1_2026-02-03_20-34\';
file_name = 'Ramp_Data.xlsx';
full_path = fullfile(base_path, file_name);

if ~isfile(full_path)
    % Try looking in current folder if path is wrong
    full_path = 'Ramp_Data.xlsx'; 
end

T = readtable(full_path);
t_val = T.Time_sec;
u_val = T.Voltage_V;
y_real = T.Speed_rad_s;

% 3. SETUP SIMULATION - WITH A TWIST
in = Simulink.SimulationInput(model_name);
in = in.setVariable('motor_R', 2.780746939); 
in = in.setVariable('motor_L', 0.039595291);
in = in.setVariable('motor_J', motor_J);
in = in.setVariable('motor_B', motor_B);
in = in.setVariable('motor_Ke', motor_Ke);

% *** THE TEST: FORCE EFFICIENCY TO 1.0 (IGNORE 0.36) ***
fprintf('Testing with FORCED Efficiency = 100%% (Ignoring %.1f%%)...\n', motor_Eff*100);
in = in.setVariable('motor_Eff', 1.0); 

% Setup Input & Solver
assignin('base', 'u_sim_val', [t_val, u_val]);
in = in.setExternalInput('u_sim_val');
in = in.setModelParameter('SolverType','Fixed-step', 'Solver','ode14x', 'FixedStep','1e-3');
in = in.setModelParameter('StopTime', num2str(t_val(end)));
in = in.setModelParameter('ZeroCrossControl', 'DisableAll');

% 4. RUN
try
    simOut = sim(in);
    
    % *** FIX: Robust Data Extraction ***
    if isa(simOut.yout, 'Simulink.SimulationData.Dataset')
        % Newer format
        y_sim = simOut.yout.get(1).Values.Data;
        t_sim = simOut.yout.get(1).Values.Time;
    else
        % Older format
        y_sim = simOut.yout.signals(1).values;
        t_sim = simOut.tout;
    end
    
    % Interpolate to match exact time points
    y_sim = interp1(t_sim, y_sim, t_val, 'linear', 'extrap');

    % 5. PLOT
    figure('Color','w', 'Name', 'Diagnostic Check');
    plot(t_val, y_real, 'b', 'LineWidth', 2); hold on;
    plot(t_val, y_sim, 'r--', 'LineWidth', 2);
    legend('Experimental (Hardware)', 'Simulation (Forced Eff=1.0)');
    title(['Diagnostic: Does forcing Eff=1.0 fix the drop? (Orig Eff=' num2str(motor_Eff*100) '%)']);
    grid on;
    xlabel('Time (s)'); ylabel('Speed (rad/s)');
    
catch ME
    fprintf('Simulation Failed: %s\n', ME.message);
end