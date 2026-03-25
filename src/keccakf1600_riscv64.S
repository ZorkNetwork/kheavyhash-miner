#if __riscv_xlen == 64
# if __SIZEOF_POINTER__ == 16
# define PUSH csc
# define POP clc
# else
# define PUSH sd
# define POP ld
# endif
# if defined(__riscv_zbkb) && !defined(__riscv_zbb)
# define __riscv_zbb __riscv_zbkb
# endif
#else
# error "unsupported __riscv_xlen"
#endif

.text
.option pic

.type __KeccakF1600, @function
.align 2
__KeccakF1600:
 add x2, x2, -8*14
 PUSH x1, 80(x2)

 sd x27, 40(x2)
 sd x28, 48(x2)
 lla x1, iotas # iotas
 slli x6, x6, 3 # number of rounds times 8
 add x6, x1, x6 # end of iotas
 sd x6, 80+__SIZEOF_POINTER__(x2)

.Loop:
 sd x9, 16(x2) # offload A[0][*]
 xor x9, x9, x14
 sd x10, 24(x2)
 xor x10, x10, x15
 sd x7, 0(x2)
 xor x5, x7, x12
 sd x8, 8(x2)
 xor x6, x8, x13
 sd x11, 32(x2)
 xor x11, x11, x16

 ld x27, 40(x2) # reload A[4][1..2]
 xor x5, x5, x17
 ld x28, 48(x2)
 xor x6, x6, x18
 xor x9, x9, x19
 xor x10, x10, x20
 xor x11, x11, x21

 xor x5, x5, x22
 xor x6, x6, x23
 xor x9, x9, x24
 xor x10, x10, x25
 xor x11, x11, x26

 xor x5, x5, x27
 xor x6, x6, x28
 xor x9, x9, x29
 xor x10, x10, x30
 xor x11, x11, x31

