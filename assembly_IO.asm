TITLE Low-level I/O Procedures with String Primitives and Macros

; Author: Marc Zalik
; Last Modified: 2022-03-11
; Description: This file contains contains the procedure main, along with subprocedures introduction,
;       ReadVal, WriteVal, and farewell, and macros mGetString and mDisplayString. Together, these
;       procedures and macros fill an array with user input signed integer values which are captured
;       as strings before converting to numeric values. The array is then printed out as a list of
;       values after converting back to strings, along with the sum and average of the input values.
;       Array size is defined by constants for easy updating, and procedures and macros use the stack 
;       and save/restore registers for proper modularization. Displays error messages for invalid inputs.

INCLUDE Irvine32.inc

;----------------------------------------------------------------------------------------------------
; Name: mGetString
; 
; Prompts a user to input some string, stores the string in the buffer, and returns the number of
;       bytes read.
; 
; Preconditions: String, buffer, and bytesRead variables must be passed by reference. maxLength must 
;       be passed by value. 
; 
; Postconditions: All used registers saved and restored. Prompt displayed to the screen. 
; 
; Receives: 
;       string = Reference to prompt string
;       buffer = Address of output buffer
;       maxLength = Value of max length of input string
;       bytesRead = Reference to DWORD that stores the number of bytes read
; 
; Returns: 
;       buffer = Output buffer updated with string read by ReadString
;       bytesRead = Value at reference to DWORD that stores the number of bytes read updated with 
;           number of bytes read
; 
;----------------------------------------------------------------------------------------------------
mGetString MACRO string:REQ, buffer:REQ, maxLength:REQ, bytesRead:REQ
    ; Save registers
    PUSH    EAX
    PUSH    ECX
    PUSH    EDX
    PUSH    EDI

;----------------------------------------------------------------
; Print prompt to console, capture input string, store it in the
; buffer, and store number of bytes read.
;----------------------------------------------------------------
    MOV     EDX, string                     ; Prompt
    CALL    WriteString
    MOV     EDX, buffer                     ; Address of buffer
    MOV     ECX, maxLength
    CALL    ReadString
    MOV     EDI, bytesRead
    MOV     [EDI], EAX                      ; Store number of bytes read

    ; Restore registers
    POP     EDI
    POP     EDX
    POP     ECX
    POP     EAX

ENDM


;----------------------------------------------------------------------------------------------------
; Name: mDisplayString
; 
; Given a reference to a null-terminated string, prints the string to the console.
; 
; Preconditions: String must be passed by reference.
; 
; Postconditions: All used registers saved and restored.
; 
; Receives: 
;       string = Reference to string
; 
; Returns: None.
; 
;----------------------------------------------------------------------------------------------------
mDisplayString MACRO string:REQ
    ; Save register
    PUSH    EDX

    ; Print string to console
    MOV     EDX, string                     ; String
    CALL    WriteString

    ; Restore register
    POP     EDX

ENDM


BUFFER_SIZE = 100
ARRAY_SIZE = 10


.data

greeting            BYTE        "PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures",13,10,"Written by Marc Zalik",13,10,13,10,0
goodbye             BYTE        13,10,"Thanks for playing!",0
prompt              BYTE        "Please enter a signed number: ",0
inputBuffer         BYTE        BUFFER_SIZE DUP(0)
outputBuffer        BYTE        BUFFER_SIZE DUP(0)
numArray            SDWORD      ARRAY_SIZE DUP(?)
numVal              SDWORD      0
validFlag           BYTE        0
sum                 SDWORD      0
average             SDWORD      0
count               DWORD       1
bytesRead           DWORD       0
errorMsg            BYTE        "ERROR: You did not enter a valid signed number, or your number was too large.",13,10,0
outputMsg           BYTE        13,10,"You entered the following numbers:",13,10,0
sumMsg              BYTE        "The sum of these numbers is: ",0
subtotalMsg         BYTE        "Your subtotal so far is: ",0
avgMsg              BYTE        "The truncated average is: ",0
comma               BYTE        ', ',0
period              BYTE        '. ',0
leftBracket         BYTE        '[ ',0
rightBracket        BYTE        ' ]',13,10,0
extraCredit_1       BYTE        "**EC1: Number input lines and display a running subtotal using WriteVal.",13,10,13,10,0


