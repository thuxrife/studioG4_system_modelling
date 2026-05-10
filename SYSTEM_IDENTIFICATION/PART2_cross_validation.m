%% ========================================================================
%  CROSS-IMPACT MATRIX GENERATOR (FINAL - 5 PLOTS ONLY)
%  Features:
%    1. 5 PLOTS ONLY: No 6th dummy subplot.
%    2. LEGEND: Floating manually in the bottom-right blank space.
%    3. ACCURACY: Forces R=2.78, L=0.039.
%    4. OUTPUT: Prints RMSE to Command Window.
% =========================================================================
function Generate_Cross_Impact_Matrix_Final()
clc;
bdclose all; % Force close any hidden models
close all;

% --- 0. SUPPRESS WARNINGS --------------------------------------------
warning('off', 'Simulink:Engine:NotifyTargetConnectivity');
warning('off', 'MATLAB:class:DestructorError');
warning('off', 'Simulink:Commands:ParamUnknown');

% --- 1. CONFIGURATION ------------------------------------------------
model_name = 'Lab1_parameter_estimation_student';
base_path_in = 'C:\Users\User\Documents\GitHub\FRA233_Lab1_G04\PART2_studyV4_Synced_Speed\';
PARENT_FOLDER = 'PART2_result';

wave_names = {'Step', 'Ramp', 'Stair', 'Sine', 'Chirp'};


folders_in = {'part2_Step_1_2026-02-06_20-23', ...
           'part2_Ramp_1_2026-02-06_20-25', ...
           'part2_Stair_1_2026-02-06_20-26', ...
           'part2_Sine_1_2026-02-06_20-32', ...
           'part2_Chirp_1_2026-02-06_20-35'};

% folders_in = {'part2_Step_3_2026-02-03_20-31', ...
%     'part2_Ramp_3_2026-02-03_20-35', ...
%     'part2_Stair_3_2026-02-03_20-41', ...
%     'part2_Sine_3_2026-02-03_20-58', ...
%     'part2_Chirp_3_2026-02-03_21-36'};

% folders_in = {'part2_Step_2_2026-02-03_20-30', ...
%               'part2_Ramp_2_2026-02-03_20-34', ...
%               'part2_Stair_2_2026-02-03_20-40', ...
%               'part2_Sine_2_2026-02-03_20-58', ...
%               'part2_Chirp_2_2026-02-03_21-36'};

param_files = {'Params_Step.mat'; 'Params_Ramp.mat'; 'Params_Stair.mat'; 'Params_Sine.mat'; 'Params_Chirp.mat'};

% --- 2. FOLDER CREATION ----------------------------------------------
if ~exist(PARENT_FOLDER, 'dir'), mkdir(PARENT_FOLDER); end
prefix = 'part2_result';
search_pattern = fullfile(PARENT_FOLDER, [prefix '_*']);
existing_items = dir(search_pattern);
next_num = sum([existing_items.isdir]) + 1;
ts = datestr(now, 'yyyy-mm-dd_HH-MM');
folder_name = sprintf('%s_%d_%s', prefix, next_num, ts);
FINAL_PATH = fullfile(PARENT_FOLDER, folder_name);
mkdir(FINAL_PATH);
fprintf('OUTPUT FOLDER: %s\n', FINAL_PATH);

% --- 3. PRE-LOAD MODEL -----------------------------------------------
fprintf('Loading Model... ');
load_system(model_name);
fprintf('Ready.\n\n');

rmse_matrix = zeros(5,5);
SimResults = struct();

% --- 4. PHASE 1: SIMULATION (TEXT ONLY) ------------------------------
fprintf('=== PHASE 1: RUNNING SIMULATIONS ===\n');
fprintf('Using Fixed Electrical Params: R=3.399924458, L=0.002853248\n');
fprintf('-----------------------------------------------------------\n');
fprintf('| %-10s | %-10s | %-10s |\n', 'SOURCE', 'TARGET', 'RMSE');
fprintf('-----------------------------------------------------------\n');

for src_idx = 1:5
    p_file = param_files{src_idx};
    source_name = wave_names{src_idx};

    if ~isfile(p_file)
        fprintf('[SKIP] Missing %s\n', p_file); continue;
    end
    p = load(p_file);

    % *** CRITICAL: PUSH VARIABLES TO WORKSPACE ***
    assignin('base', 'motor_J', p.motor_J);
    assignin('base', 'motor_B', p.motor_B);
    assignin('base', 'motor_Ke', p.motor_Ke);

    % USE YOUR SPECIFIC VALUES
    assignin('base', 'motor_R', 3.399924458);
    assignin('base', 'motor_L', 0.002853248);

    % Handle Efficiency/Friction safely
    if isfield(p, 'motor_Eff'), assignin('base', 'motor_Eff', p.motor_Eff); else, assignin('base', 'motor_Eff', 1.0); end
    if isfield(p, 'motor_Cf'), assignin('base', 'motor_Cf', p.motor_Cf); else, assignin('base', 'motor_Cf', 0); end
    if isfield(p, 'motor_V_dead'), assignin('base', 'motor_V_dead', p.motor_V_dead); else, assignin('base', 'motor_V_dead', 0); end

    for tgt_idx = 1:5
        target_wave = wave_names{tgt_idx};

        % Load Data
        data_file = fullfile(base_path_in, folders_in{tgt_idx}, [target_wave, '_Synced.xlsx']);
        T = readtable(data_file);
        y_real = T.Speed_rad_s; t_val = T.Time_sec; u_val = T.Voltage_V;

        % Setup Simulation
        assignin('base', 'u_sim_val', [t_val, u_val]);
        set_param(model_name, 'StopTime', num2str(t_val(end)));

        % --- FIX: Changed Step Size to 0.0005 (500us) ---
        set_param(model_name, 'SolverType', 'Fixed-step', 'Solver', 'ode14x', 'FixedStep', '0.0005');
        set_param(model_name, 'LoadExternalInput', 'on', 'ExternalInput', 'u_sim_val');

        try
            simOut = sim(model_name);

            % Extract Data
            if isa(simOut, 'Simulink.SimulationOutput')
                if isa(simOut.yout, 'Simulink.SimulationData.Dataset')
                    y_raw = simOut.yout.get(1).Values.Data;
                    t_raw = simOut.yout.get(1).Values.Time;
                else
                    y_raw = simOut.yout.signals(1).values;
                    t_raw = simOut.tout;
                end
            else
                y_raw = simOut.yout(:,2); t_raw = simOut.tout;
            end

            y_sim = interp1(t_raw, y_raw, t_val, 'linear', 'extrap');
            err = y_real - y_sim;
            rmse = sqrt(mean(err.^2));

            % Store Results
            idx = sub2ind([5,5], src_idx, tgt_idx);
            SimResults(idx).t = t_val;
            SimResults(idx).y_real = y_real;
            SimResults(idx).y_sim = y_sim;
            SimResults(idx).rmse = rmse;
            SimResults(idx).src = source_name;
            SimResults(idx).tgt = target_wave;
            SimResults(idx).p = p;

            rmse_matrix(src_idx, tgt_idx) = rmse;

            % PRINT TO COMMAND LINE
            fprintf('| %-10s | %-10s | %-10.4f |\n', source_name, target_wave, rmse);

        catch
            fprintf('| %-10s | %-10s | %-10s |\n', source_name, target_wave, 'FAIL');
            rmse_matrix(src_idx, tgt_idx) = Inf;
        end
    end
    fprintf('-----------------------------------------------------------\n');
