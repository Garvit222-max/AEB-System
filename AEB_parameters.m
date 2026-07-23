%% Automatic Emergency Braking System
% Author: Garvit
% Erasmus+ Traineeship - Tomas Bata University Zlin
% July 2026

%% Vehicle Parameters
m = 1500;        % Vehicle mass (kg)
v0 = 100/3.6;    % Initial speed 100 km/h to m/s
d0 = 80;         % Distance to obstacle (m)
g = 9.81;        % Gravity (m/s2)
mu = 0.8;        % Road friction coefficient

%% Calculations
F_brake = mu * m * g;        % Maximum braking force (N)
a_max = F_brake / m;         % Maximum deceleration (m/s2)
d_stop = (v0^2)/(2*a_max);  % Minimum stopping distance (m)
TTC = d0/v0;                 % Time to collision (seconds)

%% Display Results
fprintf('================================\n')
fprintf('  AEB SYSTEM - INITIAL ANALYSIS \n')
fprintf('================================\n')
fprintf('Vehicle mass:        %d kg\n', m)
fprintf('Initial speed:       %.1f km/h\n', v0*3.6)
fprintf('Obstacle distance:   %d m\n', d0)
fprintf('Max braking force:   %.1f N\n', F_brake)
fprintf('Max deceleration:    %.2f m/s2\n', a_max)
fprintf('Stopping distance:   %.2f m\n', d_stop)
fprintf('Time to collision:   %.2f s\n', TTC)
fprintf('================================\n')

%% Safety Check
if d_stop < d0
    fprintf('RESULT: SAFE - Car stops before obstacle\n')
else
    fprintf('RESULT: COLLISION - AEB system needed!\n')
end
fprintf('================================\n')