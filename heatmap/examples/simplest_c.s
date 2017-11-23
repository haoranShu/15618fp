GAS LISTING /tmp/ccnhEzDm.s 			page 1


   1              		.file	"simplest.c"
   2              		.section	.debug_abbrev,"",@progbits
   3              	.Ldebug_abbrev0:
   4              		.section	.debug_info,"",@progbits
   5              	.Ldebug_info0:
   6              		.section	.debug_line,"",@progbits
   7              	.Ldebug_line0:
   8 0000 1D010000 		.text
   8      0200B400 
   8      00000101 
   8      FB0E0D00 
   8      01010101 
   9              	.Ltext0:
  10              		.section	.rodata.str1.1,"aMS",@progbits,1
  11              	.LC4:
  12 0000 546F7461 		.string	"Total time: %f seconds\n"
  12      6C207469 
  12      6D653A20 
  12      25662073 
  12      65636F6E 
  13              	.LC5:
  14 0018 68656174 		.string	"heatmap.png"
  14      6D61702E 
  14      706E6700 
  15              		.section	.rodata.str1.8,"aMS",@progbits,1
  16              		.align 8
  17              	.LC6:
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
GAS LISTING /tmp/ccnhEzDm.s 			page 2


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
  34:examples/simplest.c ****     static const size_t w = 4096, h = 4096, npoints = 10000000;
  35:examples/simplest.c ****     unsigned char image[4096 * 4096 * 4];
  36:examples/simplest.c ****     unsigned i;
  37:examples/simplest.c **** 
  38:examples/simplest.c ****     srand(time(NULL));
  31              		.loc 1 39 0
  32 0002 31FF     		xorl	%edi, %edi
  34:examples/simplest.c ****     static const size_t w = 4096, h = 4096, npoints = 10000000;
  33              		.loc 1 34 0
  34 0004 4156     		pushq	%r14
  35              		.cfi_def_cfa_offset 24
  36              		.cfi_offset 14, -24
  39:examples/simplest.c **** 
  40:examples/simplest.c ****     float *xs = (float *) malloc(sizeof(float) * npoints);
  41:examples/simplest.c ****     float *ys = (float *) malloc(sizeof(float) * npoints);
  42:examples/simplest.c ****     float *ws = (float *) malloc(sizeof(float) * npoints);
  37              		.loc 1 43 0
  38 0006 4531F6   		xorl	%r14d, %r14d
  34:examples/simplest.c ****     static const size_t w = 4096, h = 4096, npoints = 10000000;
  39              		.loc 1 34 0
  40 0009 4155     		pushq	%r13
  41              		.cfi_def_cfa_offset 32
  42              		.cfi_offset 13, -32
  43 000b 4154     		pushq	%r12
  44              		.cfi_def_cfa_offset 40
  45              		.cfi_offset 12, -40
  46              	.LBB2:
  43:examples/simplest.c ****     /* Add a bunch of random points to the heatmap now. */
  44:examples/simplest.c ****     for(i = 0 ; i < npoints ; ++i) {
  45:examples/simplest.c ****         /* Fake a normal distribution. */
  46:examples/simplest.c ****         unsigned x = rand() % w/3 + rand() % w/3 + rand() % w/3;
  47:examples/simplest.c ****         unsigned y = rand() % h/3 + rand() % h/3 + rand() % h/3;
  48:examples/simplest.c ****         xs[i] = (float)x;
  47              		.loc 1 49 0
  48 000d 49BCABAA 		movabsq	$-6148914691236517205, %r12
  48      AAAAAAAA 
GAS LISTING /tmp/ccnhEzDm.s 			page 3


  48      AAAA
  49              	.LBE2:
  34:examples/simplest.c **** {
  50              		.loc 1 34 0
  51 0017 55       		pushq	%rbp
  52              		.cfi_def_cfa_offset 48
  53              		.cfi_offset 6, -48
  54 0018 53       		pushq	%rbx
  55              		.cfi_def_cfa_offset 56
  56              		.cfi_offset 3, -56
  57 0019 4881EC48 		subq	$67108936, %rsp
  57      000004
  58              		.cfi_def_cfa_offset 67108992
  39:examples/simplest.c **** 
  59              		.loc 1 39 0
  60 0020 E8000000 		call	time@PLT
  60      00
  61 0025 89C7     		movl	%eax, %edi
  62 0027 E8000000 		call	srand@PLT
  62      00
  41:examples/simplest.c ****     float *xs = (float *) malloc(sizeof(float) * npoints);
  63              		.loc 1 41 0
  64 002c BF005A62 		movl	$40000000, %edi
  64      02
  65 0031 E8000000 		call	malloc@PLT
  65      00
  42:examples/simplest.c ****     float *ys = (float *) malloc(sizeof(float) * npoints);
  66              		.loc 1 42 0
  67 0036 BF005A62 		movl	$40000000, %edi
  67      02
  41:examples/simplest.c ****     float *xs = (float *) malloc(sizeof(float) * npoints);
  68              		.loc 1 41 0
  69 003b 4889C3   		movq	%rax, %rbx
  70              	.LVL0:
  42:examples/simplest.c ****     float *ys = (float *) malloc(sizeof(float) * npoints);
  71              		.loc 1 42 0
  72 003e E8000000 		call	malloc@PLT
  72      00
  73              	.LVL1:
  43:examples/simplest.c ****     float *ws = (float *) malloc(sizeof(float) * npoints);
  74              		.loc 1 43 0
  75 0043 BF005A62 		movl	$40000000, %edi
  75      02
  42:examples/simplest.c ****     float *ys = (float *) malloc(sizeof(float) * npoints);
  76              		.loc 1 42 0
  77 0048 4889C5   		movq	%rax, %rbp
  78              	.LVL2:
  43:examples/simplest.c ****     float *ws = (float *) malloc(sizeof(float) * npoints);
  79              		.loc 1 43 0
  80 004b E8000000 		call	malloc@PLT
  80      00
  81              	.LVL3:
  82 0050 4989C5   		movq	%rax, %r13
  83              	.LVL4:
  84              		.p2align 4,,10
  85 0053 0F1F4400 		.p2align 3
  85      00
GAS LISTING /tmp/ccnhEzDm.s 			page 4


  86              	.L6:
  87              	.LBB3:
  47:examples/simplest.c ****         unsigned x = rand() % w/3 + rand() % w/3 + rand() % w/3;
  88              		.loc 1 47 0
  89 0058 E8000000 		call	rand@PLT
  89      00
  90 005d 89442430 		movl	%eax, 48(%rsp)
  91 0061 E8000000 		call	rand@PLT
  91      00
  92 0066 89442420 		movl	%eax, 32(%rsp)
  93 006a E8000000 		call	rand@PLT
  93      00
  94 006f 89442410 		movl	%eax, 16(%rsp)
  48:examples/simplest.c ****         unsigned y = rand() % h/3 + rand() % h/3 + rand() % h/3;
  95              		.loc 1 48 0
  96 0073 E8000000 		call	rand@PLT
  96      00
  97 0078 4189C7   		movl	%eax, %r15d
  98 007b E8000000 		call	rand@PLT
  98      00
  99 0080 89442408 		movl	%eax, 8(%rsp)
  49:examples/simplest.c ****         ys[i] = (float)y;
 100              		.loc 1 50 0
 101 0084 4181E7FF 		andl	$4095, %r15d
 101      0F0000
  48:examples/simplest.c ****         unsigned y = rand() % h/3 + rand() % h/3 + rand() % h/3;
 102              		.loc 1 48 0
 103 008b E8000000 		call	rand@PLT
 103      00
  49:examples/simplest.c ****         ys[i] = (float)y;
 104              		.loc 1 49 0
 105 0090 8B742420 		movl	32(%rsp), %esi
  48:examples/simplest.c ****         unsigned y = rand() % h/3 + rand() % h/3 + rand() % h/3;
 106              		.loc 1 48 0
 107 0094 89C7     		movl	%eax, %edi
 108              		.loc 1 50 0
 109 0096 8B4C2408 		movl	8(%rsp), %ecx
 110 009a 81E7FF0F 		andl	$4095, %edi
 110      0000
  49:examples/simplest.c ****         ys[i] = (float)y;
 111              		.loc 1 49 0
 112 00a0 81E6FF0F 		andl	$4095, %esi
 112      0000
 113              		.loc 1 50 0
 114 00a6 81E1FF0F 		andl	$4095, %ecx
 114      0000
  49:examples/simplest.c ****         ys[i] = (float)y;
 115              		.loc 1 49 0
 116 00ac 4889F0   		movq	%rsi, %rax
 117 00af 49F7E4   		mulq	%r12
 118 00b2 4889D6   		movq	%rdx, %rsi
 119 00b5 8B542430 		movl	48(%rsp), %edx
 120 00b9 48D1EE   		shrq	%rsi
 121 00bc 81E2FF0F 		andl	$4095, %edx
 121      0000
 122 00c2 4889D0   		movq	%rdx, %rax
 123 00c5 49F7E4   		mulq	%r12
GAS LISTING /tmp/ccnhEzDm.s 			page 5


 124 00c8 48D1EA   		shrq	%rdx
 125 00cb 01D6     		addl	%edx, %esi
 126 00cd 8B542410 		movl	16(%rsp), %edx
 127 00d1 81E2FF0F 		andl	$4095, %edx
 127      0000
 128 00d7 4889D0   		movq	%rdx, %rax
 129 00da 49F7E4   		mulq	%r12
 130              		.loc 1 50 0
 131 00dd 4889C8   		movq	%rcx, %rax
  49:examples/simplest.c ****         ys[i] = (float)y;
 132              		.loc 1 49 0
 133 00e0 48D1EA   		shrq	%rdx
 134 00e3 01D6     		addl	%edx, %esi
 135              		.loc 1 50 0
 136 00e5 49F7E4   		mulq	%r12
 137 00e8 4C89F8   		movq	%r15, %rax
  49:examples/simplest.c ****         ys[i] = (float)y;
 138              		.loc 1 49 0
 139 00eb F3480F2A 		cvtsi2ssq	%rsi, %xmm0
 139      C6
 140              		.loc 1 50 0
 141 00f0 4889D1   		movq	%rdx, %rcx
 142 00f3 49F7E4   		mulq	%r12
 143 00f6 48D1E9   		shrq	%rcx
 144 00f9 4889F8   		movq	%rdi, %rax
 145 00fc 48D1EA   		shrq	%rdx
 146 00ff 01D1     		addl	%edx, %ecx
 147 0101 49F7E4   		mulq	%r12
  49:examples/simplest.c ****         ys[i] = (float)y;
 148              		.loc 1 49 0
 149 0104 F3420F11 		movss	%xmm0, (%rbx,%r14)
 149      0433
  50:examples/simplest.c ****         ws[i] = 1.0;
 150              		.loc 1 51 0
 151 010a 43C74435 		movl	$0x3f800000, 0(%r13,%r14)
 151      00000080 
 151      3F
  50:examples/simplest.c ****         ws[i] = 1.0;
 152              		.loc 1 50 0
 153 0113 48D1EA   		shrq	%rdx
 154 0116 01D1     		addl	%edx, %ecx
 155 0118 F3480F2A 		cvtsi2ssq	%rcx, %xmm0
 155      C1
 156 011d F3420F11 		movss	%xmm0, 0(%rbp,%r14)
 156      443500
 157              		.loc 1 51 0
 158 0124 4983C604 		addq	$4, %r14
 159              	.LBE3:
  45:examples/simplest.c ****     for(i = 0 ; i < npoints ; ++i) {
 160              		.loc 1 45 0
 161 0128 4981FE00 		cmpq	$40000000, %r14
 161      5A6202
 162 012f 0F8523FF 		jne	.L6
 162      FFFF
  51:examples/simplest.c ****     }
  52:examples/simplest.c ****     double begin = omp_get_wtime();
 163              		.loc 1 53 0
GAS LISTING /tmp/ccnhEzDm.s 			page 6


 164 0135 E8000000 		call	omp_get_wtime@PLT
 164      00
  53:examples/simplest.c **** 
  54:examples/simplest.c ****     /* Create the heatmap object with the given dimensions (in pixel). */
  55:examples/simplest.c ****     heatmap_t* hm = heatmap_new(w, h);
 165              		.loc 1 56 0
 166 013a BE001000 		movl	$4096, %esi
 166      00
 167 013f BF001000 		movl	$4096, %edi
 167      00
  53:examples/simplest.c **** 
 168              		.loc 1 53 0
 169 0144 F20F1144 		movsd	%xmm0, 8(%rsp)
 169      2408
 170              	.LVL5:
 171              		.loc 1 56 0
 172 014a E8000000 		call	heatmap_new@PLT
 172      00
 173              	.LVL6:
  56:examples/simplest.c **** 
  57:examples/simplest.c ****     // heatmap_add_points_omp(hm, xs, ys, npoints);
  58:examples/simplest.c **** 
  59:examples/simplest.c ****     cudaKDE_renderer(hm, xs, ys, ws, npoints,
 174              		.loc 1 60 0
 175 014f 0F57D2   		xorps	%xmm2, %xmm2
 176 0152 4889DE   		movq	%rbx, %rsi
 177 0155 F30F101D 		movss	.LC2(%rip), %xmm3
 177      00000000 
  60:examples/simplest.c ****                      0, 8192, 0, 8192, 3);
  61:examples/simplest.c ****     /*for (i = 0; i < npoints; i++)*/
  62:examples/simplest.c ****     /*{*/
  63:examples/simplest.c ****         /*heatmap_add_point(hm, xs[i], ys[i]);*/
  64:examples/simplest.c ****     /*}*/
  65:examples/simplest.c **** 
  66:examples/simplest.c ****     /* This creates an image out of the heatmap.
  67:examples/simplest.c ****      * `image` now contains the image data in 32-bit RGBA.
  68:examples/simplest.c ****      */
  69:examples/simplest.c ****     heatmap_render_default_to(hm, image);
 178              		.loc 1 70 0
 179 015d 488D5C24 		leaq	64(%rsp), %rbx
 179      40
 180              	.LVL7:
  60:examples/simplest.c ****                      0, 8192, 0, 8192, 3);
 181              		.loc 1 60 0
 182 0162 0F28CB   		movaps	%xmm3, %xmm1
 183 0165 41B88096 		movl	$10000000, %r8d
 183      9800
 184 016b 0F28C2   		movaps	%xmm2, %xmm0
 185 016e 4C89E9   		movq	%r13, %rcx
 186 0171 F30F1025 		movss	.LC1(%rip), %xmm4
 186      00000000 
 187 0179 4889EA   		movq	%rbp, %rdx
  56:examples/simplest.c **** 
 188              		.loc 1 56 0
 189 017c 4989C4   		movq	%rax, %r12
 190              	.LVL8:
  60:examples/simplest.c ****                      0, 8192, 0, 8192, 3);
