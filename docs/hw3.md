# Homework 3: Signal Conditioning

## Debouncer Module

When its input changes, `Debouncer` latches the new value.
After a configurable number of clock cycles, it resumes monitoring for input changes, and will latch them as well.

![Debouncer simulation waveform](/images/hw-3-debouncer.png)


## OnePulse Module

When its input transitions from low to high, `OnePulse` generates a one-cycle-long output pulse.

![OnePulse simulation waveform](/images/hw-3-onepulse.png)


## Conditioner Module

`Conditioner` chains together its subsidiary `Synchronizer`, `Debouncer`, and `OnePulse` modules to produce a useful signal for later design stages.
Specifically, its output is a single pulse, in response to any low-to-high input transition, but ignoring bounciness within a specified time window.

![Conditioner simulation waveform](/images/hw-3-conditioner.png)

The accompanying testbench includes two basic, hard-coded test cases (short and long input pulses), as well as a set of five bouncy input cases.
These bouncy tests derive their input from a simulation-time pseudorandom number generation routine, eliminating the need to hard-code bouncy inputs and improving the general robustness of the testbench.