#ifdef __riscv_zbb
 ror x7, x9, 63
 xor x7, x7, x5 # D[1] = T[0] ^ ROL64(D[3], 1);
 ror x8, x11, 63
 xor x9, x9, x8 # D[3] ^= ROL64(D[0], 1);
 ror x8, x6, 63
 xor x11, x11, x8 # D[0] ^= ROL64(T[1], 1);
 ror x8, x10, 63
 xor x8, x8, x6 # D[2] = T[1] ^ ROL64(D[4], 1)
 ror x6, x5, 63
 xor x10, x10, x6 # D[4] ^= ROL64(T[0], 1);
 xor x5, x13, x7

 ror x6, x5, 64-44

 xor x5, x19, x8
 sd x6, 48(x2) # offload new A[0][*]
 ror x6, x5, 64-43

 xor x5, x25, x9
 sd x6, 56(x2)
 ror x6, x5, 64-21

 xor x5, x31, x10
 sd x6, 64(x2)
 ror x6, x5, 64-14

 xor x13, x16, x10
 sd x6, 72(x2)
 xor x19, x20, x9
 xor x25, x24, x8
 xor x31, x28, x7
 ror x13, x13, 64-20
 ror x19, x19, 64-25
 ror x25, x25, 64-15
 ror x31, x31, 64-2

 xor x16, x29, x8
 xor x20, x26, x10
 xor x24, x18, x7
 xor x28, x15, x9
 ror x16, x16, 64-61
 ror x20, x20, 64-8
 ror x24, x24, 64-10
 ror x28, x28, 64-55

 xor x29, x21, x10
 xor x26, x30, x9
 xor x18, x14, x8
 xor x15, x23, x7
 ror x29, x29, 64-39
 ror x26, x26, 64-56
 ror x18, x18, 64-6
 ror x15, x15, 64-45

 xor x21, x27, x11
 ld x27, 16(x2) # load original A[0][*]
 xor x30, x22, x11
 ld x22, 32(x2)
 xor x14, x17, x11
 ld x17, 8(x2)
 xor x23, x12, x11
 ld x12, 24(x2)
 ror x21, x21, 64-18
 ror x30, x30, 64-41
 ror x14, x14, 64-3
 ror x23, x23, 64-36

 xor x27, x27, x8
 xor x22, x22, x10
 xor x17, x17, x7
 xor x12, x12, x9
 ror x27, x27, 64-62
 ror x22, x22, 64-27
 ror x17, x17, 64-1
 ror x12, x12, 64-28

 andn x5, x14, x13
 andn x7, x15, x14
 andn x8, x16, x15
 andn x9, x12, x16
 andn x10, x13, x12
 xor x12, x12, x5
 xor x13, x13, x7
 xor x14, x14, x8
 xor x15, x15, x9
 xor x16, x16, x10

 andn x5, x19, x18
 andn x7, x20, x19
 andn x8, x21, x20
 andn x9, x17, x21
 andn x10, x18, x17
 xor x17, x17, x5
 xor x18, x18, x7
 xor x19, x19, x8
 xor x20, x20, x9
 xor x21, x21, x10

 andn x5, x24, x23
 andn x7, x25, x24
 andn x8, x26, x25
 andn x9, x22, x26
 andn x10, x23, x22
 xor x22, x22, x5
 xor x23, x23, x7
 xor x24, x24, x8
 xor x25, x25, x9
 xor x26, x26, x10

 andn x5, x29, x28
 andn x7, x30, x29
 andn x8, x31, x30
 andn x9, x27, x31
 andn x10, x28, x27
 xor x27, x27, x5
 xor x28, x28, x7
 ld x7, 0(x2) # reload A[0][*]
 xor x29, x29, x8
 ld x8, 48(x2)
 xor x30, x30, x9
 ld x9, 56(x2)
 xor x31, x31, x10
 ld x10, 64(x2)

 xor x7, x7, x11
 ld x11, 72(x2)

 sd x27, 40(x2) # make room for T[2]
 andn x27, x11, x10
 sd x28, 48(x2) # make room for T[3]
 andn x28, x7, x11
 andn x5, x10, x9
 andn x6, x9, x8
 xor x9, x9, x27
 andn x27, x8, x7
 xor x10, x10, x28
 ld x28, 0(x1) # *iotas++
 add x1, x1, 8
 xor x8, x8, x5
 xor x7, x7, x6
 xor x11, x11, x27
