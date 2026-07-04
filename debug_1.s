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

riscv asm is by default little endian and this is a load and sotre architecture 
so before doing anything i must load the value   ,  this helps a lot 
but in some case like immediate field i dont need to load the imm value 

Ok Now i have to show a practical and serious workflow here 

6          li t0 , 0xA
(gdb) si
7          li t1 , 0x14
(gdb) info  reg t0
t0             0xa      10
(gdb) si
8          add a0 , t0 , t1
(gdb) info reg t1
t1             0x14     20
(gdb) si
9          la t2 , result_1
(gdb) info reg a0
a0             0x1e     30
(gdb) si
0x0000000000010188      9          la t2 , result_1
(gdb) si
10         sw a0 , 0(t2)
(gdb) info reg t2
t2             0x12000  73728
(gdb) si
11         sw a0 , 4(t2)
(gdb) si
12         sw a0 , 8(t2)
(gdb) si
13         sw a0 , 12(t2)
(gdb)
14         sw a0 , -16(t2)
(gdb)
15         sw a0 , -20(t2)
(gdb)
17         li a0  , 0
(gdb) x/wd 0x12000
0x12000:        30
(gdb) x/wd 0x12000 + 4
0x12004:        30
(gdb) x/wd 0x12000 + 8
0x12008:        30
(gdb) x/wd 0x12000 + 12
0x1200c:        30
(gdb) x/wd 0x12000 - 16
0x11ff0:        30
(gdb) x/wd 0x12000 - 20
0x11fec:        30
(gdb) x/wd 0x12000 - 4
0x11ffc:        0
(gdb) shell cat hello.s
.section .data
result_1 : .word 0
.section .text
.global _start
_start:
   li t0 , 0xA
   li t1 , 0x14
   add a0 , t0 , t1
   la t2 , result_1
   sw a0 , 0(t2)
   sw a0 , 4(t2)
   sw a0 , 8(t2)
   sw a0 , 12(t2)
   sw a0 , -16(t2)
   sw a0 , -20(t2)

   li a0  , 0
   li a7 , 93
   ecall

(gdb) shell cat stack.s



a linier stack diagram 

-8 <-              -4 <-               0 ->           4 ->                8 ->           12 ->
1200 -8         12000-4             12000+0        12000+4          12004 + 4       12008 + 4
                                      -> form here i have strated incrementing by offsets
                                      -> i have incremented form 12000 to 12012 after incrementing the pointer is at 12012 not 12000
                                      -> at 12012 the offset is 16 ...and if i  next time just use the offset -16 then what happens ?
                                      -> in math 12 + (-16) = -4
                                      -> so with the offset -4 the address is 12000 -4
                                      -> x/wd 0x12000 -4 should show the same value of a0 logicially but fucked

(gdb) x/wd 0x12000 - 4
0x11ffc:        0
(gdb) x/wd 0x12000 - 8
0x11ff8:        0
(gdb) x/wd 0x12000 - 12
0x11ff4:        -1
(gdb) x/wd 0x12000 - 16
0x11ff0:        30
(gdb)

So i thought that , x/wd 0x12000 -4 should also show 30 but here  is no the case , 
I thought about the address pointer(which works according to previous ofsets) is worng 
right is offsets works directly and it dosent care about the previous one and here no math works like 
16 - 12 = 4 so x/wd 0x12000 - 4 should show the value , no thats not 
and thats why x/wd 0x12000 -4 is showing nothing but x/wd 0x12000 - 16 is showing the value 
even if i use sp here and then i store values in it as much as i can , after storing the value 
if i do -> info reg sp , this will show the first address of sp not like offset + first sp address 
so now i can understand that storing value with sw and ofsets dosent chnage the stack pointer address
instead ofsets just took the sp place them + offset = to show the target value nothing else 


QUESTION -> 

so I have a serious qustion here ...
so I know that stack goes downword so what if i do :
sw a0 , 4(sp)
sw a1 , -4(sp)
both goes downword  ? 
answer : 
addi sp , sp , - imm_n -> this took the sp to downword 
addi sp , sp , imm_n -> this took the sp to upword 

for + imm_n the main possible problem is overflow 
for - imm_n the main possible problem is underflow 
this only happens when the usage sp is more then the allocated sp bound 

ok so i have a recent observation 
QWEN ai advised me not to use neg offsets for sp when i allocate the 
sp like -> addi sp , sp , -32 and then addi sp , sp , 32  

i never do anything about neg sp ever but the only reason is i saw this 
in disassembly , in disassembly they used both -> addi sp , sp , -32 
and also neg offsets but they didnt use it for sp they use it for frame 
pointer and that was s0 
....i am now skipping the frame pointers concepts because first i have 
to master only the load and sore 

lets  only learn the diffirence between lh and lhu 

what happens in lhu  first of all ? 
example : 
so the binary is 1111111110000000 which is 65408 in decimal 
in the rule is if i use lbu to load this value first of all 
the cpu dont care anything it just put 0 for 48 times at  the msb 
now 48 + 16 = 64 which is perfectly for a 64 bit system that i am using 
now 

so if i use lh ? 
for lh the cpu will see the msb is 0 or 1 if this is 0  then the left 
bits (64 - 16 = 48) will put 0 at msb for 48 times 
and then if there is 1 then it will put  1 at msb for 48 times 
and thus how it can chnage the value 

rule i must follow : 
1-> the value is neg and if i use lhu the value will be unexpected 
2-> the value is neg and if i use lh ,then the value will be neg 
3-> the value is pos and if i use lh ,then the value will be the same 
4-> the value is pos and if i use lhu ,then the value will be the same 

