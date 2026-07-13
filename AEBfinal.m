%% AEB System - Complete Final Simulation
% Author: Garvit
% Erasmus+ Traineeship - Tomas Bata University Zlin
% July 2026

%% ============================================
%% COMPLETE AUTOMATIC EMERGENCY BRAKING SYSTEM
%% ============================================

%% Vehicle Parameters
m = 1500;
g = 9.81;
mu = 0.8;
dt = 0.01;

%% System Parameters
TTC_threshold = 2.0;    % Time to collision threshold (seconds)
t_reaction = 0.3;       % System reaction time (seconds)

%% Test Scenarios
scenarios = [
    50,  60;
    100, 80;
    130, 100];

scenario_names = {'City 50kmh Obstacle 60m', 'Highway 100kmh Obstacle 80m', 'Fast 130kmh Obstacle 100m'};
colors = {'g', 'b', 'r'};

figure(7)
clf

fprintf('==========================================\n')
fprintf('  COMPLETE AEB SYSTEM - FINAL RESULTS\n')
fprintf('==========================================\n')

for s = 1:3
    v0 = scenarios(s,1)/3.6;
    d0 = scenarios(s,2);
    F_max = mu * m * g;

    t = 0:dt:15;
    n = length(t);
    v = zeros(1,n);
    d = zeros(1,n);
    aeb_active = zeros(1,n);
    v(1) = v0;
    d(1) = d0;
    stop_idx = n;
    collision = 0;
    aeb_triggered = false;
    aeb_trigger_time = 0;

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
            F_brake = F_max;
            aeb_active(i) = 1;
        else
            F_brake = 0;
        end

        a = F_brake / m;
        v(i) = v(i-1) - a * dt;
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
        fprintf('%s\n  SAFE STOP at %.2fs | Remaining: %.2fm | AEB triggered at: %.2fs\n\n', scenario_names{s}, t(stop_idx), d(stop_idx), aeb_trigger_time)
    else
        fprintf('%s\n  COLLISION at %.2fs | AEB triggered at: %.2fs\n\n', scenario_names{s}, t(stop_idx), aeb_trigger_time)
    end

    subplot(3,1,1)
    hold on
    plot(t(1:stop_idx), v(1:stop_idx)*3.6, colors{s}, 'LineWidth', 2)

    subplot(3,1,2)
    hold on
    plot(t(1:stop_idx), d(1:stop_idx), colors{s}, 'LineWidth', 2)

    subplot(3,1,3)
    hold on
    plot(t(1:stop_idx), aeb_active(1:stop_idx), colors{s}, 'LineWidth', 2)
end

subplot(3,1,1)
xlabel('Time (seconds)')
ylabel('Speed (km/h)')
title('Complete AEB System - Vehicle Speed')
legend(scenario_names)
grid on

subplot(3,1,2)
xlabel('Time (seconds)')
ylabel('Distance to Obstacle (m)')
title('Complete AEB System - Distance to Obstacle')
legend(scenario_names)
grid on

subplot(3,1,3)
xlabel('Time (seconds)')
ylabel('AEB Active')
title('Complete AEB System - Braking Activation')
legend(scenario_names)
grid on
ylim([-0.1 1.5])

fprintf('==========================================\n')
fprintf('SYSTEM SUMMARY\n')
fprintf('TTC Threshold: %.1f seconds\n', TTC_threshold)
fprintf('Reaction Time: %.1f seconds\n', t_reaction)
fprintf('Max Braking Force: %.0f N\n', mu*m*g)
fprintf('Max Deceleration: %.2f m/s2\n', mu*g)
fprintf('==========================================\n')