.code
;----------------------------------------------------------------------------------------------------
; Name: main
; 
; Prompts user to input ARRAY_SIZE number of signed integers (default 10), which are captured as
; strings, converted to numeric values, and stored in an array. A running count and subtotal are printed
; for each valid input, and once the array is filled displays a list of the user inputs as strings along
; with total sum and average values of the inputs (also displayed as strings). Validates user input
; against constraints for the data type (SDWORD) and prints error messages if invalid input provided.
; 
; Preconditions: Global constants ARRAY_SIZE and BUFFER_SIZE must be defined. Macros mGetString and 
;       mDisplayString must be defined.
; 
; Postconditions: Changes registers EAX, EBX, ECX, EDX, ESI, and EDI. 
; 
; Receives:
;       greeting = global variable string with name of program and author
;       goodbye = global variable string with farewell message
;       prompt = global variable string with prompt for user input
;       inputBuffer = global variable of the buffer array used for string input and integer to string conversions
;       outputBuffer = global variable of the buffer array used for integer to string conversions
;       numArray = global variable array for storing numeric values of integers provided
;       numVal = global variable SDWORD for numeric value of most recent integer input
;       validFlag = global variable BYTE flagging whether most recent user input is a valid signed integer
;       sum = global variable SDWORD for storing running sum of user integers
;       average = global variable SDWORD for storing average of all valid user integers
;       count = global variable DWORD for storing count of valid inputs provided for numbering lines
;       bytesRead = global variable DWORD for number of bytes read (string length) of valid user input
;       errorMsg = global variable string with error message for invalid input
;       outputMsg = global variable string for beginning of list of user inputs
;       sumMsg = global variable string with sum of user inputs
;       subtotalMsg = global variable string for running subtotal of user inputs
;       avgMsg = global variable string for average of user inputs
;       comma = global variable string with comma character for separating list of user inputs
;       period = global variable string with period character for delimiting the line number
;       leftBracket = global variable string with left bracket character for starting the list of user inputs
;       rightBracket = global variable string with right bracket character for ending the list of user inputs
;       extraCredit_1 = global variable string noting which extra credit was worked on
; 
; Returns: None.
; 
;----------------------------------------------------------------------------------------------------
main PROC

    PUSH    OFFSET  greeting
    PUSH    OFFSET  extraCredit_1
    CALL    introduction

    MOV     ECX, ARRAY_SIZE
    MOV     EDI, OFFSET numArray

_InLoop:
;----------------------------------------------------------------
; Prints the line number (count of valid inputs) and a prompt for
; the next integer, converts the string input to a numeric value,
; stores the value in an array, and accumulates and prints the 
; running sum.
;----------------------------------------------------------------
    ; Display Count
    PUSH    count
    PUSH    OFFSET  inputBuffer
    PUSH    OFFSET  outputBuffer
    CALL    WriteVal
    MOV     EDX, OFFSET period
    CALL    WriteString

    ; Read input
    PUSH    OFFSET  bytesRead
    PUSH    OFFSET  validFlag
    PUSH    OFFSET  numVal
    PUSH    OFFSET  prompt
    PUSH    OFFSET  inputBuffer
    PUSH    OFFSET  errorMsg
    CALL    ReadVal

    ; Check if valid input
    CMP     validFlag, 0
    JE      _InLoop                         ; Repeat until valid input detected

    ; Accumulate sum and store to array
    MOV     EAX, numVal
    ADD     sum, EAX
    MOV     [EDI], EAX                      ; Register Indirect for accessing array elements
    ADD     EDI, TYPE numArray
    INC     count

    ; Print subtotal
    MOV     EDX, OFFSET subtotalMsg
    CALL    WriteString
    PUSH    sum
    PUSH    OFFSET  inputBuffer
    PUSH    OFFSET  outputBuffer
    CALL    WriteVal
    CALL    CrLf
    CALL    CrLf
    
    DEC     ECX
    CMP     ECX, 0
    JA      _InLoop                         ; Too far for LOOP instruction

_Average:
;----------------------------------------------------------------
; Prints the ending message, prepares for the output loop to
; print off values as strings, and calculates the average value.
;----------------------------------------------------------------
    MOV     EDX, OFFSET outputMsg
    CALL    WriteString
    MOV     EDX, OFFSET leftBracket
    CALL    WriteString

    ; Calculate Average
    MOV     EAX, sum
    CDQ
    MOV     EBX, ARRAY_SIZE
    IDIV    EBX                             ; Average = sum / number of elements in array
    MOV     average, EAX

    ; Prepare for outloop
    MOV     ECX, ARRAY_SIZE
    MOV     ESI, OFFSET numArray

