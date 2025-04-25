/*** asmEncrypt.s   ***/

#include <xc.h>

// Declare the following to be in data memory 
.data  

/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Edward Guerra Ramirez"  
.align
 
/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

// Define the globals so that the C code can access them
// (in this lab we return the pointer, so strictly speaking,
// does not really need to be defined as global)
// .global cipherText
.type cipherText,%gnu_unique_object

.align
 
@ NOTE: THIS .equ MUST MATCH THE #DEFINE IN main.c !!!!!
@ TODO: create a .h file that handles both C and assembly syntax for this definition
.equ CIPHER_TEXT_LEN, 200
 
// space allocated for cipherText: 200 bytes, prefilled with 0x2A
cipherText: .space CIPHER_TEXT_LEN,0x2A  

.align
 
.global cipherTextPtr
.type cipherTextPtr,%gnu_unique_object
cipherTextPtr: .word cipherText

// Tell the assembler that what follows is in instruction memory    
.text
.align

// Tell the assembler to allow both 16b and 32b extended Thumb instructions
.syntax unified

    
/********************************************************************
function name: asmEncrypt
function description:
     pointerToCipherText = asmEncrypt ( ptrToInputText , key )
     
where:
     input:
     ptrToInputText: location of first character in null-terminated
                     input string. Per calling convention, passed in via r0.
     key:            shift value (K). Range 0-25. Passed in via r1.
     
     output:
     pointerToCipherText: mem location (address) of first character of
                          encrypted text. Returned in r0
     
     function description: asmEncrypt reads each character of an input
                           string, uses a shifted alphabet to encrypt it,
                           and stores the new character value in memory
                           location beginning at "cipherText". After copying
                           a character to cipherText, a pointer is incremented 
                           so that the next letter is stored in the bext byte.
                           Only encrypt characters in the range [a-zA-Z].
                           Any other characters should just be copied as-is
                           without modifications
                           Stop processing the input string when a NULL (0)
                           byte is reached. Make sure to add the NULL at the
                           end of the cipherText string.
     
     notes:
        The return value will always be the mem location defined by
        the label "cipherText".
     
     
********************************************************************/    
.global asmEncrypt
.type asmEncrypt,%function
asmEncrypt:   

    // save the caller's registers, as required by the ARM calling convention
    push {r4-r11,LR} 
    
    /* YOUR asmEncrypt CODE BELOW THIS LINE! VVVVVVVVVVVVVVVVVVVVV  */

    ldr r2, =cipherText        /* r2 will point to the destination buffer where encrypted characters are stored */
    mov r3, r0                 /* r3 holds the current position in the input string while r0 originally had the pointer */
    mov r4, r1                 /* r4 holds the encryption key (the shift value from 0 to 25) */

    encrypt_loop:
    ldrb r5, [r3], #1          /* Loads the current character from the input string into r5, and moves r3 to the next char */
    cmp r5, #0                 /* Checks if we've reached the end of the input string (null terminator '\0') */
    beq done                   /* If yes, it will break out of the loop as all characters have been processed */

    /* Checks if the current character is an uppercase letter ('A' to 'Z') */
    mov r6, r5                 /* Copies the character into r6 to work with it */
    sub r6, #65                /* Converts the ASCII to 0-based index for A-Z (e.g., 'A' becomes 0, 'B' becomes 1, ...) */
    cmp r6, #25                /* If the result is > 25, then it wasn?t in range A-Z */
    bhi check_lowercase        /* If the character wasn't uppercase, it'll check if it's lowercase */

    /* Encrypts the uppercase letter using Caesar cipher */
    add r6, r4                 /* Applies the shift key to the index */
    mov r7, #26                /* Uses 26 because the alphabet has 26 letters needed for wrap-around (modulo) */
    udiv r8, r6, r7            /* Divides to prepare for modulus operation (r8 = floor(r6 / 26)) */
    mls r6, r8, r7, r6         /* Efficient modulus: r6 = r6 - (r8 * 26) = r6 % 26 */
    add r5, r6, #65            /* Converts the shifted index back to ASCII uppercase letter */
    b store                    /* Goes to store the encrypted character */

    check_lowercase:
    mov r6, r5                 /* Prepares to check if character is lowercase */
    sub r6, #97                /* Converts ASCII to 0-based index for a-z */
    cmp r6, #25                /* Checks if it's outside the lowercase letter range */
    bhi store                  /* If it's not a lowercase letter, leave it unchanged and goes to store it */

    /* Encrypts lowercase letter using Caesar cipher */
    add r6, r4                 /* Applies the shift key */
    mov r7, #26
    udiv r8, r6, r7            /* Prepares for wrap-around */
    mls r6, r8, r7, r6         /* Modulo 26 to wrap around alphabet if needed */
    add r5, r6, #97            /* Converts the index back to lowercase ASCII character */

    store:
    strb r5, [r2], #1          /* Stores the (possibly encrypted) character in the cipherText buffer and moves the pointer */

    b encrypt_loop             /* Repeats for the next character */

    done:
    mov r5, #0
    strb r5, [r2]              /* Append null terminator to the encrypted string */
    ldr r0, =cipherText        /* Returns pointer to start of the encrypted buffer in r0 (per function contract) */

    
    /* YOUR asmEncrypt CODE ABOVE THIS LINE! ^^^^^^^^^^^^^^^^^^^^^  */

    // restore the caller's registers, as required by the ARM calling convention
    pop {r4-r11,LR}

    mov pc, lr	 /* asmEncrypt return to caller */
   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




