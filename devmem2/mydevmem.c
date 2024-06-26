/*
 * devmem2.c: Simple program to read/write from/to any location in memory.
 *
 *  Copyright (C) 2000, Jan-Derk Bakker (jdb@lartmaker.nl)
 *
 *
 * This software has been developed for the LART computing board
 * (http://www.lart.tudelft.nl/). The development has been sponsored by
 * the Mobile MultiMedia Communications (http://www.mmc.tudelft.nl/)
 * and Ubiquitous Communications (http://www.ubicom.tudelft.nl/)
 * projects.
 *
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <signal.h>
#include <fcntl.h>
#include <ctype.h>
#include <termios.h>
#include <sys/types.h>
#include <sys/mman.h>

#define FATAL do { fprintf(stderr, "Error at line %d, file %s (%d) [%s]\n", \
  __LINE__, __FILE__, errno, strerror(errno)); exit(1); } while(0)

int main(int argc, char **argv) {
    int fd;
    void *map_base, *virt_addr;
    unsigned long read_result, writeval;
    off_t target;
    int access_type = 'w';

    long map_size = sysconf(_SC_PAGESIZE);
    long map_mask = (map_size - 1);

    if(argc < 2) {
        fprintf(stderr, "\nUsage:\t%s { address } [ type [ data ] ]\n"
            "\taddress : memory address to act upon\n"
            "\ttype    : access operation type : [b]yte, [h]alfword, [w]ord\n"
            "\tdata    : data to be written\n"
            "System reports page size of %ld bytes\n\n",
            argv[0], map_size);
        exit(1);
    }
    target = strtoul(argv[1], 0, 0);

    if(argc > 2)
        access_type = tolower(argv[2][0]);


    if((fd = open("/dev/mem", O_RDWR | O_SYNC)) == -1) FATAL;
    printf("/dev/mem opened.\n");
    fflush(stdout);

    /* Map one page */
    map_base = mmap(0, map_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, target & ~map_mask);
    if(map_base == (void *) -1) FATAL;
    printf("Memory mapped at address %p.\n", map_base);
    fflush(stdout);

    virt_addr = map_base + (target & map_mask);
    switch(access_type) {
        case 'b':
            read_result = *((unsigned char *) virt_addr);
            break;
        case 'h':
            read_result = *((unsigned short *) virt_addr);
            break;
        case 'w':
            read_result = *((unsigned long *) virt_addr);
            break;
        default:
            fprintf(stderr, "Illegal data type '%c'.\n", access_type);
            exit(2);
    }
    printf("Value at address 0x%lX (%p): 0x%lX\n", target, virt_addr, read_result);
    fflush(stdout);

    if(argc > 3) {
        writeval = strtoul(argv[3], 0, 0);
        switch(access_type) {
            case 'b':
                *((unsigned char *) virt_addr) = writeval;
                read_result = *((unsigned char *) virt_addr);
                break;
            case 'h':
                *((unsigned short *) virt_addr) = writeval;
                read_result = *((unsigned short *) virt_addr);
                break;
            case 'w':
                *((unsigned long *) virt_addr) = writeval;
                read_result = *((unsigned long *) virt_addr);
                break;
        }
        printf("Written 0x%lX; readback 0x%lX\n", writeval, read_result);
        fflush(stdout);
    }

    if(munmap(map_base, map_size) == -1) FATAL;
    close(fd);
    return 0;
}

