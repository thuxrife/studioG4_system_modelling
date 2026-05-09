%% --- 1. USER CONFIGURATION ---
% Choose your source: 'PART2' for hardware data, 'MODEL' for simulation data
SOURCE_TYPE = 'PART2'; 
% Order must match your Multiport Switch in Simulink
wave_names = {'Step', 'Ramp', 'Stair', 'Sine', 'Chirp'}; 
PARENT_FOLDER = 'PART2_studyV4';

%% --- 2. SELECT DATA SOURCE OBJECTS ---
switch SOURCE_TYPE
    case 'PART2'
        source_prefix = 'part2';
        if isprop(out, 'data') && isprop(out, 'mode')
            data_obj = out.data;      % Experimental sensors
            mode_obj = out.mode;      % Experimental mode selection
        else
            error('Experimental blocks (data/mode) not found in "out" object.');
        end
    case 'MODEL'
        source_prefix = 'model';
        if isprop(out, 'model_data') && isprop(out, 'model_mode')
            data_obj = out.model_data; % Simulation sensors
            mode_obj = out.model_mode; % Simulation mode selection
        else
            error('Simulation blocks (model_data/model_mode) not found in "out" object.');
        end
    otherwise
        error('Invalid SOURCE_TYPE. Set to ''PART2'' or ''MODEL''.');
end

% Get wave name based on the mode value
mode_val = mode_obj.Data(1);
current_wave = wave_names{mode_val};
if ~exist(PARENT_FOLDER, 'dir'), mkdir(PARENT_FOLDER); end

%% --- 3. GENERATE TIMESTAMP & AUTO-INCREMENT FOLDER ---
ts = datestr(now, 'yyyy-mm-dd_HH-MM'); 
search_pattern = fullfile(PARENT_FOLDER, [source_prefix '_' current_wave '_*']);
existing_items = dir(search_pattern);
dir_flags = [existing_items.isdir];
next_num = sum(dir_flags) + 1;

folder_name = sprintf('%s_%s_%d_%s', source_prefix, current_wave, next_num, ts);
FINAL_SUBFOLDER_PATH = fullfile(PARENT_FOLDER, folder_name);

if exist(FINAL_SUBFOLDER_PATH, 'dir')
    ts_sec = datestr(now, 'yyyy-mm-dd_HH-MM-ss');
    folder_name = sprintf('%s_%s_%d_%s', source_prefix, current_wave, next_num, ts_sec);
    FINAL_SUBFOLDER_PATH = fullfile(PARENT_FOLDER, folder_name);
end
mkdir(FINAL_SUBFOLDER_PATH);

%% --- 4. HARVEST DATA ---
Time  = data_obj.Time;
Input = data_obj.Data(:,1); 
Velo  = data_obj.Data(:,2); 

%% --- 5. GENERATE & SAVE PLOT ---
% 1. Create Figure with White Background
fig = figure('Visible', 'off', 'Position', [100, 100, 900, 500], 'Color', 'w'); 

% 2. Create Axes with White Background and Black Axis Lines
ax = axes('Position', [0.1, 0.15, 0.65, 0.7], ...
          'Color', 'w', ...      % Forces graph zone to white
          'XColor', 'k', ...     % Forces X-axis and numbers to black
          'YColor', 'k', ...     % Forces Y-axis and numbers to black
          'GridColor', [0.3, 0.3, 0.3]); % Darker grid for better visibility on white

plot(Time, Velo, 'b', 'LineWidth', 1.5); 
grid on; 
xlabel('Time (s)', 'Color', 'k'); 
ylabel('Velocity (rad/s)', 'Color', 'k'); 

% 3. Force Legend to have white background and black text
legend('Velocity (\omega)', 'Location', 'northeast', ...
       'Color', 'w', 'TextColor', 'k', 'EdgeColor', 'k'); 

% 4. Create Parameter String
param_text = sprintf(['Motor Parameters:\n', ...
    'R: %.4f \\Omega\n', ...
    'L: %.4f H\n', ...
    'Eff: %.4f\n', ...
    'Ke: %.4f\n', ...
    'J: %.4f\n', ...
    'B: %.4f'], ...
    motor_R, motor_L, motor_Eff, motor_Ke, motor_J, motor_B);

% 5. Add Parameter Box (Force white background, black text/border)
annotation('textbox', [0.78, 0.4, 0.18, 0.3], 'String', param_text, ...
    'FitBoxToText', 'on', 'BackgroundColor', 'white', 'FontSize', 9, ...
    'EdgeColor', 'black', 'Color', 'k'); 

% 6. Force Title to be black
title(ax, sprintf('%s - %s Velocity Response (Run %d)', source_prefix, current_wave, next_num), ...
      'Color', 'k');

% Save as PNG (Ensures background color is preserved in the file)
saveas(fig, fullfile(FINAL_SUBFOLDER_PATH, [current_wave '_Plot.png']));
close(fig);

%% --- 6. SAVE RAW FILES (.MAT & .XLSX) ---
RawData.Time = Time; 
RawData.Input = Input; 
RawData.Velo = Velo;
save(fullfile(FINAL_SUBFOLDER_PATH, [current_wave '_Raw.mat']), 'RawData');

T = table(Time, Input, Velo, 'VariableNames', {'Time_sec', 'Voltage_V', 'Speed_rad_s'});
writetable(T, fullfile(FINAL_SUBFOLDER_PATH, [current_wave '_Data.xlsx']));

fprintf('SUCCESS: %s data for %s (Run %d) saved to: %s\n', ...
    SOURCE_TYPE, current_wave, next_num, FINAL_SUBFOLDER_PATH);