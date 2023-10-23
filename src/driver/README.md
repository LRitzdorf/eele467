# LED_Patterns Driver

This driver is implemented as a loadable, out-of-tree kernel module.
Also, this version of the driver depends on a patched version of the [Altera SoC FPGA kernel](https://github.com/altera-opensource/linux-socfpga).
Instructions for patching are below.


## Kernel Patching

1. Clone the [Altera kernel repo](https://github.com/altera-opensource/linux-socfpga) and check out the appropriate branch.
   This patch was developed for 6.1.38 LTS (i.e. the `socfpga-6.1.38-lts` branch), but should work more generally as well.
   > **Tip:**
   > The Linux kernel is quite large.
   > Fortunately, Git allows cloning a single branch, via the invocation `git clone <uri> -b <branch> --single-branch`!
   > This should reduce download time somewhat, and can be combined with a shallow clone for greater effect.
1. Apply my [fixed-point parsing patch](0001-kstrtox-implement-kstrtoUQ44-for-fixed-point-parsing.patch) to the kernel, via `git am <path/to/the/file.patch>`.
1. Configure and compile the kernel as normal.
   Further relevant instructions for this process are available in the [device tree README](../devtree/README.md).