#else
 add x7, x9, x9 # dsll x9, 1
 xor x7, x7, x5
 srl x8, x9, 63
 xor x7, x7, x8 # D[1] = T[0] ^ ROL64(D[3], 1);
 add x8, x11, x11 # dsll x11, 1
 xor x9, x9, x8
 srl x8, x11, 63
 xor x9, x9, x8 # D[3] ^= ROL64(D[0], 1);
 add x8, x6, x6 # dsll x6, 1
 xor x11, x11, x8
 srl x8, x6, 63
 xor x11, x11, x8 # D[0] ^= ROL64(T[1], 1);
 add x8, x10, x10 # dsll x10, 1
 xor x8, x8, x6
 srl x6, x10, 63
 xor x8, x8, x6 # D[2] = T[1] ^ ROL64(D[4], 1);
 add x6, x5, x5 # dsll x5, 1
 xor x10, x10, x6
 srl x6, x5, 63
 xor x10, x10, x6 # D[4] ^= ROL64(T[0], 1);


 xor x5, x13, x7
 sll x6, x5, 44
 srl x5, x5, 64-44
 or x6, x6, x5

 xor x5, x19, x8
 sd x6, 48(x2) # offload new A[0][*]
 sll x6, x5, 43
 srl x5, x5, 64-43
 or x6, x6, x5

 xor x5, x25, x9
 sd x6, 56(x2)
 sll x6, x5, 21
 srl x5, x5, 64-21
 or x6, x6, x5

 xor x5, x31, x10
 sd x6, 64(x2)
 sll x6, x5, 14
 srl x5, x5, 64-14
 or x6, x6, x5


 xor x13, x16, x10
 xor x19, x20, x9
 sd x6, 72(x2)
 srl x5, x13, 64-20
 srl x6, x19, 64-25
 sll x13, x13, 20
 sll x19, x19, 25

 xor x25, x24, x8
 xor x31, x28, x7
 or x13, x13, x5
 srl x5, x25, 64-15
 or x19, x19, x6
 srl x6, x31, 64-2
 sll x25, x25, 15
 sll x31, x31, 2


 xor x16, x29, x8
 xor x20, x26, x10
 or x25, x25, x5
 srl x5, x16, 64-61
 or x31, x31, x6
 srl x6, x20, 64-8
 sll x16, x16, 61
 sll x20, x20, 8

 xor x24, x18, x7
 xor x28, x15, x9
 or x16, x16, x5
 srl x5, x24, 64-10
 or x20, x20, x6
 srl x6, x28, 64-55
 sll x24, x24, 10
 sll x28, x28, 55


 xor x29, x21, x10
 xor x26, x30, x9
 or x24, x24, x5
 srl x5, x29, 64-39
 or x28, x28, x6
 srl x6, x26, 64-56
 sll x29, x29, 39
 sll x26, x26, 56

 xor x18, x14, x8
 xor x15, x23, x7
 or x29, x29, x5
 srl x5, x18, 64-6
 or x26, x26, x6
 srl x6, x15, 64-45
 sll x18, x18, 6
 sll x15, x15, 45


 xor x21, x27, x11
 ld x27, 16(x2) # load original A[0][*]
 xor x30, x22, x11
 ld x22, 32(x2)
 or x18, x18, x5
 srl x5, x21, 64-18
 or x15, x15, x6
 srl x6, x30, 64-41
 sll x21, x21, 18
 sll x30, x30, 41

 xor x14, x17, x11
 ld x17, 8(x2)
 xor x23, x12, x11
 ld x12, 24(x2)
 or x21, x21, x5
 srl x5, x14, 64-3
 or x30, x30, x6
 srl x6, x23, 64-36
 sll x14, x14, 3
 sll x23, x23, 36


 xor x27, x27, x8
 xor x22, x22, x10
 or x14, x14, x5
 srl x5, x27, 64-62
 or x23, x23, x6
 srl x6, x22, 64-27
 sll x27, x27, 62
 sll x22, x22, 27

 xor x17, x17, x7
 xor x12, x12, x9
 or x27, x27, x5
 srl x5, x17, 64-1
 or x22, x22, x6
 srl x6, x12, 64-28
 sll x17, x17, 1
 sll x12, x12, 28
 or x17, x17, x5
 or x12, x12, x6

 not x8, x16
 or x5, x13, x14
 and x7, x14, x15
 or x8, x8, x15
 or x9, x16, x12
 and x10, x12, x13
 xor x12, x12, x5
 xor x13, x13, x7
 xor x14, x14, x8
 xor x15, x15, x9
 xor x16, x16, x10

 or x5, x18, x19
 and x7, x19, x20
 not x20, x20
 or x9, x21, x17
 and x10, x17, x18
 and x8, x20, x21
 xor x17, x17, x5
 xor x18, x18, x7
 xor x19, x19, x8
 xor x20, x20, x9
 xor x21, x21, x10

 and x5, x23, x24
 or x7, x24, x25
 not x25, x25
 and x9, x26, x22
 or x10, x22, x23
 or x8, x25, x26
 not x6, x28
 xor x22, x22, x5
 xor x23, x23, x7
 xor x24, x24, x8
 xor x25, x25, x9
 xor x26, x26, x10

 and x5, x6, x29
 or x7, x29, x30
 and x8, x30, x31
 or x9, x31, x27
 and x10, x27, x28
 xor x27, x27, x5
 xor x28, x6, x7
 ld x7, 0(x2) # reload A[0][*]
 xor x29, x29, x8
 ld x8, 48(x2)
 xor x30, x30, x9
 ld x9, 56(x2)
 xor x31, x31, x10
 ld x10, 64(x2)

 xor x7, x7, x11
 ld x11, 72(x2)

 not x6, x9
 or x5, x8, x9
 or x6, x6, x10
 sd x27, 40(x2) # make room for T[2]
 and x27, x10, x11
 sd x28, 48(x2) # make room for T[3]
 or x28, x11, x7
 xor x9, x9, x27
 and x27, x7, x8
 xor x10, x10, x28
 ld x28, 0(x1) # *iotas++
 add x1, x1, 8
 xor x11, x11, x27
 xor x7, x7, x5
 xor x8, x8, x6
