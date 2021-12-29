
//Screen panels
#define INSTRUCTION_HELP "help"
#define MEMORY_STATE "state"

//Identifier of the link register
#define LINK_REGISTER "RL"
#define FLAG_REGISTER "RF"
#define PROGRAM_REGISTER "RP"

//Flags
#define ERROR_FLAG (1 << 0)
#define EQUAL_FLAG (1 << 1)
#define GREATER_FLAG (1 << 2)

//Amount of registers that the interpreter has access to.
//Labelled R0 to R15 at 16
#define REGISTER_COUNT 16

//Maximum amount of messages stored in console
#define MAX_CONSOLE_OUTPUT 50

//Maximum length of messages stored in console
#define MAX_CONSOLE_MESSAGE_LENGTH 400

//Maximum stack size
//You can only push this many elements to the stack before it overflows
#define MAXIMUM_STACK_SIZE 1000

//The amount of memory that the program has
#define DEFAULT_MEMORY_SIZE 10000
