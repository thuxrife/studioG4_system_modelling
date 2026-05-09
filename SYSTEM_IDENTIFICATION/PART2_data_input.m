%% --- 1. LOAD DATA ---
filepath = 'C:\Users\User\Documents\GitHub\FRA233_Lab1_G04\PART2_studyV2\part2_Step_1_2026-01-31_20-36\Step_Data.xlsx'; %
T = readtable(filepath); 

fs = 1 / (T.Time_sec(2) - T.Time_sec(1)); % Sampling Frequency
y_raw = T.Speed_rad_s; 

%% --- 2. SIGNAL CONDITIONING (filtfilt) ---
% Based on your FFT analysis, define the cutoff (e.g., 20Hz)
fc = 50; 
[b, a] = butter(2, fc/(fs/2), 'low'); %

% Apply zero-phase filter to a NEW variable
y_clean = filtfilt(b, a, y_raw); 

%% --- 3. DUAL-SIGNAL VISUALIZATION ---
fig = figure('Color', 'w', 'Name', 'Signal Conditioning Analysis');
ax1 = subplot(2,1,1); % Top plot for Time Domain
plot(T.Time_sec, y_raw, 'Color', [0.8 0.8 0.8], 'DisplayName', 'Raw Data'); 
hold on;
plot(T.Time_sec, y_clean, 'b', 'LineWidth', 1.2, 'DisplayName', 'Cleaned (filtfilt)');
grid on; ylabel('Velocity (rad/s)'); legend('show');
title('Time Domain: Raw vs. Filtered Signal');

% Bottom plot for FFT (to prove noise is gone)
ax2 = subplot(2,1,2);
L = length(y_raw);
f = fs*(0:(L/2))/L;
% FFT of Raw
Y_raw = fft(y_raw); P1_raw = abs(Y_raw/L); P1_raw = P1_raw(1:floor(L/2)+1);
% FFT of Clean
Y_clean = fft(y_clean); P1_clean = abs(Y_clean/L); P1_clean = P1_clean(1:floor(L/2)+1);

semilogy(f, P1_raw, 'Color', [0.8 0.8 0.8], 'DisplayName', 'Raw Spectrum');
hold on;
semilogy(f, P1_clean, 'r', 'LineWidth', 1, 'DisplayName', 'Cleaned Spectrum');
grid on; xlabel('Frequency (Hz)'); ylabel('Amplitude'); legend('show');
title('Frequency Domain: Noise Suppression Analysis');

%% --- 4. EXPORT TO WORKSPACE ---
% We provide the clean data to the estimator variables
exp_time = T.Time_sec;
exp_input = T.Voltage_V;
exp_output = y_clean; % Only send the clean signal to the App

fprintf('Workspace ready. Use [exp_time, exp_output] in Parameter Estimator.\n');