#endif
 ld x5, 80+__SIZEOF_POINTER__(x2)
 xor x7, x7, x28 # A[0][0] ^= iotas[i]

 bne x1, x5, .Loop

 POP x1, 80(x2)

 ld x27, 40(x2)
 ld x28, 48(x2)

 add x2, x2, 8*14
 ret
.size __KeccakF1600, .-__KeccakF1600

.globl KeccakF1600
.type KeccakF1600, @function
.align 2
KeccakF1600:
	li x11, 24
	j KeccakF1600_rounds
.size KeccakF1600, .-KeccakF1600
.type KeccakF1600_rounds, @function
.align 2
KeccakF1600_rounds:
 add x2, x2, -__SIZEOF_POINTER__*16

 PUSH x1, __SIZEOF_POINTER__*15(x2)
 PUSH x8, __SIZEOF_POINTER__*14(x2)
 PUSH x9, __SIZEOF_POINTER__*13(x2)
 PUSH x18, __SIZEOF_POINTER__*12(x2)
 PUSH x19, __SIZEOF_POINTER__*11(x2)
 PUSH x20, __SIZEOF_POINTER__*10(x2)
 PUSH x21, __SIZEOF_POINTER__*9(x2)
 PUSH x22, __SIZEOF_POINTER__*8(x2)
 PUSH x23, __SIZEOF_POINTER__*7(x2)
 PUSH x24, __SIZEOF_POINTER__*6(x2)
 PUSH x25, __SIZEOF_POINTER__*5(x2)
 PUSH x26, __SIZEOF_POINTER__*4(x2)
 PUSH x27, __SIZEOF_POINTER__*3(x2)

 PUSH x10, 0(x2)
 mv x1, x10
 mv x6, x11 # number of rounds

 ld x7, 0x00(x10)
 ld x8, 0x08(x10)
 ld x9, 0x10(x10)
 ld x10, 0x18(x10)
 ld x11, 0x20(x1)
 ld x12, 0x28(x1)
 ld x13, 0x30(x1)
 ld x14, 0x38(x1)
 ld x15, 0x40(x1)
 ld x16, 0x48(x1)
 ld x17, 0x50(x1)
 ld x18, 0x58(x1)
 ld x19, 0x60(x1)
 ld x20, 0x68(x1)
 ld x21, 0x70(x1)
 ld x22, 0x78(x1)
 ld x23, 0x80(x1)
 ld x24, 0x88(x1)
 ld x25, 0x90(x1)
 ld x26, 0x98(x1)
 ld x27, 0xa0(x1)
 ld x28, 0xa8(x1)
 ld x29, 0xb0(x1)
 ld x30, 0xb8(x1)
 ld x31, 0xc0(x1)

#ifndef __riscv_zbb
 not x8, x8
 not x9, x9
 not x15, x15
 not x19, x19
 not x24, x24
 not x27, x27
#endif

 jal __KeccakF1600

 POP x6, 0(x2)

#ifndef __riscv_zbb
 not x8, x8
 not x9, x9
 not x15, x15
 not x19, x19
 not x24, x24
 not x27, x27
