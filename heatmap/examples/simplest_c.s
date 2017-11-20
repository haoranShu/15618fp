GAS LISTING /tmp/ccYl4XIm.s 			page 1


   1              		.file	"simplest.c"
   2              		.section	.debug_abbrev,"",@progbits
   3              	.Ldebug_abbrev0:
   4              		.section	.debug_info,"",@progbits
   5              	.Ldebug_info0:
   6              		.section	.debug_line,"",@progbits
   7              	.Ldebug_line0:
   8 0000 0E010000 		.text
   8      0200B400 
   8      00000101 
   8      FB0E0D00 
   8      01010101 
   9              	.Ltext0:
  10              		.section	.rodata.str1.1,"aMS",@progbits,1
  11              	.LC0:
  12 0000 546F7461 		.string	"Total time: %f seconds\n"
  12      6C207469 
  12      6D653A20 
  12      25662073 
  12      65636F6E 
  13              	.LC1:
  14 0018 68656174 		.string	"heatmap.png"
  14      6D61702E 
  14      706E6700 
  15              		.section	.rodata.str1.8,"aMS",@progbits,1
  16              		.align 8
  17              	.LC2:
  18 0000 4572726F 		.string	"Error (%u) creating PNG file: %s\n"
  18      72202825 
  18      75292063 
  18      72656174 
  18      696E6720 
  19              		.text
  20              		.p2align 4,,15
  21              	.globl main
  22              		.type	main, @function
  23              	main:
  24              	.LFB30:
  25              		.file 1 "examples/simplest.c"
   0:examples/simplest.c **** /* heatmap - High performance heatmap creation in C.
   1:examples/simplest.c ****  *
   2:examples/simplest.c ****  * The MIT License (MIT)
   3:examples/simplest.c ****  *
   4:examples/simplest.c ****  * Copyright (c) 2013 Lucas Beyer
   5:examples/simplest.c ****  *
   6:examples/simplest.c ****  * Permission is hereby granted, free of charge, to any person obtaining a copy of
   7:examples/simplest.c ****  * this software and associated documentation files (the "Software"), to deal in
   8:examples/simplest.c ****  * the Software without restriction, including without limitation the rights to
   9:examples/simplest.c ****  * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
  10:examples/simplest.c ****  * the Software, and to permit persons to whom the Software is furnished to do so,
  11:examples/simplest.c ****  * subject to the following conditions:
  12:examples/simplest.c ****  *
  13:examples/simplest.c ****  * The above copyright notice and this permission notice shall be included in all
  14:examples/simplest.c ****  * copies or substantial portions of the Software.
  15:examples/simplest.c ****  *
  16:examples/simplest.c ****  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  17:examples/simplest.c ****  * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
GAS LISTING /tmp/ccYl4XIm.s 			page 2


  18:examples/simplest.c ****  * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
  19:examples/simplest.c ****  * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
  20:examples/simplest.c ****  * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
  21:examples/simplest.c ****  * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  22:examples/simplest.c ****  */
  23:examples/simplest.c **** 
  24:examples/simplest.c **** #include <stdlib.h>
  25:examples/simplest.c **** #include <stdio.h>
  26:examples/simplest.c **** #include <time.h>
  27:examples/simplest.c **** #include <omp.h>
  28:examples/simplest.c **** 
  29:examples/simplest.c **** #include "lodepng.h"
  30:examples/simplest.c **** #include "heatmap.h"
  31:examples/simplest.c **** 
  32:examples/simplest.c **** int main()
  33:examples/simplest.c **** {
  26              		.loc 1 34 0
  27              		.cfi_startproc
  28 0000 4157     		pushq	%r15
  29              		.cfi_def_cfa_offset 16
  30              		.cfi_offset 15, -16
  34:examples/simplest.c ****     static const size_t w = 4096, h = 4096, npoints = 10000;
  35:examples/simplest.c ****     unsigned char image[4096 * 4096 * 4];
  36:examples/simplest.c ****     unsigned i;
  37:examples/simplest.c **** 
  38:examples/simplest.c ****     srand(time(NULL));
  31              		.loc 1 39 0
  32 0002 31FF     		xorl	%edi, %edi
  34:examples/simplest.c ****     static const size_t w = 4096, h = 4096, npoints = 10000;
  33              		.loc 1 34 0
  34 0004 4156     		pushq	%r14
  35              		.cfi_def_cfa_offset 24
  36              		.cfi_offset 14, -24
  37 0006 4155     		pushq	%r13
  38              		.cfi_def_cfa_offset 32
  39              		.cfi_offset 13, -32
  39:examples/simplest.c **** 
  40:examples/simplest.c ****     unsigned *xs = (unsigned *) malloc(sizeof(unsigned) * npoints);
  41:examples/simplest.c ****     unsigned *ys = (unsigned *) malloc(sizeof(unsigned) * npoints);
  40              		.loc 1 42 0
  41 0008 4531ED   		xorl	%r13d, %r13d
  34:examples/simplest.c ****     static const size_t w = 4096, h = 4096, npoints = 10000;
  42              		.loc 1 34 0
  43 000b 4154     		pushq	%r12
  44              		.cfi_def_cfa_offset 40
  45              		.cfi_offset 12, -40
  46              	.LBB2:
  42:examples/simplest.c ****     /* Add a bunch of random points to the heatmap now. */
  43:examples/simplest.c ****     for(i = 0 ; i < npoints ; ++i) {
  44:examples/simplest.c ****         /* Fake a normal distribution. */
  45:examples/simplest.c ****         unsigned x = rand() % w/3 + rand() % w/3 + rand() % w/3;
  46:examples/simplest.c ****         unsigned y = rand() % h/3 + rand() % h/3 + rand() % h/3;
  47:examples/simplest.c ****         xs[i] = x;
  47              		.loc 1 48 0
  48 000d 49BCABAA 		movabsq	$-6148914691236517205, %r12
  48      AAAAAAAA 
  48      AAAA
GAS LISTING /tmp/ccYl4XIm.s 			page 3


  49              	.LBE2:
  34:examples/simplest.c **** {
  50              		.loc 1 34 0
  51 0017 55       		pushq	%rbp
  52              		.cfi_def_cfa_offset 48
  53              		.cfi_offset 6, -48
  54 0018 53       		pushq	%rbx
  55              		.cfi_def_cfa_offset 56
  56              		.cfi_offset 3, -56
  57 0019 4881EC38 		subq	$67108920, %rsp
  57      000004
  58              		.cfi_def_cfa_offset 67108976
  39:examples/simplest.c **** 
  59              		.loc 1 39 0
  60 0020 E8000000 		call	time@PLT
  60      00
  61 0025 89C7     		movl	%eax, %edi
  62 0027 E8000000 		call	srand@PLT
  62      00
  41:examples/simplest.c ****     unsigned *xs = (unsigned *) malloc(sizeof(unsigned) * npoints);
  63              		.loc 1 41 0
  64 002c BF409C00 		movl	$40000, %edi
  64      00
  65 0031 E8000000 		call	malloc@PLT
  65      00
  42:examples/simplest.c ****     /* Add a bunch of random points to the heatmap now. */
  66              		.loc 1 42 0
  67 0036 BF409C00 		movl	$40000, %edi
  67      00
  41:examples/simplest.c ****     unsigned *xs = (unsigned *) malloc(sizeof(unsigned) * npoints);
  68              		.loc 1 41 0
  69 003b 4889C3   		movq	%rax, %rbx
  70              	.LVL0:
  42:examples/simplest.c ****     /* Add a bunch of random points to the heatmap now. */
  71              		.loc 1 42 0
  72 003e E8000000 		call	malloc@PLT
  72      00
  73              	.LVL1:
  74 0043 4889C5   		movq	%rax, %rbp
  75              	.LVL2:
  76 0046 662E0F1F 		.p2align 4,,10
  76      84000000 
  76      0000
  77              		.p2align 3
  78              	.L2:
  79              	.LBB3:
  46:examples/simplest.c ****         unsigned x = rand() % w/3 + rand() % w/3 + rand() % w/3;
  80              		.loc 1 46 0
  81 0050 E8000000 		call	rand@PLT
  81      00
  82 0055 89442420 		movl	%eax, 32(%rsp)
  83 0059 E8000000 		call	rand@PLT
  83      00
  84 005e 89442410 		movl	%eax, 16(%rsp)
  85 0062 E8000000 		call	rand@PLT
  85      00
  86 0067 89442408 		movl	%eax, 8(%rsp)
GAS LISTING /tmp/ccYl4XIm.s 			page 4


  47:examples/simplest.c ****         unsigned y = rand() % h/3 + rand() % h/3 + rand() % h/3;
  87              		.loc 1 47 0
  88 006b E8000000 		call	rand@PLT
  88      00
  89 0070 4189C6   		movl	%eax, %r14d
  90 0073 E8000000 		call	rand@PLT
  90      00
  91 0078 4189C7   		movl	%eax, %r15d
  48:examples/simplest.c ****         ys[i] = y;
  92              		.loc 1 49 0
  93 007b 4181E6FF 		andl	$4095, %r14d
  93      0F0000
  47:examples/simplest.c ****         unsigned y = rand() % h/3 + rand() % h/3 + rand() % h/3;
  94              		.loc 1 47 0
  95 0082 E8000000 		call	rand@PLT
  95      00
  48:examples/simplest.c ****         ys[i] = y;
  96              		.loc 1 48 0
  97 0087 8B742410 		movl	16(%rsp), %esi
  47:examples/simplest.c ****         unsigned y = rand() % h/3 + rand() % h/3 + rand() % h/3;
  98              		.loc 1 47 0
  99 008b 89C7     		movl	%eax, %edi
 100              		.loc 1 49 0
 101 008d 4C89F9   		movq	%r15, %rcx
 102 0090 81E1FF0F 		andl	$4095, %ecx
 102      0000
 103 0096 81E7FF0F 		andl	$4095, %edi
 103      0000
  48:examples/simplest.c ****         ys[i] = y;
 104              		.loc 1 48 0
 105 009c 81E6FF0F 		andl	$4095, %esi
 105      0000
 106 00a2 4889F0   		movq	%rsi, %rax
 107 00a5 49F7E4   		mulq	%r12
 108 00a8 4889D6   		movq	%rdx, %rsi
 109 00ab 8B542420 		movl	32(%rsp), %edx
 110 00af 48D1EE   		shrq	%rsi
 111 00b2 81E2FF0F 		andl	$4095, %edx
 111      0000
 112 00b8 4889D0   		movq	%rdx, %rax
 113 00bb 49F7E4   		mulq	%r12
 114 00be 48D1EA   		shrq	%rdx
 115 00c1 01D6     		addl	%edx, %esi
 116 00c3 8B542408 		movl	8(%rsp), %edx
 117 00c7 81E2FF0F 		andl	$4095, %edx
 117      0000
 118 00cd 4889D0   		movq	%rdx, %rax
 119 00d0 49F7E4   		mulq	%r12
 120              		.loc 1 49 0
 121 00d3 4889C8   		movq	%rcx, %rax
  48:examples/simplest.c ****         ys[i] = y;
 122              		.loc 1 48 0
 123 00d6 48D1EA   		shrq	%rdx
 124 00d9 01D6     		addl	%edx, %esi
 125              		.loc 1 49 0
 126 00db 49F7E4   		mulq	%r12
 127 00de 4C89F0   		movq	%r14, %rax
GAS LISTING /tmp/ccYl4XIm.s 			page 5


  48:examples/simplest.c ****         ys[i] = y;
 128              		.loc 1 48 0
 129 00e1 4289342B 		movl	%esi, (%rbx,%r13)
 130              		.loc 1 49 0
 131 00e5 4889D1   		movq	%rdx, %rcx
 132 00e8 49F7E4   		mulq	%r12
 133 00eb 48D1E9   		shrq	%rcx
 134 00ee 4889F8   		movq	%rdi, %rax
 135 00f1 48D1EA   		shrq	%rdx
 136 00f4 01D1     		addl	%edx, %ecx
 137 00f6 49F7E4   		mulq	%r12
 138 00f9 48D1EA   		shrq	%rdx
 139 00fc 01D1     		addl	%edx, %ecx
 140 00fe 42894C2D 		movl	%ecx, 0(%rbp,%r13)
 140      00
 141 0103 4983C504 		addq	$4, %r13
 142              	.LBE3:
  44:examples/simplest.c ****     for(i = 0 ; i < npoints ; ++i) {
 143              		.loc 1 44 0
 144 0107 4981FD40 		cmpq	$40000, %r13
 144      9C0000
 145 010e 0F853CFF 		jne	.L2
 145      FFFF
  49:examples/simplest.c ****     }
  50:examples/simplest.c ****     double begin = omp_get_wtime();
 146              		.loc 1 51 0
 147 0114 E8000000 		call	omp_get_wtime@PLT
 147      00
  51:examples/simplest.c **** 
  52:examples/simplest.c ****     /* Create the heatmap object with the given dimensions (in pixel). */
  53:examples/simplest.c ****     heatmap_t* hm = heatmap_new(w, h);
 148              		.loc 1 54 0
 149 0119 BE001000 		movl	$4096, %esi
 149      00
 150 011e BF001000 		movl	$4096, %edi
 150      00
  51:examples/simplest.c **** 
 151              		.loc 1 51 0
 152 0123 F20F1144 		movsd	%xmm0, 8(%rsp)
 152      2408
 153              	.LVL3:
 154              		.loc 1 54 0
 155 0129 E8000000 		call	heatmap_new@PLT
 155      00
 156              	.LVL4:
  54:examples/simplest.c **** 
  55:examples/simplest.c ****     heatmap_add_points_omp(hm, xs, ys, npoints);
 157              		.loc 1 56 0
 158 012e 4889DE   		movq	%rbx, %rsi
  56:examples/simplest.c **** 
  57:examples/simplest.c ****     /*for (i = 0; i < npoints; i++)*/
  58:examples/simplest.c ****     /*{*/
  59:examples/simplest.c ****         /*heatmap_add_point(hm, xs[i], ys[i]);*/
  60:examples/simplest.c ****     /*}*/
  61:examples/simplest.c **** 
  62:examples/simplest.c ****     /* This creates an image out of the heatmap.
  63:examples/simplest.c ****      * `image` now contains the image data in 32-bit RGBA.
GAS LISTING /tmp/ccYl4XIm.s 			page 6


  64:examples/simplest.c ****      */
  65:examples/simplest.c ****     heatmap_render_default_to(hm, image);
 159              		.loc 1 66 0
 160 0131 488D5C24 		leaq	48(%rsp), %rbx
 160      30
 161              	.LVL5:
  56:examples/simplest.c **** 
 162              		.loc 1 56 0
 163 0136 B9102700 		movl	$10000, %ecx
 163      00
 164 013b 4889EA   		movq	%rbp, %rdx
  54:examples/simplest.c **** 
 165              		.loc 1 54 0
 166 013e 4989C4   		movq	%rax, %r12
 167              	.LVL6:
  56:examples/simplest.c **** 
 168              		.loc 1 56 0
 169 0141 4889C7   		movq	%rax, %rdi
 170 0144 E8000000 		call	heatmap_add_points_omp@PLT
 170      00
 171              	.LVL7:
 172              		.loc 1 66 0
 173 0149 4889DE   		movq	%rbx, %rsi
 174 014c 4C89E7   		movq	%r12, %rdi
 175 014f E8000000 		call	heatmap_render_default_to@PLT
 175      00
  66:examples/simplest.c **** 
  67:examples/simplest.c ****     /* Now that we've got a finished heatmap picture,
  68:examples/simplest.c ****      * we don't need the map anymore.
  69:examples/simplest.c ****      */
  70:examples/simplest.c ****     heatmap_free(hm);
 176              		.loc 1 71 0
 177 0154 4C89E7   		movq	%r12, %rdi
 178 0157 E8000000 		call	heatmap_free@PLT
 178      00
  71:examples/simplest.c **** 
  72:examples/simplest.c ****     double end = omp_get_wtime();
 179              		.loc 1 73 0
 180 015c E8000000 		call	omp_get_wtime@PLT
 180      00
 181              	.LVL8:
  73:examples/simplest.c ****     printf("Total time: %f seconds\n", end - begin);
 182              		.loc 1 74 0
 183 0161 F20F5C44 		subsd	8(%rsp), %xmm0
 183      2408
 184              	.LVL9:
 185 0167 488D3D00 		leaq	.LC0(%rip), %rdi
 185      000000
 186 016e B8010000 		movl	$1, %eax
 186      00
 187 0173 E8000000 		call	printf@PLT
 187      00
 188              	.LBB4:
  74:examples/simplest.c **** 
  75:examples/simplest.c ****     /* Finally, we use the fantastic lodepng library to save it as an image. */
  76:examples/simplest.c ****     {
  77:examples/simplest.c ****         unsigned error = lodepng_encode32_file("heatmap.png", image, w, h);
GAS LISTING /tmp/ccYl4XIm.s 			page 7


 189              		.loc 1 78 0
 190 0178 488D3D00 		leaq	.LC1(%rip), %rdi
 190      000000
 191 017f 4889DE   		movq	%rbx, %rsi
 192 0182 B9001000 		movl	$4096, %ecx
 192      00
 193 0187 BA001000 		movl	$4096, %edx
 193      00
 194 018c E8000000 		call	lodepng_encode32_file@PLT
 194      00
  78:examples/simplest.c ****         if(error)
 195              		.loc 1 79 0
 196 0191 85C0     		testl	%eax, %eax
  78:examples/simplest.c ****         if(error)
 197              		.loc 1 78 0
 198 0193 89C3     		movl	%eax, %ebx
 199              	.LVL10:
 200              		.loc 1 79 0
 201 0195 7424     		je	.L3
  79:examples/simplest.c ****             fprintf(stderr, "Error (%u) creating PNG file: %s\n",
 202              		.loc 1 80 0
 203 0197 89C7     		movl	%eax, %edi
 204 0199 E8000000 		call	lodepng_error_text@PLT
 204      00
 205              	.LVL11:
 206 019e 4889C1   		movq	%rax, %rcx
 207 01a1 488B0500 		movq	stderr@GOTPCREL(%rip), %rax
 207      000000
 208 01a8 488D3500 		leaq	.LC2(%rip), %rsi
 208      000000
 209 01af 89DA     		movl	%ebx, %edx
 210 01b1 488B38   		movq	(%rax), %rdi
 211 01b4 31C0     		xorl	%eax, %eax
 212 01b6 E8000000 		call	fprintf@PLT
 212      00
 213              	.L3:
 214              	.LBE4:
  80:examples/simplest.c ****                     error, lodepng_error_text(error));
  81:examples/simplest.c ****     }
  82:examples/simplest.c **** 
  83:examples/simplest.c ****     return 0;
  84:examples/simplest.c **** }
 215              		.loc 1 85 0
 216 01bb 4881C438 		addq	$67108920, %rsp
 216      000004
 217              		.cfi_def_cfa_offset 56
 218 01c2 31C0     		xorl	%eax, %eax
 219 01c4 5B       		popq	%rbx
 220              		.cfi_def_cfa_offset 48
 221              	.LVL12:
 222 01c5 5D       		popq	%rbp
 223              		.cfi_def_cfa_offset 40
 224              	.LVL13:
 225 01c6 415C     		popq	%r12
 226              		.cfi_def_cfa_offset 32
 227              	.LVL14:
 228 01c8 415D     		popq	%r13
GAS LISTING /tmp/ccYl4XIm.s 			page 8


 229              		.cfi_def_cfa_offset 24
 230 01ca 415E     		popq	%r14
 231              		.cfi_def_cfa_offset 16
 232 01cc 415F     		popq	%r15
 233              		.cfi_def_cfa_offset 8
 234 01ce C3       		ret
 235              		.cfi_endproc
 236              	.LFE30:
 237              		.size	main, .-main
 238              	.Letext0:
 239              		.section	.debug_loc,"",@progbits
 240              	.Ldebug_loc0:
 241              	.LLST0:
 242 0000 3E000000 		.quad	.LVL0-.Ltext0
 242      00000000 
 243 0008 42000000 		.quad	.LVL1-1-.Ltext0
 243      00000000 
 244 0010 0100     		.value	0x1
 245 0012 50       		.byte	0x50
 246 0013 42000000 		.quad	.LVL1-1-.Ltext0
 246      00000000 
 247 001b 36010000 		.quad	.LVL5-.Ltext0
 247      00000000 
 248 0023 0100     		.value	0x1
 249 0025 53       		.byte	0x53
 250 0026 36010000 		.quad	.LVL5-.Ltext0
 250      00000000 
 251 002e 48010000 		.quad	.LVL7-1-.Ltext0
 251      00000000 
 252 0036 0100     		.value	0x1
 253 0038 54       		.byte	0x54
 254 0039 00000000 		.quad	0x0
 254      00000000 
 255 0041 00000000 		.quad	0x0
 255      00000000 
 256              	.LLST1:
 257 0049 46000000 		.quad	.LVL2-.Ltext0
 257      00000000 
 258 0051 C6010000 		.quad	.LVL13-.Ltext0
 258      00000000 
 259 0059 0100     		.value	0x1
 260 005b 56       		.byte	0x56
 261 005c 00000000 		.quad	0x0
 261      00000000 
 262 0064 00000000 		.quad	0x0
 262      00000000 
 263              	.LLST2:
 264 006c 29010000 		.quad	.LVL3-.Ltext0
 264      00000000 
 265 0074 2D010000 		.quad	.LVL4-1-.Ltext0
 265      00000000 
 266 007c 0100     		.value	0x1
 267 007e 61       		.byte	0x61
 268 007f 2D010000 		.quad	.LVL4-1-.Ltext0
 268      00000000 
 269 0087 CF010000 		.quad	.LFE30-.Ltext0
 269      00000000 
GAS LISTING /tmp/ccYl4XIm.s 			page 9


 270 008f 0500     		.value	0x5
 271 0091 91       		.byte	0x91
 272 0092 98FFFF5F 		.sleb128 -67108968
 273 0096 00000000 		.quad	0x0
 273      00000000 
 274 009e 00000000 		.quad	0x0
 274      00000000 
 275              	.LLST3:
 276 00a6 41010000 		.quad	.LVL6-.Ltext0
 276      00000000 
 277 00ae 48010000 		.quad	.LVL7-1-.Ltext0
 277      00000000 
 278 00b6 0100     		.value	0x1
 279 00b8 50       		.byte	0x50
 280 00b9 48010000 		.quad	.LVL7-1-.Ltext0
 280      00000000 
 281 00c1 C8010000 		.quad	.LVL14-.Ltext0
 281      00000000 
 282 00c9 0100     		.value	0x1
 283 00cb 5C       		.byte	0x5c
 284 00cc 00000000 		.quad	0x0
 284      00000000 
 285 00d4 00000000 		.quad	0x0
 285      00000000 
 286              	.LLST4:
 287 00dc 61010000 		.quad	.LVL8-.Ltext0
 287      00000000 
 288 00e4 67010000 		.quad	.LVL9-.Ltext0
 288      00000000 
 289 00ec 0100     		.value	0x1
 290 00ee 61       		.byte	0x61
 291 00ef 00000000 		.quad	0x0
 291      00000000 
 292 00f7 00000000 		.quad	0x0
 292      00000000 
 293              	.LLST5:
 294 00ff 95010000 		.quad	.LVL10-.Ltext0
 294      00000000 
 295 0107 9D010000 		.quad	.LVL11-1-.Ltext0
 295      00000000 
 296 010f 0100     		.value	0x1
 297 0111 50       		.byte	0x50
 298 0112 9D010000 		.quad	.LVL11-1-.Ltext0
 298      00000000 
 299 011a C5010000 		.quad	.LVL12-.Ltext0
 299      00000000 
 300 0122 0100     		.value	0x1
 301 0124 53       		.byte	0x53
 302 0125 00000000 		.quad	0x0
 302      00000000 
 303 012d 00000000 		.quad	0x0
 303      00000000 
 304              		.file 2 "/usr/lib/gcc/x86_64-redhat-linux/4.4.7/include/stddef.h"
 305              		.file 3 "/usr/include/bits/types.h"
 306              		.file 4 "/usr/include/libio.h"
 307              		.file 5 "./heatmap.h"
 308              		.file 6 "/usr/include/stdio.h"
GAS LISTING /tmp/ccYl4XIm.s 			page 10


 309              		.section	.debug_info
 310 0000 51040000 		.long	0x451
 311 0004 0300     		.value	0x3
 312 0006 00000000 		.long	.Ldebug_abbrev0
 313 000a 08       		.byte	0x8
 314 000b 01       		.uleb128 0x1
 315 000c 00000000 		.long	.LASF57
 316 0010 01       		.byte	0x1
 317 0011 00000000 		.long	.LASF58
 318 0015 00000000 		.long	.LASF59
 319 0019 00000000 		.quad	.Ltext0
 319      00000000 
 320 0021 00000000 		.quad	.Letext0
 320      00000000 
 321 0029 00000000 		.long	.Ldebug_line0
 322 002d 02       		.uleb128 0x2
 323 002e 00000000 		.long	.LASF8
 324 0032 02       		.byte	0x2
 325 0033 D3       		.byte	0xd3
 326 0034 38000000 		.long	0x38
 327 0038 03       		.uleb128 0x3
 328 0039 08       		.byte	0x8
 329 003a 07       		.byte	0x7
 330 003b 00000000 		.long	.LASF0
 331 003f 04       		.uleb128 0x4
 332 0040 04       		.byte	0x4
 333 0041 05       		.byte	0x5
 334 0042 696E7400 		.string	"int"
 335 0046 03       		.uleb128 0x3
 336 0047 04       		.byte	0x4
 337 0048 07       		.byte	0x7
 338 0049 00000000 		.long	.LASF1
 339 004d 03       		.uleb128 0x3
 340 004e 08       		.byte	0x8
 341 004f 05       		.byte	0x5
 342 0050 00000000 		.long	.LASF2
 343 0054 03       		.uleb128 0x3
 344 0055 08       		.byte	0x8
 345 0056 05       		.byte	0x5
 346 0057 00000000 		.long	.LASF3
 347 005b 03       		.uleb128 0x3
 348 005c 01       		.byte	0x1
 349 005d 08       		.byte	0x8
 350 005e 00000000 		.long	.LASF4
 351 0062 03       		.uleb128 0x3
 352 0063 02       		.byte	0x2
 353 0064 07       		.byte	0x7
 354 0065 00000000 		.long	.LASF5
 355 0069 03       		.uleb128 0x3
 356 006a 01       		.byte	0x1
 357 006b 06       		.byte	0x6
 358 006c 00000000 		.long	.LASF6
 359 0070 03       		.uleb128 0x3
 360 0071 02       		.byte	0x2
 361 0072 05       		.byte	0x5
 362 0073 00000000 		.long	.LASF7
 363 0077 02       		.uleb128 0x2
GAS LISTING /tmp/ccYl4XIm.s 			page 11


 364 0078 00000000 		.long	.LASF9
 365 007c 03       		.byte	0x3
 366 007d 8D       		.byte	0x8d
 367 007e 4D000000 		.long	0x4d
 368 0082 02       		.uleb128 0x2
 369 0083 00000000 		.long	.LASF10
 370 0087 03       		.byte	0x3
 371 0088 8E       		.byte	0x8e
 372 0089 4D000000 		.long	0x4d
 373 008d 05       		.uleb128 0x5
 374 008e 08       		.byte	0x8
 375 008f 06       		.uleb128 0x6
 376 0090 08       		.byte	0x8
 377 0091 95000000 		.long	0x95
 378 0095 03       		.uleb128 0x3
 379 0096 01       		.byte	0x1
 380 0097 06       		.byte	0x6
 381 0098 00000000 		.long	.LASF11
 382 009c 03       		.uleb128 0x3
 383 009d 08       		.byte	0x8
 384 009e 07       		.byte	0x7
 385 009f 00000000 		.long	.LASF12
 386 00a3 07       		.uleb128 0x7
 387 00a4 00000000 		.long	.LASF42
 388 00a8 D8       		.byte	0xd8
 389 00a9 04       		.byte	0x4
 390 00aa 0F01     		.value	0x10f
 391 00ac 3F020000 		.long	0x23f
 392 00b0 08       		.uleb128 0x8
 393 00b1 00000000 		.long	.LASF13
 394 00b5 04       		.byte	0x4
 395 00b6 1001     		.value	0x110
 396 00b8 3F000000 		.long	0x3f
 397 00bc 00       		.sleb128 0
 398 00bd 08       		.uleb128 0x8
 399 00be 00000000 		.long	.LASF14
 400 00c2 04       		.byte	0x4
 401 00c3 1501     		.value	0x115
 402 00c5 8F000000 		.long	0x8f
 403 00c9 08       		.sleb128 8
 404 00ca 08       		.uleb128 0x8
 405 00cb 00000000 		.long	.LASF15
 406 00cf 04       		.byte	0x4
 407 00d0 1601     		.value	0x116
 408 00d2 8F000000 		.long	0x8f
 409 00d6 10       		.sleb128 16
 410 00d7 08       		.uleb128 0x8
 411 00d8 00000000 		.long	.LASF16
 412 00dc 04       		.byte	0x4
 413 00dd 1701     		.value	0x117
 414 00df 8F000000 		.long	0x8f
 415 00e3 18       		.sleb128 24
 416 00e4 08       		.uleb128 0x8
 417 00e5 00000000 		.long	.LASF17
 418 00e9 04       		.byte	0x4
 419 00ea 1801     		.value	0x118
 420 00ec 8F000000 		.long	0x8f
GAS LISTING /tmp/ccYl4XIm.s 			page 12


 421 00f0 20       		.sleb128 32
 422 00f1 08       		.uleb128 0x8
 423 00f2 00000000 		.long	.LASF18
 424 00f6 04       		.byte	0x4
 425 00f7 1901     		.value	0x119
 426 00f9 8F000000 		.long	0x8f
 427 00fd 28       		.sleb128 40
 428 00fe 08       		.uleb128 0x8
 429 00ff 00000000 		.long	.LASF19
 430 0103 04       		.byte	0x4
 431 0104 1A01     		.value	0x11a
 432 0106 8F000000 		.long	0x8f
 433 010a 30       		.sleb128 48
 434 010b 08       		.uleb128 0x8
 435 010c 00000000 		.long	.LASF20
 436 0110 04       		.byte	0x4
 437 0111 1B01     		.value	0x11b
 438 0113 8F000000 		.long	0x8f
 439 0117 38       		.sleb128 56
 440 0118 08       		.uleb128 0x8
 441 0119 00000000 		.long	.LASF21
 442 011d 04       		.byte	0x4
 443 011e 1C01     		.value	0x11c
 444 0120 8F000000 		.long	0x8f
 445 0124 C000     		.sleb128 64
 446 0126 08       		.uleb128 0x8
 447 0127 00000000 		.long	.LASF22
 448 012b 04       		.byte	0x4
 449 012c 1E01     		.value	0x11e
 450 012e 8F000000 		.long	0x8f
 451 0132 C800     		.sleb128 72
 452 0134 08       		.uleb128 0x8
 453 0135 00000000 		.long	.LASF23
 454 0139 04       		.byte	0x4
 455 013a 1F01     		.value	0x11f
 456 013c 8F000000 		.long	0x8f
 457 0140 D000     		.sleb128 80
 458 0142 08       		.uleb128 0x8
 459 0143 00000000 		.long	.LASF24
 460 0147 04       		.byte	0x4
 461 0148 2001     		.value	0x120
 462 014a 8F000000 		.long	0x8f
 463 014e D800     		.sleb128 88
 464 0150 08       		.uleb128 0x8
 465 0151 00000000 		.long	.LASF25
 466 0155 04       		.byte	0x4
 467 0156 2201     		.value	0x122
 468 0158 77020000 		.long	0x277
 469 015c E000     		.sleb128 96
 470 015e 08       		.uleb128 0x8
 471 015f 00000000 		.long	.LASF26
 472 0163 04       		.byte	0x4
 473 0164 2401     		.value	0x124
 474 0166 7D020000 		.long	0x27d
 475 016a E800     		.sleb128 104
 476 016c 08       		.uleb128 0x8
 477 016d 00000000 		.long	.LASF27
GAS LISTING /tmp/ccYl4XIm.s 			page 13


 478 0171 04       		.byte	0x4
 479 0172 2601     		.value	0x126
 480 0174 3F000000 		.long	0x3f
 481 0178 F000     		.sleb128 112
 482 017a 08       		.uleb128 0x8
 483 017b 00000000 		.long	.LASF28
 484 017f 04       		.byte	0x4
 485 0180 2A01     		.value	0x12a
 486 0182 3F000000 		.long	0x3f
 487 0186 F400     		.sleb128 116
 488 0188 08       		.uleb128 0x8
 489 0189 00000000 		.long	.LASF29
 490 018d 04       		.byte	0x4
 491 018e 2C01     		.value	0x12c
 492 0190 77000000 		.long	0x77
 493 0194 F800     		.sleb128 120
 494 0196 08       		.uleb128 0x8
 495 0197 00000000 		.long	.LASF30
 496 019b 04       		.byte	0x4
 497 019c 3001     		.value	0x130
 498 019e 62000000 		.long	0x62
 499 01a2 8001     		.sleb128 128
 500 01a4 08       		.uleb128 0x8
 501 01a5 00000000 		.long	.LASF31
 502 01a9 04       		.byte	0x4
 503 01aa 3101     		.value	0x131
 504 01ac 69000000 		.long	0x69
 505 01b0 8201     		.sleb128 130
 506 01b2 08       		.uleb128 0x8
 507 01b3 00000000 		.long	.LASF32
 508 01b7 04       		.byte	0x4
 509 01b8 3201     		.value	0x132
 510 01ba 83020000 		.long	0x283
 511 01be 8301     		.sleb128 131
 512 01c0 08       		.uleb128 0x8
 513 01c1 00000000 		.long	.LASF33
 514 01c5 04       		.byte	0x4
 515 01c6 3601     		.value	0x136
 516 01c8 93020000 		.long	0x293
 517 01cc 8801     		.sleb128 136
 518 01ce 08       		.uleb128 0x8
 519 01cf 00000000 		.long	.LASF34
 520 01d3 04       		.byte	0x4
 521 01d4 3F01     		.value	0x13f
 522 01d6 82000000 		.long	0x82
 523 01da 9001     		.sleb128 144
 524 01dc 08       		.uleb128 0x8
 525 01dd 00000000 		.long	.LASF35
 526 01e1 04       		.byte	0x4
 527 01e2 4801     		.value	0x148
 528 01e4 8D000000 		.long	0x8d
 529 01e8 9801     		.sleb128 152
 530 01ea 08       		.uleb128 0x8
 531 01eb 00000000 		.long	.LASF36
 532 01ef 04       		.byte	0x4
 533 01f0 4901     		.value	0x149
 534 01f2 8D000000 		.long	0x8d
GAS LISTING /tmp/ccYl4XIm.s 			page 14


 535 01f6 A001     		.sleb128 160
 536 01f8 08       		.uleb128 0x8
 537 01f9 00000000 		.long	.LASF37
 538 01fd 04       		.byte	0x4
 539 01fe 4A01     		.value	0x14a
 540 0200 8D000000 		.long	0x8d
 541 0204 A801     		.sleb128 168
 542 0206 08       		.uleb128 0x8
 543 0207 00000000 		.long	.LASF38
 544 020b 04       		.byte	0x4
 545 020c 4B01     		.value	0x14b
 546 020e 8D000000 		.long	0x8d
 547 0212 B001     		.sleb128 176
 548 0214 08       		.uleb128 0x8
 549 0215 00000000 		.long	.LASF39
 550 0219 04       		.byte	0x4
 551 021a 4C01     		.value	0x14c
 552 021c 2D000000 		.long	0x2d
 553 0220 B801     		.sleb128 184
 554 0222 08       		.uleb128 0x8
 555 0223 00000000 		.long	.LASF40
 556 0227 04       		.byte	0x4
 557 0228 4E01     		.value	0x14e
 558 022a 3F000000 		.long	0x3f
 559 022e C001     		.sleb128 192
 560 0230 08       		.uleb128 0x8
 561 0231 00000000 		.long	.LASF41
 562 0235 04       		.byte	0x4
 563 0236 5001     		.value	0x150
 564 0238 99020000 		.long	0x299
 565 023c C401     		.sleb128 196
 566 023e 00       		.byte	0x0
 567 023f 09       		.uleb128 0x9
 568 0240 00000000 		.long	.LASF60
 569 0244 04       		.byte	0x4
 570 0245 B4       		.byte	0xb4
 571 0246 0A       		.uleb128 0xa
 572 0247 00000000 		.long	.LASF43
 573 024b 18       		.byte	0x18
 574 024c 04       		.byte	0x4
 575 024d BA       		.byte	0xba
 576 024e 77020000 		.long	0x277
 577 0252 0B       		.uleb128 0xb
 578 0253 00000000 		.long	.LASF44
 579 0257 04       		.byte	0x4
 580 0258 BB       		.byte	0xbb
 581 0259 77020000 		.long	0x277
 582 025d 00       		.sleb128 0
 583 025e 0B       		.uleb128 0xb
 584 025f 00000000 		.long	.LASF45
 585 0263 04       		.byte	0x4
 586 0264 BC       		.byte	0xbc
 587 0265 7D020000 		.long	0x27d
 588 0269 08       		.sleb128 8
 589 026a 0B       		.uleb128 0xb
 590 026b 00000000 		.long	.LASF46
 591 026f 04       		.byte	0x4
GAS LISTING /tmp/ccYl4XIm.s 			page 15


 592 0270 C0       		.byte	0xc0
 593 0271 3F000000 		.long	0x3f
 594 0275 10       		.sleb128 16
 595 0276 00       		.byte	0x0
 596 0277 06       		.uleb128 0x6
 597 0278 08       		.byte	0x8
 598 0279 46020000 		.long	0x246
 599 027d 06       		.uleb128 0x6
 600 027e 08       		.byte	0x8
 601 027f A3000000 		.long	0xa3
 602 0283 0C       		.uleb128 0xc
 603 0284 95000000 		.long	0x95
 604 0288 93020000 		.long	0x293
 605 028c 0D       		.uleb128 0xd
 606 028d 38000000 		.long	0x38
 607 0291 00       		.byte	0x0
 608 0292 00       		.byte	0x0
 609 0293 06       		.uleb128 0x6
 610 0294 08       		.byte	0x8
 611 0295 3F020000 		.long	0x23f
 612 0299 0C       		.uleb128 0xc
 613 029a 95000000 		.long	0x95
 614 029e A9020000 		.long	0x2a9
 615 02a2 0D       		.uleb128 0xd
 616 02a3 38000000 		.long	0x38
 617 02a7 13       		.byte	0x13
 618 02a8 00       		.byte	0x0
 619 02a9 0E       		.uleb128 0xe
 620 02aa 18       		.byte	0x18
 621 02ab 05       		.byte	0x5
 622 02ac 27       		.byte	0x27
 623 02ad DE020000 		.long	0x2de
 624 02b1 0F       		.uleb128 0xf
 625 02b2 62756600 		.string	"buf"
 626 02b6 05       		.byte	0x5
 627 02b7 28       		.byte	0x28
 628 02b8 DE020000 		.long	0x2de
 629 02bc 00       		.sleb128 0
 630 02bd 0F       		.uleb128 0xf
 631 02be 6D617800 		.string	"max"
 632 02c2 05       		.byte	0x5
 633 02c3 29       		.byte	0x29
 634 02c4 E4020000 		.long	0x2e4
 635 02c8 08       		.sleb128 8
 636 02c9 0F       		.uleb128 0xf
 637 02ca 7700     		.string	"w"
 638 02cc 05       		.byte	0x5
 639 02cd 2A       		.byte	0x2a
 640 02ce 46000000 		.long	0x46
 641 02d2 0C       		.sleb128 12
 642 02d3 0F       		.uleb128 0xf
 643 02d4 6800     		.string	"h"
 644 02d6 05       		.byte	0x5
 645 02d7 2A       		.byte	0x2a
 646 02d8 46000000 		.long	0x46
 647 02dc 10       		.sleb128 16
 648 02dd 00       		.byte	0x0
GAS LISTING /tmp/ccYl4XIm.s 			page 16


 649 02de 06       		.uleb128 0x6
 650 02df 08       		.byte	0x8
 651 02e0 E4020000 		.long	0x2e4
 652 02e4 03       		.uleb128 0x3
 653 02e5 04       		.byte	0x4
 654 02e6 04       		.byte	0x4
 655 02e7 00000000 		.long	.LASF47
 656 02eb 02       		.uleb128 0x2
 657 02ec 00000000 		.long	.LASF48
 658 02f0 05       		.byte	0x5
 659 02f1 2B       		.byte	0x2b
 660 02f2 A9020000 		.long	0x2a9
 661 02f6 10       		.uleb128 0x10
 662 02f7 01       		.byte	0x1
 663 02f8 00000000 		.long	.LASF61
 664 02fc 01       		.byte	0x1
 665 02fd 21       		.byte	0x21
 666 02fe 3F000000 		.long	0x3f
 667 0302 00000000 		.quad	.LFB30
 667      00000000 
 668 030a 00000000 		.quad	.LFE30
 668      00000000 
 669 0312 01       		.byte	0x1
 670 0313 9C       		.byte	0x9c
 671 0314 DB030000 		.long	0x3db
 672 0318 11       		.uleb128 0x11
 673 0319 7700     		.string	"w"
 674 031b 01       		.byte	0x1
 675 031c 23       		.byte	0x23
 676 031d DB030000 		.long	0x3db
 677 0321 0010     		.value	0x1000
 678 0323 11       		.uleb128 0x11
 679 0324 6800     		.string	"h"
 680 0326 01       		.byte	0x1
 681 0327 23       		.byte	0x23
 682 0328 DB030000 		.long	0x3db
 683 032c 0010     		.value	0x1000
 684 032e 12       		.uleb128 0x12
 685 032f 00000000 		.long	.LASF49
 686 0333 01       		.byte	0x1
 687 0334 23       		.byte	0x23
 688 0335 DB030000 		.long	0x3db
 689 0339 1027     		.value	0x2710
 690 033b 13       		.uleb128 0x13
 691 033c 00000000 		.long	.LASF50
 692 0340 01       		.byte	0x1
 693 0341 24       		.byte	0x24
 694 0342 E0030000 		.long	0x3e0
 695 0346 05       		.byte	0x5
 696 0347 91       		.byte	0x91
 697 0348 C0FFFF5F 		.sleb128 -67108928
 698 034c 14       		.uleb128 0x14
 699 034d 6900     		.string	"i"
 700 034f 01       		.byte	0x1
 701 0350 25       		.byte	0x25
 702 0351 46000000 		.long	0x46
 703 0355 15       		.uleb128 0x15
GAS LISTING /tmp/ccYl4XIm.s 			page 17


 704 0356 787300   		.string	"xs"
 705 0359 01       		.byte	0x1
 706 035a 29       		.byte	0x29
 707 035b F3030000 		.long	0x3f3
 708 035f 00000000 		.long	.LLST0
 709 0363 15       		.uleb128 0x15
 710 0364 797300   		.string	"ys"
 711 0367 01       		.byte	0x1
 712 0368 2A       		.byte	0x2a
 713 0369 F3030000 		.long	0x3f3
 714 036d 00000000 		.long	.LLST1
 715 0371 16       		.uleb128 0x16
 716 0372 00000000 		.long	.LASF51
 717 0376 01       		.byte	0x1
 718 0377 33       		.byte	0x33
 719 0378 F9030000 		.long	0x3f9
 720 037c 00000000 		.long	.LLST2
 721 0380 15       		.uleb128 0x15
 722 0381 686D00   		.string	"hm"
 723 0384 01       		.byte	0x1
 724 0385 36       		.byte	0x36
 725 0386 00040000 		.long	0x400
 726 038a 00000000 		.long	.LLST3
 727 038e 15       		.uleb128 0x15
 728 038f 656E6400 		.string	"end"
 729 0393 01       		.byte	0x1
 730 0394 49       		.byte	0x49
 731 0395 F9030000 		.long	0x3f9
 732 0399 00000000 		.long	.LLST4
 733 039d 17       		.uleb128 0x17
 734 039e 00000000 		.long	.Ldebug_ranges0+0x0
 735 03a2 B9030000 		.long	0x3b9
 736 03a6 14       		.uleb128 0x14
 737 03a7 7800     		.string	"x"
 738 03a9 01       		.byte	0x1
 739 03aa 2E       		.byte	0x2e
 740 03ab 46000000 		.long	0x46
 741 03af 14       		.uleb128 0x14
 742 03b0 7900     		.string	"y"
 743 03b2 01       		.byte	0x1
 744 03b3 2F       		.byte	0x2f
 745 03b4 46000000 		.long	0x46
 746 03b8 00       		.byte	0x0
 747 03b9 18       		.uleb128 0x18
 748 03ba 00000000 		.quad	.LBB4
 748      00000000 
 749 03c2 00000000 		.quad	.LBE4
 749      00000000 
 750 03ca 16       		.uleb128 0x16
 751 03cb 00000000 		.long	.LASF52
 752 03cf 01       		.byte	0x1
 753 03d0 4E       		.byte	0x4e
 754 03d1 46000000 		.long	0x46
 755 03d5 00000000 		.long	.LLST5
 756 03d9 00       		.byte	0x0
 757 03da 00       		.byte	0x0
 758 03db 19       		.uleb128 0x19
GAS LISTING /tmp/ccYl4XIm.s 			page 18


 759 03dc 2D000000 		.long	0x2d
 760 03e0 0C       		.uleb128 0xc
 761 03e1 5B000000 		.long	0x5b
 762 03e5 F3030000 		.long	0x3f3
 763 03e9 1A       		.uleb128 0x1a
 764 03ea 38000000 		.long	0x38
 765 03ee FFFFFF03 		.long	0x3ffffff
 766 03f2 00       		.byte	0x0
 767 03f3 06       		.uleb128 0x6
 768 03f4 08       		.byte	0x8
 769 03f5 46000000 		.long	0x46
 770 03f9 03       		.uleb128 0x3
 771 03fa 08       		.byte	0x8
 772 03fb 04       		.byte	0x4
 773 03fc 00000000 		.long	.LASF53
 774 0400 06       		.uleb128 0x6
 775 0401 08       		.byte	0x8
 776 0402 EB020000 		.long	0x2eb
 777 0406 1B       		.uleb128 0x1b
 778 0407 00000000 		.long	.LASF54
 779 040b 06       		.byte	0x6
 780 040c A5       		.byte	0xa5
 781 040d 7D020000 		.long	0x27d
 782 0411 01       		.byte	0x1
 783 0412 01       		.byte	0x1
 784 0413 1B       		.uleb128 0x1b
 785 0414 00000000 		.long	.LASF55
 786 0418 06       		.byte	0x6
 787 0419 A6       		.byte	0xa6
 788 041a 7D020000 		.long	0x27d
 789 041e 01       		.byte	0x1
 790 041f 01       		.byte	0x1
 791 0420 1B       		.uleb128 0x1b
 792 0421 00000000 		.long	.LASF56
 793 0425 06       		.byte	0x6
 794 0426 A7       		.byte	0xa7
 795 0427 7D020000 		.long	0x27d
 796 042b 01       		.byte	0x1
 797 042c 01       		.byte	0x1
 798 042d 1B       		.uleb128 0x1b
 799 042e 00000000 		.long	.LASF54
 800 0432 06       		.byte	0x6
 801 0433 A5       		.byte	0xa5
 802 0434 7D020000 		.long	0x27d
 803 0438 01       		.byte	0x1
 804 0439 01       		.byte	0x1
 805 043a 1B       		.uleb128 0x1b
 806 043b 00000000 		.long	.LASF55
 807 043f 06       		.byte	0x6
 808 0440 A6       		.byte	0xa6
 809 0441 7D020000 		.long	0x27d
 810 0445 01       		.byte	0x1
 811 0446 01       		.byte	0x1
 812 0447 1B       		.uleb128 0x1b
 813 0448 00000000 		.long	.LASF56
 814 044c 06       		.byte	0x6
 815 044d A7       		.byte	0xa7
GAS LISTING /tmp/ccYl4XIm.s 			page 19


 816 044e 7D020000 		.long	0x27d
 817 0452 01       		.byte	0x1
 818 0453 01       		.byte	0x1
 819 0454 00       		.byte	0x0
 820              		.section	.debug_abbrev
 821 0000 01       		.uleb128 0x1
 822 0001 11       		.uleb128 0x11
 823 0002 01       		.byte	0x1
 824 0003 25       		.uleb128 0x25
 825 0004 0E       		.uleb128 0xe
 826 0005 13       		.uleb128 0x13
 827 0006 0B       		.uleb128 0xb
 828 0007 03       		.uleb128 0x3
 829 0008 0E       		.uleb128 0xe
 830 0009 1B       		.uleb128 0x1b
 831 000a 0E       		.uleb128 0xe
 832 000b 11       		.uleb128 0x11
 833 000c 01       		.uleb128 0x1
 834 000d 12       		.uleb128 0x12
 835 000e 01       		.uleb128 0x1
 836 000f 10       		.uleb128 0x10
 837 0010 06       		.uleb128 0x6
 838 0011 00       		.byte	0x0
 839 0012 00       		.byte	0x0
 840 0013 02       		.uleb128 0x2
 841 0014 16       		.uleb128 0x16
 842 0015 00       		.byte	0x0
 843 0016 03       		.uleb128 0x3
 844 0017 0E       		.uleb128 0xe
 845 0018 3A       		.uleb128 0x3a
 846 0019 0B       		.uleb128 0xb
 847 001a 3B       		.uleb128 0x3b
 848 001b 0B       		.uleb128 0xb
 849 001c 49       		.uleb128 0x49
 850 001d 13       		.uleb128 0x13
 851 001e 00       		.byte	0x0
 852 001f 00       		.byte	0x0
 853 0020 03       		.uleb128 0x3
 854 0021 24       		.uleb128 0x24
 855 0022 00       		.byte	0x0
 856 0023 0B       		.uleb128 0xb
 857 0024 0B       		.uleb128 0xb
 858 0025 3E       		.uleb128 0x3e
 859 0026 0B       		.uleb128 0xb
 860 0027 03       		.uleb128 0x3
 861 0028 0E       		.uleb128 0xe
 862 0029 00       		.byte	0x0
 863 002a 00       		.byte	0x0
 864 002b 04       		.uleb128 0x4
 865 002c 24       		.uleb128 0x24
 866 002d 00       		.byte	0x0
 867 002e 0B       		.uleb128 0xb
 868 002f 0B       		.uleb128 0xb
 869 0030 3E       		.uleb128 0x3e
 870 0031 0B       		.uleb128 0xb
 871 0032 03       		.uleb128 0x3
 872 0033 08       		.uleb128 0x8
GAS LISTING /tmp/ccYl4XIm.s 			page 20


 873 0034 00       		.byte	0x0
 874 0035 00       		.byte	0x0
 875 0036 05       		.uleb128 0x5
 876 0037 0F       		.uleb128 0xf
 877 0038 00       		.byte	0x0
 878 0039 0B       		.uleb128 0xb
 879 003a 0B       		.uleb128 0xb
 880 003b 00       		.byte	0x0
 881 003c 00       		.byte	0x0
 882 003d 06       		.uleb128 0x6
 883 003e 0F       		.uleb128 0xf
 884 003f 00       		.byte	0x0
 885 0040 0B       		.uleb128 0xb
 886 0041 0B       		.uleb128 0xb
 887 0042 49       		.uleb128 0x49
 888 0043 13       		.uleb128 0x13
 889 0044 00       		.byte	0x0
 890 0045 00       		.byte	0x0
 891 0046 07       		.uleb128 0x7
 892 0047 13       		.uleb128 0x13
 893 0048 01       		.byte	0x1
 894 0049 03       		.uleb128 0x3
 895 004a 0E       		.uleb128 0xe
 896 004b 0B       		.uleb128 0xb
 897 004c 0B       		.uleb128 0xb
 898 004d 3A       		.uleb128 0x3a
 899 004e 0B       		.uleb128 0xb
 900 004f 3B       		.uleb128 0x3b
 901 0050 05       		.uleb128 0x5
 902 0051 01       		.uleb128 0x1
 903 0052 13       		.uleb128 0x13
 904 0053 00       		.byte	0x0
 905 0054 00       		.byte	0x0
 906 0055 08       		.uleb128 0x8
 907 0056 0D       		.uleb128 0xd
 908 0057 00       		.byte	0x0
 909 0058 03       		.uleb128 0x3
 910 0059 0E       		.uleb128 0xe
 911 005a 3A       		.uleb128 0x3a
 912 005b 0B       		.uleb128 0xb
 913 005c 3B       		.uleb128 0x3b
 914 005d 05       		.uleb128 0x5
 915 005e 49       		.uleb128 0x49
 916 005f 13       		.uleb128 0x13
 917 0060 38       		.uleb128 0x38
 918 0061 0D       		.uleb128 0xd
 919 0062 00       		.byte	0x0
 920 0063 00       		.byte	0x0
 921 0064 09       		.uleb128 0x9
 922 0065 16       		.uleb128 0x16
 923 0066 00       		.byte	0x0
 924 0067 03       		.uleb128 0x3
 925 0068 0E       		.uleb128 0xe
 926 0069 3A       		.uleb128 0x3a
 927 006a 0B       		.uleb128 0xb
 928 006b 3B       		.uleb128 0x3b
 929 006c 0B       		.uleb128 0xb
GAS LISTING /tmp/ccYl4XIm.s 			page 21


 930 006d 00       		.byte	0x0
 931 006e 00       		.byte	0x0
 932 006f 0A       		.uleb128 0xa
 933 0070 13       		.uleb128 0x13
 934 0071 01       		.byte	0x1
 935 0072 03       		.uleb128 0x3
 936 0073 0E       		.uleb128 0xe
 937 0074 0B       		.uleb128 0xb
 938 0075 0B       		.uleb128 0xb
 939 0076 3A       		.uleb128 0x3a
 940 0077 0B       		.uleb128 0xb
 941 0078 3B       		.uleb128 0x3b
 942 0079 0B       		.uleb128 0xb
 943 007a 01       		.uleb128 0x1
 944 007b 13       		.uleb128 0x13
 945 007c 00       		.byte	0x0
 946 007d 00       		.byte	0x0
 947 007e 0B       		.uleb128 0xb
 948 007f 0D       		.uleb128 0xd
 949 0080 00       		.byte	0x0
 950 0081 03       		.uleb128 0x3
 951 0082 0E       		.uleb128 0xe
 952 0083 3A       		.uleb128 0x3a
 953 0084 0B       		.uleb128 0xb
 954 0085 3B       		.uleb128 0x3b
 955 0086 0B       		.uleb128 0xb
 956 0087 49       		.uleb128 0x49
 957 0088 13       		.uleb128 0x13
 958 0089 38       		.uleb128 0x38
 959 008a 0D       		.uleb128 0xd
 960 008b 00       		.byte	0x0
 961 008c 00       		.byte	0x0
 962 008d 0C       		.uleb128 0xc
 963 008e 01       		.uleb128 0x1
 964 008f 01       		.byte	0x1
 965 0090 49       		.uleb128 0x49
 966 0091 13       		.uleb128 0x13
 967 0092 01       		.uleb128 0x1
 968 0093 13       		.uleb128 0x13
 969 0094 00       		.byte	0x0
 970 0095 00       		.byte	0x0
 971 0096 0D       		.uleb128 0xd
 972 0097 21       		.uleb128 0x21
 973 0098 00       		.byte	0x0
 974 0099 49       		.uleb128 0x49
 975 009a 13       		.uleb128 0x13
 976 009b 2F       		.uleb128 0x2f
 977 009c 0B       		.uleb128 0xb
 978 009d 00       		.byte	0x0
 979 009e 00       		.byte	0x0
 980 009f 0E       		.uleb128 0xe
 981 00a0 13       		.uleb128 0x13
 982 00a1 01       		.byte	0x1
 983 00a2 0B       		.uleb128 0xb
 984 00a3 0B       		.uleb128 0xb
 985 00a4 3A       		.uleb128 0x3a
 986 00a5 0B       		.uleb128 0xb
GAS LISTING /tmp/ccYl4XIm.s 			page 22


 987 00a6 3B       		.uleb128 0x3b
 988 00a7 0B       		.uleb128 0xb
 989 00a8 01       		.uleb128 0x1
 990 00a9 13       		.uleb128 0x13
 991 00aa 00       		.byte	0x0
 992 00ab 00       		.byte	0x0
 993 00ac 0F       		.uleb128 0xf
 994 00ad 0D       		.uleb128 0xd
 995 00ae 00       		.byte	0x0
 996 00af 03       		.uleb128 0x3
 997 00b0 08       		.uleb128 0x8
 998 00b1 3A       		.uleb128 0x3a
 999 00b2 0B       		.uleb128 0xb
 1000 00b3 3B       		.uleb128 0x3b
 1001 00b4 0B       		.uleb128 0xb
 1002 00b5 49       		.uleb128 0x49
 1003 00b6 13       		.uleb128 0x13
 1004 00b7 38       		.uleb128 0x38
 1005 00b8 0D       		.uleb128 0xd
 1006 00b9 00       		.byte	0x0
 1007 00ba 00       		.byte	0x0
 1008 00bb 10       		.uleb128 0x10
 1009 00bc 2E       		.uleb128 0x2e
 1010 00bd 01       		.byte	0x1
 1011 00be 3F       		.uleb128 0x3f
 1012 00bf 0C       		.uleb128 0xc
 1013 00c0 03       		.uleb128 0x3
 1014 00c1 0E       		.uleb128 0xe
 1015 00c2 3A       		.uleb128 0x3a
 1016 00c3 0B       		.uleb128 0xb
 1017 00c4 3B       		.uleb128 0x3b
 1018 00c5 0B       		.uleb128 0xb
 1019 00c6 49       		.uleb128 0x49
 1020 00c7 13       		.uleb128 0x13
 1021 00c8 11       		.uleb128 0x11
 1022 00c9 01       		.uleb128 0x1
 1023 00ca 12       		.uleb128 0x12
 1024 00cb 01       		.uleb128 0x1
 1025 00cc 40       		.uleb128 0x40
 1026 00cd 0A       		.uleb128 0xa
 1027 00ce 01       		.uleb128 0x1
 1028 00cf 13       		.uleb128 0x13
 1029 00d0 00       		.byte	0x0
 1030 00d1 00       		.byte	0x0
 1031 00d2 11       		.uleb128 0x11
 1032 00d3 34       		.uleb128 0x34
 1033 00d4 00       		.byte	0x0
 1034 00d5 03       		.uleb128 0x3
 1035 00d6 08       		.uleb128 0x8
 1036 00d7 3A       		.uleb128 0x3a
 1037 00d8 0B       		.uleb128 0xb
 1038 00d9 3B       		.uleb128 0x3b
 1039 00da 0B       		.uleb128 0xb
 1040 00db 49       		.uleb128 0x49
 1041 00dc 13       		.uleb128 0x13
 1042 00dd 1C       		.uleb128 0x1c
 1043 00de 05       		.uleb128 0x5
GAS LISTING /tmp/ccYl4XIm.s 			page 23


 1044 00df 00       		.byte	0x0
 1045 00e0 00       		.byte	0x0
 1046 00e1 12       		.uleb128 0x12
 1047 00e2 34       		.uleb128 0x34
 1048 00e3 00       		.byte	0x0
 1049 00e4 03       		.uleb128 0x3
 1050 00e5 0E       		.uleb128 0xe
 1051 00e6 3A       		.uleb128 0x3a
 1052 00e7 0B       		.uleb128 0xb
 1053 00e8 3B       		.uleb128 0x3b
 1054 00e9 0B       		.uleb128 0xb
 1055 00ea 49       		.uleb128 0x49
 1056 00eb 13       		.uleb128 0x13
 1057 00ec 1C       		.uleb128 0x1c
 1058 00ed 05       		.uleb128 0x5
 1059 00ee 00       		.byte	0x0
 1060 00ef 00       		.byte	0x0
 1061 00f0 13       		.uleb128 0x13
 1062 00f1 34       		.uleb128 0x34
 1063 00f2 00       		.byte	0x0
 1064 00f3 03       		.uleb128 0x3
 1065 00f4 0E       		.uleb128 0xe
 1066 00f5 3A       		.uleb128 0x3a
 1067 00f6 0B       		.uleb128 0xb
 1068 00f7 3B       		.uleb128 0x3b
 1069 00f8 0B       		.uleb128 0xb
 1070 00f9 49       		.uleb128 0x49
 1071 00fa 13       		.uleb128 0x13
 1072 00fb 02       		.uleb128 0x2
 1073 00fc 0A       		.uleb128 0xa
 1074 00fd 00       		.byte	0x0
 1075 00fe 00       		.byte	0x0
 1076 00ff 14       		.uleb128 0x14
 1077 0100 34       		.uleb128 0x34
 1078 0101 00       		.byte	0x0
 1079 0102 03       		.uleb128 0x3
 1080 0103 08       		.uleb128 0x8
 1081 0104 3A       		.uleb128 0x3a
 1082 0105 0B       		.uleb128 0xb
 1083 0106 3B       		.uleb128 0x3b
 1084 0107 0B       		.uleb128 0xb
 1085 0108 49       		.uleb128 0x49
 1086 0109 13       		.uleb128 0x13
 1087 010a 00       		.byte	0x0
 1088 010b 00       		.byte	0x0
 1089 010c 15       		.uleb128 0x15
 1090 010d 34       		.uleb128 0x34
 1091 010e 00       		.byte	0x0
 1092 010f 03       		.uleb128 0x3
 1093 0110 08       		.uleb128 0x8
 1094 0111 3A       		.uleb128 0x3a
 1095 0112 0B       		.uleb128 0xb
 1096 0113 3B       		.uleb128 0x3b
 1097 0114 0B       		.uleb128 0xb
 1098 0115 49       		.uleb128 0x49
 1099 0116 13       		.uleb128 0x13
 1100 0117 02       		.uleb128 0x2
GAS LISTING /tmp/ccYl4XIm.s 			page 24


 1101 0118 06       		.uleb128 0x6
 1102 0119 00       		.byte	0x0
 1103 011a 00       		.byte	0x0
 1104 011b 16       		.uleb128 0x16
 1105 011c 34       		.uleb128 0x34
 1106 011d 00       		.byte	0x0
 1107 011e 03       		.uleb128 0x3
 1108 011f 0E       		.uleb128 0xe
 1109 0120 3A       		.uleb128 0x3a
 1110 0121 0B       		.uleb128 0xb
 1111 0122 3B       		.uleb128 0x3b
 1112 0123 0B       		.uleb128 0xb
 1113 0124 49       		.uleb128 0x49
 1114 0125 13       		.uleb128 0x13
 1115 0126 02       		.uleb128 0x2
 1116 0127 06       		.uleb128 0x6
 1117 0128 00       		.byte	0x0
 1118 0129 00       		.byte	0x0
 1119 012a 17       		.uleb128 0x17
 1120 012b 0B       		.uleb128 0xb
 1121 012c 01       		.byte	0x1
 1122 012d 55       		.uleb128 0x55
 1123 012e 06       		.uleb128 0x6
 1124 012f 01       		.uleb128 0x1
 1125 0130 13       		.uleb128 0x13
 1126 0131 00       		.byte	0x0
 1127 0132 00       		.byte	0x0
 1128 0133 18       		.uleb128 0x18
 1129 0134 0B       		.uleb128 0xb
 1130 0135 01       		.byte	0x1
 1131 0136 11       		.uleb128 0x11
 1132 0137 01       		.uleb128 0x1
 1133 0138 12       		.uleb128 0x12
 1134 0139 01       		.uleb128 0x1
 1135 013a 00       		.byte	0x0
 1136 013b 00       		.byte	0x0
 1137 013c 19       		.uleb128 0x19
 1138 013d 26       		.uleb128 0x26
 1139 013e 00       		.byte	0x0
 1140 013f 49       		.uleb128 0x49
 1141 0140 13       		.uleb128 0x13
 1142 0141 00       		.byte	0x0
 1143 0142 00       		.byte	0x0
 1144 0143 1A       		.uleb128 0x1a
 1145 0144 21       		.uleb128 0x21
 1146 0145 00       		.byte	0x0
 1147 0146 49       		.uleb128 0x49
 1148 0147 13       		.uleb128 0x13
 1149 0148 2F       		.uleb128 0x2f
 1150 0149 06       		.uleb128 0x6
 1151 014a 00       		.byte	0x0
 1152 014b 00       		.byte	0x0
 1153 014c 1B       		.uleb128 0x1b
 1154 014d 34       		.uleb128 0x34
 1155 014e 00       		.byte	0x0
 1156 014f 03       		.uleb128 0x3
 1157 0150 0E       		.uleb128 0xe
GAS LISTING /tmp/ccYl4XIm.s 			page 25


 1158 0151 3A       		.uleb128 0x3a
 1159 0152 0B       		.uleb128 0xb
 1160 0153 3B       		.uleb128 0x3b
 1161 0154 0B       		.uleb128 0xb
 1162 0155 49       		.uleb128 0x49
 1163 0156 13       		.uleb128 0x13
 1164 0157 3F       		.uleb128 0x3f
 1165 0158 0C       		.uleb128 0xc
 1166 0159 3C       		.uleb128 0x3c
 1167 015a 0C       		.uleb128 0xc
 1168 015b 00       		.byte	0x0
 1169 015c 00       		.byte	0x0
 1170 015d 00       		.byte	0x0
 1171              		.section	.debug_pubnames,"",@progbits
 1172 0000 17000000 		.long	0x17
 1173 0004 0200     		.value	0x2
 1174 0006 00000000 		.long	.Ldebug_info0
 1175 000a 55040000 		.long	0x455
 1176 000e F6020000 		.long	0x2f6
 1177 0012 6D61696E 		.string	"main"
 1177      00
 1178 0017 00000000 		.long	0x0
 1179              		.section	.debug_pubtypes,"",@progbits
 1180 0000 6C000000 		.long	0x6c
 1181 0004 0200     		.value	0x2
 1182 0006 00000000 		.long	.Ldebug_info0
 1183 000a 55040000 		.long	0x455
 1184 000e 2D000000 		.long	0x2d
 1185 0012 73697A65 		.string	"size_t"
 1185      5F7400
 1186 0019 77000000 		.long	0x77
 1187 001d 5F5F6F66 		.string	"__off_t"
 1187      665F7400 
 1188 0025 82000000 		.long	0x82
 1189 0029 5F5F6F66 		.string	"__off64_t"
 1189      6636345F 
 1189      7400
 1190 0033 3F020000 		.long	0x23f
 1191 0037 5F494F5F 		.string	"_IO_lock_t"
 1191      6C6F636B 
 1191      5F7400
 1192 0042 46020000 		.long	0x246
 1193 0046 5F494F5F 		.string	"_IO_marker"
 1193      6D61726B 
 1193      657200
 1194 0051 A3000000 		.long	0xa3
 1195 0055 5F494F5F 		.string	"_IO_FILE"
 1195      46494C45 
 1195      00
 1196 005e EB020000 		.long	0x2eb
 1197 0062 68656174 		.string	"heatmap_t"
 1197      6D61705F 
 1197      7400
 1198 006c 00000000 		.long	0x0
 1199              		.section	.debug_aranges,"",@progbits
 1200 0000 2C000000 		.long	0x2c
 1201 0004 0200     		.value	0x2
GAS LISTING /tmp/ccYl4XIm.s 			page 26


 1202 0006 00000000 		.long	.Ldebug_info0
 1203 000a 08       		.byte	0x8
 1204 000b 00       		.byte	0x0
 1205 000c 0000     		.value	0x0
 1206 000e 0000     		.value	0x0
 1207 0010 00000000 		.quad	.Ltext0
 1207      00000000 
 1208 0018 CF010000 		.quad	.Letext0-.Ltext0
 1208      00000000 
 1209 0020 00000000 		.quad	0x0
 1209      00000000 
 1210 0028 00000000 		.quad	0x0
 1210      00000000 
 1211              		.section	.debug_ranges,"",@progbits
 1212              	.Ldebug_ranges0:
 1213 0000 0D000000 		.quad	.LBB2-.Ltext0
 1213      00000000 
 1214 0008 17000000 		.quad	.LBE2-.Ltext0
 1214      00000000 
 1215 0010 50000000 		.quad	.LBB3-.Ltext0
 1215      00000000 
 1216 0018 07010000 		.quad	.LBE3-.Ltext0
 1216      00000000 
 1217 0020 00000000 		.quad	0x0
 1217      00000000 
 1218 0028 00000000 		.quad	0x0
 1218      00000000 
 1219              		.section	.debug_str,"MS",@progbits,1
 1220              	.LASF53:
 1221 0000 646F7562 		.string	"double"
 1221      6C6500
 1222              	.LASF42:
 1223 0007 5F494F5F 		.string	"_IO_FILE"
 1223      46494C45 
 1223      00
 1224              	.LASF24:
 1225 0010 5F494F5F 		.string	"_IO_save_end"
 1225      73617665 
 1225      5F656E64 
 1225      00
 1226              	.LASF58:
 1227 001d 6578616D 		.string	"examples/simplest.c"
 1227      706C6573 
 1227      2F73696D 
 1227      706C6573 
 1227      742E6300 
 1228              	.LASF7:
 1229 0031 73686F72 		.string	"short int"
 1229      7420696E 
 1229      7400
 1230              	.LASF8:
 1231 003b 73697A65 		.string	"size_t"
 1231      5F7400
 1232              	.LASF34:
 1233 0042 5F6F6666 		.string	"_offset"
 1233      73657400 
 1234              	.LASF48:
GAS LISTING /tmp/ccYl4XIm.s 			page 27


 1235 004a 68656174 		.string	"heatmap_t"
 1235      6D61705F 
 1235      7400
 1236              	.LASF51:
 1237 0054 62656769 		.string	"begin"
 1237      6E00
 1238              	.LASF18:
 1239 005a 5F494F5F 		.string	"_IO_write_ptr"
 1239      77726974 
 1239      655F7074 
 1239      7200
 1240              	.LASF13:
 1241 0068 5F666C61 		.string	"_flags"
 1241      677300
 1242              	.LASF20:
 1243 006f 5F494F5F 		.string	"_IO_buf_base"
 1243      6275665F 
 1243      62617365 
 1243      00
 1244              	.LASF25:
 1245 007c 5F6D6172 		.string	"_markers"
 1245      6B657273 
 1245      00
 1246              	.LASF15:
 1247 0085 5F494F5F 		.string	"_IO_read_end"
 1247      72656164 
 1247      5F656E64 
 1247      00
 1248              	.LASF59:
 1249 0092 2F686F6D 		.string	"/home/hshu1/15618/project/15618fp/heatmap"
 1249      652F6873 
 1249      6875312F 
 1249      31353631 
 1249      382F7072 
 1250              	.LASF47:
 1251 00bc 666C6F61 		.string	"float"
 1251      7400
 1252              	.LASF56:
 1253 00c2 73746465 		.string	"stderr"
 1253      727200
 1254              	.LASF3:
 1255 00c9 6C6F6E67 		.string	"long long int"
 1255      206C6F6E 
 1255      6720696E 
 1255      7400
 1256              	.LASF33:
 1257 00d7 5F6C6F63 		.string	"_lock"
 1257      6B00
 1258              	.LASF2:
 1259 00dd 6C6F6E67 		.string	"long int"
 1259      20696E74 
 1259      00
 1260              	.LASF30:
 1261 00e6 5F637572 		.string	"_cur_column"
 1261      5F636F6C 
 1261      756D6E00 
 1262              	.LASF46:
GAS LISTING /tmp/ccYl4XIm.s 			page 28


 1263 00f2 5F706F73 		.string	"_pos"
 1263      00
 1264              	.LASF29:
 1265 00f7 5F6F6C64 		.string	"_old_offset"
 1265      5F6F6666 
 1265      73657400 
 1266              	.LASF4:
 1267 0103 756E7369 		.string	"unsigned char"
 1267      676E6564 
 1267      20636861 
 1267      7200
 1268              	.LASF6:
 1269 0111 7369676E 		.string	"signed char"
 1269      65642063 
 1269      68617200 
 1270              	.LASF12:
 1271 011d 6C6F6E67 		.string	"long long unsigned int"
 1271      206C6F6E 
 1271      6720756E 
 1271      7369676E 
 1271      65642069 
 1272              	.LASF1:
 1273 0134 756E7369 		.string	"unsigned int"
 1273      676E6564 
 1273      20696E74 
 1273      00
 1274              	.LASF43:
 1275 0141 5F494F5F 		.string	"_IO_marker"
 1275      6D61726B 
 1275      657200
 1276              	.LASF32:
 1277 014c 5F73686F 		.string	"_shortbuf"
 1277      72746275 
 1277      6600
 1278              	.LASF17:
 1279 0156 5F494F5F 		.string	"_IO_write_base"
 1279      77726974 
 1279      655F6261 
 1279      736500
 1280              	.LASF41:
 1281 0165 5F756E75 		.string	"_unused2"
 1281      73656432 
 1281      00
 1282              	.LASF14:
 1283 016e 5F494F5F 		.string	"_IO_read_ptr"
 1283      72656164 
 1283      5F707472 
 1283      00
 1284              	.LASF21:
 1285 017b 5F494F5F 		.string	"_IO_buf_end"
 1285      6275665F 
 1285      656E6400 
 1286              	.LASF11:
 1287 0187 63686172 		.string	"char"
 1287      00
 1288              	.LASF61:
 1289 018c 6D61696E 		.string	"main"
GAS LISTING /tmp/ccYl4XIm.s 			page 29


 1289      00
 1290              	.LASF44:
 1291 0191 5F6E6578 		.string	"_next"
 1291      7400
 1292              	.LASF35:
 1293 0197 5F5F7061 		.string	"__pad1"
 1293      643100
 1294              	.LASF36:
 1295 019e 5F5F7061 		.string	"__pad2"
 1295      643200
 1296              	.LASF37:
 1297 01a5 5F5F7061 		.string	"__pad3"
 1297      643300
 1298              	.LASF38:
 1299 01ac 5F5F7061 		.string	"__pad4"
 1299      643400
 1300              	.LASF39:
 1301 01b3 5F5F7061 		.string	"__pad5"
 1301      643500
 1302              	.LASF57:
 1303 01ba 474E5520 		.string	"GNU C 4.4.7 20120313 (Red Hat 4.4.7-4)"
 1303      4320342E 
 1303      342E3720 
 1303      32303132 
 1303      30333133 
 1304              	.LASF5:
 1305 01e1 73686F72 		.string	"short unsigned int"
 1305      7420756E 
 1305      7369676E 
 1305      65642069 
 1305      6E7400
 1306              	.LASF0:
 1307 01f4 6C6F6E67 		.string	"long unsigned int"
 1307      20756E73 
 1307      69676E65 
 1307      6420696E 
 1307      7400
 1308              	.LASF49:
 1309 0206 6E706F69 		.string	"npoints"
 1309      6E747300 
 1310              	.LASF19:
 1311 020e 5F494F5F 		.string	"_IO_write_end"
 1311      77726974 
 1311      655F656E 
 1311      6400
 1312              	.LASF10:
 1313 021c 5F5F6F66 		.string	"__off64_t"
 1313      6636345F 
 1313      7400
 1314              	.LASF50:
 1315 0226 696D6167 		.string	"image"
 1315      6500
 1316              	.LASF27:
 1317 022c 5F66696C 		.string	"_fileno"
 1317      656E6F00 
 1318              	.LASF26:
 1319 0234 5F636861 		.string	"_chain"
GAS LISTING /tmp/ccYl4XIm.s 			page 30


 1319      696E00
 1320              	.LASF9:
 1321 023b 5F5F6F66 		.string	"__off_t"
 1321      665F7400 
 1322              	.LASF23:
 1323 0243 5F494F5F 		.string	"_IO_backup_base"
 1323      6261636B 
 1323      75705F62 
 1323      61736500 
 1324              	.LASF54:
 1325 0253 73746469 		.string	"stdin"
 1325      6E00
 1326              	.LASF28:
 1327 0259 5F666C61 		.string	"_flags2"
 1327      67733200 
 1328              	.LASF40:
 1329 0261 5F6D6F64 		.string	"_mode"
 1329      6500
 1330              	.LASF16:
 1331 0267 5F494F5F 		.string	"_IO_read_base"
 1331      72656164 
 1331      5F626173 
 1331      6500
 1332              	.LASF31:
 1333 0275 5F767461 		.string	"_vtable_offset"
 1333      626C655F 
 1333      6F666673 
 1333      657400
 1334              	.LASF52:
 1335 0284 6572726F 		.string	"error"
 1335      7200
 1336              	.LASF22:
 1337 028a 5F494F5F 		.string	"_IO_save_base"
 1337      73617665 
 1337      5F626173 
 1337      6500
 1338              	.LASF45:
 1339 0298 5F736275 		.string	"_sbuf"
 1339      6600
 1340              	.LASF55:
 1341 029e 7374646F 		.string	"stdout"
 1341      757400
 1342              	.LASF60:
 1343 02a5 5F494F5F 		.string	"_IO_lock_t"
 1343      6C6F636B 
 1343      5F7400
 1344              		.ident	"GCC: (GNU) 4.4.7 20120313 (Red Hat 4.4.7-4)"
 1345              		.section	.note.GNU-stack,"",@progbits
