%% --- 1. SETUP PATHS AND PARAMETERS ---
base_path = 'C:\Users\User\Documents\GitHub\FRA233_Lab1_G04\PART2_studyV4_Synced_Speed\';

% The names must match your Excel file prefixes exactly
wave_names = {'Step', 'Ramp', 'Stair', 'Sine', 'Chirp'}; 

folders = {'part2_Step_1_2026-02-06_20-23', ...
           'part2_Ramp_1_2026-02-06_20-25', ...
           'part2_Stair_1_2026-02-06_20-26', ...
           'part2_Sine_1_2026-02-06_20-32', ...
           'part2_Chirp_1_2026-02-06_20-35'};

% --- FILTER TOGGLE ---
use_filter = false; % Recommended: set to true for better Parameter Estimation
fc = 50;           

%% --- 2. AUTOMATED PROCESSING LOOP ---
fprintf('\n--- Processing Multi-Signal Data (Filter: %s) ---\n', string(use_filter));

for i = 1:5
    % LOGIC: Construct the filename using the wave_name (e.g., 'Step_Data.xlsx')
    filename = [wave_names{i}, '_Synced.xlsx'];
    current_file = fullfile(base_path, folders{i}, filename);
    
    % Read the data
    T_temp = readtable(current_file);
    
    time_data = T_temp.Time_sec;
    volt_data = T_temp.Voltage_V;
    speed_data = T_temp.Speed_rad_s;
    
    if use_filter
        fs = 1 / (time_data(2) - time_data(1)); %
        [b, a] = butter(2, fc/(fs/2), 'low'); %
        final_speed = filtfilt(b, a, speed_data); %
    else
        final_speed = speed_data;
    end
    
    % Export to workspace
    eval(['exp', num2str(i), '_time = time_data;']);
    eval(['exp', num2str(i), '_input = volt_data;']);
    eval(['exp', num2str(i), '_output = final_speed;']);
    
    fprintf('Done: Experiment %d (%s)\n', i, wave_names{i});
end

%% --- 3. COPY-PASTE HELPER (ARRAY NOTATION) ---
fprintf('\n--- COPY-PASTE THESE INTO PARAMETER ESTIMATOR ---\n');
for i = 1:5
    fprintf('Experiment %d (%s) Setup:\n', i, wave_names{i});
    fprintf('  Inputs:  [exp%d_time, exp%d_input]\n', i, i);
    fprintf('  Outputs: [exp%d_time, exp%d_output]\n', i, i);
    fprintf('------------------------------------------\n');
end