#endif

 sd x7, 0x00(x6)
 sd x8, 0x08(x6)
 sd x9, 0x10(x6)
 sd x10, 0x18(x6)
 sd x11, 0x20(x6)
 sd x12, 0x28(x6)
 sd x13, 0x30(x6)
 sd x14, 0x38(x6)
 sd x15, 0x40(x6)
 sd x16, 0x48(x6)
 sd x17, 0x50(x6)
 sd x18, 0x58(x6)
 sd x19, 0x60(x6)
 sd x20, 0x68(x6)
 sd x21, 0x70(x6)
 sd x22, 0x78(x6)
 sd x23, 0x80(x6)
 sd x24, 0x88(x6)
 sd x25, 0x90(x6)
 sd x26, 0x98(x6)
 sd x27, 0xa0(x6)
 sd x28, 0xa8(x6)
 sd x29, 0xb0(x6)
 sd x30, 0xb8(x6)
 sd x31, 0xc0(x6)

 POP x1, __SIZEOF_POINTER__*15(x2)
 POP x8, __SIZEOF_POINTER__*14(x2)
 POP x9, __SIZEOF_POINTER__*13(x2)
 POP x18, __SIZEOF_POINTER__*12(x2)
 POP x19, __SIZEOF_POINTER__*11(x2)
 POP x20, __SIZEOF_POINTER__*10(x2)
 POP x21, __SIZEOF_POINTER__*9(x2)
 POP x22, __SIZEOF_POINTER__*8(x2)
 POP x23, __SIZEOF_POINTER__*7(x2)
 POP x24, __SIZEOF_POINTER__*6(x2)
 POP x25, __SIZEOF_POINTER__*5(x2)
 POP x26, __SIZEOF_POINTER__*4(x2)
 POP x27, __SIZEOF_POINTER__*3(x2)
 add x2, x2, __SIZEOF_POINTER__*16
 ret
.size KeccakF1600_rounds, .-KeccakF1600_rounds
#ifndef __riscv_misaligned_fast
.type __load_n_xor, @function
.align 2
__load_n_xor:
 lbu x28, 0(x29)
 lbu x30, 1(x29)
 xor x5, x5, x28
 lbu x28, 2(x29)
 sll x30, x30, 8
 xor x5, x5, x30
 lbu x30, 3(x29)
 sll x28, x28, 16
 xor x5, x5, x28
 lbu x28, 4(x29)
 sll x30, x30, 24
 xor x5, x5, x30
 lbu x30, 5(x29)
 sll x28, x28, 32
 xor x5, x5, x28
 lbu x28, 6(x29)
 sll x30, x30, 40
 xor x5, x5, x30
 lbu x30, 7(x29)
 sll x28, x28, 48
 xor x5, x5, x28
 sll x30, x30, 56
 xor x5, x5, x30
 add x29, x29, 8
 ret
.size __load_n_xor, .-__load_n_xor
#endif

.globl SHA3_absorb
.type SHA3_absorb, @function
.align 2
SHA3_absorb:
#ifdef __riscv_zicfilp
 lpad 0
