%% AEB System - PID Comfort vs Safety Comparison
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

%% Three PID Profiles
profiles = [
    1200, 80, 200;
    800,  50, 100;
    400,  20,  50];

names = {'Safety Mode Kp=1200', 'Balanced Mode Kp=800', 'Comfort Mode Kp=400'};
colors = {'r', 'b', 'g'};

figure(11)
clf

fprintf('=== PID COMFORT vs SAFETY ===\n')

for s = 1:3
    Kp = profiles(s,1);
    Ki = profiles(s,2);
    Kd = profiles(s,3);
    
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
    
    for i = 2:n
        if v(i-1) > 0
            TTC = d(i-1) / v(i-1);
        else
            TTC = inf;
        end
        
        if TTC <= TTC_threshold && ~aeb_triggered
            aeb_triggered = true;
            aeb_trigger_time = t(i);
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
            fprintf('%s: COLLISION at %.2fs\n', names{s}, t(i))
            break
        end
        if v(i) == 0
            stop_idx = i;
            fprintf('%s: SAFE STOP at %.2fs | Remaining: %.2fm\n', names{s}, t(stop_idx), d(stop_idx))
            break
        end
    end
    
    subplot(3,1,1)
    hold on
    plot(t(1:stop_idx), v(1:stop_idx)*3.6, colors{s}, 'LineWidth', 2)
    
    subplot(3,1,2)
    hold on
    plot(t(1:stop_idx), d(1:stop_idx), colors{s}, 'LineWidth', 2)
    
    subplot(3,1,3)
    hold on
    plot(t(1:stop_idx), brake_force(1:stop_idx), colors{s}, 'LineWidth', 2)
end

subplot(3,1,1)
xlabel('Time (seconds)')
ylabel('Speed (km/h)')
title('PID Profiles - Speed Comparison')
legend(names)
grid on

subplot(3,1,2)
xlabel('Time (seconds)')
ylabel('Distance to Obstacle (m)')
title('PID Profiles - Distance Comparison')
legend(names)
grid on

subplot(3,1,3)
xlabel('Time (seconds)')
ylabel('Braking Force (N)')
title('PID Profiles - Braking Force Comparison')
legend(names)
grid on

fprintf('==============================\n')
fprintf('Safety mode: fastest stop\n')
fprintf('Comfort mode: smoothest deceleration\n')
fprintf('Balanced mode: best trade-off\n')
fprintf('==============================\n')