GAS LISTING /tmp/ccnhEzDm.s 			page 7


 191              		.loc 1 60 0
 192 017f 4889C7   		movq	%rax, %rdi
 193 0182 E8000000 		call	cudaKDE_renderer@PLT
 193      00
 194              	.LVL9:
 195              		.loc 1 70 0
 196 0187 4889DE   		movq	%rbx, %rsi
 197 018a 4C89E7   		movq	%r12, %rdi
 198 018d E8000000 		call	heatmap_render_default_to@PLT
 198      00
  70:examples/simplest.c **** 
  71:examples/simplest.c ****     /* Now that we've got a finished heatmap picture,
  72:examples/simplest.c ****      * we don't need the map anymore.
  73:examples/simplest.c ****      */
  74:examples/simplest.c ****     heatmap_free(hm);
 199              		.loc 1 75 0
 200 0192 4C89E7   		movq	%r12, %rdi
 201 0195 E8000000 		call	heatmap_free@PLT
 201      00
  75:examples/simplest.c **** 
  76:examples/simplest.c ****     double end = omp_get_wtime();
 202              		.loc 1 77 0
 203 019a E8000000 		call	omp_get_wtime@PLT
 203      00
 204              	.LVL10:
  77:examples/simplest.c ****     printf("Total time: %f seconds\n", end - begin);
 205              		.loc 1 78 0
 206 019f F20F5C44 		subsd	8(%rsp), %xmm0
 206      2408
 207              	.LVL11:
 208 01a5 488D3D00 		leaq	.LC4(%rip), %rdi
 208      000000
 209 01ac B8010000 		movl	$1, %eax
 209      00
 210 01b1 E8000000 		call	printf@PLT
 210      00
 211              	.LBB4:
  78:examples/simplest.c **** 
  79:examples/simplest.c ****     /* Finally, we use the fantastic lodepng library to save it as an image. */
  80:examples/simplest.c ****     {
  81:examples/simplest.c ****         unsigned error = lodepng_encode32_file("heatmap.png", image, w, h);
 212              		.loc 1 82 0
 213 01b6 488D3D00 		leaq	.LC5(%rip), %rdi
 213      000000
 214 01bd 4889DE   		movq	%rbx, %rsi
 215 01c0 B9001000 		movl	$4096, %ecx
 215      00
 216 01c5 BA001000 		movl	$4096, %edx
 216      00
 217 01ca E8000000 		call	lodepng_encode32_file@PLT
 217      00
  82:examples/simplest.c ****         if(error)
 218              		.loc 1 83 0
 219 01cf 85C0     		testl	%eax, %eax
  82:examples/simplest.c ****         if(error)
 220              		.loc 1 82 0
 221 01d1 89C3     		movl	%eax, %ebx
GAS LISTING /tmp/ccnhEzDm.s 			page 8


 222              	.LVL12:
 223              		.loc 1 83 0
 224 01d3 7424     		je	.L7
  83:examples/simplest.c ****             fprintf(stderr, "Error (%u) creating PNG file: %s\n",
 225              		.loc 1 84 0
 226 01d5 89C7     		movl	%eax, %edi
 227 01d7 E8000000 		call	lodepng_error_text@PLT
 227      00
 228              	.LVL13:
 229 01dc 4889C1   		movq	%rax, %rcx
 230 01df 488B0500 		movq	stderr@GOTPCREL(%rip), %rax
 230      000000
 231 01e6 488D3500 		leaq	.LC6(%rip), %rsi
 231      000000
 232 01ed 89DA     		movl	%ebx, %edx
 233 01ef 488B38   		movq	(%rax), %rdi
 234 01f2 31C0     		xorl	%eax, %eax
 235 01f4 E8000000 		call	fprintf@PLT
 235      00
 236              	.L7:
 237              	.LBE4:
  84:examples/simplest.c ****                     error, lodepng_error_text(error));
  85:examples/simplest.c ****     }
  86:examples/simplest.c **** 
  87:examples/simplest.c ****     return 0;
  88:examples/simplest.c **** }
 238              		.loc 1 89 0
 239 01f9 4881C448 		addq	$67108936, %rsp
 239      000004
 240              		.cfi_def_cfa_offset 56
 241 0200 31C0     		xorl	%eax, %eax
 242 0202 5B       		popq	%rbx
 243              		.cfi_def_cfa_offset 48
 244              	.LVL14:
 245 0203 5D       		popq	%rbp
 246              		.cfi_def_cfa_offset 40
 247              	.LVL15:
 248 0204 415C     		popq	%r12
 249              		.cfi_def_cfa_offset 32
 250              	.LVL16:
 251 0206 415D     		popq	%r13
 252              		.cfi_def_cfa_offset 24
 253              	.LVL17:
 254 0208 415E     		popq	%r14
 255              		.cfi_def_cfa_offset 16
 256 020a 415F     		popq	%r15
 257              		.cfi_def_cfa_offset 8
 258 020c C3       		ret
 259              		.cfi_endproc
 260              	.LFE30:
 261              		.size	main, .-main
 262              		.section	.rodata.cst4,"aM",@progbits,4
 263              		.align 4
 264              	.LC1:
 265 0000 00004040 		.long	1077936128
 266              		.align 4
 267              	.LC2:
