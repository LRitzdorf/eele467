# Lab 10: Modifying the Linux Device Tree

![hps_led_patterns in the Linux device tree](/images/lab-10-devtree.png)

> NOTE:
> The "compatible" string does not include a trailing newline, so simply `cat`ing it results in the output running together with the next line of the shell prompt.
> The addition of braces and an empty `echo` inserts such a newline, yielding a more readable result.