end

bdclose(model_name);
fprintf('\n=== PHASE 2: GENERATING IMAGES ===\n');

% --- 5. PHASE 2: PLOTTING (5 PLOTS ONLY) -----------------------------
for src_idx = 1:5
    source_name = wave_names{src_idx};

    idx_first = sub2ind([5,5], src_idx, 1);
    if isempty(SimResults) || idx_first > length(SimResults) || isempty(SimResults(idx_first).p), continue; end
    p = SimResults(idx_first).p;

    % Title matches your image style
    title_str = sprintf('SOURCE: %s Parameters\nJ=%.2e, B=%.2e, Ke=%.4f, Eff=%.1f%%', ...
        source_name, p.motor_J, p.motor_B, p.motor_Ke, p.motor_Eff*100);

    f = figure('Name', ['Source_' source_name], 'Color', 'w', ...
        'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.6], 'Visible', 'off');
    sgtitle(title_str, 'FontSize', 14, 'FontWeight', 'bold');

    h_real = []; h_sim = [];

    % Plot 5 waves in specific slots
    for tgt_idx = 1:5
        idx = sub2ind([5,5], src_idx, tgt_idx);
        res = SimResults(idx);
        if isempty(res.t), continue; end

        subplot(2,3,tgt_idx); % 1-5 filled, 6 REMAINS EMPTY
        h_real = plot(res.t, res.y_real, 'b', 'LineWidth', 1); hold on;
        h_sim  = plot(res.t, res.y_sim, 'r--', 'LineWidth', 2); % Dashed red

        % Title Format: "TEST on X"
        if src_idx == tgt_idx
            title(sprintf('TEST on %s (SELF)\nRMSE: %.4f', res.tgt, res.rmse), 'Color', 'b', 'FontWeight', 'bold');
        else
            title(sprintf('TEST on %s\nRMSE: %.4f', res.tgt, res.rmse), 'Color', 'k');
        end
        grid on; xlim([0, res.t(end)]);
        xlabel('Time (s)');
        ylabel('Speed (\omega) [rad/s]');
    end

    % LEGEND: FLOATING (No Subplot)
    % We place it manually in the coordinates of the 6th slot (Bottom Right)
    % Coordinates: [Left Bottom Width Height] (Normalized 0-1)
    if ~isempty(h_real) && ~isempty(h_sim)
        lgd = legend([h_real, h_sim], 'Experimental', 'Simulation', ...
            'Position', [0.73, 0.20, 0.15, 0.1]);
        lgd.FontSize = 12; lgd.Box = 'on';
    end

    save_name = sprintf('Source_%s_Validation.png', source_name);
    saveas(f, fullfile(FINAL_PATH, save_name));
    close(f);
    fprintf('Saved Plot: %s\n', save_name);
end

% --- 6. SUMMARY ------------------------------------------------------
row_sums = sum(rmse_matrix, 2);
[min_sum, best_idx] = min(row_sums);
optimal_name = wave_names{best_idx};

f_heat = figure('Name', 'Cross-Impact Matrix', 'Color', 'w', 'Visible', 'off');
y_labels = wave_names;
y_labels{best_idx} = ['>>> ' wave_names{best_idx} ' (MOST OPTIMAL)'];
h = heatmap(wave_names, y_labels, rmse_matrix);
h.Title = sprintf('Cross-Impact RMSE (Lower is Better)\nMost Optimal: %s', optimal_name);
h.XLabel = 'TESTED ON (Target)'; h.YLabel = 'TRAINED ON (Source)';
h.Colormap = parula;

saveas(f_heat, fullfile(FINAL_PATH, 'Cross_Impact_Heatmap.png'));
close(f_heat);

ResultsTable = table(wave_names', row_sums, 'VariableNames', {'Source', 'Total_RMSE'});
writetable(ResultsTable, fullfile(FINAL_PATH, 'Summary_Ranking.xlsx'));

fprintf('\nSUCCESS. Results in: %s\n', FINAL_PATH);
winopen(FINAL_PATH);
end