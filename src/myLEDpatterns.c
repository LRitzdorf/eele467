// Lab 8: LED Patterns in C

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <argp.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <time.h>


// Configuration values
#define MAX_STEPS 32
#define LINE_LEN 20
// Hardware memory addresses
#define BRIDGE_BASE_ADDR 0xFF200000
#define IFACE_LEN 16 //in bytes
#define OVERRIDE_REG 0x0
#define PATTERN_REG 0x4

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
    {"help",    'h', 0,                0, "show this help message", -1},
    {"version", 'V', 0,                0, "show program version", -1},
    {"usage",   'u', 0,                0, "show program usage summary", -1},
    {"verbose", 'v', 0,                0, "print information for each displayed pattern step", 0},
    {"loop",    'l', 0,                0, "display the pattern in an loop until canceled", 0},
    {"no-loop", 'n', 0,                0, "display the pattern for one cycle", 0},
    {"pattern", 'p', "BIN TIME [...]", 0, "specify a sequence of pattern steps", 1},
    {"file",    'f', "FILE",           0, "specify a file containing pattern steps", 1},
    {0}
};
static error_t parse_opt(int, char *, struct argp_state *);
struct arguments {
    struct {
        unsigned int num_steps;
        uint8_t steps[MAX_STEPS];
        unsigned int delays[MAX_STEPS];
        bool loop;
    } pattern;
    char *file;
    bool verbose;
    bool loop_override;
};
// Final parser setup
static struct argp argp = {options, parse_opt, 0, doc};


// Argument parsing logic
static error_t parse_opt(int key, char *arg, struct argp_state *state) {
    struct arguments *arguments = state->input;
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

        case 'v':
            // verbose
            arguments->verbose = true;
            break;
        case 'l'|'n':
            // loop/no-loop overrides
            arguments->loop_override = true;
            arguments->pattern.loop = (key == 'l');
            break;
        case 'p':
            // pattern literal series
            if (arguments->file) {
                fputs("Pattern file already specified; pattern sequence not allowed!\n", stderr);
                return 1;
            } else {
                // Set loop parameter if not overridden
                if (!arguments->loop_override) {
                    arguments->pattern.loop = true;
                }
                // Parse remaining arguments
                unsigned int arg_index;
                for (arg_index = state->next - 1; arg_index < state->argc - 1; arg_index = arg_index + 2) {
                    // Ensure we don't consume more steps than we can handle
                    if (arguments->pattern.num_steps >= MAX_STEPS) {
                        break;
                    }
                    // Capture binary pattern and corresponding delay
                    arguments->pattern.steps [arguments->pattern.num_steps] = (uint8_t)     strtol(state->argv[arg_index],     NULL, 0);
                    arguments->pattern.delays[arguments->pattern.num_steps] = (unsigned int)strtol(state->argv[arg_index + 1], NULL, 0);
                    // Increment pattern step count
                    arguments->pattern.num_steps++;
                }
                // Update parser state with the args we just consumed
                state->next = arg_index;
            }
            break;
        case 'f':
            // pattern file
            if (arguments->pattern.num_steps) {
                fputs("Pattern sequence already specified; pattern file not allowed!\n", stderr);
                return 1;
            } else {
                // Set loop parameter if not overridden
                if (!arguments->loop_override) {
                    arguments->pattern.loop = false;
                }
                // Store (pointer to) filename
                arguments->file = arg;
            }
            break;

        default:
            // Unknown option
            return ARGP_ERR_UNKNOWN;
    }
    return 0;
}


// Pattern loading from file
int load_pattern_file(struct arguments *arguments) {
    // Open file, if available
    FILE* fin = fopen(arguments->file, "r");
    if (fin == NULL) {
        fprintf(stderr, "Failed to open input file \"%s\"\n", arguments->file);
        return 1;
    }

    char line[LINE_LEN];
    // Read in lines individually, until EOF or too many steps
    while (arguments->pattern.num_steps < MAX_STEPS
            && fgets(line, sizeof(line), fin) != NULL) {
        // Extract values from line
        unsigned int step;
        unsigned int delay;
        sscanf(line, "%X %d", &step, &delay);
        // Add the corresponding pattern step
        arguments->pattern.steps [arguments->pattern.num_steps] = (uint8_t)step;
        arguments->pattern.delays[arguments->pattern.num_steps] = delay;
        arguments->pattern.num_steps++;
    }

    // Clean up and exit
    fclose(fin);
    return 0;
}


// Hardware memory writing
int write_mem(unsigned long addr, uint32_t data) {
    // TODO
    printf("Would write 0x%X to address 0x%lX\n", data, addr);
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
    struct arguments params = {
        {0},  // Empty pattern struct
        NULL, // Empty filepath
        false // Not verbose
    };
    argp_parse(&argp, argc, argv, ARGP_NO_HELP, 0, &params);
    // Load patterns from file, if provided
    if (params.file) {
        load_pattern_file(&params);
    }
    // Ensure that patterns are present
    if (params.pattern.num_steps == 0) {
        fputs("No patterns loaded! Provide a pattern sequence or a valid pattern file.\n", stderr);
        return 1;
    }

    // Prepare /dev/mem for writing
    int mem = open("/dev/mem", 'w');
    if (mem == -1) {
        printf("Failed to open /dev/mem for writing. Are you root?\n");
        return 1;
    }
    long map_size = sysconf(_SC_PAGESIZE);
    long map_mask = (map_size - 1);
    void *map_base = mmap(0, IFACE_LEN, PROT_WRITE, MAP_SHARED, mem, BRIDGE_BASE_ADDR & ~map_mask);
    if (map_base == (void *) -1) {
        printf("Failed to map memory\n");
        return 1;
    }

    unsigned int step = 0;
    struct timespec ts = {0};
    // Enable pattern override
    write_mem(BRIDGE_BASE_ADDR + OVERRIDE_REG, true);
    // Display pattern steps in sequence until interrupted
    while (!interrupted) {

        // Convert millisecond input to timespec
        ts.tv_sec = params.pattern.delays[step] / 1000; // Integer division is intended here
        ts.tv_nsec = (params.pattern.delays[step] % 1000) * 1000000;
        // Display pattern and sleep
        if (params.verbose) {
            printf("Displaying pattern step 0x%X for %d ms\n", params.pattern.steps[step], params.pattern.delays[step]);
        }
        write_mem(BRIDGE_BASE_ADDR + PATTERN_REG, params.pattern.steps[step]);
        nanosleep(&ts, NULL);

        // Increment or wrap step counter, as appropriate
        if (step >= params.pattern.num_steps - 1) {
            // Wrap step counter, or exit if not looping
            if (params.pattern.loop) {
                step = 0;
            } else {
                break;
            }
        } else {
            // Increment step counter
            step++;
        }

    }
    // Clean up and exit
    write_mem(BRIDGE_BASE_ADDR + OVERRIDE_REG, false);
    close(mem);

    return 0;
}
