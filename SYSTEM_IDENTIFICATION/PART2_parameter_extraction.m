%% ========================================================================
%  PARAMETER SAVER UTILITY
%  Run this AFTER clicking "Update Model" in the Parameter Estimator App.
% =========================================================================
clc;

% 1. Check if parameters exist in Workspace
required_vars = {'motor_J', 'motor_B', 'motor_Ke', 'motor_Eff'};
missing_vars = {};

for i = 1:length(required_vars)
    if ~exist(required_vars{i}, 'var')
        missing_vars{end+1} = required_vars{i};
    end
end

if ~isempty(missing_vars)
    fprintf('[ERROR] These variables are missing from your Workspace:\n');
    disp(missing_vars);
    fprintf('Did you forget to click "Update Model" in the App?\n');
    return;
end

% 2. Ask User which file to save
fprintf('------------------------------------------------\n');
fprintf('  WHICH EXPERIMENT DID YOU JUST FINISH?\n');
fprintf('------------------------------------------------\n');
fprintf('  1) Step  -> Params_Step.mat\n');
fprintf('  2) Ramp  -> Params_Ramp.mat\n');
fprintf('  3) Stair -> Params_Stair.mat\n');
fprintf('  4) Sine  -> Params_Sine.mat\n');
fprintf('  5) Chirp -> Params_Chirp.mat\n');
fprintf('------------------------------------------------\n');

choice = input('Enter number (1-5): ');

switch choice
    case 1, fname = 'Params_Step.mat';
    case 2, fname = 'Params_Ramp.mat';
    case 3, fname = 'Params_Stair.mat';
    case 4, fname = 'Params_Sine.mat';
    case 5, fname = 'Params_Chirp.mat';
    otherwise
        fprintf('Invalid selection. Nothing saved.\n');
        return;
end

% 3. Save the file
try
    save(fname, 'motor_J', 'motor_B', 'motor_Ke', 'motor_Eff');
    fprintf('\n[SUCCESS] Saved current workspace parameters to:\n   >> %s\n', fname);
    fprintf('------------------------------------------------\n');
catch ME
    fprintf('[ERROR] Could not save file: %s\n', ME.message);
end