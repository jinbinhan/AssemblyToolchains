#! /bin/bash

# Created by Lubos Kuzma
# ISS Program, SADT, SAIT
# August 2022
#edits by Saiban: 64-bit is default
# Edits by Ben: Implemented getopt for command line
# Edits by Jinbin Han: Added update function

source auto_update.sh #update script

if [ $# -lt 1 ]; then # if no option is selected the user guide is printed
        echo "Usage:"
        echo ""
        echo "x86_toolchain.sh [ options ] <assembly filename> [-o | --output <output filename>]"
        echo ""
        echo "-v | --verbose                Show some information about steps performed."
        echo "-g | --gdb                    Run gdb command on executable."
        echo "-b | --break <break point>    Add breakpoint after running gdb. Default is _start."
        echo "-r | --run                    Run program in gdb automatically. Same as run command inside gdb env."
        echo "-q | --qemu                   Run executable in QEMU emulator. This will execute the program."
        echo "-32| --x86-32                 Compile for 32bit (x86-32) system."
        echo "-o | --output <filename>      Output filename."

        exit 1 # after printing the guide the program will exit
fi             # closes the above if statement

# setting default parameters
GDB=False
OUTPUT_FILE=""
VERBOSE=False
BITS=True
QEMU=False
BREAK="_start"
RUN=False

# Use getopt to parse command line options. Can be -(short) and/or --(long).
options=$(getopt -o go:v32qrb: --long gdb,output:,verbose,x86-32,qemu,run,break: -- "$@")

# Set positional parameters to the result from getopt.
eval set -- "$options"

# Loop through positional paramters.
while [[ $# -gt 0 ]]; do # while statement is executed if user enters an argument
        case $1 in       # checking different cases below to find a match with the command entered by user
        -g | --gdb)      # if -g is entered, then GDB is set to true
                GDB=True
                shift # past argument
                ;;
        -o | --output)           # if -o is entered, then user will enter a file name or another argument
                OUTPUT_FILE="$2" # OUTPUT_FILE variable will store the file name entered
                shift            # past argument
                shift            # past value
                ;;
        -v | --verbose) # if -v command is entered, then VERBOSE is set true
                VERBOSE=True
                shift # past argument
                ;;
        -3 | --x86-32) # Getopt only takes one char for short commands (-32 will still work).
                BITS=False
                shift # past argument
                ;;
        -q | --qemu) # if -q is entered, then QEMU is set true
                QEMU=True
                shift # past argument
                ;;
        -r | --run) # if -r is entered, then RUN is set true
                RUN=True
                shift # past argument
                ;;
        -b | --break)      # if -b is entered, then user will enter another argument to specify breakthrough point
                BREAK="$2" # breakthrough point will be saved in BREAK
                shift      # past argument
                shift      # past value
                ;;
        --)           # Case '--' is always the last arg of getopt args.
                shift # past argument
                break # exit the loop
                ;;
        esac # ends the above case statement
done         # ends the while loop

# Use original args that were not modified by getopt.
INPUT_FILE="$@"

if [[ ! -f $INPUT_FILE ]]; then # statement will be executed if the file entered by user is not found in the current directory
        echo "Specified file does not exist"
        exit 1 # program exited
fi

if [ "$OUTPUT_FILE" == "" ]; then    # statement will be executed if user doesn't specify the name of the output file
        OUTPUT_FILE=${INPUT_FILE%.*} # variable output file will be equal to the name of input file
fi

if [ "$VERBOSE" == "True" ]; then # if the statement is true, then VERBOSE will show information of steps performed
        echo "Arguments being set:"
        echo "  GDB = ${GDB}"
        echo "  RUN = ${RUN}"
        echo "  BREAK = ${BREAK}"
        echo "  QEMU = ${QEMU}"
        echo "  Input File = $INPUT_FILE"
        echo "  Output File = $OUTPUT_FILE"
        echo "  Verbose = $VERBOSE"
        echo "  64 bit mode = $BITS"
        echo ""

        echo "NASM started..."

fi

if [ "$BITS" == "True" ]; then # if BITS is true, then nasm will compile the file in 64 bit mode

        nasm -fPIE elf64 $1 -o $OUTPUT_FILE.o && echo "" # object file is created

elif
        [ "$BITS" == "False" ]
then # if BITS is false, then nasm will compile file in 32 bit mode

        nasm -fPIE elf $1 -o $OUTPUT_FILE.o && echo "" # object file is created

fi

if [ "$VERBOSE" == "True" ]; then

        echo "NASM finished"
        echo "Linking with GCC ..."

fi

if [ "$BITS" == "True" ]; then # if BITS is true, then gcc will compile the file in 64 bit mode

        gcc -m64 -nostdlib $OUTPUT_FILE.o -o $OUTPUT_FILE && echo "" # an executable file is created

elif
        [ "$BITS" == "False" ]
then # if BITS is false, then gcc will compile the file in 32 bit mode

        gcc -m32 -nostdlib $OUTPUT_FILE.o -o $OUTPUT_FILE && echo "" # an executable file is created

fi

if [ "$VERBOSE" == "True" ]; then

        echo "Linking finished"

fi

if [ "$QEMU" == "True" ]; then # if statement is true, then QEMU will start

        echo "Starting QEMU ..."
        echo ""

        if [ "$BITS" == "True" ]; then # if BITS is true, then QEMU will execute program in 64 bit mode

                qemu-x86_64 $OUTPUT_FILE && echo "" # QEMU runs the program

        elif [ "$BITS" == "False" ]; then # if BITS is false, then QEMU will execute program in 32 bit mode

                qemu-i386 $OUTPUT_FILE && echo "" # QEMU runs the program

        fi

        exit 0

fi

if [ "$GDB" == "True" ]; then # if the statement is true, the program will load in GDB

        gdb_params=()                  # GDB parameters entered by user are stored here
        gdb_params+=(-ex "b ${BREAK}") # breakthrough point is specified

        if [ "$RUN" == "True" ]; then # if statement is true, GDB will run the program

                gdb_params+=(-ex "r")

        fi

        gdb "${gdb_params[@]}" $OUTPUT_FILE # file will run in GDB terminal with entered paramenters

fi
