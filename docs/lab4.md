# Lab 4: LED Patterns

## Hardware Architecture

Conceptually, the `LED_Patterns` component is relatively straightforward.
It consists of three primary stages, each addressed in their own section, and illustrated in the following diagram: clock generation, pattern generation, and output control.

![LED_Patterns block diagram](/images/lab-4.png)

### Clock Generation

The clock generator is a hierarchically-distinct module, which is configured via a list of clock scale factors.
These factors represent durations in seconds, and are interpreted as UQ4.4 values (unsigned, with four bits each for the integer and fractional parts).
They thus permit the configuration of up to 16 seconds of delay, with a resolution of 1/16<sup>th</sup> of a second.

It is worth noting that the output clocks do not have the usual 50% duty cycle — in fact, they strobe high for only a single cycle of the system clock.
However, they are still perfectly valid as drivers for the downstream pattern-generation logic.

### Pattern Generation

Once the pattern clocks have been generated, they serve to control the step speed of their respective pattern generator processes.
Each of these generators is a basic flip-flop, fed by a combinational "pattern core" which generates the next pattern based on the current one.
These generators are instantiated via VHDL *configurations*, which specify the appropriate pattern core to use, while leaving the pattern generator's structure and surrounding logic unchanged.

In addition, a single-bit "heartbeat" is produced, in order to validate that the hardware is indeed being clocked and other components of the design should also be functioning.
The heartbeat system also utilizes an output from the clock generator, but is implemented as a simple process, rather than a distinct module.

### Output Control

Once generated, all five patterns, plus the heartbeat bit and HPS pattern, are passed into a combinational dual-stage multiplexer.
This concatenates the heartbeat bit with the appropriate seven-bit pattern, then selects either this signal or the HPS pattern, according to the HPS override line.

In addition, the control state machine includes its own time counter, which controls the duration for which the switch values are passed through to the pattern output.
This functionality cannot be driven by a signal from the clock generator, since the one-second switch visibility window is asynchronous to the clock generator's one-second output.


## Custom LED Pattern

The custom pattern implemented for this project is a "chaser" light strip, as seen (for example) on the vehicle "KITT" from the 1980s TV show *Knight Rider*.
While it ultimately consists of simple bit-shifts, more sophisticated control logic is still required — for instance, the pattern must switch directions when "bouncing" off either end of the light strip.
In addition, the incandescent bulbs used in KITT's light strip gradually fade out, instead of turning off quickly as LEDs do.
This effect can be roughly approximated by shifting a set of two adjacent bits, instead of just one, and ensuring that the pattern runs fast enough (1/16<sup>th</sup> of a second per step) for persistence of vision to further improve the fading illusion.
The use of two adjacent bits also requires slightly more sophistication when dealing with the endpoints of the light strip, since the two bits "bouncing" directly off the edge of the strip does not faithfully reproduce the original pattern.
To mitigate this, the underlying pattern-generator logic actually works with a nine-bit vector, and extracts only the middle seven bits for display on the physical LED array.
