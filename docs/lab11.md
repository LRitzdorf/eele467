# Lab 11: Platform Device Driver

The `hps_led_patterns` device driver consists of two primary components (register-level interfaces and the character device), described below.

## Register-Level Interfaces

User-tunable parameters of a device are exposed via the "system filesystem," or "sysfs" for short.
These might include such features as display backlight and keyboard status LED states.

In this case, the three configuration inputs for the `LED_Patterns` module (`hps_led_control`, `led_reg`, and `base_rate`)  are exposed as 32-bit registers on the lightweight HPS-to-fabric bus.
The device driver presents each register via its own sysfs entry (located in `/sys/class/misc/hps_led_patterns`).
Writing to or reading from such an entry triggers a corresponding function in the driver, which performs appropriate memory reads, writes, and translation steps from character strings to binary and back.
This allows user applications to read and write the registers using a more familiar format — for example, writing `2.125` instead of the equivalent fixed-point `0x22`.

## Character Device

In addition to friendly user-facing pseudo-files, the driver provides a "character device" at `/dev/hps_led_patterns`.
This provides direct access to the full set of control registers exposed on the lightweight bus, in the sequence that they are addressed and mapped into memory.

Similar character-level interfaces exist for hardware such as disk drives, which provide direct access to (for example) raw disk contents.
