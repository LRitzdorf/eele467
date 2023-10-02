// Lab 8: LED Patterns in C

#include <stdio.h>
#include <signal.h>
#include <time.h>


// Interrupt flag setup and handling
static volatile sig_atomic_t interrupted = 0;
static void sig_handler(int _) {
    (void)_;
    puts("Caught SIGINT, exiting...");
    interrupted = 1;
}


int main(int argc, char **argv) {
    // Register interrupt handler
    signal(SIGINT, sig_handler);

    // Print placeholder message
    printf("Received %d arguments\n", argc);

    // Loop until interrupted
    struct timespec ts;
    ts.tv_sec = 1;
    ts.tv_nsec = 0;
    while (!interrupted) {
        puts("Still running...");
        nanosleep(&ts, NULL);
    }

    return 0;
}
