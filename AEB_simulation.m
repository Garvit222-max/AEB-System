%% AEB System - Vehicle Motion Simulation
% Author: Garvit
% Tomas Bata University - July 2026

%% Parameters
m = 1500;       % Mass (kg)
v0 = 100/3.6;   % Initial speed (m/s)
d0 = 80;        % Obstacle distance (m)
mu = 0.8;       % Friction coefficient
g = 9.81;       % Gravity (m/s2)

%% Time Setup
dt = 0.01;      % Time step (seconds)
t = 0:dt:10;    % Simulation time 0 to 10 seconds
n = length(t);

%% Initialize Arrays
v = zeros(1,n);   % Speed array
d = zeros(1,n);   % Distance array
v(1) = v0;        % Initial speed
d(1) = d0;        % Initial distance

%% Braking Force
F_brake = mu * m * g;
a_brake = F_brake / m;

%% Simulation Loop
for i = 2:n
    % Apply braking
    v(i) = v(i-1) - a_brake * dt;
    
    % Speed cannot go below zero
    if v(i) < 0
        v(i) = 0;
    end
    
    % Update distance to obstacle
    d(i) = d(i-1) - v(i-1) * dt;
    
    % Stop if collision or car stopped
    if d(i) <= 0
        d(i) = 0;
        fprintf('COLLISION at t = %.2f seconds\n', t(i))
        break
    end
    
    if v(i) == 0
        fprintf('Car stopped safely at t = %.2f seconds\n', t(i))
        fprintf('Remaining distance to obstacle: %.2f m\n', d(i))
        break
    end
end

%% Plot Results
figure(1)
subplot(2,1,1)
plot(t(1:i), v(1:i)*3.6, 'b', 'LineWidth', 2)
xlabel('Time (seconds)')
ylabel('Speed (km/h)')
title('Vehicle Speed During Emergency Braking')
grid on

subplot(2,1,2)
plot(t(1:i), d(1:i), 'r', 'LineWidth', 2)
xlabel('Time (seconds)')
ylabel('Distance to Obstacle (m)')
title('Distance to Obstacle During Braking')
grid on