# Configurable PWM Generator with Dead-Time Insertion

RTL implementation of a PWM generation engine with dead-time insertion
for BLDC gate driver applications, targeting EV motor control systems.

## Modules
- `pwm_gen.v` — Configurable PWM generator with adjustable duty cycle and period
- `dead_time.v` — Dead-time insertion module preventing shoot-through on gate pairs

## Results
- Clock frequency: 100 MHz
- Dead-time: 40 ns (consistent across all duty cycles)
- Shoot-through violations: 0 across 11 test cases (0% to 100% duty cycle sweep)

## Simulation
Install [Icarus Verilog](http://bleyer.org/icarus/) then run:
```bash
iverilog -o sweep.out pwm_gen.v dead_time.v tb_sweep.v
vvp sweep.out
```

## Tools
- Icarus Verilog
- GTKWave