GAS LISTING /tmp/ccnhEzDm.s 			page 9


 268 0004 00000046 		.long	1174405120
 269              		.text
 270              	.Letext0:
 271              		.section	.debug_loc,"",@progbits
 272              	.Ldebug_loc0:
 273              	.LLST0:
 274 0000 3E000000 		.quad	.LVL0-.Ltext0
 274      00000000 
 275 0008 42000000 		.quad	.LVL1-1-.Ltext0
 275      00000000 
 276 0010 0100     		.value	0x1
 277 0012 50       		.byte	0x50
 278 0013 42000000 		.quad	.LVL1-1-.Ltext0
 278      00000000 
 279 001b 62010000 		.quad	.LVL7-.Ltext0
 279      00000000 
 280 0023 0100     		.value	0x1
 281 0025 53       		.byte	0x53
 282 0026 62010000 		.quad	.LVL7-.Ltext0
 282      00000000 
 283 002e 86010000 		.quad	.LVL9-1-.Ltext0
 283      00000000 
 284 0036 0100     		.value	0x1
 285 0038 54       		.byte	0x54
 286 0039 00000000 		.quad	0x0
 286      00000000 
 287 0041 00000000 		.quad	0x0
 287      00000000 
 288              	.LLST1:
 289 0049 4B000000 		.quad	.LVL2-.Ltext0
 289      00000000 
 290 0051 4F000000 		.quad	.LVL3-1-.Ltext0
 290      00000000 
 291 0059 0100     		.value	0x1
 292 005b 50       		.byte	0x50
 293 005c 4F000000 		.quad	.LVL3-1-.Ltext0
 293      00000000 
 294 0064 04020000 		.quad	.LVL15-.Ltext0
 294      00000000 
 295 006c 0100     		.value	0x1
 296 006e 56       		.byte	0x56
 297 006f 00000000 		.quad	0x0
 297      00000000 
 298 0077 00000000 		.quad	0x0
 298      00000000 
 299              	.LLST2:
 300 007f 53000000 		.quad	.LVL4-.Ltext0
 300      00000000 
 301 0087 08020000 		.quad	.LVL17-.Ltext0
 301      00000000 
 302 008f 0100     		.value	0x1
 303 0091 5D       		.byte	0x5d
 304 0092 00000000 		.quad	0x0
 304      00000000 
 305 009a 00000000 		.quad	0x0
 305      00000000 
 306              	.LLST3:
GAS LISTING /tmp/ccnhEzDm.s 			page 10


 307 00a2 4A010000 		.quad	.LVL5-.Ltext0
 307      00000000 
 308 00aa 4E010000 		.quad	.LVL6-1-.Ltext0
 308      00000000 
 309 00b2 0100     		.value	0x1
 310 00b4 61       		.byte	0x61
 311 00b5 4E010000 		.quad	.LVL6-1-.Ltext0
 311      00000000 
 312 00bd 0D020000 		.quad	.LFE30-.Ltext0
 312      00000000 
 313 00c5 0500     		.value	0x5
 314 00c7 91       		.byte	0x91
 315 00c8 88FFFF5F 		.sleb128 -67108984
 316 00cc 00000000 		.quad	0x0
 316      00000000 
 317 00d4 00000000 		.quad	0x0
 317      00000000 
 318              	.LLST4:
 319 00dc 7F010000 		.quad	.LVL8-.Ltext0
 319      00000000 
 320 00e4 86010000 		.quad	.LVL9-1-.Ltext0
 320      00000000 
 321 00ec 0100     		.value	0x1
 322 00ee 50       		.byte	0x50
 323 00ef 86010000 		.quad	.LVL9-1-.Ltext0
 323      00000000 
 324 00f7 06020000 		.quad	.LVL16-.Ltext0
 324      00000000 
 325 00ff 0100     		.value	0x1
 326 0101 5C       		.byte	0x5c
 327 0102 00000000 		.quad	0x0
 327      00000000 
 328 010a 00000000 		.quad	0x0
 328      00000000 
 329              	.LLST5:
 330 0112 9F010000 		.quad	.LVL10-.Ltext0
 330      00000000 
 331 011a A5010000 		.quad	.LVL11-.Ltext0
 331      00000000 
 332 0122 0100     		.value	0x1
 333 0124 61       		.byte	0x61
 334 0125 00000000 		.quad	0x0
 334      00000000 
 335 012d 00000000 		.quad	0x0
 335      00000000 
 336              	.LLST6:
 337 0135 D3010000 		.quad	.LVL12-.Ltext0
 337      00000000 
 338 013d DB010000 		.quad	.LVL13-1-.Ltext0
 338      00000000 
 339 0145 0100     		.value	0x1
 340 0147 50       		.byte	0x50
 341 0148 DB010000 		.quad	.LVL13-1-.Ltext0
 341      00000000 
 342 0150 03020000 		.quad	.LVL14-.Ltext0
 342      00000000 
 343 0158 0100     		.value	0x1
GAS LISTING /tmp/ccnhEzDm.s 			page 11


 344 015a 53       		.byte	0x53
 345 015b 00000000 		.quad	0x0
 345      00000000 
 346 0163 00000000 		.quad	0x0
 346      00000000 
 347              		.file 2 "/usr/lib/gcc/x86_64-redhat-linux/4.4.7/include/stddef.h"
 348              		.file 3 "/usr/include/bits/types.h"
 349              		.file 4 "/usr/include/libio.h"
 350              		.file 5 "./heatmap.h"
 351              		.file 6 "/usr/include/stdio.h"
 352              		.section	.debug_info
 353 0000 5B040000 		.long	0x45b
 354 0004 0300     		.value	0x3
 355 0006 00000000 		.long	.Ldebug_abbrev0
 356 000a 08       		.byte	0x8
 357 000b 01       		.uleb128 0x1
 358 000c 00000000 		.long	.LASF57
 359 0010 01       		.byte	0x1
 360 0011 00000000 		.long	.LASF58
 361 0015 00000000 		.long	.LASF59
 362 0019 00000000 		.quad	.Ltext0
 362      00000000 
 363 0021 00000000 		.quad	.Letext0
 363      00000000 
 364 0029 00000000 		.long	.Ldebug_line0
 365 002d 02       		.uleb128 0x2
 366 002e 00000000 		.long	.LASF8
 367 0032 02       		.byte	0x2
 368 0033 D3       		.byte	0xd3
 369 0034 38000000 		.long	0x38
 370 0038 03       		.uleb128 0x3
 371 0039 08       		.byte	0x8
 372 003a 07       		.byte	0x7
 373 003b 00000000 		.long	.LASF0
 374 003f 04       		.uleb128 0x4
 375 0040 04       		.byte	0x4
 376 0041 05       		.byte	0x5
 377 0042 696E7400 		.string	"int"
 378 0046 03       		.uleb128 0x3
 379 0047 04       		.byte	0x4
 380 0048 07       		.byte	0x7
 381 0049 00000000 		.long	.LASF1
 382 004d 03       		.uleb128 0x3
 383 004e 08       		.byte	0x8
 384 004f 05       		.byte	0x5
 385 0050 00000000 		.long	.LASF2
 386 0054 03       		.uleb128 0x3
 387 0055 08       		.byte	0x8
 388 0056 05       		.byte	0x5
 389 0057 00000000 		.long	.LASF3
 390 005b 03       		.uleb128 0x3
 391 005c 01       		.byte	0x1
 392 005d 08       		.byte	0x8
 393 005e 00000000 		.long	.LASF4
 394 0062 03       		.uleb128 0x3
 395 0063 02       		.byte	0x2
 396 0064 07       		.byte	0x7
GAS LISTING /tmp/ccnhEzDm.s 			page 12


 397 0065 00000000 		.long	.LASF5
 398 0069 03       		.uleb128 0x3
 399 006a 01       		.byte	0x1
 400 006b 06       		.byte	0x6
 401 006c 00000000 		.long	.LASF6
 402 0070 03       		.uleb128 0x3
 403 0071 02       		.byte	0x2
 404 0072 05       		.byte	0x5
 405 0073 00000000 		.long	.LASF7
 406 0077 02       		.uleb128 0x2
 407 0078 00000000 		.long	.LASF9
 408 007c 03       		.byte	0x3
 409 007d 8D       		.byte	0x8d
 410 007e 4D000000 		.long	0x4d
 411 0082 02       		.uleb128 0x2
 412 0083 00000000 		.long	.LASF10
 413 0087 03       		.byte	0x3
 414 0088 8E       		.byte	0x8e
 415 0089 4D000000 		.long	0x4d
 416 008d 05       		.uleb128 0x5
 417 008e 08       		.byte	0x8
 418 008f 06       		.uleb128 0x6
 419 0090 08       		.byte	0x8
 420 0091 95000000 		.long	0x95
 421 0095 03       		.uleb128 0x3
 422 0096 01       		.byte	0x1
 423 0097 06       		.byte	0x6
 424 0098 00000000 		.long	.LASF11
 425 009c 03       		.uleb128 0x3
 426 009d 08       		.byte	0x8
 427 009e 07       		.byte	0x7
 428 009f 00000000 		.long	.LASF12
 429 00a3 07       		.uleb128 0x7
 430 00a4 00000000 		.long	.LASF42
 431 00a8 D8       		.byte	0xd8
 432 00a9 04       		.byte	0x4
 433 00aa 0F01     		.value	0x10f
 434 00ac 3F020000 		.long	0x23f
 435 00b0 08       		.uleb128 0x8
 436 00b1 00000000 		.long	.LASF13
 437 00b5 04       		.byte	0x4
 438 00b6 1001     		.value	0x110
 439 00b8 3F000000 		.long	0x3f
 440 00bc 00       		.sleb128 0
 441 00bd 08       		.uleb128 0x8
 442 00be 00000000 		.long	.LASF14
 443 00c2 04       		.byte	0x4
 444 00c3 1501     		.value	0x115
 445 00c5 8F000000 		.long	0x8f
 446 00c9 08       		.sleb128 8
 447 00ca 08       		.uleb128 0x8
 448 00cb 00000000 		.long	.LASF15
 449 00cf 04       		.byte	0x4
 450 00d0 1601     		.value	0x116
 451 00d2 8F000000 		.long	0x8f
 452 00d6 10       		.sleb128 16
 453 00d7 08       		.uleb128 0x8
