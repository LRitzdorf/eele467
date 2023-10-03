// Lab 8: LED Patterns in C

#include <stdio.h>
#include <signal.h>
#include <argp.h>
#include <time.h>


// Version information
const char *argp_program_version = "myLEDpatterns 1.0";
// Documentation
static char doc[] =
    "Display LED patterns on a dedicated hardware peripheral.\n";
// Argument parser setup
static struct argp argp = {0, 0, 0, doc};


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

    // Parse arguments
    argp_parse(&argp, argc, argv, 0, 0, 0);
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
