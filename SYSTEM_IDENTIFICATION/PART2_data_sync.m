%% ========================================================================
%  DATA SYNCHRONIZER (SPEED TRIGGER VERSION)
%  Goal: 
%     1. Detects when ROTATIONAL SPEED starts (overcomes friction).
%     2. Shifts Time so motion starts exactly at t=0.
%     3. Saves to a NEW folder 'PART2_studyV4_Synced_Speed'.
% =========================================================================
clc; clear; close all;

%% --- 1. CONFIGURATION ---
INPUT_FOLDER  = 'PART2_studyV3_12V'; 
OUTPUT_FOLDER = 'PART2_studyV3_Synced_Speed'; % Distinct output folder

% SPEED THRESHOLD: 
% 0.5 rad/s is usually good to ignore sensor noise but catch the start.
SPEED_THRESHOLD = 0.5; 

SAVE_NEW_FILES = true;

%% --- 2. SETUP FOLDERS ---
if ~exist(INPUT_FOLDER, 'dir')
    error('Input folder "%s" does not exist.', INPUT_FOLDER);
end

if ~exist(OUTPUT_FOLDER, 'dir')
    mkdir(OUTPUT_FOLDER);
    fprintf('Created new output folder: %s\n', OUTPUT_FOLDER);
end

items = dir(INPUT_FOLDER);
dirFlags = [items.isdir];
subFolders = items(dirFlags);
subFolders = subFolders(~ismember({subFolders.name}, {'.', '..'}));

fprintf('Found %d subfolders. Syncing based on SPEED > %.2f rad/s...\n\n', length(subFolders), SPEED_THRESHOLD);

%% --- 3. PROCESS LOOP ---
for k = 1:length(subFolders)
    thisFolder = subFolders(k).name;
    
    srcFolderPath  = fullfile(INPUT_FOLDER, thisFolder);
    destFolderPath = fullfile(OUTPUT_FOLDER, thisFolder);
    
    if ~exist(destFolderPath, 'dir'), mkdir(destFolderPath); end
    
    xlsxFiles = dir(fullfile(srcFolderPath, '*_Data.xlsx'));
    xlsxFiles = xlsxFiles(~contains({xlsxFiles.name}, '_Synced')); 
    
    if isempty(xlsxFiles)
        fprintf('[SKIP] No data in: %s\n', thisFolder);
        continue;
    end
    
    filename = xlsxFiles(1).name;
    fullFilePath = fullfile(srcFolderPath, filename);
    T = readtable(fullFilePath);
    
    if height(T) < 10, continue; end
    
    % --- 4. SYNC LOGIC (BASED ON SPEED) ---
    % Find index where |Speed| > Threshold
    idx_start = find(abs(T.Speed_rad_s) >= SPEED_THRESHOLD, 1, 'first');
    
    if isempty(idx_start)
        fprintf('[WARN] Motor never moved in %s\n', thisFolder);
        continue;
    end
    
    % Buffer: Step back 5-10 samples to capture the curve rising
    idx_start = max(1, idx_start - 10); 
    t_zero = T.Time_sec(idx_start);
    
    % Shift & Crop
    T_sync = T;
    T_sync.Time_sec = T.Time_sec - t_zero;
    T_sync = T_sync(T_sync.Time_sec >= 0, :);
    
    Time  = T_sync.Time_sec;
    Input = T_sync.Voltage_V;
    Velo  = T_sync.Speed_rad_s;
    
    %% --- 5. SAVE TO NEW FOLDER ---
    if SAVE_NEW_FILES
        % 1. Save Excel
        newNameXLSX = strrep(filename, '_Data.xlsx', '_Synced.xlsx');
        writetable(T_sync, fullfile(destFolderPath, newNameXLSX));
        
        % 2. Save MAT
        RawData.Time = Time;
        RawData.Input = Input;
        RawData.Velo = Velo;
        [~, fname, ~] = fileparts(filename);
        newNameMAT = [strrep(fname, '_Data', ''), '_Synced.mat']; 
        save(fullfile(destFolderPath, newNameMAT), 'RawData');
        
        % 3. Plot (Speed-Based Sync)
        fig = figure('Visible', 'off', 'Position', [100, 100, 900, 500], 'Color', 'w'); 
        ax = axes('Position', [0.1, 0.15, 0.65, 0.7], 'Color', 'w', ...
                  'XColor', 'k', 'YColor', 'k', 'GridColor', [0.3, 0.3, 0.3]); 
        
        plot(Time, Velo, 'b', 'LineWidth', 1.5); 
        grid on; 
        xlabel('Time (s)'); ylabel('Velocity (rad/s)'); 
        title(ax, [thisFolder ' (Speed Sync)'], 'Color', 'k', 'Interpreter', 'none');
        legend('Velocity (\omega)', 'Location', 'northeast');
        
        % Info Box
        info_text = sprintf('Sync Source: SPEED\nShift: %.4fs\nStart > %.1f rad/s', ...
                            t_zero, SPEED_THRESHOLD);
        annotation('textbox', [0.78, 0.4, 0.18, 0.2], 'String', info_text, ...
            'BackgroundColor', 'white', 'EdgeColor', 'black'); 
        
        imgName = strrep(filename, '_Data.xlsx', '_Synced_Plot.png');
        saveas(fig, fullfile(destFolderPath, imgName));
        close(fig);
        
        fprintf('[DONE] %s (Shift: %.4fs)\n', thisFolder, t_zero);
    end
end

fprintf('\nComplete. Check the "%s" folder.\n', OUTPUT_FOLDER);