GAS LISTING /tmp/ccnhEzDm.s 			page 13


 454 00d8 00000000 		.long	.LASF16
 455 00dc 04       		.byte	0x4
 456 00dd 1701     		.value	0x117
 457 00df 8F000000 		.long	0x8f
 458 00e3 18       		.sleb128 24
 459 00e4 08       		.uleb128 0x8
 460 00e5 00000000 		.long	.LASF17
 461 00e9 04       		.byte	0x4
 462 00ea 1801     		.value	0x118
 463 00ec 8F000000 		.long	0x8f
 464 00f0 20       		.sleb128 32
 465 00f1 08       		.uleb128 0x8
 466 00f2 00000000 		.long	.LASF18
 467 00f6 04       		.byte	0x4
 468 00f7 1901     		.value	0x119
 469 00f9 8F000000 		.long	0x8f
 470 00fd 28       		.sleb128 40
 471 00fe 08       		.uleb128 0x8
 472 00ff 00000000 		.long	.LASF19
 473 0103 04       		.byte	0x4
 474 0104 1A01     		.value	0x11a
 475 0106 8F000000 		.long	0x8f
 476 010a 30       		.sleb128 48
 477 010b 08       		.uleb128 0x8
 478 010c 00000000 		.long	.LASF20
 479 0110 04       		.byte	0x4
 480 0111 1B01     		.value	0x11b
 481 0113 8F000000 		.long	0x8f
 482 0117 38       		.sleb128 56
 483 0118 08       		.uleb128 0x8
 484 0119 00000000 		.long	.LASF21
 485 011d 04       		.byte	0x4
 486 011e 1C01     		.value	0x11c
 487 0120 8F000000 		.long	0x8f
 488 0124 C000     		.sleb128 64
 489 0126 08       		.uleb128 0x8
 490 0127 00000000 		.long	.LASF22
 491 012b 04       		.byte	0x4
 492 012c 1E01     		.value	0x11e
 493 012e 8F000000 		.long	0x8f
 494 0132 C800     		.sleb128 72
 495 0134 08       		.uleb128 0x8
 496 0135 00000000 		.long	.LASF23
 497 0139 04       		.byte	0x4
 498 013a 1F01     		.value	0x11f
 499 013c 8F000000 		.long	0x8f
 500 0140 D000     		.sleb128 80
 501 0142 08       		.uleb128 0x8
 502 0143 00000000 		.long	.LASF24
 503 0147 04       		.byte	0x4
 504 0148 2001     		.value	0x120
 505 014a 8F000000 		.long	0x8f
 506 014e D800     		.sleb128 88
 507 0150 08       		.uleb128 0x8
 508 0151 00000000 		.long	.LASF25
 509 0155 04       		.byte	0x4
 510 0156 2201     		.value	0x122
GAS LISTING /tmp/ccnhEzDm.s 			page 14


 511 0158 77020000 		.long	0x277
 512 015c E000     		.sleb128 96
 513 015e 08       		.uleb128 0x8
 514 015f 00000000 		.long	.LASF26
 515 0163 04       		.byte	0x4
 516 0164 2401     		.value	0x124
 517 0166 7D020000 		.long	0x27d
 518 016a E800     		.sleb128 104
 519 016c 08       		.uleb128 0x8
 520 016d 00000000 		.long	.LASF27
 521 0171 04       		.byte	0x4
 522 0172 2601     		.value	0x126
 523 0174 3F000000 		.long	0x3f
 524 0178 F000     		.sleb128 112
 525 017a 08       		.uleb128 0x8
 526 017b 00000000 		.long	.LASF28
 527 017f 04       		.byte	0x4
 528 0180 2A01     		.value	0x12a
 529 0182 3F000000 		.long	0x3f
 530 0186 F400     		.sleb128 116
 531 0188 08       		.uleb128 0x8
 532 0189 00000000 		.long	.LASF29
 533 018d 04       		.byte	0x4
 534 018e 2C01     		.value	0x12c
 535 0190 77000000 		.long	0x77
 536 0194 F800     		.sleb128 120
 537 0196 08       		.uleb128 0x8
 538 0197 00000000 		.long	.LASF30
 539 019b 04       		.byte	0x4
 540 019c 3001     		.value	0x130
 541 019e 62000000 		.long	0x62
 542 01a2 8001     		.sleb128 128
 543 01a4 08       		.uleb128 0x8
 544 01a5 00000000 		.long	.LASF31
 545 01a9 04       		.byte	0x4
 546 01aa 3101     		.value	0x131
 547 01ac 69000000 		.long	0x69
 548 01b0 8201     		.sleb128 130
 549 01b2 08       		.uleb128 0x8
 550 01b3 00000000 		.long	.LASF32
 551 01b7 04       		.byte	0x4
 552 01b8 3201     		.value	0x132
 553 01ba 83020000 		.long	0x283
 554 01be 8301     		.sleb128 131
 555 01c0 08       		.uleb128 0x8
 556 01c1 00000000 		.long	.LASF33
 557 01c5 04       		.byte	0x4
 558 01c6 3601     		.value	0x136
 559 01c8 93020000 		.long	0x293
 560 01cc 8801     		.sleb128 136
 561 01ce 08       		.uleb128 0x8
 562 01cf 00000000 		.long	.LASF34
 563 01d3 04       		.byte	0x4
 564 01d4 3F01     		.value	0x13f
 565 01d6 82000000 		.long	0x82
 566 01da 9001     		.sleb128 144
 567 01dc 08       		.uleb128 0x8
GAS LISTING /tmp/ccnhEzDm.s 			page 15


 568 01dd 00000000 		.long	.LASF35
 569 01e1 04       		.byte	0x4
 570 01e2 4801     		.value	0x148
 571 01e4 8D000000 		.long	0x8d
 572 01e8 9801     		.sleb128 152
 573 01ea 08       		.uleb128 0x8
 574 01eb 00000000 		.long	.LASF36
 575 01ef 04       		.byte	0x4
 576 01f0 4901     		.value	0x149
 577 01f2 8D000000 		.long	0x8d
 578 01f6 A001     		.sleb128 160
 579 01f8 08       		.uleb128 0x8
 580 01f9 00000000 		.long	.LASF37
 581 01fd 04       		.byte	0x4
 582 01fe 4A01     		.value	0x14a
 583 0200 8D000000 		.long	0x8d
 584 0204 A801     		.sleb128 168
 585 0206 08       		.uleb128 0x8
 586 0207 00000000 		.long	.LASF38
 587 020b 04       		.byte	0x4
 588 020c 4B01     		.value	0x14b
 589 020e 8D000000 		.long	0x8d
 590 0212 B001     		.sleb128 176
 591 0214 08       		.uleb128 0x8
 592 0215 00000000 		.long	.LASF39
 593 0219 04       		.byte	0x4
 594 021a 4C01     		.value	0x14c
 595 021c 2D000000 		.long	0x2d
 596 0220 B801     		.sleb128 184
 597 0222 08       		.uleb128 0x8
 598 0223 00000000 		.long	.LASF40
 599 0227 04       		.byte	0x4
 600 0228 4E01     		.value	0x14e
 601 022a 3F000000 		.long	0x3f
 602 022e C001     		.sleb128 192
 603 0230 08       		.uleb128 0x8
 604 0231 00000000 		.long	.LASF41
 605 0235 04       		.byte	0x4
 606 0236 5001     		.value	0x150
 607 0238 99020000 		.long	0x299
 608 023c C401     		.sleb128 196
 609 023e 00       		.byte	0x0
 610 023f 09       		.uleb128 0x9
 611 0240 00000000 		.long	.LASF60
 612 0244 04       		.byte	0x4
 613 0245 B4       		.byte	0xb4
 614 0246 0A       		.uleb128 0xa
 615 0247 00000000 		.long	.LASF43
 616 024b 18       		.byte	0x18
 617 024c 04       		.byte	0x4
 618 024d BA       		.byte	0xba
 619 024e 77020000 		.long	0x277
 620 0252 0B       		.uleb128 0xb
 621 0253 00000000 		.long	.LASF44
 622 0257 04       		.byte	0x4
 623 0258 BB       		.byte	0xbb
 624 0259 77020000 		.long	0x277
GAS LISTING /tmp/ccnhEzDm.s 			page 16


 625 025d 00       		.sleb128 0
 626 025e 0B       		.uleb128 0xb
 627 025f 00000000 		.long	.LASF45
 628 0263 04       		.byte	0x4
 629 0264 BC       		.byte	0xbc
 630 0265 7D020000 		.long	0x27d
 631 0269 08       		.sleb128 8
 632 026a 0B       		.uleb128 0xb
 633 026b 00000000 		.long	.LASF46
 634 026f 04       		.byte	0x4
 635 0270 C0       		.byte	0xc0
 636 0271 3F000000 		.long	0x3f
 637 0275 10       		.sleb128 16
 638 0276 00       		.byte	0x0
 639 0277 06       		.uleb128 0x6
 640 0278 08       		.byte	0x8
 641 0279 46020000 		.long	0x246
 642 027d 06       		.uleb128 0x6
 643 027e 08       		.byte	0x8
 644 027f A3000000 		.long	0xa3
 645 0283 0C       		.uleb128 0xc
 646 0284 95000000 		.long	0x95
 647 0288 93020000 		.long	0x293
 648 028c 0D       		.uleb128 0xd
 649 028d 38000000 		.long	0x38
 650 0291 00       		.byte	0x0
 651 0292 00       		.byte	0x0
 652 0293 06       		.uleb128 0x6
 653 0294 08       		.byte	0x8
 654 0295 3F020000 		.long	0x23f
 655 0299 0C       		.uleb128 0xc
 656 029a 95000000 		.long	0x95
 657 029e A9020000 		.long	0x2a9
 658 02a2 0D       		.uleb128 0xd
 659 02a3 38000000 		.long	0x38
 660 02a7 13       		.byte	0x13
 661 02a8 00       		.byte	0x0
 662 02a9 0E       		.uleb128 0xe
 663 02aa 18       		.byte	0x18
 664 02ab 05       		.byte	0x5
 665 02ac 27       		.byte	0x27
 666 02ad DE020000 		.long	0x2de
 667 02b1 0F       		.uleb128 0xf
 668 02b2 62756600 		.string	"buf"
 669 02b6 05       		.byte	0x5
 670 02b7 28       		.byte	0x28
 671 02b8 DE020000 		.long	0x2de
 672 02bc 00       		.sleb128 0
 673 02bd 0F       		.uleb128 0xf
 674 02be 6D617800 		.string	"max"
 675 02c2 05       		.byte	0x5
 676 02c3 29       		.byte	0x29
 677 02c4 E4020000 		.long	0x2e4
 678 02c8 08       		.sleb128 8
 679 02c9 0F       		.uleb128 0xf
 680 02ca 7700     		.string	"w"
 681 02cc 05       		.byte	0x5
