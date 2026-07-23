# AEB-System
Automatic Emergency Braking System Simulation in MATLAB - Erasmus Traineeship Tomas Bata University 2026
# Automatic Emergency Braking System Simulation
## MATLAB/Simulink - Erasmus+ Traineeship 2026

**Author:** Garvit
**University:** Tomas Bata University, Zlín, Czech Republic
**Supervisor:** Assoc. Prof. Radek Matušů
**Period:** July - August 2026

## Project Overview
Complete simulation of an Automatic Emergency Braking System 
built in MATLAB R2024b as part of Erasmus+ traineeship at 
Tomas Bata University, Faculty of Applied Informatics.

## Scripts

| Script | Description |
|--------|-------------|
| AEB_parameters.m | Basic vehicle calculations |
| AEB_simulation.m | Vehicle motion simulation |
| AEB_speed_comparison.m | Speed scenario analysis |
| AEBreaction.m | Reaction time analysis |
| AEBroads.m | Road condition analysis |
| AEBpid.m | PID braking controller |
| AEBoptimise.m | Braking optimisation |
| AEBfinal.m | Complete integrated system |

## Key Results
- Car at 100 km/h stops in 3.54 seconds
- Every 0.5s reaction delay costs 13m safety margin
- AEB fails at 130 km/h with only 80m detection range
- Full braking leaves 30m safety margin vs 2m for gentle braking
- TTC based triggering activates braking at optimal moment

## Tools Used
- MATLAB R2024b
- Simulink (coming next week)
## Phase 2 — Improved Scripts
## Based on Supervisor Feedback — July 2026

| Script | Description |
|--------|-------------|
| AEBsensor.m | Radar and camera sensor fusion with measurement noise |
| AEBmoving.m | Moving obstacle with relative speed calculation |
| AEBsigmoid.m | Sigmoid smooth braking vs instant braking |
| AEBcomfort.m | PID comfort vs safety vs balanced comparison |

## Key Engineering Findings

1. Every 0.5 second reaction delay costs 13 metres of safety margin
2. Sensor noise can cause AEB system failure — validates sensor fusion need
3. Sigmoid braking significantly improves passenger comfort
4. Balanced PID gives best trade-off between safety and comfort
5. AEB fails at 130 km/h with 80 metre detection range
6. Icy road stopping distance is 4x longer than dry road
7. Moving obstacle relative speed calculation is critical for realistic AEB

## Supervisor Feedback
Prof. Radek Matušů — Tomas Bata University:
"Excellent progress with systematic approach"
