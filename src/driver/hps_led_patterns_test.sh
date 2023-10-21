#!/bin/sh
# Test driver for the hps_led_patterns device, via its custom kernel driver

device=/sys/class/misc/hps_led_patterns
regs="hps_led_control led_reg base_rate"

# Helper functions
read_register () {
    contents=`cat "$device/$1"`
    echo " $1 contains $contents"
}
write_register () {
    echo " writing $2 to $1"
    echo "$2" > "$device/$1"
}


# Main test sequence

echo ":: Reading register files..."
for reg in $regs
do
    read_register $reg
done

echo ":: Writing register files..."
write_register hps_led_control 1
write_register led_reg 0xAA
write_register base_rate 5.4375

echo ":: Re-reading register files..."
for reg in $regs
do
    read_register $reg
done