GAS LISTING /tmp/ccnhEzDm.s 			page 17


 682 02cd 2A       		.byte	0x2a
 683 02ce 46000000 		.long	0x46
 684 02d2 0C       		.sleb128 12
 685 02d3 0F       		.uleb128 0xf
 686 02d4 6800     		.string	"h"
 687 02d6 05       		.byte	0x5
 688 02d7 2A       		.byte	0x2a
 689 02d8 46000000 		.long	0x46
 690 02dc 10       		.sleb128 16
 691 02dd 00       		.byte	0x0
 692 02de 06       		.uleb128 0x6
 693 02df 08       		.byte	0x8
 694 02e0 E4020000 		.long	0x2e4
 695 02e4 03       		.uleb128 0x3
 696 02e5 04       		.byte	0x4
 697 02e6 04       		.byte	0x4
 698 02e7 00000000 		.long	.LASF47
 699 02eb 02       		.uleb128 0x2
 700 02ec 00000000 		.long	.LASF48
 701 02f0 05       		.byte	0x5
 702 02f1 2B       		.byte	0x2b
 703 02f2 A9020000 		.long	0x2a9
 704 02f6 10       		.uleb128 0x10
 705 02f7 01       		.byte	0x1
 706 02f8 00000000 		.long	.LASF61
 707 02fc 01       		.byte	0x1
 708 02fd 21       		.byte	0x21
 709 02fe 3F000000 		.long	0x3f
 710 0302 00000000 		.quad	.LFB30
 710      00000000 
 711 030a 00000000 		.quad	.LFE30
 711      00000000 
 712 0312 01       		.byte	0x1
 713 0313 9C       		.byte	0x9c
 714 0314 EB030000 		.long	0x3eb
 715 0318 11       		.uleb128 0x11
 716 0319 7700     		.string	"w"
 717 031b 01       		.byte	0x1
 718 031c 23       		.byte	0x23
 719 031d EB030000 		.long	0x3eb
 720 0321 0010     		.value	0x1000
 721 0323 11       		.uleb128 0x11
 722 0324 6800     		.string	"h"
 723 0326 01       		.byte	0x1
 724 0327 23       		.byte	0x23
 725 0328 EB030000 		.long	0x3eb
 726 032c 0010     		.value	0x1000
 727 032e 12       		.uleb128 0x12
 728 032f 00000000 		.long	.LASF49
 729 0333 01       		.byte	0x1
 730 0334 23       		.byte	0x23
 731 0335 EB030000 		.long	0x3eb
 732 0339 80969800 		.long	0x989680
 733 033d 13       		.uleb128 0x13
 734 033e 00000000 		.long	.LASF50
 735 0342 01       		.byte	0x1
 736 0343 24       		.byte	0x24
GAS LISTING /tmp/ccnhEzDm.s 			page 18


 737 0344 F0030000 		.long	0x3f0
 738 0348 05       		.byte	0x5
 739 0349 91       		.byte	0x91
 740 034a C0FFFF5F 		.sleb128 -67108928
 741 034e 14       		.uleb128 0x14
 742 034f 6900     		.string	"i"
 743 0351 01       		.byte	0x1
 744 0352 25       		.byte	0x25
 745 0353 46000000 		.long	0x46
 746 0357 15       		.uleb128 0x15
 747 0358 787300   		.string	"xs"
 748 035b 01       		.byte	0x1
 749 035c 29       		.byte	0x29
 750 035d DE020000 		.long	0x2de
 751 0361 00000000 		.long	.LLST0
 752 0365 15       		.uleb128 0x15
 753 0366 797300   		.string	"ys"
 754 0369 01       		.byte	0x1
 755 036a 2A       		.byte	0x2a
 756 036b DE020000 		.long	0x2de
 757 036f 00000000 		.long	.LLST1
 758 0373 15       		.uleb128 0x15
 759 0374 777300   		.string	"ws"
 760 0377 01       		.byte	0x1
 761 0378 2B       		.byte	0x2b
 762 0379 DE020000 		.long	0x2de
 763 037d 00000000 		.long	.LLST2
 764 0381 16       		.uleb128 0x16
 765 0382 00000000 		.long	.LASF51
 766 0386 01       		.byte	0x1
 767 0387 35       		.byte	0x35
 768 0388 03040000 		.long	0x403
 769 038c 00000000 		.long	.LLST3
 770 0390 15       		.uleb128 0x15
 771 0391 686D00   		.string	"hm"
 772 0394 01       		.byte	0x1
 773 0395 38       		.byte	0x38
 774 0396 0A040000 		.long	0x40a
 775 039a 00000000 		.long	.LLST4
 776 039e 15       		.uleb128 0x15
 777 039f 656E6400 		.string	"end"
 778 03a3 01       		.byte	0x1
 779 03a4 4D       		.byte	0x4d
 780 03a5 03040000 		.long	0x403
 781 03a9 00000000 		.long	.LLST5
 782 03ad 17       		.uleb128 0x17
 783 03ae 00000000 		.long	.Ldebug_ranges0+0x0
 784 03b2 C9030000 		.long	0x3c9
 785 03b6 14       		.uleb128 0x14
 786 03b7 7800     		.string	"x"
 787 03b9 01       		.byte	0x1
 788 03ba 2F       		.byte	0x2f
 789 03bb 46000000 		.long	0x46
 790 03bf 14       		.uleb128 0x14
 791 03c0 7900     		.string	"y"
 792 03c2 01       		.byte	0x1
 793 03c3 30       		.byte	0x30
GAS LISTING /tmp/ccnhEzDm.s 			page 19


 794 03c4 46000000 		.long	0x46
 795 03c8 00       		.byte	0x0
 796 03c9 18       		.uleb128 0x18
 797 03ca 00000000 		.quad	.LBB4
 797      00000000 
 798 03d2 00000000 		.quad	.LBE4
 798      00000000 
 799 03da 16       		.uleb128 0x16
 800 03db 00000000 		.long	.LASF52
 801 03df 01       		.byte	0x1
 802 03e0 52       		.byte	0x52
 803 03e1 46000000 		.long	0x46
 804 03e5 00000000 		.long	.LLST6
 805 03e9 00       		.byte	0x0
 806 03ea 00       		.byte	0x0
 807 03eb 19       		.uleb128 0x19
 808 03ec 2D000000 		.long	0x2d
 809 03f0 0C       		.uleb128 0xc
 810 03f1 5B000000 		.long	0x5b
 811 03f5 03040000 		.long	0x403
 812 03f9 1A       		.uleb128 0x1a
 813 03fa 38000000 		.long	0x38
 814 03fe FFFFFF03 		.long	0x3ffffff
 815 0402 00       		.byte	0x0
 816 0403 03       		.uleb128 0x3
 817 0404 08       		.byte	0x8
 818 0405 04       		.byte	0x4
 819 0406 00000000 		.long	.LASF53
 820 040a 06       		.uleb128 0x6
 821 040b 08       		.byte	0x8
 822 040c EB020000 		.long	0x2eb
 823 0410 1B       		.uleb128 0x1b
 824 0411 00000000 		.long	.LASF54
 825 0415 06       		.byte	0x6
 826 0416 A5       		.byte	0xa5
 827 0417 7D020000 		.long	0x27d
 828 041b 01       		.byte	0x1
 829 041c 01       		.byte	0x1
 830 041d 1B       		.uleb128 0x1b
 831 041e 00000000 		.long	.LASF55
 832 0422 06       		.byte	0x6
 833 0423 A6       		.byte	0xa6
 834 0424 7D020000 		.long	0x27d
 835 0428 01       		.byte	0x1
 836 0429 01       		.byte	0x1
 837 042a 1B       		.uleb128 0x1b
 838 042b 00000000 		.long	.LASF56
 839 042f 06       		.byte	0x6
 840 0430 A7       		.byte	0xa7
 841 0431 7D020000 		.long	0x27d
 842 0435 01       		.byte	0x1
 843 0436 01       		.byte	0x1
 844 0437 1B       		.uleb128 0x1b
 845 0438 00000000 		.long	.LASF54
 846 043c 06       		.byte	0x6
 847 043d A5       		.byte	0xa5
 848 043e 7D020000 		.long	0x27d
