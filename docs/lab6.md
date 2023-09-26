# Lab 6: Platform Designer

The registers contained in the `HPS_LED_Patterns` module are sized to match the signals they hold, despite being connected to a 32-bit bus.
Accordingly, additional leading digits are prepended to the signals (extending them to 32 bits) when they are read, and those extra bit positions are simply ignored when the registers are written to.

These registers are connected to the HPS itself via the Avalon lightweight HPS-to-FPGA bridge.
Via this interface, they will be made available in the ARM CPUs' memory map.
In order to actually read or write the registers, an address must be provided, and either a read- or write-enable signal must be asserted by the Avalon interconnect.

The base address of the `HPS_LED_patterns` module (within Platform Designer) is `0x0000_0000`.
If it were anything else, the Avalon interconnect would perform a layer of address translation, passing a zero-based address to the relevant peripheral on the bus.
