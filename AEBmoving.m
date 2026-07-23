%% AEB System - Moving Obstacle
% Author: Garvit
% Tomas Bata University - July 2026

%% Parameters
m = 1500;
g = 9.81;
mu = 0.8;
dt = 0.01;
v_ego = 100/3.6;      % Your car speed
v_lead = 30/3.6;      % Lead vehicle speed
d0 = 80;              % Initial gap between vehicles
F_max = mu * m * g;
TTC_threshold = 2.0;
t_reaction = 0.3;

t = 0:dt:15;
n = length(t);

v = zeros(1,n);
d = zeros(1,n);
v_lead_arr = zeros(1,n);
rel_speed = zeros(1,n);
brake_force = zeros(1,n);

v(1) = v_ego;
d(1) = d0;
v_lead_arr(1) = v_lead;

aeb_triggered = false;
aeb_trigger_time = 0;
stop_idx = n;
collision = 0;

fprintf('=== AEB - MOVING OBSTACLE ===\n')
fprintf('Ego vehicle: %.0f km/h\n', v_ego*3.6)
fprintf('Lead vehicle: %.0f km/h\n', v_lead*3.6)
fprintf('Relative speed: %.0f km/h\n', (v_ego-v_lead)*3.6)
fprintf('Initial gap: %.0f m\n', d0)
fprintf('============================\n')

for i = 2:n
    rel_speed(i) = v(i-1) - v_lead_arr(i-1);
    
    if rel_speed(i) > 0
        TTC = d(i-1) / rel_speed(i);
    else
        TTC = inf;
    end
    
    if TTC <= TTC_threshold && ~aeb_triggered
        aeb_triggered = true;
        aeb_trigger_time = t(i);
        fprintf('AEB TRIGGERED at t=%.2fs | TTC=%.2fs | Gap=%.2fm\n', t(i), TTC, d(i-1))
    end
    
    if aeb_triggered && (t(i) - aeb_trigger_time) >= t_reaction
        brake_force(i) = F_max;
    else
        brake_force(i) = 0;
    end
    
    a = brake_force(i) / m;
    v(i) = v(i-1) - a * dt;
    if v(i) < 0
        v(i) = 0;
    end
    
    v_lead_arr(i) = v_lead;
    d(i) = d(i-1) - (v(i-1) - v_lead_arr(i-1)) * dt;
    
    if d(i) <= 0
        d(i) = 0;
        stop_idx = i;
        collision = 1;
        fprintf('COLLISION at t=%.2fs\n', t(i))
        break
    end
    if v(i) <= v_lead_arr(i)
        stop_idx = i;
        fprintf('SAFE - Matched lead speed at t=%.2fs | Gap remaining: %.2fm\n', t(i), d(i))
        break
    end
end

figure(9)
clf

subplot(3,1,1)
hold on
plot(t(1:stop_idx), v(1:stop_idx)*3.6, 'b', 'LineWidth', 2)
plot(t(1:stop_idx), v_lead_arr(1:stop_idx)*3.6, 'r--', 'LineWidth', 2)
xlabel('Time (seconds)')
ylabel('Speed (km/h)')
title('AEB Moving Obstacle - Vehicle Speeds')
legend('Ego Vehicle', 'Lead Vehicle')
grid on

subplot(3,1,2)
plot(t(1:stop_idx), d(1:stop_idx), 'g', 'LineWidth', 2)
xlabel('Time (seconds)')
ylabel('Gap (m)')
title('Gap Between Ego and Lead Vehicle')
grid on

subplot(3,1,3)
plot(t(1:stop_idx), brake_force(1:stop_idx), 'r', 'LineWidth', 2)
xlabel('Time (seconds)')
ylabel('Braking Force (N)')
title('Braking Force Applied')
grid on

fprintf('============================\n')
if collision == 0
    fprintf('RESULT: SAFE - No collision\n')
else
    fprintf('RESULT: COLLISION OCCURRED\n')
end
fprintf('============================\n')