GAS LISTING /tmp/ccnhEzDm.s 			page 20


 849 0442 01       		.byte	0x1
 850 0443 01       		.byte	0x1
 851 0444 1B       		.uleb128 0x1b
 852 0445 00000000 		.long	.LASF55
 853 0449 06       		.byte	0x6
 854 044a A6       		.byte	0xa6
 855 044b 7D020000 		.long	0x27d
 856 044f 01       		.byte	0x1
 857 0450 01       		.byte	0x1
 858 0451 1B       		.uleb128 0x1b
 859 0452 00000000 		.long	.LASF56
 860 0456 06       		.byte	0x6
 861 0457 A7       		.byte	0xa7
 862 0458 7D020000 		.long	0x27d
 863 045c 01       		.byte	0x1
 864 045d 01       		.byte	0x1
 865 045e 00       		.byte	0x0
 866              		.section	.debug_abbrev
 867 0000 01       		.uleb128 0x1
 868 0001 11       		.uleb128 0x11
 869 0002 01       		.byte	0x1
 870 0003 25       		.uleb128 0x25
 871 0004 0E       		.uleb128 0xe
 872 0005 13       		.uleb128 0x13
 873 0006 0B       		.uleb128 0xb
 874 0007 03       		.uleb128 0x3
 875 0008 0E       		.uleb128 0xe
 876 0009 1B       		.uleb128 0x1b
 877 000a 0E       		.uleb128 0xe
 878 000b 11       		.uleb128 0x11
 879 000c 01       		.uleb128 0x1
 880 000d 12       		.uleb128 0x12
 881 000e 01       		.uleb128 0x1
 882 000f 10       		.uleb128 0x10
 883 0010 06       		.uleb128 0x6
 884 0011 00       		.byte	0x0
 885 0012 00       		.byte	0x0
 886 0013 02       		.uleb128 0x2
 887 0014 16       		.uleb128 0x16
 888 0015 00       		.byte	0x0
 889 0016 03       		.uleb128 0x3
 890 0017 0E       		.uleb128 0xe
 891 0018 3A       		.uleb128 0x3a
 892 0019 0B       		.uleb128 0xb
 893 001a 3B       		.uleb128 0x3b
 894 001b 0B       		.uleb128 0xb
 895 001c 49       		.uleb128 0x49
 896 001d 13       		.uleb128 0x13
 897 001e 00       		.byte	0x0
 898 001f 00       		.byte	0x0
 899 0020 03       		.uleb128 0x3
 900 0021 24       		.uleb128 0x24
 901 0022 00       		.byte	0x0
 902 0023 0B       		.uleb128 0xb
 903 0024 0B       		.uleb128 0xb
 904 0025 3E       		.uleb128 0x3e
 905 0026 0B       		.uleb128 0xb
GAS LISTING /tmp/ccnhEzDm.s 			page 21


 906 0027 03       		.uleb128 0x3
 907 0028 0E       		.uleb128 0xe
 908 0029 00       		.byte	0x0
 909 002a 00       		.byte	0x0
 910 002b 04       		.uleb128 0x4
 911 002c 24       		.uleb128 0x24
 912 002d 00       		.byte	0x0
 913 002e 0B       		.uleb128 0xb
 914 002f 0B       		.uleb128 0xb
 915 0030 3E       		.uleb128 0x3e
 916 0031 0B       		.uleb128 0xb
 917 0032 03       		.uleb128 0x3
 918 0033 08       		.uleb128 0x8
 919 0034 00       		.byte	0x0
 920 0035 00       		.byte	0x0
 921 0036 05       		.uleb128 0x5
 922 0037 0F       		.uleb128 0xf
 923 0038 00       		.byte	0x0
 924 0039 0B       		.uleb128 0xb
 925 003a 0B       		.uleb128 0xb
 926 003b 00       		.byte	0x0
 927 003c 00       		.byte	0x0
 928 003d 06       		.uleb128 0x6
 929 003e 0F       		.uleb128 0xf
 930 003f 00       		.byte	0x0
 931 0040 0B       		.uleb128 0xb
 932 0041 0B       		.uleb128 0xb
 933 0042 49       		.uleb128 0x49
 934 0043 13       		.uleb128 0x13
 935 0044 00       		.byte	0x0
 936 0045 00       		.byte	0x0
 937 0046 07       		.uleb128 0x7
 938 0047 13       		.uleb128 0x13
 939 0048 01       		.byte	0x1
 940 0049 03       		.uleb128 0x3
 941 004a 0E       		.uleb128 0xe
 942 004b 0B       		.uleb128 0xb
 943 004c 0B       		.uleb128 0xb
 944 004d 3A       		.uleb128 0x3a
 945 004e 0B       		.uleb128 0xb
 946 004f 3B       		.uleb128 0x3b
 947 0050 05       		.uleb128 0x5
 948 0051 01       		.uleb128 0x1
 949 0052 13       		.uleb128 0x13
 950 0053 00       		.byte	0x0
 951 0054 00       		.byte	0x0
 952 0055 08       		.uleb128 0x8
 953 0056 0D       		.uleb128 0xd
 954 0057 00       		.byte	0x0
 955 0058 03       		.uleb128 0x3
 956 0059 0E       		.uleb128 0xe
 957 005a 3A       		.uleb128 0x3a
 958 005b 0B       		.uleb128 0xb
 959 005c 3B       		.uleb128 0x3b
 960 005d 05       		.uleb128 0x5
 961 005e 49       		.uleb128 0x49
 962 005f 13       		.uleb128 0x13
GAS LISTING /tmp/ccnhEzDm.s 			page 22


 963 0060 38       		.uleb128 0x38
 964 0061 0D       		.uleb128 0xd
 965 0062 00       		.byte	0x0
 966 0063 00       		.byte	0x0
 967 0064 09       		.uleb128 0x9
 968 0065 16       		.uleb128 0x16
 969 0066 00       		.byte	0x0
 970 0067 03       		.uleb128 0x3
 971 0068 0E       		.uleb128 0xe
 972 0069 3A       		.uleb128 0x3a
 973 006a 0B       		.uleb128 0xb
 974 006b 3B       		.uleb128 0x3b
 975 006c 0B       		.uleb128 0xb
 976 006d 00       		.byte	0x0
 977 006e 00       		.byte	0x0
 978 006f 0A       		.uleb128 0xa
 979 0070 13       		.uleb128 0x13
 980 0071 01       		.byte	0x1
 981 0072 03       		.uleb128 0x3
 982 0073 0E       		.uleb128 0xe
 983 0074 0B       		.uleb128 0xb
 984 0075 0B       		.uleb128 0xb
 985 0076 3A       		.uleb128 0x3a
 986 0077 0B       		.uleb128 0xb
 987 0078 3B       		.uleb128 0x3b
 988 0079 0B       		.uleb128 0xb
 989 007a 01       		.uleb128 0x1
 990 007b 13       		.uleb128 0x13
 991 007c 00       		.byte	0x0
 992 007d 00       		.byte	0x0
 993 007e 0B       		.uleb128 0xb
 994 007f 0D       		.uleb128 0xd
 995 0080 00       		.byte	0x0
 996 0081 03       		.uleb128 0x3
 997 0082 0E       		.uleb128 0xe
 998 0083 3A       		.uleb128 0x3a
 999 0084 0B       		.uleb128 0xb
 1000 0085 3B       		.uleb128 0x3b
 1001 0086 0B       		.uleb128 0xb
 1002 0087 49       		.uleb128 0x49
 1003 0088 13       		.uleb128 0x13
 1004 0089 38       		.uleb128 0x38
 1005 008a 0D       		.uleb128 0xd
 1006 008b 00       		.byte	0x0
 1007 008c 00       		.byte	0x0
 1008 008d 0C       		.uleb128 0xc
 1009 008e 01       		.uleb128 0x1
 1010 008f 01       		.byte	0x1
 1011 0090 49       		.uleb128 0x49
 1012 0091 13       		.uleb128 0x13
 1013 0092 01       		.uleb128 0x1
 1014 0093 13       		.uleb128 0x13
 1015 0094 00       		.byte	0x0
 1016 0095 00       		.byte	0x0
 1017 0096 0D       		.uleb128 0xd
 1018 0097 21       		.uleb128 0x21
 1019 0098 00       		.byte	0x0
GAS LISTING /tmp/ccnhEzDm.s 			page 23


 1020 0099 49       		.uleb128 0x49
 1021 009a 13       		.uleb128 0x13
 1022 009b 2F       		.uleb128 0x2f
 1023 009c 0B       		.uleb128 0xb
 1024 009d 00       		.byte	0x0
 1025 009e 00       		.byte	0x0
 1026 009f 0E       		.uleb128 0xe
 1027 00a0 13       		.uleb128 0x13
 1028 00a1 01       		.byte	0x1
 1029 00a2 0B       		.uleb128 0xb
 1030 00a3 0B       		.uleb128 0xb
 1031 00a4 3A       		.uleb128 0x3a
 1032 00a5 0B       		.uleb128 0xb
 1033 00a6 3B       		.uleb128 0x3b
 1034 00a7 0B       		.uleb128 0xb
 1035 00a8 01       		.uleb128 0x1
 1036 00a9 13       		.uleb128 0x13
 1037 00aa 00       		.byte	0x0
 1038 00ab 00       		.byte	0x0
 1039 00ac 0F       		.uleb128 0xf
 1040 00ad 0D       		.uleb128 0xd
 1041 00ae 00       		.byte	0x0
 1042 00af 03       		.uleb128 0x3
 1043 00b0 08       		.uleb128 0x8
 1044 00b1 3A       		.uleb128 0x3a
 1045 00b2 0B       		.uleb128 0xb
 1046 00b3 3B       		.uleb128 0x3b
 1047 00b4 0B       		.uleb128 0xb
 1048 00b5 49       		.uleb128 0x49
 1049 00b6 13       		.uleb128 0x13
 1050 00b7 38       		.uleb128 0x38
 1051 00b8 0D       		.uleb128 0xd
 1052 00b9 00       		.byte	0x0
 1053 00ba 00       		.byte	0x0
 1054 00bb 10       		.uleb128 0x10
 1055 00bc 2E       		.uleb128 0x2e
 1056 00bd 01       		.byte	0x1
 1057 00be 3F       		.uleb128 0x3f
 1058 00bf 0C       		.uleb128 0xc
 1059 00c0 03       		.uleb128 0x3
 1060 00c1 0E       		.uleb128 0xe
 1061 00c2 3A       		.uleb128 0x3a
 1062 00c3 0B       		.uleb128 0xb
 1063 00c4 3B       		.uleb128 0x3b
 1064 00c5 0B       		.uleb128 0xb
 1065 00c6 49       		.uleb128 0x49
 1066 00c7 13       		.uleb128 0x13
 1067 00c8 11       		.uleb128 0x11
 1068 00c9 01       		.uleb128 0x1
 1069 00ca 12       		.uleb128 0x12
 1070 00cb 01       		.uleb128 0x1
 1071 00cc 40       		.uleb128 0x40
 1072 00cd 0A       		.uleb128 0xa
 1073 00ce 01       		.uleb128 0x1
 1074 00cf 13       		.uleb128 0x13
 1075 00d0 00       		.byte	0x0
 1076 00d1 00       		.byte	0x0
