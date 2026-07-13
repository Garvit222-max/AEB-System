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