_OutLoop:
;----------------------------------------------------------------
; Prints off the valid inputs as stored in the integer array as
; strings using WriteVal.
;----------------------------------------------------------------
    PUSH    [ESI]                           ; Register Indirect for accessing array elements
    PUSH    OFFSET  inputBuffer
    PUSH    OFFSET  outputBuffer
    CALL    WriteVal
    CMP     ECX, 1
    JNE     _MiddleOfArray
    MOV     EDX, OFFSET rightBracket
    CALL    WriteString
    JMP     _EndOutLoop

_MiddleOfArray:
    ; Print commas separating values in the array
    MOV     EDX, OFFSET comma
    CALL    WriteString
    ADD     ESI, TYPE numArray

_EndOutLoop:
;----------------------------------------------------------------
; Prints the end of the array, including the final sum and 
; average values.
;----------------------------------------------------------------
    LOOP    _OutLoop

    ; Print sum and average
    MOV     EDX, OFFSET sumMsg
    CALL    WriteString
    PUSH    sum
    PUSH    OFFSET  inputBuffer
    PUSH    OFFSET  outputBuffer
    CALL    WriteVal                        ; WriteVal to print sum
    CALL    CrLf
    MOV     EDX, OFFSET avgMsg
    CALL    WriteString
    PUSH    average
    PUSH    OFFSET  inputBuffer
    PUSH    OFFSET  outputBuffer
    CALL    WriteVal                        ; WriteVal to print average
    CALL    CrLf
    CALL    CrLf

    PUSH    OFFSET  goodbye
    CALL    farewell

	Invoke ExitProcess,0	; exit to operating system
main ENDP


;----------------------------------------------------------------------------------------------------
; Name: introduction
; 
; Prints an introduction with the name of the program and author, a description of the program, and a 
; note indicating which extra credit was worked on.
; 
; Preconditions: None.
; 
; Postconditions: All used registers saved and restored. Displays message to the console.
; 
; Receives: 
;       [EBP+16] = Reference to introduction string
;       [EBP+12] = Reference to EC1 message
; 
; Returns: None.
; 
;----------------------------------------------------------------------------------------------------
introduction PROC USES EDX
    ; Set stack frame's EBP
    PUSH    EBP
    MOV     EBP, ESP

    ; Print intro to console
    MOV     EDX, [EBP+16]                   ; greeting
    CALL    WriteString
    MOV     EDX, [EBP+12]                   ; EC 1
    CALL    WriteString

    ; Restore EBP for calling procedure
    POP     EBP

    RET     8
introduction ENDP


;----------------------------------------------------------------------------------------------------
; Name: ReadVal
; 
; Prompts user to input a signed integer value, captures it as a string, and converts the string value
; to a signed integer value fitting in an SDWORD data type. Prints an error message if the user input
; is not a properly formatted signed integer value, or if the value is too large or too small to fit
; in an SDWORD data type. If the value is valid, stores the signed integer value at the address
; provided and updates validFlag to 1 indicating a valid value. Otherwise, validFlag is set to 0 for
; invalid inputs.
; 
; Preconditions: Global constant BUFFER_SIZE must be defined. Macro mGetString must be defined.
; 
; Postconditions: All used registers saved and restored.
; 
; Receives: 
;       [EBP+28] = Reference to bytesRead
;       [EBP+24] = Reference to validFlag
;       [EBP+20] = Reference to numVal
;       [EBP+16] = Reference to prompt
;       [EBP+12] = Address of inputBuffer
;       [EBP+8] = Reference to error message
; 
; Returns: 
;       [EBP+24] = Flag, 1 for valid value, 0 for invalid value
;       [EBP+20] = Updates value of numVal
; 
;----------------------------------------------------------------------------------------------------
ReadVal PROC USES EAX EBX ECX EDX ESI EDI
    ; Set up stack frame and allocate local variables
    LOCAL   numInt:SDWORD, stringLength: DWORD, sign:SBYTE

    MOV     sign, 1                         ; Default values to positive unless leading '-' provided
    MOV     EAX, 0
    MOV     EBX, 0

    ; Call macro to get input string
    mGetString  [EBP+16], [EBP+12], BUFFER_SIZE, [EBP+28]

    ; Prepare for loop to convert string to integer
    MOV     numInt, 0
    CLD
    MOV     ESI, [EBP+28]                   ; Set ECX to value of bytesRead and store it in local variable stringLength
    MOV     ECX, [ESI]
    MOV     stringLength, ECX
    MOV     ESI, [EBP+12]                   ; inputBuffer