GAS LISTING /tmp/ccnhEzDm.s 			page 24


 1077 00d2 11       		.uleb128 0x11
 1078 00d3 34       		.uleb128 0x34
 1079 00d4 00       		.byte	0x0
 1080 00d5 03       		.uleb128 0x3
 1081 00d6 08       		.uleb128 0x8
 1082 00d7 3A       		.uleb128 0x3a
 1083 00d8 0B       		.uleb128 0xb
 1084 00d9 3B       		.uleb128 0x3b
 1085 00da 0B       		.uleb128 0xb
 1086 00db 49       		.uleb128 0x49
 1087 00dc 13       		.uleb128 0x13
 1088 00dd 1C       		.uleb128 0x1c
 1089 00de 05       		.uleb128 0x5
 1090 00df 00       		.byte	0x0
 1091 00e0 00       		.byte	0x0
 1092 00e1 12       		.uleb128 0x12
 1093 00e2 34       		.uleb128 0x34
 1094 00e3 00       		.byte	0x0
 1095 00e4 03       		.uleb128 0x3
 1096 00e5 0E       		.uleb128 0xe
 1097 00e6 3A       		.uleb128 0x3a
 1098 00e7 0B       		.uleb128 0xb
 1099 00e8 3B       		.uleb128 0x3b
 1100 00e9 0B       		.uleb128 0xb
 1101 00ea 49       		.uleb128 0x49
 1102 00eb 13       		.uleb128 0x13
 1103 00ec 1C       		.uleb128 0x1c
 1104 00ed 06       		.uleb128 0x6
 1105 00ee 00       		.byte	0x0
 1106 00ef 00       		.byte	0x0
 1107 00f0 13       		.uleb128 0x13
 1108 00f1 34       		.uleb128 0x34
 1109 00f2 00       		.byte	0x0
 1110 00f3 03       		.uleb128 0x3
 1111 00f4 0E       		.uleb128 0xe
 1112 00f5 3A       		.uleb128 0x3a
 1113 00f6 0B       		.uleb128 0xb
 1114 00f7 3B       		.uleb128 0x3b
 1115 00f8 0B       		.uleb128 0xb
 1116 00f9 49       		.uleb128 0x49
 1117 00fa 13       		.uleb128 0x13
 1118 00fb 02       		.uleb128 0x2
 1119 00fc 0A       		.uleb128 0xa
 1120 00fd 00       		.byte	0x0
 1121 00fe 00       		.byte	0x0
 1122 00ff 14       		.uleb128 0x14
 1123 0100 34       		.uleb128 0x34
 1124 0101 00       		.byte	0x0
 1125 0102 03       		.uleb128 0x3
 1126 0103 08       		.uleb128 0x8
 1127 0104 3A       		.uleb128 0x3a
 1128 0105 0B       		.uleb128 0xb
 1129 0106 3B       		.uleb128 0x3b
 1130 0107 0B       		.uleb128 0xb
 1131 0108 49       		.uleb128 0x49
 1132 0109 13       		.uleb128 0x13
 1133 010a 00       		.byte	0x0
GAS LISTING /tmp/ccnhEzDm.s 			page 25


 1134 010b 00       		.byte	0x0
 1135 010c 15       		.uleb128 0x15
 1136 010d 34       		.uleb128 0x34
 1137 010e 00       		.byte	0x0
 1138 010f 03       		.uleb128 0x3
 1139 0110 08       		.uleb128 0x8
 1140 0111 3A       		.uleb128 0x3a
 1141 0112 0B       		.uleb128 0xb
 1142 0113 3B       		.uleb128 0x3b
 1143 0114 0B       		.uleb128 0xb
 1144 0115 49       		.uleb128 0x49
 1145 0116 13       		.uleb128 0x13
 1146 0117 02       		.uleb128 0x2
 1147 0118 06       		.uleb128 0x6
 1148 0119 00       		.byte	0x0
 1149 011a 00       		.byte	0x0
 1150 011b 16       		.uleb128 0x16
 1151 011c 34       		.uleb128 0x34
 1152 011d 00       		.byte	0x0
 1153 011e 03       		.uleb128 0x3
 1154 011f 0E       		.uleb128 0xe
 1155 0120 3A       		.uleb128 0x3a
 1156 0121 0B       		.uleb128 0xb
 1157 0122 3B       		.uleb128 0x3b
 1158 0123 0B       		.uleb128 0xb
 1159 0124 49       		.uleb128 0x49
 1160 0125 13       		.uleb128 0x13
 1161 0126 02       		.uleb128 0x2
 1162 0127 06       		.uleb128 0x6
 1163 0128 00       		.byte	0x0
 1164 0129 00       		.byte	0x0
 1165 012a 17       		.uleb128 0x17
 1166 012b 0B       		.uleb128 0xb
 1167 012c 01       		.byte	0x1
 1168 012d 55       		.uleb128 0x55
 1169 012e 06       		.uleb128 0x6
 1170 012f 01       		.uleb128 0x1
 1171 0130 13       		.uleb128 0x13
 1172 0131 00       		.byte	0x0
 1173 0132 00       		.byte	0x0
 1174 0133 18       		.uleb128 0x18
 1175 0134 0B       		.uleb128 0xb
 1176 0135 01       		.byte	0x1
 1177 0136 11       		.uleb128 0x11
 1178 0137 01       		.uleb128 0x1
 1179 0138 12       		.uleb128 0x12
 1180 0139 01       		.uleb128 0x1
 1181 013a 00       		.byte	0x0
 1182 013b 00       		.byte	0x0
 1183 013c 19       		.uleb128 0x19
 1184 013d 26       		.uleb128 0x26
 1185 013e 00       		.byte	0x0
 1186 013f 49       		.uleb128 0x49
 1187 0140 13       		.uleb128 0x13
 1188 0141 00       		.byte	0x0
 1189 0142 00       		.byte	0x0
 1190 0143 1A       		.uleb128 0x1a
GAS LISTING /tmp/ccnhEzDm.s 			page 26


 1191 0144 21       		.uleb128 0x21
 1192 0145 00       		.byte	0x0
 1193 0146 49       		.uleb128 0x49
 1194 0147 13       		.uleb128 0x13
 1195 0148 2F       		.uleb128 0x2f
 1196 0149 06       		.uleb128 0x6
 1197 014a 00       		.byte	0x0
 1198 014b 00       		.byte	0x0
 1199 014c 1B       		.uleb128 0x1b
 1200 014d 34       		.uleb128 0x34
 1201 014e 00       		.byte	0x0
 1202 014f 03       		.uleb128 0x3
 1203 0150 0E       		.uleb128 0xe
 1204 0151 3A       		.uleb128 0x3a
 1205 0152 0B       		.uleb128 0xb
 1206 0153 3B       		.uleb128 0x3b
 1207 0154 0B       		.uleb128 0xb
 1208 0155 49       		.uleb128 0x49
 1209 0156 13       		.uleb128 0x13
 1210 0157 3F       		.uleb128 0x3f
 1211 0158 0C       		.uleb128 0xc
 1212 0159 3C       		.uleb128 0x3c
 1213 015a 0C       		.uleb128 0xc
 1214 015b 00       		.byte	0x0
 1215 015c 00       		.byte	0x0
 1216 015d 00       		.byte	0x0
 1217              		.section	.debug_pubnames,"",@progbits
 1218 0000 17000000 		.long	0x17
 1219 0004 0200     		.value	0x2
 1220 0006 00000000 		.long	.Ldebug_info0
 1221 000a 5F040000 		.long	0x45f
 1222 000e F6020000 		.long	0x2f6
 1223 0012 6D61696E 		.string	"main"
 1223      00
 1224 0017 00000000 		.long	0x0
 1225              		.section	.debug_pubtypes,"",@progbits
 1226 0000 6C000000 		.long	0x6c
 1227 0004 0200     		.value	0x2
 1228 0006 00000000 		.long	.Ldebug_info0
 1229 000a 5F040000 		.long	0x45f
 1230 000e 2D000000 		.long	0x2d
 1231 0012 73697A65 		.string	"size_t"
 1231      5F7400
 1232 0019 77000000 		.long	0x77
 1233 001d 5F5F6F66 		.string	"__off_t"
 1233      665F7400 
 1234 0025 82000000 		.long	0x82
 1235 0029 5F5F6F66 		.string	"__off64_t"
 1235      6636345F 
 1235      7400
 1236 0033 3F020000 		.long	0x23f
 1237 0037 5F494F5F 		.string	"_IO_lock_t"
 1237      6C6F636B 
 1237      5F7400
 1238 0042 46020000 		.long	0x246
 1239 0046 5F494F5F 		.string	"_IO_marker"
 1239      6D61726B 
