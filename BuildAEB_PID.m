%% Upgrade AEB Model to Full PID & Environment Subsystems
% Author: Garvit
% Erasmus+ Traineeship - Tomas Bata University Zlin

modelName = 'AEB_Complete';

% Ensure model is open
if ~bdIsLoaded(modelName)
    open_system(modelName);
end

fprintf('Upgrading AEB Controller with PID & TTC logic...\n');

%% 1. CLEAR AND REBUILD AEB CONTROLLER INTERNALS
controllerPath = [modelName '/AEB Controller'];

% Remove existing elements to prevent line/port overlap
Simulink.BlockDiagram.deleteContents(controllerPath);

% Add Inports for Feedback
add_block('built-in/Inport', [controllerPath '/Current_Speed'], 'Position', [50, 60, 80, 74], 'Port', '1');
add_block('built-in/Inport', [controllerPath '/Current_Distance'], 'Position', [50, 140, 80, 154], 'Port', '2');

% Add TTC Calculation (TTC = Distance / Speed)
add_block('simulink/Math Operations/Divide', [controllerPath '/TTC_Calc'], ...
    'Inputs', '/*Position', [160, 95, 190, 125]);

% Compare TTC <= 2.0s threshold
add_block('simulink/Logic and Bit Operations/Compare To Constant', [controllerPath '/TTC_Trigger'], ...
    'relop', '<=', 'const', '2.0', 'Position', [230, 95, 280, 125]);

% PID Controller Block (Kp=800, Ki=50, Kd=100)
add_block('simulink/Continuous/PID Controller', [controllerPath '/PID_Brake'], ...
    'P', '800', 'I', '50', 'D', '100', 'Position', [330, 92, 370, 128]);

% Gain to convert control output to deceleration curve
add_block('simulink/Math Operations/Gain', [controllerPath '/Decel_Gain'], ...
    'Gain', '-0.01', 'Position', [410, 95, 450, 125]);

% Add Initial Speed offset (27.78 m/s = 100 km/h)
add_block('simulink/Sources/Constant', [controllerPath '/V_init'], ...
    'Value', '27.78', 'Position', [410, 45, 450, 75]);

add_block('simulink/Math Operations/Add', [controllerPath '/Speed_Combine'], ...
    'Inputs', '++', 'Position', [480, 60, 500, 110]);

% Outport
add_block('built-in/Outport', [controllerPath '/Speed_Cmd'], 'Position', [540, 78, 570, 92], 'Port', '1');

% Wire internal AEB Controller
add_line(controllerPath, 'Current_Distance/1', 'TTC_Calc/1', 'autorouting', 'on');
add_line(controllerPath, 'Current_Speed/1', 'TTC_Calc/2', 'autorouting', 'on');
add_line(controllerPath, 'TTC_Calc/1', 'TTC_Trigger/1', 'autorouting', 'on');
add_line(controllerPath, 'TTC_Trigger/1', 'PID_Brake/1', 'autorouting', 'on');
add_line(controllerPath, 'PID_Brake/1', 'Decel_Gain/1', 'autorouting', 'on');
add_line(controllerPath, 'V_init/1', 'Speed_Combine/1', 'autorouting', 'on');
add_line(controllerPath, 'Decel_Gain/1', 'Speed_Combine/2', 'autorouting', 'on');
add_line(controllerPath, 'Speed_Combine/1', 'Speed_Cmd/1', 'autorouting', 'on');

%% 2. ADD ENVIRONMENT SUBSYSTEM AT TOP-LEVEL
if isempty(find_system(modelName, 'SearchDepth', 1, 'Name', 'Environment'))
    add_block('built-in/SubSystem', [modelName '/Environment'], 'Position', [30, 120, 110, 200]);
    add_block('simulink/Sources/Constant', [modelName '/Environment/Init_Speed'], 'Value', '27.78', 'Position', [30, 40, 70, 70]);
    add_block('simulink/Sources/Constant', [modelName '/Environment/Init_Dist'], 'Value', '80', 'Position', [30, 100, 70, 130]);
    add_block('built-in/Outport', [modelName '/Environment/V_env'], 'Position', [120, 48, 150, 62], 'Port', '1');
    add_block('built-in/Outport', [modelName '/Environment/D_env'], 'Position', [120, 108, 150, 122], 'Port', '2');
    add_line([modelName '/Environment'], 'Init_Speed/1', 'V_env/1', 'autorouting', 'on');
    add_line([modelName '/Environment'], 'Init_Dist/1', 'D_env/1', 'autorouting', 'on');
end

%% 3. WIRE TOP-LEVEL FEEDBACK LOOPS
% Delete existing top-level lines to re-wire cleanly
lines = get_param(modelName, 'Lines');
for i = 1:length(lines)
    if lines(i).Handle ~= -1
        delete_line(lines(i).Handle);
    end
end

% Connect Controller to Vehicle Dynamics
add_line(modelName, 'AEB Controller/1', 'Vehicle Dynamics/1', 'autorouting', 'on');

% Connect Vehicle Dynamics outputs back into Controller inputs (Feedback Loop)
add_line(modelName, 'Vehicle Dynamics/1', 'AEB Controller/1', 'autorouting', 'on');
add_line(modelName, 'Vehicle Dynamics/2', 'AEB Controller/2', 'autorouting', 'on');

% Connect to Scopes
add_line(modelName, 'Vehicle Dynamics/1', 'Speed_Scope/1', 'autorouting', 'on');
add_line(modelName, 'Vehicle Dynamics/2', 'Distance_Scope/1', 'autorouting', 'on');

save_system(modelName);
sim(modelName);

fprintf('SUCCESS: Full PID Controller and Feedback Loop built!\n');