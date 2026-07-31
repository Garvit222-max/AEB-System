%% Upgrade AEB Model to Full Closed-Loop PID (Latched & Tuned)
% Author: Garvit
% Erasmus+ Traineeship - Tomas Bata University Zlin

modelName = 'AEB_Advanced';

% Close if already open
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end

new_system(modelName);
open_system(modelName);
set_param(modelName, 'StopTime', '4');
set_param(modelName, 'ZeroCrossControl', 'DisableAll'); 

%% 1. CREATE EMPTY SUBSYSTEMS
add_block('built-in/SubSystem', [modelName '/Environment'], 'Position', [30, 120, 110, 200]);
add_block('built-in/SubSystem', [modelName '/AEB Controller'], 'Position', [150, 120, 280, 200]);
add_block('built-in/SubSystem', [modelName '/Vehicle Dynamics'], 'Position', [400, 120, 550, 200]);

%% 2. BUILD ENVIRONMENT
add_block('simulink/Sources/Constant', [modelName '/Environment/Init_Speed'], 'Value', '27.78', 'Position', [30, 40, 70, 70]);
add_block('simulink/Sources/Constant', [modelName '/Environment/Init_Dist'], 'Value', '80', 'Position', [30, 100, 70, 130]);
add_block('built-in/Outport', [modelName '/Environment/V_env'], 'Position', [120, 48, 150, 62], 'Port', '1');
add_block('built-in/Outport', [modelName '/Environment/D_env'], 'Position', [120, 108, 150, 122], 'Port', '2');
add_line([modelName '/Environment'], 'Init_Speed/1', 'V_env/1', 'autorouting', 'on');
add_line([modelName '/Environment'], 'Init_Dist/1', 'D_env/1', 'autorouting', 'on');

%% 3. BUILD AEB CONTROLLER (Latched Logic + Proper Error PID)
add_block('built-in/Inport', [modelName '/AEB Controller/Current_Speed'], 'Position', [50, 60, 80, 74], 'Port', '1');
add_block('built-in/Inport', [modelName '/AEB Controller/Current_Distance'], 'Position', [50, 140, 80, 154], 'Port', '2');

% TTC Calculation & Trigger
add_block('simulink/Math Operations/Divide', [modelName '/AEB Controller/TTC_Calc'], 'Inputs', '*/', 'Position', [120, 95, 150, 125]);
add_block('simulink/Logic and Bit Operations/Compare To Constant', [modelName '/AEB Controller/TTC_Trigger'], 'relop', '<=', 'const', '2.0', 'Position', [180, 95, 220, 125]);

% Latch Mechanism (Locks brakes ON once triggered)
add_block('simulink/Logic and Bit Operations/Logical Operator', [modelName '/AEB Controller/OR_Latch'], 'Operator', 'OR', 'Position', [260, 100, 290, 130]);
add_block('simulink/Discrete/Memory', [modelName '/AEB Controller/Mem_Latch'], 'Position', [260, 150, 290, 180], 'BlockMirror', 'on');
add_block('simulink/Signal Attributes/Data Type Conversion', [modelName '/AEB Controller/Type_Conv'], 'OutDataTypeStr', 'double', 'Position', [320, 105, 360, 125]);

% Target Speed Switch (27.78 normally, drops to 0 when triggered)
add_block('simulink/Sources/Constant', [modelName '/AEB Controller/Zero_Target'], 'Value', '0', 'Position', [350, 60, 380, 90]);
add_block('simulink/Sources/Constant', [modelName '/AEB Controller/V_init_Target'], 'Value', '27.78', 'Position', [350, 150, 380, 180]);
add_block('simulink/Signal Routing/Switch', [modelName '/AEB Controller/Target_Switch'], 'Criteria', 'u2 >= Threshold', 'Threshold', '0.5', 'Position', [420, 95, 450, 125]);

% Error Calculation & PID (Tuned for smooth braking)
add_block('simulink/Math Operations/Sum', [modelName '/AEB Controller/Error_Sum'], 'Inputs', '+-', 'Position', [490, 95, 510, 125]);
add_block('simulink/Continuous/PID Controller', [modelName '/AEB Controller/PID_Brake'], 'P', '0.1', 'I', '0.8', 'D', '0', 'Position', [550, 92, 590, 128]);

% Feedforward & Saturation
add_block('simulink/Sources/Constant', [modelName '/AEB Controller/V_init_FF'], 'Value', '27.78', 'Position', [580, 40, 620, 70]);
add_block('simulink/Math Operations/Sum', [modelName '/AEB Controller/FF_Sum'], 'Inputs', '++', 'Position', [640, 80, 660, 110]);
add_block('simulink/Discontinuities/Saturation', [modelName '/AEB Controller/Speed_Sat'], 'UpperLimit', '27.78', 'LowerLimit', '0', 'Position', [690, 80, 720, 110]);
add_block('built-in/Outport', [modelName '/AEB Controller/Speed_Cmd'], 'Position', [760, 88, 790, 102], 'Port', '1');