GAS LISTING /tmp/ccnhEzDm.s 			page 27


 1239      657200
 1240 0051 A3000000 		.long	0xa3
 1241 0055 5F494F5F 		.string	"_IO_FILE"
 1241      46494C45 
 1241      00
 1242 005e EB020000 		.long	0x2eb
 1243 0062 68656174 		.string	"heatmap_t"
 1243      6D61705F 
 1243      7400
 1244 006c 00000000 		.long	0x0
 1245              		.section	.debug_aranges,"",@progbits
 1246 0000 2C000000 		.long	0x2c
 1247 0004 0200     		.value	0x2
 1248 0006 00000000 		.long	.Ldebug_info0
 1249 000a 08       		.byte	0x8
 1250 000b 00       		.byte	0x0
 1251 000c 0000     		.value	0x0
 1252 000e 0000     		.value	0x0
 1253 0010 00000000 		.quad	.Ltext0
 1253      00000000 
 1254 0018 0D020000 		.quad	.Letext0-.Ltext0
 1254      00000000 
 1255 0020 00000000 		.quad	0x0
 1255      00000000 
 1256 0028 00000000 		.quad	0x0
 1256      00000000 
 1257              		.section	.debug_ranges,"",@progbits
 1258              	.Ldebug_ranges0:
 1259 0000 0D000000 		.quad	.LBB2-.Ltext0
 1259      00000000 
 1260 0008 17000000 		.quad	.LBE2-.Ltext0
 1260      00000000 
 1261 0010 58000000 		.quad	.LBB3-.Ltext0
 1261      00000000 
 1262 0018 28010000 		.quad	.LBE3-.Ltext0
 1262      00000000 
 1263 0020 00000000 		.quad	0x0
 1263      00000000 
 1264 0028 00000000 		.quad	0x0
 1264      00000000 
 1265              		.section	.debug_str,"MS",@progbits,1
 1266              	.LASF53:
 1267 0000 646F7562 		.string	"double"
 1267      6C6500
 1268              	.LASF42:
 1269 0007 5F494F5F 		.string	"_IO_FILE"
 1269      46494C45 
 1269      00
 1270              	.LASF24:
 1271 0010 5F494F5F 		.string	"_IO_save_end"
 1271      73617665 
 1271      5F656E64 
 1271      00
 1272              	.LASF58:
 1273 001d 6578616D 		.string	"examples/simplest.c"
 1273      706C6573 
 1273      2F73696D 
GAS LISTING /tmp/ccnhEzDm.s 			page 28


 1273      706C6573 
 1273      742E6300 
 1274              	.LASF7:
 1275 0031 73686F72 		.string	"short int"
 1275      7420696E 
 1275      7400
 1276              	.LASF8:
 1277 003b 73697A65 		.string	"size_t"
 1277      5F7400
 1278              	.LASF34:
 1279 0042 5F6F6666 		.string	"_offset"
 1279      73657400 
 1280              	.LASF48:
 1281 004a 68656174 		.string	"heatmap_t"
 1281      6D61705F 
 1281      7400
 1282              	.LASF51:
 1283 0054 62656769 		.string	"begin"
 1283      6E00
 1284              	.LASF18:
 1285 005a 5F494F5F 		.string	"_IO_write_ptr"
 1285      77726974 
 1285      655F7074 
 1285      7200
 1286              	.LASF13:
 1287 0068 5F666C61 		.string	"_flags"
 1287      677300
 1288              	.LASF20:
 1289 006f 5F494F5F 		.string	"_IO_buf_base"
 1289      6275665F 
 1289      62617365 
 1289      00
 1290              	.LASF25:
 1291 007c 5F6D6172 		.string	"_markers"
 1291      6B657273 
 1291      00
 1292              	.LASF15:
 1293 0085 5F494F5F 		.string	"_IO_read_end"
 1293      72656164 
 1293      5F656E64 
 1293      00
 1294              	.LASF59:
 1295 0092 2F686F6D 		.string	"/home/hshu1/15618/project/15618fp/heatmap"
 1295      652F6873 
 1295      6875312F 
 1295      31353631 
 1295      382F7072 
 1296              	.LASF47:
 1297 00bc 666C6F61 		.string	"float"
 1297      7400
 1298              	.LASF56:
 1299 00c2 73746465 		.string	"stderr"
 1299      727200
 1300              	.LASF3:
 1301 00c9 6C6F6E67 		.string	"long long int"
 1301      206C6F6E 
 1301      6720696E 
GAS LISTING /tmp/ccnhEzDm.s 			page 29


 1301      7400
 1302              	.LASF33:
 1303 00d7 5F6C6F63 		.string	"_lock"
 1303      6B00
 1304              	.LASF2:
 1305 00dd 6C6F6E67 		.string	"long int"
 1305      20696E74 
 1305      00
 1306              	.LASF30:
 1307 00e6 5F637572 		.string	"_cur_column"
 1307      5F636F6C 
 1307      756D6E00 
 1308              	.LASF46:
 1309 00f2 5F706F73 		.string	"_pos"
 1309      00
 1310              	.LASF29:
 1311 00f7 5F6F6C64 		.string	"_old_offset"
 1311      5F6F6666 
 1311      73657400 
 1312              	.LASF4:
 1313 0103 756E7369 		.string	"unsigned char"
 1313      676E6564 
 1313      20636861 
 1313      7200
 1314              	.LASF6:
 1315 0111 7369676E 		.string	"signed char"
 1315      65642063 
 1315      68617200 
 1316              	.LASF12:
 1317 011d 6C6F6E67 		.string	"long long unsigned int"
 1317      206C6F6E 
 1317      6720756E 
 1317      7369676E 
 1317      65642069 
 1318              	.LASF1:
 1319 0134 756E7369 		.string	"unsigned int"
 1319      676E6564 
 1319      20696E74 
 1319      00
 1320              	.LASF43:
 1321 0141 5F494F5F 		.string	"_IO_marker"
 1321      6D61726B 
 1321      657200
 1322              	.LASF32:
 1323 014c 5F73686F 		.string	"_shortbuf"
 1323      72746275 
 1323      6600
 1324              	.LASF17:
 1325 0156 5F494F5F 		.string	"_IO_write_base"
 1325      77726974 
 1325      655F6261 
 1325      736500
 1326              	.LASF41:
 1327 0165 5F756E75 		.string	"_unused2"
 1327      73656432 
 1327      00
 1328              	.LASF14:
GAS LISTING /tmp/ccnhEzDm.s 			page 30


 1329 016e 5F494F5F 		.string	"_IO_read_ptr"
 1329      72656164 
 1329      5F707472 
 1329      00
 1330              	.LASF21:
 1331 017b 5F494F5F 		.string	"_IO_buf_end"
 1331      6275665F 
 1331      656E6400 
 1332              	.LASF11:
 1333 0187 63686172 		.string	"char"
 1333      00
 1334              	.LASF61:
 1335 018c 6D61696E 		.string	"main"
 1335      00
 1336              	.LASF44:
 1337 0191 5F6E6578 		.string	"_next"
 1337      7400
 1338              	.LASF35:
 1339 0197 5F5F7061 		.string	"__pad1"
 1339      643100
 1340              	.LASF36:
 1341 019e 5F5F7061 		.string	"__pad2"
 1341      643200
 1342              	.LASF37:
 1343 01a5 5F5F7061 		.string	"__pad3"
 1343      643300
 1344              	.LASF38:
 1345 01ac 5F5F7061 		.string	"__pad4"
 1345      643400
 1346              	.LASF39:
 1347 01b3 5F5F7061 		.string	"__pad5"
 1347      643500
 1348              	.LASF57:
 1349 01ba 474E5520 		.string	"GNU C 4.4.7 20120313 (Red Hat 4.4.7-4)"
 1349      4320342E 
 1349      342E3720 
 1349      32303132 
 1349      30333133 
 1350              	.LASF5:
 1351 01e1 73686F72 		.string	"short unsigned int"
 1351      7420756E 
 1351      7369676E 
 1351      65642069 
 1351      6E7400
 1352              	.LASF0:
 1353 01f4 6C6F6E67 		.string	"long unsigned int"
 1353      20756E73 
 1353      69676E65 
 1353      6420696E 
 1353      7400
 1354              	.LASF49:
 1355 0206 6E706F69 		.string	"npoints"
 1355      6E747300 
 1356              	.LASF19:
 1357 020e 5F494F5F 		.string	"_IO_write_end"
 1357      77726974 
 1357      655F656E 
GAS LISTING /tmp/ccnhEzDm.s 			page 31


 1357      6400
 1358              	.LASF10:
 1359 021c 5F5F6F66 		.string	"__off64_t"
 1359      6636345F 
 1359      7400
 1360              	.LASF50:
 1361 0226 696D6167 		.string	"image"
 1361      6500
 1362              	.LASF27:
 1363 022c 5F66696C 		.string	"_fileno"
 1363      656E6F00 
 1364              	.LASF26:
 1365 0234 5F636861 		.string	"_chain"
 1365      696E00
 1366              	.LASF9:
 1367 023b 5F5F6F66 		.string	"__off_t"
 1367      665F7400 
 1368              	.LASF23:
 1369 0243 5F494F5F 		.string	"_IO_backup_base"
 1369      6261636B 
 1369      75705F62 
 1369      61736500 
 1370              	.LASF54:
 1371 0253 73746469 		.string	"stdin"
 1371      6E00
 1372              	.LASF28:
 1373 0259 5F666C61 		.string	"_flags2"
 1373      67733200 
 1374              	.LASF40:
 1375 0261 5F6D6F64 		.string	"_mode"
 1375      6500
 1376              	.LASF16:
 1377 0267 5F494F5F 		.string	"_IO_read_base"
 1377      72656164 
 1377      5F626173 
 1377      6500
 1378              	.LASF31:
 1379 0275 5F767461 		.string	"_vtable_offset"
 1379      626C655F 
 1379      6F666673 
 1379      657400
 1380              	.LASF52:
 1381 0284 6572726F 		.string	"error"
 1381      7200
 1382              	.LASF22:
 1383 028a 5F494F5F 		.string	"_IO_save_base"
 1383      73617665 
 1383      5F626173 
 1383      6500
 1384              	.LASF45:
 1385 0298 5F736275 		.string	"_sbuf"
 1385      6600
 1386              	.LASF55:
 1387 029e 7374646F 		.string	"stdout"
 1387      757400
 1388              	.LASF60:
 1389 02a5 5F494F5F 		.string	"_IO_lock_t"
GAS LISTING /tmp/ccnhEzDm.s 			page 32


 1389      6C6F636B 
 1389      5F7400
 1390              		.ident	"GCC: (GNU) 4.4.7 20120313 (Red Hat 4.4.7-4)"
 1391              		.section	.note.GNU-stack,"",@progbits
