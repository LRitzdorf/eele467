// Lab 8: LED Patterns in C

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <argp.h>
#include <time.h>


// Configuration values
#define MAX_STEPS 32

// Helper macros to allow stringizing other macro values
#define xstr(a) str(a)
#define str(a) #a

// Argument parser metadata
const char *argp_program_version = "myLEDpatterns 1.0";
const char *argp_program_bug_address = "lucas.ritzdorf@student.montana.edu";
static char doc[] =
    "Display LED patterns on a dedicated hardware peripheral.\n"
    "\vCompiled with support for up to " xstr(MAX_STEPS) " pattern steps.";
// Argument parser options
static struct argp_option options[] = {
    {"help",    'h', 0, 0, "show this help message", -1},
    {"version", 'V', 0, 0, "show program version", -1},
    {"usage",   'u', 0, 0, "show program usage summary", -1},
    {0}
};
static error_t parse_opt(int, char *, struct argp_state *);
struct arguments {
    struct {
        unsigned int num_steps;
        uint8_t steps[MAX_STEPS];
        unsigned int delays[MAX_STEPS];
    } pattern;
    char *file;
    bool verbose;
};
// Final parser setup
static struct argp argp = {options, parse_opt, 0, doc};

// Argument parsing logic
static error_t parse_opt(int key, char *arg, struct argp_state *state) {
    switch (key) {
        case 'h':
            // help
            argp_state_help(state, state->out_stream, ARGP_HELP_STD_HELP);
            break;
        case 'V':
            // version
            fprintf(state->out_stream, "%s\n", argp_program_version);
            exit(0);
            break;
        case 'u':
            // usage
            argp_state_help(state, state->out_stream, ARGP_HELP_USAGE | ARGP_HELP_EXIT_OK);
            break;
        default:
            // Unknown option
            return ARGP_ERR_UNKNOWN;
    }
    return 0;
}


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
    argp_parse(&argp, argc, argv, ARGP_NO_HELP, 0, 0);
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
