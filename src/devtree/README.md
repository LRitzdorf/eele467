# Customized SoC Device Tree

This project requires overriding the Linux device tree so that we may integrate our custom LED pattern generator.


## Procedure

1. Clone [Altera's Linux kernel repo](https://github.com/altera-opensource/linux-socfpga).
   Configure the kernel as desired and compile.
1. Inject our custom device tree into the kernel source.
   This process is described in further detail below.


## Examples

Key settings and parameters used in this project are described here, for the sake of reproducibility.

### Kernel Compilation

Enable the following kernel options:
- `CONFIG_DEBUG_KERNEL`
- `CONFIG_DEBUG_SLAB`
- `CONFIG_DEBUG_DRIVER`
- `CONFIG_MODULE_FORCE_UNLOAD`

Note that the kernel module Makefile provided here will assume the kernel repo is located at `~/linux-socfpga`, though this can be overridden by exporting `KDIR` to point to a different directory.

### Device Tree Injection

Injecting our custom device tree into the kernel requires some light modification.
1. Move into the `arch/arm/boot/dts` directory.
1. Make the existing device tree source file available as a device tree include file:
   `ln -s socfpga_cyclone5_de0_nano_soc.dts{,i}`
1. Make our custom device tree available in the kernel repo:
   `ln -s {<path to this repo>/src/devtree/,}socfpga_cyclone5_de10nano_ledpatterns.dts`
1. Add our custom device tree to the kernel's Makefile in this directory.
   For the `6.1.38-lts` kernel, that change looks like:
   ```diff
   diff --git a/arch/arm/boot/dts/Makefile b/arch/arm/boot/dts/Makefile
   index 6aa7dc4db2fc..a741390cc0de 100644
   --- a/arch/arm/boot/dts/Makefile
   +++ b/arch/arm/boot/dts/Makefile
   @@ -1179,6 +1179,7 @@ dtb-$(CONFIG_ARCH_INTEL_SOCFPGA) += \
    	socfpga_cyclone5_mcvevk.dtb \
    	socfpga_cyclone5_socdk.dtb \
    	socfpga_cyclone5_de0_nano_soc.dtb \
   +	socfpga_cyclone5_de10nano_ledpatterns.dtb \
    	socfpga_cyclone5_sockit.dtb \
    	socfpga_cyclone5_socrates.dtb \
    	socfpga_cyclone5_sodia.dtb \
   ```
1. Move up to the root of the kernel repo and rebuild the device trees:
   `make ARCH=arm dtbs`
1. Retrieve the newly-built device tree blob from `arch/arm/boot/dts/socfpga_cyclone5_de10nano_ledpatterns.dtb`.
