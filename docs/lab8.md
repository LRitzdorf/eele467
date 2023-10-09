# Lab 8: LED Patterns in C

The physical address formula for a component on a memory-mapped bus is *register[i] = bus offset + component offset + 4i* (since units are bytes and we have 32-bit registers).

For our `HPS_LED_Patterns` component on the lightweight bridge, this becomes *register[i] = 0xFF200000 + 0x0 + 4i*.