% Wiring AEB Controller
add_line([modelName '/AEB Controller'], 'Current_Distance/1', 'TTC_Calc/1', 'autorouting', 'on');
add_line([modelName '/AEB Controller'], 'Current_Speed/1', 'TTC_Calc/2', 'autorouting', 'on');
add_line([modelName '/AEB Controller'], 'Current_Speed/1', 'Error_Sum/2', 'autorouting', 'on');
add_line([modelName '/AEB Controller'], 'TTC_Calc/1', 'TTC_Trigger/1', 'autorouting', 'on');
add_line([modelName '/AEB Controller'], 'TTC_Trigger/1', 'OR_Latch/1', 'autorouting', 'on');
add_line([modelName '/AEB Controller'], 'Mem_Latch/1', 'OR_Latch/2', 'autorouting', 'on');
add_line([modelName '/AEB Controller'], 'OR_Latch/1', 'Mem_Latch/1', 'autorouting', 'on');
add_line([modelName '/AEB Controller'], 'OR_Latch/1', 'Type_Conv/1', 'autorouting', 'on');
add_line([modelName '/AEB Controller'], 'Zero_Target/1', 'Target_Switch/1', 'autorouting', 'on');
add_line([modelName '/AEB Controller'], 'Type_Conv/1', 'Target_Switch/2', 'autorouting', 'on');
add_line([modelName '/AEB Controller'], 'V_init_Target/1', 'Target_Switch/3', 'autorouting', 'on');
add_line([modelName '/AEB Controller'], 'Target_Switch/1', 'Error_Sum/1', 'autorouting', 'on');
add_line([modelName '/AEB Controller'], 'Error_Sum/1', 'PID_Brake/1', 'autorouting', 'on');
add_line([modelName '/AEB Controller'], 'V_init_FF/1', 'FF_Sum/1', 'autorouting', 'on');
add_line([modelName '/AEB Controller'], 'PID_Brake/1', 'FF_Sum/2', 'autorouting', 'on');
add_line([modelName '/AEB Controller'], 'FF_Sum/1', 'Speed_Sat/1', 'autorouting', 'on');
add_line([modelName '/AEB Controller'], 'Speed_Sat/1', 'Speed_Cmd/1', 'autorouting', 'on');

%% 4. BUILD VEHICLE DYNAMICS (Physics)
add_block('built-in/Inport', [modelName '/Vehicle Dynamics/Speed_In'], 'Position', [50, 100, 80, 115]);
add_block('simulink/Discontinuities/Saturation', [modelName '/Vehicle Dynamics/Speed_Limit'], 'UpperLimit', '27.78', 'LowerLimit', '0', 'Position', [150, 95, 190, 125]);
add_block('simulink/Math Operations/Gain', [modelName '/Vehicle Dynamics/To_kmh'], 'Gain', '3.6', 'Position', [280, 55, 320, 85]);
add_block('simulink/Math Operations/Gain', [modelName '/Vehicle Dynamics/Neg_Speed'], 'Gain', '-1', 'Position', [280, 155, 320, 185]);
add_block('simulink/Continuous/Integrator', [modelName '/Vehicle Dynamics/Distance'], 'InitialCondition', '80', 'LimitOutput', 'on', 'LowerSaturationLimit', '0', 'Position', [380, 155, 410, 185]);
add_block('built-in/Outport', [modelName '/Vehicle Dynamics/Speed_kmh'], 'Position', [480, 63, 510, 77], 'Port', '1');
add_block('built-in/Outport', [modelName '/Vehicle Dynamics/Distance_m'], 'Position', [480, 163, 510, 177], 'Port', '2');

add_line([modelName '/Vehicle Dynamics'], 'Speed_In/1', 'Speed_Limit/1', 'autorouting', 'on');
add_line([modelName '/Vehicle Dynamics'], 'Speed_Limit/1', 'To_kmh/1', 'autorouting', 'on');
add_line([modelName '/Vehicle Dynamics'], 'Speed_Limit/1', 'Neg_Speed/1', 'autorouting', 'on');
add_line([modelName '/Vehicle Dynamics'], 'Neg_Speed/1', 'Distance/1', 'autorouting', 'on');
add_line([modelName '/Vehicle Dynamics'], 'To_kmh/1', 'Speed_kmh/1', 'autorouting', 'on');
add_line([modelName '/Vehicle Dynamics'], 'Distance/1', 'Distance_m/1', 'autorouting', 'on');

%% 5. TOP-LEVEL CONNECTIONS, SCOPES & MEMORY BLOCKS
add_block('simulink/Sinks/Scope', [modelName '/Speed_Scope'], 'Position', [700, 100, 740, 140]);
add_block('simulink/Sinks/Scope', [modelName '/Distance_Scope'], 'Position', [700, 180, 740, 220]);

add_block('simulink/Discrete/Memory', [modelName '/Mem_Speed'], 'Position', [310, 240, 340, 270], 'BlockMirror', 'on');
add_block('simulink/Discrete/Memory', [modelName '/Mem_Dist'], 'Position', [310, 290, 340, 320], 'BlockMirror', 'on');

add_line(modelName, 'AEB Controller/1', 'Vehicle Dynamics/1', 'autorouting', 'on');
add_line(modelName, 'Vehicle Dynamics/1', 'Speed_Scope/1', 'autorouting', 'on');
add_line(modelName, 'Vehicle Dynamics/2', 'Distance_Scope/1', 'autorouting', 'on');

add_line(modelName, 'Vehicle Dynamics/1', 'Mem_Speed/1', 'autorouting', 'on');
add_line(modelName, 'Vehicle Dynamics/2', 'Mem_Dist/1', 'autorouting', 'on');
add_line(modelName, 'Mem_Speed/1', 'AEB Controller/1', 'autorouting', 'on');
add_line(modelName, 'Mem_Dist/1', 'AEB Controller/2', 'autorouting', 'on');

save_system(modelName);
sim(modelName);