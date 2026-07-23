%% AEB System - Sigmoid Braking
% Author: Garvit
% Tomas Bata University - July 2026

%% Parameters
m = 1500;
g = 9.81;
mu = 0.8;
dt = 0.01;
v0 = 100/3.6;
d0 = 80;
F_max = mu * m * g;
TTC_threshold = 2.0;
t_reaction = 0.3;

t = 0:dt:10;
n = length(t);

%% Two scenarios - instant vs sigmoid
figure(10)
clf

scenarios = {'Instant Braking', 'Sigmoid Braking'};
colors = {'r', 'b'};

fprintf('=== SIGMOID vs INSTANT BRAKING ===\n')

for s = 1:2
    v = zeros(1,n);
    d = zeros(1,n);
    brake_force = zeros(1,n);
    v(1) = v0;
    d(1) = d0;
    
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
        
        if aeb_triggered
            t_since = t(i) - aeb_trigger_time - t_reaction;
            
            if s == 1
                % Instant braking
                if t_since >= 0
                    brake_force(i) = F_max;
                end
            else
                % Sigmoid braking
                if t_since >= 0
                    sigmoid = 1 / (1 + exp(-5 * (t_since - 0.5)));
                    brake_force(i) = F_max * sigmoid;
                end
            end
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
            fprintf('%s: COLLISION at %.2fs\n', scenarios{s}, t(i))
            break
        end
        if v(i) == 0
            stop_idx = i;
            fprintf('%s: SAFE STOP at %.2fs | Remaining: %.2fm\n', scenarios{s}, t(stop_idx), d(stop_idx))
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
title('Sigmoid vs Instant Braking - Speed Comparison')
legend(scenarios)
grid on

subplot(3,1,2)
xlabel('Time (seconds)')
ylabel('Distance to Obstacle (m)')
title('Sigmoid vs Instant Braking - Distance Comparison')
legend(scenarios)
grid on

subplot(3,1,3)
xlabel('Time (seconds)')
ylabel('Braking Force (N)')
title('Braking Force Profile - Sigmoid vs Instant')
legend(scenarios)
grid on

fprintf('==================================\n')
fprintf('Sigmoid braking is more comfortable\n')
fprintf('Instant braking stops slightly faster\n')
fprintf('Real AEB uses sigmoid for passenger comfort\n')
fprintf('==================================\n')