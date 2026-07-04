.section .text 
.global _start 
_start: 
   li t0 , 100 
   li t1 , 200 
   add a0 , t0 , t1 
   sw a0 , 0(t3) 

   li a0 , 0 
   li a7 , 93 
   ecall 

so this code has an  intentional  bug and i will find it using gdb 
form gdb I can see :  
Program received signal SIGSEGV, Segmentation fault.
_start () at hello.s:7
7          sw a0 , 0(t3)

what is this ? 
I think only can store a value to an address not an registers directly ....even t3 i havent initalized before or i dont loaded any memory address with t3 before 
first of all i will try to store this is  with another immediate value and lets see what happens



.section .text
.global _start
_start:
   li t0 , 100
   li t1 , 200
   add a0 , t0 , t1
   sw a0 , 0(0x2000)

   li a0 , 0
   li a7 , 93
   ecall  

the assembler says that this is illigal operand 'sw a0 , 0(0x2000)'

so the correct code will be this : 
.section .data 
result_1 : .word 0 
.section .text 
.global _start 
_start: 
   li t0 , 100 
   li t1 , 200 
   add a0 , t0 , t1 
   la t3 ,  result_1 
   sw a0 , 0(t3) 

   li a0 , 0 
   li a7 , 93 
   ecall 

it means first of all i have to init the memeory address at the to in the  data section so that i can store this value in it 

so i have write another code  which is this 
.section .data
result_1 : .word 0
.section .text
.global _start
_start:
     li t0 , 100
     li t1 , 200
     add a0 , t0 , t1
     la t2 , result_1
     sw a0 , 0(t2)
     add a1 , t0 , t1
     sw a1 , 4(t2)

     li a0 , 0
     li a7 , 93
     ecall

this code compiles anyhow but i dont know if this is right or worng 
key tip -> in gdb i dont need to type the same command like si again and again ....because the last command will 
repeat if i press inter 

.section .text 
.global _start 
_start: 
    li t0 , b00000110
    li t1 , b00010100
    add a0 , t0 , t1 

    li a0 , 0 
    li a7 , 93 
    ecall 
so this code is worng ....the assembler cannot recognize the binary even if i use any b literals 
so the only way is to use hexdecimals 



