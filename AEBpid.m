%% AEB System - PID Braking Controller
% Author: Garvit
% Tomas Bata University - July 2026

%% Parameters
m = 1500;
g = 9.81;
mu = 0.8;
d0 = 80;
dt = 0.01;
v0 = 100/3.6;

%% PID Parameters
Kp = 1.5;    % Proportional gain
Ki = 0.01;   % Integral gain
Kd = 0.5;    % Derivative gain

%% Time Setup
t = 0:dt:10;
n = length(t);

%% Initialize Arrays
v = zeros(1,n);
d = zeros(1,n);
brake_force = zeros(1,n);
error_sum = 0;
error_prev = 0;
v(1) = v0;
d(1) = d0;

%% Target Speed
v_target = 0;

%% Maximum Braking Force
F_max = mu * m * g;

%% Simulation Loop
stop_idx = n;

for i = 2:n
    
    % Error - difference between current and target speed
    error = v(i-1) - v_target;
    
    % Integral
    error_sum = error_sum + error * dt;
    
    % Derivative
    error_diff = (error - error_prev) / dt;
    error_prev = error;
    
    % PID Output - braking force
    F_pid = Kp*error + Ki*error_sum + Kd*error_diff;
    
    % Limit braking force
    F_pid = max(0, min(F_pid, F_max));
    brake_force(i) = F_pid;
    
    % Update speed
    a = F_pid / m;
    v(i) = v(i-1) - a * dt;
    
    % Speed cannot go below zero
    if v(i) < 0
        v(i) = 0;
    end
    
    % Update distance
    d(i) = d(i-1) - v(i-1) * dt;
    
    % Check collision or stop
    if d(i) <= 0
        d(i) = 0;
        stop_idx = i;
        fprintf('PID Controller: COLLISION at %.2f s\n', t(i))
        break
    end
    
    if v(i) == 0
        stop_idx = i;
        fprintf('PID Controller: SAFE STOP at %.2f s\n', t(i))
        fprintf('Remaining distance: %.2f m\n', d(i))
        break
    end
end

%% Plot Results
figure(5)

subplot(3,1,1)
plot(t(1:stop_idx), v(1:stop_idx)*3.6, 'b', 'LineWidth', 2)
xlabel('Time (seconds)')
ylabel('Speed (km/h)')
title('PID Controller - Vehicle Speed')
grid on

subplot(3,1,2)
plot(t(1:stop_idx), d(1:stop_idx), 'r', 'LineWidth', 2)
xlabel('Time (seconds)')
ylabel('Distance to Obstacle (m)')
title('PID Controller - Distance to Obstacle')
grid on

subplot(3,1,3)
plot(t(1:stop_idx), brake_force(1:stop_idx), 'g', 'LineWidth', 2)
xlabel('Time (seconds)')
ylabel('Braking Force (N)')
title('PID Controller - Braking Force Applied')
grid on