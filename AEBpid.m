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
F_max = mu * m * g;
TTC_threshold = 2.0;
t_reaction = 0.3;

%% PID Parameters - properly tuned
Kp = 800;
Ki = 50;
Kd = 100;

t = 0:dt:10;
n = length(t);

v = zeros(1,n);
d = zeros(1,n);
brake_force = zeros(1,n);
v(1) = v0;
d(1) = d0;

error_sum = 0;
error_prev = 0;
aeb_triggered = false;
aeb_trigger_time = 0;
stop_idx = n;
collision = 0;

fprintf('=== PID BRAKING CONTROLLER ===\n')
fprintf('Kp=%.0f Ki=%.0f Kd=%.0f\n', Kp, Ki, Kd)
fprintf('==============================\n')

for i = 2:n
    if v(i-1) > 0
        TTC = d(i-1) / v(i-1);
    else
        TTC = inf;
    end
    
    if TTC <= TTC_threshold && ~aeb_triggered
        aeb_triggered = true;
        aeb_trigger_time = t(i);
        fprintf('AEB triggered at t=%.2fs | TTC=%.2fs\n', t(i), TTC)
    end
    
    if aeb_triggered && (t(i) - aeb_trigger_time) >= t_reaction
        error = v(i-1);
        error_sum = error_sum + error * dt;
        error_diff = (error - error_prev) / dt;
        error_prev = error;
        
        F_pid = Kp*error + Ki*error_sum + Kd*error_diff;
        F_pid = max(0, min(F_pid, F_max));
        brake_force(i) = F_pid;
    end
    
    a = brake_force(i) / m;
    v(i) = v(i-1) - a * dt;
    if v(i) < 0
        v(i) = 0;
    end
    
    d(i) = d(i-1) - v(i-1) * dt;
    
    if d(i) <= 0
        d(i) = 0;
        stop_idx = i;
        collision = 1;
        fprintf('COLLISION at t=%.2fs\n', t(i))
        break
    end
    if v(i) == 0
        stop_idx = i;
        fprintf('SAFE STOP at t=%.2fs | Remaining: %.2fm\n', t(stop_idx), d(stop_idx))
        break
    end
end

figure(5)
clf

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

fprintf('==============================\n')