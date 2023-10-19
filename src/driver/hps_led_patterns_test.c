#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <errno.h>
#include <string.h>

#include "reg_offsets.h"

int main() {
    FILE *file = fopen ("/dev/hps_led_patterns" , "rb+" );
    if (file == NULL) {
        printf("Failed to open device file; check your permissions\n");
        exit(1);
    }
    size_t ret;

    // Create a place to store register values
    unsigned int val;


    // Test reading the regsiters sequentially
    printf(":: Reading all registers...\n");

    fread(&val, 4, 1, file);
    printf(" HPS_LED_control contains 0x%X\n", val);

    fread(&val, 4, 1, file);
    printf(" LED_reg contains 0x%X\n", val);

    fread(&val, 4, 1, file);
    printf(" Base_rate contains 0x%X\n", val);

    fread(&val, 4, 1, file);
    printf(" Empty register contains 0x%X\n", val);


    // Seek back to beginning of device file
    printf(":: Seeking to beginning of device file\n");
    ret = fseek(file, 0, SEEK_SET);
    printf(" fseek returned %u (%s)\n", ret, strerror(errno));

    // Write to all registers using fseek
    printf(":: Writing directly to all registers...\n");

    val = 1;
    printf(" writing 0x%X to LED_reg\n", val);
    fseek(file, REG0_HPS_LED_CONTROL_OFFSET, SEEK_SET);
    fwrite(&val, 4, 1, file);

    val = 0xAA;
    printf(" writing 0x%X to LED_reg\n", val);
    fseek(file, REG1_LED_REG_OFFSET, SEEK_SET);
    fwrite(&val, 4, 1, file);

    val = 0x57;
    printf(" writing 0x%X to LED_reg\n", val);
    fseek(file, REG2_BASE_RATE_OFFSET, SEEK_SET);
    fwrite(&val, 4, 1, file);


    // Seek back to beginning of device file
    printf(":: Seeking to beginning of device file\n");
    ret = fseek(file, 0, SEEK_SET);
    printf(" fseek returned %u (errno %s)\n", ret, strerror(errno));

    // Read back values just written
    printf(":: Reading back all registers...\n");

    fread(&val, 4, 1, file);
    printf(" HPS_LED_control contains 0x%X\n", val);

    fread(&val, 4, 1, file);
    printf(" LED_reg contains 0x%X\n", val);

    fread(&val, 4, 1, file);
    printf(" Base_rate contains 0x%X\n", val);


    // Clean up and exit
    fclose(file);
    return 0;
}