_BeginLoop:
    ; Load next value from inputBuffer and handle special case for first index
    LODSB
    CMP     ECX, stringLength
    JE      _CheckSign
    JMP     _Digits

_CheckSign:
    ; First byte may be +/- to set sign
    CMP     AL, 43                          ; '+'
    JE      _SetPositive
    CMP     AL, 45                          ; '-'
    JE      _SetNegative
    JMP     _Digits

_SetNegative:
    ; Set sign for negatives
    MOV     sign, -1

_SetPositive:
    LOOP    _BeginLoop                      ; Default sign value is 1, no need to change

_Digits:
;----------------------------------------------------------------
; Confirms all bytes (excluding initial sign values) are digits,
; converts the ASCII value to its numeric value, and prepares to
; add the value to the sum (numInt).
;----------------------------------------------------------------
    ; Confirm digit
    CMP     AL, 48                          ; 0
    JB      _Error
    CMP     AL, 57                          ; 9
    JA      _Error

    ; Convert ASCII to numeric
    SUB     AL, 48
    MOV     BL, AL
    MOV     EAX, numInt
    MOV     EDX, 10
    CMP     sign, -1
    JE      _NegativeOverflow

_PositiveOverflow:
;----------------------------------------------------------------
; Increases current sum (numInt) by an order of magnitude and then
; adds the numeric value of the current byte in the input buffer.
; Checks for overflows at each step of the process that could
; cause the value of numInt to exceed the MAX value of an SDWORD.
;----------------------------------------------------------------
    MUL     EDX
    ;JO      _Error
    MOV     numInt, EAX
    JO      _Error                          ; numInt overflowed after increasing magnitude
    ADD     numInt, EBX
    JO      _Error                          ; numInt overflowed after adding current digit
    JMP     _EndLoop

_NegativeOverflow:
;----------------------------------------------------------------
; Increases current sum (numInt) by an order of magnitude and then
; adds the numeric value of the current byte in the input buffer.
; Checks for overflows at each step of the process that could
; cause the value of numInt to exceed the MIN value of an SDWORD.
;----------------------------------------------------------------
    MOV     EDX, -10                        ; Set numInt to negative during overflow checks, to account for value of -2147483648
    IMUL    EDX
    ;JO      _Error
    MOV     numInt, EAX
    JO      _Error                          ; numInt overflowed after increasing magnitude
    SUB     numInt, EBX
    JO      _Error                          ; numInt overflowed after adding current digit
    MOV     EDX, -1                         ; Set numInt back to positive, so that part of the loop can be reused for both positives and negatives
    MOV     EAX, numInt
    IMUL    EDX
    MOV     numInt, EAX

_EndLoop:
;----------------------------------------------------------------
; Stores the final value of numInt to the memory location 
; referenced by the stack parameter pointer for numVal.
;----------------------------------------------------------------
    LOOP    _BeginLoop
    CMP     sign, -1
    JNE     _StoreNum
    MOV     EDX, -1                         ; For negative values, negate numInt before storing since it was previously negated only temporarily for overflow checks
    MOV     EAX, numInt
    IMUL    EDX
    MOV     numInt, EAX

_StoreNum:
    ; Stores results back to the stack using Base + Offset for accessing stack parameters
    MOV     EDI, [EBP+20]                   ; numVal
    MOV     EAX, numInt
    MOV     [EDI], EAX
    MOV     EDI, [EBP+24]                   ; validFlag = 1, valid input
    MOV     [EDI], BYTE PTR 1
    JMP     _End

_Error:
    ; Prints error message if invalid input or number too large or small for SDWORD detected
    MOV     EDI, [EBP+24]                   ; validFlag = 0, invalid input
    MOV     [EDI], BYTE PTR 0
    MOV     EDX, [EBP+8]                    ; errorMsg
    CALL    WriteString

_End:

    RET     24
ReadVal ENDP


