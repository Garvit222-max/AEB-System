%% AEB System - Reaction Time Effect
% Author: Garvit
% Tomas Bata University - July 2026

%% Parameters
m = 1500;
g = 9.81;
mu = 0.8;
d0 = 80;
dt = 0.01;
v0 = 100/3.6;

%% Three Reaction Times
reaction_times = [0, 0.5, 1.0];
colors = {'g', 'b', 'r'};

figure(3)

for r = 1:3
    t_react = reaction_times(r);
    t = 0:dt:10;
    n = length(t);
    v = zeros(1,n);
    d = zeros(1,n);
    v(1) = v0;
    d(1) = d0;
    
    F_brake = mu * m * g;
    a_brake = F_brake / m;
    stop_idx = n;
    
    for i = 2:n
        if t(i) < t_react
            % Reaction delay - no braking yet
            v(i) = v(i-1);
        else
            % Braking applied
            v(i) = v(i-1) - a_brake * dt;
            if v(i) < 0
                v(i) = 0;
            end
        end
        
        d(i) = d(i-1) - v(i-1) * dt;
        
        if d(i) <= 0
            d(i) = 0;
            stop_idx = i;
            fprintf('Reaction %.1fs: COLLISION at %.2f s\n', t_react, t(i))
            break
        end
        if v(i) == 0
            stop_idx = i;
            fprintf('Reaction %.1fs: SAFE STOP | Remaining: %.2f m\n', t_react, d(i))
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
title('AEB System - Effect of Reaction Time on Braking')
legend('0s Instant AEB', '0.5s Delayed AEB', '1.0s Late AEB')
grid on

subplot(2,1,2)
xlabel('Time (seconds)')
ylabel('Distance to Obstacle (m)')
title('AEB System - Distance with Different Reaction Times')
legend('0s Instant AEB', '0.5s Delayed AEB', '1.0s Late AEB')
grid on