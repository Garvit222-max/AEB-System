%% AEB System - Road Condition Analysis
% Author: Garvit
% Tomas Bata University - July 2026

%% Parameters
m = 1500;
g = 9.81;
d0 = 80;
dt = 0.01;
v0 = 100/3.6;

%% Road Conditions
mu_values = [0.8, 0.5, 0.2];
colors = {'g', 'b', 'r'};

figure(4)

for r = 1:3
    mu = mu_values(r);
    t = 0:dt:20;
    n = length(t);
    v = zeros(1,n);
    d = zeros(1,n);
    v(1) = v0;
    d(1) = d0;
    
    F_brake = mu * m * g;
    a_brake = F_brake / m;
    stop_idx = n;
    
    for i = 2:n
        v(i) = v(i-1) - a_brake * dt;
        if v(i) < 0
            v(i) = 0;
        end
        d(i) = d(i-1) - v(i-1) * dt;
        
        if d(i) <= 0
            d(i) = 0;
            stop_idx = i;
            fprintf('Road mu=%.1f: COLLISION at %.2f s\n', mu, t(i))
            break
        end
        if v(i) == 0
            stop_idx = i;
            fprintf('Road mu=%.1f: SAFE STOP | Remaining: %.2f m\n', mu, d(i))
            break
        end
    end
    
    subplot(2,1,1)
    hold on
    plot(t(1:stop_idx), v(1:stop_idx)*3.6, colors{r}, 'LineWidth', 2)
    
    subplot(2,1,2)
    hold on
    plot(t(1:stop_idx), d(1:stop_idx), colors{r}, 'LineWidth', 2)
end

subplot(2,1,1)
xlabel('Time (seconds)')
ylabel('Speed (km/h)')
title('AEB System - Braking on Different Road Conditions')
legend('Dry Road mu=0.8', 'Wet Road mu=0.5', 'Icy Road mu=0.2')
grid on

subplot(2,1,2)
xlabel('Time (seconds)')
ylabel('Distance to Obstacle (m)')
title('AEB System - Distance on Different Road Conditions')
legend('Dry Road mu=0.8', 'Wet Road mu=0.5', 'Icy Road mu=0.2')
grid on