;----------------------------------------------------------------------------------------------------
; Name: WriteVal
; 
; Given an integer value, converts the numeric value to a null-terminated ASCII string and prints it
; to the console. 
; 
; Preconditions: Macro mDisplayString must be defined.
; 
; Postconditions: All used registers saved and restored.
; 
; Receives: 
;       [EBP+16] = Value to print
;       [EBP+12] = Reference to inputBuffer
;       [EBP+8] = Reference to outputBuffer
; 
; Returns: None.
; 
;----------------------------------------------------------------------------------------------------
WriteVal PROC USES EAX EBX ECX EDX ESI EDI
    ; Set up stack frame and allocate local variables
    LOCAL   numInt:SDWORD, sign: SBYTE

    ; Default sign to positive
    MOV     sign, 1

    ; Prepare to loop through integer and convert to string
    CLD
    MOV     EBX, [EBP+16]                   ; Integer value
    MOV     EDI, [EBP+12]                   ; inputBuffer
    MOV     ECX, 0
    MOV     numInt, EBX
    CMP     numInt, 0
    JGE     _StringLoop
    MOV     sign, -1

_StringLoop:
;----------------------------------------------------------------
; Extracts least significant digit remaining from integer value.
; If a value of 0 was extracted and no value remains, we have
; reached the end of the integer value.
;----------------------------------------------------------------
    ; Extract digit
    MOV     EAX, numInt
    CDQ
    MOV     EBX, 10
    IDIV    EBX
    CMP     ECX, 0
    JE      _ContinueLoop                   ; Handle case where integer value to print is 0
    CMP     EAX, 0
    JNE     _ContinueLoop
    CMP     EDX, 0
    JE      _EndStringLoop                  ; No more digits to print

_ContinueLoop:
    ; Prepare to convert extracted digit back to ASCII based on the sign of integer
    MOV     numInt, EAX
    MOV     EAX, EDX
    CMP     sign, -1
    JE      _NegativeChars

_PositiveChars:
    ; Convert digit to ASCII and store it
    ADD     EAX, 48                         ; ASCII digits start at 48d
    STOSB
    JMP     _Repeat

_NegativeChars:
    ; If integer is negative, extracted digit is also negative. Convert to positive before converting to ASCII and storing
    MOV     EDX, -1
    IMUL    EDX
    ADD     EAX, 48
    STOSB

_Repeat:
    ; Keep track of number of digits seen. Necessary for reversing.
    INC     ECX
    JMP     _StringLoop

_EndStringLoop:
;----------------------------------------------------------------
; inputBuffer is filled with the ASCII values representing the 
; integer value, but in reverse. Using string primitives, loops
; backwards through the inputBuffer and stores each ASCII byte
; forwards in the outputBuffer, effectively reversing the string.
; Also handles leading sign for negative values.
;----------------------------------------------------------------
    ; Add leading negative sign if necessary
    CMP     sign, 1
    JE      _SetUpReverse
    MOV     EAX, 45                         ; Negative Sign '-'
    STOSB
    INC     ECX

_SetUpReverse:
    ; Initialize ESI for end of inputBuffer and EDI for beginning of outputBuffer
    MOV     ESI, [EBP+12]                   ; inputBuffer
    ADD     ESI, ECX                        ; ECX contains number of bytes in inputBuffer
    DEC     ESI
    MOV     EDI, [EBP+8]                    ; outputBuffer

_ReverseLoop:
    ; Reverse string into output buffer
    STD
    LODSB
    CLD
    STOSB
    LOOP    _ReverseLoop

    MOV     EAX, BYTE PTR 0
    STOSB                                   ; Append null terminator to end out outputBuffer

    ; Call macro to write outputBuffer
    mDisplayString  [EBP+8]

    RET     12
WriteVal ENDP


;----------------------------------------------------------------------------------------------------
; Name: farewell
; 
; Prints a goodbye message to the screen via standard I/O.
; 
; Preconditions: None.
; 
; Postconditions: All used registers saved and restored. Displays message to the console.
; 
; Receives: 
;       [EBP+12] = Reference to farewell string
; 
; Returns: None.
; 
;----------------------------------------------------------------------------------------------------
farewell PROC USES EDX
    ; Set stack frame's EBP
    PUSH    EBP
    MOV     EBP, ESP

    MOV     EDX, [EBP+12]                   ; goodbye
    CALL    WriteString

    ; Restore EBP for calling procedure
    POP     EBP

    RET     4
farewell ENDP

END main