#endif
 bltu x12, x13, .Labsorb_abort

 add x2, x2, -__SIZEOF_POINTER__*20

 PUSH x1, __SIZEOF_POINTER__*19(x2)
 PUSH x8, __SIZEOF_POINTER__*18(x2)
 PUSH x9, __SIZEOF_POINTER__*17(x2)
 PUSH x18, __SIZEOF_POINTER__*16(x2)
 PUSH x19, __SIZEOF_POINTER__*15(x2)
 PUSH x20, __SIZEOF_POINTER__*14(x2)
 PUSH x21, __SIZEOF_POINTER__*13(x2)
 PUSH x22, __SIZEOF_POINTER__*12(x2)
 PUSH x23, __SIZEOF_POINTER__*11(x2)
 PUSH x24, __SIZEOF_POINTER__*10(x2)
 PUSH x25, __SIZEOF_POINTER__*9(x2)
 PUSH x26, __SIZEOF_POINTER__*8(x2)
 PUSH x27, __SIZEOF_POINTER__*7(x2)

 mv x6, x10
 mv x29, x11
 PUSH x10, __SIZEOF_POINTER__*0(x2) # put aside A[][]
 mv x30, x12
 sd x13, __SIZEOF_POINTER__*3(x2) # put aside bsz
 mv x31, x13

 ld x7, 0x00(x10)
 ld x8, 0x08(x10)
 ld x9, 0x10(x10)
 ld x10, 0x18(x10)
 ld x11, 0x20(x6)
 ld x12, 0x28(x6)
 ld x13, 0x30(x6)
 ld x14, 0x38(x6)
 ld x15, 0x40(x6)
 ld x16, 0x48(x6)
 ld x17, 0x50(x6)
 ld x18, 0x58(x6)
 ld x19, 0x60(x6)
 ld x20, 0x68(x6)
 ld x21, 0x70(x6)
 ld x22, 0x78(x6)
 ld x23, 0x80(x6)
 ld x24, 0x88(x6)
 ld x25, 0x90(x6)
 ld x26, 0x98(x6)
 ld x27, 0xa0(x6)

#ifndef __riscv_zbb
 not x8, x8
 not x9, x9
 not x15, x15
 not x19, x19
 not x24, x24
 not x27, x27
#endif

.Loop_absorb:
 sub x30, x30, x31
 add x1, x29, x31 # pointer to next block
 andi x5, x29, 7 # is input aligned?
 sd x30, __SIZEOF_POINTER__*2(x2)
 PUSH x1, __SIZEOF_POINTER__*1(x2)

#ifndef __riscv_misaligned_fast
 beqz x5, .Labsorb_aligned

 mv x5, x7
 jal __load_n_xor
 mv x7, x5
 mv x5, x8
 jal __load_n_xor
 mv x8, x5
 mv x5, x9
 jal __load_n_xor
 mv x9, x5
 mv x5, x10
 jal __load_n_xor
 mv x10, x5
 mv x5, x11
 jal __load_n_xor
 mv x11, x5
 mv x5, x12
 jal __load_n_xor
 mv x12, x5
 mv x5, x13
 jal __load_n_xor
 mv x13, x5
 mv x5, x14
 jal __load_n_xor
 mv x14, x5
 mv x5, x15
 jal __load_n_xor
 li x28, 72
 mv x15, x5
 beq x31, x28, .Lprocess_block

 mv x5, x16
 jal __load_n_xor
 mv x16, x5
 mv x5, x17
 jal __load_n_xor
 mv x17, x5
 mv x5, x18
 jal __load_n_xor
 mv x18, x5
 mv x5, x19
 jal __load_n_xor
 li x28, 104
 mv x19, x5
 beq x31, x28, .Lprocess_block

 mv x5, x20
 jal __load_n_xor
 mv x20, x5
 mv x5, x21
 jal __load_n_xor
 mv x21, x5
 mv x5, x22
 jal __load_n_xor
 mv x22, x5
 mv x5, x23
 jal __load_n_xor
 li x28, 136
 mv x23, x5
 beq x31, x28, .Lprocess_block

 mv x5, x24
 jal __load_n_xor
 li x28, 144
 mv x24, x5
 beq x31, x28, .Lprocess_block

 mv x5, x25
 jal __load_n_xor
 mv x25, x5
 mv x5, x26
 jal __load_n_xor
 mv x26, x5
 mv x5, x27
 jal __load_n_xor
 mv x27, x5
 j .Lprocess_block

