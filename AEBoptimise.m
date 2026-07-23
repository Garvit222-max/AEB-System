%% AEB System - Braking Optimisation
% Author: Garvit
% Tomas Bata University - July 2026

m = 1500;
g = 9.81;
mu = 0.8;
d0 = 80;
dt = 0.01;
v0 = 100/3.6;
F_max = mu * m * g;

profiles = [0.3, 0.7, 1.0];
names = {'Gentle 30%', 'Moderate 70%', 'Full 100%'};
colors = {'g', 'b', 'r'};

figure(6)
clf

fprintf('=== BRAKING OPTIMISATION ===\n')

for s = 1:3

    F_brake = profiles(s) * F_max;
    a_brake = F_brake / m;

    t = 0:dt:15;
    n = length(t);
    v = zeros(1,n);
    d = zeros(1,n);
    v(1) = v0;
    d(1) = d0;
    stop_idx = n;
    collision = 0;

    for i = 2:n
        v(i) = v(i-1) - a_brake * dt;
        if v(i) < 0
            v(i) = 0;
        end
        d(i) = d(i-1) - v(i-1) * dt;
        if d(i) <= 0
            d(i) = 0;
            stop_idx = i;
            collision = 1;
            break
        end
        if v(i) == 0
            stop_idx = i;
            break
        end
    end

    if collision == 0
        fprintf('%s | SAFE | %.2fs | %.2fm remaining\n', names{s}, t(stop_idx), d(stop_idx))
    else
        fprintf('%s | COLLISION at %.2fs\n', names{s}, t(stop_idx))
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
title('AEB Optimisation - Braking Profile Comparison')
legend(names)
grid on

subplot(2,1,2)
xlabel('Time (seconds)')
ylabel('Distance to Obstacle (m)')
title('AEB Optimisation - Distance Comparison')
legend(names)
grid on

fprintf('============================\n')
fprintf('Full braking stops fastest\n')
fprintf('Gentle braking improves comfort\n')
fprintf('Optimal AEB uses graduated strategy\n')