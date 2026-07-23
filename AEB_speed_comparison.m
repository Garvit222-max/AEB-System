%% AEB System - Multiple Speed Analysis
% Author: Garvit
% Tomas Bata University - July 2026

%% Parameters
m = 1500;
g = 9.81;
mu = 0.8;
d0 = 80;
dt = 0.01;

%% Test Three Scenarios
speeds = [50, 100, 130];
colors = {'g', 'b', 'r'};

figure(2)

for s = 1:3
    v0 = speeds(s)/3.6;
    t = 0:dt:15;
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
            fprintf('Speed %d kmh: COLLISION at %.2f s\n', speeds(s), t(i))
            break
        end
        if v(i) == 0
            stop_idx = i;
            fprintf('Speed %d kmh: SAFE STOP at %.2f s | Remaining: %.2f m\n', speeds(s), t(i), d(i))
            break
        end
    end
    
    subplot(2,1,1)
    hold on
    plot(t(1:stop_idx), v(1:stop_idx)*3.6, colors{s}, 'LineWidth', 2)
    
    subplot(2,1,2)
    hold on
    plot(t(1:stop_idx), d(1:stop_idx), colors{s}, 'LineWidth', 2)
end

subplot(2,1,1)
xlabel('Time (seconds)')
ylabel('Speed (km/h)')
title('AEB System - Speed Comparison')
legend('50 km/h City', '100 km/h Highway', '130 km/h Fast Highway')
grid on

subplot(2,1,2)
xlabel('Time (seconds)')
ylabel('Distance to Obstacle (m)')
title('AEB System - Distance Comparison')
legend('50 km/h City', '100 km/h Highway', '130 km/h Fast Highway')
grid on