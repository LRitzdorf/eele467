# Lab 7: System Console and `/dev/mem`


## System Console Notes

```tcl
# Save the JTAG interface's path for later use
# NOTE: The index (0 in this example) may need to change!
set m [lindex [get_service_paths master] 0]

# Open the interface
open_service master $m

# Read a set of three registers, starting from base address zero
master_read_32 $m 0x0 3

# Write a set of two registers, starting from base address four (i.e. byte four; second register)
master_write_32 $m 0x4 0xAA 0x08

# Close the interface
close_service master $m
```

Address format: *register[i] = component address + 4i* (since units are bytes and we have 32-bit registers).


## `/dev/mem` Notes

Address format: *register[i] = lightweight bridge address + component address + 4i* (since units are bytes and we have 32-bit registers).

Lightweight bridge address is `0xFF20_0000`.


## Manipulating Timing via Registers

1. My system implements the `SYS_CLKs_sec` parameter as a VHDL generic, so it is not writable at runtime.
   However, if it were, we could double the displayed pattern speed by writing half of its usual value, which is 25,000,000.
   (This value can be entered as a decimal literal in the System Console.)
2. This speed doubling could be reversed (or rather, the existing speed halved in general) by writing a value representing 2 to the `Base_rate` register.
   In its hardware-backed UQ4.4 form, this corresponds to `0x20`.
