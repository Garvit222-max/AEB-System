# AEB-System


## Automatic Emergency Braking System Simulation in MATLAB
**MATLAB/Simulink — Erasmus+ Traineeship 2026**

* **Author:** Garvit
* **University:** Tomas Bata University, Zlín, Czech Republic
* **Supervisor:** Assoc. Prof. Radek Matušů
* **Period:** July - August 2026

---

## Project Overview
Complete simulation of an Automatic Emergency Braking (AEB) System built in MATLAB R2024b/Simulink as part of an Erasmus+ traineeship at Tomas Bata University, Faculty of Applied Informatics. The repository features validated open-loop baselines alongside advanced closed-loop PID and sensor-fusion architectures.

---

## Repository Structure & Scripts

### Phase 1 — Core Analysis & Integration
* **`AEB_parameters.m`**: Basic vehicle calculations.
* **`AEB_simulation.m`**: Vehicle motion simulation.
* **`AEB_speed_comparison.m`**: Speed scenario analysis.
* **`AEBreaction.m`**: Reaction time analysis.
* **`AEBroads.m`**: Road condition analysis.
* **`AEBpid.m`**: PID braking controller.
* **`AEBoptimise.m`**: Braking optimisation.
* **`AEBfinal.m`**: Complete integrated system.

### Phase 2 — Improved Scripts & Advanced Modeling
* **`AEBsensor.m`**: Radar and camera sensor fusion with measurement noise.
* **`AEBmoving.m`**: Moving obstacle with relative speed calculation.
* **`AEBsigmoid.m`**: Sigmoid smooth braking vs instant braking.
* **`AEBcomfort.m`**: PID comfort vs safety vs balanced comparison.

### Automated Model Builders & Simulink Deliverables
* **`Build_AEB.m`**: Programmatic builder script for the advanced closed-loop PID and latched system[cite: 1].
* **`BuildAEB_Baseline.m`**: Automated script for structuring the baseline open-loop model[cite: 2].
* **`BuildAEB_PID.m`**: Automated script for upgrading the model with TTC logic and PID tuning[cite: 3].
* **`AEB_Baseline.slx`**: Baseline open-loop starting model[cite: 1, 2].
* **`AEB_Final_PID.slx`**: Definitive closed-loop final system featuring memory latches and optimal braking control[cite: 1, 3].

---

## Key Results & Engineering Findings
* **Stopping Performance:** Car at 100 km/h stops in 3.54 seconds.
* **Reaction Delay Impact:** Every 0.5 seconds of reaction delay costs 13 meters of safety margin.
* **Detection Limits:** The AEB system fails at 130 km/h with only an 80-meter detection range.
* **Braking Strategy:** Full braking leaves a 30-meter safety margin compared to only 2 meters for gentle braking.
* **Sensor Fusion:** Sensor noise can cause AEB system failure, which validates the critical need for radar and camera sensor fusion.
* **Passenger Comfort:** Sigmoid smooth braking significantly improves passenger comfort, with the balanced PID configuration delivering the best trade-off between safety and comfort.
* **Environmental Factors:** Icy road stopping distance is 4x longer than on dry roads, and relative speed calculations for moving obstacles are essential for realistic performance.
* **Triggering Mechanism:** Time-To-Collision (TTC) based triggering activates braking at the optimal moment[cite: 3].

---

## Tools Used
* MATLAB R2024b
* Simulink

---

## Supervisor Feedback
> Assoc. Prof. Radek Matušů — Tomas Bata University: *"Excellent progress with systematic approach"*