.Labsorb_aligned:
#endif
 ld x28, 8*0(x29)
 ld x30, 8*1(x29)
 ld x5, 8*2(x29)
 ld x1, 8*3(x29)
 xor x7, x7, x28
 ld x28, 8*4(x29)
 xor x8, x8, x30
 ld x30, 8*5(x29)
 xor x9, x9, x5
 ld x5, 8*6(x29)
 xor x10, x10, x1
 ld x1, 8*7(x29)
 xor x11, x11, x28
 ld x28, 8*8(x29)
 xor x12, x12, x30
 li x30, 72
 xor x13, x13, x5
 add x29, x29, 8*9
 xor x14, x14, x1
 xor x15, x15, x28
 beq x31, x30, .Lprocess_block

 ld x28, 8*0(x29)
 ld x30, 8*1(x29)
 ld x5, 8*2(x29)
 ld x1, 8*3(x29)
 add x29, x29, 8*4
 xor x16, x16, x28
 li x28, 104
 xor x17, x17, x30
 xor x18, x18, x5
 xor x19, x19, x1
 beq x31, x28, .Lprocess_block

 ld x28, 8*0(x29)
 ld x30, 8*1(x29)
 ld x5, 8*2(x29)
 ld x1, 8*3(x29)
 add x29, x29, 8*4
 xor x20, x20, x28
 li x28, 136
 xor x21, x21, x30
 xor x22, x22, x5
 xor x23, x23, x1
 beq x31, x28, .Lprocess_block

 ld x28, 8*0(x29)
 li x30, 144
 add x29, x29, 8*1
 xor x24, x24, x28
 beq x31, x30, .Lprocess_block

 ld x28, 8*0(x29)
 ld x30, 8*1(x29)
 ld x5, 8*2(x29)
 add x29, x29, 8*3
 xor x25, x25, x28
 xor x26, x26, x30
 xor x27, x27, x5

.Lprocess_block:
 ld x28, 0xa8(x6)
 ld x29, 0xb0(x6)
 ld x30, 0xb8(x6)
 ld x31, 0xc0(x6)

 li x6, 24 # number of rounds
 jal __KeccakF1600

 POP x6, __SIZEOF_POINTER__*0(x2) # pull A[][]

 sd x28, 0xa8(x6)
 sd x29, 0xb0(x6)
 sd x30, 0xb8(x6)
 sd x31, 0xc0(x6)

 ld x31, __SIZEOF_POINTER__*3(x2)
 ld x30, __SIZEOF_POINTER__*2(x2)
 POP x29, __SIZEOF_POINTER__*1(x2) # pointer to next block

 bgeu x30, x31, .Loop_absorb # len < bsz?

#ifndef __riscv_zbb
 not x8, x8
 not x9, x9
 not x15, x15
 not x19, x19
 not x24, x24
 not x27, x27
#endif

 sd x7, 0x00(x6)
 sd x8, 0x08(x6)
 sd x9, 0x10(x6)
 sd x10, 0x18(x6)
 sd x11, 0x20(x6)
 sd x12, 0x28(x6)
 sd x13, 0x30(x6)
 sd x14, 0x38(x6)
 sd x15, 0x40(x6)
 sd x16, 0x48(x6)
 sd x17, 0x50(x6)
 sd x18, 0x58(x6)
 sd x19, 0x60(x6)
 sd x20, 0x68(x6)
 sd x21, 0x70(x6)
 sd x22, 0x78(x6)
 sd x23, 0x80(x6)
 sd x24, 0x88(x6)
 sd x25, 0x90(x6)
 sd x26, 0x98(x6)
 sd x27, 0xa0(x6)

 mv x10, x30 # return value

 POP x1, __SIZEOF_POINTER__*19(x2)
 POP x8, __SIZEOF_POINTER__*18(x2)
 POP x9, __SIZEOF_POINTER__*17(x2)
 POP x18, __SIZEOF_POINTER__*16(x2)
 POP x19, __SIZEOF_POINTER__*15(x2)
 POP x20, __SIZEOF_POINTER__*14(x2)
 POP x21, __SIZEOF_POINTER__*13(x2)
 POP x22, __SIZEOF_POINTER__*12(x2)
 POP x23, __SIZEOF_POINTER__*11(x2)
 POP x24, __SIZEOF_POINTER__*10(x2)
 POP x25, __SIZEOF_POINTER__*9(x2)
 POP x26, __SIZEOF_POINTER__*8(x2)
 POP x27, __SIZEOF_POINTER__*7(x2)
 add x2, x2, __SIZEOF_POINTER__*20
 ret

