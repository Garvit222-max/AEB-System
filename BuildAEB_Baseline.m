%% Build Structured AEB Simulink Model (Parameter Fix)
% Author: Garvit
% Erasmus+ Traineeship - Tomas Bata University Zlin

modelName = 'AEB_Complete';

% Close model if it's already open
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end

% Create and open new model
new_system(modelName);
open_system(modelName);
set_param(modelName, 'StopTime', '4');

fprintf('Building structured subsystems...\n');

%% 1. CREATE EMPTY SUBSYSTEMS
add_block('built-in/SubSystem', [modelName '/AEB Controller'], 'Position', [150, 120, 280, 200]);
add_block('built-in/SubSystem', [modelName '/Vehicle Dynamics'], 'Position', [400, 120, 550, 200]);

%% 2. BUILD AEB CONTROLLER (The Brain)
% FIXED PARAMETER NAMES: 'slope', 'start', 'X0'
add_block('simulink/Sources/Ramp', [modelName '/AEB Controller/Braking_Decel'], ...
    'slope', '-7.85', 'start', '0', 'X0', '27.78', 'Position', [50, 50, 90, 80]);

add_block('built-in/Outport', [modelName '/AEB Controller/Speed_Cmd'], 'Position', [200, 58, 230, 72]);
add_line([modelName '/AEB Controller'], 'Braking_Decel/1', 'Speed_Cmd/1');

%% 3. BUILD VEHICLE DYNAMICS (The Physics)
add_block('built-in/Inport', [modelName '/Vehicle Dynamics/Speed_In'], 'Position', [50, 100, 80, 115]);

add_block('simulink/Discontinuities/Saturation', [modelName '/Vehicle Dynamics/Speed_Limit'], ...
    'UpperLimit', '27.78', 'LowerLimit', '0', 'Position', [150, 95, 190, 125]);

add_block('simulink/Math Operations/Gain', [modelName '/Vehicle Dynamics/To_kmh'], ...
    'Gain', '3.6', 'Position', [280, 55, 320, 85]);
    
add_block('simulink/Math Operations/Gain', [modelName '/Vehicle Dynamics/Neg_Speed'], ...
    'Gain', '-1', 'Position', [280, 155, 320, 185]);
    
add_block('simulink/Continuous/Integrator', [modelName '/Vehicle Dynamics/Distance'], ...
    'InitialCondition', '80', 'LimitOutput', 'on', 'LowerSaturationLimit', '0', 'Position', [380, 155, 410, 185]);
    
add_block('built-in/Outport', [modelName '/Vehicle Dynamics/Speed_kmh'], 'Position', [480, 63, 510, 77], 'Port', '1');
add_block('built-in/Outport', [modelName '/Vehicle Dynamics/Distance_m'], 'Position', [480, 163, 510, 177], 'Port', '2');

% Wire Vehicle Dynamics
add_line([modelName '/Vehicle Dynamics'], 'Speed_In/1', 'Speed_Limit/1', 'autorouting', 'on');
add_line([modelName '/Vehicle Dynamics'], 'Speed_Limit/1', 'To_kmh/1', 'autorouting', 'on');
add_line([modelName '/Vehicle Dynamics'], 'Speed_Limit/1', 'Neg_Speed/1', 'autorouting', 'on');
add_line([modelName '/Vehicle Dynamics'], 'Neg_Speed/1', 'Distance/1', 'autorouting', 'on');
add_line([modelName '/Vehicle Dynamics'], 'To_kmh/1', 'Speed_kmh/1', 'autorouting', 'on');
add_line([modelName '/Vehicle Dynamics'], 'Distance/1', 'Distance_m/1', 'autorouting', 'on');

%% 4. TOP-LEVEL SCOPES & CONNECTIONS
add_block('simulink/Sinks/Scope', [modelName '/Speed_Scope'], 'Position', [650, 100, 690, 140]);
add_block('simulink/Sinks/Scope', [modelName '/Distance_Scope'], 'Position', [650, 180, 690, 220]);

% Connect Subsystems to Scopes
add_line(modelName, 'AEB Controller/1', 'Vehicle Dynamics/1', 'autorouting', 'on');
add_line(modelName, 'Vehicle Dynamics/1', 'Speed_Scope/1', 'autorouting', 'on');
add_line(modelName, 'Vehicle Dynamics/2', 'Distance_Scope/1', 'autorouting', 'on');

% Save and Run
save_system(modelName);
sim(modelName);

fprintf('SUCCESS: Structured model created without parameter errors!\n');