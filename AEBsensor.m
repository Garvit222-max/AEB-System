%% AEB System - Realistic Sensor Model
% Author: Garvit
% Tomas Bata University - July 2026
% Improvement 1: Adding Radar Sensor with Noise

%% Vehicle Parameters
m = 1500;
g = 9.81;
mu = 0.8;
dt = 0.01;
v0 = 100/3.6;
d0 = 80;
F_max = mu * m * g;

%% Sensor Parameters
radar_noise_std = 1.5;    % Radar noise standard deviation (metres)
camera_noise_std = 3.0;   % Camera noise standard deviation (metres)
radar_weight = 0.7;       % Radar reliability weight
camera_weight = 0.3;      % Camera reliability weight

%% Time Setup
t = 0:dt:10;
n = length(t);

%% Initialize Arrays
v = zeros(1,n);
d_real = zeros(1,n);
d_measured = zeros(1,n);
d_radar = zeros(1,n);
d_camera = zeros(1,n);
brake_force = zeros(1,n);

v(1) = v0;
d_real(1) = d0;
d_measured(1) = d0;

%% AEB Parameters
TTC_threshold = 2.0;
t_reaction = 0.3;
aeb_triggered = false;
aeb_trigger_time = 0;

stop_idx = n;
collision = 0;

fprintf('=== AEB SYSTEM WITH RADAR SENSOR ===\n')
fprintf('Initial speed: %.1f km/h\n', v0*3.6)
fprintf('Initial distance: %.1f m\n', d0)
fprintf('Radar noise std: %.1f m\n', radar_noise_std)
fprintf('Camera noise std: %.1f m\n', camera_noise_std)
fprintf('=====================================\n')

%% Simulation Loop
for i = 2:n
    
    %% Sensor Measurements With Noise
    radar_noise = randn() * radar_noise_std;
    camera_noise = randn() * camera_noise_std;
    
    d_radar(i) = d_real(i-1) + radar_noise;
    d_camera(i) = d_real(i-1) + camera_noise;
    
    %% Sensor Fusion
    d_measured(i) = radar_weight * d_radar(i) + ...
                    camera_weight * d_camera(i);
    
    %% Ensure measured distance not negative
    d_measured(i) = max(0, d_measured(i));
    
    %% TTC Calculation Using Measured Distance
    if v(i-1) > 0
        TTC = d_measured(i) / v(i-1);
    else
        TTC = inf;
    end
    
    %% AEB Trigger
    if TTC <= TTC_threshold && ~aeb_triggered
        aeb_triggered = true;
        aeb_trigger_time = t(i);
        fprintf('AEB TRIGGERED at t=%.2fs | TTC=%.2fs | Measured distance=%.2fm | Real distance=%.2fm\n', ...
                t(i), TTC, d_measured(i), d_real(i-1))
    end
    
    %% Apply Braking After Reaction Time
    if aeb_triggered && (t(i) - aeb_trigger_time) >= t_reaction
        brake_force(i) = F_max;
    else
        brake_force(i) = 0;
    end
    
    %% Update Vehicle Speed
    a = brake_force(i) / m;
    v(i) = v(i-1) - a * dt;
    if v(i) < 0
        v(i) = 0;
    end
    
    %% Update Real Distance
    d_real(i) = d_real(i-1) - v(i-1) * dt;
    
    %% Check Collision or Stop
    if d_real(i) <= 0
        d_real(i) = 0;
        stop_idx = i;
        collision = 1;
        fprintf('COLLISION at t=%.2fs\n', t(i))
        break
    end
    if v(i) == 0
        stop_idx = i;
        fprintf('SAFE STOP at t=%.2fs\n', t(i))
        fprintf('Real remaining distance: %.2fm\n', d_real(i))
        break
    end
end

%% Plot Results
figure(8)
clf

subplot(3,1,1)
plot(t(1:stop_idx), v(1:stop_idx)*3.6, 'b', 'LineWidth', 2)
xlabel('Time (seconds)')
ylabel('Speed (km/h)')
title('AEB With Sensor Noise - Vehicle Speed')
grid on

subplot(3,1,2)
hold on
plot(t(1:stop_idx), d_real(1:stop_idx), 'b', 'LineWidth', 2)
plot(t(2:stop_idx), d_measured(2:stop_idx), 'r--', 'LineWidth', 1.5)
plot(t(2:stop_idx), d_radar(2:stop_idx), 'g:', 'LineWidth', 1)
plot(t(2:stop_idx), d_camera(2:stop_idx), 'm:', 'LineWidth', 1)
xlabel('Time (seconds)')
ylabel('Distance (m)')
title('Real vs Measured Distance - Sensor Noise Effect')
legend('Real Distance', 'Fused Measurement', 'Radar Only', 'Camera Only')
grid on

subplot(3,1,3)
plot(t(1:stop_idx), brake_force(1:stop_idx), 'r', 'LineWidth', 2)
xlabel('Time (seconds)')
ylabel('Braking Force (N)')
title('AEB Braking Force Applied')
grid on

fprintf('=====================================\n')
fprintf('Sensor noise caused measurement error\n')
fprintf('Radar weight: %.0f%% Camera weight: %.0f%%\n', radar_weight*100, camera_weight*100)
fprintf('=====================================\n')