.Labsorb_abort:
 mv x10, x12 # return value
 ret
.size SHA3_absorb, .-SHA3_absorb
.globl SHA3_squeeze
.type SHA3_squeeze, @function
.align 2
SHA3_squeeze:
#ifdef __riscv_zicfilp
 lpad 0
#endif
 add x2, x2, -__SIZEOF_POINTER__*6

 PUSH x1, __SIZEOF_POINTER__*5(x2)
 PUSH x8, __SIZEOF_POINTER__*3(x2)
 PUSH x9, __SIZEOF_POINTER__*2(x2)
 PUSH x18, __SIZEOF_POINTER__*1(x2)
 PUSH x19, __SIZEOF_POINTER__*0(x2)

 mv x8, x10
 mv x9, x11
 mv x18, x12
 mv x19, x13

.Loop_squeeze:
 ld x14, 0(x10)
 sltu x1, x18, 8 # len < 8?
 add x10, x10, 8
 bnez x1, .Lsqueeze_tail

 srl x15, x14, 8
 sb x14, 0(x9)
 srl x16, x14, 16
 sb x15, 1(x9)
 srl x17, x14, 24
 sb x16, 2(x9)
 srl x5, x14, 32
 sb x17, 3(x9)
 srl x15, x14, 40
 sb x5, 4(x9)
 srl x16, x14, 48
 sb x15, 5(x9)
 srl x17, x14, 56
 sb x16, 6(x9)
 addi x18, x18, -8 # len -= 8
 sb x17, 7(x9)
 add x9, x9, 8
 beqz x18, .Lsqueeze_done

 addi x13, x13, -8
 bnez x13, .Loop_squeeze

 mv x10, x8
 li x11, 24 # number of rounds
	jal KeccakF1600_rounds

 mv x10, x8
 mv x13, x19
 j .Loop_squeeze

.Lsqueeze_tail:
 sb x14, 0(x9)
 add x9, x9, 1
 addi x18, x18, -1
 srl x14, x14, 8
 bnez x18, .Lsqueeze_tail

.Lsqueeze_done:
 POP x1, __SIZEOF_POINTER__*5(x2)
 POP x8, __SIZEOF_POINTER__*3(x2)
 POP x9, __SIZEOF_POINTER__*2(x2)
 POP x18, __SIZEOF_POINTER__*1(x2)
 POP x19, __SIZEOF_POINTER__*0(x2)
 add x2, x2, __SIZEOF_POINTER__*6
 ret
.size SHA3_squeeze, .-SHA3_squeeze
.section .rodata
.align 6
iotas:
 .dword 0x0000000000000001
 .dword 0x0000000000008082
 .dword 0x800000000000808a
 .dword 0x8000000080008000
 .dword 0x000000000000808b
 .dword 0x0000000080000001
 .dword 0x8000000080008081
 .dword 0x8000000000008009
 .dword 0x000000000000008a
 .dword 0x0000000000000088
 .dword 0x0000000080008009
 .dword 0x000000008000000a
 .dword 0x000000008000808b
 .dword 0x800000000000008b
 .dword 0x8000000000008089
 .dword 0x8000000000008003
 .dword 0x8000000000008002
 .dword 0x8000000000000080
 .dword 0x000000000000800a
 .dword 0x800000008000000a
 .dword 0x8000000080008081
 .dword 0x8000000000008080
 .dword 0x0000000080000001
 .dword 0x8000000080008008
.string "Keccak-1600 absorb and squeeze for RISC-V, CRYPTOGAMS by @dot-asm"
