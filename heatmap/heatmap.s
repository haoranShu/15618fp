GAS LISTING /tmp/ccK2IhnQ.s 			page 1


   1              		.file	"heatmap_block.c"
   2              		.section	.debug_abbrev,"",@progbits
   3              	.Ldebug_abbrev0:
   4              		.section	.debug_info,"",@progbits
   5              	.Ldebug_info0:
   6              		.section	.debug_line,"",@progbits
   7              	.Ldebug_line0:
   8 0000 51020000 		.text
   8      02006E00 
   8      00000101 
   8      FB0E0D00 
   8      01010101 
   9              	.Ltext0:
  10              		.p2align 4,,15
  11              	.globl heatmap_add_point_with_stamp
  12              		.type	heatmap_add_point_with_stamp, @function
  13              	heatmap_add_point_with_stamp:
  14              	.LFB28:
  15              		.file 1 "heatmap_block.c"
   0:heatmap_block.c **** /* heatmap - High performance heatmap creation in C.
   1:heatmap_block.c ****  *
   2:heatmap_block.c ****  * The MIT License (MIT)
   3:heatmap_block.c ****  *
   4:heatmap_block.c ****  * Copyright (c) 2013 Lucas Beyer
   5:heatmap_block.c ****  *
   6:heatmap_block.c ****  * Permission is hereby granted, free of charge, to any person obtaining a copy of
   7:heatmap_block.c ****  * this software and associated documentation files (the "Software"), to deal in
   8:heatmap_block.c ****  * the Software without restriction, including without limitation the rights to
   9:heatmap_block.c ****  * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
  10:heatmap_block.c ****  * the Software, and to permit persons to whom the Software is furnished to do so,
  11:heatmap_block.c ****  * subject to the following conditions:
  12:heatmap_block.c ****  *
  13:heatmap_block.c ****  * The above copyright notice and this permission notice shall be included in all
  14:heatmap_block.c ****  * copies or substantial portions of the Software.
  15:heatmap_block.c ****  *
  16:heatmap_block.c ****  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  17:heatmap_block.c ****  * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
  18:heatmap_block.c ****  * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
  19:heatmap_block.c ****  * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
  20:heatmap_block.c ****  * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
  21:heatmap_block.c ****  * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  22:heatmap_block.c ****  */
  23:heatmap_block.c **** 
  24:heatmap_block.c **** #include "heatmap.h"
  25:heatmap_block.c **** 
  26:heatmap_block.c **** #include <stdlib.h> /* malloc, calloc, free */
  27:heatmap_block.c **** #include <string.h> /* memcpy, memset */
  28:heatmap_block.c **** #include <math.h>   /* sqrtf */
  29:heatmap_block.c **** #include <assert.h> /* assert, #define NDEBUG to ignore. */
  30:heatmap_block.c **** #include <omp.h>
  31:heatmap_block.c **** 
  32:heatmap_block.c **** #define NUM_OF_BLOCKS 8
  33:heatmap_block.c **** 
  34:heatmap_block.c **** /* Having a default stamp ready makes it easier for simple usage of the library
  35:heatmap_block.c ****  * since there is no need to create a new stamp.
  36:heatmap_block.c ****  */
  37:heatmap_block.c **** static float stamp_default_4_data[] = {
GAS LISTING /tmp/ccK2IhnQ.s 			page 2


  38:heatmap_block.c ****     0.0f      , 0.0f      , 0.1055728f, 0.1753789f, 0.2f, 0.1753789f, 0.1055728f, 0.0f      , 0.0f 
  39:heatmap_block.c ****     0.0f      , 0.1514719f, 0.2788897f, 0.3675445f, 0.4f, 0.3675445f, 0.2788897f, 0.1514719f, 0.0f 
  40:heatmap_block.c ****     0.1055728f, 0.2788897f, 0.4343146f, 0.5527864f, 0.6f, 0.5527864f, 0.4343146f, 0.2788897f, 0.105
  41:heatmap_block.c ****     0.1753789f, 0.3675445f, 0.5527864f, 0.7171573f, 0.8f, 0.7171573f, 0.5527864f, 0.3675445f, 0.175
  42:heatmap_block.c ****     0.2f      , 0.4f      , 0.6f      , 0.8f      , 1.0f, 0.8f      , 0.6f      , 0.4f      , 0.2f 
  43:heatmap_block.c ****     0.1753789f, 0.3675445f, 0.5527864f, 0.7171573f, 0.8f, 0.7171573f, 0.5527864f, 0.3675445f, 0.175
  44:heatmap_block.c ****     0.1055728f, 0.2788897f, 0.4343146f, 0.5527864f, 0.6f, 0.5527864f, 0.4343146f, 0.2788897f, 0.105
  45:heatmap_block.c ****     0.0f      , 0.1514719f, 0.2788897f, 0.3675445f, 0.4f, 0.3675445f, 0.2788897f, 0.1514719f, 0.0f 
  46:heatmap_block.c ****     0.0f      , 0.0f      , 0.1055728f, 0.1753789f, 0.2f, 0.1753789f, 0.1055728f, 0.0f      , 0.0f 
  47:heatmap_block.c **** };
  48:heatmap_block.c **** 
  49:heatmap_block.c **** static heatmap_stamp_t stamp_default_4 = {
  50:heatmap_block.c ****     stamp_default_4_data, 9, 9
  51:heatmap_block.c **** };
  52:heatmap_block.c **** 
  53:heatmap_block.c **** void heatmap_init(heatmap_t* hm, unsigned w, unsigned h)
  54:heatmap_block.c **** {
  55:heatmap_block.c ****     memset(hm, 0, sizeof(heatmap_t));
  56:heatmap_block.c ****     hm->buf = (float*)calloc(w*h, sizeof(float));
  57:heatmap_block.c ****     hm->w = w;
  58:heatmap_block.c ****     hm->h = h;
  59:heatmap_block.c **** }
  60:heatmap_block.c **** 
  61:heatmap_block.c **** heatmap_t* heatmap_new(unsigned w, unsigned h)
  62:heatmap_block.c **** {
  63:heatmap_block.c ****     heatmap_t* hm = (heatmap_t*)malloc(sizeof(heatmap_t));
  64:heatmap_block.c ****     heatmap_init(hm, w, h);
  65:heatmap_block.c ****     return hm;
  66:heatmap_block.c **** }
  67:heatmap_block.c **** 
  68:heatmap_block.c **** void heatmap_free(heatmap_t* h)
  69:heatmap_block.c **** {
  70:heatmap_block.c ****     free(h->buf);
  71:heatmap_block.c ****     free(h);
  72:heatmap_block.c **** }
  73:heatmap_block.c **** 
  74:heatmap_block.c **** /* Jay: Added functions to support better OpenMP parallelism */
  75:heatmap_block.c **** void heatmap_add_points_omp(heatmap_t* h, unsigned* xs, unsigned* ys, unsigned num_points)
  76:heatmap_block.c **** {
  77:heatmap_block.c ****     heatmap_add_points_omp_with_stamp(h, xs, ys, num_points, &stamp_default_4);
  78:heatmap_block.c **** }
  79:heatmap_block.c **** 
  80:heatmap_block.c **** void heatmap_add_points_omp_with_stamp(heatmap_t* h, unsigned* xs, unsigned* ys, unsigned num_point
  81:heatmap_block.c **** {
  82:heatmap_block.c **** 
  83:heatmap_block.c ****     const unsigned block_length = (num_points + NUM_OF_BLOCKS - 1) / NUM_OF_BLOCKS;
  84:heatmap_block.c ****     heatmap_t local_heatmap[NUM_OF_BLOCKS];
  85:heatmap_block.c **** 
  86:heatmap_block.c ****     omp_set_num_threads(NUM_OF_BLOCKS);
  87:heatmap_block.c ****     #pragma omp parallel
  88:heatmap_block.c ****     {
  89:heatmap_block.c ****         int idx = omp_get_thread_num();
  90:heatmap_block.c ****         unsigned start = idx * block_length;
  91:heatmap_block.c ****         unsigned end = start + block_length <= num_points ? start + block_length : num_points;
  92:heatmap_block.c **** 
  93:heatmap_block.c ****         heatmap_init(&local_heatmap[idx], h->w, h->h);
  94:heatmap_block.c **** 
GAS LISTING /tmp/ccK2IhnQ.s 			page 3


  95:heatmap_block.c ****         unsigned i;
  96:heatmap_block.c ****         for (i = start; i < end; i++)
  97:heatmap_block.c ****         {
  98:heatmap_block.c ****             // heatmap_add_weighted_point_with_stamp(local_heatmap + idx, xs[i], ys[i], 1.0, stamp)
  99:heatmap_block.c ****             local_heatmap[idx].buf[ys[i] * h->w + xs[i]] += 1.0;
 100:heatmap_block.c ****         }
 101:heatmap_block.c ****     }
 102:heatmap_block.c **** 
 103:heatmap_block.c ****     unsigned x, y, k, i;
 104:heatmap_block.c ****     float w;
 105:heatmap_block.c **** 
 106:heatmap_block.c ****     for (y = 0, i = 0; y < h->h; y++)
 107:heatmap_block.c ****     {
 108:heatmap_block.c ****         for (x = 0; x < h->w; x++, i++)
 109:heatmap_block.c ****         {
 110:heatmap_block.c ****             w = local_heatmap[0].buf[i];
 111:heatmap_block.c ****             for (k = 1; k < NUM_OF_BLOCKS; k++)
 112:heatmap_block.c ****             {
 113:heatmap_block.c ****                 w += local_heatmap[k].buf[i];
 114:heatmap_block.c ****             }
 115:heatmap_block.c **** 
 116:heatmap_block.c ****             if (w > 0)
 117:heatmap_block.c ****             {
 118:heatmap_block.c ****                 heatmap_add_weighted_point_with_stamp(h, x, y, w, stamp);
 119:heatmap_block.c ****             }
 120:heatmap_block.c **** 
 121:heatmap_block.c ****         }
 122:heatmap_block.c ****     }
 123:heatmap_block.c **** }
 124:heatmap_block.c **** /* End added functions */
 125:heatmap_block.c **** 
 126:heatmap_block.c **** void heatmap_add_point(heatmap_t* h, unsigned x, unsigned y)
 127:heatmap_block.c **** {
 128:heatmap_block.c ****     heatmap_add_point_with_stamp(h, x, y, &stamp_default_4);
 129:heatmap_block.c **** }
 130:heatmap_block.c **** 
 131:heatmap_block.c **** void heatmap_add_point_with_stamp(heatmap_t* h, unsigned x, unsigned y, const heatmap_stamp_t* stam
 132:heatmap_block.c **** {
  16              		.loc 1 133 0
  17              		.cfi_startproc
  18              	.LVL0:
  19 0000 4157     		pushq	%r15
  20              		.cfi_def_cfa_offset 16
  21              		.cfi_offset 15, -16
 133:heatmap_block.c ****     /* I'm still unsure whether we want this to be an assert or not... */
 134:heatmap_block.c ****     if(x >= h->w || y >= h->h)
  22              		.loc 1 135 0
  23 0002 448B5F0C 		movl	12(%rdi), %r11d
 133:heatmap_block.c ****     /* I'm still unsure whether we want this to be an assert or not... */
  24              		.loc 1 133 0
  25 0006 4156     		pushq	%r14
  26              		.cfi_def_cfa_offset 24
  27              		.cfi_offset 14, -24
  28              		.loc 1 135 0
  29 0008 4139F3   		cmpl	%esi, %r11d
 133:heatmap_block.c ****     /* I'm still unsure whether we want this to be an assert or not... */
  30              		.loc 1 133 0
GAS LISTING /tmp/ccK2IhnQ.s 			page 4


  31 000b 4155     		pushq	%r13
  32              		.cfi_def_cfa_offset 32
  33              		.cfi_offset 13, -32
  34 000d 4154     		pushq	%r12
  35              		.cfi_def_cfa_offset 40
  36              		.cfi_offset 12, -40
  37 000f 55       		pushq	%rbp
  38              		.cfi_def_cfa_offset 48
  39              		.cfi_offset 6, -48
  40 0010 53       		pushq	%rbx
  41              		.cfi_def_cfa_offset 56
  42              		.cfi_offset 3, -56
  43              		.loc 1 135 0
  44 0011 0F86F800 		jbe	.L15
  44      0000
  45 0017 448B4710 		movl	16(%rdi), %r8d
  46 001b 4139D0   		cmpl	%edx, %r8d
  47 001e 0F86EB00 		jbe	.L15
  47      0000
  48              	.LBB2:
 135:heatmap_block.c ****         return;
 136:heatmap_block.c **** 
 137:heatmap_block.c ****     /* I hate you, C */
 138:heatmap_block.c ****     {
 139:heatmap_block.c ****         /* Note: the order of operations is important, since we're computing with unsigned! */
 140:heatmap_block.c **** 
 141:heatmap_block.c ****         /* These are [first, last) pairs in the STAMP's pixels. */
 142:heatmap_block.c ****         const unsigned x0 = x < stamp->w/2 ? (stamp->w/2 - x) : 0;
  49              		.loc 1 143 0
  50 0024 448B6108 		movl	8(%rcx), %r12d
 143:heatmap_block.c ****         const unsigned y0 = y < stamp->h/2 ? (stamp->h/2 - y) : 0;
  51              		.loc 1 144 0
  52 0028 8B590C   		movl	12(%rcx), %ebx
 143:heatmap_block.c ****         const unsigned y0 = y < stamp->h/2 ? (stamp->h/2 - y) : 0;
  53              		.loc 1 143 0
  54 002b 4531C9   		xorl	%r9d, %r9d
  55 002e 4489E0   		movl	%r12d, %eax
  56              		.loc 1 144 0
  57 0031 4189DF   		movl	%ebx, %r15d
 144:heatmap_block.c ****         const unsigned x1 = (x + stamp->w/2) < h->w ? stamp->w : stamp->w/2 + (h->w - x);
  58              		.loc 1 145 0
  59 0034 4589E5   		movl	%r12d, %r13d
 143:heatmap_block.c ****         const unsigned y0 = y < stamp->h/2 ? (stamp->h/2 - y) : 0;
  60              		.loc 1 143 0
  61 0037 D1E8     		shrl	%eax
  62 0039 89C5     		movl	%eax, %ebp
  63 003b 29F5     		subl	%esi, %ebp
  64 003d 39C6     		cmpl	%eax, %esi
  65 003f 410F43E9 		cmovae	%r9d, %ebp
  66              	.LVL1:
 144:heatmap_block.c ****         const unsigned x1 = (x + stamp->w/2) < h->w ? stamp->w : stamp->w/2 + (h->w - x);
  67              		.loc 1 144 0
  68 0043 41D1EF   		shrl	%r15d
  69 0046 4589FA   		movl	%r15d, %r10d
  70 0049 4129D2   		subl	%edx, %r10d
  71 004c 4439FA   		cmpl	%r15d, %edx
  72 004f 450F42CA 		cmovb	%r10d, %r9d
GAS LISTING /tmp/ccK2IhnQ.s 			page 5


  73              	.LVL2:
  74              		.loc 1 145 0
  75 0053 448D1406 		leal	(%rsi,%rax), %r10d
  76 0057 4539D3   		cmpl	%r10d, %r11d
  77 005a 7707     		ja	.L8
  78 005c 468D2C18 		leal	(%rax,%r11), %r13d
  79 0060 4129F5   		subl	%esi, %r13d
  80              	.L8:
  81              	.LVL3:
 145:heatmap_block.c ****         const unsigned y1 = (y + stamp->h/2) < h->h ? stamp->h : stamp->h/2 + (h->h - y);
  82              		.loc 1 146 0
  83 0063 468D143A 		leal	(%rdx,%r15), %r10d
  84 0067 4539D0   		cmpl	%r10d, %r8d
  85 006a 0F86AA00 		jbe	.L19
  85      0000
  86              	.L9:
  87              	.LVL4:
 146:heatmap_block.c **** 
 147:heatmap_block.c ****         unsigned iy;
 148:heatmap_block.c **** 
 149:heatmap_block.c ****         for(iy = y0 ; iy < y1 ; ++iy) {
  88              		.loc 1 150 0
  89 0070 4139D9   		cmpl	%ebx, %r9d
  90 0073 0F839600 		jae	.L15
  90      0000
  91 0079 8D743500 		leal	0(%rbp,%rsi), %esi
  92              	.LVL5:
  93 007d 89C0     		mov	%eax, %eax
  94 007f 4429FA   		subl	%r15d, %edx
  95              	.LVL6:
  96              	.LBB4:
 150:heatmap_block.c ****             /* TODO: could it be clearer by using separate vars and computing a ystep? */
 151:heatmap_block.c ****             float* line = h->buf + ((y + iy) - stamp->h/2)*h->w + (x + x0) - stamp->w/2;
  97              		.loc 1 152 0
  98 0082 4589CA   		movl	%r9d, %r10d
  99              	.LBE4:
 150:heatmap_block.c ****             /* TODO: could it be clearer by using separate vars and computing a ystep? */
 100              		.loc 1 150 0
 101 0085 4189D7   		movl	%edx, %r15d
 102 0088 4C8B31   		movq	(%rcx), %r14
 103 008b 48897424 		movq	%rsi, -16(%rsp)
 103      F0
 104 0090 48294424 		subq	%rax, -16(%rsp)
 104      F0
 105 0095 89E8     		mov	%ebp, %eax
 106 0097 48894424 		movq	%rax, -8(%rsp)
 106      F8
 107              	.LBB3:
 132:heatmap_block.c **** void heatmap_add_point_with_stamp(heatmap_t* h, unsigned x, unsigned y, const heatmap_stamp_t* stam
 108              		.loc 1 132 0
 109 009c 89E8     		movl	%ebp, %eax
 110              		.loc 1 152 0
 111 009e 488B17   		movq	(%rdi), %rdx
 132:heatmap_block.c **** void heatmap_add_point_with_stamp(heatmap_t* h, unsigned x, unsigned y, const heatmap_stamp_t* stam
 112              		.loc 1 132 0
 113 00a1 F7D0     		notl	%eax
 114 00a3 4401E8   		addl	%r13d, %eax
GAS LISTING /tmp/ccK2IhnQ.s 			page 6


 115              		.loc 1 152 0
 116 00a6 450FAFD4 		imull	%r12d, %r10d
 132:heatmap_block.c **** void heatmap_add_point_with_stamp(heatmap_t* h, unsigned x, unsigned y, const heatmap_stamp_t* stam
 117              		.loc 1 132 0
 118 00aa 4C8D0485 		leaq	4(,%rax,4), %r8
 118      04000000 
 119              	.LVL7:
 120              		.p2align 4,,10
 121 00b2 660F1F44 		.p2align 3
 121      0000
 122              	.L14:
 152:heatmap_block.c ****             const float* stampline = stamp->buf + iy*stamp->w + x0;
 153:heatmap_block.c **** 
 154:heatmap_block.c ****             unsigned ix;
 155:heatmap_block.c ****             for(ix = x0 ; ix < x1 ; ++ix, ++line, ++stampline) {
 123              		.loc 1 156 0
 124 00b8 4439ED   		cmpl	%r13d, %ebp
 125 00bb 7346     		jae	.L10
 152:heatmap_block.c ****             const float* stampline = stamp->buf + iy*stamp->w + x0;
 126              		.loc 1 152 0
 127 00bd 438D0439 		leal	(%r9,%r15), %eax
 128 00c1 410FAFC3 		imull	%r11d, %eax
 129 00c5 48034424 		addq	-16(%rsp), %rax
 129      F0
 130 00ca 488D0C82 		leaq	(%rdx,%rax,4), %rcx
 153:heatmap_block.c ****             const float* stampline = stamp->buf + iy*stamp->w + x0;
 131              		.loc 1 153 0
 132 00ce 4489D0   		mov	%r10d, %eax
 133 00d1 48034424 		addq	-8(%rsp), %rax
 133      F8
 134 00d6 498D3486 		leaq	(%r14,%rax,4), %rsi
 132:heatmap_block.c **** void heatmap_add_point_with_stamp(heatmap_t* h, unsigned x, unsigned y, const heatmap_stamp_t* stam
 135              		.loc 1 132 0
 136 00da 31C0     		xorl	%eax, %eax
 137              	.LVL8:
 138 00dc 0F1F4000 		.p2align 4,,10
 139              		.p2align 3
 140              	.L13:
 156:heatmap_block.c ****                 /* TODO: Let's actually accept negatives and try out funky stamps. */
 157:heatmap_block.c ****                 /* Note that that might mess with the max though. */
 158:heatmap_block.c ****                 /* And that we'll have to clamp the bottom to 0 when rendering. */
 159:heatmap_block.c ****                 assert(*stampline >= 0.0f);
 160:heatmap_block.c **** 
 161:heatmap_block.c ****                 *line += *stampline;
 141              		.loc 1 162 0
 142 00e0 F30F1004 		movss	(%rcx,%rax), %xmm0
 142      01
 143 00e5 F30F5804 		addss	(%rsi,%rax), %xmm0
 143      06
 144 00ea F30F1104 		movss	%xmm0, (%rcx,%rax)
 144      01
 162:heatmap_block.c ****                 if(*line > h->max) {h->max = *line;}
 145              		.loc 1 163 0
 146 00ef 0F2E4708 		ucomiss	8(%rdi), %xmm0
 147 00f3 7605     		jbe	.L11
 148 00f5 F30F1147 		movss	%xmm0, 8(%rdi)
 148      08
GAS LISTING /tmp/ccK2IhnQ.s 			page 7


 149              	.L11:
 150 00fa 4883C004 		addq	$4, %rax
 156:heatmap_block.c ****                 /* TODO: Let's actually accept negatives and try out funky stamps. */
 151              		.loc 1 156 0
 152 00fe 4C39C0   		cmpq	%r8, %rax
 153 0101 75DD     		jne	.L13
 154              	.L10:
 155              	.LBE3:
 150:heatmap_block.c ****         for(iy = y0 ; iy < y1 ; ++iy) {
 156              		.loc 1 150 0
 157 0103 4183C101 		addl	$1, %r9d
 158              	.LVL9:
 159 0107 4501E2   		addl	%r12d, %r10d
 160 010a 4439CB   		cmpl	%r9d, %ebx
 161 010d 77A9     		ja	.L14
 162              	.LVL10:
 163              	.L15:
 164              	.LBE2:
 163:heatmap_block.c **** 
 164:heatmap_block.c ****                 assert(*line >= 0.0f);
 165:heatmap_block.c ****             }
 166:heatmap_block.c ****         }
 167:heatmap_block.c ****     } /* I hate you very much! */
 168:heatmap_block.c **** }
 165              		.loc 1 169 0
 166 010f 5B       		popq	%rbx
 167              		.cfi_remember_state
 168              		.cfi_def_cfa_offset 48
 169 0110 5D       		popq	%rbp
 170              		.cfi_def_cfa_offset 40
 171 0111 415C     		popq	%r12
 172              		.cfi_def_cfa_offset 32
 173 0113 415D     		popq	%r13
 174              		.cfi_def_cfa_offset 24
 175 0115 415E     		popq	%r14
 176              		.cfi_def_cfa_offset 16
 177 0117 415F     		popq	%r15
 178              		.cfi_def_cfa_offset 8
 179 0119 C3       		ret
 180              	.LVL11:
 181              	.L19:
 182              		.cfi_restore_state
 183              	.LBB5:
 146:heatmap_block.c ****         const unsigned y1 = (y + stamp->h/2) < h->h ? stamp->h : stamp->h/2 + (h->h - y);
 184              		.loc 1 146 0
 185 011a 438D1C07 		leal	(%r15,%r8), %ebx
 186 011e 29D3     		subl	%edx, %ebx
 187 0120 E94BFFFF 		jmp	.L9
 187      FF
 188              	.LBE5:
 189              		.cfi_endproc
 190              	.LFE28:
 191              		.size	heatmap_add_point_with_stamp, .-heatmap_add_point_with_stamp
 192 0125 66662E0F 		.p2align 4,,15
 192      1F840000 
 192      000000
 193              	.globl heatmap_add_point
GAS LISTING /tmp/ccK2IhnQ.s 			page 8


 194              		.type	heatmap_add_point, @function
 195              	heatmap_add_point:
 196              	.LFB27:
 128:heatmap_block.c **** {
 197              		.loc 1 128 0
 198              		.cfi_startproc
 199              	.LVL12:
 129:heatmap_block.c ****     heatmap_add_point_with_stamp(h, x, y, &stamp_default_4);
 200              		.loc 1 129 0
 201 0130 488D0D00 		leaq	stamp_default_4(%rip), %rcx
 201      000000
 202 0137 E9000000 		jmp	heatmap_add_point_with_stamp@PLT
 202      00
 203              		.cfi_endproc
 204              	.LFE27:
 205              		.size	heatmap_add_point, .-heatmap_add_point
 206 013c 0F1F4000 		.p2align 4,,15
 207              	.globl heatmap_add_weighted_point_with_stamp
 208              		.type	heatmap_add_weighted_point_with_stamp, @function
 209              	heatmap_add_weighted_point_with_stamp:
 210              	.LFB30:
 169:heatmap_block.c **** 
 170:heatmap_block.c **** void heatmap_add_weighted_point(heatmap_t* h, unsigned x, unsigned y, float w)
 171:heatmap_block.c **** {
 172:heatmap_block.c ****     heatmap_add_weighted_point_with_stamp(h, x, y, w, &stamp_default_4);
 173:heatmap_block.c **** }
 174:heatmap_block.c **** 
 175:heatmap_block.c **** /* Initial timings do show a difference large enough (~10% slower without FMA)
 176:heatmap_block.c ****  * that we do care about splitting the implementation,
 177:heatmap_block.c ****  * even though JUST A SINGLE LINE OF CODE has changed!
 178:heatmap_block.c ****  * And I don't want to spoil the readability by using macro-trickery to avoid duplication.
 179:heatmap_block.c ****  * sad :-(
 180:heatmap_block.c ****  */
 181:heatmap_block.c **** void heatmap_add_weighted_point_with_stamp(heatmap_t* h, unsigned x, unsigned y, float w, const hea
 182:heatmap_block.c **** {
 211              		.loc 1 183 0
 212              		.cfi_startproc
 213              	.LVL13:
 214 0140 4157     		pushq	%r15
 215              		.cfi_def_cfa_offset 16
 216              		.cfi_offset 15, -16
 183:heatmap_block.c ****     /* I'm still unsure whether we want this to be an assert or not... */
 184:heatmap_block.c ****     if(x >= h->w || y >= h->h)
 217              		.loc 1 185 0
 218 0142 448B5F0C 		movl	12(%rdi), %r11d
 183:heatmap_block.c ****     /* I'm still unsure whether we want this to be an assert or not... */
 219              		.loc 1 183 0
 220 0146 4156     		pushq	%r14
 221              		.cfi_def_cfa_offset 24
 222              		.cfi_offset 14, -24
 223              		.loc 1 185 0
 224 0148 4139F3   		cmpl	%esi, %r11d
 183:heatmap_block.c ****     /* I'm still unsure whether we want this to be an assert or not... */
 225              		.loc 1 183 0
 226 014b 4155     		pushq	%r13
 227              		.cfi_def_cfa_offset 32
 228              		.cfi_offset 13, -32
GAS LISTING /tmp/ccK2IhnQ.s 			page 9


 229 014d 4154     		pushq	%r12
 230              		.cfi_def_cfa_offset 40
 231              		.cfi_offset 12, -40
 232 014f 55       		pushq	%rbp
 233              		.cfi_def_cfa_offset 48
 234              		.cfi_offset 6, -48
 235 0150 53       		pushq	%rbx
 236              		.cfi_def_cfa_offset 56
 237              		.cfi_offset 3, -56
 238              		.loc 1 185 0
 239 0151 0F86FC00 		jbe	.L36
 239      0000
 240 0157 448B4710 		movl	16(%rdi), %r8d
 241 015b 4139D0   		cmpl	%edx, %r8d
 242 015e 0F86EF00 		jbe	.L36
 242      0000
 243              	.LBB6:
 185:heatmap_block.c ****         return;
 186:heatmap_block.c **** 
 187:heatmap_block.c ****     /* Currently, negative weights are not supported as they mess with the max. */
 188:heatmap_block.c ****     assert(w >= 0.0f);
 189:heatmap_block.c **** 
 190:heatmap_block.c ****     /* I hate you, C */
 191:heatmap_block.c ****     {
 192:heatmap_block.c ****         /* Note: the order of operations is important, since we're computing with unsigned! */
 193:heatmap_block.c **** 
 194:heatmap_block.c ****         /* These are [first, last) pairs in the STAMP's pixels. */
 195:heatmap_block.c ****         const unsigned x0 = x < stamp->w/2 ? (stamp->w/2 - x) : 0;
 244              		.loc 1 196 0
 245 0164 448B6108 		movl	8(%rcx), %r12d
 196:heatmap_block.c ****         const unsigned y0 = y < stamp->h/2 ? (stamp->h/2 - y) : 0;
 246              		.loc 1 197 0
 247 0168 8B590C   		movl	12(%rcx), %ebx
 196:heatmap_block.c ****         const unsigned y0 = y < stamp->h/2 ? (stamp->h/2 - y) : 0;
 248              		.loc 1 196 0
 249 016b 4531C9   		xorl	%r9d, %r9d
 250 016e 4489E0   		movl	%r12d, %eax
 251              		.loc 1 197 0
 252 0171 4189DF   		movl	%ebx, %r15d
 197:heatmap_block.c ****         const unsigned x1 = (x + stamp->w/2) < h->w ? stamp->w : stamp->w/2 + (h->w - x);
 253              		.loc 1 198 0
 254 0174 4589E5   		movl	%r12d, %r13d
 196:heatmap_block.c ****         const unsigned y0 = y < stamp->h/2 ? (stamp->h/2 - y) : 0;
 255              		.loc 1 196 0
 256 0177 D1E8     		shrl	%eax
 257 0179 89C5     		movl	%eax, %ebp
 258 017b 29F5     		subl	%esi, %ebp
 259 017d 39C6     		cmpl	%eax, %esi
 260 017f 410F43E9 		cmovae	%r9d, %ebp
 261              	.LVL14:
 197:heatmap_block.c ****         const unsigned x1 = (x + stamp->w/2) < h->w ? stamp->w : stamp->w/2 + (h->w - x);
 262              		.loc 1 197 0
 263 0183 41D1EF   		shrl	%r15d
 264 0186 4589FA   		movl	%r15d, %r10d
 265 0189 4129D2   		subl	%edx, %r10d
 266 018c 4439FA   		cmpl	%r15d, %edx
 267 018f 450F42CA 		cmovb	%r10d, %r9d
GAS LISTING /tmp/ccK2IhnQ.s 			page 10


 268              	.LVL15:
 269              		.loc 1 198 0
 270 0193 448D1406 		leal	(%rsi,%rax), %r10d
 271 0197 4539D3   		cmpl	%r10d, %r11d
 272 019a 7707     		ja	.L29
 273 019c 468D2C18 		leal	(%rax,%r11), %r13d
 274 01a0 4129F5   		subl	%esi, %r13d
 275              	.L29:
 276              	.LVL16:
 198:heatmap_block.c ****         const unsigned y1 = (y + stamp->h/2) < h->h ? stamp->h : stamp->h/2 + (h->h - y);
 277              		.loc 1 199 0
 278 01a3 468D143A 		leal	(%rdx,%r15), %r10d
 279 01a7 4539D0   		cmpl	%r10d, %r8d
 280 01aa 0F86AE00 		jbe	.L39
 280      0000
 281              	.L30:
 282              	.LVL17:
 199:heatmap_block.c **** 
 200:heatmap_block.c ****         unsigned iy;
 201:heatmap_block.c **** 
 202:heatmap_block.c ****         for(iy = y0 ; iy < y1 ; ++iy) {
 283              		.loc 1 203 0
 284 01b0 4139D9   		cmpl	%ebx, %r9d
 285 01b3 0F839A00 		jae	.L36
 285      0000
 286 01b9 8D743500 		leal	0(%rbp,%rsi), %esi
 287              	.LVL18:
 288 01bd 89C0     		mov	%eax, %eax
 289 01bf 4429FA   		subl	%r15d, %edx
 290              	.LVL19:
 291              	.LBB8:
 203:heatmap_block.c ****             /* TODO: could it be clearer by using separate vars and computing a ystep? */
 204:heatmap_block.c ****             float* line = h->buf + ((y + iy) - stamp->h/2)*h->w + (x + x0) - stamp->w/2;
 292              		.loc 1 205 0
 293 01c2 4589CA   		movl	%r9d, %r10d
 294              	.LBE8:
 203:heatmap_block.c ****             /* TODO: could it be clearer by using separate vars and computing a ystep? */
 295              		.loc 1 203 0
 296 01c5 4189D7   		movl	%edx, %r15d
 297 01c8 4C8B31   		movq	(%rcx), %r14
 298 01cb 48897424 		movq	%rsi, -16(%rsp)
 298      F0
 299 01d0 48294424 		subq	%rax, -16(%rsp)
 299      F0
 300 01d5 89E8     		mov	%ebp, %eax
 301 01d7 48894424 		movq	%rax, -8(%rsp)
 301      F8
 302              	.LBB7:
 182:heatmap_block.c **** void heatmap_add_weighted_point_with_stamp(heatmap_t* h, unsigned x, unsigned y, float w, const hea
 303              		.loc 1 182 0
 304 01dc 89E8     		movl	%ebp, %eax
 305              		.loc 1 205 0
 306 01de 488B17   		movq	(%rdi), %rdx
 182:heatmap_block.c **** void heatmap_add_weighted_point_with_stamp(heatmap_t* h, unsigned x, unsigned y, float w, const hea
 307              		.loc 1 182 0
 308 01e1 F7D0     		notl	%eax
 309 01e3 4401E8   		addl	%r13d, %eax
GAS LISTING /tmp/ccK2IhnQ.s 			page 11


 310              		.loc 1 205 0
 311 01e6 450FAFD4 		imull	%r12d, %r10d
 182:heatmap_block.c **** void heatmap_add_weighted_point_with_stamp(heatmap_t* h, unsigned x, unsigned y, float w, const hea
 312              		.loc 1 182 0
 313 01ea 4C8D0485 		leaq	4(,%rax,4), %r8
 313      04000000 
 314              	.LVL20:
 315              		.p2align 4,,10
 316 01f2 660F1F44 		.p2align 3
 316      0000
 317              	.L35:
 205:heatmap_block.c ****             const float* stampline = stamp->buf + iy*stamp->w + x0;
 206:heatmap_block.c **** 
 207:heatmap_block.c ****             unsigned ix;
 208:heatmap_block.c ****             for(ix = x0 ; ix < x1 ; ++ix, ++line, ++stampline) {
 318              		.loc 1 209 0
 319 01f8 4439ED   		cmpl	%r13d, %ebp
 320 01fb 734A     		jae	.L31
 205:heatmap_block.c ****             const float* stampline = stamp->buf + iy*stamp->w + x0;
 321              		.loc 1 205 0
 322 01fd 438D0439 		leal	(%r9,%r15), %eax
 323 0201 410FAFC3 		imull	%r11d, %eax
 324 0205 48034424 		addq	-16(%rsp), %rax
 324      F0
 325 020a 488D0C82 		leaq	(%rdx,%rax,4), %rcx
 206:heatmap_block.c ****             const float* stampline = stamp->buf + iy*stamp->w + x0;
 326              		.loc 1 206 0
 327 020e 4489D0   		mov	%r10d, %eax
 328 0211 48034424 		addq	-8(%rsp), %rax
 328      F8
 329 0216 498D3486 		leaq	(%r14,%rax,4), %rsi
 182:heatmap_block.c **** void heatmap_add_weighted_point_with_stamp(heatmap_t* h, unsigned x, unsigned y, float w, const hea
 330              		.loc 1 182 0
 331 021a 31C0     		xorl	%eax, %eax
 332              	.LVL21:
 333 021c 0F1F4000 		.p2align 4,,10
 334              		.p2align 3
 335              	.L34:
 209:heatmap_block.c ****                 /* TODO: see unweighted function */
 210:heatmap_block.c ****                 assert(*stampline >= 0.0f);
 211:heatmap_block.c **** 
 212:heatmap_block.c ****                 *line += *stampline * w;
 336              		.loc 1 213 0
 337 0220 F30F100C 		movss	(%rsi,%rax), %xmm1
 337      06
 338 0225 F30F59C8 		mulss	%xmm0, %xmm1
 339 0229 F30F580C 		addss	(%rcx,%rax), %xmm1
 339      01
 340 022e F30F110C 		movss	%xmm1, (%rcx,%rax)
 340      01
 213:heatmap_block.c ****                 if(*line > h->max) {h->max = *line;}
 341              		.loc 1 214 0
 342 0233 0F2E4F08 		ucomiss	8(%rdi), %xmm1
 343 0237 7605     		jbe	.L32
 344 0239 F30F114F 		movss	%xmm1, 8(%rdi)
 344      08
 345              	.L32:
GAS LISTING /tmp/ccK2IhnQ.s 			page 12


 346 023e 4883C004 		addq	$4, %rax
 209:heatmap_block.c ****                 /* TODO: see unweighted function */
 347              		.loc 1 209 0
 348 0242 4C39C0   		cmpq	%r8, %rax
 349 0245 75D9     		jne	.L34
 350              	.L31:
 351              	.LBE7:
 203:heatmap_block.c ****         for(iy = y0 ; iy < y1 ; ++iy) {
 352              		.loc 1 203 0
 353 0247 4183C101 		addl	$1, %r9d
 354              	.LVL22:
 355 024b 4501E2   		addl	%r12d, %r10d
 356 024e 4439CB   		cmpl	%r9d, %ebx
 357 0251 77A5     		ja	.L35
 358              	.LVL23:
 359              	.L36:
 360              	.LBE6:
 214:heatmap_block.c **** 
 215:heatmap_block.c ****                 assert(*line >= 0.0f);
 216:heatmap_block.c ****             }
 217:heatmap_block.c ****         }
 218:heatmap_block.c ****     } /* I hate you very much! */
 219:heatmap_block.c **** }
 361              		.loc 1 220 0
 362 0253 5B       		popq	%rbx
 363              		.cfi_remember_state
 364              		.cfi_def_cfa_offset 48
 365 0254 5D       		popq	%rbp
 366              		.cfi_def_cfa_offset 40
 367 0255 415C     		popq	%r12
 368              		.cfi_def_cfa_offset 32
 369 0257 415D     		popq	%r13
 370              		.cfi_def_cfa_offset 24
 371 0259 415E     		popq	%r14
 372              		.cfi_def_cfa_offset 16
 373 025b 415F     		popq	%r15
 374              		.cfi_def_cfa_offset 8
 375 025d C3       		ret
 376              	.LVL24:
 377              	.L39:
 378              		.cfi_restore_state
 379              	.LBB9:
 199:heatmap_block.c ****         const unsigned y1 = (y + stamp->h/2) < h->h ? stamp->h : stamp->h/2 + (h->h - y);
 380              		.loc 1 199 0
 381 025e 438D1C07 		leal	(%r15,%r8), %ebx
 382 0262 29D3     		subl	%edx, %ebx
 383 0264 E947FFFF 		jmp	.L30
 383      FF
 384              	.LBE9:
 385              		.cfi_endproc
 386              	.LFE30:
 387              		.size	heatmap_add_weighted_point_with_stamp, .-heatmap_add_weighted_point_with_stamp
 388 0269 0F1F8000 		.p2align 4,,15
 388      000000
 389              	.globl heatmap_add_weighted_point
 390              		.type	heatmap_add_weighted_point, @function
 391              	heatmap_add_weighted_point:
GAS LISTING /tmp/ccK2IhnQ.s 			page 13


 392              	.LFB29:
 172:heatmap_block.c **** {
 393              		.loc 1 172 0
 394              		.cfi_startproc
 395              	.LVL25:
 173:heatmap_block.c ****     heatmap_add_weighted_point_with_stamp(h, x, y, w, &stamp_default_4);
 396              		.loc 1 173 0
 397 0270 488D0D00 		leaq	stamp_default_4(%rip), %rcx
 397      000000
 398 0277 E9000000 		jmp	heatmap_add_weighted_point_with_stamp@PLT
 398      00
 399              		.cfi_endproc
 400              	.LFE29:
 401              		.size	heatmap_add_weighted_point, .-heatmap_add_weighted_point
 402 027c 0F1F4000 		.p2align 4,,15
 403              		.type	linear_dist, @function
 404              	linear_dist:
 405              	.LFB37:
 220:heatmap_block.c **** 
 221:heatmap_block.c **** unsigned char* heatmap_render_default_to(const heatmap_t* h, unsigned char* colorbuf)
 222:heatmap_block.c **** {
 223:heatmap_block.c ****     return heatmap_render_to(h, heatmap_cs_default, colorbuf);
 224:heatmap_block.c **** }
 225:heatmap_block.c **** 
 226:heatmap_block.c **** unsigned char* heatmap_render_to(const heatmap_t* h, const heatmap_colorscheme_t* colorscheme, unsi
 227:heatmap_block.c **** {
 228:heatmap_block.c ****     /* TODO: Time whether it makes a noticeable difference to inline that code
 229:heatmap_block.c ****      * here and drop the saturation step.
 230:heatmap_block.c ****      */
 231:heatmap_block.c ****     /* If the heatmap is empty, h->max (and thus the saturation value) is 0.0, resulting in a 0-by-
 232:heatmap_block.c ****      * In that case, we should set the saturation to anything but 0, since we want the result of th
 233:heatmap_block.c ****      * Also, a comparison to exact 0.0f (as opposed to 1e-14) is OK, since we only do division.
 234:heatmap_block.c ****      */
 235:heatmap_block.c ****     return heatmap_render_saturated_to(h, colorscheme, h->max > 0.0f ? h->max : 1.0f, colorbuf);
 236:heatmap_block.c **** }
 237:heatmap_block.c **** 
 238:heatmap_block.c **** unsigned char* heatmap_render_saturated_to(const heatmap_t* h, const heatmap_colorscheme_t* colorsc
 239:heatmap_block.c **** {
 240:heatmap_block.c ****     unsigned y;
 241:heatmap_block.c ****     assert(saturation > 0.0f);
 242:heatmap_block.c **** 
 243:heatmap_block.c ****     /* For convenience, if no buffer is given, malloc a new one. */
 244:heatmap_block.c ****     if(!colorbuf) {
 245:heatmap_block.c ****         colorbuf = (unsigned char*)malloc(h->w*h->h*4);
 246:heatmap_block.c ****         if(!colorbuf) {
 247:heatmap_block.c ****             return 0;
 248:heatmap_block.c ****         }
 249:heatmap_block.c ****     }
 250:heatmap_block.c **** 
 251:heatmap_block.c ****     /* TODO: could actually even flatten this loop before parallelizing it. */
 252:heatmap_block.c ****     /* I.e., to go i = 0 ; i < h*w since I don't have any padding! (yet?) */
 253:heatmap_block.c ****     for(y = 0 ; y < h->h ; ++y) {
 254:heatmap_block.c ****         float* bufline = h->buf + y*h->w;
 255:heatmap_block.c ****         unsigned char* colorline = colorbuf + 4*y*h->w;
 256:heatmap_block.c **** 
 257:heatmap_block.c ****         unsigned x;
 258:heatmap_block.c ****         for(x = 0 ; x < h->w ; ++x, ++bufline) {
GAS LISTING /tmp/ccK2IhnQ.s 			page 14


 259:heatmap_block.c ****             /* Saturate the heat value to the given saturation, and then
 260:heatmap_block.c ****              * normalize by that.
 261:heatmap_block.c ****              */
 262:heatmap_block.c ****             const float val = (*bufline > saturation ? saturation : *bufline)/saturation;
 263:heatmap_block.c **** 
 264:heatmap_block.c ****             /* We add 0.5 in order to do real rounding, not just dropping the
 265:heatmap_block.c ****              * decimal part. That way we are certain the highest value in the
 266:heatmap_block.c ****              * colorscheme is actually used.
 267:heatmap_block.c ****              */
 268:heatmap_block.c ****             const size_t idx = (size_t)((float)(colorscheme->ncolors-1)*val + 0.5f);
 269:heatmap_block.c **** 
 270:heatmap_block.c ****             /* This is probably caused by a negative entry in the stamp! */
 271:heatmap_block.c ****             assert(val >= 0.0f);
 272:heatmap_block.c **** 
 273:heatmap_block.c ****             /* This should never happen. It is likely a bug in this library. */
 274:heatmap_block.c ****             assert(idx < colorscheme->ncolors);
 275:heatmap_block.c **** 
 276:heatmap_block.c ****             /* Just copy over the color from the colorscheme. */
 277:heatmap_block.c ****             memcpy(colorline, colorscheme->colors + idx*4, 4);
 278:heatmap_block.c ****             colorline += 4;
 279:heatmap_block.c ****         }
 280:heatmap_block.c ****     }
 281:heatmap_block.c **** 
 282:heatmap_block.c ****     return colorbuf;
 283:heatmap_block.c **** }
 284:heatmap_block.c **** 
 285:heatmap_block.c **** void heatmap_stamp_init(heatmap_stamp_t* stamp, unsigned w, unsigned h, float* data)
 286:heatmap_block.c **** {
 287:heatmap_block.c ****     if(stamp) {
 288:heatmap_block.c ****         memset(stamp, 0, sizeof(heatmap_stamp_t));
 289:heatmap_block.c ****         stamp->w = w;
 290:heatmap_block.c ****         stamp->h = h;
 291:heatmap_block.c ****         stamp->buf = data;
 292:heatmap_block.c ****     }
 293:heatmap_block.c **** }
 294:heatmap_block.c **** 
 295:heatmap_block.c **** heatmap_stamp_t* heatmap_stamp_new_with(unsigned w, unsigned h, float* data)
 296:heatmap_block.c **** {
 297:heatmap_block.c ****     heatmap_stamp_t* stamp = (heatmap_stamp_t*)malloc(sizeof(heatmap_stamp_t));
 298:heatmap_block.c ****     heatmap_stamp_init(stamp, w, h, data);
 299:heatmap_block.c ****     return stamp;
 300:heatmap_block.c **** }
 301:heatmap_block.c **** 
 302:heatmap_block.c **** heatmap_stamp_t* heatmap_stamp_load(unsigned w, unsigned h, float* data)
 303:heatmap_block.c **** {
 304:heatmap_block.c ****     float* copy = (float*)malloc(sizeof(float)*w*h);
 305:heatmap_block.c ****     memcpy(copy, data, sizeof(float)*w*h);
 306:heatmap_block.c ****     return heatmap_stamp_new_with(w, h, copy);
 307:heatmap_block.c **** }
 308:heatmap_block.c **** 
 309:heatmap_block.c **** static float linear_dist(float dist)
 310:heatmap_block.c **** {
 406              		.loc 1 311 0
 407              		.cfi_startproc
 408              	.LVL26:
 311:heatmap_block.c ****     return dist;
 312:heatmap_block.c **** }
GAS LISTING /tmp/ccK2IhnQ.s 			page 15


 409              		.loc 1 313 0
 410 0280 F3       		rep
 411 0281 C3       		ret
 412              		.cfi_endproc
 413              	.LFE37:
 414              		.size	linear_dist, .-linear_dist
 415 0282 66666666 		.p2align 4,,15
 415      662E0F1F 
 415      84000000 
 415      0000
 416              	.globl heatmap_colorscheme_free
 417              		.type	heatmap_colorscheme_free, @function
 418              	heatmap_colorscheme_free:
 419              	.LFB42:
 313:heatmap_block.c **** 
 314:heatmap_block.c **** heatmap_stamp_t* heatmap_stamp_gen(unsigned r)
 315:heatmap_block.c **** {
 316:heatmap_block.c ****     return heatmap_stamp_gen_nonlinear(r, linear_dist);
 317:heatmap_block.c **** }
 318:heatmap_block.c **** 
 319:heatmap_block.c **** heatmap_stamp_t* heatmap_stamp_gen_nonlinear(unsigned r, float (*distshape)(float))
 320:heatmap_block.c **** {
 321:heatmap_block.c ****     unsigned y;
 322:heatmap_block.c ****     unsigned d = 2*r+1;
 323:heatmap_block.c **** 
 324:heatmap_block.c ****     float* stamp = (float*)calloc(d*d, sizeof(float));
 325:heatmap_block.c ****     if(!stamp)
 326:heatmap_block.c ****         return 0;
 327:heatmap_block.c **** 
 328:heatmap_block.c ****     for(y = 0 ; y < d ; ++y) {
 329:heatmap_block.c ****         float* line = stamp + y*d;
 330:heatmap_block.c ****         unsigned x;
 331:heatmap_block.c ****         for(x = 0 ; x < d ; ++x, ++line) {
 332:heatmap_block.c ****             const float dist = sqrtf((float)((x-r)*(x-r) + (y-r)*(y-r)))/(float)(r+1);
 333:heatmap_block.c ****             const float ds = (*distshape)(dist);
 334:heatmap_block.c ****             /* This doesn't generate optimal assembly, but meh, it's readable. */
 335:heatmap_block.c ****             const float clamped_ds = ds > 1.0f ? 1.0f
 336:heatmap_block.c ****                                    : ds < 0.0f ? 0.0f
 337:heatmap_block.c ****                                    :             ds;
 338:heatmap_block.c ****             *line = 1.0f - clamped_ds;
 339:heatmap_block.c ****         }
 340:heatmap_block.c ****     }
 341:heatmap_block.c **** 
 342:heatmap_block.c ****     return heatmap_stamp_new_with(d, d, stamp);
 343:heatmap_block.c **** }
 344:heatmap_block.c **** 
 345:heatmap_block.c **** void heatmap_stamp_free(heatmap_stamp_t* s)
 346:heatmap_block.c **** {
 347:heatmap_block.c ****     free(s->buf);
 348:heatmap_block.c ****     free(s);
 349:heatmap_block.c **** }
 350:heatmap_block.c **** 
 351:heatmap_block.c **** heatmap_colorscheme_t* heatmap_colorscheme_load(const unsigned char* in_colors, size_t ncolors)
 352:heatmap_block.c **** {
 353:heatmap_block.c ****     heatmap_colorscheme_t* cs = (heatmap_colorscheme_t*)calloc(1, sizeof(heatmap_colorscheme_t));
 354:heatmap_block.c ****     unsigned char* colors = (unsigned char*)malloc(4*ncolors);
 355:heatmap_block.c **** 
GAS LISTING /tmp/ccK2IhnQ.s 			page 16


 356:heatmap_block.c ****     if(!cs || !colors) {
 357:heatmap_block.c ****         free(cs);
 358:heatmap_block.c ****         free(colors);
 359:heatmap_block.c ****         return 0;
 360:heatmap_block.c ****     }
 361:heatmap_block.c **** 
 362:heatmap_block.c ****     memcpy(colors, in_colors, 4*ncolors);
 363:heatmap_block.c **** 
 364:heatmap_block.c ****     cs->colors = colors;
 365:heatmap_block.c ****     cs->ncolors = ncolors;
 366:heatmap_block.c ****     return cs;
 367:heatmap_block.c **** }
 368:heatmap_block.c **** 
 369:heatmap_block.c **** void heatmap_colorscheme_free(heatmap_colorscheme_t* cs)
 370:heatmap_block.c **** {
 420              		.loc 1 371 0
 421              		.cfi_startproc
 422              	.LVL27:
 423 0290 53       		pushq	%rbx
 424              		.cfi_def_cfa_offset 16
 425              		.cfi_offset 3, -16
 426              		.loc 1 371 0
 427 0291 4889FB   		movq	%rdi, %rbx
 371:heatmap_block.c ****     /* ehhh, const_cast<>! */
 372:heatmap_block.c ****     free((void*)cs->colors);
 428              		.loc 1 373 0
 429 0294 488B3F   		movq	(%rdi), %rdi
 430              	.LVL28:
 431 0297 E8000000 		call	free@PLT
 431      00
 373:heatmap_block.c ****     free(cs);
 432              		.loc 1 374 0
 433 029c 4889DF   		movq	%rbx, %rdi
 374:heatmap_block.c **** }
 434              		.loc 1 375 0
 435 029f 5B       		popq	%rbx
 436              		.cfi_def_cfa_offset 8
 437              	.LVL29:
 374:heatmap_block.c **** }
 438              		.loc 1 374 0
 439 02a0 E9000000 		jmp	free@PLT
 439      00
 440              		.cfi_endproc
 441              	.LFE42:
 442              		.size	heatmap_colorscheme_free, .-heatmap_colorscheme_free
 443 02a5 66662E0F 		.p2align 4,,15
 443      1F840000 
 443      000000
 444              	.globl heatmap_stamp_free
 445              		.type	heatmap_stamp_free, @function
 446              	heatmap_stamp_free:
 447              	.LFB40:
 347:heatmap_block.c **** {
 448              		.loc 1 347 0
 449              		.cfi_startproc
 450              	.LVL30:
 451 02b0 53       		pushq	%rbx
GAS LISTING /tmp/ccK2IhnQ.s 			page 17


 452              		.cfi_def_cfa_offset 16
 453              		.cfi_offset 3, -16
 347:heatmap_block.c **** {
 454              		.loc 1 347 0
 455 02b1 4889FB   		movq	%rdi, %rbx
 348:heatmap_block.c ****     free(s->buf);
 456              		.loc 1 348 0
 457 02b4 488B3F   		movq	(%rdi), %rdi
 458              	.LVL31:
 459 02b7 E8000000 		call	free@PLT
 459      00
 349:heatmap_block.c ****     free(s);
 460              		.loc 1 349 0
 461 02bc 4889DF   		movq	%rbx, %rdi
 350:heatmap_block.c **** }
 462              		.loc 1 350 0
 463 02bf 5B       		popq	%rbx
 464              		.cfi_def_cfa_offset 8
 465              	.LVL32:
 349:heatmap_block.c ****     free(s);
 466              		.loc 1 349 0
 467 02c0 E9000000 		jmp	free@PLT
 467      00
 468              		.cfi_endproc
 469              	.LFE40:
 470              		.size	heatmap_stamp_free, .-heatmap_stamp_free
 471 02c5 66662E0F 		.p2align 4,,15
 471      1F840000 
 471      000000
 472              	.globl heatmap_free
 473              		.type	heatmap_free, @function
 474              	heatmap_free:
 475              	.LFB24:
  70:heatmap_block.c **** {
 476              		.loc 1 70 0
 477              		.cfi_startproc
 478              	.LVL33:
 479 02d0 53       		pushq	%rbx
 480              		.cfi_def_cfa_offset 16
 481              		.cfi_offset 3, -16
  70:heatmap_block.c **** {
 482              		.loc 1 70 0
 483 02d1 4889FB   		movq	%rdi, %rbx
  71:heatmap_block.c ****     free(h->buf);
 484              		.loc 1 71 0
 485 02d4 488B3F   		movq	(%rdi), %rdi
 486              	.LVL34:
 487 02d7 E8000000 		call	free@PLT
 487      00
  72:heatmap_block.c ****     free(h);
 488              		.loc 1 72 0
 489 02dc 4889DF   		movq	%rbx, %rdi
  73:heatmap_block.c **** }
 490              		.loc 1 73 0
 491 02df 5B       		popq	%rbx
 492              		.cfi_def_cfa_offset 8
 493              	.LVL35:
GAS LISTING /tmp/ccK2IhnQ.s 			page 18


  72:heatmap_block.c ****     free(h);
 494              		.loc 1 72 0
 495 02e0 E9000000 		jmp	free@PLT
 495      00
 496              		.cfi_endproc
 497              	.LFE24:
 498              		.size	heatmap_free, .-heatmap_free
 499 02e5 66662E0F 		.p2align 4,,15
 499      1F840000 
 499      000000
 500              	.globl heatmap_colorscheme_load
 501              		.type	heatmap_colorscheme_load, @function
 502              	heatmap_colorscheme_load:
 503              	.LFB41:
 353:heatmap_block.c **** {
 504              		.loc 1 353 0
 505              		.cfi_startproc
 506              	.LVL36:
 507 02f0 4C896424 		movq	%r12, -32(%rsp)
 507      E0
 508 02f5 4989F4   		movq	%rsi, %r12
 509              		.cfi_offset 12, -40
 510 02f8 4C897424 		movq	%r14, -16(%rsp)
 510      F0
 355:heatmap_block.c ****     unsigned char* colors = (unsigned char*)malloc(4*ncolors);
 511              		.loc 1 355 0
 512 02fd 4E8D34A5 		leaq	0(,%r12,4), %r14
 512      00000000 
 513              		.cfi_offset 14, -24
 353:heatmap_block.c **** {
 514              		.loc 1 353 0
 515 0305 48895C24 		movq	%rbx, -48(%rsp)
 515      D0
 516 030a 48896C24 		movq	%rbp, -40(%rsp)
 516      D8
 517 030f 4C896C24 		movq	%r13, -24(%rsp)
 517      E8
 518 0314 4C897C24 		movq	%r15, -8(%rsp)
 518      F8
 354:heatmap_block.c ****     heatmap_colorscheme_t* cs = (heatmap_colorscheme_t*)calloc(1, sizeof(heatmap_colorscheme_t));
 519              		.loc 1 354 0
 520 0319 BE100000 		movl	$16, %esi
 520      00
 521              	.LVL37:
 353:heatmap_block.c **** {
 522              		.loc 1 353 0
 523 031e 4883EC38 		subq	$56, %rsp
 524              		.cfi_def_cfa_offset 64
 525              		.cfi_offset 15, -16
 526              		.cfi_offset 13, -32
 527              		.cfi_offset 6, -48
 528              		.cfi_offset 3, -56
 353:heatmap_block.c **** {
 529              		.loc 1 353 0
 530 0322 4989FD   		movq	%rdi, %r13
 354:heatmap_block.c ****     heatmap_colorscheme_t* cs = (heatmap_colorscheme_t*)calloc(1, sizeof(heatmap_colorscheme_t));
 531              		.loc 1 354 0
GAS LISTING /tmp/ccK2IhnQ.s 			page 19


 532 0325 BF010000 		movl	$1, %edi
 532      00
 533              	.LVL38:
 534 032a E8000000 		call	calloc@PLT
 534      00
 355:heatmap_block.c ****     unsigned char* colors = (unsigned char*)malloc(4*ncolors);
 535              		.loc 1 355 0
 536 032f 4C89F7   		movq	%r14, %rdi
 354:heatmap_block.c ****     heatmap_colorscheme_t* cs = (heatmap_colorscheme_t*)calloc(1, sizeof(heatmap_colorscheme_t));
 537              		.loc 1 354 0
 538 0332 4889C3   		movq	%rax, %rbx
 539 0335 4989C7   		movq	%rax, %r15
 540              	.LVL39:
 355:heatmap_block.c ****     unsigned char* colors = (unsigned char*)malloc(4*ncolors);
 541              		.loc 1 355 0
 542 0338 E8000000 		call	malloc@PLT
 542      00
 543              	.LVL40:
 357:heatmap_block.c ****     if(!cs || !colors) {
 544              		.loc 1 357 0
 545 033d 4885C0   		testq	%rax, %rax
 355:heatmap_block.c ****     unsigned char* colors = (unsigned char*)malloc(4*ncolors);
 546              		.loc 1 355 0
 547 0340 4889C5   		movq	%rax, %rbp
 548              	.LVL41:
 357:heatmap_block.c ****     if(!cs || !colors) {
 549              		.loc 1 357 0
 550 0343 7443     		je	.L55
 551 0345 4885DB   		testq	%rbx, %rbx
 552 0348 743E     		je	.L55
 363:heatmap_block.c ****     memcpy(colors, in_colors, 4*ncolors);
 553              		.loc 1 363 0
 554 034a 4C89F2   		movq	%r14, %rdx
 555 034d 4C89EE   		movq	%r13, %rsi
 556 0350 4889C7   		movq	%rax, %rdi
 557 0353 E8000000 		call	memcpy@PLT
 557      00
 558              	.LVL42:
 365:heatmap_block.c ****     cs->colors = colors;
 559              		.loc 1 365 0
 560 0358 48892B   		movq	%rbp, (%rbx)
 366:heatmap_block.c ****     cs->ncolors = ncolors;
 561              		.loc 1 366 0
 562 035b 4C896308 		movq	%r12, 8(%rbx)
 563              	.LVL43:
 564              	.L53:
 368:heatmap_block.c **** }
 565              		.loc 1 368 0
 566 035f 4889D8   		movq	%rbx, %rax
 567 0362 488B6C24 		movq	16(%rsp), %rbp
 567      10
 568              	.LVL44:
 569 0367 488B5C24 		movq	8(%rsp), %rbx
 569      08
 570 036c 4C8B6424 		movq	24(%rsp), %r12
 570      18
 571              	.LVL45:
GAS LISTING /tmp/ccK2IhnQ.s 			page 20


 572 0371 4C8B6C24 		movq	32(%rsp), %r13
 572      20
 573              	.LVL46:
 574 0376 4C8B7424 		movq	40(%rsp), %r14
 574      28
 575 037b 4C8B7C24 		movq	48(%rsp), %r15
 575      30
 576              	.LVL47:
 577 0380 4883C438 		addq	$56, %rsp
 578              		.cfi_remember_state
 579              		.cfi_def_cfa_offset 8
 580 0384 C3       		ret
 581              	.LVL48:
 582              		.p2align 4,,10
 583 0385 0F1F00   		.p2align 3
 584              	.L55:
 585              		.cfi_restore_state
 358:heatmap_block.c ****         free(cs);
 586              		.loc 1 358 0
 587 0388 4C89FF   		movq	%r15, %rdi
 359:heatmap_block.c ****         free(colors);
 588              		.loc 1 359 0
 589 038b 31DB     		xorl	%ebx, %ebx
 590              	.LVL49:
 358:heatmap_block.c ****         free(cs);
 591              		.loc 1 358 0
 592 038d E8000000 		call	free@PLT
 592      00
 593              	.LVL50:
 359:heatmap_block.c ****         free(colors);
 594              		.loc 1 359 0
 595 0392 4889EF   		movq	%rbp, %rdi
 596 0395 E8000000 		call	free@PLT
 596      00
 360:heatmap_block.c ****         return 0;
 597              		.loc 1 360 0
 598 039a EBC3     		jmp	.L53
 599              		.cfi_endproc
 600              	.LFE41:
 601              		.size	heatmap_colorscheme_load, .-heatmap_colorscheme_load
 602 039c 0F1F4000 		.p2align 4,,15
 603              	.globl heatmap_render_saturated_to
 604              		.type	heatmap_render_saturated_to, @function
 605              	heatmap_render_saturated_to:
 606              	.LFB33:
 240:heatmap_block.c **** {
 607              		.loc 1 240 0
 608              		.cfi_startproc
 609              	.LVL51:
 610 03a0 4154     		pushq	%r12
 611              		.cfi_def_cfa_offset 16
 612              		.cfi_offset 12, -16
 613 03a2 4889D0   		movq	%rdx, %rax
 614 03a5 55       		pushq	%rbp
 615              		.cfi_def_cfa_offset 24
 616              		.cfi_offset 6, -24
 617 03a6 53       		pushq	%rbx
GAS LISTING /tmp/ccK2IhnQ.s 			page 21


 618              		.cfi_def_cfa_offset 32
 619              		.cfi_offset 3, -32
 620 03a7 4889FB   		movq	%rdi, %rbx
 621 03aa 4883EC20 		subq	$32, %rsp
 622              		.cfi_def_cfa_offset 64
 245:heatmap_block.c ****     if(!colorbuf) {
 623              		.loc 1 245 0
 624 03ae 4885D2   		testq	%rdx, %rdx
 625 03b1 0F84F200 		je	.L72
 625      0000
 626              	.LVL52:
 627              	.L57:
 254:heatmap_block.c ****     for(y = 0 ; y < h->h ; ++y) {
 628              		.loc 1 254 0
 629 03b7 8B5310   		movl	16(%rbx), %edx
 630 03ba 85D2     		testl	%edx, %edx
 631 03bc 0F84DE00 		je	.L58
 631      0000
 632 03c2 8B7B0C   		movl	12(%rbx), %edi
 633 03c5 4531E4   		xorl	%r12d, %r12d
 634              	.LBB10:
 635              	.LBB11:
 278:heatmap_block.c ****             memcpy(colorline, colorscheme->colors + idx*4, 4);
 636              		.loc 1 278 0
 637 03c8 48BD0000 		movabsq	$-9223372036854775808, %rbp
 637      00000000 
 637      0080
 638 03d2 F30F101D 		movss	.LC0(%rip), %xmm3
 638      00000000 
 639 03da F30F1025 		movss	.LC1(%rip), %xmm4
 639      00000000 
 640              	.LVL53:
 641              		.p2align 4,,10
 642 03e2 660F1F44 		.p2align 3
 642      0000
 643              	.L67:
 644              	.LBE11:
 259:heatmap_block.c ****         for(x = 0 ; x < h->w ; ++x, ++bufline) {
 645              		.loc 1 259 0
 646 03e8 85FF     		testl	%edi, %edi
 255:heatmap_block.c ****         float* bufline = h->buf + y*h->w;
 647              		.loc 1 255 0
 648 03ea 488B0B   		movq	(%rbx), %rcx
 649              	.LVL54:
 259:heatmap_block.c ****         for(x = 0 ; x < h->w ; ++x, ++bufline) {
 650              		.loc 1 259 0
 651 03ed 0F84A000 		je	.L59
 651      0000
 255:heatmap_block.c ****         float* bufline = h->buf + y*h->w;
 652              		.loc 1 255 0
 653 03f3 410FAFFC 		imull	%r12d, %edi
 654              	.LVL55:
 256:heatmap_block.c ****         unsigned char* colorline = colorbuf + 4*y*h->w;
 655              		.loc 1 256 0
 656 03f7 4531C0   		xorl	%r8d, %r8d
 255:heatmap_block.c ****         float* bufline = h->buf + y*h->w;
 657              		.loc 1 255 0
GAS LISTING /tmp/ccK2IhnQ.s 			page 22


 658 03fa 89FA     		mov	%edi, %edx
 256:heatmap_block.c ****         unsigned char* colorline = colorbuf + 4*y*h->w;
 659              		.loc 1 256 0
 660 03fc C1E702   		sall	$2, %edi
 661              	.LVL56:
 662 03ff 4189FA   		mov	%edi, %r10d
 255:heatmap_block.c ****         float* bufline = h->buf + y*h->w;
 663              		.loc 1 255 0
 664 0402 4C8D1C91 		leaq	(%rcx,%rdx,4), %r11
 256:heatmap_block.c ****         unsigned char* colorline = colorbuf + 4*y*h->w;
 665              		.loc 1 256 0
 666 0406 31C9     		xorl	%ecx, %ecx
 667 0408 4E8D1410 		leaq	(%rax,%r10), %r10
 668 040c EB23     		jmp	.L66
 669              	.LVL57:
 670 040e 6690     		.p2align 4,,10
 671              		.p2align 3
 672              	.L74:
 673              	.LBB12:
 278:heatmap_block.c ****             memcpy(colorline, colorscheme->colors + idx*4, 4);
 674              		.loc 1 278 0
 675 0410 F3480F2C 		cvttss2siq	%xmm1, %rdi
 675      F9
 676              	.L65:
 677 0415 48C1E702 		salq	$2, %rdi
 678 0419 48033E   		addq	(%rsi), %rdi
 679              	.LBE12:
 259:heatmap_block.c ****         for(x = 0 ; x < h->w ; ++x, ++bufline) {
 680              		.loc 1 259 0
 681 041c 4183C001 		addl	$1, %r8d
 682 0420 4883C104 		addq	$4, %rcx
 683              	.LBB13:
 278:heatmap_block.c ****             memcpy(colorline, colorscheme->colors + idx*4, 4);
 684              		.loc 1 278 0
 685 0424 8B17     		movl	(%rdi), %edx
 686 0426 418911   		movl	%edx, (%r9)
 687              	.LVL58:
 688              	.LBE13:
 259:heatmap_block.c ****         for(x = 0 ; x < h->w ; ++x, ++bufline) {
 689              		.loc 1 259 0
 690 0429 8B7B0C   		movl	12(%rbx), %edi
 691 042c 4439C7   		cmpl	%r8d, %edi
 692 042f 765F     		jbe	.L73
 693              	.LVL59:
 694              	.L66:
 695              	.LBB14:
 278:heatmap_block.c ****             memcpy(colorline, colorscheme->colors + idx*4, 4);
 696              		.loc 1 278 0
 697 0431 488B7E08 		movq	8(%rsi), %rdi
 263:heatmap_block.c ****             const float val = (*bufline > saturation ? saturation : *bufline)/saturation;
 698              		.loc 1 263 0
 699 0435 0F28C8   		movaps	%xmm0, %xmm1
 700              	.LBE14:
 239:heatmap_block.c **** unsigned char* heatmap_render_saturated_to(const heatmap_t* h, const heatmap_colorscheme_t* colorsc
 701              		.loc 1 239 0
 702 0438 4D8D0C0A 		leaq	(%r10,%rcx), %r9
 703              	.LBB15:
GAS LISTING /tmp/ccK2IhnQ.s 			page 23


 263:heatmap_block.c ****             const float val = (*bufline > saturation ? saturation : *bufline)/saturation;
 704              		.loc 1 263 0
 705 043c F3410F5D 		minss	(%r11,%rcx), %xmm1
 705      0C0B
 706              	.LVL60:
 278:heatmap_block.c ****             memcpy(colorline, colorscheme->colors + idx*4, 4);
 707              		.loc 1 278 0
 708 0442 4883EF01 		subq	$1, %rdi
 709 0446 7828     		js	.L62
 710 0448 F3480F2A 		cvtsi2ssq	%rdi, %xmm2
 710      D7
 711              	.L63:
 712 044d F30F5EC8 		divss	%xmm0, %xmm1
 713              	.LVL61:
 714 0451 F30F59CA 		mulss	%xmm2, %xmm1
 715 0455 F30F58CB 		addss	%xmm3, %xmm1
 716 0459 0F2E0D00 		ucomiss	.LC1(%rip), %xmm1
 716      000000
 717 0460 72AE     		jb	.L74
 718 0462 F30F5CCC 		subss	%xmm4, %xmm1
 719 0466 F3480F2C 		cvttss2siq	%xmm1, %rdi
 719      F9
 720 046b 4831EF   		xorq	%rbp, %rdi
 721 046e EBA5     		jmp	.L65
 722              	.LVL62:
 723              		.p2align 4,,10
 724              		.p2align 3
 725              	.L62:
 726 0470 4889FA   		movq	%rdi, %rdx
 727 0473 83E701   		andl	$1, %edi
 728 0476 48D1EA   		shrq	%rdx
 729 0479 4809FA   		orq	%rdi, %rdx
 730 047c F3480F2A 		cvtsi2ssq	%rdx, %xmm2
 730      D2
 731 0481 F30F58D2 		addss	%xmm2, %xmm2
 732 0485 EBC6     		jmp	.L63
 733              	.LVL63:
 734 0487 660F1F84 		.p2align 4,,10
 734      00000000 
 734      00
 735              		.p2align 3
 736              	.L73:
 737              	.LBE15:
 259:heatmap_block.c ****         for(x = 0 ; x < h->w ; ++x, ++bufline) {
 738              		.loc 1 259 0
 739 0490 8B5310   		movl	16(%rbx), %edx
 740              	.LVL64:
 741              	.L59:
 742              	.LBE10:
 254:heatmap_block.c ****     for(y = 0 ; y < h->h ; ++y) {
 743              		.loc 1 254 0
 744 0493 4183C401 		addl	$1, %r12d
 745              	.LVL65:
 746 0497 4139D4   		cmpl	%edx, %r12d
 747 049a 0F8248FF 		jb	.L67
 747      FFFF
 748              	.LVL66:
GAS LISTING /tmp/ccK2IhnQ.s 			page 24


 749              	.L58:
 284:heatmap_block.c **** }
 750              		.loc 1 284 0
 751 04a0 4883C420 		addq	$32, %rsp
 752              		.cfi_remember_state
 753              		.cfi_def_cfa_offset 32
 754 04a4 5B       		popq	%rbx
 755              		.cfi_def_cfa_offset 24
 756              	.LVL67:
 757 04a5 5D       		popq	%rbp
 758              		.cfi_def_cfa_offset 16
 759 04a6 415C     		popq	%r12
 760              		.cfi_def_cfa_offset 8
 761 04a8 C3       		ret
 762              	.LVL68:
 763              	.L72:
 764              		.cfi_restore_state
 246:heatmap_block.c ****         colorbuf = (unsigned char*)malloc(h->w*h->h*4);
 765              		.loc 1 246 0
 766 04a9 8B470C   		movl	12(%rdi), %eax
 767              	.LVL69:
 768 04ac 48897424 		movq	%rsi, 24(%rsp)
 768      18
 769 04b1 F30F1104 		movss	%xmm0, (%rsp)
 769      24
 770 04b6 0FAF4710 		imull	16(%rdi), %eax
 771 04ba C1E002   		sall	$2, %eax
 772 04bd 89C7     		mov	%eax, %edi
 773 04bf E8000000 		call	malloc@PLT
 773      00
 774              	.LVL70:
 247:heatmap_block.c ****         if(!colorbuf) {
 775              		.loc 1 247 0
 776 04c4 4885C0   		testq	%rax, %rax
 777 04c7 488B7424 		movq	24(%rsp), %rsi
 777      18
 778 04cc F30F1004 		movss	(%rsp), %xmm0
 778      24
 779 04d1 0F85E0FE 		jne	.L57
 779      FFFF
 780 04d7 EBC7     		jmp	.L58
 781              		.cfi_endproc
 782              	.LFE33:
 783              		.size	heatmap_render_saturated_to, .-heatmap_render_saturated_to
 784 04d9 0F1F8000 		.p2align 4,,15
 784      000000
 785              	.globl heatmap_render_to
 786              		.type	heatmap_render_to, @function
 787              	heatmap_render_to:
 788              	.LFB32:
 228:heatmap_block.c **** {
 789              		.loc 1 228 0
 790              		.cfi_startproc
 791              	.LVL71:
 236:heatmap_block.c ****     return heatmap_render_saturated_to(h, colorscheme, h->max > 0.0f ? h->max : 1.0f, colorbuf);
 792              		.loc 1 236 0
 793 04e0 0F57C9   		xorps	%xmm1, %xmm1
GAS LISTING /tmp/ccK2IhnQ.s 			page 25


 794 04e3 F30F1047 		movss	8(%rdi), %xmm0
 794      08
 795 04e8 0F28D0   		movaps	%xmm0, %xmm2
 796 04eb F30FC2C8 		cmpltss	%xmm0, %xmm1
 796      01
 797 04f0 F30F1005 		movss	.LC3(%rip), %xmm0
 797      00000000 
 798 04f8 0F54D1   		andps	%xmm1, %xmm2
 799 04fb 0F55C8   		andnps	%xmm0, %xmm1
 800 04fe 0F28C1   		movaps	%xmm1, %xmm0
 801 0501 0F56C2   		orps	%xmm2, %xmm0
 802 0504 E9000000 		jmp	heatmap_render_saturated_to@PLT
 802      00
 803              		.cfi_endproc
 804              	.LFE32:
 805              		.size	heatmap_render_to, .-heatmap_render_to
 806 0509 0F1F8000 		.p2align 4,,15
 806      000000
 807              	.globl heatmap_render_default_to
 808              		.type	heatmap_render_default_to, @function
 809              	heatmap_render_default_to:
 810              	.LFB31:
 223:heatmap_block.c **** {
 811              		.loc 1 223 0
 812              		.cfi_startproc
 813              	.LVL72:
 224:heatmap_block.c ****     return heatmap_render_to(h, heatmap_cs_default, colorbuf);
 814              		.loc 1 224 0
 815 0510 488B0500 		movq	heatmap_cs_default@GOTPCREL(%rip), %rax
 815      000000
 223:heatmap_block.c **** {
 816              		.loc 1 223 0
 817 0517 4889F2   		movq	%rsi, %rdx
 224:heatmap_block.c ****     return heatmap_render_to(h, heatmap_cs_default, colorbuf);
 818              		.loc 1 224 0
 819 051a 488B30   		movq	(%rax), %rsi
 820              	.LVL73:
 821 051d E9000000 		jmp	heatmap_render_to@PLT
 821      00
 822              		.cfi_endproc
 823              	.LFE31:
 824              		.size	heatmap_render_default_to, .-heatmap_render_default_to
 825 0522 66666666 		.p2align 4,,15
 825      662E0F1F 
 825      84000000 
 825      0000
 826              	.globl heatmap_stamp_init
 827              		.type	heatmap_stamp_init, @function
 828              	heatmap_stamp_init:
 829              	.LFB34:
 287:heatmap_block.c **** {
 830              		.loc 1 287 0
 831              		.cfi_startproc
 832              	.LVL74:
 288:heatmap_block.c ****     if(stamp) {
 833              		.loc 1 288 0
 834 0530 4885FF   		testq	%rdi, %rdi
GAS LISTING /tmp/ccK2IhnQ.s 			page 26


 835 0533 7409     		je	.L82
 290:heatmap_block.c ****         stamp->w = w;
 836              		.loc 1 290 0
 837 0535 897708   		movl	%esi, 8(%rdi)
 291:heatmap_block.c ****         stamp->h = h;
 838              		.loc 1 291 0
 839 0538 89570C   		movl	%edx, 12(%rdi)
 292:heatmap_block.c ****         stamp->buf = data;
 840              		.loc 1 292 0
 841 053b 48890F   		movq	%rcx, (%rdi)
 842              	.L82:
 843 053e F3       		rep
 844 053f C3       		ret
 845              		.cfi_endproc
 846              	.LFE34:
 847              		.size	heatmap_stamp_init, .-heatmap_stamp_init
 848              		.p2align 4,,15
 849              	.globl heatmap_stamp_new_with
 850              		.type	heatmap_stamp_new_with, @function
 851              	heatmap_stamp_new_with:
 852              	.LFB35:
 297:heatmap_block.c **** {
 853              		.loc 1 297 0
 854              		.cfi_startproc
 855              	.LVL75:
 856 0540 48895C24 		movq	%rbx, -32(%rsp)
 856      E0
 857 0545 48896C24 		movq	%rbp, -24(%rsp)
 857      E8
 858 054a 89FB     		movl	%edi, %ebx
 859              		.cfi_offset 6, -32
 860              		.cfi_offset 3, -40
 861 054c 4C896424 		movq	%r12, -16(%rsp)
 861      F0
 862 0551 4C896C24 		movq	%r13, -8(%rsp)
 862      F8
 863 0556 4189F4   		movl	%esi, %r12d
 864              		.cfi_offset 13, -16
 865              		.cfi_offset 12, -24
 866 0559 4883EC28 		subq	$40, %rsp
 867              		.cfi_def_cfa_offset 48
 297:heatmap_block.c **** {
 868              		.loc 1 297 0
 869 055d 4989D5   		movq	%rdx, %r13
 298:heatmap_block.c ****     heatmap_stamp_t* stamp = (heatmap_stamp_t*)malloc(sizeof(heatmap_stamp_t));
 870              		.loc 1 298 0
 871 0560 BF100000 		movl	$16, %edi
 871      00
 872              	.LVL76:
 873 0565 E8000000 		call	malloc@PLT
 873      00
 874              	.LVL77:
 299:heatmap_block.c ****     heatmap_stamp_init(stamp, w, h, data);
 875              		.loc 1 299 0
 876 056a 4C89E9   		movq	%r13, %rcx
 298:heatmap_block.c ****     heatmap_stamp_t* stamp = (heatmap_stamp_t*)malloc(sizeof(heatmap_stamp_t));
 877              		.loc 1 298 0
GAS LISTING /tmp/ccK2IhnQ.s 			page 27


 878 056d 4889C5   		movq	%rax, %rbp
 879              	.LVL78:
 299:heatmap_block.c ****     heatmap_stamp_init(stamp, w, h, data);
 880              		.loc 1 299 0
 881 0570 4489E2   		movl	%r12d, %edx
 882 0573 89DE     		movl	%ebx, %esi
 883 0575 4889C7   		movq	%rax, %rdi
 884 0578 E8000000 		call	heatmap_stamp_init@PLT
 884      00
 885              	.LVL79:
 301:heatmap_block.c **** }
 886              		.loc 1 301 0
 887 057d 4889E8   		movq	%rbp, %rax
 888 0580 488B5C24 		movq	8(%rsp), %rbx
 888      08
 889              	.LVL80:
 890 0585 488B6C24 		movq	16(%rsp), %rbp
 890      10
 891              	.LVL81:
 892 058a 4C8B6424 		movq	24(%rsp), %r12
 892      18
 893              	.LVL82:
 894 058f 4C8B6C24 		movq	32(%rsp), %r13
 894      20
 895              	.LVL83:
 896 0594 4883C428 		addq	$40, %rsp
 897              		.cfi_def_cfa_offset 8
 898 0598 C3       		ret
 899              		.cfi_endproc
 900              	.LFE35:
 901              		.size	heatmap_stamp_new_with, .-heatmap_stamp_new_with
 902 0599 0F1F8000 		.p2align 4,,15
 902      000000
 903              	.globl heatmap_stamp_gen_nonlinear
 904              		.type	heatmap_stamp_gen_nonlinear, @function
 905              	heatmap_stamp_gen_nonlinear:
 906              	.LFB39:
 321:heatmap_block.c **** {
 907              		.loc 1 321 0
 908              		.cfi_startproc
 909              	.LVL84:
 910 05a0 4157     		pushq	%r15
 911              		.cfi_def_cfa_offset 16
 912              		.cfi_offset 15, -16
 913 05a2 4156     		pushq	%r14
 914              		.cfi_def_cfa_offset 24
 915              		.cfi_offset 14, -24
 916 05a4 4155     		pushq	%r13
 917              		.cfi_def_cfa_offset 32
 918              		.cfi_offset 13, -32
 919 05a6 4154     		pushq	%r12
 920              		.cfi_def_cfa_offset 40
 921              		.cfi_offset 12, -40
 922 05a8 4989F4   		movq	%rsi, %r12
 325:heatmap_block.c ****     float* stamp = (float*)calloc(d*d, sizeof(float));
 923              		.loc 1 325 0
 924 05ab BE040000 		movl	$4, %esi
GAS LISTING /tmp/ccK2IhnQ.s 			page 28


 924      00
 925              	.LVL85:
 321:heatmap_block.c **** {
 926              		.loc 1 321 0
 927 05b0 55       		pushq	%rbp
 928              		.cfi_def_cfa_offset 48
 929              		.cfi_offset 6, -48
 930 05b1 89FD     		movl	%edi, %ebp
 931 05b3 53       		pushq	%rbx
 932              		.cfi_def_cfa_offset 56
 933              		.cfi_offset 3, -56
 323:heatmap_block.c ****     unsigned d = 2*r+1;
 934              		.loc 1 323 0
 935 05b4 8D5C2D01 		leal	1(%rbp,%rbp), %ebx
 936              	.LVL86:
 325:heatmap_block.c ****     float* stamp = (float*)calloc(d*d, sizeof(float));
 937              		.loc 1 325 0
 938 05b8 89DF     		movl	%ebx, %edi
 939              	.LVL87:
 321:heatmap_block.c **** {
 940              		.loc 1 321 0
 941 05ba 4883EC28 		subq	$40, %rsp
 942              		.cfi_def_cfa_offset 96
 325:heatmap_block.c ****     float* stamp = (float*)calloc(d*d, sizeof(float));
 943              		.loc 1 325 0
 944 05be 0FAFFB   		imull	%ebx, %edi
 945 05c1 E8000000 		call	calloc@PLT
 945      00
 326:heatmap_block.c ****     if(!stamp)
 946              		.loc 1 326 0
 947 05c6 4885C0   		testq	%rax, %rax
 325:heatmap_block.c ****     float* stamp = (float*)calloc(d*d, sizeof(float));
 948              		.loc 1 325 0
 949 05c9 48894424 		movq	%rax, 24(%rsp)
 949      18
 950              	.LVL88:
 326:heatmap_block.c ****     if(!stamp)
 951              		.loc 1 326 0
 952 05ce 0F84C600 		je	.L103
 952      0000
 953              	.LVL89:
 329:heatmap_block.c ****     for(y = 0 ; y < d ; ++y) {
 954              		.loc 1 329 0
 955 05d4 85DB     		testl	%ebx, %ebx
 956 05d6 0F84A200 		je	.L88
 956      0000
 957 05dc 8D4501   		leal	1(%rbp), %eax
 958              	.LVL90:
 959 05df C7442414 		movl	$0, 20(%rsp)
 959      00000000 
 960 05e7 C7442410 		movl	$0, 16(%rsp)
 960      00000000 
 961              	.LBB16:
 962              	.LBB17:
 334:heatmap_block.c ****             const float ds = (*distshape)(dist);
 963              		.loc 1 334 0
 964 05ef F3480F2A 		cvtsi2ssq	%rax, %xmm0
GAS LISTING /tmp/ccK2IhnQ.s 			page 29


 964      C0
 965 05f4 F30F1144 		movss	%xmm0, 12(%rsp)
 965      240C
 966              	.LVL91:
 967 05fa 660F1F44 		.p2align 4,,10
 967      0000
 968              		.p2align 3
 969              	.L99:
 970              	.LBE17:
 330:heatmap_block.c ****         float* line = stamp + y*d;
 971              		.loc 1 330 0
 972 0600 8B4C2414 		mov	20(%rsp), %ecx
 973 0604 448B7C24 		movl	16(%rsp), %r15d
 973      10
 974 0609 4531ED   		xorl	%r13d, %r13d
 975 060c 488B4424 		movq	24(%rsp), %rax
 975      18
 976 0611 4129EF   		subl	%ebp, %r15d
 977 0614 4C8D3488 		leaq	(%rax,%rcx,4), %r14
 978              	.LVL92:
 979 0618 450FAFFF 		imull	%r15d, %r15d
 980 061c EB06     		jmp	.L98
 981              	.LVL93:
 982 061e 6690     		.p2align 4,,10
 983              		.p2align 3
 984              	.L104:
 332:heatmap_block.c ****         for(x = 0 ; x < d ; ++x, ++line) {
 985              		.loc 1 332 0
 986 0620 4983C604 		addq	$4, %r14
 987              	.LVL94:
 988              	.L98:
 330:heatmap_block.c ****         float* line = stamp + y*d;
 989              		.loc 1 330 0
 990 0624 4489E9   		movl	%r13d, %ecx
 991 0627 29E9     		subl	%ebp, %ecx
 992              	.LBB18:
 333:heatmap_block.c ****             const float dist = sqrtf((float)((x-r)*(x-r) + (y-r)*(y-r)))/(float)(r+1);
 993              		.loc 1 333 0
 994 0629 0FAFC9   		imull	%ecx, %ecx
 995 062c 4401F9   		addl	%r15d, %ecx
 996 062f F3480F2A 		cvtsi2ssq	%rcx, %xmm0
 996      C1
 997 0634 F30F51C0 		sqrtss	%xmm0, %xmm0
 334:heatmap_block.c ****             const float ds = (*distshape)(dist);
 998              		.loc 1 334 0
 999 0638 F30F5E44 		divss	12(%rsp), %xmm0
 999      240C
 1000 063e 41FFD4   		call	*%r12
 1001              	.LVL95:
 338:heatmap_block.c ****                                    :             ds;
 1002              		.loc 1 338 0
 1003 0641 F30F100D 		movss	.LC3(%rip), %xmm1
 1003      00000000 
 1004 0649 0F2EC1   		ucomiss	%xmm1, %xmm0
 1005 064c 7707     		ja	.L95
 1006 064e 0F57C9   		xorps	%xmm1, %xmm1
 1007 0651 F30F5FC8 		maxss	%xmm0, %xmm1
GAS LISTING /tmp/ccK2IhnQ.s 			page 30


 1008              	.L95:
 1009              	.LVL96:
 339:heatmap_block.c ****             *line = 1.0f - clamped_ds;
 1010              		.loc 1 339 0
 1011 0655 F30F1005 		movss	.LC3(%rip), %xmm0
 1011      00000000 
 1012              	.LVL97:
 1013              	.LBE18:
 332:heatmap_block.c ****         for(x = 0 ; x < d ; ++x, ++line) {
 1014              		.loc 1 332 0
 1015 065d 4183C501 		addl	$1, %r13d
 1016              	.LVL98:
 1017              	.LBB19:
 339:heatmap_block.c ****             *line = 1.0f - clamped_ds;
 1018              		.loc 1 339 0
 1019 0661 F30F5CC1 		subss	%xmm1, %xmm0
 1020              	.LBE19:
 332:heatmap_block.c ****         for(x = 0 ; x < d ; ++x, ++line) {
 1021              		.loc 1 332 0
 1022 0665 4439EB   		cmpl	%r13d, %ebx
 1023              	.LBB20:
 339:heatmap_block.c ****             *line = 1.0f - clamped_ds;
 1024              		.loc 1 339 0
 1025 0668 F3410F11 		movss	%xmm0, (%r14)
 1025      06
 1026              	.LBE20:
 332:heatmap_block.c ****         for(x = 0 ; x < d ; ++x, ++line) {
 1027              		.loc 1 332 0
 1028 066d 77B1     		ja	.L104
 1029              	.LBE16:
 329:heatmap_block.c ****     for(y = 0 ; y < d ; ++y) {
 1030              		.loc 1 329 0
 1031 066f 83442410 		addl	$1, 16(%rsp)
 1031      01
 1032              	.LVL99:
 1033 0674 015C2414 		addl	%ebx, 20(%rsp)
 1034 0678 3B5C2410 		cmpl	16(%rsp), %ebx
 1035 067c 7782     		ja	.L99
 1036              	.LVL100:
 1037              	.L88:
 343:heatmap_block.c ****     return heatmap_stamp_new_with(d, d, stamp);
 1038              		.loc 1 343 0
 1039 067e 488B5424 		movq	24(%rsp), %rdx
 1039      18
 1040 0683 89DE     		movl	%ebx, %esi
 344:heatmap_block.c **** }
 1041              		.loc 1 344 0
 1042 0685 4883C428 		addq	$40, %rsp
 1043              		.cfi_remember_state
 1044              		.cfi_def_cfa_offset 56
 343:heatmap_block.c ****     return heatmap_stamp_new_with(d, d, stamp);
 1045              		.loc 1 343 0
 1046 0689 89DF     		movl	%ebx, %edi
 344:heatmap_block.c **** }
 1047              		.loc 1 344 0
 1048 068b 5B       		popq	%rbx
 1049              		.cfi_def_cfa_offset 48
GAS LISTING /tmp/ccK2IhnQ.s 			page 31


 1050              	.LVL101:
 1051 068c 5D       		popq	%rbp
 1052              		.cfi_def_cfa_offset 40
 1053              	.LVL102:
 1054 068d 415C     		popq	%r12
 1055              		.cfi_def_cfa_offset 32
 1056              	.LVL103:
 1057 068f 415D     		popq	%r13
 1058              		.cfi_def_cfa_offset 24
 1059 0691 415E     		popq	%r14
 1060              		.cfi_def_cfa_offset 16
 1061 0693 415F     		popq	%r15
 1062              		.cfi_def_cfa_offset 8
 343:heatmap_block.c ****     return heatmap_stamp_new_with(d, d, stamp);
 1063              		.loc 1 343 0
 1064 0695 E9000000 		jmp	heatmap_stamp_new_with@PLT
 1064      00
 1065              	.LVL104:
 1066              	.L103:
 1067              		.cfi_restore_state
 344:heatmap_block.c **** }
 1068              		.loc 1 344 0
 1069 069a 4883C428 		addq	$40, %rsp
 1070              		.cfi_def_cfa_offset 56
 1071 069e 5B       		popq	%rbx
 1072              		.cfi_def_cfa_offset 48
 1073              	.LVL105:
 1074 069f 5D       		popq	%rbp
 1075              		.cfi_def_cfa_offset 40
 1076              	.LVL106:
 1077 06a0 415C     		popq	%r12
 1078              		.cfi_def_cfa_offset 32
 1079              	.LVL107:
 1080 06a2 415D     		popq	%r13
 1081              		.cfi_def_cfa_offset 24
 1082 06a4 415E     		popq	%r14
 1083              		.cfi_def_cfa_offset 16
 1084 06a6 415F     		popq	%r15
 1085              		.cfi_def_cfa_offset 8
 1086 06a8 C3       		ret
 1087              		.cfi_endproc
 1088              	.LFE39:
 1089              		.size	heatmap_stamp_gen_nonlinear, .-heatmap_stamp_gen_nonlinear
 1090 06a9 0F1F8000 		.p2align 4,,15
 1090      000000
 1091              	.globl heatmap_stamp_gen
 1092              		.type	heatmap_stamp_gen, @function
 1093              	heatmap_stamp_gen:
 1094              	.LFB38:
 316:heatmap_block.c **** {
 1095              		.loc 1 316 0
 1096              		.cfi_startproc
 1097              	.LVL108:
 317:heatmap_block.c ****     return heatmap_stamp_gen_nonlinear(r, linear_dist);
 1098              		.loc 1 317 0
 1099 06b0 488D35C9 		leaq	linear_dist(%rip), %rsi
 1099      FBFFFF
GAS LISTING /tmp/ccK2IhnQ.s 			page 32


 1100 06b7 E9000000 		jmp	heatmap_stamp_gen_nonlinear@PLT
 1100      00
 1101              		.cfi_endproc
 1102              	.LFE38:
 1103              		.size	heatmap_stamp_gen, .-heatmap_stamp_gen
 1104 06bc 0F1F4000 		.p2align 4,,15
 1105              	.globl heatmap_stamp_load
 1106              		.type	heatmap_stamp_load, @function
 1107              	heatmap_stamp_load:
 1108              	.LFB36:
 304:heatmap_block.c **** {
 1109              		.loc 1 304 0
 1110              		.cfi_startproc
 1111              	.LVL109:
 1112 06c0 4C897424 		movq	%r14, -8(%rsp)
 1112      F8
 305:heatmap_block.c ****     float* copy = (float*)malloc(sizeof(float)*w*h);
 1113              		.loc 1 305 0
 1114 06c5 4189FE   		mov	%edi, %r14d
 1115              		.cfi_offset 14, -16
 1116 06c8 89F0     		mov	%esi, %eax
 1117 06ca 49C1E602 		salq	$2, %r14
 304:heatmap_block.c **** {
 1118              		.loc 1 304 0
 1119 06ce 48895C24 		movq	%rbx, -40(%rsp)
 1119      D8
 1120 06d3 48896C24 		movq	%rbp, -32(%rsp)
 1120      E0
 305:heatmap_block.c ****     float* copy = (float*)malloc(sizeof(float)*w*h);
 1121              		.loc 1 305 0
 1122 06d8 4C0FAFF0 		imulq	%rax, %r14
 304:heatmap_block.c **** {
 1123              		.loc 1 304 0
 1124 06dc 4C896424 		movq	%r12, -24(%rsp)
 1124      E8
 1125 06e1 4C896C24 		movq	%r13, -16(%rsp)
 1125      F0
 1126 06e6 89FB     		movl	%edi, %ebx
 1127              		.cfi_offset 13, -24
 1128              		.cfi_offset 12, -32
 1129              		.cfi_offset 6, -40
 1130              		.cfi_offset 3, -48
 1131 06e8 4883EC28 		subq	$40, %rsp
 1132              		.cfi_def_cfa_offset 48
 304:heatmap_block.c **** {
 1133              		.loc 1 304 0
 1134 06ec 4989D5   		movq	%rdx, %r13
 1135 06ef 89F5     		movl	%esi, %ebp
 305:heatmap_block.c ****     float* copy = (float*)malloc(sizeof(float)*w*h);
 1136              		.loc 1 305 0
 1137 06f1 4C89F7   		movq	%r14, %rdi
 1138              	.LVL110:
 1139 06f4 E8000000 		call	malloc@PLT
 1139      00
 1140              	.LVL111:
 306:heatmap_block.c ****     memcpy(copy, data, sizeof(float)*w*h);
 1141              		.loc 1 306 0
GAS LISTING /tmp/ccK2IhnQ.s 			page 33


 1142 06f9 4C89F2   		movq	%r14, %rdx
 305:heatmap_block.c ****     float* copy = (float*)malloc(sizeof(float)*w*h);
 1143              		.loc 1 305 0
 1144 06fc 4989C4   		movq	%rax, %r12
 1145              	.LVL112:
 306:heatmap_block.c ****     memcpy(copy, data, sizeof(float)*w*h);
 1146              		.loc 1 306 0
 1147 06ff 4C89EE   		movq	%r13, %rsi
 1148 0702 4889C7   		movq	%rax, %rdi
 1149 0705 E8000000 		call	memcpy@PLT
 1149      00
 1150              	.LVL113:
 307:heatmap_block.c ****     return heatmap_stamp_new_with(w, h, copy);
 1151              		.loc 1 307 0
 1152 070a 4C89E2   		movq	%r12, %rdx
 1153 070d 89EE     		movl	%ebp, %esi
 1154 070f 89DF     		movl	%ebx, %edi
 308:heatmap_block.c **** }
 1155              		.loc 1 308 0
 1156 0711 488B6C24 		movq	8(%rsp), %rbp
 1156      08
 1157              	.LVL114:
 1158 0716 488B1C24 		movq	(%rsp), %rbx
 1159              	.LVL115:
 1160 071a 4C8B6424 		movq	16(%rsp), %r12
 1160      10
 1161              	.LVL116:
 1162 071f 4C8B6C24 		movq	24(%rsp), %r13
 1162      18
 1163              	.LVL117:
 1164 0724 4C8B7424 		movq	32(%rsp), %r14
 1164      20
 1165 0729 4883C428 		addq	$40, %rsp
 1166              		.cfi_def_cfa_offset 8
 307:heatmap_block.c ****     return heatmap_stamp_new_with(w, h, copy);
 1167              		.loc 1 307 0
 1168 072d E9000000 		jmp	heatmap_stamp_new_with@PLT
 1168      00
 1169              		.cfi_endproc
 1170              	.LFE36:
 1171              		.size	heatmap_stamp_load, .-heatmap_stamp_load
 1172 0732 66666666 		.p2align 4,,15
 1172      662E0F1F 
 1172      84000000 
 1172      0000
 1173              	.globl heatmap_init
 1174              		.type	heatmap_init, @function
 1175              	heatmap_init:
 1176              	.LFB22:
  55:heatmap_block.c **** {
 1177              		.loc 1 55 0
 1178              		.cfi_startproc
 1179              	.LVL118:
 1180 0740 48895C24 		movq	%rbx, -24(%rsp)
 1180      E8
 1181 0745 48896C24 		movq	%rbp, -16(%rsp)
 1181      F0
GAS LISTING /tmp/ccK2IhnQ.s 			page 34


 1182 074a 4889FB   		movq	%rdi, %rbx
 1183              		.cfi_offset 6, -24
 1184              		.cfi_offset 3, -32
 1185 074d 4C896424 		movq	%r12, -8(%rsp)
 1185      F8
 1186 0752 4883EC18 		subq	$24, %rsp
 1187              		.cfi_def_cfa_offset 32
 1188              		.cfi_offset 12, -16
  56:heatmap_block.c ****     memset(hm, 0, sizeof(heatmap_t));
 1189              		.loc 1 56 0
 1190 0756 48C70700 		movq	$0, (%rdi)
 1190      000000
 1191 075d 48C74708 		movq	$0, 8(%rdi)
 1191      00000000 
 1192 0765 48C74710 		movq	$0, 16(%rdi)
 1192      00000000 
  57:heatmap_block.c ****     hm->buf = (float*)calloc(w*h, sizeof(float));
 1193              		.loc 1 57 0
 1194 076d 89D7     		movl	%edx, %edi
 1195              	.LVL119:
 1196 076f 0FAFFE   		imull	%esi, %edi
  55:heatmap_block.c **** {
 1197              		.loc 1 55 0
 1198 0772 89F5     		movl	%esi, %ebp
 1199 0774 4189D4   		movl	%edx, %r12d
  57:heatmap_block.c ****     hm->buf = (float*)calloc(w*h, sizeof(float));
 1200              		.loc 1 57 0
 1201 0777 BE040000 		movl	$4, %esi
 1201      00
 1202              	.LVL120:
 1203 077c E8000000 		call	calloc@PLT
 1203      00
 1204              	.LVL121:
  58:heatmap_block.c ****     hm->w = w;
 1205              		.loc 1 58 0
 1206 0781 896B0C   		movl	%ebp, 12(%rbx)
  59:heatmap_block.c ****     hm->h = h;
 1207              		.loc 1 59 0
 1208 0784 44896310 		movl	%r12d, 16(%rbx)
  57:heatmap_block.c ****     hm->buf = (float*)calloc(w*h, sizeof(float));
 1209              		.loc 1 57 0
 1210 0788 488903   		movq	%rax, (%rbx)
  60:heatmap_block.c **** }
 1211              		.loc 1 60 0
 1212 078b 488B6C24 		movq	8(%rsp), %rbp
 1212      08
 1213              	.LVL122:
 1214 0790 488B1C24 		movq	(%rsp), %rbx
 1215              	.LVL123:
 1216 0794 4C8B6424 		movq	16(%rsp), %r12
 1216      10
 1217              	.LVL124:
 1218 0799 4883C418 		addq	$24, %rsp
 1219              		.cfi_def_cfa_offset 8
 1220 079d C3       		ret
 1221              		.cfi_endproc
 1222              	.LFE22:
GAS LISTING /tmp/ccK2IhnQ.s 			page 35


 1223              		.size	heatmap_init, .-heatmap_init
 1224 079e 6690     		.p2align 4,,15
 1225              	.globl heatmap_new
 1226              		.type	heatmap_new, @function
 1227              	heatmap_new:
 1228              	.LFB23:
  63:heatmap_block.c **** {
 1229              		.loc 1 63 0
 1230              		.cfi_startproc
 1231              	.LVL125:
 1232 07a0 48895C24 		movq	%rbx, -24(%rsp)
 1232      E8
 1233 07a5 48896C24 		movq	%rbp, -16(%rsp)
 1233      F0
 1234 07aa 89FB     		movl	%edi, %ebx
 1235              		.cfi_offset 6, -24
 1236              		.cfi_offset 3, -32
 1237 07ac 4C896424 		movq	%r12, -8(%rsp)
 1237      F8
  64:heatmap_block.c ****     heatmap_t* hm = (heatmap_t*)malloc(sizeof(heatmap_t));
 1238              		.loc 1 64 0
 1239 07b1 BF180000 		movl	$24, %edi
 1239      00
 1240              	.LVL126:
  63:heatmap_block.c **** {
 1241              		.loc 1 63 0
 1242 07b6 4883EC18 		subq	$24, %rsp
 1243              		.cfi_def_cfa_offset 32
 1244              		.cfi_offset 12, -16
  63:heatmap_block.c **** {
 1245              		.loc 1 63 0
 1246 07ba 4189F4   		movl	%esi, %r12d
  64:heatmap_block.c ****     heatmap_t* hm = (heatmap_t*)malloc(sizeof(heatmap_t));
 1247              		.loc 1 64 0
 1248 07bd E8000000 		call	malloc@PLT
 1248      00
 1249              	.LVL127:
  65:heatmap_block.c ****     heatmap_init(hm, w, h);
 1250              		.loc 1 65 0
 1251 07c2 4489E2   		movl	%r12d, %edx
  64:heatmap_block.c ****     heatmap_t* hm = (heatmap_t*)malloc(sizeof(heatmap_t));
 1252              		.loc 1 64 0
 1253 07c5 4889C5   		movq	%rax, %rbp
 1254              	.LVL128:
  65:heatmap_block.c ****     heatmap_init(hm, w, h);
 1255              		.loc 1 65 0
 1256 07c8 89DE     		movl	%ebx, %esi
 1257 07ca 4889C7   		movq	%rax, %rdi
 1258 07cd E8000000 		call	heatmap_init@PLT
 1258      00
 1259              	.LVL129:
  67:heatmap_block.c **** }
 1260              		.loc 1 67 0
 1261 07d2 4889E8   		movq	%rbp, %rax
 1262 07d5 488B1C24 		movq	(%rsp), %rbx
 1263              	.LVL130:
 1264 07d9 488B6C24 		movq	8(%rsp), %rbp
GAS LISTING /tmp/ccK2IhnQ.s 			page 36


 1264      08
 1265              	.LVL131:
 1266 07de 4C8B6424 		movq	16(%rsp), %r12
 1266      10
 1267              	.LVL132:
 1268 07e3 4883C418 		addq	$24, %rsp
 1269              		.cfi_def_cfa_offset 8
 1270 07e7 C3       		ret
 1271              		.cfi_endproc
 1272              	.LFE23:
 1273              		.size	heatmap_new, .-heatmap_new
 1274 07e8 0F1F8400 		.p2align 4,,15
 1274      00000000 
 1275              		.type	heatmap_add_points_omp_with_stamp.omp_fn.0, @function
 1276              	heatmap_add_points_omp_with_stamp.omp_fn.0:
 1277              	.LFB43:
  88:heatmap_block.c ****     #pragma omp parallel
 1278              		.loc 1 88 0
 1279              		.cfi_startproc
 1280              	.LVL133:
 1281 07f0 4155     		pushq	%r13
 1282              		.cfi_def_cfa_offset 16
 1283              		.cfi_offset 13, -16
 1284 07f2 4154     		pushq	%r12
 1285              		.cfi_def_cfa_offset 24
 1286              		.cfi_offset 12, -24
 1287 07f4 55       		pushq	%rbp
 1288              		.cfi_def_cfa_offset 32
 1289              		.cfi_offset 6, -32
 1290 07f5 53       		pushq	%rbx
 1291              		.cfi_def_cfa_offset 40
 1292              		.cfi_offset 3, -40
 1293 07f6 4889FB   		movq	%rdi, %rbx
 1294 07f9 4883EC08 		subq	$8, %rsp
 1295              		.cfi_def_cfa_offset 48
  88:heatmap_block.c ****     #pragma omp parallel
 1296              		.loc 1 88 0
 1297 07fd 8B6F24   		movl	36(%rdi), %ebp
 1298              	.LVL134:
 1299              	.LBB21:
  90:heatmap_block.c ****         int idx = omp_get_thread_num();
 1300              		.loc 1 90 0
 1301 0800 E8000000 		call	omp_get_thread_num@PLT
 1301      00
 1302              	.LVL135:
  91:heatmap_block.c ****         unsigned start = idx * block_length;
 1303              		.loc 1 91 0
 1304 0805 4189C4   		movl	%eax, %r12d
  92:heatmap_block.c ****         unsigned end = start + block_length <= num_points ? start + block_length : num_points;
 1305              		.loc 1 92 0
 1306 0808 8B5320   		movl	32(%rbx), %edx
  94:heatmap_block.c ****         heatmap_init(&local_heatmap[idx], h->w, h->h);
 1307              		.loc 1 94 0
 1308 080b 4898     		cltq
 1309              	.LVL136:
  91:heatmap_block.c ****         unsigned start = idx * block_length;
 1310              		.loc 1 91 0
GAS LISTING /tmp/ccK2IhnQ.s 			page 37


 1311 080d 440FAFE5 		imull	%ebp, %r12d
 1312              	.LVL137:
  94:heatmap_block.c ****         heatmap_init(&local_heatmap[idx], h->w, h->h);
 1313              		.loc 1 94 0
 1314 0811 4C8D2C40 		leaq	(%rax,%rax,2), %r13
 1315 0815 488B0B   		movq	(%rbx), %rcx
  92:heatmap_block.c ****         unsigned end = start + block_length <= num_points ? start + block_length : num_points;
 1316              		.loc 1 92 0
 1317 0818 418D2C2C 		leal	(%r12,%rbp), %ebp
 1318              	.LVL138:
  94:heatmap_block.c ****         heatmap_init(&local_heatmap[idx], h->w, h->h);
 1319              		.loc 1 94 0
 1320 081c 8B710C   		movl	12(%rcx), %esi
  92:heatmap_block.c ****         unsigned end = start + block_length <= num_points ? start + block_length : num_points;
 1321              		.loc 1 92 0
 1322 081f 39D5     		cmpl	%edx, %ebp
 1323 0821 0F47EA   		cmova	%edx, %ebp
 1324              	.LVL139:
  94:heatmap_block.c ****         heatmap_init(&local_heatmap[idx], h->w, h->h);
 1325              		.loc 1 94 0
 1326 0824 49C1E503 		salq	$3, %r13
 1327 0828 8B5110   		movl	16(%rcx), %edx
 1328 082b 4C89EF   		movq	%r13, %rdi
 1329 082e 48037B18 		addq	24(%rbx), %rdi
 1330 0832 E8000000 		call	heatmap_init@PLT
 1330      00
 1331              	.LVL140:
  97:heatmap_block.c ****         for (i = start; i < end; i++)
 1332              		.loc 1 97 0
 1333 0837 4139EC   		cmpl	%ebp, %r12d
 1334 083a 734A     		jae	.L117
 100:heatmap_block.c ****             local_heatmap[idx].buf[ys[i] * h->w + xs[i]] += 1.0;
 1335              		.loc 1 100 0
 1336 083c 488B4318 		movq	24(%rbx), %rax
  97:heatmap_block.c ****         for (i = start; i < end; i++)
 1337              		.loc 1 97 0
 1338 0840 4C8B4310 		movq	16(%rbx), %r8
 1339 0844 488B7B08 		movq	8(%rbx), %rdi
 1340 0848 F30F100D 		movss	.LC3(%rip), %xmm1
 1340      00000000 
 100:heatmap_block.c ****             local_heatmap[idx].buf[ys[i] * h->w + xs[i]] += 1.0;
 1341              		.loc 1 100 0
 1342 0850 498B7405 		movq	0(%r13,%rax), %rsi
 1342      00
 1343 0855 488B03   		movq	(%rbx), %rax
 1344 0858 8B480C   		movl	12(%rax), %ecx
 1345              	.LVL141:
 1346 085b 0F1F4400 		.p2align 4,,10
 1346      00
 1347              		.p2align 3
 1348              	.L115:
 1349 0860 4489E0   		mov	%r12d, %eax
  97:heatmap_block.c ****         for (i = start; i < end; i++)
 1350              		.loc 1 97 0
 1351 0863 4183C401 		addl	$1, %r12d
 1352              	.LVL142:
 100:heatmap_block.c ****             local_heatmap[idx].buf[ys[i] * h->w + xs[i]] += 1.0;
GAS LISTING /tmp/ccK2IhnQ.s 			page 38


 1353              		.loc 1 100 0
 1354 0867 418B1480 		movl	(%r8,%rax,4), %edx
 1355 086b 0FAFD1   		imull	%ecx, %edx
 1356 086e 031487   		addl	(%rdi,%rax,4), %edx
  97:heatmap_block.c ****         for (i = start; i < end; i++)
 1357              		.loc 1 97 0
 1358 0871 4439E5   		cmpl	%r12d, %ebp
 100:heatmap_block.c ****             local_heatmap[idx].buf[ys[i] * h->w + xs[i]] += 1.0;
 1359              		.loc 1 100 0
 1360 0874 488D0496 		leaq	(%rsi,%rdx,4), %rax
 1361 0878 F30F1000 		movss	(%rax), %xmm0
 1362 087c F30F58C1 		addss	%xmm1, %xmm0
 1363 0880 F30F1100 		movss	%xmm0, (%rax)
  97:heatmap_block.c ****         for (i = start; i < end; i++)
 1364              		.loc 1 97 0
 1365 0884 77DA     		ja	.L115
 1366              	.L117:
 1367              	.LBE21:
  88:heatmap_block.c ****     #pragma omp parallel
 1368              		.loc 1 88 0
 1369 0886 4883C408 		addq	$8, %rsp
 1370              		.cfi_def_cfa_offset 40
 1371 088a 5B       		popq	%rbx
 1372              		.cfi_def_cfa_offset 32
 1373              	.LVL143:
 1374 088b 5D       		popq	%rbp
 1375              		.cfi_def_cfa_offset 24
 1376              	.LVL144:
 1377 088c 415C     		popq	%r12
 1378              		.cfi_def_cfa_offset 16
 1379              	.LVL145:
 1380 088e 415D     		popq	%r13
 1381              		.cfi_def_cfa_offset 8
 1382 0890 C3       		ret
 1383              		.cfi_endproc
 1384              	.LFE43:
 1385              		.size	heatmap_add_points_omp_with_stamp.omp_fn.0, .-heatmap_add_points_omp_with_stamp.omp_fn.0
 1386 0891 66666666 		.p2align 4,,15
 1386      66662E0F 
 1386      1F840000 
 1386      000000
 1387              	.globl heatmap_add_points_omp_with_stamp
 1388              		.type	heatmap_add_points_omp_with_stamp, @function
 1389              	heatmap_add_points_omp_with_stamp:
 1390              	.LFB26:
  82:heatmap_block.c **** {
 1391              		.loc 1 82 0
 1392              		.cfi_startproc
 1393              	.LVL146:
 1394 08a0 4156     		pushq	%r14
 1395              		.cfi_def_cfa_offset 16
 1396              		.cfi_offset 14, -16
 1397 08a2 4D89C6   		movq	%r8, %r14
 1398 08a5 4155     		pushq	%r13
 1399              		.cfi_def_cfa_offset 24
 1400              		.cfi_offset 13, -24
 1401 08a7 4189CD   		movl	%ecx, %r13d
GAS LISTING /tmp/ccK2IhnQ.s 			page 39


 1402              	.LVL147:
 1403 08aa 4154     		pushq	%r12
 1404              		.cfi_def_cfa_offset 32
 1405              		.cfi_offset 12, -32
 1406 08ac 4989D4   		movq	%rdx, %r12
 1407 08af 55       		pushq	%rbp
 1408              		.cfi_def_cfa_offset 40
 1409              		.cfi_offset 6, -40
 1410 08b0 4889F5   		movq	%rsi, %rbp
 1411 08b3 53       		pushq	%rbx
 1412              		.cfi_def_cfa_offset 48
 1413              		.cfi_offset 3, -48
 1414 08b4 4889FB   		movq	%rdi, %rbx
  87:heatmap_block.c ****     omp_set_num_threads(NUM_OF_BLOCKS);
 1415              		.loc 1 87 0
 1416 08b7 BF080000 		movl	$8, %edi
 1416      00
 1417              	.LVL148:
  82:heatmap_block.c **** {
 1418              		.loc 1 82 0
 1419 08bc 4881EC00 		subq	$256, %rsp
 1419      010000
 1420              		.cfi_def_cfa_offset 304
  87:heatmap_block.c ****     omp_set_num_threads(NUM_OF_BLOCKS);
 1421              		.loc 1 87 0
 1422 08c3 E8000000 		call	omp_set_num_threads@PLT
 1422      00
 1423              	.LVL149:
  88:heatmap_block.c ****     #pragma omp parallel
 1424              		.loc 1 88 0
 1425 08c8 418D4507 		leal	7(%r13), %eax
 1426 08cc 48899C24 		movq	%rbx, 208(%rsp)
 1426      D0000000 
 1427 08d4 488D9C24 		leaq	208(%rsp), %rbx
 1427      D0000000 
 1428              	.LVL150:
 1429 08dc 488D3D0D 		leaq	heatmap_add_points_omp_with_stamp.omp_fn.0(%rip), %rdi
 1429      FFFFFF
 1430 08e3 31D2     		xorl	%edx, %edx
 1431 08e5 4C89A424 		movq	%r12, 224(%rsp)
 1431      E0000000 
 1432 08ed C1E803   		shrl	$3, %eax
 1433 08f0 4889DE   		movq	%rbx, %rsi
 1434 08f3 4889AC24 		movq	%rbp, 216(%rsp)
 1434      D8000000 
 1435 08fb 898424F4 		movl	%eax, 244(%rsp)
 1435      000000
 1436 0902 488D4424 		leaq	16(%rsp), %rax
 1436      10
 1437 0907 4489AC24 		movl	%r13d, 240(%rsp)
 1437      F0000000 
 1438 090f 48898424 		movq	%rax, 232(%rsp)
 1438      E8000000 
 1439 0917 E8000000 		call	GOMP_parallel_start@PLT
 1439      00
 1440              	.LVL151:
 1441 091c 4889DF   		movq	%rbx, %rdi
GAS LISTING /tmp/ccK2IhnQ.s 			page 40


 1442 091f E8CCFEFF 		call	heatmap_add_points_omp_with_stamp.omp_fn.0
 1442      FF
 1443 0924 E8000000 		call	GOMP_parallel_end@PLT
 1443      00
 1444 0929 4C8BA424 		movq	208(%rsp), %r12
 1444      D0000000 
 1445              	.LVL152:
 107:heatmap_block.c ****     for (y = 0, i = 0; y < h->h; y++)
 1446              		.loc 1 107 0
 1447 0931 418B4424 		movl	16(%r12), %eax
 1447      10
 1448 0936 85C0     		testl	%eax, %eax
 1449 0938 0F84CF00 		je	.L127
 1449      0000
 1450 093e 418B4C24 		movl	12(%r12), %ecx
 1450      0C
 1451 0943 0F57C9   		xorps	%xmm1, %xmm1
 1452 0946 4531ED   		xorl	%r13d, %r13d
 1453              	.LVL153:
 1454 0949 31ED     		xorl	%ebp, %ebp
 1455              	.LVL154:
 1456 094b 0F1F4400 		.p2align 4,,10
 1456      00
 1457              		.p2align 3
 1458              	.L121:
 1459 0950 31DB     		xorl	%ebx, %ebx
 109:heatmap_block.c ****         for (x = 0; x < h->w; x++, i++)
 1460              		.loc 1 109 0
 1461 0952 85C9     		testl	%ecx, %ecx
 1462 0954 7518     		jne	.L124
 1463 0956 E9A50000 		jmp	.L126
 1463      00
 1464              	.LVL155:
 1465 095b 0F1F4400 		.p2align 4,,10
 1465      00
 1466              		.p2align 3
 1467              	.L122:
 1468 0960 83C301   		addl	$1, %ebx
 1469              	.LVL156:
 1470 0963 83C501   		addl	$1, %ebp
 1471              	.LVL157:
 1472 0966 39CB     		cmpl	%ecx, %ebx
 1473 0968 0F838D00 		jae	.L130
 1473      0000
 1474              	.LVL158:
 1475              	.L124:
 111:heatmap_block.c ****             w = local_heatmap[0].buf[i];
 1476              		.loc 1 111 0
 1477 096e 488B5424 		movq	16(%rsp), %rdx
 1477      10
 1478 0973 89E8     		mov	%ebp, %eax
 1479 0975 F30F1004 		movss	(%rdx,%rax,4), %xmm0
 1479      82
 1480              	.LVL159:
 114:heatmap_block.c ****                 w += local_heatmap[k].buf[i];
 1481              		.loc 1 114 0
 1482 097a 488B5424 		movq	40(%rsp), %rdx
GAS LISTING /tmp/ccK2IhnQ.s 			page 41


 1482      28
 1483 097f F30F5804 		addss	(%rdx,%rax,4), %xmm0
 1483      82
 1484              	.LVL160:
 1485 0984 488B5424 		movq	64(%rsp), %rdx
 1485      40
 1486 0989 F30F5804 		addss	(%rdx,%rax,4), %xmm0
 1486      82
 1487              	.LVL161:
 1488 098e 488B5424 		movq	88(%rsp), %rdx
 1488      58
 1489 0993 F30F5804 		addss	(%rdx,%rax,4), %xmm0
 1489      82
 1490              	.LVL162:
 1491 0998 488B5424 		movq	112(%rsp), %rdx
 1491      70
 1492 099d F30F5804 		addss	(%rdx,%rax,4), %xmm0
 1492      82
 1493              	.LVL163:
 1494 09a2 488B9424 		movq	136(%rsp), %rdx
 1494      88000000 
 1495 09aa F30F5804 		addss	(%rdx,%rax,4), %xmm0
 1495      82
 1496              	.LVL164:
 1497 09af 488B9424 		movq	160(%rsp), %rdx
 1497      A0000000 
 1498 09b7 F30F5804 		addss	(%rdx,%rax,4), %xmm0
 1498      82
 1499              	.LVL165:
 1500 09bc 488B9424 		movq	184(%rsp), %rdx
 1500      B8000000 
 1501 09c4 F30F5804 		addss	(%rdx,%rax,4), %xmm0
 1501      82
 1502              	.LVL166:
 117:heatmap_block.c ****             if (w > 0)
 1503              		.loc 1 117 0
 1504 09c9 0F2EC1   		ucomiss	%xmm1, %xmm0
 1505 09cc 7692     		jbe	.L122
 119:heatmap_block.c ****                 heatmap_add_weighted_point_with_stamp(h, x, y, w, stamp);
 1506              		.loc 1 119 0
 1507 09ce 4C89F1   		movq	%r14, %rcx
 1508 09d1 89DE     		movl	%ebx, %esi
 1509 09d3 4489EA   		movl	%r13d, %edx
 1510 09d6 4C89E7   		movq	%r12, %rdi
 1511 09d9 F30F110C 		movss	%xmm1, (%rsp)
 1511      24
 109:heatmap_block.c ****         for (x = 0; x < h->w; x++, i++)
 1512              		.loc 1 109 0
 1513 09de 83C301   		addl	$1, %ebx
 119:heatmap_block.c ****                 heatmap_add_weighted_point_with_stamp(h, x, y, w, stamp);
 1514              		.loc 1 119 0
 1515 09e1 E8000000 		call	heatmap_add_weighted_point_with_stamp@PLT
 1515      00
 1516              	.LVL167:
 1517 09e6 418B4C24 		movl	12(%r12), %ecx
 1517      0C
 109:heatmap_block.c ****         for (x = 0; x < h->w; x++, i++)
GAS LISTING /tmp/ccK2IhnQ.s 			page 42


 1518              		.loc 1 109 0
 1519 09eb 83C501   		addl	$1, %ebp
 1520              	.LVL168:
 119:heatmap_block.c ****                 heatmap_add_weighted_point_with_stamp(h, x, y, w, stamp);
 1521              		.loc 1 119 0
 1522 09ee F30F100C 		movss	(%rsp), %xmm1
 1522      24
 109:heatmap_block.c ****         for (x = 0; x < h->w; x++, i++)
 1523              		.loc 1 109 0
 1524 09f3 39CB     		cmpl	%ecx, %ebx
 1525 09f5 0F8273FF 		jb	.L124
 1525      FFFF
 1526              	.L130:
 1527 09fb 418B4424 		movl	16(%r12), %eax
 1527      10
 1528              	.LVL169:
 1529              	.L126:
 107:heatmap_block.c ****     for (y = 0, i = 0; y < h->h; y++)
 1530              		.loc 1 107 0
 1531 0a00 4183C501 		addl	$1, %r13d
 1532              	.LVL170:
 1533 0a04 4139C5   		cmpl	%eax, %r13d
 1534 0a07 0F8243FF 		jb	.L121
 1534      FFFF
 1535              	.LVL171:
 1536              	.L127:
 124:heatmap_block.c **** }
 1537              		.loc 1 124 0
 1538 0a0d 4881C400 		addq	$256, %rsp
 1538      010000
 1539              		.cfi_def_cfa_offset 48
 1540 0a14 5B       		popq	%rbx
 1541              		.cfi_def_cfa_offset 40
 1542 0a15 5D       		popq	%rbp
 1543              		.cfi_def_cfa_offset 32
 1544 0a16 415C     		popq	%r12
 1545              		.cfi_def_cfa_offset 24
 1546              	.LVL172:
 1547 0a18 415D     		popq	%r13
 1548              		.cfi_def_cfa_offset 16
 1549 0a1a 415E     		popq	%r14
 1550              		.cfi_def_cfa_offset 8
 1551              	.LVL173:
 1552 0a1c C3       		ret
 1553              		.cfi_endproc
 1554              	.LFE26:
 1555              		.size	heatmap_add_points_omp_with_stamp, .-heatmap_add_points_omp_with_stamp
 1556 0a1d 0F1F00   		.p2align 4,,15
 1557              	.globl heatmap_add_points_omp
 1558              		.type	heatmap_add_points_omp, @function
 1559              	heatmap_add_points_omp:
 1560              	.LFB25:
  77:heatmap_block.c **** {
 1561              		.loc 1 77 0
 1562              		.cfi_startproc
 1563              	.LVL174:
  78:heatmap_block.c ****     heatmap_add_points_omp_with_stamp(h, xs, ys, num_points, &stamp_default_4);
GAS LISTING /tmp/ccK2IhnQ.s 			page 43


 1564              		.loc 1 78 0
 1565 0a20 4C8D0500 		leaq	stamp_default_4(%rip), %r8
 1565      000000
 1566 0a27 E9000000 		jmp	heatmap_add_points_omp_with_stamp@PLT
 1566      00
 1567              		.cfi_endproc
 1568              	.LFE25:
 1569              		.size	heatmap_add_points_omp, .-heatmap_add_points_omp
 1570              	.globl heatmap_cs_default
 1571              		.section	.data.rel.local,"aw",@progbits
 1572              		.align 8
 1573              		.type	heatmap_cs_default, @object
 1574              		.size	heatmap_cs_default, 8
 1575              	heatmap_cs_default:
 1576 0000 00000000 		.quad	cs_spectral_mixed
 1576      00000000 
 1577 0008 00000000 		.align 16
 1577      00000000 
 1578              		.type	stamp_default_4, @object
 1579              		.size	stamp_default_4, 16
 1580              	stamp_default_4:
 1581 0010 00000000 		.quad	stamp_default_4_data
 1581      00000000 
 1582 0018 09000000 		.long	9
 1583 001c 09000000 		.long	9
 1584              		.section	.data.rel.ro.local,"aw",@progbits
 1585              		.align 16
 1586              		.type	cs_spectral_mixed, @object
 1587              		.size	cs_spectral_mixed, 16
 1588              	cs_spectral_mixed:
 1589 0000 00000000 		.quad	mixed_data
 1589      00000000 
 1590 0008 01040000 		.quad	1025
 1590      00000000 
 1591              		.data
 1592              		.align 32
 1593              		.type	stamp_default_4_data, @object
 1594              		.size	stamp_default_4_data, 324
 1595              	stamp_default_4_data:
 1596 0000 00000000 		.long	0
 1597 0004 00000000 		.long	0
 1598 0008 8D36D83D 		.long	1037579917
 1599 000c 8796333E 		.long	1043568263
 1600 0010 CDCC4C3E 		.long	1045220557
 1601 0014 8796333E 		.long	1043568263
 1602 0018 8D36D83D 		.long	1037579917
 1603 001c 00000000 		.long	0
 1604 0020 00000000 		.long	0
 1605 0024 00000000 		.long	0
 1606 0028 731B1B3E 		.long	1041963891
 1607 002c A1CA8E3E 		.long	1049545377
 1608 0030 CB2EBC3E 		.long	1052520139
 1609 0034 CDCCCC3E 		.long	1053609165
 1610 0038 CB2EBC3E 		.long	1052520139
 1611 003c A1CA8E3E 		.long	1049545377
 1612 0040 731B1B3E 		.long	1041963891
 1613 0044 00000000 		.long	0
GAS LISTING /tmp/ccK2IhnQ.s 			page 44


 1614 0048 8D36D83D 		.long	1037579917
 1615 004c A1CA8E3E 		.long	1049545377
 1616 0050 7C5EDE3E 		.long	1054760572
 1617 0054 69830D3F 		.long	1057850217
 1618 0058 9A99193F 		.long	1058642330
 1619 005c 69830D3F 		.long	1057850217
 1620 0060 7C5EDE3E 		.long	1054760572
 1621 0064 A1CA8E3E 		.long	1049545377
 1622 0068 8D36D83D 		.long	1037579917
 1623 006c 8796333E 		.long	1043568263
 1624 0070 CB2EBC3E 		.long	1052520139
 1625 0074 69830D3F 		.long	1057850217
 1626 0078 9F97373F 		.long	1060607903
 1627 007c CDCC4C3F 		.long	1061997773
 1628 0080 9F97373F 		.long	1060607903
 1629 0084 69830D3F 		.long	1057850217
 1630 0088 CB2EBC3E 		.long	1052520139
 1631 008c 8796333E 		.long	1043568263
 1632 0090 CDCC4C3E 		.long	1045220557
 1633 0094 CDCCCC3E 		.long	1053609165
 1634 0098 9A99193F 		.long	1058642330
 1635 009c CDCC4C3F 		.long	1061997773
 1636 00a0 0000803F 		.long	1065353216
 1637 00a4 CDCC4C3F 		.long	1061997773
 1638 00a8 9A99193F 		.long	1058642330
 1639 00ac CDCCCC3E 		.long	1053609165
 1640 00b0 CDCC4C3E 		.long	1045220557
 1641 00b4 8796333E 		.long	1043568263
 1642 00b8 CB2EBC3E 		.long	1052520139
 1643 00bc 69830D3F 		.long	1057850217
 1644 00c0 9F97373F 		.long	1060607903
 1645 00c4 CDCC4C3F 		.long	1061997773
 1646 00c8 9F97373F 		.long	1060607903
 1647 00cc 69830D3F 		.long	1057850217
 1648 00d0 CB2EBC3E 		.long	1052520139
 1649 00d4 8796333E 		.long	1043568263
 1650 00d8 8D36D83D 		.long	1037579917
 1651 00dc A1CA8E3E 		.long	1049545377
 1652 00e0 7C5EDE3E 		.long	1054760572
 1653 00e4 69830D3F 		.long	1057850217
 1654 00e8 9A99193F 		.long	1058642330
 1655 00ec 69830D3F 		.long	1057850217
 1656 00f0 7C5EDE3E 		.long	1054760572
 1657 00f4 A1CA8E3E 		.long	1049545377
 1658 00f8 8D36D83D 		.long	1037579917
 1659 00fc 00000000 		.long	0
 1660 0100 731B1B3E 		.long	1041963891
 1661 0104 A1CA8E3E 		.long	1049545377
 1662 0108 CB2EBC3E 		.long	1052520139
 1663 010c CDCCCC3E 		.long	1053609165
 1664 0110 CB2EBC3E 		.long	1052520139
 1665 0114 A1CA8E3E 		.long	1049545377
 1666 0118 731B1B3E 		.long	1041963891
 1667 011c 00000000 		.long	0
 1668 0120 00000000 		.long	0
 1669 0124 00000000 		.long	0
 1670 0128 8D36D83D 		.long	1037579917
GAS LISTING /tmp/ccK2IhnQ.s 			page 45


 1671 012c 8796333E 		.long	1043568263
 1672 0130 CDCC4C3E 		.long	1045220557
 1673 0134 8796333E 		.long	1043568263
 1674 0138 8D36D83D 		.long	1037579917
 1675 013c 00000000 		.long	0
 1676 0140 00000000 		.long	0
 1677              		.section	.rodata
 1678              		.align 32
 1679              		.type	mixed_data, @object
 1680              		.size	mixed_data, 4100
 1681              	mixed_data:
 1682 0000 00       		.byte	0
 1683 0001 00       		.byte	0
 1684 0002 00       		.byte	0
 1685 0003 00       		.byte	0
 1686 0004 5E       		.byte	94
 1687 0005 4F       		.byte	79
 1688 0006 A2       		.byte	-94
 1689 0007 00       		.byte	0
 1690 0008 5D       		.byte	93
 1691 0009 4F       		.byte	79
 1692 000a A2       		.byte	-94
 1693 000b 07       		.byte	7
 1694 000c 5D       		.byte	93
 1695 000d 50       		.byte	80
 1696 000e A2       		.byte	-94
 1697 000f 0E       		.byte	14
 1698 0010 5C       		.byte	92
 1699 0011 50       		.byte	80
 1700 0012 A3       		.byte	-93
 1701 0013 16       		.byte	22
 1702 0014 5C       		.byte	92
 1703 0015 51       		.byte	81
 1704 0016 A3       		.byte	-93
 1705 0017 1D       		.byte	29
 1706 0018 5B       		.byte	91
 1707 0019 51       		.byte	81
 1708 001a A4       		.byte	-92
 1709 001b 25       		.byte	37
 1710 001c 5B       		.byte	91
 1711 001d 52       		.byte	82
 1712 001e A4       		.byte	-92
 1713 001f 2C       		.byte	44
 1714 0020 5A       		.byte	90
 1715 0021 52       		.byte	82
 1716 0022 A4       		.byte	-92
 1717 0023 34       		.byte	52
 1718 0024 5A       		.byte	90
 1719 0025 53       		.byte	83
 1720 0026 A5       		.byte	-91
 1721 0027 3B       		.byte	59
 1722 0028 59       		.byte	89
 1723 0029 53       		.byte	83
 1724 002a A5       		.byte	-91
 1725 002b 43       		.byte	67
 1726 002c 59       		.byte	89
 1727 002d 54       		.byte	84
GAS LISTING /tmp/ccK2IhnQ.s 			page 46


 1728 002e A6       		.byte	-90
 1729 002f 4A       		.byte	74
 1730 0030 58       		.byte	88
 1731 0031 54       		.byte	84
 1732 0032 A6       		.byte	-90
 1733 0033 52       		.byte	82
 1734 0034 58       		.byte	88
 1735 0035 55       		.byte	85
 1736 0036 A6       		.byte	-90
 1737 0037 59       		.byte	89
 1738 0038 57       		.byte	87
 1739 0039 55       		.byte	85
 1740 003a A7       		.byte	-89
 1741 003b 61       		.byte	97
 1742 003c 57       		.byte	87
 1743 003d 56       		.byte	86
 1744 003e A7       		.byte	-89
 1745 003f 68       		.byte	104
 1746 0040 56       		.byte	86
 1747 0041 56       		.byte	86
 1748 0042 A7       		.byte	-89
 1749 0043 70       		.byte	112
 1750 0044 56       		.byte	86
 1751 0045 57       		.byte	87
 1752 0046 A8       		.byte	-88
 1753 0047 77       		.byte	119
 1754 0048 55       		.byte	85
 1755 0049 57       		.byte	87
 1756 004a A8       		.byte	-88
 1757 004b 7F       		.byte	127
 1758 004c 55       		.byte	85
 1759 004d 58       		.byte	88
 1760 004e A8       		.byte	-88
 1761 004f 86       		.byte	-122
 1762 0050 54       		.byte	84
 1763 0051 58       		.byte	88
 1764 0052 A9       		.byte	-87
 1765 0053 8D       		.byte	-115
 1766 0054 54       		.byte	84
 1767 0055 59       		.byte	89
 1768 0056 A9       		.byte	-87
 1769 0057 95       		.byte	-107
 1770 0058 53       		.byte	83
 1771 0059 59       		.byte	89
 1772 005a A9       		.byte	-87
 1773 005b 9C       		.byte	-100
 1774 005c 53       		.byte	83
 1775 005d 5A       		.byte	90
 1776 005e AA       		.byte	-86
 1777 005f A4       		.byte	-92
 1778 0060 53       		.byte	83
 1779 0061 5A       		.byte	90
 1780 0062 AA       		.byte	-86
 1781 0063 AB       		.byte	-85
 1782 0064 52       		.byte	82
 1783 0065 5B       		.byte	91
 1784 0066 AA       		.byte	-86
GAS LISTING /tmp/ccK2IhnQ.s 			page 47


 1785 0067 B3       		.byte	-77
 1786 0068 52       		.byte	82
 1787 0069 5B       		.byte	91
 1788 006a AB       		.byte	-85
 1789 006b BA       		.byte	-70
 1790 006c 51       		.byte	81
 1791 006d 5C       		.byte	92
 1792 006e AB       		.byte	-85
 1793 006f C2       		.byte	-62
 1794 0070 51       		.byte	81
 1795 0071 5C       		.byte	92
 1796 0072 AB       		.byte	-85
 1797 0073 C9       		.byte	-55
 1798 0074 50       		.byte	80
 1799 0075 5D       		.byte	93
 1800 0076 AC       		.byte	-84
 1801 0077 D1       		.byte	-47
 1802 0078 50       		.byte	80
 1803 0079 5D       		.byte	93
 1804 007a AC       		.byte	-84
 1805 007b D8       		.byte	-40
 1806 007c 4F       		.byte	79
 1807 007d 5E       		.byte	94
 1808 007e AC       		.byte	-84
 1809 007f E0       		.byte	-32
 1810 0080 4F       		.byte	79
 1811 0081 5E       		.byte	94
 1812 0082 AC       		.byte	-84
 1813 0083 E7       		.byte	-25
 1814 0084 4E       		.byte	78
 1815 0085 5F       		.byte	95
 1816 0086 AD       		.byte	-83
 1817 0087 EF       		.byte	-17
 1818 0088 4E       		.byte	78
 1819 0089 5F       		.byte	95
 1820 008a AD       		.byte	-83
 1821 008b F6       		.byte	-10
 1822 008c 4D       		.byte	77
 1823 008d 5F       		.byte	95
 1824 008e AD       		.byte	-83
 1825 008f FE       		.byte	-2
 1826 0090 4D       		.byte	77
 1827 0091 60       		.byte	96
 1828 0092 AE       		.byte	-82
 1829 0093 FF       		.byte	-1
 1830 0094 4C       		.byte	76
 1831 0095 60       		.byte	96
 1832 0096 AE       		.byte	-82
 1833 0097 FF       		.byte	-1
 1834 0098 4C       		.byte	76
 1835 0099 61       		.byte	97
 1836 009a AE       		.byte	-82
 1837 009b FF       		.byte	-1
 1838 009c 4B       		.byte	75
 1839 009d 61       		.byte	97
 1840 009e AE       		.byte	-82
 1841 009f FF       		.byte	-1
GAS LISTING /tmp/ccK2IhnQ.s 			page 48


 1842 00a0 4B       		.byte	75
 1843 00a1 62       		.byte	98
 1844 00a2 AF       		.byte	-81
 1845 00a3 FF       		.byte	-1
 1846 00a4 4A       		.byte	74
 1847 00a5 62       		.byte	98
 1848 00a6 AF       		.byte	-81
 1849 00a7 FF       		.byte	-1
 1850 00a8 4A       		.byte	74
 1851 00a9 63       		.byte	99
 1852 00aa AF       		.byte	-81
 1853 00ab FF       		.byte	-1
 1854 00ac 49       		.byte	73
 1855 00ad 63       		.byte	99
 1856 00ae AF       		.byte	-81
 1857 00af FF       		.byte	-1
 1858 00b0 49       		.byte	73
 1859 00b1 64       		.byte	100
 1860 00b2 B0       		.byte	-80
 1861 00b3 FF       		.byte	-1
 1862 00b4 48       		.byte	72
 1863 00b5 64       		.byte	100
 1864 00b6 B0       		.byte	-80
 1865 00b7 FF       		.byte	-1
 1866 00b8 48       		.byte	72
 1867 00b9 65       		.byte	101
 1868 00ba B0       		.byte	-80
 1869 00bb FF       		.byte	-1
 1870 00bc 48       		.byte	72
 1871 00bd 65       		.byte	101
 1872 00be B0       		.byte	-80
 1873 00bf FF       		.byte	-1
 1874 00c0 47       		.byte	71
 1875 00c1 65       		.byte	101
 1876 00c2 B0       		.byte	-80
 1877 00c3 FF       		.byte	-1
 1878 00c4 47       		.byte	71
 1879 00c5 66       		.byte	102
 1880 00c6 B1       		.byte	-79
 1881 00c7 FF       		.byte	-1
 1882 00c8 46       		.byte	70
 1883 00c9 66       		.byte	102
 1884 00ca B1       		.byte	-79
 1885 00cb FF       		.byte	-1
 1886 00cc 46       		.byte	70
 1887 00cd 67       		.byte	103
 1888 00ce B1       		.byte	-79
 1889 00cf FF       		.byte	-1
 1890 00d0 45       		.byte	69
 1891 00d1 67       		.byte	103
 1892 00d2 B1       		.byte	-79
 1893 00d3 FF       		.byte	-1
 1894 00d4 3C       		.byte	60
 1895 00d5 73       		.byte	115
 1896 00d6 B7       		.byte	-73
 1897 00d7 FF       		.byte	-1
 1898 00d8 3C       		.byte	60
GAS LISTING /tmp/ccK2IhnQ.s 			page 49


 1899 00d9 73       		.byte	115
 1900 00da B7       		.byte	-73
 1901 00db FF       		.byte	-1
 1902 00dc 3B       		.byte	59
 1903 00dd 74       		.byte	116
 1904 00de B7       		.byte	-73
 1905 00df FF       		.byte	-1
 1906 00e0 3B       		.byte	59
 1907 00e1 74       		.byte	116
 1908 00e2 B7       		.byte	-73
 1909 00e3 FF       		.byte	-1
 1910 00e4 3A       		.byte	58
 1911 00e5 75       		.byte	117
 1912 00e6 B8       		.byte	-72
 1913 00e7 FF       		.byte	-1
 1914 00e8 3A       		.byte	58
 1915 00e9 75       		.byte	117
 1916 00ea B8       		.byte	-72
 1917 00eb FF       		.byte	-1
 1918 00ec 3A       		.byte	58
 1919 00ed 76       		.byte	118
 1920 00ee B8       		.byte	-72
 1921 00ef FF       		.byte	-1
 1922 00f0 39       		.byte	57
 1923 00f1 76       		.byte	118
 1924 00f2 B8       		.byte	-72
 1925 00f3 FF       		.byte	-1
 1926 00f4 39       		.byte	57
 1927 00f5 76       		.byte	118
 1928 00f6 B8       		.byte	-72
 1929 00f7 FF       		.byte	-1
 1930 00f8 38       		.byte	56
 1931 00f9 77       		.byte	119
 1932 00fa B8       		.byte	-72
 1933 00fb FF       		.byte	-1
 1934 00fc 38       		.byte	56
 1935 00fd 77       		.byte	119
 1936 00fe B9       		.byte	-71
 1937 00ff FF       		.byte	-1
 1938 0100 38       		.byte	56
 1939 0101 78       		.byte	120
 1940 0102 B9       		.byte	-71
 1941 0103 FF       		.byte	-1
 1942 0104 37       		.byte	55
 1943 0105 78       		.byte	120
 1944 0106 B9       		.byte	-71
 1945 0107 FF       		.byte	-1
 1946 0108 37       		.byte	55
 1947 0109 79       		.byte	121
 1948 010a B9       		.byte	-71
 1949 010b FF       		.byte	-1
 1950 010c 37       		.byte	55
 1951 010d 79       		.byte	121
 1952 010e B9       		.byte	-71
 1953 010f FF       		.byte	-1
 1954 0110 36       		.byte	54
 1955 0111 79       		.byte	121
GAS LISTING /tmp/ccK2IhnQ.s 			page 50


 1956 0112 B9       		.byte	-71
 1957 0113 FF       		.byte	-1
 1958 0114 36       		.byte	54
 1959 0115 7A       		.byte	122
 1960 0116 BA       		.byte	-70
 1961 0117 FF       		.byte	-1
 1962 0118 36       		.byte	54
 1963 0119 7A       		.byte	122
 1964 011a BA       		.byte	-70
 1965 011b FF       		.byte	-1
 1966 011c 35       		.byte	53
 1967 011d 7B       		.byte	123
 1968 011e BA       		.byte	-70
 1969 011f FF       		.byte	-1
 1970 0120 35       		.byte	53
 1971 0121 7B       		.byte	123
 1972 0122 BA       		.byte	-70
 1973 0123 FF       		.byte	-1
 1974 0124 35       		.byte	53
 1975 0125 7C       		.byte	124
 1976 0126 BA       		.byte	-70
 1977 0127 FF       		.byte	-1
 1978 0128 34       		.byte	52
 1979 0129 7C       		.byte	124
 1980 012a BA       		.byte	-70
 1981 012b FF       		.byte	-1
 1982 012c 34       		.byte	52
 1983 012d 7C       		.byte	124
 1984 012e BA       		.byte	-70
 1985 012f FF       		.byte	-1
 1986 0130 34       		.byte	52
 1987 0131 7D       		.byte	125
 1988 0132 BA       		.byte	-70
 1989 0133 FF       		.byte	-1
 1990 0134 34       		.byte	52
 1991 0135 7D       		.byte	125
 1992 0136 BB       		.byte	-69
 1993 0137 FF       		.byte	-1
 1994 0138 33       		.byte	51
 1995 0139 7E       		.byte	126
 1996 013a BB       		.byte	-69
 1997 013b FF       		.byte	-1
 1998 013c 33       		.byte	51
 1999 013d 7E       		.byte	126
 2000 013e BB       		.byte	-69
 2001 013f FF       		.byte	-1
 2002 0140 33       		.byte	51
 2003 0141 7E       		.byte	126
 2004 0142 BB       		.byte	-69
 2005 0143 FF       		.byte	-1
 2006 0144 33       		.byte	51
 2007 0145 7F       		.byte	127
 2008 0146 BB       		.byte	-69
 2009 0147 FF       		.byte	-1
 2010 0148 32       		.byte	50
 2011 0149 7F       		.byte	127
 2012 014a BB       		.byte	-69
GAS LISTING /tmp/ccK2IhnQ.s 			page 51


 2013 014b FF       		.byte	-1
 2014 014c 32       		.byte	50
 2015 014d 80       		.byte	-128
 2016 014e BB       		.byte	-69
 2017 014f FF       		.byte	-1
 2018 0150 32       		.byte	50
 2019 0151 80       		.byte	-128
 2020 0152 BB       		.byte	-69
 2021 0153 FF       		.byte	-1
 2022 0154 32       		.byte	50
 2023 0155 80       		.byte	-128
 2024 0156 BB       		.byte	-69
 2025 0157 FF       		.byte	-1
 2026 0158 32       		.byte	50
 2027 0159 81       		.byte	-127
 2028 015a BB       		.byte	-69
 2029 015b FF       		.byte	-1
 2030 015c 32       		.byte	50
 2031 015d 81       		.byte	-127
 2032 015e BC       		.byte	-68
 2033 015f FF       		.byte	-1
 2034 0160 32       		.byte	50
 2035 0161 82       		.byte	-126
 2036 0162 BC       		.byte	-68
 2037 0163 FF       		.byte	-1
 2038 0164 31       		.byte	49
 2039 0165 82       		.byte	-126
 2040 0166 BC       		.byte	-68
 2041 0167 FF       		.byte	-1
 2042 0168 31       		.byte	49
 2043 0169 82       		.byte	-126
 2044 016a BC       		.byte	-68
 2045 016b FF       		.byte	-1
 2046 016c 31       		.byte	49
 2047 016d 83       		.byte	-125
 2048 016e BC       		.byte	-68
 2049 016f FF       		.byte	-1
 2050 0170 31       		.byte	49
 2051 0171 83       		.byte	-125
 2052 0172 BC       		.byte	-68
 2053 0173 FF       		.byte	-1
 2054 0174 31       		.byte	49
 2055 0175 84       		.byte	-124
 2056 0176 BC       		.byte	-68
 2057 0177 FF       		.byte	-1
 2058 0178 31       		.byte	49
 2059 0179 84       		.byte	-124
 2060 017a BC       		.byte	-68
 2061 017b FF       		.byte	-1
 2062 017c 31       		.byte	49
 2063 017d 84       		.byte	-124
 2064 017e BC       		.byte	-68
 2065 017f FF       		.byte	-1
 2066 0180 31       		.byte	49
 2067 0181 85       		.byte	-123
 2068 0182 BC       		.byte	-68
 2069 0183 FF       		.byte	-1
GAS LISTING /tmp/ccK2IhnQ.s 			page 52


 2070 0184 31       		.byte	49
 2071 0185 85       		.byte	-123
 2072 0186 BC       		.byte	-68
 2073 0187 FF       		.byte	-1
 2074 0188 31       		.byte	49
 2075 0189 85       		.byte	-123
 2076 018a BC       		.byte	-68
 2077 018b FF       		.byte	-1
 2078 018c 31       		.byte	49
 2079 018d 86       		.byte	-122
 2080 018e BC       		.byte	-68
 2081 018f FF       		.byte	-1
 2082 0190 31       		.byte	49
 2083 0191 86       		.byte	-122
 2084 0192 BC       		.byte	-68
 2085 0193 FF       		.byte	-1
 2086 0194 31       		.byte	49
 2087 0195 87       		.byte	-121
 2088 0196 BC       		.byte	-68
 2089 0197 FF       		.byte	-1
 2090 0198 31       		.byte	49
 2091 0199 87       		.byte	-121
 2092 019a BC       		.byte	-68
 2093 019b FF       		.byte	-1
 2094 019c 31       		.byte	49
 2095 019d 87       		.byte	-121
 2096 019e BC       		.byte	-68
 2097 019f FF       		.byte	-1
 2098 01a0 31       		.byte	49
 2099 01a1 88       		.byte	-120
 2100 01a2 BD       		.byte	-67
 2101 01a3 FF       		.byte	-1
 2102 01a4 2F       		.byte	47
 2103 01a5 88       		.byte	-120
 2104 01a6 BD       		.byte	-67
 2105 01a7 FF       		.byte	-1
 2106 01a8 2E       		.byte	46
 2107 01a9 89       		.byte	-119
 2108 01aa BD       		.byte	-67
 2109 01ab FF       		.byte	-1
 2110 01ac 2D       		.byte	45
 2111 01ad 8A       		.byte	-118
 2112 01ae BD       		.byte	-67
 2113 01af FF       		.byte	-1
 2114 01b0 2B       		.byte	43
 2115 01b1 8A       		.byte	-118
 2116 01b2 BD       		.byte	-67
 2117 01b3 FF       		.byte	-1
 2118 01b4 2A       		.byte	42
 2119 01b5 8B       		.byte	-117
 2120 01b6 BE       		.byte	-66
 2121 01b7 FF       		.byte	-1
 2122 01b8 29       		.byte	41
 2123 01b9 8B       		.byte	-117
 2124 01ba BE       		.byte	-66
 2125 01bb FF       		.byte	-1
 2126 01bc 27       		.byte	39
GAS LISTING /tmp/ccK2IhnQ.s 			page 53


 2127 01bd 8C       		.byte	-116
 2128 01be BE       		.byte	-66
 2129 01bf FF       		.byte	-1
 2130 01c0 26       		.byte	38
 2131 01c1 8C       		.byte	-116
 2132 01c2 BE       		.byte	-66
 2133 01c3 FF       		.byte	-1
 2134 01c4 24       		.byte	36
 2135 01c5 8D       		.byte	-115
 2136 01c6 BE       		.byte	-66
 2137 01c7 FF       		.byte	-1
 2138 01c8 23       		.byte	35
 2139 01c9 8D       		.byte	-115
 2140 01ca BE       		.byte	-66
 2141 01cb FF       		.byte	-1
 2142 01cc 21       		.byte	33
 2143 01cd 8E       		.byte	-114
 2144 01ce BE       		.byte	-66
 2145 01cf FF       		.byte	-1
 2146 01d0 1F       		.byte	31
 2147 01d1 8E       		.byte	-114
 2148 01d2 BE       		.byte	-66
 2149 01d3 FF       		.byte	-1
 2150 01d4 1E       		.byte	30
 2151 01d5 8F       		.byte	-113
 2152 01d6 BE       		.byte	-66
 2153 01d7 FF       		.byte	-1
 2154 01d8 1C       		.byte	28
 2155 01d9 8F       		.byte	-113
 2156 01da BE       		.byte	-66
 2157 01db FF       		.byte	-1
 2158 01dc 1A       		.byte	26
 2159 01dd 90       		.byte	-112
 2160 01de BF       		.byte	-65
 2161 01df FF       		.byte	-1
 2162 01e0 18       		.byte	24
 2163 01e1 91       		.byte	-111
 2164 01e2 BF       		.byte	-65
 2165 01e3 FF       		.byte	-1
 2166 01e4 16       		.byte	22
 2167 01e5 91       		.byte	-111
 2168 01e6 BF       		.byte	-65
 2169 01e7 FF       		.byte	-1
 2170 01e8 14       		.byte	20
 2171 01e9 92       		.byte	-110
 2172 01ea BF       		.byte	-65
 2173 01eb FF       		.byte	-1
 2174 01ec 11       		.byte	17
 2175 01ed 92       		.byte	-110
 2176 01ee BF       		.byte	-65
 2177 01ef FF       		.byte	-1
 2178 01f0 0F       		.byte	15
 2179 01f1 93       		.byte	-109
 2180 01f2 BF       		.byte	-65
 2181 01f3 FF       		.byte	-1
 2182 01f4 0C       		.byte	12
 2183 01f5 93       		.byte	-109
GAS LISTING /tmp/ccK2IhnQ.s 			page 54


 2184 01f6 BF       		.byte	-65
 2185 01f7 FF       		.byte	-1
 2186 01f8 0A       		.byte	10
 2187 01f9 94       		.byte	-108
 2188 01fa BF       		.byte	-65
 2189 01fb FF       		.byte	-1
 2190 01fc 0A       		.byte	10
 2191 01fd 94       		.byte	-108
 2192 01fe BF       		.byte	-65
 2193 01ff FF       		.byte	-1
 2194 0200 0A       		.byte	10
 2195 0201 95       		.byte	-107
 2196 0202 BF       		.byte	-65
 2197 0203 FF       		.byte	-1
 2198 0204 0A       		.byte	10
 2199 0205 95       		.byte	-107
 2200 0206 BF       		.byte	-65
 2201 0207 FF       		.byte	-1
 2202 0208 0A       		.byte	10
 2203 0209 96       		.byte	-106
 2204 020a BF       		.byte	-65
 2205 020b FF       		.byte	-1
 2206 020c 0A       		.byte	10
 2207 020d 96       		.byte	-106
 2208 020e BE       		.byte	-66
 2209 020f FF       		.byte	-1
 2210 0210 0A       		.byte	10
 2211 0211 97       		.byte	-105
 2212 0212 BE       		.byte	-66
 2213 0213 FF       		.byte	-1
 2214 0214 0A       		.byte	10
 2215 0215 97       		.byte	-105
 2216 0216 BE       		.byte	-66
 2217 0217 FF       		.byte	-1
 2218 0218 0A       		.byte	10
 2219 0219 98       		.byte	-104
 2220 021a BE       		.byte	-66
 2221 021b FF       		.byte	-1
 2222 021c 0A       		.byte	10
 2223 021d 98       		.byte	-104
 2224 021e BE       		.byte	-66
 2225 021f FF       		.byte	-1
 2226 0220 0A       		.byte	10
 2227 0221 99       		.byte	-103
 2228 0222 BE       		.byte	-66
 2229 0223 FF       		.byte	-1
 2230 0224 0A       		.byte	10
 2231 0225 99       		.byte	-103
 2232 0226 BE       		.byte	-66
 2233 0227 FF       		.byte	-1
 2234 0228 0A       		.byte	10
 2235 0229 9A       		.byte	-102
 2236 022a BE       		.byte	-66
 2237 022b FF       		.byte	-1
 2238 022c 0A       		.byte	10
 2239 022d 9A       		.byte	-102
 2240 022e BE       		.byte	-66
GAS LISTING /tmp/ccK2IhnQ.s 			page 55


 2241 022f FF       		.byte	-1
 2242 0230 0A       		.byte	10
 2243 0231 9B       		.byte	-101
 2244 0232 BE       		.byte	-66
 2245 0233 FF       		.byte	-1
 2246 0234 0A       		.byte	10
 2247 0235 9B       		.byte	-101
 2248 0236 BD       		.byte	-67
 2249 0237 FF       		.byte	-1
 2250 0238 0A       		.byte	10
 2251 0239 9C       		.byte	-100
 2252 023a BD       		.byte	-67
 2253 023b FF       		.byte	-1
 2254 023c 0A       		.byte	10
 2255 023d 9C       		.byte	-100
 2256 023e BD       		.byte	-67
 2257 023f FF       		.byte	-1
 2258 0240 0A       		.byte	10
 2259 0241 9D       		.byte	-99
 2260 0242 BD       		.byte	-67
 2261 0243 FF       		.byte	-1
 2262 0244 0A       		.byte	10
 2263 0245 9D       		.byte	-99
 2264 0246 BD       		.byte	-67
 2265 0247 FF       		.byte	-1
 2266 0248 0A       		.byte	10
 2267 0249 9E       		.byte	-98
 2268 024a BD       		.byte	-67
 2269 024b FF       		.byte	-1
 2270 024c 0A       		.byte	10
 2271 024d 9E       		.byte	-98
 2272 024e BC       		.byte	-68
 2273 024f FF       		.byte	-1
 2274 0250 0A       		.byte	10
 2275 0251 9E       		.byte	-98
 2276 0252 BC       		.byte	-68
 2277 0253 FF       		.byte	-1
 2278 0254 0A       		.byte	10
 2279 0255 9F       		.byte	-97
 2280 0256 BC       		.byte	-68
 2281 0257 FF       		.byte	-1
 2282 0258 0A       		.byte	10
 2283 0259 9F       		.byte	-97
 2284 025a BC       		.byte	-68
 2285 025b FF       		.byte	-1
 2286 025c 0A       		.byte	10
 2287 025d A0       		.byte	-96
 2288 025e BC       		.byte	-68
 2289 025f FF       		.byte	-1
 2290 0260 0A       		.byte	10
 2291 0261 A0       		.byte	-96
 2292 0262 BB       		.byte	-69
 2293 0263 FF       		.byte	-1
 2294 0264 0A       		.byte	10
 2295 0265 A1       		.byte	-95
 2296 0266 BB       		.byte	-69
 2297 0267 FF       		.byte	-1
GAS LISTING /tmp/ccK2IhnQ.s 			page 56


 2298 0268 0A       		.byte	10
 2299 0269 A1       		.byte	-95
 2300 026a BB       		.byte	-69
 2301 026b FF       		.byte	-1
 2302 026c 14       		.byte	20
 2303 026d AD       		.byte	-83
 2304 026e B6       		.byte	-74
 2305 026f FF       		.byte	-1
 2306 0270 16       		.byte	22
 2307 0271 AE       		.byte	-82
 2308 0272 B6       		.byte	-74
 2309 0273 FF       		.byte	-1
 2310 0274 19       		.byte	25
 2311 0275 AE       		.byte	-82
 2312 0276 B5       		.byte	-75
 2313 0277 FF       		.byte	-1
 2314 0278 1C       		.byte	28
 2315 0279 AF       		.byte	-81
 2316 027a B5       		.byte	-75
 2317 027b FF       		.byte	-1
 2318 027c 1E       		.byte	30
 2319 027d AF       		.byte	-81
 2320 027e B5       		.byte	-75
 2321 027f FF       		.byte	-1
 2322 0280 21       		.byte	33
 2323 0281 B0       		.byte	-80
 2324 0282 B4       		.byte	-76
 2325 0283 FF       		.byte	-1
 2326 0284 23       		.byte	35
 2327 0285 B0       		.byte	-80
 2328 0286 B4       		.byte	-76
 2329 0287 FF       		.byte	-1
 2330 0288 25       		.byte	37
 2331 0289 B0       		.byte	-80
 2332 028a B4       		.byte	-76
 2333 028b FF       		.byte	-1
 2334 028c 27       		.byte	39
 2335 028d B1       		.byte	-79
 2336 028e B4       		.byte	-76
 2337 028f FF       		.byte	-1
 2338 0290 29       		.byte	41
 2339 0291 B1       		.byte	-79
 2340 0292 B3       		.byte	-77
 2341 0293 FF       		.byte	-1
 2342 0294 2B       		.byte	43
 2343 0295 B2       		.byte	-78
 2344 0296 B3       		.byte	-77
 2345 0297 FF       		.byte	-1
 2346 0298 2D       		.byte	45
 2347 0299 B2       		.byte	-78
 2348 029a B3       		.byte	-77
 2349 029b FF       		.byte	-1
 2350 029c 2E       		.byte	46
 2351 029d B3       		.byte	-77
 2352 029e B2       		.byte	-78
 2353 029f FF       		.byte	-1
 2354 02a0 30       		.byte	48
GAS LISTING /tmp/ccK2IhnQ.s 			page 57


 2355 02a1 B3       		.byte	-77
 2356 02a2 B2       		.byte	-78
 2357 02a3 FF       		.byte	-1
 2358 02a4 32       		.byte	50
 2359 02a5 B3       		.byte	-77
 2360 02a6 B2       		.byte	-78
 2361 02a7 FF       		.byte	-1
 2362 02a8 33       		.byte	51
 2363 02a9 B4       		.byte	-76
 2364 02aa B1       		.byte	-79
 2365 02ab FF       		.byte	-1
 2366 02ac 35       		.byte	53
 2367 02ad B4       		.byte	-76
 2368 02ae B1       		.byte	-79
 2369 02af FF       		.byte	-1
 2370 02b0 36       		.byte	54
 2371 02b1 B5       		.byte	-75
 2372 02b2 B1       		.byte	-79
 2373 02b3 FF       		.byte	-1
 2374 02b4 38       		.byte	56
 2375 02b5 B5       		.byte	-75
 2376 02b6 B0       		.byte	-80
 2377 02b7 FF       		.byte	-1
 2378 02b8 3A       		.byte	58
 2379 02b9 B6       		.byte	-74
 2380 02ba B0       		.byte	-80
 2381 02bb FF       		.byte	-1
 2382 02bc 3B       		.byte	59
 2383 02bd B6       		.byte	-74
 2384 02be B0       		.byte	-80
 2385 02bf FF       		.byte	-1
 2386 02c0 3D       		.byte	61
 2387 02c1 B6       		.byte	-74
 2388 02c2 AF       		.byte	-81
 2389 02c3 FF       		.byte	-1
 2390 02c4 3E       		.byte	62
 2391 02c5 B7       		.byte	-73
 2392 02c6 AF       		.byte	-81
 2393 02c7 FF       		.byte	-1
 2394 02c8 40       		.byte	64
 2395 02c9 B7       		.byte	-73
 2396 02ca AF       		.byte	-81
 2397 02cb FF       		.byte	-1
 2398 02cc 41       		.byte	65
 2399 02cd B8       		.byte	-72
 2400 02ce AE       		.byte	-82
 2401 02cf FF       		.byte	-1
 2402 02d0 42       		.byte	66
 2403 02d1 B8       		.byte	-72
 2404 02d2 AE       		.byte	-82
 2405 02d3 FF       		.byte	-1
 2406 02d4 44       		.byte	68
 2407 02d5 B8       		.byte	-72
 2408 02d6 AE       		.byte	-82
 2409 02d7 FF       		.byte	-1
 2410 02d8 45       		.byte	69
 2411 02d9 B9       		.byte	-71
GAS LISTING /tmp/ccK2IhnQ.s 			page 58


 2412 02da AD       		.byte	-83
 2413 02db FF       		.byte	-1
 2414 02dc 47       		.byte	71
 2415 02dd B9       		.byte	-71
 2416 02de AD       		.byte	-83
 2417 02df FF       		.byte	-1
 2418 02e0 48       		.byte	72
 2419 02e1 BA       		.byte	-70
 2420 02e2 AD       		.byte	-83
 2421 02e3 FF       		.byte	-1
 2422 02e4 4A       		.byte	74
 2423 02e5 BA       		.byte	-70
 2424 02e6 AC       		.byte	-84
 2425 02e7 FF       		.byte	-1
 2426 02e8 4B       		.byte	75
 2427 02e9 BA       		.byte	-70
 2428 02ea AC       		.byte	-84
 2429 02eb FF       		.byte	-1
 2430 02ec 4C       		.byte	76
 2431 02ed BB       		.byte	-69
 2432 02ee AB       		.byte	-85
 2433 02ef FF       		.byte	-1
 2434 02f0 4E       		.byte	78
 2435 02f1 BB       		.byte	-69
 2436 02f2 AB       		.byte	-85
 2437 02f3 FF       		.byte	-1
 2438 02f4 4F       		.byte	79
 2439 02f5 BB       		.byte	-69
 2440 02f6 AB       		.byte	-85
 2441 02f7 FF       		.byte	-1
 2442 02f8 50       		.byte	80
 2443 02f9 BC       		.byte	-68
 2444 02fa AA       		.byte	-86
 2445 02fb FF       		.byte	-1
 2446 02fc 52       		.byte	82
 2447 02fd BC       		.byte	-68
 2448 02fe AA       		.byte	-86
 2449 02ff FF       		.byte	-1
 2450 0300 53       		.byte	83
 2451 0301 BD       		.byte	-67
 2452 0302 AA       		.byte	-86
 2453 0303 FF       		.byte	-1
 2454 0304 55       		.byte	85
 2455 0305 BD       		.byte	-67
 2456 0306 A9       		.byte	-87
 2457 0307 FF       		.byte	-1
 2458 0308 56       		.byte	86
 2459 0309 BD       		.byte	-67
 2460 030a A9       		.byte	-87
 2461 030b FF       		.byte	-1
 2462 030c 57       		.byte	87
 2463 030d BE       		.byte	-66
 2464 030e A9       		.byte	-87
 2465 030f FF       		.byte	-1
 2466 0310 59       		.byte	89
 2467 0311 BE       		.byte	-66
 2468 0312 A8       		.byte	-88
GAS LISTING /tmp/ccK2IhnQ.s 			page 59


 2469 0313 FF       		.byte	-1
 2470 0314 5A       		.byte	90
 2471 0315 BE       		.byte	-66
 2472 0316 A8       		.byte	-88
 2473 0317 FF       		.byte	-1
 2474 0318 5B       		.byte	91
 2475 0319 BF       		.byte	-65
 2476 031a A7       		.byte	-89
 2477 031b FF       		.byte	-1
 2478 031c 5D       		.byte	93
 2479 031d BF       		.byte	-65
 2480 031e A7       		.byte	-89
 2481 031f FF       		.byte	-1
 2482 0320 5E       		.byte	94
 2483 0321 BF       		.byte	-65
 2484 0322 A7       		.byte	-89
 2485 0323 FF       		.byte	-1
 2486 0324 5F       		.byte	95
 2487 0325 C0       		.byte	-64
 2488 0326 A6       		.byte	-90
 2489 0327 FF       		.byte	-1
 2490 0328 61       		.byte	97
 2491 0329 C0       		.byte	-64
 2492 032a A6       		.byte	-90
 2493 032b FF       		.byte	-1
 2494 032c 62       		.byte	98
 2495 032d C1       		.byte	-63
 2496 032e A6       		.byte	-90
 2497 032f FF       		.byte	-1
 2498 0330 63       		.byte	99
 2499 0331 C1       		.byte	-63
 2500 0332 A5       		.byte	-91
 2501 0333 FF       		.byte	-1
 2502 0334 64       		.byte	100
 2503 0335 C1       		.byte	-63
 2504 0336 A5       		.byte	-91
 2505 0337 FF       		.byte	-1
 2506 0338 66       		.byte	102
 2507 0339 C2       		.byte	-62
 2508 033a A4       		.byte	-92
 2509 033b FF       		.byte	-1
 2510 033c 66       		.byte	102
 2511 033d C2       		.byte	-62
 2512 033e A4       		.byte	-92
 2513 033f FF       		.byte	-1
 2514 0340 67       		.byte	103
 2515 0341 C2       		.byte	-62
 2516 0342 A4       		.byte	-92
 2517 0343 FF       		.byte	-1
 2518 0344 67       		.byte	103
 2519 0345 C2       		.byte	-62
 2520 0346 A4       		.byte	-92
 2521 0347 FF       		.byte	-1
 2522 0348 68       		.byte	104
 2523 0349 C2       		.byte	-62
 2524 034a A4       		.byte	-92
 2525 034b FF       		.byte	-1
GAS LISTING /tmp/ccK2IhnQ.s 			page 60


 2526 034c 68       		.byte	104
 2527 034d C3       		.byte	-61
 2528 034e A4       		.byte	-92
 2529 034f FF       		.byte	-1
 2530 0350 69       		.byte	105
 2531 0351 C3       		.byte	-61
 2532 0352 A4       		.byte	-92
 2533 0353 FF       		.byte	-1
 2534 0354 69       		.byte	105
 2535 0355 C3       		.byte	-61
 2536 0356 A4       		.byte	-92
 2537 0357 FF       		.byte	-1
 2538 0358 6A       		.byte	106
 2539 0359 C3       		.byte	-61
 2540 035a A4       		.byte	-92
 2541 035b FF       		.byte	-1
 2542 035c 6A       		.byte	106
 2543 035d C4       		.byte	-60
 2544 035e A4       		.byte	-92
 2545 035f FF       		.byte	-1
 2546 0360 6B       		.byte	107
 2547 0361 C4       		.byte	-60
 2548 0362 A4       		.byte	-92
 2549 0363 FF       		.byte	-1
 2550 0364 6C       		.byte	108
 2551 0365 C4       		.byte	-60
 2552 0366 A4       		.byte	-92
 2553 0367 FF       		.byte	-1
 2554 0368 6C       		.byte	108
 2555 0369 C4       		.byte	-60
 2556 036a A4       		.byte	-92
 2557 036b FF       		.byte	-1
 2558 036c 6D       		.byte	109
 2559 036d C4       		.byte	-60
 2560 036e A4       		.byte	-92
 2561 036f FF       		.byte	-1
 2562 0370 6D       		.byte	109
 2563 0371 C5       		.byte	-59
 2564 0372 A4       		.byte	-92
 2565 0373 FF       		.byte	-1
 2566 0374 6E       		.byte	110
 2567 0375 C5       		.byte	-59
 2568 0376 A4       		.byte	-92
 2569 0377 FF       		.byte	-1
 2570 0378 6E       		.byte	110
 2571 0379 C5       		.byte	-59
 2572 037a A4       		.byte	-92
 2573 037b FF       		.byte	-1
 2574 037c 6F       		.byte	111
 2575 037d C5       		.byte	-59
 2576 037e A4       		.byte	-92
 2577 037f FF       		.byte	-1
 2578 0380 6F       		.byte	111
 2579 0381 C6       		.byte	-58
 2580 0382 A4       		.byte	-92
 2581 0383 FF       		.byte	-1
 2582 0384 70       		.byte	112
GAS LISTING /tmp/ccK2IhnQ.s 			page 61


 2583 0385 C6       		.byte	-58
 2584 0386 A4       		.byte	-92
 2585 0387 FF       		.byte	-1
 2586 0388 70       		.byte	112
 2587 0389 C6       		.byte	-58
 2588 038a A4       		.byte	-92
 2589 038b FF       		.byte	-1
 2590 038c 71       		.byte	113
 2591 038d C6       		.byte	-58
 2592 038e A4       		.byte	-92
 2593 038f FF       		.byte	-1
 2594 0390 71       		.byte	113
 2595 0391 C6       		.byte	-58
 2596 0392 A4       		.byte	-92
 2597 0393 FF       		.byte	-1
 2598 0394 72       		.byte	114
 2599 0395 C7       		.byte	-57
 2600 0396 A4       		.byte	-92
 2601 0397 FF       		.byte	-1
 2602 0398 73       		.byte	115
 2603 0399 C7       		.byte	-57
 2604 039a A4       		.byte	-92
 2605 039b FF       		.byte	-1
 2606 039c 73       		.byte	115
 2607 039d C7       		.byte	-57
 2608 039e A4       		.byte	-92
 2609 039f FF       		.byte	-1
 2610 03a0 74       		.byte	116
 2611 03a1 C7       		.byte	-57
 2612 03a2 A4       		.byte	-92
 2613 03a3 FF       		.byte	-1
 2614 03a4 74       		.byte	116
 2615 03a5 C8       		.byte	-56
 2616 03a6 A4       		.byte	-92
 2617 03a7 FF       		.byte	-1
 2618 03a8 75       		.byte	117
 2619 03a9 C8       		.byte	-56
 2620 03aa A4       		.byte	-92
 2621 03ab FF       		.byte	-1
 2622 03ac 75       		.byte	117
 2623 03ad C8       		.byte	-56
 2624 03ae A4       		.byte	-92
 2625 03af FF       		.byte	-1
 2626 03b0 76       		.byte	118
 2627 03b1 C8       		.byte	-56
 2628 03b2 A4       		.byte	-92
 2629 03b3 FF       		.byte	-1
 2630 03b4 76       		.byte	118
 2631 03b5 C8       		.byte	-56
 2632 03b6 A4       		.byte	-92
 2633 03b7 FF       		.byte	-1
 2634 03b8 77       		.byte	119
 2635 03b9 C9       		.byte	-55
 2636 03ba A4       		.byte	-92
 2637 03bb FF       		.byte	-1
 2638 03bc 77       		.byte	119
 2639 03bd C9       		.byte	-55
GAS LISTING /tmp/ccK2IhnQ.s 			page 62


 2640 03be A4       		.byte	-92
 2641 03bf FF       		.byte	-1
 2642 03c0 78       		.byte	120
 2643 03c1 C9       		.byte	-55
 2644 03c2 A4       		.byte	-92
 2645 03c3 FF       		.byte	-1
 2646 03c4 78       		.byte	120
 2647 03c5 C9       		.byte	-55
 2648 03c6 A4       		.byte	-92
 2649 03c7 FF       		.byte	-1
 2650 03c8 79       		.byte	121
 2651 03c9 C9       		.byte	-55
 2652 03ca A4       		.byte	-92
 2653 03cb FF       		.byte	-1
 2654 03cc 7A       		.byte	122
 2655 03cd CA       		.byte	-54
 2656 03ce A4       		.byte	-92
 2657 03cf FF       		.byte	-1
 2658 03d0 7A       		.byte	122
 2659 03d1 CA       		.byte	-54
 2660 03d2 A4       		.byte	-92
 2661 03d3 FF       		.byte	-1
 2662 03d4 7B       		.byte	123
 2663 03d5 CA       		.byte	-54
 2664 03d6 A4       		.byte	-92
 2665 03d7 FF       		.byte	-1
 2666 03d8 7B       		.byte	123
 2667 03d9 CA       		.byte	-54
 2668 03da A4       		.byte	-92
 2669 03db FF       		.byte	-1
 2670 03dc 7C       		.byte	124
 2671 03dd CB       		.byte	-53
 2672 03de A4       		.byte	-92
 2673 03df FF       		.byte	-1
 2674 03e0 7C       		.byte	124
 2675 03e1 CB       		.byte	-53
 2676 03e2 A4       		.byte	-92
 2677 03e3 FF       		.byte	-1
 2678 03e4 7D       		.byte	125
 2679 03e5 CB       		.byte	-53
 2680 03e6 A4       		.byte	-92
 2681 03e7 FF       		.byte	-1
 2682 03e8 7D       		.byte	125
 2683 03e9 CB       		.byte	-53
 2684 03ea A4       		.byte	-92
 2685 03eb FF       		.byte	-1
 2686 03ec 7E       		.byte	126
 2687 03ed CB       		.byte	-53
 2688 03ee A4       		.byte	-92
 2689 03ef FF       		.byte	-1
 2690 03f0 7E       		.byte	126
 2691 03f1 CC       		.byte	-52
 2692 03f2 A4       		.byte	-92
 2693 03f3 FF       		.byte	-1
 2694 03f4 7F       		.byte	127
 2695 03f5 CC       		.byte	-52
 2696 03f6 A4       		.byte	-92
GAS LISTING /tmp/ccK2IhnQ.s 			page 63


 2697 03f7 FF       		.byte	-1
 2698 03f8 7F       		.byte	127
 2699 03f9 CC       		.byte	-52
 2700 03fa A3       		.byte	-93
 2701 03fb FF       		.byte	-1
 2702 03fc 80       		.byte	-128
 2703 03fd CC       		.byte	-52
 2704 03fe A3       		.byte	-93
 2705 03ff FF       		.byte	-1
 2706 0400 81       		.byte	-127
 2707 0401 CC       		.byte	-52
 2708 0402 A3       		.byte	-93
 2709 0403 FF       		.byte	-1
 2710 0404 8F       		.byte	-113
 2711 0405 D2       		.byte	-46
 2712 0406 A3       		.byte	-93
 2713 0407 FF       		.byte	-1
 2714 0408 8F       		.byte	-113
 2715 0409 D2       		.byte	-46
 2716 040a A3       		.byte	-93
 2717 040b FF       		.byte	-1
 2718 040c 90       		.byte	-112
 2719 040d D2       		.byte	-46
 2720 040e A3       		.byte	-93
 2721 040f FF       		.byte	-1
 2722 0410 90       		.byte	-112
 2723 0411 D3       		.byte	-45
 2724 0412 A3       		.byte	-93
 2725 0413 FF       		.byte	-1
 2726 0414 91       		.byte	-111
 2727 0415 D3       		.byte	-45
 2728 0416 A3       		.byte	-93
 2729 0417 FF       		.byte	-1
 2730 0418 92       		.byte	-110
 2731 0419 D3       		.byte	-45
 2732 041a A3       		.byte	-93
 2733 041b FF       		.byte	-1
 2734 041c 92       		.byte	-110
 2735 041d D3       		.byte	-45
 2736 041e A3       		.byte	-93
 2737 041f FF       		.byte	-1
 2738 0420 93       		.byte	-109
 2739 0421 D4       		.byte	-44
 2740 0422 A3       		.byte	-93
 2741 0423 FF       		.byte	-1
 2742 0424 93       		.byte	-109
 2743 0425 D4       		.byte	-44
 2744 0426 A3       		.byte	-93
 2745 0427 FF       		.byte	-1
 2746 0428 94       		.byte	-108
 2747 0429 D4       		.byte	-44
 2748 042a A3       		.byte	-93
 2749 042b FF       		.byte	-1
 2750 042c 94       		.byte	-108
 2751 042d D4       		.byte	-44
 2752 042e A3       		.byte	-93
 2753 042f FF       		.byte	-1
GAS LISTING /tmp/ccK2IhnQ.s 			page 64


 2754 0430 95       		.byte	-107
 2755 0431 D4       		.byte	-44
 2756 0432 A3       		.byte	-93
 2757 0433 FF       		.byte	-1
 2758 0434 95       		.byte	-107
 2759 0435 D5       		.byte	-43
 2760 0436 A3       		.byte	-93
 2761 0437 FF       		.byte	-1
 2762 0438 96       		.byte	-106
 2763 0439 D5       		.byte	-43
 2764 043a A3       		.byte	-93
 2765 043b FF       		.byte	-1
 2766 043c 96       		.byte	-106
 2767 043d D5       		.byte	-43
 2768 043e A3       		.byte	-93
 2769 043f FF       		.byte	-1
 2770 0440 97       		.byte	-105
 2771 0441 D5       		.byte	-43
 2772 0442 A3       		.byte	-93
 2773 0443 FF       		.byte	-1
 2774 0444 97       		.byte	-105
 2775 0445 D5       		.byte	-43
 2776 0446 A3       		.byte	-93
 2777 0447 FF       		.byte	-1
 2778 0448 98       		.byte	-104
 2779 0449 D6       		.byte	-42
 2780 044a A3       		.byte	-93
 2781 044b FF       		.byte	-1
 2782 044c 99       		.byte	-103
 2783 044d D6       		.byte	-42
 2784 044e A3       		.byte	-93
 2785 044f FF       		.byte	-1
 2786 0450 99       		.byte	-103
 2787 0451 D6       		.byte	-42
 2788 0452 A3       		.byte	-93
 2789 0453 FF       		.byte	-1
 2790 0454 9A       		.byte	-102
 2791 0455 D6       		.byte	-42
 2792 0456 A3       		.byte	-93
 2793 0457 FF       		.byte	-1
 2794 0458 9A       		.byte	-102
 2795 0459 D6       		.byte	-42
 2796 045a A3       		.byte	-93
 2797 045b FF       		.byte	-1
 2798 045c 9B       		.byte	-101
 2799 045d D7       		.byte	-41
 2800 045e A3       		.byte	-93
 2801 045f FF       		.byte	-1
 2802 0460 9B       		.byte	-101
 2803 0461 D7       		.byte	-41
 2804 0462 A3       		.byte	-93
 2805 0463 FF       		.byte	-1
 2806 0464 9C       		.byte	-100
 2807 0465 D7       		.byte	-41
 2808 0466 A3       		.byte	-93
 2809 0467 FF       		.byte	-1
 2810 0468 9C       		.byte	-100
GAS LISTING /tmp/ccK2IhnQ.s 			page 65


 2811 0469 D7       		.byte	-41
 2812 046a A3       		.byte	-93
 2813 046b FF       		.byte	-1
 2814 046c 9D       		.byte	-99
 2815 046d D7       		.byte	-41
 2816 046e A3       		.byte	-93
 2817 046f FF       		.byte	-1
 2818 0470 9D       		.byte	-99
 2819 0471 D8       		.byte	-40
 2820 0472 A3       		.byte	-93
 2821 0473 FF       		.byte	-1
 2822 0474 9E       		.byte	-98
 2823 0475 D8       		.byte	-40
 2824 0476 A3       		.byte	-93
 2825 0477 FF       		.byte	-1
 2826 0478 9E       		.byte	-98
 2827 0479 D8       		.byte	-40
 2828 047a A3       		.byte	-93
 2829 047b FF       		.byte	-1
 2830 047c 9F       		.byte	-97
 2831 047d D8       		.byte	-40
 2832 047e A3       		.byte	-93
 2833 047f FF       		.byte	-1
 2834 0480 A0       		.byte	-96
 2835 0481 D8       		.byte	-40
 2836 0482 A3       		.byte	-93
 2837 0483 FF       		.byte	-1
 2838 0484 A0       		.byte	-96
 2839 0485 D9       		.byte	-39
 2840 0486 A3       		.byte	-93
 2841 0487 FF       		.byte	-1
 2842 0488 A1       		.byte	-95
 2843 0489 D9       		.byte	-39
 2844 048a A3       		.byte	-93
 2845 048b FF       		.byte	-1
 2846 048c A1       		.byte	-95
 2847 048d D9       		.byte	-39
 2848 048e A3       		.byte	-93
 2849 048f FF       		.byte	-1
 2850 0490 A2       		.byte	-94
 2851 0491 D9       		.byte	-39
 2852 0492 A3       		.byte	-93
 2853 0493 FF       		.byte	-1
 2854 0494 A2       		.byte	-94
 2855 0495 D9       		.byte	-39
 2856 0496 A3       		.byte	-93
 2857 0497 FF       		.byte	-1
 2858 0498 A3       		.byte	-93
 2859 0499 DA       		.byte	-38
 2860 049a A3       		.byte	-93
 2861 049b FF       		.byte	-1
 2862 049c A3       		.byte	-93
 2863 049d DA       		.byte	-38
 2864 049e A3       		.byte	-93
 2865 049f FF       		.byte	-1
 2866 04a0 A4       		.byte	-92
 2867 04a1 DA       		.byte	-38
GAS LISTING /tmp/ccK2IhnQ.s 			page 66


 2868 04a2 A3       		.byte	-93
 2869 04a3 FF       		.byte	-1
 2870 04a4 A4       		.byte	-92
 2871 04a5 DA       		.byte	-38
 2872 04a6 A3       		.byte	-93
 2873 04a7 FF       		.byte	-1
 2874 04a8 A5       		.byte	-91
 2875 04a9 DA       		.byte	-38
 2876 04aa A3       		.byte	-93
 2877 04ab FF       		.byte	-1
 2878 04ac A6       		.byte	-90
 2879 04ad DB       		.byte	-37
 2880 04ae A3       		.byte	-93
 2881 04af FF       		.byte	-1
 2882 04b0 A6       		.byte	-90
 2883 04b1 DB       		.byte	-37
 2884 04b2 A3       		.byte	-93
 2885 04b3 FF       		.byte	-1
 2886 04b4 A7       		.byte	-89
 2887 04b5 DB       		.byte	-37
 2888 04b6 A3       		.byte	-93
 2889 04b7 FF       		.byte	-1
 2890 04b8 A7       		.byte	-89
 2891 04b9 DB       		.byte	-37
 2892 04ba A3       		.byte	-93
 2893 04bb FF       		.byte	-1
 2894 04bc A8       		.byte	-88
 2895 04bd DB       		.byte	-37
 2896 04be A3       		.byte	-93
 2897 04bf FF       		.byte	-1
 2898 04c0 A8       		.byte	-88
 2899 04c1 DC       		.byte	-36
 2900 04c2 A3       		.byte	-93
 2901 04c3 FF       		.byte	-1
 2902 04c4 A9       		.byte	-87
 2903 04c5 DC       		.byte	-36
 2904 04c6 A3       		.byte	-93
 2905 04c7 FF       		.byte	-1
 2906 04c8 A9       		.byte	-87
 2907 04c9 DC       		.byte	-36
 2908 04ca A3       		.byte	-93
 2909 04cb FF       		.byte	-1
 2910 04cc AA       		.byte	-86
 2911 04cd DC       		.byte	-36
 2912 04ce A3       		.byte	-93
 2913 04cf FF       		.byte	-1
 2914 04d0 AA       		.byte	-86
 2915 04d1 DC       		.byte	-36
 2916 04d2 A3       		.byte	-93
 2917 04d3 FF       		.byte	-1
 2918 04d4 AB       		.byte	-85
 2919 04d5 DD       		.byte	-35
 2920 04d6 A3       		.byte	-93
 2921 04d7 FF       		.byte	-1
 2922 04d8 AB       		.byte	-85
 2923 04d9 DD       		.byte	-35
 2924 04da A3       		.byte	-93
GAS LISTING /tmp/ccK2IhnQ.s 			page 67


 2925 04db FF       		.byte	-1
 2926 04dc AC       		.byte	-84
 2927 04dd DD       		.byte	-35
 2928 04de A3       		.byte	-93
 2929 04df FF       		.byte	-1
 2930 04e0 AC       		.byte	-84
 2931 04e1 DD       		.byte	-35
 2932 04e2 A3       		.byte	-93
 2933 04e3 FF       		.byte	-1
 2934 04e4 AC       		.byte	-84
 2935 04e5 DE       		.byte	-34
 2936 04e6 A3       		.byte	-93
 2937 04e7 FF       		.byte	-1
 2938 04e8 AD       		.byte	-83
 2939 04e9 DE       		.byte	-34
 2940 04ea A3       		.byte	-93
 2941 04eb FF       		.byte	-1
 2942 04ec AD       		.byte	-83
 2943 04ed DE       		.byte	-34
 2944 04ee A3       		.byte	-93
 2945 04ef FF       		.byte	-1
 2946 04f0 AD       		.byte	-83
 2947 04f1 DE       		.byte	-34
 2948 04f2 A3       		.byte	-93
 2949 04f3 FF       		.byte	-1
 2950 04f4 AE       		.byte	-82
 2951 04f5 DE       		.byte	-34
 2952 04f6 A3       		.byte	-93
 2953 04f7 FF       		.byte	-1
 2954 04f8 AE       		.byte	-82
 2955 04f9 DF       		.byte	-33
 2956 04fa A3       		.byte	-93
 2957 04fb FF       		.byte	-1
 2958 04fc AF       		.byte	-81
 2959 04fd DF       		.byte	-33
 2960 04fe A3       		.byte	-93
 2961 04ff FF       		.byte	-1
 2962 0500 AF       		.byte	-81
 2963 0501 DF       		.byte	-33
 2964 0502 A3       		.byte	-93
 2965 0503 FF       		.byte	-1
 2966 0504 AF       		.byte	-81
 2967 0505 DF       		.byte	-33
 2968 0506 A2       		.byte	-94
 2969 0507 FF       		.byte	-1
 2970 0508 B0       		.byte	-80
 2971 0509 DF       		.byte	-33
 2972 050a A2       		.byte	-94
 2973 050b FF       		.byte	-1
 2974 050c B0       		.byte	-80
 2975 050d E0       		.byte	-32
 2976 050e A2       		.byte	-94
 2977 050f FF       		.byte	-1
 2978 0510 B1       		.byte	-79
 2979 0511 E0       		.byte	-32
 2980 0512 A2       		.byte	-94
 2981 0513 FF       		.byte	-1
GAS LISTING /tmp/ccK2IhnQ.s 			page 68


 2982 0514 B1       		.byte	-79
 2983 0515 E0       		.byte	-32
 2984 0516 A2       		.byte	-94
 2985 0517 FF       		.byte	-1
 2986 0518 B1       		.byte	-79
 2987 0519 E0       		.byte	-32
 2988 051a A2       		.byte	-94
 2989 051b FF       		.byte	-1
 2990 051c B2       		.byte	-78
 2991 051d E0       		.byte	-32
 2992 051e A2       		.byte	-94
 2993 051f FF       		.byte	-1
 2994 0520 B2       		.byte	-78
 2995 0521 E1       		.byte	-31
 2996 0522 A2       		.byte	-94
 2997 0523 FF       		.byte	-1
 2998 0524 B3       		.byte	-77
 2999 0525 E1       		.byte	-31
 3000 0526 A2       		.byte	-94
 3001 0527 FF       		.byte	-1
 3002 0528 B3       		.byte	-77
 3003 0529 E1       		.byte	-31
 3004 052a A2       		.byte	-94
 3005 052b FF       		.byte	-1
 3006 052c B3       		.byte	-77
 3007 052d E1       		.byte	-31
 3008 052e A2       		.byte	-94
 3009 052f FF       		.byte	-1
 3010 0530 B4       		.byte	-76
 3011 0531 E1       		.byte	-31
 3012 0532 A1       		.byte	-95
 3013 0533 FF       		.byte	-1
 3014 0534 B4       		.byte	-76
 3015 0535 E2       		.byte	-30
 3016 0536 A1       		.byte	-95
 3017 0537 FF       		.byte	-1
 3018 0538 B5       		.byte	-75
 3019 0539 E2       		.byte	-30
 3020 053a A1       		.byte	-95
 3021 053b FF       		.byte	-1
 3022 053c B5       		.byte	-75
 3023 053d E2       		.byte	-30
 3024 053e A1       		.byte	-95
 3025 053f FF       		.byte	-1
 3026 0540 B6       		.byte	-74
 3027 0541 E2       		.byte	-30
 3028 0542 A1       		.byte	-95
 3029 0543 FF       		.byte	-1
 3030 0544 B6       		.byte	-74
 3031 0545 E2       		.byte	-30
 3032 0546 A1       		.byte	-95
 3033 0547 FF       		.byte	-1
 3034 0548 B6       		.byte	-74
 3035 0549 E3       		.byte	-29
 3036 054a A1       		.byte	-95
 3037 054b FF       		.byte	-1
 3038 054c B7       		.byte	-73
GAS LISTING /tmp/ccK2IhnQ.s 			page 69


 3039 054d E3       		.byte	-29
 3040 054e A1       		.byte	-95
 3041 054f FF       		.byte	-1
 3042 0550 B7       		.byte	-73
 3043 0551 E3       		.byte	-29
 3044 0552 A1       		.byte	-95
 3045 0553 FF       		.byte	-1
 3046 0554 B8       		.byte	-72
 3047 0555 E3       		.byte	-29
 3048 0556 A1       		.byte	-95
 3049 0557 FF       		.byte	-1
 3050 0558 B8       		.byte	-72
 3051 0559 E3       		.byte	-29
 3052 055a A0       		.byte	-96
 3053 055b FF       		.byte	-1
 3054 055c B9       		.byte	-71
 3055 055d E4       		.byte	-28
 3056 055e A0       		.byte	-96
 3057 055f FF       		.byte	-1
 3058 0560 B9       		.byte	-71
 3059 0561 E4       		.byte	-28
 3060 0562 A0       		.byte	-96
 3061 0563 FF       		.byte	-1
 3062 0564 B9       		.byte	-71
 3063 0565 E4       		.byte	-28
 3064 0566 A0       		.byte	-96
 3065 0567 FF       		.byte	-1
 3066 0568 BA       		.byte	-70
 3067 0569 E4       		.byte	-28
 3068 056a A0       		.byte	-96
 3069 056b FF       		.byte	-1
 3070 056c BA       		.byte	-70
 3071 056d E4       		.byte	-28
 3072 056e A0       		.byte	-96
 3073 056f FF       		.byte	-1
 3074 0570 BB       		.byte	-69
 3075 0571 E5       		.byte	-27
 3076 0572 A0       		.byte	-96
 3077 0573 FF       		.byte	-1
 3078 0574 BB       		.byte	-69
 3079 0575 E5       		.byte	-27
 3080 0576 A0       		.byte	-96
 3081 0577 FF       		.byte	-1
 3082 0578 BC       		.byte	-68
 3083 0579 E5       		.byte	-27
 3084 057a A0       		.byte	-96
 3085 057b FF       		.byte	-1
 3086 057c BC       		.byte	-68
 3087 057d E5       		.byte	-27
 3088 057e A0       		.byte	-96
 3089 057f FF       		.byte	-1
 3090 0580 BD       		.byte	-67
 3091 0581 E5       		.byte	-27
 3092 0582 9F       		.byte	-97
 3093 0583 FF       		.byte	-1
 3094 0584 BD       		.byte	-67
 3095 0585 E6       		.byte	-26
GAS LISTING /tmp/ccK2IhnQ.s 			page 70


 3096 0586 9F       		.byte	-97
 3097 0587 FF       		.byte	-1
 3098 0588 BD       		.byte	-67
 3099 0589 E6       		.byte	-26
 3100 058a 9F       		.byte	-97
 3101 058b FF       		.byte	-1
 3102 058c BE       		.byte	-66
 3103 058d E6       		.byte	-26
 3104 058e 9F       		.byte	-97
 3105 058f FF       		.byte	-1
 3106 0590 BE       		.byte	-66
 3107 0591 E6       		.byte	-26
 3108 0592 9F       		.byte	-97
 3109 0593 FF       		.byte	-1
 3110 0594 BF       		.byte	-65
 3111 0595 E6       		.byte	-26
 3112 0596 9F       		.byte	-97
 3113 0597 FF       		.byte	-1
 3114 0598 BF       		.byte	-65
 3115 0599 E7       		.byte	-25
 3116 059a 9F       		.byte	-97
 3117 059b FF       		.byte	-1
 3118 059c C0       		.byte	-64
 3119 059d E7       		.byte	-25
 3120 059e 9F       		.byte	-97
 3121 059f FF       		.byte	-1
 3122 05a0 CC       		.byte	-52
 3123 05a1 EC       		.byte	-20
 3124 05a2 9C       		.byte	-100
 3125 05a3 FF       		.byte	-1
 3126 05a4 CD       		.byte	-51
 3127 05a5 EC       		.byte	-20
 3128 05a6 9C       		.byte	-100
 3129 05a7 FF       		.byte	-1
 3130 05a8 CD       		.byte	-51
 3131 05a9 EC       		.byte	-20
 3132 05aa 9C       		.byte	-100
 3133 05ab FF       		.byte	-1
 3134 05ac CD       		.byte	-51
 3135 05ad EC       		.byte	-20
 3136 05ae 9C       		.byte	-100
 3137 05af FF       		.byte	-1
 3138 05b0 CE       		.byte	-50
 3139 05b1 EC       		.byte	-20
 3140 05b2 9C       		.byte	-100
 3141 05b3 FF       		.byte	-1
 3142 05b4 CE       		.byte	-50
 3143 05b5 ED       		.byte	-19
 3144 05b6 9C       		.byte	-100
 3145 05b7 FF       		.byte	-1
 3146 05b8 CF       		.byte	-49
 3147 05b9 ED       		.byte	-19
 3148 05ba 9C       		.byte	-100
 3149 05bb FF       		.byte	-1
 3150 05bc CF       		.byte	-49
 3151 05bd ED       		.byte	-19
 3152 05be 9C       		.byte	-100
GAS LISTING /tmp/ccK2IhnQ.s 			page 71


 3153 05bf FF       		.byte	-1
 3154 05c0 D0       		.byte	-48
 3155 05c1 ED       		.byte	-19
 3156 05c2 9C       		.byte	-100
 3157 05c3 FF       		.byte	-1
 3158 05c4 D0       		.byte	-48
 3159 05c5 ED       		.byte	-19
 3160 05c6 9B       		.byte	-101
 3161 05c7 FF       		.byte	-1
 3162 05c8 D1       		.byte	-47
 3163 05c9 EE       		.byte	-18
 3164 05ca 9B       		.byte	-101
 3165 05cb FF       		.byte	-1
 3166 05cc D1       		.byte	-47
 3167 05cd EE       		.byte	-18
 3168 05ce 9B       		.byte	-101
 3169 05cf FF       		.byte	-1
 3170 05d0 D2       		.byte	-46
 3171 05d1 EE       		.byte	-18
 3172 05d2 9B       		.byte	-101
 3173 05d3 FF       		.byte	-1
 3174 05d4 D2       		.byte	-46
 3175 05d5 EE       		.byte	-18
 3176 05d6 9B       		.byte	-101
 3177 05d7 FF       		.byte	-1
 3178 05d8 D3       		.byte	-45
 3179 05d9 EE       		.byte	-18
 3180 05da 9B       		.byte	-101
 3181 05db FF       		.byte	-1
 3182 05dc D3       		.byte	-45
 3183 05dd EE       		.byte	-18
 3184 05de 9B       		.byte	-101
 3185 05df FF       		.byte	-1
 3186 05e0 D4       		.byte	-44
 3187 05e1 EF       		.byte	-17
 3188 05e2 9B       		.byte	-101
 3189 05e3 FF       		.byte	-1
 3190 05e4 D4       		.byte	-44
 3191 05e5 EF       		.byte	-17
 3192 05e6 9B       		.byte	-101
 3193 05e7 FF       		.byte	-1
 3194 05e8 D5       		.byte	-43
 3195 05e9 EF       		.byte	-17
 3196 05ea 9B       		.byte	-101
 3197 05eb FF       		.byte	-1
 3198 05ec D5       		.byte	-43
 3199 05ed EF       		.byte	-17
 3200 05ee 9A       		.byte	-102
 3201 05ef FF       		.byte	-1
 3202 05f0 D6       		.byte	-42
 3203 05f1 EF       		.byte	-17
 3204 05f2 9A       		.byte	-102
 3205 05f3 FF       		.byte	-1
 3206 05f4 D6       		.byte	-42
 3207 05f5 F0       		.byte	-16
 3208 05f6 9A       		.byte	-102
 3209 05f7 FF       		.byte	-1
GAS LISTING /tmp/ccK2IhnQ.s 			page 72


 3210 05f8 D7       		.byte	-41
 3211 05f9 F0       		.byte	-16
 3212 05fa 9A       		.byte	-102
 3213 05fb FF       		.byte	-1
 3214 05fc D7       		.byte	-41
 3215 05fd F0       		.byte	-16
 3216 05fe 9A       		.byte	-102
 3217 05ff FF       		.byte	-1
 3218 0600 D8       		.byte	-40
 3219 0601 F0       		.byte	-16
 3220 0602 9A       		.byte	-102
 3221 0603 FF       		.byte	-1
 3222 0604 D8       		.byte	-40
 3223 0605 F0       		.byte	-16
 3224 0606 9A       		.byte	-102
 3225 0607 FF       		.byte	-1
 3226 0608 D9       		.byte	-39
 3227 0609 F0       		.byte	-16
 3228 060a 9A       		.byte	-102
 3229 060b FF       		.byte	-1
 3230 060c D9       		.byte	-39
 3231 060d F1       		.byte	-15
 3232 060e 9A       		.byte	-102
 3233 060f FF       		.byte	-1
 3234 0610 DA       		.byte	-38
 3235 0611 F1       		.byte	-15
 3236 0612 9A       		.byte	-102
 3237 0613 FF       		.byte	-1
 3238 0614 DA       		.byte	-38
 3239 0615 F1       		.byte	-15
 3240 0616 99       		.byte	-103
 3241 0617 FF       		.byte	-1
 3242 0618 DB       		.byte	-37
 3243 0619 F1       		.byte	-15
 3244 061a 99       		.byte	-103
 3245 061b FF       		.byte	-1
 3246 061c DB       		.byte	-37
 3247 061d F1       		.byte	-15
 3248 061e 99       		.byte	-103
 3249 061f FF       		.byte	-1
 3250 0620 DC       		.byte	-36
 3251 0621 F1       		.byte	-15
 3252 0622 99       		.byte	-103
 3253 0623 FF       		.byte	-1
 3254 0624 DC       		.byte	-36
 3255 0625 F2       		.byte	-14
 3256 0626 99       		.byte	-103
 3257 0627 FF       		.byte	-1
 3258 0628 DD       		.byte	-35
 3259 0629 F2       		.byte	-14
 3260 062a 99       		.byte	-103
 3261 062b FF       		.byte	-1
 3262 062c DD       		.byte	-35
 3263 062d F2       		.byte	-14
 3264 062e 99       		.byte	-103
 3265 062f FF       		.byte	-1
 3266 0630 DE       		.byte	-34
GAS LISTING /tmp/ccK2IhnQ.s 			page 73


 3267 0631 F2       		.byte	-14
 3268 0632 99       		.byte	-103
 3269 0633 FF       		.byte	-1
 3270 0634 DE       		.byte	-34
 3271 0635 F2       		.byte	-14
 3272 0636 99       		.byte	-103
 3273 0637 FF       		.byte	-1
 3274 0638 DF       		.byte	-33
 3275 0639 F2       		.byte	-14
 3276 063a 99       		.byte	-103
 3277 063b FF       		.byte	-1
 3278 063c DF       		.byte	-33
 3279 063d F3       		.byte	-13
 3280 063e 99       		.byte	-103
 3281 063f FF       		.byte	-1
 3282 0640 E0       		.byte	-32
 3283 0641 F3       		.byte	-13
 3284 0642 98       		.byte	-104
 3285 0643 FF       		.byte	-1
 3286 0644 E0       		.byte	-32
 3287 0645 F3       		.byte	-13
 3288 0646 98       		.byte	-104
 3289 0647 FF       		.byte	-1
 3290 0648 E1       		.byte	-31
 3291 0649 F3       		.byte	-13
 3292 064a 98       		.byte	-104
 3293 064b FF       		.byte	-1
 3294 064c E1       		.byte	-31
 3295 064d F3       		.byte	-13
 3296 064e 98       		.byte	-104
 3297 064f FF       		.byte	-1
 3298 0650 E2       		.byte	-30
 3299 0651 F3       		.byte	-13
 3300 0652 98       		.byte	-104
 3301 0653 FF       		.byte	-1
 3302 0654 E3       		.byte	-29
 3303 0655 F4       		.byte	-12
 3304 0656 98       		.byte	-104
 3305 0657 FF       		.byte	-1
 3306 0658 E3       		.byte	-29
 3307 0659 F4       		.byte	-12
 3308 065a 98       		.byte	-104
 3309 065b FF       		.byte	-1
 3310 065c E4       		.byte	-28
 3311 065d F4       		.byte	-12
 3312 065e 98       		.byte	-104
 3313 065f FF       		.byte	-1
 3314 0660 E4       		.byte	-28
 3315 0661 F4       		.byte	-12
 3316 0662 98       		.byte	-104
 3317 0663 FF       		.byte	-1
 3318 0664 E5       		.byte	-27
 3319 0665 F4       		.byte	-12
 3320 0666 98       		.byte	-104
 3321 0667 FF       		.byte	-1
 3322 0668 E5       		.byte	-27
 3323 0669 F4       		.byte	-12
GAS LISTING /tmp/ccK2IhnQ.s 			page 74


 3324 066a 98       		.byte	-104
 3325 066b FF       		.byte	-1
 3326 066c E6       		.byte	-26
 3327 066d F4       		.byte	-12
 3328 066e 97       		.byte	-105
 3329 066f FF       		.byte	-1
 3330 0670 E6       		.byte	-26
 3331 0671 F4       		.byte	-12
 3332 0672 97       		.byte	-105
 3333 0673 FF       		.byte	-1
 3334 0674 E6       		.byte	-26
 3335 0675 F4       		.byte	-12
 3336 0676 97       		.byte	-105
 3337 0677 FF       		.byte	-1
 3338 0678 E6       		.byte	-26
 3339 0679 F4       		.byte	-12
 3340 067a 97       		.byte	-105
 3341 067b FF       		.byte	-1
 3342 067c E6       		.byte	-26
 3343 067d F4       		.byte	-12
 3344 067e 97       		.byte	-105
 3345 067f FF       		.byte	-1
 3346 0680 E6       		.byte	-26
 3347 0681 F4       		.byte	-12
 3348 0682 97       		.byte	-105
 3349 0683 FF       		.byte	-1
 3350 0684 E6       		.byte	-26
 3351 0685 F4       		.byte	-12
 3352 0686 97       		.byte	-105
 3353 0687 FF       		.byte	-1
 3354 0688 E6       		.byte	-26
 3355 0689 F4       		.byte	-12
 3356 068a 97       		.byte	-105
 3357 068b FF       		.byte	-1
 3358 068c E6       		.byte	-26
 3359 068d F4       		.byte	-12
 3360 068e 97       		.byte	-105
 3361 068f FF       		.byte	-1
 3362 0690 E7       		.byte	-25
 3363 0691 F4       		.byte	-12
 3364 0692 97       		.byte	-105
 3365 0693 FF       		.byte	-1
 3366 0694 E7       		.byte	-25
 3367 0695 F4       		.byte	-12
 3368 0696 97       		.byte	-105
 3369 0697 FF       		.byte	-1
 3370 0698 E7       		.byte	-25
 3371 0699 F4       		.byte	-12
 3372 069a 97       		.byte	-105
 3373 069b FF       		.byte	-1
 3374 069c E7       		.byte	-25
 3375 069d F3       		.byte	-13
 3376 069e 97       		.byte	-105
 3377 069f FF       		.byte	-1
 3378 06a0 E7       		.byte	-25
 3379 06a1 F3       		.byte	-13
 3380 06a2 97       		.byte	-105
GAS LISTING /tmp/ccK2IhnQ.s 			page 75


 3381 06a3 FF       		.byte	-1
 3382 06a4 E7       		.byte	-25
 3383 06a5 F3       		.byte	-13
 3384 06a6 97       		.byte	-105
 3385 06a7 FF       		.byte	-1
 3386 06a8 E7       		.byte	-25
 3387 06a9 F3       		.byte	-13
 3388 06aa 97       		.byte	-105
 3389 06ab FF       		.byte	-1
 3390 06ac E7       		.byte	-25
 3391 06ad F3       		.byte	-13
 3392 06ae 96       		.byte	-106
 3393 06af FF       		.byte	-1
 3394 06b0 E7       		.byte	-25
 3395 06b1 F3       		.byte	-13
 3396 06b2 96       		.byte	-106
 3397 06b3 FF       		.byte	-1
 3398 06b4 E8       		.byte	-24
 3399 06b5 F3       		.byte	-13
 3400 06b6 96       		.byte	-106
 3401 06b7 FF       		.byte	-1
 3402 06b8 E8       		.byte	-24
 3403 06b9 F3       		.byte	-13
 3404 06ba 96       		.byte	-106
 3405 06bb FF       		.byte	-1
 3406 06bc E8       		.byte	-24
 3407 06bd F3       		.byte	-13
 3408 06be 96       		.byte	-106
 3409 06bf FF       		.byte	-1
 3410 06c0 E8       		.byte	-24
 3411 06c1 F3       		.byte	-13
 3412 06c2 96       		.byte	-106
 3413 06c3 FF       		.byte	-1
 3414 06c4 E8       		.byte	-24
 3415 06c5 F3       		.byte	-13
 3416 06c6 96       		.byte	-106
 3417 06c7 FF       		.byte	-1
 3418 06c8 E8       		.byte	-24
 3419 06c9 F3       		.byte	-13
 3420 06ca 96       		.byte	-106
 3421 06cb FF       		.byte	-1
 3422 06cc E8       		.byte	-24
 3423 06cd F3       		.byte	-13
 3424 06ce 96       		.byte	-106
 3425 06cf FF       		.byte	-1
 3426 06d0 E8       		.byte	-24
 3427 06d1 F2       		.byte	-14
 3428 06d2 96       		.byte	-106
 3429 06d3 FF       		.byte	-1
 3430 06d4 E8       		.byte	-24
 3431 06d5 F2       		.byte	-14
 3432 06d6 96       		.byte	-106
 3433 06d7 FF       		.byte	-1
 3434 06d8 E9       		.byte	-23
 3435 06d9 F2       		.byte	-14
 3436 06da 96       		.byte	-106
 3437 06db FF       		.byte	-1
GAS LISTING /tmp/ccK2IhnQ.s 			page 76


 3438 06dc E9       		.byte	-23
 3439 06dd F2       		.byte	-14
 3440 06de 96       		.byte	-106
 3441 06df FF       		.byte	-1
 3442 06e0 E9       		.byte	-23
 3443 06e1 F2       		.byte	-14
 3444 06e2 96       		.byte	-106
 3445 06e3 FF       		.byte	-1
 3446 06e4 E9       		.byte	-23
 3447 06e5 F2       		.byte	-14
 3448 06e6 96       		.byte	-106
 3449 06e7 FF       		.byte	-1
 3450 06e8 E9       		.byte	-23
 3451 06e9 F2       		.byte	-14
 3452 06ea 96       		.byte	-106
 3453 06eb FF       		.byte	-1
 3454 06ec E9       		.byte	-23
 3455 06ed F2       		.byte	-14
 3456 06ee 96       		.byte	-106
 3457 06ef FF       		.byte	-1
 3458 06f0 E9       		.byte	-23
 3459 06f1 F2       		.byte	-14
 3460 06f2 96       		.byte	-106
 3461 06f3 FF       		.byte	-1
 3462 06f4 E9       		.byte	-23
 3463 06f5 F2       		.byte	-14
 3464 06f6 95       		.byte	-107
 3465 06f7 FF       		.byte	-1
 3466 06f8 E9       		.byte	-23
 3467 06f9 F2       		.byte	-14
 3468 06fa 95       		.byte	-107
 3469 06fb FF       		.byte	-1
 3470 06fc EA       		.byte	-22
 3471 06fd F2       		.byte	-14
 3472 06fe 95       		.byte	-107
 3473 06ff FF       		.byte	-1
 3474 0700 EA       		.byte	-22
 3475 0701 F1       		.byte	-15
 3476 0702 95       		.byte	-107
 3477 0703 FF       		.byte	-1
 3478 0704 EA       		.byte	-22
 3479 0705 F1       		.byte	-15
 3480 0706 95       		.byte	-107
 3481 0707 FF       		.byte	-1
 3482 0708 EA       		.byte	-22
 3483 0709 F1       		.byte	-15
 3484 070a 95       		.byte	-107
 3485 070b FF       		.byte	-1
 3486 070c EA       		.byte	-22
 3487 070d F1       		.byte	-15
 3488 070e 95       		.byte	-107
 3489 070f FF       		.byte	-1
 3490 0710 EA       		.byte	-22
 3491 0711 F1       		.byte	-15
 3492 0712 95       		.byte	-107
 3493 0713 FF       		.byte	-1
 3494 0714 EA       		.byte	-22
GAS LISTING /tmp/ccK2IhnQ.s 			page 77


 3495 0715 F1       		.byte	-15
 3496 0716 95       		.byte	-107
 3497 0717 FF       		.byte	-1
 3498 0718 EA       		.byte	-22
 3499 0719 F1       		.byte	-15
 3500 071a 95       		.byte	-107
 3501 071b FF       		.byte	-1
 3502 071c EA       		.byte	-22
 3503 071d F1       		.byte	-15
 3504 071e 95       		.byte	-107
 3505 071f FF       		.byte	-1
 3506 0720 EB       		.byte	-21
 3507 0721 F1       		.byte	-15
 3508 0722 95       		.byte	-107
 3509 0723 FF       		.byte	-1
 3510 0724 EB       		.byte	-21
 3511 0725 F1       		.byte	-15
 3512 0726 95       		.byte	-107
 3513 0727 FF       		.byte	-1
 3514 0728 EB       		.byte	-21
 3515 0729 F1       		.byte	-15
 3516 072a 95       		.byte	-107
 3517 072b FF       		.byte	-1
 3518 072c EB       		.byte	-21
 3519 072d F1       		.byte	-15
 3520 072e 95       		.byte	-107
 3521 072f FF       		.byte	-1
 3522 0730 EB       		.byte	-21
 3523 0731 F0       		.byte	-16
 3524 0732 95       		.byte	-107
 3525 0733 FF       		.byte	-1
 3526 0734 EB       		.byte	-21
 3527 0735 F0       		.byte	-16
 3528 0736 95       		.byte	-107
 3529 0737 FF       		.byte	-1
 3530 0738 EB       		.byte	-21
 3531 0739 F0       		.byte	-16
 3532 073a 95       		.byte	-107
 3533 073b FF       		.byte	-1
 3534 073c EB       		.byte	-21
 3535 073d F0       		.byte	-16
 3536 073e 95       		.byte	-107
 3537 073f FF       		.byte	-1
 3538 0740 EB       		.byte	-21
 3539 0741 F0       		.byte	-16
 3540 0742 95       		.byte	-107
 3541 0743 FF       		.byte	-1
 3542 0744 EC       		.byte	-20
 3543 0745 F0       		.byte	-16
 3544 0746 94       		.byte	-108
 3545 0747 FF       		.byte	-1
 3546 0748 EC       		.byte	-20
 3547 0749 F0       		.byte	-16
 3548 074a 94       		.byte	-108
 3549 074b FF       		.byte	-1
 3550 074c EC       		.byte	-20
 3551 074d F0       		.byte	-16
GAS LISTING /tmp/ccK2IhnQ.s 			page 78


 3552 074e 94       		.byte	-108
 3553 074f FF       		.byte	-1
 3554 0750 EC       		.byte	-20
 3555 0751 F0       		.byte	-16
 3556 0752 94       		.byte	-108
 3557 0753 FF       		.byte	-1
 3558 0754 EC       		.byte	-20
 3559 0755 F0       		.byte	-16
 3560 0756 94       		.byte	-108
 3561 0757 FF       		.byte	-1
 3562 0758 EC       		.byte	-20
 3563 0759 F0       		.byte	-16
 3564 075a 94       		.byte	-108
 3565 075b FF       		.byte	-1
 3566 075c EC       		.byte	-20
 3567 075d F0       		.byte	-16
 3568 075e 94       		.byte	-108
 3569 075f FF       		.byte	-1
 3570 0760 EC       		.byte	-20
 3571 0761 EF       		.byte	-17
 3572 0762 94       		.byte	-108
 3573 0763 FF       		.byte	-1
 3574 0764 EC       		.byte	-20
 3575 0765 EF       		.byte	-17
 3576 0766 94       		.byte	-108
 3577 0767 FF       		.byte	-1
 3578 0768 EC       		.byte	-20
 3579 0769 EF       		.byte	-17
 3580 076a 94       		.byte	-108
 3581 076b FF       		.byte	-1
 3582 076c ED       		.byte	-19
 3583 076d EF       		.byte	-17
 3584 076e 94       		.byte	-108
 3585 076f FF       		.byte	-1
 3586 0770 ED       		.byte	-19
 3587 0771 EF       		.byte	-17
 3588 0772 94       		.byte	-108
 3589 0773 FF       		.byte	-1
 3590 0774 ED       		.byte	-19
 3591 0775 EF       		.byte	-17
 3592 0776 94       		.byte	-108
 3593 0777 FF       		.byte	-1
 3594 0778 ED       		.byte	-19
 3595 0779 EF       		.byte	-17
 3596 077a 94       		.byte	-108
 3597 077b FF       		.byte	-1
 3598 077c ED       		.byte	-19
 3599 077d EF       		.byte	-17
 3600 077e 94       		.byte	-108
 3601 077f FF       		.byte	-1
 3602 0780 ED       		.byte	-19
 3603 0781 EF       		.byte	-17
 3604 0782 94       		.byte	-108
 3605 0783 FF       		.byte	-1
 3606 0784 ED       		.byte	-19
 3607 0785 EF       		.byte	-17
 3608 0786 94       		.byte	-108
GAS LISTING /tmp/ccK2IhnQ.s 			page 79


 3609 0787 FF       		.byte	-1
 3610 0788 ED       		.byte	-19
 3611 0789 EF       		.byte	-17
 3612 078a 94       		.byte	-108
 3613 078b FF       		.byte	-1
 3614 078c ED       		.byte	-19
 3615 078d EF       		.byte	-17
 3616 078e 94       		.byte	-108
 3617 078f FF       		.byte	-1
 3618 0790 ED       		.byte	-19
 3619 0791 EE       		.byte	-18
 3620 0792 94       		.byte	-108
 3621 0793 FF       		.byte	-1
 3622 0794 EE       		.byte	-18
 3623 0795 EE       		.byte	-18
 3624 0796 94       		.byte	-108
 3625 0797 FF       		.byte	-1
 3626 0798 EE       		.byte	-18
 3627 0799 EE       		.byte	-18
 3628 079a 94       		.byte	-108
 3629 079b FF       		.byte	-1
 3630 079c EE       		.byte	-18
 3631 079d EE       		.byte	-18
 3632 079e 94       		.byte	-108
 3633 079f FF       		.byte	-1
 3634 07a0 EE       		.byte	-18
 3635 07a1 EE       		.byte	-18
 3636 07a2 94       		.byte	-108
 3637 07a3 FF       		.byte	-1
 3638 07a4 EE       		.byte	-18
 3639 07a5 EE       		.byte	-18
 3640 07a6 93       		.byte	-109
 3641 07a7 FF       		.byte	-1
 3642 07a8 EE       		.byte	-18
 3643 07a9 EE       		.byte	-18
 3644 07aa 93       		.byte	-109
 3645 07ab FF       		.byte	-1
 3646 07ac EE       		.byte	-18
 3647 07ad EE       		.byte	-18
 3648 07ae 93       		.byte	-109
 3649 07af FF       		.byte	-1
 3650 07b0 EE       		.byte	-18
 3651 07b1 EE       		.byte	-18
 3652 07b2 93       		.byte	-109
 3653 07b3 FF       		.byte	-1
 3654 07b4 EE       		.byte	-18
 3655 07b5 EE       		.byte	-18
 3656 07b6 93       		.byte	-109
 3657 07b7 FF       		.byte	-1
 3658 07b8 EE       		.byte	-18
 3659 07b9 EE       		.byte	-18
 3660 07ba 93       		.byte	-109
 3661 07bb FF       		.byte	-1
 3662 07bc EF       		.byte	-17
 3663 07bd EE       		.byte	-18
 3664 07be 93       		.byte	-109
 3665 07bf FF       		.byte	-1
GAS LISTING /tmp/ccK2IhnQ.s 			page 80


 3666 07c0 EF       		.byte	-17
 3667 07c1 ED       		.byte	-19
 3668 07c2 93       		.byte	-109
 3669 07c3 FF       		.byte	-1
 3670 07c4 EF       		.byte	-17
 3671 07c5 ED       		.byte	-19
 3672 07c6 93       		.byte	-109
 3673 07c7 FF       		.byte	-1
 3674 07c8 EF       		.byte	-17
 3675 07c9 ED       		.byte	-19
 3676 07ca 93       		.byte	-109
 3677 07cb FF       		.byte	-1
 3678 07cc EF       		.byte	-17
 3679 07cd ED       		.byte	-19
 3680 07ce 93       		.byte	-109
 3681 07cf FF       		.byte	-1
 3682 07d0 EF       		.byte	-17
 3683 07d1 ED       		.byte	-19
 3684 07d2 93       		.byte	-109
 3685 07d3 FF       		.byte	-1
 3686 07d4 EF       		.byte	-17
 3687 07d5 ED       		.byte	-19
 3688 07d6 93       		.byte	-109
 3689 07d7 FF       		.byte	-1
 3690 07d8 EF       		.byte	-17
 3691 07d9 ED       		.byte	-19
 3692 07da 93       		.byte	-109
 3693 07db FF       		.byte	-1
 3694 07dc EF       		.byte	-17
 3695 07dd ED       		.byte	-19
 3696 07de 93       		.byte	-109
 3697 07df FF       		.byte	-1
 3698 07e0 EF       		.byte	-17
 3699 07e1 ED       		.byte	-19
 3700 07e2 93       		.byte	-109
 3701 07e3 FF       		.byte	-1
 3702 07e4 F0       		.byte	-16
 3703 07e5 ED       		.byte	-19
 3704 07e6 93       		.byte	-109
 3705 07e7 FF       		.byte	-1
 3706 07e8 F0       		.byte	-16
 3707 07e9 ED       		.byte	-19
 3708 07ea 93       		.byte	-109
 3709 07eb FF       		.byte	-1
 3710 07ec F0       		.byte	-16
 3711 07ed ED       		.byte	-19
 3712 07ee 93       		.byte	-109
 3713 07ef FF       		.byte	-1
 3714 07f0 F0       		.byte	-16
 3715 07f1 EC       		.byte	-20
 3716 07f2 93       		.byte	-109
 3717 07f3 FF       		.byte	-1
 3718 07f4 F0       		.byte	-16
 3719 07f5 EC       		.byte	-20
 3720 07f6 93       		.byte	-109
 3721 07f7 FF       		.byte	-1
 3722 07f8 F0       		.byte	-16
GAS LISTING /tmp/ccK2IhnQ.s 			page 81


 3723 07f9 EC       		.byte	-20
 3724 07fa 93       		.byte	-109
 3725 07fb FF       		.byte	-1
 3726 07fc F0       		.byte	-16
 3727 07fd EC       		.byte	-20
 3728 07fe 93       		.byte	-109
 3729 07ff FF       		.byte	-1
 3730 0800 F0       		.byte	-16
 3731 0801 EC       		.byte	-20
 3732 0802 93       		.byte	-109
 3733 0803 FF       		.byte	-1
 3734 0804 F5       		.byte	-11
 3735 0805 E8       		.byte	-24
 3736 0806 91       		.byte	-111
 3737 0807 FF       		.byte	-1
 3738 0808 F5       		.byte	-11
 3739 0809 E8       		.byte	-24
 3740 080a 91       		.byte	-111
 3741 080b FF       		.byte	-1
 3742 080c F5       		.byte	-11
 3743 080d E8       		.byte	-24
 3744 080e 91       		.byte	-111
 3745 080f FF       		.byte	-1
 3746 0810 F5       		.byte	-11
 3747 0811 E8       		.byte	-24
 3748 0812 91       		.byte	-111
 3749 0813 FF       		.byte	-1
 3750 0814 F5       		.byte	-11
 3751 0815 E8       		.byte	-24
 3752 0816 91       		.byte	-111
 3753 0817 FF       		.byte	-1
 3754 0818 F6       		.byte	-10
 3755 0819 E7       		.byte	-25
 3756 081a 91       		.byte	-111
 3757 081b FF       		.byte	-1
 3758 081c F6       		.byte	-10
 3759 081d E7       		.byte	-25
 3760 081e 91       		.byte	-111
 3761 081f FF       		.byte	-1
 3762 0820 F6       		.byte	-10
 3763 0821 E7       		.byte	-25
 3764 0822 91       		.byte	-111
 3765 0823 FF       		.byte	-1
 3766 0824 F6       		.byte	-10
 3767 0825 E7       		.byte	-25
 3768 0826 91       		.byte	-111
 3769 0827 FF       		.byte	-1
 3770 0828 F6       		.byte	-10
 3771 0829 E7       		.byte	-25
 3772 082a 91       		.byte	-111
 3773 082b FF       		.byte	-1
 3774 082c F6       		.byte	-10
 3775 082d E7       		.byte	-25
 3776 082e 91       		.byte	-111
 3777 082f FF       		.byte	-1
 3778 0830 F6       		.byte	-10
 3779 0831 E7       		.byte	-25
GAS LISTING /tmp/ccK2IhnQ.s 			page 82


 3780 0832 91       		.byte	-111
 3781 0833 FF       		.byte	-1
 3782 0834 F6       		.byte	-10
 3783 0835 E7       		.byte	-25
 3784 0836 91       		.byte	-111
 3785 0837 FF       		.byte	-1
 3786 0838 F6       		.byte	-10
 3787 0839 E7       		.byte	-25
 3788 083a 91       		.byte	-111
 3789 083b FF       		.byte	-1
 3790 083c F6       		.byte	-10
 3791 083d E7       		.byte	-25
 3792 083e 91       		.byte	-111
 3793 083f FF       		.byte	-1
 3794 0840 F6       		.byte	-10
 3795 0841 E7       		.byte	-25
 3796 0842 91       		.byte	-111
 3797 0843 FF       		.byte	-1
 3798 0844 F7       		.byte	-9
 3799 0845 E7       		.byte	-25
 3800 0846 91       		.byte	-111
 3801 0847 FF       		.byte	-1
 3802 0848 F7       		.byte	-9
 3803 0849 E6       		.byte	-26
 3804 084a 91       		.byte	-111
 3805 084b FF       		.byte	-1
 3806 084c F7       		.byte	-9
 3807 084d E6       		.byte	-26
 3808 084e 91       		.byte	-111
 3809 084f FF       		.byte	-1
 3810 0850 F7       		.byte	-9
 3811 0851 E6       		.byte	-26
 3812 0852 91       		.byte	-111
 3813 0853 FF       		.byte	-1
 3814 0854 F7       		.byte	-9
 3815 0855 E6       		.byte	-26
 3816 0856 91       		.byte	-111
 3817 0857 FF       		.byte	-1
 3818 0858 F7       		.byte	-9
 3819 0859 E6       		.byte	-26
 3820 085a 90       		.byte	-112
 3821 085b FF       		.byte	-1
 3822 085c F7       		.byte	-9
 3823 085d E6       		.byte	-26
 3824 085e 90       		.byte	-112
 3825 085f FF       		.byte	-1
 3826 0860 F7       		.byte	-9
 3827 0861 E6       		.byte	-26
 3828 0862 90       		.byte	-112
 3829 0863 FF       		.byte	-1
 3830 0864 F7       		.byte	-9
 3831 0865 E6       		.byte	-26
 3832 0866 90       		.byte	-112
 3833 0867 FF       		.byte	-1
 3834 0868 F7       		.byte	-9
 3835 0869 E6       		.byte	-26
 3836 086a 90       		.byte	-112
GAS LISTING /tmp/ccK2IhnQ.s 			page 83


 3837 086b FF       		.byte	-1
 3838 086c F7       		.byte	-9
 3839 086d E6       		.byte	-26
 3840 086e 90       		.byte	-112
 3841 086f FF       		.byte	-1
 3842 0870 F8       		.byte	-8
 3843 0871 E6       		.byte	-26
 3844 0872 90       		.byte	-112
 3845 0873 FF       		.byte	-1
 3846 0874 F8       		.byte	-8
 3847 0875 E6       		.byte	-26
 3848 0876 90       		.byte	-112
 3849 0877 FF       		.byte	-1
 3850 0878 F8       		.byte	-8
 3851 0879 E5       		.byte	-27
 3852 087a 90       		.byte	-112
 3853 087b FF       		.byte	-1
 3854 087c F8       		.byte	-8
 3855 087d E5       		.byte	-27
 3856 087e 90       		.byte	-112
 3857 087f FF       		.byte	-1
 3858 0880 F8       		.byte	-8
 3859 0881 E5       		.byte	-27
 3860 0882 90       		.byte	-112
 3861 0883 FF       		.byte	-1
 3862 0884 F8       		.byte	-8
 3863 0885 E5       		.byte	-27
 3864 0886 90       		.byte	-112
 3865 0887 FF       		.byte	-1
 3866 0888 F8       		.byte	-8
 3867 0889 E5       		.byte	-27
 3868 088a 90       		.byte	-112
 3869 088b FF       		.byte	-1
 3870 088c F8       		.byte	-8
 3871 088d E5       		.byte	-27
 3872 088e 90       		.byte	-112
 3873 088f FF       		.byte	-1
 3874 0890 F8       		.byte	-8
 3875 0891 E5       		.byte	-27
 3876 0892 90       		.byte	-112
 3877 0893 FF       		.byte	-1
 3878 0894 F8       		.byte	-8
 3879 0895 E5       		.byte	-27
 3880 0896 90       		.byte	-112
 3881 0897 FF       		.byte	-1
 3882 0898 F8       		.byte	-8
 3883 0899 E5       		.byte	-27
 3884 089a 90       		.byte	-112
 3885 089b FF       		.byte	-1
 3886 089c F8       		.byte	-8
 3887 089d E5       		.byte	-27
 3888 089e 90       		.byte	-112
 3889 089f FF       		.byte	-1
 3890 08a0 F9       		.byte	-7
 3891 08a1 E5       		.byte	-27
 3892 08a2 90       		.byte	-112
 3893 08a3 FF       		.byte	-1
GAS LISTING /tmp/ccK2IhnQ.s 			page 84


 3894 08a4 F9       		.byte	-7
 3895 08a5 E5       		.byte	-27
 3896 08a6 90       		.byte	-112
 3897 08a7 FF       		.byte	-1
 3898 08a8 F9       		.byte	-7
 3899 08a9 E5       		.byte	-27
 3900 08aa 90       		.byte	-112
 3901 08ab FF       		.byte	-1
 3902 08ac F9       		.byte	-7
 3903 08ad E4       		.byte	-28
 3904 08ae 90       		.byte	-112
 3905 08af FF       		.byte	-1
 3906 08b0 F9       		.byte	-7
 3907 08b1 E4       		.byte	-28
 3908 08b2 90       		.byte	-112
 3909 08b3 FF       		.byte	-1
 3910 08b4 F9       		.byte	-7
 3911 08b5 E4       		.byte	-28
 3912 08b6 90       		.byte	-112
 3913 08b7 FF       		.byte	-1
 3914 08b8 F9       		.byte	-7
 3915 08b9 E4       		.byte	-28
 3916 08ba 90       		.byte	-112
 3917 08bb FF       		.byte	-1
 3918 08bc F9       		.byte	-7
 3919 08bd E4       		.byte	-28
 3920 08be 90       		.byte	-112
 3921 08bf FF       		.byte	-1
 3922 08c0 F9       		.byte	-7
 3923 08c1 E4       		.byte	-28
 3924 08c2 90       		.byte	-112
 3925 08c3 FF       		.byte	-1
 3926 08c4 F9       		.byte	-7
 3927 08c5 E4       		.byte	-28
 3928 08c6 90       		.byte	-112
 3929 08c7 FF       		.byte	-1
 3930 08c8 F9       		.byte	-7
 3931 08c9 E4       		.byte	-28
 3932 08ca 90       		.byte	-112
 3933 08cb FF       		.byte	-1
 3934 08cc F9       		.byte	-7
 3935 08cd E4       		.byte	-28
 3936 08ce 90       		.byte	-112
 3937 08cf FF       		.byte	-1
 3938 08d0 FA       		.byte	-6
 3939 08d1 E4       		.byte	-28
 3940 08d2 90       		.byte	-112
 3941 08d3 FF       		.byte	-1
 3942 08d4 FA       		.byte	-6
 3943 08d5 E4       		.byte	-28
 3944 08d6 90       		.byte	-112
 3945 08d7 FF       		.byte	-1
 3946 08d8 FA       		.byte	-6
 3947 08d9 E4       		.byte	-28
 3948 08da 90       		.byte	-112
 3949 08db FF       		.byte	-1
 3950 08dc FA       		.byte	-6
GAS LISTING /tmp/ccK2IhnQ.s 			page 85


 3951 08dd E3       		.byte	-29
 3952 08de 90       		.byte	-112
 3953 08df FF       		.byte	-1
 3954 08e0 FA       		.byte	-6
 3955 08e1 E3       		.byte	-29
 3956 08e2 90       		.byte	-112
 3957 08e3 FF       		.byte	-1
 3958 08e4 FA       		.byte	-6
 3959 08e5 E3       		.byte	-29
 3960 08e6 90       		.byte	-112
 3961 08e7 FF       		.byte	-1
 3962 08e8 FA       		.byte	-6
 3963 08e9 E3       		.byte	-29
 3964 08ea 90       		.byte	-112
 3965 08eb FF       		.byte	-1
 3966 08ec FA       		.byte	-6
 3967 08ed E3       		.byte	-29
 3968 08ee 90       		.byte	-112
 3969 08ef FF       		.byte	-1
 3970 08f0 FA       		.byte	-6
 3971 08f1 E3       		.byte	-29
 3972 08f2 90       		.byte	-112
 3973 08f3 FF       		.byte	-1
 3974 08f4 FA       		.byte	-6
 3975 08f5 E3       		.byte	-29
 3976 08f6 90       		.byte	-112
 3977 08f7 FF       		.byte	-1
 3978 08f8 FA       		.byte	-6
 3979 08f9 E3       		.byte	-29
 3980 08fa 90       		.byte	-112
 3981 08fb FF       		.byte	-1
 3982 08fc FA       		.byte	-6
 3983 08fd E3       		.byte	-29
 3984 08fe 90       		.byte	-112
 3985 08ff FF       		.byte	-1
 3986 0900 FB       		.byte	-5
 3987 0901 E3       		.byte	-29
 3988 0902 90       		.byte	-112
 3989 0903 FF       		.byte	-1
 3990 0904 FB       		.byte	-5
 3991 0905 E3       		.byte	-29
 3992 0906 90       		.byte	-112
 3993 0907 FF       		.byte	-1
 3994 0908 FB       		.byte	-5
 3995 0909 E3       		.byte	-29
 3996 090a 90       		.byte	-112
 3997 090b FF       		.byte	-1
 3998 090c FB       		.byte	-5
 3999 090d E2       		.byte	-30
 4000 090e 90       		.byte	-112
 4001 090f FF       		.byte	-1
 4002 0910 FB       		.byte	-5
 4003 0911 E2       		.byte	-30
 4004 0912 90       		.byte	-112
 4005 0913 FF       		.byte	-1
 4006 0914 FB       		.byte	-5
 4007 0915 E2       		.byte	-30
GAS LISTING /tmp/ccK2IhnQ.s 			page 86


 4008 0916 90       		.byte	-112
 4009 0917 FF       		.byte	-1
 4010 0918 FB       		.byte	-5
 4011 0919 E2       		.byte	-30
 4012 091a 90       		.byte	-112
 4013 091b FF       		.byte	-1
 4014 091c FB       		.byte	-5
 4015 091d E2       		.byte	-30
 4016 091e 90       		.byte	-112
 4017 091f FF       		.byte	-1
 4018 0920 FB       		.byte	-5
 4019 0921 E2       		.byte	-30
 4020 0922 90       		.byte	-112
 4021 0923 FF       		.byte	-1
 4022 0924 FB       		.byte	-5
 4023 0925 E2       		.byte	-30
 4024 0926 90       		.byte	-112
 4025 0927 FF       		.byte	-1
 4026 0928 FB       		.byte	-5
 4027 0929 E2       		.byte	-30
 4028 092a 90       		.byte	-112
 4029 092b FF       		.byte	-1
 4030 092c FB       		.byte	-5
 4031 092d E2       		.byte	-30
 4032 092e 90       		.byte	-112
 4033 092f FF       		.byte	-1
 4034 0930 FB       		.byte	-5
 4035 0931 E2       		.byte	-30
 4036 0932 90       		.byte	-112
 4037 0933 FF       		.byte	-1
 4038 0934 FC       		.byte	-4
 4039 0935 E2       		.byte	-30
 4040 0936 90       		.byte	-112
 4041 0937 FF       		.byte	-1
 4042 0938 FC       		.byte	-4
 4043 0939 E2       		.byte	-30
 4044 093a 90       		.byte	-112
 4045 093b FF       		.byte	-1
 4046 093c FC       		.byte	-4
 4047 093d E1       		.byte	-31
 4048 093e 90       		.byte	-112
 4049 093f FF       		.byte	-1
 4050 0940 FC       		.byte	-4
 4051 0941 E1       		.byte	-31
 4052 0942 90       		.byte	-112
 4053 0943 FF       		.byte	-1
 4054 0944 FC       		.byte	-4
 4055 0945 E1       		.byte	-31
 4056 0946 90       		.byte	-112
 4057 0947 FF       		.byte	-1
 4058 0948 FC       		.byte	-4
 4059 0949 E1       		.byte	-31
 4060 094a 90       		.byte	-112
 4061 094b FF       		.byte	-1
 4062 094c FC       		.byte	-4
 4063 094d E1       		.byte	-31
 4064 094e 90       		.byte	-112
GAS LISTING /tmp/ccK2IhnQ.s 			page 87


 4065 094f FF       		.byte	-1
 4066 0950 FC       		.byte	-4
 4067 0951 E1       		.byte	-31
 4068 0952 90       		.byte	-112
 4069 0953 FF       		.byte	-1
 4070 0954 FC       		.byte	-4
 4071 0955 E1       		.byte	-31
 4072 0956 90       		.byte	-112
 4073 0957 FF       		.byte	-1
 4074 0958 FC       		.byte	-4
 4075 0959 E1       		.byte	-31
 4076 095a 90       		.byte	-112
 4077 095b FF       		.byte	-1
 4078 095c FC       		.byte	-4
 4079 095d E1       		.byte	-31
 4080 095e 90       		.byte	-112
 4081 095f FF       		.byte	-1
 4082 0960 FC       		.byte	-4
 4083 0961 E1       		.byte	-31
 4084 0962 90       		.byte	-112
 4085 0963 FF       		.byte	-1
 4086 0964 FC       		.byte	-4
 4087 0965 E1       		.byte	-31
 4088 0966 90       		.byte	-112
 4089 0967 FF       		.byte	-1
 4090 0968 FD       		.byte	-3
 4091 0969 E1       		.byte	-31
 4092 096a 90       		.byte	-112
 4093 096b FF       		.byte	-1
 4094 096c FD       		.byte	-3
 4095 096d E1       		.byte	-31
 4096 096e 90       		.byte	-112
 4097 096f FF       		.byte	-1
 4098 0970 FD       		.byte	-3
 4099 0971 E0       		.byte	-32
 4100 0972 90       		.byte	-112
 4101 0973 FF       		.byte	-1
 4102 0974 FD       		.byte	-3
 4103 0975 E0       		.byte	-32
 4104 0976 90       		.byte	-112
 4105 0977 FF       		.byte	-1
 4106 0978 FD       		.byte	-3
 4107 0979 E0       		.byte	-32
 4108 097a 90       		.byte	-112
 4109 097b FF       		.byte	-1
 4110 097c FD       		.byte	-3
 4111 097d E0       		.byte	-32
 4112 097e 90       		.byte	-112
 4113 097f FF       		.byte	-1
 4114 0980 FD       		.byte	-3
 4115 0981 E0       		.byte	-32
 4116 0982 90       		.byte	-112
 4117 0983 FF       		.byte	-1
 4118 0984 FD       		.byte	-3
 4119 0985 E0       		.byte	-32
 4120 0986 90       		.byte	-112
 4121 0987 FF       		.byte	-1
GAS LISTING /tmp/ccK2IhnQ.s 			page 88


 4122 0988 FD       		.byte	-3
 4123 0989 E0       		.byte	-32
 4124 098a 90       		.byte	-112
 4125 098b FF       		.byte	-1
 4126 098c FD       		.byte	-3
 4127 098d E0       		.byte	-32
 4128 098e 90       		.byte	-112
 4129 098f FF       		.byte	-1
 4130 0990 FD       		.byte	-3
 4131 0991 E0       		.byte	-32
 4132 0992 90       		.byte	-112
 4133 0993 FF       		.byte	-1
 4134 0994 FD       		.byte	-3
 4135 0995 E0       		.byte	-32
 4136 0996 90       		.byte	-112
 4137 0997 FF       		.byte	-1
 4138 0998 FD       		.byte	-3
 4139 0999 E0       		.byte	-32
 4140 099a 90       		.byte	-112
 4141 099b FF       		.byte	-1
 4142 099c FD       		.byte	-3
 4143 099d E0       		.byte	-32
 4144 099e 90       		.byte	-112
 4145 099f FF       		.byte	-1
 4146 09a0 FD       		.byte	-3
 4147 09a1 DF       		.byte	-33
 4148 09a2 8F       		.byte	-113
 4149 09a3 FF       		.byte	-1
 4150 09a4 FD       		.byte	-3
 4151 09a5 DF       		.byte	-33
 4152 09a6 8F       		.byte	-113
 4153 09a7 FF       		.byte	-1
 4154 09a8 FD       		.byte	-3
 4155 09a9 DF       		.byte	-33
 4156 09aa 8E       		.byte	-114
 4157 09ab FF       		.byte	-1
 4158 09ac FD       		.byte	-3
 4159 09ad DE       		.byte	-34
 4160 09ae 8E       		.byte	-114
 4161 09af FF       		.byte	-1
 4162 09b0 FD       		.byte	-3
 4163 09b1 DE       		.byte	-34
 4164 09b2 8D       		.byte	-115
 4165 09b3 FF       		.byte	-1
 4166 09b4 FD       		.byte	-3
 4167 09b5 DD       		.byte	-35
 4168 09b6 8D       		.byte	-115
 4169 09b7 FF       		.byte	-1
 4170 09b8 FD       		.byte	-3
 4171 09b9 DD       		.byte	-35
 4172 09ba 8D       		.byte	-115
 4173 09bb FF       		.byte	-1
 4174 09bc FD       		.byte	-3
 4175 09bd DD       		.byte	-35
 4176 09be 8C       		.byte	-116
 4177 09bf FF       		.byte	-1
 4178 09c0 FD       		.byte	-3
GAS LISTING /tmp/ccK2IhnQ.s 			page 89


 4179 09c1 DC       		.byte	-36
 4180 09c2 8C       		.byte	-116
 4181 09c3 FF       		.byte	-1
 4182 09c4 FD       		.byte	-3
 4183 09c5 DC       		.byte	-36
 4184 09c6 8B       		.byte	-117
 4185 09c7 FF       		.byte	-1
 4186 09c8 FD       		.byte	-3
 4187 09c9 DC       		.byte	-36
 4188 09ca 8B       		.byte	-117
 4189 09cb FF       		.byte	-1
 4190 09cc FD       		.byte	-3
 4191 09cd DB       		.byte	-37
 4192 09ce 8A       		.byte	-118
 4193 09cf FF       		.byte	-1
 4194 09d0 FD       		.byte	-3
 4195 09d1 DB       		.byte	-37
 4196 09d2 8A       		.byte	-118
 4197 09d3 FF       		.byte	-1
 4198 09d4 FD       		.byte	-3
 4199 09d5 DA       		.byte	-38
 4200 09d6 8A       		.byte	-118
 4201 09d7 FF       		.byte	-1
 4202 09d8 FD       		.byte	-3
 4203 09d9 DA       		.byte	-38
 4204 09da 89       		.byte	-119
 4205 09db FF       		.byte	-1
 4206 09dc FD       		.byte	-3
 4207 09dd DA       		.byte	-38
 4208 09de 89       		.byte	-119
 4209 09df FF       		.byte	-1
 4210 09e0 FD       		.byte	-3
 4211 09e1 D9       		.byte	-39
 4212 09e2 88       		.byte	-120
 4213 09e3 FF       		.byte	-1
 4214 09e4 FD       		.byte	-3
 4215 09e5 D9       		.byte	-39
 4216 09e6 88       		.byte	-120
 4217 09e7 FF       		.byte	-1
 4218 09e8 FD       		.byte	-3
 4219 09e9 D9       		.byte	-39
 4220 09ea 87       		.byte	-121
 4221 09eb FF       		.byte	-1
 4222 09ec FD       		.byte	-3
 4223 09ed D8       		.byte	-40
 4224 09ee 87       		.byte	-121
 4225 09ef FF       		.byte	-1
 4226 09f0 FD       		.byte	-3
 4227 09f1 D8       		.byte	-40
 4228 09f2 87       		.byte	-121
 4229 09f3 FF       		.byte	-1
 4230 09f4 FD       		.byte	-3
 4231 09f5 D7       		.byte	-41
 4232 09f6 86       		.byte	-122
 4233 09f7 FF       		.byte	-1
 4234 09f8 FD       		.byte	-3
 4235 09f9 D7       		.byte	-41
GAS LISTING /tmp/ccK2IhnQ.s 			page 90


 4236 09fa 86       		.byte	-122
 4237 09fb FF       		.byte	-1
 4238 09fc FD       		.byte	-3
 4239 09fd D7       		.byte	-41
 4240 09fe 85       		.byte	-123
 4241 09ff FF       		.byte	-1
 4242 0a00 FD       		.byte	-3
 4243 0a01 D6       		.byte	-42
 4244 0a02 85       		.byte	-123
 4245 0a03 FF       		.byte	-1
 4246 0a04 FD       		.byte	-3
 4247 0a05 D6       		.byte	-42
 4248 0a06 85       		.byte	-123
 4249 0a07 FF       		.byte	-1
 4250 0a08 FD       		.byte	-3
 4251 0a09 D6       		.byte	-42
 4252 0a0a 84       		.byte	-124
 4253 0a0b FF       		.byte	-1
 4254 0a0c FD       		.byte	-3
 4255 0a0d D5       		.byte	-43
 4256 0a0e 84       		.byte	-124
 4257 0a0f FF       		.byte	-1
 4258 0a10 FD       		.byte	-3
 4259 0a11 D5       		.byte	-43
 4260 0a12 83       		.byte	-125
 4261 0a13 FF       		.byte	-1
 4262 0a14 FD       		.byte	-3
 4263 0a15 D4       		.byte	-44
 4264 0a16 83       		.byte	-125
 4265 0a17 FF       		.byte	-1
 4266 0a18 FD       		.byte	-3
 4267 0a19 D4       		.byte	-44
 4268 0a1a 83       		.byte	-125
 4269 0a1b FF       		.byte	-1
 4270 0a1c FD       		.byte	-3
 4271 0a1d D4       		.byte	-44
 4272 0a1e 82       		.byte	-126
 4273 0a1f FF       		.byte	-1
 4274 0a20 FD       		.byte	-3
 4275 0a21 D3       		.byte	-45
 4276 0a22 82       		.byte	-126
 4277 0a23 FF       		.byte	-1
 4278 0a24 FD       		.byte	-3
 4279 0a25 D3       		.byte	-45
 4280 0a26 81       		.byte	-127
 4281 0a27 FF       		.byte	-1
 4282 0a28 FD       		.byte	-3
 4283 0a29 D3       		.byte	-45
 4284 0a2a 81       		.byte	-127
 4285 0a2b FF       		.byte	-1
 4286 0a2c FD       		.byte	-3
 4287 0a2d D2       		.byte	-46
 4288 0a2e 81       		.byte	-127
 4289 0a2f FF       		.byte	-1
 4290 0a30 FD       		.byte	-3
 4291 0a31 D2       		.byte	-46
 4292 0a32 80       		.byte	-128
GAS LISTING /tmp/ccK2IhnQ.s 			page 91


 4293 0a33 FF       		.byte	-1
 4294 0a34 FD       		.byte	-3
 4295 0a35 D1       		.byte	-47
 4296 0a36 80       		.byte	-128
 4297 0a37 FF       		.byte	-1
 4298 0a38 FD       		.byte	-3
 4299 0a39 D1       		.byte	-47
 4300 0a3a 7F       		.byte	127
 4301 0a3b FF       		.byte	-1
 4302 0a3c FD       		.byte	-3
 4303 0a3d D1       		.byte	-47
 4304 0a3e 7F       		.byte	127
 4305 0a3f FF       		.byte	-1
 4306 0a40 FD       		.byte	-3
 4307 0a41 D0       		.byte	-48
 4308 0a42 7F       		.byte	127
 4309 0a43 FF       		.byte	-1
 4310 0a44 FD       		.byte	-3
 4311 0a45 D0       		.byte	-48
 4312 0a46 7E       		.byte	126
 4313 0a47 FF       		.byte	-1
 4314 0a48 FD       		.byte	-3
 4315 0a49 CF       		.byte	-49
 4316 0a4a 7E       		.byte	126
 4317 0a4b FF       		.byte	-1
 4318 0a4c FD       		.byte	-3
 4319 0a4d CF       		.byte	-49
 4320 0a4e 7D       		.byte	125
 4321 0a4f FF       		.byte	-1
 4322 0a50 FD       		.byte	-3
 4323 0a51 CF       		.byte	-49
 4324 0a52 7D       		.byte	125
 4325 0a53 FF       		.byte	-1
 4326 0a54 FD       		.byte	-3
 4327 0a55 CE       		.byte	-50
 4328 0a56 7D       		.byte	125
 4329 0a57 FF       		.byte	-1
 4330 0a58 FD       		.byte	-3
 4331 0a59 CE       		.byte	-50
 4332 0a5a 7C       		.byte	124
 4333 0a5b FF       		.byte	-1
 4334 0a5c FD       		.byte	-3
 4335 0a5d CD       		.byte	-51
 4336 0a5e 7C       		.byte	124
 4337 0a5f FF       		.byte	-1
 4338 0a60 FD       		.byte	-3
 4339 0a61 CD       		.byte	-51
 4340 0a62 7B       		.byte	123
 4341 0a63 FF       		.byte	-1
 4342 0a64 FD       		.byte	-3
 4343 0a65 CD       		.byte	-51
 4344 0a66 7B       		.byte	123
 4345 0a67 FF       		.byte	-1
 4346 0a68 FD       		.byte	-3
 4347 0a69 CC       		.byte	-52
 4348 0a6a 7B       		.byte	123
 4349 0a6b FF       		.byte	-1
GAS LISTING /tmp/ccK2IhnQ.s 			page 92


 4350 0a6c FD       		.byte	-3
 4351 0a6d C2       		.byte	-62
 4352 0a6e 71       		.byte	113
 4353 0a6f FF       		.byte	-1
 4354 0a70 FD       		.byte	-3
 4355 0a71 C2       		.byte	-62
 4356 0a72 71       		.byte	113
 4357 0a73 FF       		.byte	-1
 4358 0a74 FD       		.byte	-3
 4359 0a75 C1       		.byte	-63
 4360 0a76 70       		.byte	112
 4361 0a77 FF       		.byte	-1
 4362 0a78 FD       		.byte	-3
 4363 0a79 C1       		.byte	-63
 4364 0a7a 70       		.byte	112
 4365 0a7b FF       		.byte	-1
 4366 0a7c FD       		.byte	-3
 4367 0a7d C0       		.byte	-64
 4368 0a7e 70       		.byte	112
 4369 0a7f FF       		.byte	-1
 4370 0a80 FD       		.byte	-3
 4371 0a81 C0       		.byte	-64
 4372 0a82 6F       		.byte	111
 4373 0a83 FF       		.byte	-1
 4374 0a84 FD       		.byte	-3
 4375 0a85 C0       		.byte	-64
 4376 0a86 6F       		.byte	111
 4377 0a87 FF       		.byte	-1
 4378 0a88 FD       		.byte	-3
 4379 0a89 BF       		.byte	-65
 4380 0a8a 6E       		.byte	110
 4381 0a8b FF       		.byte	-1
 4382 0a8c FD       		.byte	-3
 4383 0a8d BF       		.byte	-65
 4384 0a8e 6E       		.byte	110
 4385 0a8f FF       		.byte	-1
 4386 0a90 FD       		.byte	-3
 4387 0a91 BE       		.byte	-66
 4388 0a92 6E       		.byte	110
 4389 0a93 FF       		.byte	-1
 4390 0a94 FD       		.byte	-3
 4391 0a95 BE       		.byte	-66
 4392 0a96 6D       		.byte	109
 4393 0a97 FF       		.byte	-1
 4394 0a98 FD       		.byte	-3
 4395 0a99 BE       		.byte	-66
 4396 0a9a 6D       		.byte	109
 4397 0a9b FF       		.byte	-1
 4398 0a9c FD       		.byte	-3
 4399 0a9d BD       		.byte	-67
 4400 0a9e 6D       		.byte	109
 4401 0a9f FF       		.byte	-1
 4402 0aa0 FD       		.byte	-3
 4403 0aa1 BD       		.byte	-67
 4404 0aa2 6C       		.byte	108
 4405 0aa3 FF       		.byte	-1
 4406 0aa4 FD       		.byte	-3
GAS LISTING /tmp/ccK2IhnQ.s 			page 93


 4407 0aa5 BC       		.byte	-68
 4408 0aa6 6C       		.byte	108
 4409 0aa7 FF       		.byte	-1
 4410 0aa8 FD       		.byte	-3
 4411 0aa9 BC       		.byte	-68
 4412 0aaa 6C       		.byte	108
 4413 0aab FF       		.byte	-1
 4414 0aac FD       		.byte	-3
 4415 0aad BC       		.byte	-68
 4416 0aae 6B       		.byte	107
 4417 0aaf FF       		.byte	-1
 4418 0ab0 FD       		.byte	-3
 4419 0ab1 BB       		.byte	-69
 4420 0ab2 6B       		.byte	107
 4421 0ab3 FF       		.byte	-1
 4422 0ab4 FD       		.byte	-3
 4423 0ab5 BB       		.byte	-69
 4424 0ab6 6B       		.byte	107
 4425 0ab7 FF       		.byte	-1
 4426 0ab8 FD       		.byte	-3
 4427 0ab9 BA       		.byte	-70
 4428 0aba 6A       		.byte	106
 4429 0abb FF       		.byte	-1
 4430 0abc FD       		.byte	-3
 4431 0abd BA       		.byte	-70
 4432 0abe 6A       		.byte	106
 4433 0abf FF       		.byte	-1
 4434 0ac0 FD       		.byte	-3
 4435 0ac1 BA       		.byte	-70
 4436 0ac2 6A       		.byte	106
 4437 0ac3 FF       		.byte	-1
 4438 0ac4 FD       		.byte	-3
 4439 0ac5 B9       		.byte	-71
 4440 0ac6 69       		.byte	105
 4441 0ac7 FF       		.byte	-1
 4442 0ac8 FD       		.byte	-3
 4443 0ac9 B9       		.byte	-71
 4444 0aca 69       		.byte	105
 4445 0acb FF       		.byte	-1
 4446 0acc FD       		.byte	-3
 4447 0acd B8       		.byte	-72
 4448 0ace 69       		.byte	105
 4449 0acf FF       		.byte	-1
 4450 0ad0 FD       		.byte	-3
 4451 0ad1 B8       		.byte	-72
 4452 0ad2 68       		.byte	104
 4453 0ad3 FF       		.byte	-1
 4454 0ad4 FD       		.byte	-3
 4455 0ad5 B8       		.byte	-72
 4456 0ad6 68       		.byte	104
 4457 0ad7 FF       		.byte	-1
 4458 0ad8 FD       		.byte	-3
 4459 0ad9 B7       		.byte	-73
 4460 0ada 68       		.byte	104
 4461 0adb FF       		.byte	-1
 4462 0adc FD       		.byte	-3
 4463 0add B7       		.byte	-73
GAS LISTING /tmp/ccK2IhnQ.s 			page 94


 4464 0ade 67       		.byte	103
 4465 0adf FF       		.byte	-1
 4466 0ae0 FD       		.byte	-3
 4467 0ae1 B6       		.byte	-74
 4468 0ae2 67       		.byte	103
 4469 0ae3 FF       		.byte	-1
 4470 0ae4 FD       		.byte	-3
 4471 0ae5 B6       		.byte	-74
 4472 0ae6 67       		.byte	103
 4473 0ae7 FF       		.byte	-1
 4474 0ae8 FD       		.byte	-3
 4475 0ae9 B6       		.byte	-74
 4476 0aea 66       		.byte	102
 4477 0aeb FF       		.byte	-1
 4478 0aec FD       		.byte	-3
 4479 0aed B5       		.byte	-75
 4480 0aee 66       		.byte	102
 4481 0aef FF       		.byte	-1
 4482 0af0 FD       		.byte	-3
 4483 0af1 B5       		.byte	-75
 4484 0af2 66       		.byte	102
 4485 0af3 FF       		.byte	-1
 4486 0af4 FD       		.byte	-3
 4487 0af5 B4       		.byte	-76
 4488 0af6 65       		.byte	101
 4489 0af7 FF       		.byte	-1
 4490 0af8 FD       		.byte	-3
 4491 0af9 B4       		.byte	-76
 4492 0afa 65       		.byte	101
 4493 0afb FF       		.byte	-1
 4494 0afc FD       		.byte	-3
 4495 0afd B4       		.byte	-76
 4496 0afe 65       		.byte	101
 4497 0aff FF       		.byte	-1
 4498 0b00 FD       		.byte	-3
 4499 0b01 B3       		.byte	-77
 4500 0b02 64       		.byte	100
 4501 0b03 FF       		.byte	-1
 4502 0b04 FD       		.byte	-3
 4503 0b05 B3       		.byte	-77
 4504 0b06 64       		.byte	100
 4505 0b07 FF       		.byte	-1
 4506 0b08 FD       		.byte	-3
 4507 0b09 B2       		.byte	-78
 4508 0b0a 64       		.byte	100
 4509 0b0b FF       		.byte	-1
 4510 0b0c FD       		.byte	-3
 4511 0b0d B2       		.byte	-78
 4512 0b0e 64       		.byte	100
 4513 0b0f FF       		.byte	-1
 4514 0b10 FD       		.byte	-3
 4515 0b11 B2       		.byte	-78
 4516 0b12 63       		.byte	99
 4517 0b13 FF       		.byte	-1
 4518 0b14 FD       		.byte	-3
 4519 0b15 B1       		.byte	-79
 4520 0b16 63       		.byte	99
GAS LISTING /tmp/ccK2IhnQ.s 			page 95


 4521 0b17 FF       		.byte	-1
 4522 0b18 FD       		.byte	-3
 4523 0b19 B1       		.byte	-79
 4524 0b1a 63       		.byte	99
 4525 0b1b FF       		.byte	-1
 4526 0b1c FD       		.byte	-3
 4527 0b1d B0       		.byte	-80
 4528 0b1e 62       		.byte	98
 4529 0b1f FF       		.byte	-1
 4530 0b20 FD       		.byte	-3
 4531 0b21 B0       		.byte	-80
 4532 0b22 62       		.byte	98
 4533 0b23 FF       		.byte	-1
 4534 0b24 FD       		.byte	-3
 4535 0b25 AF       		.byte	-81
 4536 0b26 62       		.byte	98
 4537 0b27 FF       		.byte	-1
 4538 0b28 FD       		.byte	-3
 4539 0b29 AF       		.byte	-81
 4540 0b2a 62       		.byte	98
 4541 0b2b FF       		.byte	-1
 4542 0b2c FD       		.byte	-3
 4543 0b2d AF       		.byte	-81
 4544 0b2e 61       		.byte	97
 4545 0b2f FF       		.byte	-1
 4546 0b30 FD       		.byte	-3
 4547 0b31 AE       		.byte	-82
 4548 0b32 61       		.byte	97
 4549 0b33 FF       		.byte	-1
 4550 0b34 FD       		.byte	-3
 4551 0b35 AE       		.byte	-82
 4552 0b36 61       		.byte	97
 4553 0b37 FF       		.byte	-1
 4554 0b38 FC       		.byte	-4
 4555 0b39 AD       		.byte	-83
 4556 0b3a 60       		.byte	96
 4557 0b3b FF       		.byte	-1
 4558 0b3c FC       		.byte	-4
 4559 0b3d AD       		.byte	-83
 4560 0b3e 60       		.byte	96
 4561 0b3f FF       		.byte	-1
 4562 0b40 FC       		.byte	-4
 4563 0b41 AC       		.byte	-84
 4564 0b42 60       		.byte	96
 4565 0b43 FF       		.byte	-1
 4566 0b44 FC       		.byte	-4
 4567 0b45 AC       		.byte	-84
 4568 0b46 5F       		.byte	95
 4569 0b47 FF       		.byte	-1
 4570 0b48 FC       		.byte	-4
 4571 0b49 AC       		.byte	-84
 4572 0b4a 5F       		.byte	95
 4573 0b4b FF       		.byte	-1
 4574 0b4c FC       		.byte	-4
 4575 0b4d AB       		.byte	-85
 4576 0b4e 5F       		.byte	95
 4577 0b4f FF       		.byte	-1
GAS LISTING /tmp/ccK2IhnQ.s 			page 96


 4578 0b50 FC       		.byte	-4
 4579 0b51 AB       		.byte	-85
 4580 0b52 5E       		.byte	94
 4581 0b53 FF       		.byte	-1
 4582 0b54 FC       		.byte	-4
 4583 0b55 AA       		.byte	-86
 4584 0b56 5E       		.byte	94
 4585 0b57 FF       		.byte	-1
 4586 0b58 FC       		.byte	-4
 4587 0b59 AA       		.byte	-86
 4588 0b5a 5E       		.byte	94
 4589 0b5b FF       		.byte	-1
 4590 0b5c FC       		.byte	-4
 4591 0b5d A9       		.byte	-87
 4592 0b5e 5D       		.byte	93
 4593 0b5f FF       		.byte	-1
 4594 0b60 FC       		.byte	-4
 4595 0b61 A9       		.byte	-87
 4596 0b62 5D       		.byte	93
 4597 0b63 FF       		.byte	-1
 4598 0b64 FC       		.byte	-4
 4599 0b65 A8       		.byte	-88
 4600 0b66 5D       		.byte	93
 4601 0b67 FF       		.byte	-1
 4602 0b68 FC       		.byte	-4
 4603 0b69 A8       		.byte	-88
 4604 0b6a 5C       		.byte	92
 4605 0b6b FF       		.byte	-1
 4606 0b6c FC       		.byte	-4
 4607 0b6d A7       		.byte	-89
 4608 0b6e 5C       		.byte	92
 4609 0b6f FF       		.byte	-1
 4610 0b70 FC       		.byte	-4
 4611 0b71 A7       		.byte	-89
 4612 0b72 5C       		.byte	92
 4613 0b73 FF       		.byte	-1
 4614 0b74 FC       		.byte	-4
 4615 0b75 A6       		.byte	-90
 4616 0b76 5B       		.byte	91
 4617 0b77 FF       		.byte	-1
 4618 0b78 FC       		.byte	-4
 4619 0b79 A6       		.byte	-90
 4620 0b7a 5B       		.byte	91
 4621 0b7b FF       		.byte	-1
 4622 0b7c FC       		.byte	-4
 4623 0b7d A5       		.byte	-91
 4624 0b7e 5B       		.byte	91
 4625 0b7f FF       		.byte	-1
 4626 0b80 FB       		.byte	-5
 4627 0b81 A5       		.byte	-91
 4628 0b82 5A       		.byte	90
 4629 0b83 FF       		.byte	-1
 4630 0b84 FB       		.byte	-5
 4631 0b85 A4       		.byte	-92
 4632 0b86 5A       		.byte	90
 4633 0b87 FF       		.byte	-1
 4634 0b88 FB       		.byte	-5
GAS LISTING /tmp/ccK2IhnQ.s 			page 97


 4635 0b89 A4       		.byte	-92
 4636 0b8a 5A       		.byte	90
 4637 0b8b FF       		.byte	-1
 4638 0b8c FB       		.byte	-5
 4639 0b8d A3       		.byte	-93
 4640 0b8e 59       		.byte	89
 4641 0b8f FF       		.byte	-1
 4642 0b90 FB       		.byte	-5
 4643 0b91 A3       		.byte	-93
 4644 0b92 59       		.byte	89
 4645 0b93 FF       		.byte	-1
 4646 0b94 FB       		.byte	-5
 4647 0b95 A2       		.byte	-94
 4648 0b96 59       		.byte	89
 4649 0b97 FF       		.byte	-1
 4650 0b98 FB       		.byte	-5
 4651 0b99 A2       		.byte	-94
 4652 0b9a 59       		.byte	89
 4653 0b9b FF       		.byte	-1
 4654 0b9c FB       		.byte	-5
 4655 0b9d A2       		.byte	-94
 4656 0b9e 58       		.byte	88
 4657 0b9f FF       		.byte	-1
 4658 0ba0 FB       		.byte	-5
 4659 0ba1 A1       		.byte	-95
 4660 0ba2 58       		.byte	88
 4661 0ba3 FF       		.byte	-1
 4662 0ba4 FB       		.byte	-5
 4663 0ba5 A1       		.byte	-95
 4664 0ba6 58       		.byte	88
 4665 0ba7 FF       		.byte	-1
 4666 0ba8 FB       		.byte	-5
 4667 0ba9 A0       		.byte	-96
 4668 0baa 57       		.byte	87
 4669 0bab FF       		.byte	-1
 4670 0bac FB       		.byte	-5
 4671 0bad A0       		.byte	-96
 4672 0bae 57       		.byte	87
 4673 0baf FF       		.byte	-1
 4674 0bb0 FB       		.byte	-5
 4675 0bb1 9F       		.byte	-97
 4676 0bb2 57       		.byte	87
 4677 0bb3 FF       		.byte	-1
 4678 0bb4 FB       		.byte	-5
 4679 0bb5 9F       		.byte	-97
 4680 0bb6 57       		.byte	87
 4681 0bb7 FF       		.byte	-1
 4682 0bb8 FB       		.byte	-5
 4683 0bb9 9E       		.byte	-98
 4684 0bba 56       		.byte	86
 4685 0bbb FF       		.byte	-1
 4686 0bbc FB       		.byte	-5
 4687 0bbd 9E       		.byte	-98
 4688 0bbe 56       		.byte	86
 4689 0bbf FF       		.byte	-1
 4690 0bc0 FB       		.byte	-5
 4691 0bc1 9D       		.byte	-99
GAS LISTING /tmp/ccK2IhnQ.s 			page 98


 4692 0bc2 56       		.byte	86
 4693 0bc3 FF       		.byte	-1
 4694 0bc4 FA       		.byte	-6
 4695 0bc5 9D       		.byte	-99
 4696 0bc6 55       		.byte	85
 4697 0bc7 FF       		.byte	-1
 4698 0bc8 FA       		.byte	-6
 4699 0bc9 9C       		.byte	-100
 4700 0bca 55       		.byte	85
 4701 0bcb FF       		.byte	-1
 4702 0bcc FA       		.byte	-6
 4703 0bcd 9C       		.byte	-100
 4704 0bce 55       		.byte	85
 4705 0bcf FF       		.byte	-1
 4706 0bd0 FA       		.byte	-6
 4707 0bd1 9B       		.byte	-101
 4708 0bd2 55       		.byte	85
 4709 0bd3 FF       		.byte	-1
 4710 0bd4 FA       		.byte	-6
 4711 0bd5 9B       		.byte	-101
 4712 0bd6 54       		.byte	84
 4713 0bd7 FF       		.byte	-1
 4714 0bd8 FA       		.byte	-6
 4715 0bd9 9A       		.byte	-102
 4716 0bda 54       		.byte	84
 4717 0bdb FF       		.byte	-1
 4718 0bdc FA       		.byte	-6
 4719 0bdd 9A       		.byte	-102
 4720 0bde 54       		.byte	84
 4721 0bdf FF       		.byte	-1
 4722 0be0 FA       		.byte	-6
 4723 0be1 99       		.byte	-103
 4724 0be2 54       		.byte	84
 4725 0be3 FF       		.byte	-1
 4726 0be4 FA       		.byte	-6
 4727 0be5 99       		.byte	-103
 4728 0be6 53       		.byte	83
 4729 0be7 FF       		.byte	-1
 4730 0be8 FA       		.byte	-6
 4731 0be9 98       		.byte	-104
 4732 0bea 53       		.byte	83
 4733 0beb FF       		.byte	-1
 4734 0bec FA       		.byte	-6
 4735 0bed 98       		.byte	-104
 4736 0bee 53       		.byte	83
 4737 0bef FF       		.byte	-1
 4738 0bf0 FA       		.byte	-6
 4739 0bf1 97       		.byte	-105
 4740 0bf2 53       		.byte	83
 4741 0bf3 FF       		.byte	-1
 4742 0bf4 FA       		.byte	-6
 4743 0bf5 97       		.byte	-105
 4744 0bf6 52       		.byte	82
 4745 0bf7 FF       		.byte	-1
 4746 0bf8 FA       		.byte	-6
 4747 0bf9 96       		.byte	-106
 4748 0bfa 52       		.byte	82
GAS LISTING /tmp/ccK2IhnQ.s 			page 99


 4749 0bfb FF       		.byte	-1
 4750 0bfc FA       		.byte	-6
 4751 0bfd 96       		.byte	-106
 4752 0bfe 52       		.byte	82
 4753 0bff FF       		.byte	-1
 4754 0c00 F9       		.byte	-7
 4755 0c01 95       		.byte	-107
 4756 0c02 52       		.byte	82
 4757 0c03 FF       		.byte	-1
 4758 0c04 F8       		.byte	-8
 4759 0c05 88       		.byte	-120
 4760 0c06 4B       		.byte	75
 4761 0c07 FF       		.byte	-1
 4762 0c08 F8       		.byte	-8
 4763 0c09 87       		.byte	-121
 4764 0c0a 4B       		.byte	75
 4765 0c0b FF       		.byte	-1
 4766 0c0c F7       		.byte	-9
 4767 0c0d 87       		.byte	-121
 4768 0c0e 4B       		.byte	75
 4769 0c0f FF       		.byte	-1
 4770 0c10 F7       		.byte	-9
 4771 0c11 86       		.byte	-122
 4772 0c12 4B       		.byte	75
 4773 0c13 FF       		.byte	-1
 4774 0c14 F7       		.byte	-9
 4775 0c15 86       		.byte	-122
 4776 0c16 4A       		.byte	74
 4777 0c17 FF       		.byte	-1
 4778 0c18 F7       		.byte	-9
 4779 0c19 85       		.byte	-123
 4780 0c1a 4A       		.byte	74
 4781 0c1b FF       		.byte	-1
 4782 0c1c F7       		.byte	-9
 4783 0c1d 85       		.byte	-123
 4784 0c1e 4A       		.byte	74
 4785 0c1f FF       		.byte	-1
 4786 0c20 F7       		.byte	-9
 4787 0c21 84       		.byte	-124
 4788 0c22 4A       		.byte	74
 4789 0c23 FF       		.byte	-1
 4790 0c24 F7       		.byte	-9
 4791 0c25 84       		.byte	-124
 4792 0c26 4A       		.byte	74
 4793 0c27 FF       		.byte	-1
 4794 0c28 F7       		.byte	-9
 4795 0c29 83       		.byte	-125
 4796 0c2a 49       		.byte	73
 4797 0c2b FF       		.byte	-1
 4798 0c2c F7       		.byte	-9
 4799 0c2d 83       		.byte	-125
 4800 0c2e 49       		.byte	73
 4801 0c2f FF       		.byte	-1
 4802 0c30 F7       		.byte	-9
 4803 0c31 82       		.byte	-126
 4804 0c32 49       		.byte	73
 4805 0c33 FF       		.byte	-1
GAS LISTING /tmp/ccK2IhnQ.s 			page 100


 4806 0c34 F7       		.byte	-9
 4807 0c35 82       		.byte	-126
 4808 0c36 49       		.byte	73
 4809 0c37 FF       		.byte	-1
 4810 0c38 F7       		.byte	-9
 4811 0c39 81       		.byte	-127
 4812 0c3a 48       		.byte	72
 4813 0c3b FF       		.byte	-1
 4814 0c3c F7       		.byte	-9
 4815 0c3d 81       		.byte	-127
 4816 0c3e 48       		.byte	72
 4817 0c3f FF       		.byte	-1
 4818 0c40 F7       		.byte	-9
 4819 0c41 80       		.byte	-128
 4820 0c42 48       		.byte	72
 4821 0c43 FF       		.byte	-1
 4822 0c44 F6       		.byte	-10
 4823 0c45 80       		.byte	-128
 4824 0c46 48       		.byte	72
 4825 0c47 FF       		.byte	-1
 4826 0c48 F6       		.byte	-10
 4827 0c49 7F       		.byte	127
 4828 0c4a 48       		.byte	72
 4829 0c4b FF       		.byte	-1
 4830 0c4c F6       		.byte	-10
 4831 0c4d 7E       		.byte	126
 4832 0c4e 47       		.byte	71
 4833 0c4f FF       		.byte	-1
 4834 0c50 F6       		.byte	-10
 4835 0c51 7E       		.byte	126
 4836 0c52 47       		.byte	71
 4837 0c53 FF       		.byte	-1
 4838 0c54 F6       		.byte	-10
 4839 0c55 7D       		.byte	125
 4840 0c56 47       		.byte	71
 4841 0c57 FF       		.byte	-1
 4842 0c58 F6       		.byte	-10
 4843 0c59 7D       		.byte	125
 4844 0c5a 47       		.byte	71
 4845 0c5b FF       		.byte	-1
 4846 0c5c F6       		.byte	-10
 4847 0c5d 7C       		.byte	124
 4848 0c5e 47       		.byte	71
 4849 0c5f FF       		.byte	-1
 4850 0c60 F6       		.byte	-10
 4851 0c61 7C       		.byte	124
 4852 0c62 47       		.byte	71
 4853 0c63 FF       		.byte	-1
 4854 0c64 F6       		.byte	-10
 4855 0c65 7B       		.byte	123
 4856 0c66 46       		.byte	70
 4857 0c67 FF       		.byte	-1
 4858 0c68 F6       		.byte	-10
 4859 0c69 7B       		.byte	123
 4860 0c6a 46       		.byte	70
 4861 0c6b FF       		.byte	-1
 4862 0c6c F6       		.byte	-10
GAS LISTING /tmp/ccK2IhnQ.s 			page 101


 4863 0c6d 7A       		.byte	122
 4864 0c6e 46       		.byte	70
 4865 0c6f FF       		.byte	-1
 4866 0c70 F6       		.byte	-10
 4867 0c71 7A       		.byte	122
 4868 0c72 46       		.byte	70
 4869 0c73 FF       		.byte	-1
 4870 0c74 F6       		.byte	-10
 4871 0c75 79       		.byte	121
 4872 0c76 46       		.byte	70
 4873 0c77 FF       		.byte	-1
 4874 0c78 F5       		.byte	-11
 4875 0c79 79       		.byte	121
 4876 0c7a 46       		.byte	70
 4877 0c7b FF       		.byte	-1
 4878 0c7c F5       		.byte	-11
 4879 0c7d 78       		.byte	120
 4880 0c7e 45       		.byte	69
 4881 0c7f FF       		.byte	-1
 4882 0c80 F5       		.byte	-11
 4883 0c81 78       		.byte	120
 4884 0c82 45       		.byte	69
 4885 0c83 FF       		.byte	-1
 4886 0c84 F5       		.byte	-11
 4887 0c85 77       		.byte	119
 4888 0c86 45       		.byte	69
 4889 0c87 FF       		.byte	-1
 4890 0c88 F5       		.byte	-11
 4891 0c89 77       		.byte	119
 4892 0c8a 45       		.byte	69
 4893 0c8b FF       		.byte	-1
 4894 0c8c F5       		.byte	-11
 4895 0c8d 76       		.byte	118
 4896 0c8e 45       		.byte	69
 4897 0c8f FF       		.byte	-1
 4898 0c90 F5       		.byte	-11
 4899 0c91 75       		.byte	117
 4900 0c92 45       		.byte	69
 4901 0c93 FF       		.byte	-1
 4902 0c94 F5       		.byte	-11
 4903 0c95 75       		.byte	117
 4904 0c96 44       		.byte	68
 4905 0c97 FF       		.byte	-1
 4906 0c98 F5       		.byte	-11
 4907 0c99 74       		.byte	116
 4908 0c9a 44       		.byte	68
 4909 0c9b FF       		.byte	-1
 4910 0c9c F5       		.byte	-11
 4911 0c9d 74       		.byte	116
 4912 0c9e 44       		.byte	68
 4913 0c9f FF       		.byte	-1
 4914 0ca0 F5       		.byte	-11
 4915 0ca1 73       		.byte	115
 4916 0ca2 44       		.byte	68
 4917 0ca3 FF       		.byte	-1
 4918 0ca4 F5       		.byte	-11
 4919 0ca5 73       		.byte	115
GAS LISTING /tmp/ccK2IhnQ.s 			page 102


 4920 0ca6 44       		.byte	68
 4921 0ca7 FF       		.byte	-1
 4922 0ca8 F4       		.byte	-12
 4923 0ca9 72       		.byte	114
 4924 0caa 44       		.byte	68
 4925 0cab FF       		.byte	-1
 4926 0cac F4       		.byte	-12
 4927 0cad 72       		.byte	114
 4928 0cae 44       		.byte	68
 4929 0caf FF       		.byte	-1
 4930 0cb0 F4       		.byte	-12
 4931 0cb1 71       		.byte	113
 4932 0cb2 43       		.byte	67
 4933 0cb3 FF       		.byte	-1
 4934 0cb4 F4       		.byte	-12
 4935 0cb5 71       		.byte	113
 4936 0cb6 43       		.byte	67
 4937 0cb7 FF       		.byte	-1
 4938 0cb8 F4       		.byte	-12
 4939 0cb9 70       		.byte	112
 4940 0cba 43       		.byte	67
 4941 0cbb FF       		.byte	-1
 4942 0cbc F4       		.byte	-12
 4943 0cbd 6F       		.byte	111
 4944 0cbe 43       		.byte	67
 4945 0cbf FF       		.byte	-1
 4946 0cc0 F4       		.byte	-12
 4947 0cc1 6F       		.byte	111
 4948 0cc2 43       		.byte	67
 4949 0cc3 FF       		.byte	-1
 4950 0cc4 F4       		.byte	-12
 4951 0cc5 6E       		.byte	110
 4952 0cc6 43       		.byte	67
 4953 0cc7 FF       		.byte	-1
 4954 0cc8 F4       		.byte	-12
 4955 0cc9 6E       		.byte	110
 4956 0cca 43       		.byte	67
 4957 0ccb FF       		.byte	-1
 4958 0ccc F4       		.byte	-12
 4959 0ccd 6D       		.byte	109
 4960 0cce 43       		.byte	67
 4961 0ccf FF       		.byte	-1
 4962 0cd0 F4       		.byte	-12
 4963 0cd1 6D       		.byte	109
 4964 0cd2 43       		.byte	67
 4965 0cd3 FF       		.byte	-1
 4966 0cd4 F3       		.byte	-13
 4967 0cd5 6C       		.byte	108
 4968 0cd6 43       		.byte	67
 4969 0cd7 FF       		.byte	-1
 4970 0cd8 F3       		.byte	-13
 4971 0cd9 6C       		.byte	108
 4972 0cda 43       		.byte	67
 4973 0cdb FF       		.byte	-1
 4974 0cdc F3       		.byte	-13
 4975 0cdd 6B       		.byte	107
 4976 0cde 43       		.byte	67
GAS LISTING /tmp/ccK2IhnQ.s 			page 103


 4977 0cdf FF       		.byte	-1
 4978 0ce0 F3       		.byte	-13
 4979 0ce1 6B       		.byte	107
 4980 0ce2 43       		.byte	67
 4981 0ce3 FF       		.byte	-1
 4982 0ce4 F3       		.byte	-13
 4983 0ce5 6B       		.byte	107
 4984 0ce6 43       		.byte	67
 4985 0ce7 FF       		.byte	-1
 4986 0ce8 F2       		.byte	-14
 4987 0ce9 6A       		.byte	106
 4988 0cea 43       		.byte	67
 4989 0ceb FF       		.byte	-1
 4990 0cec F2       		.byte	-14
 4991 0ced 6A       		.byte	106
 4992 0cee 43       		.byte	67
 4993 0cef FF       		.byte	-1
 4994 0cf0 F2       		.byte	-14
 4995 0cf1 6A       		.byte	106
 4996 0cf2 43       		.byte	67
 4997 0cf3 FF       		.byte	-1
 4998 0cf4 F2       		.byte	-14
 4999 0cf5 69       		.byte	105
 5000 0cf6 43       		.byte	67
 5001 0cf7 FF       		.byte	-1
 5002 0cf8 F2       		.byte	-14
 5003 0cf9 69       		.byte	105
 5004 0cfa 43       		.byte	67
 5005 0cfb FF       		.byte	-1
 5006 0cfc F1       		.byte	-15
 5007 0cfd 68       		.byte	104
 5008 0cfe 44       		.byte	68
 5009 0cff FF       		.byte	-1
 5010 0d00 F1       		.byte	-15
 5011 0d01 68       		.byte	104
 5012 0d02 44       		.byte	68
 5013 0d03 FF       		.byte	-1
 5014 0d04 F1       		.byte	-15
 5015 0d05 68       		.byte	104
 5016 0d06 44       		.byte	68
 5017 0d07 FF       		.byte	-1
 5018 0d08 F1       		.byte	-15
 5019 0d09 67       		.byte	103
 5020 0d0a 44       		.byte	68
 5021 0d0b FF       		.byte	-1
 5022 0d0c F1       		.byte	-15
 5023 0d0d 67       		.byte	103
 5024 0d0e 44       		.byte	68
 5025 0d0f FF       		.byte	-1
 5026 0d10 F0       		.byte	-16
 5027 0d11 66       		.byte	102
 5028 0d12 44       		.byte	68
 5029 0d13 FF       		.byte	-1
 5030 0d14 F0       		.byte	-16
 5031 0d15 66       		.byte	102
 5032 0d16 44       		.byte	68
 5033 0d17 FF       		.byte	-1
GAS LISTING /tmp/ccK2IhnQ.s 			page 104


 5034 0d18 F0       		.byte	-16
 5035 0d19 66       		.byte	102
 5036 0d1a 44       		.byte	68
 5037 0d1b FF       		.byte	-1
 5038 0d1c F0       		.byte	-16
 5039 0d1d 65       		.byte	101
 5040 0d1e 44       		.byte	68
 5041 0d1f FF       		.byte	-1
 5042 0d20 F0       		.byte	-16
 5043 0d21 65       		.byte	101
 5044 0d22 44       		.byte	68
 5045 0d23 FF       		.byte	-1
 5046 0d24 EF       		.byte	-17
 5047 0d25 65       		.byte	101
 5048 0d26 45       		.byte	69
 5049 0d27 FF       		.byte	-1
 5050 0d28 EF       		.byte	-17
 5051 0d29 64       		.byte	100
 5052 0d2a 45       		.byte	69
 5053 0d2b FF       		.byte	-1
 5054 0d2c EF       		.byte	-17
 5055 0d2d 64       		.byte	100
 5056 0d2e 45       		.byte	69
 5057 0d2f FF       		.byte	-1
 5058 0d30 EF       		.byte	-17
 5059 0d31 63       		.byte	99
 5060 0d32 45       		.byte	69
 5061 0d33 FF       		.byte	-1
 5062 0d34 EE       		.byte	-18
 5063 0d35 63       		.byte	99
 5064 0d36 45       		.byte	69
 5065 0d37 FF       		.byte	-1
 5066 0d38 EE       		.byte	-18
 5067 0d39 63       		.byte	99
 5068 0d3a 45       		.byte	69
 5069 0d3b FF       		.byte	-1
 5070 0d3c EE       		.byte	-18
 5071 0d3d 62       		.byte	98
 5072 0d3e 45       		.byte	69
 5073 0d3f FF       		.byte	-1
 5074 0d40 EE       		.byte	-18
 5075 0d41 62       		.byte	98
 5076 0d42 45       		.byte	69
 5077 0d43 FF       		.byte	-1
 5078 0d44 EE       		.byte	-18
 5079 0d45 62       		.byte	98
 5080 0d46 45       		.byte	69
 5081 0d47 FF       		.byte	-1
 5082 0d48 ED       		.byte	-19
 5083 0d49 61       		.byte	97
 5084 0d4a 45       		.byte	69
 5085 0d4b FF       		.byte	-1
 5086 0d4c ED       		.byte	-19
 5087 0d4d 61       		.byte	97
 5088 0d4e 46       		.byte	70
 5089 0d4f FF       		.byte	-1
 5090 0d50 ED       		.byte	-19
GAS LISTING /tmp/ccK2IhnQ.s 			page 105


 5091 0d51 60       		.byte	96
 5092 0d52 46       		.byte	70
 5093 0d53 FF       		.byte	-1
 5094 0d54 ED       		.byte	-19
 5095 0d55 60       		.byte	96
 5096 0d56 46       		.byte	70
 5097 0d57 FF       		.byte	-1
 5098 0d58 EC       		.byte	-20
 5099 0d59 60       		.byte	96
 5100 0d5a 46       		.byte	70
 5101 0d5b FF       		.byte	-1
 5102 0d5c EC       		.byte	-20
 5103 0d5d 5F       		.byte	95
 5104 0d5e 46       		.byte	70
 5105 0d5f FF       		.byte	-1
 5106 0d60 EC       		.byte	-20
 5107 0d61 5F       		.byte	95
 5108 0d62 46       		.byte	70
 5109 0d63 FF       		.byte	-1
 5110 0d64 EC       		.byte	-20
 5111 0d65 5F       		.byte	95
 5112 0d66 46       		.byte	70
 5113 0d67 FF       		.byte	-1
 5114 0d68 EC       		.byte	-20
 5115 0d69 5E       		.byte	94
 5116 0d6a 46       		.byte	70
 5117 0d6b FF       		.byte	-1
 5118 0d6c EB       		.byte	-21
 5119 0d6d 5E       		.byte	94
 5120 0d6e 46       		.byte	70
 5121 0d6f FF       		.byte	-1
 5122 0d70 EB       		.byte	-21
 5123 0d71 5E       		.byte	94
 5124 0d72 46       		.byte	70
 5125 0d73 FF       		.byte	-1
 5126 0d74 EB       		.byte	-21
 5127 0d75 5D       		.byte	93
 5128 0d76 47       		.byte	71
 5129 0d77 FF       		.byte	-1
 5130 0d78 EB       		.byte	-21
 5131 0d79 5D       		.byte	93
 5132 0d7a 47       		.byte	71
 5133 0d7b FF       		.byte	-1
 5134 0d7c EA       		.byte	-22
 5135 0d7d 5C       		.byte	92
 5136 0d7e 47       		.byte	71
 5137 0d7f FF       		.byte	-1
 5138 0d80 EA       		.byte	-22
 5139 0d81 5C       		.byte	92
 5140 0d82 47       		.byte	71
 5141 0d83 FF       		.byte	-1
 5142 0d84 EA       		.byte	-22
 5143 0d85 5C       		.byte	92
 5144 0d86 47       		.byte	71
 5145 0d87 FF       		.byte	-1
 5146 0d88 EA       		.byte	-22
 5147 0d89 5B       		.byte	91
GAS LISTING /tmp/ccK2IhnQ.s 			page 106


 5148 0d8a 47       		.byte	71
 5149 0d8b FF       		.byte	-1
 5150 0d8c E9       		.byte	-23
 5151 0d8d 5B       		.byte	91
 5152 0d8e 47       		.byte	71
 5153 0d8f FF       		.byte	-1
 5154 0d90 E9       		.byte	-23
 5155 0d91 5B       		.byte	91
 5156 0d92 47       		.byte	71
 5157 0d93 FF       		.byte	-1
 5158 0d94 E9       		.byte	-23
 5159 0d95 5A       		.byte	90
 5160 0d96 47       		.byte	71
 5161 0d97 FF       		.byte	-1
 5162 0d98 E9       		.byte	-23
 5163 0d99 5A       		.byte	90
 5164 0d9a 47       		.byte	71
 5165 0d9b FF       		.byte	-1
 5166 0d9c E9       		.byte	-23
 5167 0d9d 59       		.byte	89
 5168 0d9e 48       		.byte	72
 5169 0d9f FF       		.byte	-1
 5170 0da0 E2       		.byte	-30
 5171 0da1 50       		.byte	80
 5172 0da2 4A       		.byte	74
 5173 0da3 FF       		.byte	-1
 5174 0da4 E2       		.byte	-30
 5175 0da5 4F       		.byte	79
 5176 0da6 4A       		.byte	74
 5177 0da7 FF       		.byte	-1
 5178 0da8 E2       		.byte	-30
 5179 0da9 4F       		.byte	79
 5180 0daa 4A       		.byte	74
 5181 0dab FF       		.byte	-1
 5182 0dac E1       		.byte	-31
 5183 0dad 4F       		.byte	79
 5184 0dae 4A       		.byte	74
 5185 0daf FF       		.byte	-1
 5186 0db0 E1       		.byte	-31
 5187 0db1 4E       		.byte	78
 5188 0db2 4A       		.byte	74
 5189 0db3 FF       		.byte	-1
 5190 0db4 E1       		.byte	-31
 5191 0db5 4E       		.byte	78
 5192 0db6 4A       		.byte	74
 5193 0db7 FF       		.byte	-1
 5194 0db8 E1       		.byte	-31
 5195 0db9 4D       		.byte	77
 5196 0dba 4B       		.byte	75
 5197 0dbb FF       		.byte	-1
 5198 0dbc E0       		.byte	-32
 5199 0dbd 4D       		.byte	77
 5200 0dbe 4B       		.byte	75
 5201 0dbf FF       		.byte	-1
 5202 0dc0 E0       		.byte	-32
 5203 0dc1 4D       		.byte	77
 5204 0dc2 4B       		.byte	75
GAS LISTING /tmp/ccK2IhnQ.s 			page 107


 5205 0dc3 FF       		.byte	-1
 5206 0dc4 E0       		.byte	-32
 5207 0dc5 4C       		.byte	76
 5208 0dc6 4B       		.byte	75
 5209 0dc7 FF       		.byte	-1
 5210 0dc8 E0       		.byte	-32
 5211 0dc9 4C       		.byte	76
 5212 0dca 4B       		.byte	75
 5213 0dcb FF       		.byte	-1
 5214 0dcc DF       		.byte	-33
 5215 0dcd 4C       		.byte	76
 5216 0dce 4B       		.byte	75
 5217 0dcf FF       		.byte	-1
 5218 0dd0 DF       		.byte	-33
 5219 0dd1 4B       		.byte	75
 5220 0dd2 4B       		.byte	75
 5221 0dd3 FF       		.byte	-1
 5222 0dd4 DF       		.byte	-33
 5223 0dd5 4B       		.byte	75
 5224 0dd6 4B       		.byte	75
 5225 0dd7 FF       		.byte	-1
 5226 0dd8 DF       		.byte	-33
 5227 0dd9 4B       		.byte	75
 5228 0dda 4B       		.byte	75
 5229 0ddb FF       		.byte	-1
 5230 0ddc DE       		.byte	-34
 5231 0ddd 4A       		.byte	74
 5232 0dde 4B       		.byte	75
 5233 0ddf FF       		.byte	-1
 5234 0de0 DE       		.byte	-34
 5235 0de1 4A       		.byte	74
 5236 0de2 4B       		.byte	75
 5237 0de3 FF       		.byte	-1
 5238 0de4 DE       		.byte	-34
 5239 0de5 49       		.byte	73
 5240 0de6 4C       		.byte	76
 5241 0de7 FF       		.byte	-1
 5242 0de8 DE       		.byte	-34
 5243 0de9 49       		.byte	73
 5244 0dea 4C       		.byte	76
 5245 0deb FF       		.byte	-1
 5246 0dec DD       		.byte	-35
 5247 0ded 49       		.byte	73
 5248 0dee 4C       		.byte	76
 5249 0def FF       		.byte	-1
 5250 0df0 DD       		.byte	-35
 5251 0df1 48       		.byte	72
 5252 0df2 4C       		.byte	76
 5253 0df3 FF       		.byte	-1
 5254 0df4 DD       		.byte	-35
 5255 0df5 48       		.byte	72
 5256 0df6 4C       		.byte	76
 5257 0df7 FF       		.byte	-1
 5258 0df8 DC       		.byte	-36
 5259 0df9 48       		.byte	72
 5260 0dfa 4C       		.byte	76
 5261 0dfb FF       		.byte	-1
GAS LISTING /tmp/ccK2IhnQ.s 			page 108


 5262 0dfc DC       		.byte	-36
 5263 0dfd 47       		.byte	71
 5264 0dfe 4C       		.byte	76
 5265 0dff FF       		.byte	-1
 5266 0e00 DC       		.byte	-36
 5267 0e01 47       		.byte	71
 5268 0e02 4C       		.byte	76
 5269 0e03 FF       		.byte	-1
 5270 0e04 DC       		.byte	-36
 5271 0e05 47       		.byte	71
 5272 0e06 4C       		.byte	76
 5273 0e07 FF       		.byte	-1
 5274 0e08 DB       		.byte	-37
 5275 0e09 46       		.byte	70
 5276 0e0a 4C       		.byte	76
 5277 0e0b FF       		.byte	-1
 5278 0e0c DB       		.byte	-37
 5279 0e0d 46       		.byte	70
 5280 0e0e 4C       		.byte	76
 5281 0e0f FF       		.byte	-1
 5282 0e10 DB       		.byte	-37
 5283 0e11 46       		.byte	70
 5284 0e12 4D       		.byte	77
 5285 0e13 FF       		.byte	-1
 5286 0e14 DB       		.byte	-37
 5287 0e15 45       		.byte	69
 5288 0e16 4D       		.byte	77
 5289 0e17 FF       		.byte	-1
 5290 0e18 DA       		.byte	-38
 5291 0e19 45       		.byte	69
 5292 0e1a 4D       		.byte	77
 5293 0e1b FF       		.byte	-1
 5294 0e1c DA       		.byte	-38
 5295 0e1d 44       		.byte	68
 5296 0e1e 4D       		.byte	77
 5297 0e1f FF       		.byte	-1
 5298 0e20 DA       		.byte	-38
 5299 0e21 44       		.byte	68
 5300 0e22 4D       		.byte	77
 5301 0e23 FF       		.byte	-1
 5302 0e24 D9       		.byte	-39
 5303 0e25 44       		.byte	68
 5304 0e26 4D       		.byte	77
 5305 0e27 FF       		.byte	-1
 5306 0e28 D9       		.byte	-39
 5307 0e29 43       		.byte	67
 5308 0e2a 4D       		.byte	77
 5309 0e2b FF       		.byte	-1
 5310 0e2c D9       		.byte	-39
 5311 0e2d 43       		.byte	67
 5312 0e2e 4D       		.byte	77
 5313 0e2f FF       		.byte	-1
 5314 0e30 D9       		.byte	-39
 5315 0e31 43       		.byte	67
 5316 0e32 4D       		.byte	77
 5317 0e33 FF       		.byte	-1
 5318 0e34 D8       		.byte	-40
GAS LISTING /tmp/ccK2IhnQ.s 			page 109


 5319 0e35 42       		.byte	66
 5320 0e36 4D       		.byte	77
 5321 0e37 FF       		.byte	-1
 5322 0e38 D8       		.byte	-40
 5323 0e39 42       		.byte	66
 5324 0e3a 4D       		.byte	77
 5325 0e3b FF       		.byte	-1
 5326 0e3c D8       		.byte	-40
 5327 0e3d 42       		.byte	66
 5328 0e3e 4E       		.byte	78
 5329 0e3f FF       		.byte	-1
 5330 0e40 D8       		.byte	-40
 5331 0e41 41       		.byte	65
 5332 0e42 4E       		.byte	78
 5333 0e43 FF       		.byte	-1
 5334 0e44 D7       		.byte	-41
 5335 0e45 41       		.byte	65
 5336 0e46 4E       		.byte	78
 5337 0e47 FF       		.byte	-1
 5338 0e48 D7       		.byte	-41
 5339 0e49 41       		.byte	65
 5340 0e4a 4E       		.byte	78
 5341 0e4b FF       		.byte	-1
 5342 0e4c D7       		.byte	-41
 5343 0e4d 40       		.byte	64
 5344 0e4e 4E       		.byte	78
 5345 0e4f FF       		.byte	-1
 5346 0e50 D6       		.byte	-42
 5347 0e51 40       		.byte	64
 5348 0e52 4E       		.byte	78
 5349 0e53 FF       		.byte	-1
 5350 0e54 D6       		.byte	-42
 5351 0e55 3F       		.byte	63
 5352 0e56 4E       		.byte	78
 5353 0e57 FF       		.byte	-1
 5354 0e58 D6       		.byte	-42
 5355 0e59 3F       		.byte	63
 5356 0e5a 4E       		.byte	78
 5357 0e5b FF       		.byte	-1
 5358 0e5c D6       		.byte	-42
 5359 0e5d 3F       		.byte	63
 5360 0e5e 4E       		.byte	78
 5361 0e5f FF       		.byte	-1
 5362 0e60 D5       		.byte	-43
 5363 0e61 3E       		.byte	62
 5364 0e62 4E       		.byte	78
 5365 0e63 FF       		.byte	-1
 5366 0e64 D5       		.byte	-43
 5367 0e65 3E       		.byte	62
 5368 0e66 4E       		.byte	78
 5369 0e67 FF       		.byte	-1
 5370 0e68 D5       		.byte	-43
 5371 0e69 3E       		.byte	62
 5372 0e6a 4E       		.byte	78
 5373 0e6b FF       		.byte	-1
 5374 0e6c D4       		.byte	-44
 5375 0e6d 3D       		.byte	61
GAS LISTING /tmp/ccK2IhnQ.s 			page 110


 5376 0e6e 4E       		.byte	78
 5377 0e6f FF       		.byte	-1
 5378 0e70 D4       		.byte	-44
 5379 0e71 3D       		.byte	61
 5380 0e72 4E       		.byte	78
 5381 0e73 FF       		.byte	-1
 5382 0e74 D3       		.byte	-45
 5383 0e75 3D       		.byte	61
 5384 0e76 4E       		.byte	78
 5385 0e77 FF       		.byte	-1
 5386 0e78 D3       		.byte	-45
 5387 0e79 3C       		.byte	60
 5388 0e7a 4E       		.byte	78
 5389 0e7b FF       		.byte	-1
 5390 0e7c D3       		.byte	-45
 5391 0e7d 3C       		.byte	60
 5392 0e7e 4E       		.byte	78
 5393 0e7f FF       		.byte	-1
 5394 0e80 D2       		.byte	-46
 5395 0e81 3B       		.byte	59
 5396 0e82 4E       		.byte	78
 5397 0e83 FF       		.byte	-1
 5398 0e84 D2       		.byte	-46
 5399 0e85 3B       		.byte	59
 5400 0e86 4E       		.byte	78
 5401 0e87 FF       		.byte	-1
 5402 0e88 D1       		.byte	-47
 5403 0e89 3B       		.byte	59
 5404 0e8a 4E       		.byte	78
 5405 0e8b FF       		.byte	-1
 5406 0e8c D1       		.byte	-47
 5407 0e8d 3A       		.byte	58
 5408 0e8e 4E       		.byte	78
 5409 0e8f FF       		.byte	-1
 5410 0e90 D1       		.byte	-47
 5411 0e91 3A       		.byte	58
 5412 0e92 4E       		.byte	78
 5413 0e93 FF       		.byte	-1
 5414 0e94 D0       		.byte	-48
 5415 0e95 39       		.byte	57
 5416 0e96 4E       		.byte	78
 5417 0e97 FF       		.byte	-1
 5418 0e98 D0       		.byte	-48
 5419 0e99 39       		.byte	57
 5420 0e9a 4D       		.byte	77
 5421 0e9b FF       		.byte	-1
 5422 0e9c CF       		.byte	-49
 5423 0e9d 39       		.byte	57
 5424 0e9e 4D       		.byte	77
 5425 0e9f FF       		.byte	-1
 5426 0ea0 CF       		.byte	-49
 5427 0ea1 38       		.byte	56
 5428 0ea2 4D       		.byte	77
 5429 0ea3 FF       		.byte	-1
 5430 0ea4 CE       		.byte	-50
 5431 0ea5 38       		.byte	56
 5432 0ea6 4D       		.byte	77
GAS LISTING /tmp/ccK2IhnQ.s 			page 111


 5433 0ea7 FF       		.byte	-1
 5434 0ea8 CE       		.byte	-50
 5435 0ea9 38       		.byte	56
 5436 0eaa 4D       		.byte	77
 5437 0eab FF       		.byte	-1
 5438 0eac CE       		.byte	-50
 5439 0ead 37       		.byte	55
 5440 0eae 4D       		.byte	77
 5441 0eaf FF       		.byte	-1
 5442 0eb0 CD       		.byte	-51
 5443 0eb1 37       		.byte	55
 5444 0eb2 4D       		.byte	77
 5445 0eb3 FF       		.byte	-1
 5446 0eb4 CD       		.byte	-51
 5447 0eb5 36       		.byte	54
 5448 0eb6 4D       		.byte	77
 5449 0eb7 FF       		.byte	-1
 5450 0eb8 CC       		.byte	-52
 5451 0eb9 36       		.byte	54
 5452 0eba 4D       		.byte	77
 5453 0ebb FF       		.byte	-1
 5454 0ebc CC       		.byte	-52
 5455 0ebd 36       		.byte	54
 5456 0ebe 4D       		.byte	77
 5457 0ebf FF       		.byte	-1
 5458 0ec0 CB       		.byte	-53
 5459 0ec1 35       		.byte	53
 5460 0ec2 4D       		.byte	77
 5461 0ec3 FF       		.byte	-1
 5462 0ec4 CB       		.byte	-53
 5463 0ec5 35       		.byte	53
 5464 0ec6 4C       		.byte	76
 5465 0ec7 FF       		.byte	-1
 5466 0ec8 CB       		.byte	-53
 5467 0ec9 34       		.byte	52
 5468 0eca 4C       		.byte	76
 5469 0ecb FF       		.byte	-1
 5470 0ecc CA       		.byte	-54
 5471 0ecd 34       		.byte	52
 5472 0ece 4C       		.byte	76
 5473 0ecf FF       		.byte	-1
 5474 0ed0 CA       		.byte	-54
 5475 0ed1 34       		.byte	52
 5476 0ed2 4C       		.byte	76
 5477 0ed3 FF       		.byte	-1
 5478 0ed4 C9       		.byte	-55
 5479 0ed5 33       		.byte	51
 5480 0ed6 4C       		.byte	76
 5481 0ed7 FF       		.byte	-1
 5482 0ed8 C9       		.byte	-55
 5483 0ed9 33       		.byte	51
 5484 0eda 4C       		.byte	76
 5485 0edb FF       		.byte	-1
 5486 0edc C8       		.byte	-56
 5487 0edd 32       		.byte	50
 5488 0ede 4C       		.byte	76
 5489 0edf FF       		.byte	-1
GAS LISTING /tmp/ccK2IhnQ.s 			page 112


 5490 0ee0 C8       		.byte	-56
 5491 0ee1 32       		.byte	50
 5492 0ee2 4C       		.byte	76
 5493 0ee3 FF       		.byte	-1
 5494 0ee4 C8       		.byte	-56
 5495 0ee5 32       		.byte	50
 5496 0ee6 4C       		.byte	76
 5497 0ee7 FF       		.byte	-1
 5498 0ee8 C7       		.byte	-57
 5499 0ee9 31       		.byte	49
 5500 0eea 4C       		.byte	76
 5501 0eeb FF       		.byte	-1
 5502 0eec C7       		.byte	-57
 5503 0eed 31       		.byte	49
 5504 0eee 4C       		.byte	76
 5505 0eef FF       		.byte	-1
 5506 0ef0 C6       		.byte	-58
 5507 0ef1 30       		.byte	48
 5508 0ef2 4B       		.byte	75
 5509 0ef3 FF       		.byte	-1
 5510 0ef4 C6       		.byte	-58
 5511 0ef5 30       		.byte	48
 5512 0ef6 4B       		.byte	75
 5513 0ef7 FF       		.byte	-1
 5514 0ef8 C6       		.byte	-58
 5515 0ef9 30       		.byte	48
 5516 0efa 4B       		.byte	75
 5517 0efb FF       		.byte	-1
 5518 0efc C5       		.byte	-59
 5519 0efd 2F       		.byte	47
 5520 0efe 4B       		.byte	75
 5521 0eff FF       		.byte	-1
 5522 0f00 C5       		.byte	-59
 5523 0f01 2F       		.byte	47
 5524 0f02 4B       		.byte	75
 5525 0f03 FF       		.byte	-1
 5526 0f04 C4       		.byte	-60
 5527 0f05 2E       		.byte	46
 5528 0f06 4B       		.byte	75
 5529 0f07 FF       		.byte	-1
 5530 0f08 C4       		.byte	-60
 5531 0f09 2E       		.byte	46
 5532 0f0a 4B       		.byte	75
 5533 0f0b FF       		.byte	-1
 5534 0f0c C3       		.byte	-61
 5535 0f0d 2E       		.byte	46
 5536 0f0e 4B       		.byte	75
 5537 0f0f FF       		.byte	-1
 5538 0f10 C3       		.byte	-61
 5539 0f11 2D       		.byte	45
 5540 0f12 4B       		.byte	75
 5541 0f13 FF       		.byte	-1
 5542 0f14 C3       		.byte	-61
 5543 0f15 2D       		.byte	45
 5544 0f16 4B       		.byte	75
 5545 0f17 FF       		.byte	-1
 5546 0f18 C2       		.byte	-62
GAS LISTING /tmp/ccK2IhnQ.s 			page 113


 5547 0f19 2C       		.byte	44
 5548 0f1a 4A       		.byte	74
 5549 0f1b FF       		.byte	-1
 5550 0f1c C2       		.byte	-62
 5551 0f1d 2C       		.byte	44
 5552 0f1e 4A       		.byte	74
 5553 0f1f FF       		.byte	-1
 5554 0f20 C1       		.byte	-63
 5555 0f21 2B       		.byte	43
 5556 0f22 4A       		.byte	74
 5557 0f23 FF       		.byte	-1
 5558 0f24 C1       		.byte	-63
 5559 0f25 2B       		.byte	43
 5560 0f26 4A       		.byte	74
 5561 0f27 FF       		.byte	-1
 5562 0f28 C0       		.byte	-64
 5563 0f29 2B       		.byte	43
 5564 0f2a 4A       		.byte	74
 5565 0f2b FF       		.byte	-1
 5566 0f2c C0       		.byte	-64
 5567 0f2d 2A       		.byte	42
 5568 0f2e 4A       		.byte	74
 5569 0f2f FF       		.byte	-1
 5570 0f30 C0       		.byte	-64
 5571 0f31 2A       		.byte	42
 5572 0f32 4A       		.byte	74
 5573 0f33 FF       		.byte	-1
 5574 0f34 BF       		.byte	-65
 5575 0f35 29       		.byte	41
 5576 0f36 4A       		.byte	74
 5577 0f37 FF       		.byte	-1
 5578 0f38 B4       		.byte	-76
 5579 0f39 1D       		.byte	29
 5580 0f3a 47       		.byte	71
 5581 0f3b FF       		.byte	-1
 5582 0f3c B3       		.byte	-77
 5583 0f3d 1C       		.byte	28
 5584 0f3e 47       		.byte	71
 5585 0f3f FF       		.byte	-1
 5586 0f40 B3       		.byte	-77
 5587 0f41 1C       		.byte	28
 5588 0f42 47       		.byte	71
 5589 0f43 FF       		.byte	-1
 5590 0f44 B2       		.byte	-78
 5591 0f45 1B       		.byte	27
 5592 0f46 47       		.byte	71
 5593 0f47 FF       		.byte	-1
 5594 0f48 B2       		.byte	-78
 5595 0f49 1B       		.byte	27
 5596 0f4a 47       		.byte	71
 5597 0f4b FF       		.byte	-1
 5598 0f4c B1       		.byte	-79
 5599 0f4d 1B       		.byte	27
 5600 0f4e 47       		.byte	71
 5601 0f4f FF       		.byte	-1
 5602 0f50 B1       		.byte	-79
 5603 0f51 1A       		.byte	26
GAS LISTING /tmp/ccK2IhnQ.s 			page 114


 5604 0f52 46       		.byte	70
 5605 0f53 FF       		.byte	-1
 5606 0f54 B1       		.byte	-79
 5607 0f55 1A       		.byte	26
 5608 0f56 46       		.byte	70
 5609 0f57 FF       		.byte	-1
 5610 0f58 B0       		.byte	-80
 5611 0f59 19       		.byte	25
 5612 0f5a 46       		.byte	70
 5613 0f5b FF       		.byte	-1
 5614 0f5c B0       		.byte	-80
 5615 0f5d 19       		.byte	25
 5616 0f5e 46       		.byte	70
 5617 0f5f FF       		.byte	-1
 5618 0f60 AF       		.byte	-81
 5619 0f61 18       		.byte	24
 5620 0f62 46       		.byte	70
 5621 0f63 FF       		.byte	-1
 5622 0f64 AF       		.byte	-81
 5623 0f65 18       		.byte	24
 5624 0f66 46       		.byte	70
 5625 0f67 FF       		.byte	-1
 5626 0f68 AE       		.byte	-82
 5627 0f69 17       		.byte	23
 5628 0f6a 46       		.byte	70
 5629 0f6b FF       		.byte	-1
 5630 0f6c AE       		.byte	-82
 5631 0f6d 17       		.byte	23
 5632 0f6e 46       		.byte	70
 5633 0f6f FF       		.byte	-1
 5634 0f70 AE       		.byte	-82
 5635 0f71 17       		.byte	23
 5636 0f72 46       		.byte	70
 5637 0f73 FF       		.byte	-1
 5638 0f74 AD       		.byte	-83
 5639 0f75 16       		.byte	22
 5640 0f76 46       		.byte	70
 5641 0f77 FF       		.byte	-1
 5642 0f78 AD       		.byte	-83
 5643 0f79 16       		.byte	22
 5644 0f7a 45       		.byte	69
 5645 0f7b FF       		.byte	-1
 5646 0f7c AC       		.byte	-84
 5647 0f7d 15       		.byte	21
 5648 0f7e 45       		.byte	69
 5649 0f7f FF       		.byte	-1
 5650 0f80 AC       		.byte	-84
 5651 0f81 15       		.byte	21
 5652 0f82 45       		.byte	69
 5653 0f83 FF       		.byte	-1
 5654 0f84 AB       		.byte	-85
 5655 0f85 14       		.byte	20
 5656 0f86 45       		.byte	69
 5657 0f87 FF       		.byte	-1
 5658 0f88 AB       		.byte	-85
 5659 0f89 14       		.byte	20
 5660 0f8a 45       		.byte	69
GAS LISTING /tmp/ccK2IhnQ.s 			page 115


 5661 0f8b FF       		.byte	-1
 5662 0f8c AB       		.byte	-85
 5663 0f8d 13       		.byte	19
 5664 0f8e 45       		.byte	69
 5665 0f8f FF       		.byte	-1
 5666 0f90 AA       		.byte	-86
 5667 0f91 13       		.byte	19
 5668 0f92 45       		.byte	69
 5669 0f93 FF       		.byte	-1
 5670 0f94 AA       		.byte	-86
 5671 0f95 12       		.byte	18
 5672 0f96 45       		.byte	69
 5673 0f97 FF       		.byte	-1
 5674 0f98 A9       		.byte	-87
 5675 0f99 12       		.byte	18
 5676 0f9a 45       		.byte	69
 5677 0f9b FF       		.byte	-1
 5678 0f9c A9       		.byte	-87
 5679 0f9d 11       		.byte	17
 5680 0f9e 44       		.byte	68
 5681 0f9f FF       		.byte	-1
 5682 0fa0 A8       		.byte	-88
 5683 0fa1 11       		.byte	17
 5684 0fa2 44       		.byte	68
 5685 0fa3 FF       		.byte	-1
 5686 0fa4 A8       		.byte	-88
 5687 0fa5 10       		.byte	16
 5688 0fa6 44       		.byte	68
 5689 0fa7 FF       		.byte	-1
 5690 0fa8 A8       		.byte	-88
 5691 0fa9 10       		.byte	16
 5692 0faa 44       		.byte	68
 5693 0fab FF       		.byte	-1
 5694 0fac A7       		.byte	-89
 5695 0fad 0F       		.byte	15
 5696 0fae 44       		.byte	68
 5697 0faf FF       		.byte	-1
 5698 0fb0 A7       		.byte	-89
 5699 0fb1 0E       		.byte	14
 5700 0fb2 44       		.byte	68
 5701 0fb3 FF       		.byte	-1
 5702 0fb4 A6       		.byte	-90
 5703 0fb5 0E       		.byte	14
 5704 0fb6 44       		.byte	68
 5705 0fb7 FF       		.byte	-1
 5706 0fb8 A6       		.byte	-90
 5707 0fb9 0D       		.byte	13
 5708 0fba 44       		.byte	68
 5709 0fbb FF       		.byte	-1
 5710 0fbc A5       		.byte	-91
 5711 0fbd 0D       		.byte	13
 5712 0fbe 44       		.byte	68
 5713 0fbf FF       		.byte	-1
 5714 0fc0 A5       		.byte	-91
 5715 0fc1 0C       		.byte	12
 5716 0fc2 43       		.byte	67
 5717 0fc3 FF       		.byte	-1
GAS LISTING /tmp/ccK2IhnQ.s 			page 116


 5718 0fc4 A4       		.byte	-92
 5719 0fc5 0C       		.byte	12
 5720 0fc6 43       		.byte	67
 5721 0fc7 FF       		.byte	-1
 5722 0fc8 A4       		.byte	-92
 5723 0fc9 0B       		.byte	11
 5724 0fca 43       		.byte	67
 5725 0fcb FF       		.byte	-1
 5726 0fcc A4       		.byte	-92
 5727 0fcd 0A       		.byte	10
 5728 0fce 43       		.byte	67
 5729 0fcf FF       		.byte	-1
 5730 0fd0 A3       		.byte	-93
 5731 0fd1 0A       		.byte	10
 5732 0fd2 43       		.byte	67
 5733 0fd3 FF       		.byte	-1
 5734 0fd4 A3       		.byte	-93
 5735 0fd5 09       		.byte	9
 5736 0fd6 43       		.byte	67
 5737 0fd7 FF       		.byte	-1
 5738 0fd8 A2       		.byte	-94
 5739 0fd9 08       		.byte	8
 5740 0fda 43       		.byte	67
 5741 0fdb FF       		.byte	-1
 5742 0fdc A2       		.byte	-94
 5743 0fdd 07       		.byte	7
 5744 0fde 43       		.byte	67
 5745 0fdf FF       		.byte	-1
 5746 0fe0 A1       		.byte	-95
 5747 0fe1 07       		.byte	7
 5748 0fe2 43       		.byte	67
 5749 0fe3 FF       		.byte	-1
 5750 0fe4 A1       		.byte	-95
 5751 0fe5 06       		.byte	6
 5752 0fe6 42       		.byte	66
 5753 0fe7 FF       		.byte	-1
 5754 0fe8 A1       		.byte	-95
 5755 0fe9 05       		.byte	5
 5756 0fea 42       		.byte	66
 5757 0feb FF       		.byte	-1
 5758 0fec A0       		.byte	-96
 5759 0fed 05       		.byte	5
 5760 0fee 42       		.byte	66
 5761 0fef FF       		.byte	-1
 5762 0ff0 A0       		.byte	-96
 5763 0ff1 04       		.byte	4
 5764 0ff2 42       		.byte	66
 5765 0ff3 FF       		.byte	-1
 5766 0ff4 9F       		.byte	-97
 5767 0ff5 03       		.byte	3
 5768 0ff6 42       		.byte	66
 5769 0ff7 FF       		.byte	-1
 5770 0ff8 9F       		.byte	-97
 5771 0ff9 02       		.byte	2
 5772 0ffa 42       		.byte	66
 5773 0ffb FF       		.byte	-1
 5774 0ffc 9E       		.byte	-98
GAS LISTING /tmp/ccK2IhnQ.s 			page 117


 5775 0ffd 02       		.byte	2
 5776 0ffe 42       		.byte	66
 5777 0fff FF       		.byte	-1
 5778 1000 9E       		.byte	-98
 5779 1001 01       		.byte	1
 5780 1002 42       		.byte	66
 5781 1003 FF       		.byte	-1
 5782              		.section	.rodata.cst4,"aM",@progbits,4
 5783              		.align 4
 5784              	.LC0:
 5785 0000 0000003F 		.long	1056964608
 5786              		.align 4
 5787              	.LC1:
 5788 0004 0000005F 		.long	1593835520
 5789              		.align 4
 5790              	.LC3:
 5791 0008 0000803F 		.long	1065353216
 5792              		.text
 5793              	.Letext0:
 5794              		.section	.debug_loc,"",@progbits
 5795              	.Ldebug_loc0:
 5796              	.LLST0:
 5797 0000 00000000 		.quad	.LVL0-.Ltext0
 5797      00000000 
 5798 0008 7D000000 		.quad	.LVL5-.Ltext0
 5798      00000000 
 5799 0010 0100     		.value	0x1
 5800 0012 54       		.byte	0x54
 5801 0013 1A010000 		.quad	.LVL11-.Ltext0
 5801      00000000 
 5802 001b 25010000 		.quad	.LFE28-.Ltext0
 5802      00000000 
 5803 0023 0100     		.value	0x1
 5804 0025 54       		.byte	0x54
 5805 0026 00000000 		.quad	0x0
 5805      00000000 
 5806 002e 00000000 		.quad	0x0
 5806      00000000 
 5807              	.LLST1:
 5808 0036 00000000 		.quad	.LVL0-.Ltext0
 5808      00000000 
 5809 003e 82000000 		.quad	.LVL6-.Ltext0
 5809      00000000 
 5810 0046 0100     		.value	0x1
 5811 0048 51       		.byte	0x51
 5812 0049 1A010000 		.quad	.LVL11-.Ltext0
 5812      00000000 
 5813 0051 25010000 		.quad	.LFE28-.Ltext0
 5813      00000000 
 5814 0059 0100     		.value	0x1
 5815 005b 51       		.byte	0x51
 5816 005c 00000000 		.quad	0x0
 5816      00000000 
 5817 0064 00000000 		.quad	0x0
 5817      00000000 
 5818              	.LLST2:
 5819 006c 00000000 		.quad	.LVL0-.Ltext0
GAS LISTING /tmp/ccK2IhnQ.s 			page 118


 5819      00000000 
 5820 0074 B2000000 		.quad	.LVL7-.Ltext0
 5820      00000000 
 5821 007c 0100     		.value	0x1
 5822 007e 52       		.byte	0x52
 5823 007f 1A010000 		.quad	.LVL11-.Ltext0
 5823      00000000 
 5824 0087 25010000 		.quad	.LFE28-.Ltext0
 5824      00000000 
 5825 008f 0100     		.value	0x1
 5826 0091 52       		.byte	0x52
 5827 0092 00000000 		.quad	0x0
 5827      00000000 
 5828 009a 00000000 		.quad	0x0
 5828      00000000 
 5829              	.LLST3:
 5830 00a2 43000000 		.quad	.LVL1-.Ltext0
 5830      00000000 
 5831 00aa 0F010000 		.quad	.LVL10-.Ltext0
 5831      00000000 
 5832 00b2 0100     		.value	0x1
 5833 00b4 56       		.byte	0x56
 5834 00b5 1A010000 		.quad	.LVL11-.Ltext0
 5834      00000000 
 5835 00bd 25010000 		.quad	.LFE28-.Ltext0
 5835      00000000 
 5836 00c5 0100     		.value	0x1
 5837 00c7 56       		.byte	0x56
 5838 00c8 00000000 		.quad	0x0
 5838      00000000 
 5839 00d0 00000000 		.quad	0x0
 5839      00000000 
 5840              	.LLST4:
 5841 00d8 53000000 		.quad	.LVL2-.Ltext0
 5841      00000000 
 5842 00e0 B2000000 		.quad	.LVL7-.Ltext0
 5842      00000000 
 5843 00e8 0100     		.value	0x1
 5844 00ea 59       		.byte	0x59
 5845 00eb 1A010000 		.quad	.LVL11-.Ltext0
 5845      00000000 
 5846 00f3 25010000 		.quad	.LFE28-.Ltext0
 5846      00000000 
 5847 00fb 0100     		.value	0x1
 5848 00fd 59       		.byte	0x59
 5849 00fe 00000000 		.quad	0x0
 5849      00000000 
 5850 0106 00000000 		.quad	0x0
 5850      00000000 
 5851              	.LLST5:
 5852 010e 63000000 		.quad	.LVL3-.Ltext0
 5852      00000000 
 5853 0116 0F010000 		.quad	.LVL10-.Ltext0
 5853      00000000 
 5854 011e 0100     		.value	0x1
 5855 0120 5D       		.byte	0x5d
 5856 0121 1A010000 		.quad	.LVL11-.Ltext0
GAS LISTING /tmp/ccK2IhnQ.s 			page 119


 5856      00000000 
 5857 0129 25010000 		.quad	.LFE28-.Ltext0
 5857      00000000 
 5858 0131 0100     		.value	0x1
 5859 0133 5D       		.byte	0x5d
 5860 0134 00000000 		.quad	0x0
 5860      00000000 
 5861 013c 00000000 		.quad	0x0
 5861      00000000 
 5862              	.LLST6:
 5863 0144 70000000 		.quad	.LVL4-.Ltext0
 5863      00000000 
 5864 014c 0F010000 		.quad	.LVL10-.Ltext0
 5864      00000000 
 5865 0154 0100     		.value	0x1
 5866 0156 53       		.byte	0x53
 5867 0157 00000000 		.quad	0x0
 5867      00000000 
 5868 015f 00000000 		.quad	0x0
 5868      00000000 
 5869              	.LLST7:
 5870 0167 70000000 		.quad	.LVL4-.Ltext0
 5870      00000000 
 5871 016f 0F010000 		.quad	.LVL10-.Ltext0
 5871      00000000 
 5872 0177 0100     		.value	0x1
 5873 0179 59       		.byte	0x59
 5874 017a 00000000 		.quad	0x0
 5874      00000000 
 5875 0182 00000000 		.quad	0x0
 5875      00000000 
 5876              	.LLST8:
 5877 018a B2000000 		.quad	.LVL7-.Ltext0
 5877      00000000 
 5878 0192 DC000000 		.quad	.LVL8-.Ltext0
 5878      00000000 
 5879 019a 1C00     		.value	0x1c
 5880 019c 7F       		.byte	0x7f
 5881 019d 00       		.sleb128 0
 5882 019e 79       		.byte	0x79
 5883 019f 00       		.sleb128 0
 5884 01a0 22       		.byte	0x22
 5885 01a1 75       		.byte	0x75
 5886 01a2 0C       		.sleb128 12
 5887 01a3 94       		.byte	0x94
 5888 01a4 04       		.byte	0x4
 5889 01a5 1E       		.byte	0x1e
 5890 01a6 08       		.byte	0x8
 5891 01a7 20       		.byte	0x20
 5892 01a8 24       		.byte	0x24
 5893 01a9 08       		.byte	0x8
 5894 01aa 20       		.byte	0x20
 5895 01ab 25       		.byte	0x25
 5896 01ac 91       		.byte	0x91
 5897 01ad B87F     		.sleb128 -72
 5898 01af 06       		.byte	0x6
 5899 01b0 22       		.byte	0x22
GAS LISTING /tmp/ccK2IhnQ.s 			page 120


 5900 01b1 32       		.byte	0x32
 5901 01b2 24       		.byte	0x24
 5902 01b3 75       		.byte	0x75
 5903 01b4 00       		.sleb128 0
 5904 01b5 06       		.byte	0x6
 5905 01b6 22       		.byte	0x22
 5906 01b7 9F       		.byte	0x9f
 5907 01b8 00000000 		.quad	0x0
 5907      00000000 
 5908 01c0 00000000 		.quad	0x0
 5908      00000000 
 5909              	.LLST9:
 5910 01c8 B2000000 		.quad	.LVL7-.Ltext0
 5910      00000000 
 5911 01d0 DC000000 		.quad	.LVL8-.Ltext0
 5911      00000000 
 5912 01d8 1500     		.value	0x15
 5913 01da 79       		.byte	0x79
 5914 01db 00       		.sleb128 0
 5915 01dc 7C       		.byte	0x7c
 5916 01dd 00       		.sleb128 0
 5917 01de 1E       		.byte	0x1e
 5918 01df 08       		.byte	0x8
 5919 01e0 20       		.byte	0x20
 5920 01e1 24       		.byte	0x24
 5921 01e2 08       		.byte	0x8
 5922 01e3 20       		.byte	0x20
 5923 01e4 25       		.byte	0x25
 5924 01e5 91       		.byte	0x91
 5925 01e6 40       		.sleb128 -64
 5926 01e7 06       		.byte	0x6
 5927 01e8 22       		.byte	0x22
 5928 01e9 32       		.byte	0x32
 5929 01ea 24       		.byte	0x24
 5930 01eb 7E       		.byte	0x7e
 5931 01ec 00       		.sleb128 0
 5932 01ed 22       		.byte	0x22
 5933 01ee 9F       		.byte	0x9f
 5934 01ef 00000000 		.quad	0x0
 5934      00000000 
 5935 01f7 00000000 		.quad	0x0
 5935      00000000 
 5936              	.LLST10:
 5937 01ff B2000000 		.quad	.LVL7-.Ltext0
 5937      00000000 
 5938 0207 DC000000 		.quad	.LVL8-.Ltext0
 5938      00000000 
 5939 020f 0100     		.value	0x1
 5940 0211 56       		.byte	0x56
 5941 0212 00000000 		.quad	0x0
 5941      00000000 
 5942 021a 00000000 		.quad	0x0
 5942      00000000 
 5943              	.LLST11:
 5944 0222 40010000 		.quad	.LVL13-.Ltext0
 5944      00000000 
 5945 022a BD010000 		.quad	.LVL18-.Ltext0
GAS LISTING /tmp/ccK2IhnQ.s 			page 121


 5945      00000000 
 5946 0232 0100     		.value	0x1
 5947 0234 54       		.byte	0x54
 5948 0235 5E020000 		.quad	.LVL24-.Ltext0
 5948      00000000 
 5949 023d 69020000 		.quad	.LFE30-.Ltext0
 5949      00000000 
 5950 0245 0100     		.value	0x1
 5951 0247 54       		.byte	0x54
 5952 0248 00000000 		.quad	0x0
 5952      00000000 
 5953 0250 00000000 		.quad	0x0
 5953      00000000 
 5954              	.LLST12:
 5955 0258 40010000 		.quad	.LVL13-.Ltext0
 5955      00000000 
 5956 0260 C2010000 		.quad	.LVL19-.Ltext0
 5956      00000000 
 5957 0268 0100     		.value	0x1
 5958 026a 51       		.byte	0x51
 5959 026b 5E020000 		.quad	.LVL24-.Ltext0
 5959      00000000 
 5960 0273 69020000 		.quad	.LFE30-.Ltext0
 5960      00000000 
 5961 027b 0100     		.value	0x1
 5962 027d 51       		.byte	0x51
 5963 027e 00000000 		.quad	0x0
 5963      00000000 
 5964 0286 00000000 		.quad	0x0
 5964      00000000 
 5965              	.LLST13:
 5966 028e 40010000 		.quad	.LVL13-.Ltext0
 5966      00000000 
 5967 0296 F2010000 		.quad	.LVL20-.Ltext0
 5967      00000000 
 5968 029e 0100     		.value	0x1
 5969 02a0 52       		.byte	0x52
 5970 02a1 5E020000 		.quad	.LVL24-.Ltext0
 5970      00000000 
 5971 02a9 69020000 		.quad	.LFE30-.Ltext0
 5971      00000000 
 5972 02b1 0100     		.value	0x1
 5973 02b3 52       		.byte	0x52
 5974 02b4 00000000 		.quad	0x0
 5974      00000000 
 5975 02bc 00000000 		.quad	0x0
 5975      00000000 
 5976              	.LLST14:
 5977 02c4 83010000 		.quad	.LVL14-.Ltext0
 5977      00000000 
 5978 02cc 53020000 		.quad	.LVL23-.Ltext0
 5978      00000000 
 5979 02d4 0100     		.value	0x1
 5980 02d6 56       		.byte	0x56
 5981 02d7 5E020000 		.quad	.LVL24-.Ltext0
 5981      00000000 
 5982 02df 69020000 		.quad	.LFE30-.Ltext0
GAS LISTING /tmp/ccK2IhnQ.s 			page 122


 5982      00000000 
 5983 02e7 0100     		.value	0x1
 5984 02e9 56       		.byte	0x56
 5985 02ea 00000000 		.quad	0x0
 5985      00000000 
 5986 02f2 00000000 		.quad	0x0
 5986      00000000 
 5987              	.LLST15:
 5988 02fa 93010000 		.quad	.LVL15-.Ltext0
 5988      00000000 
 5989 0302 F2010000 		.quad	.LVL20-.Ltext0
 5989      00000000 
 5990 030a 0100     		.value	0x1
 5991 030c 59       		.byte	0x59
 5992 030d 5E020000 		.quad	.LVL24-.Ltext0
 5992      00000000 
 5993 0315 69020000 		.quad	.LFE30-.Ltext0
 5993      00000000 
 5994 031d 0100     		.value	0x1
 5995 031f 59       		.byte	0x59
 5996 0320 00000000 		.quad	0x0
 5996      00000000 
 5997 0328 00000000 		.quad	0x0
 5997      00000000 
 5998              	.LLST16:
 5999 0330 A3010000 		.quad	.LVL16-.Ltext0
 5999      00000000 
 6000 0338 53020000 		.quad	.LVL23-.Ltext0
 6000      00000000 
 6001 0340 0100     		.value	0x1
 6002 0342 5D       		.byte	0x5d
 6003 0343 5E020000 		.quad	.LVL24-.Ltext0
 6003      00000000 
 6004 034b 69020000 		.quad	.LFE30-.Ltext0
 6004      00000000 
 6005 0353 0100     		.value	0x1
 6006 0355 5D       		.byte	0x5d
 6007 0356 00000000 		.quad	0x0
 6007      00000000 
 6008 035e 00000000 		.quad	0x0
 6008      00000000 
 6009              	.LLST17:
 6010 0366 B0010000 		.quad	.LVL17-.Ltext0
 6010      00000000 
 6011 036e 53020000 		.quad	.LVL23-.Ltext0
 6011      00000000 
 6012 0376 0100     		.value	0x1
 6013 0378 53       		.byte	0x53
 6014 0379 00000000 		.quad	0x0
 6014      00000000 
 6015 0381 00000000 		.quad	0x0
 6015      00000000 
 6016              	.LLST18:
 6017 0389 B0010000 		.quad	.LVL17-.Ltext0
 6017      00000000 
 6018 0391 53020000 		.quad	.LVL23-.Ltext0
 6018      00000000 
GAS LISTING /tmp/ccK2IhnQ.s 			page 123


 6019 0399 0100     		.value	0x1
 6020 039b 59       		.byte	0x59
 6021 039c 00000000 		.quad	0x0
 6021      00000000 
 6022 03a4 00000000 		.quad	0x0
 6022      00000000 
 6023              	.LLST19:
 6024 03ac F2010000 		.quad	.LVL20-.Ltext0
 6024      00000000 
 6025 03b4 1C020000 		.quad	.LVL21-.Ltext0
 6025      00000000 
 6026 03bc 1C00     		.value	0x1c
 6027 03be 7F       		.byte	0x7f
 6028 03bf 00       		.sleb128 0
 6029 03c0 79       		.byte	0x79
 6030 03c1 00       		.sleb128 0
 6031 03c2 22       		.byte	0x22
 6032 03c3 75       		.byte	0x75
 6033 03c4 0C       		.sleb128 12
 6034 03c5 94       		.byte	0x94
 6035 03c6 04       		.byte	0x4
 6036 03c7 1E       		.byte	0x1e
 6037 03c8 08       		.byte	0x8
 6038 03c9 20       		.byte	0x20
 6039 03ca 24       		.byte	0x24
 6040 03cb 08       		.byte	0x8
 6041 03cc 20       		.byte	0x20
 6042 03cd 25       		.byte	0x25
 6043 03ce 91       		.byte	0x91
 6044 03cf B87F     		.sleb128 -72
 6045 03d1 06       		.byte	0x6
 6046 03d2 22       		.byte	0x22
 6047 03d3 32       		.byte	0x32
 6048 03d4 24       		.byte	0x24
 6049 03d5 75       		.byte	0x75
 6050 03d6 00       		.sleb128 0
 6051 03d7 06       		.byte	0x6
 6052 03d8 22       		.byte	0x22
 6053 03d9 9F       		.byte	0x9f
 6054 03da 00000000 		.quad	0x0
 6054      00000000 
 6055 03e2 00000000 		.quad	0x0
 6055      00000000 
 6056              	.LLST20:
 6057 03ea F2010000 		.quad	.LVL20-.Ltext0
 6057      00000000 
 6058 03f2 1C020000 		.quad	.LVL21-.Ltext0
 6058      00000000 
 6059 03fa 1500     		.value	0x15
 6060 03fc 79       		.byte	0x79
 6061 03fd 00       		.sleb128 0
 6062 03fe 7C       		.byte	0x7c
 6063 03ff 00       		.sleb128 0
 6064 0400 1E       		.byte	0x1e
 6065 0401 08       		.byte	0x8
 6066 0402 20       		.byte	0x20
 6067 0403 24       		.byte	0x24
GAS LISTING /tmp/ccK2IhnQ.s 			page 124


 6068 0404 08       		.byte	0x8
 6069 0405 20       		.byte	0x20
 6070 0406 25       		.byte	0x25
 6071 0407 91       		.byte	0x91
 6072 0408 40       		.sleb128 -64
 6073 0409 06       		.byte	0x6
 6074 040a 22       		.byte	0x22
 6075 040b 32       		.byte	0x32
 6076 040c 24       		.byte	0x24
 6077 040d 7E       		.byte	0x7e
 6078 040e 00       		.sleb128 0
 6079 040f 22       		.byte	0x22
 6080 0410 9F       		.byte	0x9f
 6081 0411 00000000 		.quad	0x0
 6081      00000000 
 6082 0419 00000000 		.quad	0x0
 6082      00000000 
 6083              	.LLST21:
 6084 0421 F2010000 		.quad	.LVL20-.Ltext0
 6084      00000000 
 6085 0429 1C020000 		.quad	.LVL21-.Ltext0
 6085      00000000 
 6086 0431 0100     		.value	0x1
 6087 0433 56       		.byte	0x56
 6088 0434 00000000 		.quad	0x0
 6088      00000000 
 6089 043c 00000000 		.quad	0x0
 6089      00000000 
 6090              	.LLST22:
 6091 0444 90020000 		.quad	.LVL27-.Ltext0
 6091      00000000 
 6092 044c 97020000 		.quad	.LVL28-.Ltext0
 6092      00000000 
 6093 0454 0100     		.value	0x1
 6094 0456 55       		.byte	0x55
 6095 0457 97020000 		.quad	.LVL28-.Ltext0
 6095      00000000 
 6096 045f A0020000 		.quad	.LVL29-.Ltext0
 6096      00000000 
 6097 0467 0100     		.value	0x1
 6098 0469 53       		.byte	0x53
 6099 046a A0020000 		.quad	.LVL29-.Ltext0
 6099      00000000 
 6100 0472 A5020000 		.quad	.LFE42-.Ltext0
 6100      00000000 
 6101 047a 0100     		.value	0x1
 6102 047c 55       		.byte	0x55
 6103 047d 00000000 		.quad	0x0
 6103      00000000 
 6104 0485 00000000 		.quad	0x0
 6104      00000000 
 6105              	.LLST23:
 6106 048d B0020000 		.quad	.LVL30-.Ltext0
 6106      00000000 
 6107 0495 B7020000 		.quad	.LVL31-.Ltext0
 6107      00000000 
 6108 049d 0100     		.value	0x1
GAS LISTING /tmp/ccK2IhnQ.s 			page 125


 6109 049f 55       		.byte	0x55
 6110 04a0 B7020000 		.quad	.LVL31-.Ltext0
 6110      00000000 
 6111 04a8 C0020000 		.quad	.LVL32-.Ltext0
 6111      00000000 
 6112 04b0 0100     		.value	0x1
 6113 04b2 53       		.byte	0x53
 6114 04b3 C0020000 		.quad	.LVL32-.Ltext0
 6114      00000000 
 6115 04bb C5020000 		.quad	.LFE40-.Ltext0
 6115      00000000 
 6116 04c3 0100     		.value	0x1
 6117 04c5 55       		.byte	0x55
 6118 04c6 00000000 		.quad	0x0
 6118      00000000 
 6119 04ce 00000000 		.quad	0x0
 6119      00000000 
 6120              	.LLST24:
 6121 04d6 D0020000 		.quad	.LVL33-.Ltext0
 6121      00000000 
 6122 04de D7020000 		.quad	.LVL34-.Ltext0
 6122      00000000 
 6123 04e6 0100     		.value	0x1
 6124 04e8 55       		.byte	0x55
 6125 04e9 D7020000 		.quad	.LVL34-.Ltext0
 6125      00000000 
 6126 04f1 E0020000 		.quad	.LVL35-.Ltext0
 6126      00000000 
 6127 04f9 0100     		.value	0x1
 6128 04fb 53       		.byte	0x53
 6129 04fc E0020000 		.quad	.LVL35-.Ltext0
 6129      00000000 
 6130 0504 E5020000 		.quad	.LFE24-.Ltext0
 6130      00000000 
 6131 050c 0100     		.value	0x1
 6132 050e 55       		.byte	0x55
 6133 050f 00000000 		.quad	0x0
 6133      00000000 
 6134 0517 00000000 		.quad	0x0
 6134      00000000 
 6135              	.LLST25:
 6136 051f F0020000 		.quad	.LVL36-.Ltext0
 6136      00000000 
 6137 0527 2A030000 		.quad	.LVL38-.Ltext0
 6137      00000000 
 6138 052f 0100     		.value	0x1
 6139 0531 55       		.byte	0x55
 6140 0532 2A030000 		.quad	.LVL38-.Ltext0
 6140      00000000 
 6141 053a 76030000 		.quad	.LVL46-.Ltext0
 6141      00000000 
 6142 0542 0100     		.value	0x1
 6143 0544 5D       		.byte	0x5d
 6144 0545 85030000 		.quad	.LVL48-.Ltext0
 6144      00000000 
 6145 054d 9C030000 		.quad	.LFE41-.Ltext0
 6145      00000000 
GAS LISTING /tmp/ccK2IhnQ.s 			page 126


 6146 0555 0100     		.value	0x1
 6147 0557 5D       		.byte	0x5d
 6148 0558 00000000 		.quad	0x0
 6148      00000000 
 6149 0560 00000000 		.quad	0x0
 6149      00000000 
 6150              	.LLST26:
 6151 0568 F0020000 		.quad	.LVL36-.Ltext0
 6151      00000000 
 6152 0570 1E030000 		.quad	.LVL37-.Ltext0
 6152      00000000 
 6153 0578 0100     		.value	0x1
 6154 057a 54       		.byte	0x54
 6155 057b 1E030000 		.quad	.LVL37-.Ltext0
 6155      00000000 
 6156 0583 71030000 		.quad	.LVL45-.Ltext0
 6156      00000000 
 6157 058b 0100     		.value	0x1
 6158 058d 5C       		.byte	0x5c
 6159 058e 85030000 		.quad	.LVL48-.Ltext0
 6159      00000000 
 6160 0596 9C030000 		.quad	.LFE41-.Ltext0
 6160      00000000 
 6161 059e 0100     		.value	0x1
 6162 05a0 5C       		.byte	0x5c
 6163 05a1 00000000 		.quad	0x0
 6163      00000000 
 6164 05a9 00000000 		.quad	0x0
 6164      00000000 
 6165              	.LLST27:
 6166 05b1 38030000 		.quad	.LVL39-.Ltext0
 6166      00000000 
 6167 05b9 3C030000 		.quad	.LVL40-1-.Ltext0
 6167      00000000 
 6168 05c1 0100     		.value	0x1
 6169 05c3 50       		.byte	0x50
 6170 05c4 3C030000 		.quad	.LVL40-1-.Ltext0
 6170      00000000 
 6171 05cc 5F030000 		.quad	.LVL43-.Ltext0
 6171      00000000 
 6172 05d4 0100     		.value	0x1
 6173 05d6 53       		.byte	0x53
 6174 05d7 5F030000 		.quad	.LVL43-.Ltext0
 6174      00000000 
 6175 05df 80030000 		.quad	.LVL47-.Ltext0
 6175      00000000 
 6176 05e7 0100     		.value	0x1
 6177 05e9 5F       		.byte	0x5f
 6178 05ea 85030000 		.quad	.LVL48-.Ltext0
 6178      00000000 
 6179 05f2 8D030000 		.quad	.LVL49-.Ltext0
 6179      00000000 
 6180 05fa 0100     		.value	0x1
 6181 05fc 53       		.byte	0x53
 6182 05fd 8D030000 		.quad	.LVL49-.Ltext0
 6182      00000000 
 6183 0605 9C030000 		.quad	.LFE41-.Ltext0
GAS LISTING /tmp/ccK2IhnQ.s 			page 127


 6183      00000000 
 6184 060d 0100     		.value	0x1
 6185 060f 5F       		.byte	0x5f
 6186 0610 00000000 		.quad	0x0
 6186      00000000 
 6187 0618 00000000 		.quad	0x0
 6187      00000000 
 6188              	.LLST28:
 6189 0620 43030000 		.quad	.LVL41-.Ltext0
 6189      00000000 
 6190 0628 57030000 		.quad	.LVL42-1-.Ltext0
 6190      00000000 
 6191 0630 0100     		.value	0x1
 6192 0632 50       		.byte	0x50
 6193 0633 57030000 		.quad	.LVL42-1-.Ltext0
 6193      00000000 
 6194 063b 67030000 		.quad	.LVL44-.Ltext0
 6194      00000000 
 6195 0643 0100     		.value	0x1
 6196 0645 56       		.byte	0x56
 6197 0646 85030000 		.quad	.LVL48-.Ltext0
 6197      00000000 
 6198 064e 91030000 		.quad	.LVL50-1-.Ltext0
 6198      00000000 
 6199 0656 0100     		.value	0x1
 6200 0658 50       		.byte	0x50
 6201 0659 91030000 		.quad	.LVL50-1-.Ltext0
 6201      00000000 
 6202 0661 9C030000 		.quad	.LFE41-.Ltext0
 6202      00000000 
 6203 0669 0100     		.value	0x1
 6204 066b 56       		.byte	0x56
 6205 066c 00000000 		.quad	0x0
 6205      00000000 
 6206 0674 00000000 		.quad	0x0
 6206      00000000 
 6207              	.LLST29:
 6208 067c A0030000 		.quad	.LVL51-.Ltext0
 6208      00000000 
 6209 0684 B7030000 		.quad	.LVL52-.Ltext0
 6209      00000000 
 6210 068c 0100     		.value	0x1
 6211 068e 55       		.byte	0x55
 6212 068f B7030000 		.quad	.LVL52-.Ltext0
 6212      00000000 
 6213 0697 A5040000 		.quad	.LVL67-.Ltext0
 6213      00000000 
 6214 069f 0100     		.value	0x1
 6215 06a1 53       		.byte	0x53
 6216 06a2 A9040000 		.quad	.LVL68-.Ltext0
 6216      00000000 
 6217 06aa D9040000 		.quad	.LFE33-.Ltext0
 6217      00000000 
 6218 06b2 0100     		.value	0x1
 6219 06b4 53       		.byte	0x53
 6220 06b5 00000000 		.quad	0x0
 6220      00000000 
GAS LISTING /tmp/ccK2IhnQ.s 			page 128


 6221 06bd 00000000 		.quad	0x0
 6221      00000000 
 6222              	.LLST30:
 6223 06c5 A0030000 		.quad	.LVL51-.Ltext0
 6223      00000000 
 6224 06cd B7030000 		.quad	.LVL52-.Ltext0
 6224      00000000 
 6225 06d5 0100     		.value	0x1
 6226 06d7 54       		.byte	0x54
 6227 06d8 A9040000 		.quad	.LVL68-.Ltext0
 6227      00000000 
 6228 06e0 C3040000 		.quad	.LVL70-1-.Ltext0
 6228      00000000 
 6229 06e8 0100     		.value	0x1
 6230 06ea 54       		.byte	0x54
 6231 06eb 00000000 		.quad	0x0
 6231      00000000 
 6232 06f3 00000000 		.quad	0x0
 6232      00000000 
 6233              	.LLST31:
 6234 06fb A0030000 		.quad	.LVL51-.Ltext0
 6234      00000000 
 6235 0703 B7030000 		.quad	.LVL52-.Ltext0
 6235      00000000 
 6236 070b 0100     		.value	0x1
 6237 070d 61       		.byte	0x61
 6238 070e A9040000 		.quad	.LVL68-.Ltext0
 6238      00000000 
 6239 0716 C3040000 		.quad	.LVL70-1-.Ltext0
 6239      00000000 
 6240 071e 0100     		.value	0x1
 6241 0720 61       		.byte	0x61
 6242 0721 00000000 		.quad	0x0
 6242      00000000 
 6243 0729 00000000 		.quad	0x0
 6243      00000000 
 6244              	.LLST32:
 6245 0731 A0030000 		.quad	.LVL51-.Ltext0
 6245      00000000 
 6246 0739 B7030000 		.quad	.LVL52-.Ltext0
 6246      00000000 
 6247 0741 0100     		.value	0x1
 6248 0743 51       		.byte	0x51
 6249 0744 B7030000 		.quad	.LVL52-.Ltext0
 6249      00000000 
 6250 074c AC040000 		.quad	.LVL69-.Ltext0
 6250      00000000 
 6251 0754 0100     		.value	0x1
 6252 0756 50       		.byte	0x50
 6253 0757 AC040000 		.quad	.LVL69-.Ltext0
 6253      00000000 
 6254 075f C3040000 		.quad	.LVL70-1-.Ltext0
 6254      00000000 
 6255 0767 0100     		.value	0x1
 6256 0769 51       		.byte	0x51
 6257 076a C4040000 		.quad	.LVL70-.Ltext0
 6257      00000000 
GAS LISTING /tmp/ccK2IhnQ.s 			page 129


 6258 0772 D9040000 		.quad	.LFE33-.Ltext0
 6258      00000000 
 6259 077a 0100     		.value	0x1
 6260 077c 50       		.byte	0x50
 6261 077d 00000000 		.quad	0x0
 6261      00000000 
 6262 0785 00000000 		.quad	0x0
 6262      00000000 
 6263              	.LLST33:
 6264 078d B7030000 		.quad	.LVL52-.Ltext0
 6264      00000000 
 6265 0795 E2030000 		.quad	.LVL53-.Ltext0
 6265      00000000 
 6266 079d 0200     		.value	0x2
 6267 079f 30       		.byte	0x30
 6268 07a0 9F       		.byte	0x9f
 6269 07a1 97040000 		.quad	.LVL65-.Ltext0
 6269      00000000 
 6270 07a9 A0040000 		.quad	.LVL66-.Ltext0
 6270      00000000 
 6271 07b1 0100     		.value	0x1
 6272 07b3 5C       		.byte	0x5c
 6273 07b4 00000000 		.quad	0x0
 6273      00000000 
 6274 07bc 00000000 		.quad	0x0
 6274      00000000 
 6275              	.LLST34:
 6276 07c4 ED030000 		.quad	.LVL54-.Ltext0
 6276      00000000 
 6277 07cc F7030000 		.quad	.LVL55-.Ltext0
 6277      00000000 
 6278 07d4 1200     		.value	0x12
 6279 07d6 7C       		.byte	0x7c
 6280 07d7 00       		.sleb128 0
 6281 07d8 75       		.byte	0x75
 6282 07d9 00       		.sleb128 0
 6283 07da 1E       		.byte	0x1e
 6284 07db 08       		.byte	0x8
 6285 07dc 20       		.byte	0x20
 6286 07dd 24       		.byte	0x24
 6287 07de 08       		.byte	0x8
 6288 07df 20       		.byte	0x20
 6289 07e0 25       		.byte	0x25
 6290 07e1 32       		.byte	0x32
 6291 07e2 24       		.byte	0x24
 6292 07e3 73       		.byte	0x73
 6293 07e4 00       		.sleb128 0
 6294 07e5 06       		.byte	0x6
 6295 07e6 22       		.byte	0x22
 6296 07e7 9F       		.byte	0x9f
 6297 07e8 F7030000 		.quad	.LVL55-.Ltext0
 6297      00000000 
 6298 07f0 FF030000 		.quad	.LVL56-.Ltext0
 6298      00000000 
 6299 07f8 0F00     		.value	0xf
 6300 07fa 75       		.byte	0x75
 6301 07fb 00       		.sleb128 0
GAS LISTING /tmp/ccK2IhnQ.s 			page 130


 6302 07fc 08       		.byte	0x8
 6303 07fd 20       		.byte	0x20
 6304 07fe 24       		.byte	0x24
 6305 07ff 08       		.byte	0x8
 6306 0800 20       		.byte	0x20
 6307 0801 25       		.byte	0x25
 6308 0802 32       		.byte	0x32
 6309 0803 24       		.byte	0x24
 6310 0804 73       		.byte	0x73
 6311 0805 00       		.sleb128 0
 6312 0806 06       		.byte	0x6
 6313 0807 22       		.byte	0x22
 6314 0808 9F       		.byte	0x9f
 6315 0809 FF030000 		.quad	.LVL56-.Ltext0
 6315      00000000 
 6316 0811 0E040000 		.quad	.LVL57-.Ltext0
 6316      00000000 
 6317 0819 0F00     		.value	0xf
 6318 081b 71       		.byte	0x71
 6319 081c 00       		.sleb128 0
 6320 081d 08       		.byte	0x8
 6321 081e 20       		.byte	0x20
 6322 081f 24       		.byte	0x24
 6323 0820 08       		.byte	0x8
 6324 0821 20       		.byte	0x20
 6325 0822 25       		.byte	0x25
 6326 0823 32       		.byte	0x32
 6327 0824 24       		.byte	0x24
 6328 0825 73       		.byte	0x73
 6329 0826 00       		.sleb128 0
 6330 0827 06       		.byte	0x6
 6331 0828 22       		.byte	0x22
 6332 0829 9F       		.byte	0x9f
 6333 082a 00000000 		.quad	0x0
 6333      00000000 
 6334 0832 00000000 		.quad	0x0
 6334      00000000 
 6335              	.LLST35:
 6336 083a ED030000 		.quad	.LVL54-.Ltext0
 6336      00000000 
 6337 0842 F7030000 		.quad	.LVL55-.Ltext0
 6337      00000000 
 6338 084a 1100     		.value	0x11
 6339 084c 7C       		.byte	0x7c
 6340 084d 00       		.sleb128 0
 6341 084e 75       		.byte	0x75
 6342 084f 00       		.sleb128 0
 6343 0850 1E       		.byte	0x1e
 6344 0851 32       		.byte	0x32
 6345 0852 24       		.byte	0x24
 6346 0853 08       		.byte	0x8
 6347 0854 20       		.byte	0x20
 6348 0855 24       		.byte	0x24
 6349 0856 08       		.byte	0x8
 6350 0857 20       		.byte	0x20
 6351 0858 25       		.byte	0x25
 6352 0859 70       		.byte	0x70
GAS LISTING /tmp/ccK2IhnQ.s 			page 131


 6353 085a 00       		.sleb128 0
 6354 085b 22       		.byte	0x22
 6355 085c 9F       		.byte	0x9f
 6356 085d F7030000 		.quad	.LVL55-.Ltext0
 6356      00000000 
 6357 0865 FF030000 		.quad	.LVL56-.Ltext0
 6357      00000000 
 6358 086d 0E00     		.value	0xe
 6359 086f 75       		.byte	0x75
 6360 0870 00       		.sleb128 0
 6361 0871 32       		.byte	0x32
 6362 0872 24       		.byte	0x24
 6363 0873 08       		.byte	0x8
 6364 0874 20       		.byte	0x20
 6365 0875 24       		.byte	0x24
 6366 0876 08       		.byte	0x8
 6367 0877 20       		.byte	0x20
 6368 0878 25       		.byte	0x25
 6369 0879 70       		.byte	0x70
 6370 087a 00       		.sleb128 0
 6371 087b 22       		.byte	0x22
 6372 087c 9F       		.byte	0x9f
 6373 087d FF030000 		.quad	.LVL56-.Ltext0
 6373      00000000 
 6374 0885 0E040000 		.quad	.LVL57-.Ltext0
 6374      00000000 
 6375 088d 0E00     		.value	0xe
 6376 088f 71       		.byte	0x71
 6377 0890 00       		.sleb128 0
 6378 0891 32       		.byte	0x32
 6379 0892 24       		.byte	0x24
 6380 0893 08       		.byte	0x8
 6381 0894 20       		.byte	0x20
 6382 0895 24       		.byte	0x24
 6383 0896 08       		.byte	0x8
 6384 0897 20       		.byte	0x20
 6385 0898 25       		.byte	0x25
 6386 0899 70       		.byte	0x70
 6387 089a 00       		.sleb128 0
 6388 089b 22       		.byte	0x22
 6389 089c 9F       		.byte	0x9f
 6390 089d 00000000 		.quad	0x0
 6390      00000000 
 6391 08a5 00000000 		.quad	0x0
 6391      00000000 
 6392              	.LLST36:
 6393 08ad ED030000 		.quad	.LVL54-.Ltext0
 6393      00000000 
 6394 08b5 0E040000 		.quad	.LVL57-.Ltext0
 6394      00000000 
 6395 08bd 0200     		.value	0x2
 6396 08bf 30       		.byte	0x30
 6397 08c0 9F       		.byte	0x9f
 6398 08c1 29040000 		.quad	.LVL58-.Ltext0
 6398      00000000 
 6399 08c9 31040000 		.quad	.LVL59-.Ltext0
 6399      00000000 
GAS LISTING /tmp/ccK2IhnQ.s 			page 132


 6400 08d1 0100     		.value	0x1
 6401 08d3 58       		.byte	0x58
 6402 08d4 87040000 		.quad	.LVL63-.Ltext0
 6402      00000000 
 6403 08dc 93040000 		.quad	.LVL64-.Ltext0
 6403      00000000 
 6404 08e4 0100     		.value	0x1
 6405 08e6 58       		.byte	0x58
 6406 08e7 00000000 		.quad	0x0
 6406      00000000 
 6407 08ef 00000000 		.quad	0x0
 6407      00000000 
 6408              	.LLST37:
 6409 08f7 10050000 		.quad	.LVL72-.Ltext0
 6409      00000000 
 6410 08ff 1D050000 		.quad	.LVL73-.Ltext0
 6410      00000000 
 6411 0907 0100     		.value	0x1
 6412 0909 54       		.byte	0x54
 6413 090a 1D050000 		.quad	.LVL73-.Ltext0
 6413      00000000 
 6414 0912 22050000 		.quad	.LFE31-.Ltext0
 6414      00000000 
 6415 091a 0100     		.value	0x1
 6416 091c 51       		.byte	0x51
 6417 091d 00000000 		.quad	0x0
 6417      00000000 
 6418 0925 00000000 		.quad	0x0
 6418      00000000 
 6419              	.LLST38:
 6420 092d 40050000 		.quad	.LVL75-.Ltext0
 6420      00000000 
 6421 0935 65050000 		.quad	.LVL76-.Ltext0
 6421      00000000 
 6422 093d 0100     		.value	0x1
 6423 093f 55       		.byte	0x55
 6424 0940 65050000 		.quad	.LVL76-.Ltext0
 6424      00000000 
 6425 0948 85050000 		.quad	.LVL80-.Ltext0
 6425      00000000 
 6426 0950 0100     		.value	0x1
 6427 0952 53       		.byte	0x53
 6428 0953 00000000 		.quad	0x0
 6428      00000000 
 6429 095b 00000000 		.quad	0x0
 6429      00000000 
 6430              	.LLST39:
 6431 0963 40050000 		.quad	.LVL75-.Ltext0
 6431      00000000 
 6432 096b 69050000 		.quad	.LVL77-1-.Ltext0
 6432      00000000 
 6433 0973 0100     		.value	0x1
 6434 0975 54       		.byte	0x54
 6435 0976 69050000 		.quad	.LVL77-1-.Ltext0
 6435      00000000 
 6436 097e 8F050000 		.quad	.LVL82-.Ltext0
 6436      00000000 
GAS LISTING /tmp/ccK2IhnQ.s 			page 133


 6437 0986 0100     		.value	0x1
 6438 0988 5C       		.byte	0x5c
 6439 0989 00000000 		.quad	0x0
 6439      00000000 
 6440 0991 00000000 		.quad	0x0
 6440      00000000 
 6441              	.LLST40:
 6442 0999 40050000 		.quad	.LVL75-.Ltext0
 6442      00000000 
 6443 09a1 69050000 		.quad	.LVL77-1-.Ltext0
 6443      00000000 
 6444 09a9 0100     		.value	0x1
 6445 09ab 51       		.byte	0x51
 6446 09ac 69050000 		.quad	.LVL77-1-.Ltext0
 6446      00000000 
 6447 09b4 94050000 		.quad	.LVL83-.Ltext0
 6447      00000000 
 6448 09bc 0100     		.value	0x1
 6449 09be 5D       		.byte	0x5d
 6450 09bf 00000000 		.quad	0x0
 6450      00000000 
 6451 09c7 00000000 		.quad	0x0
 6451      00000000 
 6452              	.LLST41:
 6453 09cf 70050000 		.quad	.LVL78-.Ltext0
 6453      00000000 
 6454 09d7 7C050000 		.quad	.LVL79-1-.Ltext0
 6454      00000000 
 6455 09df 0100     		.value	0x1
 6456 09e1 50       		.byte	0x50
 6457 09e2 7C050000 		.quad	.LVL79-1-.Ltext0
 6457      00000000 
 6458 09ea 8A050000 		.quad	.LVL81-.Ltext0
 6458      00000000 
 6459 09f2 0100     		.value	0x1
 6460 09f4 56       		.byte	0x56
 6461 09f5 8A050000 		.quad	.LVL81-.Ltext0
 6461      00000000 
 6462 09fd 99050000 		.quad	.LFE35-.Ltext0
 6462      00000000 
 6463 0a05 0100     		.value	0x1
 6464 0a07 50       		.byte	0x50
 6465 0a08 00000000 		.quad	0x0
 6465      00000000 
 6466 0a10 00000000 		.quad	0x0
 6466      00000000 
 6467              	.LLST42:
 6468 0a18 A0050000 		.quad	.LVL84-.Ltext0
 6468      00000000 
 6469 0a20 BA050000 		.quad	.LVL87-.Ltext0
 6469      00000000 
 6470 0a28 0100     		.value	0x1
 6471 0a2a 55       		.byte	0x55
 6472 0a2b BA050000 		.quad	.LVL87-.Ltext0
 6472      00000000 
 6473 0a33 8D060000 		.quad	.LVL102-.Ltext0
 6473      00000000 
GAS LISTING /tmp/ccK2IhnQ.s 			page 134


 6474 0a3b 0100     		.value	0x1
 6475 0a3d 56       		.byte	0x56
 6476 0a3e 9A060000 		.quad	.LVL104-.Ltext0
 6476      00000000 
 6477 0a46 A0060000 		.quad	.LVL106-.Ltext0
 6477      00000000 
 6478 0a4e 0100     		.value	0x1
 6479 0a50 56       		.byte	0x56
 6480 0a51 00000000 		.quad	0x0
 6480      00000000 
 6481 0a59 00000000 		.quad	0x0
 6481      00000000 
 6482              	.LLST43:
 6483 0a61 A0050000 		.quad	.LVL84-.Ltext0
 6483      00000000 
 6484 0a69 B0050000 		.quad	.LVL85-.Ltext0
 6484      00000000 
 6485 0a71 0100     		.value	0x1
 6486 0a73 54       		.byte	0x54
 6487 0a74 B0050000 		.quad	.LVL85-.Ltext0
 6487      00000000 
 6488 0a7c 8F060000 		.quad	.LVL103-.Ltext0
 6488      00000000 
 6489 0a84 0100     		.value	0x1
 6490 0a86 5C       		.byte	0x5c
 6491 0a87 9A060000 		.quad	.LVL104-.Ltext0
 6491      00000000 
 6492 0a8f A2060000 		.quad	.LVL107-.Ltext0
 6492      00000000 
 6493 0a97 0100     		.value	0x1
 6494 0a99 5C       		.byte	0x5c
 6495 0a9a 00000000 		.quad	0x0
 6495      00000000 
 6496 0aa2 00000000 		.quad	0x0
 6496      00000000 
 6497              	.LLST44:
 6498 0aaa D4050000 		.quad	.LVL89-.Ltext0
 6498      00000000 
 6499 0ab2 FA050000 		.quad	.LVL91-.Ltext0
 6499      00000000 
 6500 0aba 0200     		.value	0x2
 6501 0abc 30       		.byte	0x30
 6502 0abd 9F       		.byte	0x9f
 6503 0abe 74060000 		.quad	.LVL99-.Ltext0
 6503      00000000 
 6504 0ac6 7E060000 		.quad	.LVL100-.Ltext0
 6504      00000000 
 6505 0ace 0300     		.value	0x3
 6506 0ad0 91       		.byte	0x91
 6507 0ad1 B07F     		.sleb128 -80
 6508 0ad3 00000000 		.quad	0x0
 6508      00000000 
 6509 0adb 00000000 		.quad	0x0
 6509      00000000 
 6510              	.LLST45:
 6511 0ae3 B8050000 		.quad	.LVL86-.Ltext0
 6511      00000000 
GAS LISTING /tmp/ccK2IhnQ.s 			page 135


 6512 0aeb 8C060000 		.quad	.LVL101-.Ltext0
 6512      00000000 
 6513 0af3 0100     		.value	0x1
 6514 0af5 53       		.byte	0x53
 6515 0af6 8C060000 		.quad	.LVL101-.Ltext0
 6515      00000000 
 6516 0afe 99060000 		.quad	.LVL104-1-.Ltext0
 6516      00000000 
 6517 0b06 0100     		.value	0x1
 6518 0b08 54       		.byte	0x54
 6519 0b09 9A060000 		.quad	.LVL104-.Ltext0
 6519      00000000 
 6520 0b11 9F060000 		.quad	.LVL105-.Ltext0
 6520      00000000 
 6521 0b19 0100     		.value	0x1
 6522 0b1b 53       		.byte	0x53
 6523 0b1c 00000000 		.quad	0x0
 6523      00000000 
 6524 0b24 00000000 		.quad	0x0
 6524      00000000 
 6525              	.LLST46:
 6526 0b2c CE050000 		.quad	.LVL88-.Ltext0
 6526      00000000 
 6527 0b34 DF050000 		.quad	.LVL90-.Ltext0
 6527      00000000 
 6528 0b3c 0100     		.value	0x1
 6529 0b3e 50       		.byte	0x50
 6530 0b3f DF050000 		.quad	.LVL90-.Ltext0
 6530      00000000 
 6531 0b47 A9060000 		.quad	.LFE39-.Ltext0
 6531      00000000 
 6532 0b4f 0300     		.value	0x3
 6533 0b51 91       		.byte	0x91
 6534 0b52 B87F     		.sleb128 -72
 6535 0b54 00000000 		.quad	0x0
 6535      00000000 
 6536 0b5c 00000000 		.quad	0x0
 6536      00000000 
 6537              	.LLST47:
 6538 0b64 18060000 		.quad	.LVL92-.Ltext0
 6538      00000000 
 6539 0b6c 1E060000 		.quad	.LVL93-.Ltext0
 6539      00000000 
 6540 0b74 0100     		.value	0x1
 6541 0b76 5E       		.byte	0x5e
 6542 0b77 1E060000 		.quad	.LVL93-.Ltext0
 6542      00000000 
 6543 0b7f 24060000 		.quad	.LVL94-.Ltext0
 6543      00000000 
 6544 0b87 0300     		.value	0x3
 6545 0b89 7E       		.byte	0x7e
 6546 0b8a 04       		.sleb128 4
 6547 0b8b 9F       		.byte	0x9f
 6548 0b8c 61060000 		.quad	.LVL98-.Ltext0
 6548      00000000 
 6549 0b94 7E060000 		.quad	.LVL100-.Ltext0
 6549      00000000 
GAS LISTING /tmp/ccK2IhnQ.s 			page 136


 6550 0b9c 0300     		.value	0x3
 6551 0b9e 7E       		.byte	0x7e
 6552 0b9f 04       		.sleb128 4
 6553 0ba0 9F       		.byte	0x9f
 6554 0ba1 00000000 		.quad	0x0
 6554      00000000 
 6555 0ba9 00000000 		.quad	0x0
 6555      00000000 
 6556              	.LLST48:
 6557 0bb1 18060000 		.quad	.LVL92-.Ltext0
 6557      00000000 
 6558 0bb9 1E060000 		.quad	.LVL93-.Ltext0
 6558      00000000 
 6559 0bc1 0200     		.value	0x2
 6560 0bc3 30       		.byte	0x30
 6561 0bc4 9F       		.byte	0x9f
 6562 0bc5 1E060000 		.quad	.LVL93-.Ltext0
 6562      00000000 
 6563 0bcd 24060000 		.quad	.LVL94-.Ltext0
 6563      00000000 
 6564 0bd5 0100     		.value	0x1
 6565 0bd7 5D       		.byte	0x5d
 6566 0bd8 61060000 		.quad	.LVL98-.Ltext0
 6566      00000000 
 6567 0be0 7E060000 		.quad	.LVL100-.Ltext0
 6567      00000000 
 6568 0be8 0100     		.value	0x1
 6569 0bea 5D       		.byte	0x5d
 6570 0beb 00000000 		.quad	0x0
 6570      00000000 
 6571 0bf3 00000000 		.quad	0x0
 6571      00000000 
 6572              	.LLST49:
 6573 0bfb 41060000 		.quad	.LVL95-.Ltext0
 6573      00000000 
 6574 0c03 5D060000 		.quad	.LVL97-.Ltext0
 6574      00000000 
 6575 0c0b 0100     		.value	0x1
 6576 0c0d 61       		.byte	0x61
 6577 0c0e 00000000 		.quad	0x0
 6577      00000000 
 6578 0c16 00000000 		.quad	0x0
 6578      00000000 
 6579              	.LLST50:
 6580 0c1e 1E060000 		.quad	.LVL93-.Ltext0
 6580      00000000 
 6581 0c26 24060000 		.quad	.LVL94-.Ltext0
 6581      00000000 
 6582 0c2e 0100     		.value	0x1
 6583 0c30 62       		.byte	0x62
 6584 0c31 55060000 		.quad	.LVL96-.Ltext0
 6584      00000000 
 6585 0c39 7E060000 		.quad	.LVL100-.Ltext0
 6585      00000000 
 6586 0c41 0100     		.value	0x1
 6587 0c43 62       		.byte	0x62
 6588 0c44 00000000 		.quad	0x0
GAS LISTING /tmp/ccK2IhnQ.s 			page 137


 6588      00000000 
 6589 0c4c 00000000 		.quad	0x0
 6589      00000000 
 6590              	.LLST51:
 6591 0c54 C0060000 		.quad	.LVL109-.Ltext0
 6591      00000000 
 6592 0c5c F4060000 		.quad	.LVL110-.Ltext0
 6592      00000000 
 6593 0c64 0100     		.value	0x1
 6594 0c66 55       		.byte	0x55
 6595 0c67 F4060000 		.quad	.LVL110-.Ltext0
 6595      00000000 
 6596 0c6f 1A070000 		.quad	.LVL115-.Ltext0
 6596      00000000 
 6597 0c77 0100     		.value	0x1
 6598 0c79 53       		.byte	0x53
 6599 0c7a 1A070000 		.quad	.LVL115-.Ltext0
 6599      00000000 
 6600 0c82 32070000 		.quad	.LFE36-.Ltext0
 6600      00000000 
 6601 0c8a 0100     		.value	0x1
 6602 0c8c 55       		.byte	0x55
 6603 0c8d 00000000 		.quad	0x0
 6603      00000000 
 6604 0c95 00000000 		.quad	0x0
 6604      00000000 
 6605              	.LLST52:
 6606 0c9d C0060000 		.quad	.LVL109-.Ltext0
 6606      00000000 
 6607 0ca5 F8060000 		.quad	.LVL111-1-.Ltext0
 6607      00000000 
 6608 0cad 0100     		.value	0x1
 6609 0caf 54       		.byte	0x54
 6610 0cb0 F8060000 		.quad	.LVL111-1-.Ltext0
 6610      00000000 
 6611 0cb8 16070000 		.quad	.LVL114-.Ltext0
 6611      00000000 
 6612 0cc0 0100     		.value	0x1
 6613 0cc2 56       		.byte	0x56
 6614 0cc3 16070000 		.quad	.LVL114-.Ltext0
 6614      00000000 
 6615 0ccb 32070000 		.quad	.LFE36-.Ltext0
 6615      00000000 
 6616 0cd3 0100     		.value	0x1
 6617 0cd5 54       		.byte	0x54
 6618 0cd6 00000000 		.quad	0x0
 6618      00000000 
 6619 0cde 00000000 		.quad	0x0
 6619      00000000 
 6620              	.LLST53:
 6621 0ce6 C0060000 		.quad	.LVL109-.Ltext0
 6621      00000000 
 6622 0cee F8060000 		.quad	.LVL111-1-.Ltext0
 6622      00000000 
 6623 0cf6 0100     		.value	0x1
 6624 0cf8 51       		.byte	0x51
 6625 0cf9 F8060000 		.quad	.LVL111-1-.Ltext0
GAS LISTING /tmp/ccK2IhnQ.s 			page 138


 6625      00000000 
 6626 0d01 24070000 		.quad	.LVL117-.Ltext0
 6626      00000000 
 6627 0d09 0100     		.value	0x1
 6628 0d0b 5D       		.byte	0x5d
 6629 0d0c 00000000 		.quad	0x0
 6629      00000000 
 6630 0d14 00000000 		.quad	0x0
 6630      00000000 
 6631              	.LLST54:
 6632 0d1c FF060000 		.quad	.LVL112-.Ltext0
 6632      00000000 
 6633 0d24 09070000 		.quad	.LVL113-1-.Ltext0
 6633      00000000 
 6634 0d2c 0100     		.value	0x1
 6635 0d2e 50       		.byte	0x50
 6636 0d2f 09070000 		.quad	.LVL113-1-.Ltext0
 6636      00000000 
 6637 0d37 1F070000 		.quad	.LVL116-.Ltext0
 6637      00000000 
 6638 0d3f 0100     		.value	0x1
 6639 0d41 5C       		.byte	0x5c
 6640 0d42 1F070000 		.quad	.LVL116-.Ltext0
 6640      00000000 
 6641 0d4a 32070000 		.quad	.LFE36-.Ltext0
 6641      00000000 
 6642 0d52 0100     		.value	0x1
 6643 0d54 51       		.byte	0x51
 6644 0d55 00000000 		.quad	0x0
 6644      00000000 
 6645 0d5d 00000000 		.quad	0x0
 6645      00000000 
 6646              	.LLST55:
 6647 0d65 40070000 		.quad	.LVL118-.Ltext0
 6647      00000000 
 6648 0d6d 6F070000 		.quad	.LVL119-.Ltext0
 6648      00000000 
 6649 0d75 0100     		.value	0x1
 6650 0d77 55       		.byte	0x55
 6651 0d78 6F070000 		.quad	.LVL119-.Ltext0
 6651      00000000 
 6652 0d80 94070000 		.quad	.LVL123-.Ltext0
 6652      00000000 
 6653 0d88 0100     		.value	0x1
 6654 0d8a 53       		.byte	0x53
 6655 0d8b 00000000 		.quad	0x0
 6655      00000000 
 6656 0d93 00000000 		.quad	0x0
 6656      00000000 
 6657              	.LLST56:
 6658 0d9b 40070000 		.quad	.LVL118-.Ltext0
 6658      00000000 
 6659 0da3 7C070000 		.quad	.LVL120-.Ltext0
 6659      00000000 
 6660 0dab 0100     		.value	0x1
 6661 0dad 54       		.byte	0x54
 6662 0dae 7C070000 		.quad	.LVL120-.Ltext0
GAS LISTING /tmp/ccK2IhnQ.s 			page 139


 6662      00000000 
 6663 0db6 90070000 		.quad	.LVL122-.Ltext0
 6663      00000000 
 6664 0dbe 0100     		.value	0x1
 6665 0dc0 56       		.byte	0x56
 6666 0dc1 90070000 		.quad	.LVL122-.Ltext0
 6666      00000000 
 6667 0dc9 94070000 		.quad	.LVL123-.Ltext0
 6667      00000000 
 6668 0dd1 0200     		.value	0x2
 6669 0dd3 73       		.byte	0x73
 6670 0dd4 0C       		.sleb128 12
 6671 0dd5 00000000 		.quad	0x0
 6671      00000000 
 6672 0ddd 00000000 		.quad	0x0
 6672      00000000 
 6673              	.LLST57:
 6674 0de5 40070000 		.quad	.LVL118-.Ltext0
 6674      00000000 
 6675 0ded 80070000 		.quad	.LVL121-1-.Ltext0
 6675      00000000 
 6676 0df5 0100     		.value	0x1
 6677 0df7 51       		.byte	0x51
 6678 0df8 80070000 		.quad	.LVL121-1-.Ltext0
 6678      00000000 
 6679 0e00 99070000 		.quad	.LVL124-.Ltext0
 6679      00000000 
 6680 0e08 0100     		.value	0x1
 6681 0e0a 5C       		.byte	0x5c
 6682 0e0b 00000000 		.quad	0x0
 6682      00000000 
 6683 0e13 00000000 		.quad	0x0
 6683      00000000 
 6684              	.LLST58:
 6685 0e1b A0070000 		.quad	.LVL125-.Ltext0
 6685      00000000 
 6686 0e23 B6070000 		.quad	.LVL126-.Ltext0
 6686      00000000 
 6687 0e2b 0100     		.value	0x1
 6688 0e2d 55       		.byte	0x55
 6689 0e2e B6070000 		.quad	.LVL126-.Ltext0
 6689      00000000 
 6690 0e36 D9070000 		.quad	.LVL130-.Ltext0
 6690      00000000 
 6691 0e3e 0100     		.value	0x1
 6692 0e40 53       		.byte	0x53
 6693 0e41 00000000 		.quad	0x0
 6693      00000000 
 6694 0e49 00000000 		.quad	0x0
 6694      00000000 
 6695              	.LLST59:
 6696 0e51 A0070000 		.quad	.LVL125-.Ltext0
 6696      00000000 
 6697 0e59 C1070000 		.quad	.LVL127-1-.Ltext0
 6697      00000000 
 6698 0e61 0100     		.value	0x1
 6699 0e63 54       		.byte	0x54
GAS LISTING /tmp/ccK2IhnQ.s 			page 140


 6700 0e64 C1070000 		.quad	.LVL127-1-.Ltext0
 6700      00000000 
 6701 0e6c E3070000 		.quad	.LVL132-.Ltext0
 6701      00000000 
 6702 0e74 0100     		.value	0x1
 6703 0e76 5C       		.byte	0x5c
 6704 0e77 00000000 		.quad	0x0
 6704      00000000 
 6705 0e7f 00000000 		.quad	0x0
 6705      00000000 
 6706              	.LLST60:
 6707 0e87 C8070000 		.quad	.LVL128-.Ltext0
 6707      00000000 
 6708 0e8f D1070000 		.quad	.LVL129-1-.Ltext0
 6708      00000000 
 6709 0e97 0100     		.value	0x1
 6710 0e99 50       		.byte	0x50
 6711 0e9a D1070000 		.quad	.LVL129-1-.Ltext0
 6711      00000000 
 6712 0ea2 DE070000 		.quad	.LVL131-.Ltext0
 6712      00000000 
 6713 0eaa 0100     		.value	0x1
 6714 0eac 56       		.byte	0x56
 6715 0ead DE070000 		.quad	.LVL131-.Ltext0
 6715      00000000 
 6716 0eb5 E8070000 		.quad	.LFE23-.Ltext0
 6716      00000000 
 6717 0ebd 0100     		.value	0x1
 6718 0ebf 50       		.byte	0x50
 6719 0ec0 00000000 		.quad	0x0
 6719      00000000 
 6720 0ec8 00000000 		.quad	0x0
 6720      00000000 
 6721              	.LLST61:
 6722 0ed0 F0070000 		.quad	.LVL133-.Ltext0
 6722      00000000 
 6723 0ed8 04080000 		.quad	.LVL135-1-.Ltext0
 6723      00000000 
 6724 0ee0 0100     		.value	0x1
 6725 0ee2 55       		.byte	0x55
 6726 0ee3 04080000 		.quad	.LVL135-1-.Ltext0
 6726      00000000 
 6727 0eeb 8B080000 		.quad	.LVL143-.Ltext0
 6727      00000000 
 6728 0ef3 0100     		.value	0x1
 6729 0ef5 53       		.byte	0x53
 6730 0ef6 00000000 		.quad	0x0
 6730      00000000 
 6731 0efe 00000000 		.quad	0x0
 6731      00000000 
 6732              	.LLST62:
 6733 0f06 F0070000 		.quad	.LVL133-.Ltext0
 6733      00000000 
 6734 0f0e 04080000 		.quad	.LVL135-1-.Ltext0
 6734      00000000 
 6735 0f16 0500     		.value	0x5
 6736 0f18 75       		.byte	0x75
GAS LISTING /tmp/ccK2IhnQ.s 			page 141


 6737 0f19 00       		.sleb128 0
 6738 0f1a 23       		.byte	0x23
 6739 0f1b 18       		.uleb128 0x18
 6740 0f1c 06       		.byte	0x6
 6741 0f1d 04080000 		.quad	.LVL135-1-.Ltext0
 6741      00000000 
 6742 0f25 8B080000 		.quad	.LVL143-.Ltext0
 6742      00000000 
 6743 0f2d 0500     		.value	0x5
 6744 0f2f 73       		.byte	0x73
 6745 0f30 00       		.sleb128 0
 6746 0f31 23       		.byte	0x23
 6747 0f32 18       		.uleb128 0x18
 6748 0f33 06       		.byte	0x6
 6749 0f34 00000000 		.quad	0x0
 6749      00000000 
 6750 0f3c 00000000 		.quad	0x0
 6750      00000000 
 6751              	.LLST63:
 6752 0f44 00080000 		.quad	.LVL134-.Ltext0
 6752      00000000 
 6753 0f4c 04080000 		.quad	.LVL135-1-.Ltext0
 6753      00000000 
 6754 0f54 0200     		.value	0x2
 6755 0f56 75       		.byte	0x75
 6756 0f57 24       		.sleb128 36
 6757 0f58 04080000 		.quad	.LVL135-1-.Ltext0
 6757      00000000 
 6758 0f60 1C080000 		.quad	.LVL138-.Ltext0
 6758      00000000 
 6759 0f68 0100     		.value	0x1
 6760 0f6a 56       		.byte	0x56
 6761 0f6b 00000000 		.quad	0x0
 6761      00000000 
 6762 0f73 00000000 		.quad	0x0
 6762      00000000 
 6763              	.LLST64:
 6764 0f7b F0070000 		.quad	.LVL133-.Ltext0
 6764      00000000 
 6765 0f83 04080000 		.quad	.LVL135-1-.Ltext0
 6765      00000000 
 6766 0f8b 0400     		.value	0x4
 6767 0f8d 75       		.byte	0x75
 6768 0f8e 00       		.sleb128 0
 6769 0f8f 23       		.byte	0x23
 6770 0f90 20       		.uleb128 0x20
 6771 0f91 04080000 		.quad	.LVL135-1-.Ltext0
 6771      00000000 
 6772 0f99 8B080000 		.quad	.LVL143-.Ltext0
 6772      00000000 
 6773 0fa1 0400     		.value	0x4
 6774 0fa3 73       		.byte	0x73
 6775 0fa4 00       		.sleb128 0
 6776 0fa5 23       		.byte	0x23
 6777 0fa6 20       		.uleb128 0x20
 6778 0fa7 00000000 		.quad	0x0
 6778      00000000 
GAS LISTING /tmp/ccK2IhnQ.s 			page 142


 6779 0faf 00000000 		.quad	0x0
 6779      00000000 
 6780              	.LLST65:
 6781 0fb7 F0070000 		.quad	.LVL133-.Ltext0
 6781      00000000 
 6782 0fbf 04080000 		.quad	.LVL135-1-.Ltext0
 6782      00000000 
 6783 0fc7 0400     		.value	0x4
 6784 0fc9 75       		.byte	0x75
 6785 0fca 00       		.sleb128 0
 6786 0fcb 23       		.byte	0x23
 6787 0fcc 10       		.uleb128 0x10
 6788 0fcd 04080000 		.quad	.LVL135-1-.Ltext0
 6788      00000000 
 6789 0fd5 8B080000 		.quad	.LVL143-.Ltext0
 6789      00000000 
 6790 0fdd 0400     		.value	0x4
 6791 0fdf 73       		.byte	0x73
 6792 0fe0 00       		.sleb128 0
 6793 0fe1 23       		.byte	0x23
 6794 0fe2 10       		.uleb128 0x10
 6795 0fe3 00000000 		.quad	0x0
 6795      00000000 
 6796 0feb 00000000 		.quad	0x0
 6796      00000000 
 6797              	.LLST66:
 6798 0ff3 F0070000 		.quad	.LVL133-.Ltext0
 6798      00000000 
 6799 0ffb 04080000 		.quad	.LVL135-1-.Ltext0
 6799      00000000 
 6800 1003 0400     		.value	0x4
 6801 1005 75       		.byte	0x75
 6802 1006 00       		.sleb128 0
 6803 1007 23       		.byte	0x23
 6804 1008 08       		.uleb128 0x8
 6805 1009 04080000 		.quad	.LVL135-1-.Ltext0
 6805      00000000 
 6806 1011 8B080000 		.quad	.LVL143-.Ltext0
 6806      00000000 
 6807 1019 0400     		.value	0x4
 6808 101b 73       		.byte	0x73
 6809 101c 00       		.sleb128 0
 6810 101d 23       		.byte	0x23
 6811 101e 08       		.uleb128 0x8
 6812 101f 00000000 		.quad	0x0
 6812      00000000 
 6813 1027 00000000 		.quad	0x0
 6813      00000000 
 6814              	.LLST67:
 6815 102f F0070000 		.quad	.LVL133-.Ltext0
 6815      00000000 
 6816 1037 04080000 		.quad	.LVL135-1-.Ltext0
 6816      00000000 
 6817 103f 0200     		.value	0x2
 6818 1041 75       		.byte	0x75
 6819 1042 00       		.sleb128 0
 6820 1043 04080000 		.quad	.LVL135-1-.Ltext0
GAS LISTING /tmp/ccK2IhnQ.s 			page 143


 6820      00000000 
 6821 104b 8B080000 		.quad	.LVL143-.Ltext0
 6821      00000000 
 6822 1053 0200     		.value	0x2
 6823 1055 73       		.byte	0x73
 6824 1056 00       		.sleb128 0
 6825 1057 00000000 		.quad	0x0
 6825      00000000 
 6826 105f 00000000 		.quad	0x0
 6826      00000000 
 6827              	.LLST68:
 6828 1067 05080000 		.quad	.LVL135-.Ltext0
 6828      00000000 
 6829 106f 0D080000 		.quad	.LVL136-.Ltext0
 6829      00000000 
 6830 1077 0100     		.value	0x1
 6831 1079 50       		.byte	0x50
 6832 107a 0D080000 		.quad	.LVL136-.Ltext0
 6832      00000000 
 6833 1082 11080000 		.quad	.LVL137-.Ltext0
 6833      00000000 
 6834 108a 0100     		.value	0x1
 6835 108c 5C       		.byte	0x5c
 6836 108d 11080000 		.quad	.LVL137-.Ltext0
 6836      00000000 
 6837 1095 36080000 		.quad	.LVL140-1-.Ltext0
 6837      00000000 
 6838 109d 0100     		.value	0x1
 6839 109f 50       		.byte	0x50
 6840 10a0 00000000 		.quad	0x0
 6840      00000000 
 6841 10a8 00000000 		.quad	0x0
 6841      00000000 
 6842              	.LLST69:
 6843 10b0 11080000 		.quad	.LVL137-.Ltext0
 6843      00000000 
 6844 10b8 5B080000 		.quad	.LVL141-.Ltext0
 6844      00000000 
 6845 10c0 0100     		.value	0x1
 6846 10c2 5C       		.byte	0x5c
 6847 10c3 00000000 		.quad	0x0
 6847      00000000 
 6848 10cb 00000000 		.quad	0x0
 6848      00000000 
 6849              	.LLST70:
 6850 10d3 24080000 		.quad	.LVL139-.Ltext0
 6850      00000000 
 6851 10db 8C080000 		.quad	.LVL144-.Ltext0
 6851      00000000 
 6852 10e3 0100     		.value	0x1
 6853 10e5 56       		.byte	0x56
 6854 10e6 00000000 		.quad	0x0
 6854      00000000 
 6855 10ee 00000000 		.quad	0x0
 6855      00000000 
 6856              	.LLST71:
 6857 10f6 37080000 		.quad	.LVL140-.Ltext0
GAS LISTING /tmp/ccK2IhnQ.s 			page 144


 6857      00000000 
 6858 10fe 8E080000 		.quad	.LVL145-.Ltext0
 6858      00000000 
 6859 1106 0100     		.value	0x1
 6860 1108 5C       		.byte	0x5c
 6861 1109 00000000 		.quad	0x0
 6861      00000000 
 6862 1111 00000000 		.quad	0x0
 6862      00000000 
 6863              	.LLST72:
 6864 1119 A0080000 		.quad	.LVL146-.Ltext0
 6864      00000000 
 6865 1121 BC080000 		.quad	.LVL148-.Ltext0
 6865      00000000 
 6866 1129 0100     		.value	0x1
 6867 112b 55       		.byte	0x55
 6868 112c BC080000 		.quad	.LVL148-.Ltext0
 6868      00000000 
 6869 1134 DC080000 		.quad	.LVL150-.Ltext0
 6869      00000000 
 6870 113c 0100     		.value	0x1
 6871 113e 53       		.byte	0x53
 6872 113f DC080000 		.quad	.LVL150-.Ltext0
 6872      00000000 
 6873 1147 1B090000 		.quad	.LVL151-1-.Ltext0
 6873      00000000 
 6874 114f 0200     		.value	0x2
 6875 1151 73       		.byte	0x73
 6876 1152 00       		.sleb128 0
 6877 1153 31090000 		.quad	.LVL152-.Ltext0
 6877      00000000 
 6878 115b 4B090000 		.quad	.LVL154-.Ltext0
 6878      00000000 
 6879 1163 0200     		.value	0x2
 6880 1165 73       		.byte	0x73
 6881 1166 00       		.sleb128 0
 6882 1167 4B090000 		.quad	.LVL154-.Ltext0
 6882      00000000 
 6883 116f 180A0000 		.quad	.LVL172-.Ltext0
 6883      00000000 
 6884 1177 0100     		.value	0x1
 6885 1179 5C       		.byte	0x5c
 6886 117a 00000000 		.quad	0x0
 6886      00000000 
 6887 1182 00000000 		.quad	0x0
 6887      00000000 
 6888              	.LLST73:
 6889 118a A0080000 		.quad	.LVL146-.Ltext0
 6889      00000000 
 6890 1192 C7080000 		.quad	.LVL149-1-.Ltext0
 6890      00000000 
 6891 119a 0100     		.value	0x1
 6892 119c 54       		.byte	0x54
 6893 119d C7080000 		.quad	.LVL149-1-.Ltext0
 6893      00000000 
 6894 11a5 31090000 		.quad	.LVL152-.Ltext0
 6894      00000000 
GAS LISTING /tmp/ccK2IhnQ.s 			page 145


 6895 11ad 0100     		.value	0x1
 6896 11af 56       		.byte	0x56
 6897 11b0 31090000 		.quad	.LVL152-.Ltext0
 6897      00000000 
 6898 11b8 4B090000 		.quad	.LVL154-.Ltext0
 6898      00000000 
 6899 11c0 0300     		.value	0x3
 6900 11c2 91       		.byte	0x91
 6901 11c3 A87F     		.sleb128 -88
 6902 11c5 00000000 		.quad	0x0
 6902      00000000 
 6903 11cd 00000000 		.quad	0x0
 6903      00000000 
 6904              	.LLST74:
 6905 11d5 A0080000 		.quad	.LVL146-.Ltext0
 6905      00000000 
 6906 11dd C7080000 		.quad	.LVL149-1-.Ltext0
 6906      00000000 
 6907 11e5 0100     		.value	0x1
 6908 11e7 51       		.byte	0x51
 6909 11e8 C7080000 		.quad	.LVL149-1-.Ltext0
 6909      00000000 
 6910 11f0 31090000 		.quad	.LVL152-.Ltext0
 6910      00000000 
 6911 11f8 0100     		.value	0x1
 6912 11fa 5C       		.byte	0x5c
 6913 11fb 31090000 		.quad	.LVL152-.Ltext0
 6913      00000000 
 6914 1203 4B090000 		.quad	.LVL154-.Ltext0
 6914      00000000 
 6915 120b 0300     		.value	0x3
 6916 120d 91       		.byte	0x91
 6917 120e B07F     		.sleb128 -80
 6918 1210 00000000 		.quad	0x0
 6918      00000000 
 6919 1218 00000000 		.quad	0x0
 6919      00000000 
 6920              	.LLST75:
 6921 1220 A0080000 		.quad	.LVL146-.Ltext0
 6921      00000000 
 6922 1228 C7080000 		.quad	.LVL149-1-.Ltext0
 6922      00000000 
 6923 1230 0100     		.value	0x1
 6924 1232 52       		.byte	0x52
 6925 1233 C7080000 		.quad	.LVL149-1-.Ltext0
 6925      00000000 
 6926 123b 31090000 		.quad	.LVL152-.Ltext0
 6926      00000000 
 6927 1243 0100     		.value	0x1
 6928 1245 5D       		.byte	0x5d
 6929 1246 31090000 		.quad	.LVL152-.Ltext0
 6929      00000000 
 6930 124e 4B090000 		.quad	.LVL154-.Ltext0
 6930      00000000 
 6931 1256 0200     		.value	0x2
 6932 1258 91       		.byte	0x91
 6933 1259 40       		.sleb128 -64
GAS LISTING /tmp/ccK2IhnQ.s 			page 146


 6934 125a 00000000 		.quad	0x0
 6934      00000000 
 6935 1262 00000000 		.quad	0x0
 6935      00000000 
 6936              	.LLST76:
 6937 126a A0080000 		.quad	.LVL146-.Ltext0
 6937      00000000 
 6938 1272 C7080000 		.quad	.LVL149-1-.Ltext0
 6938      00000000 
 6939 127a 0100     		.value	0x1
 6940 127c 58       		.byte	0x58
 6941 127d C7080000 		.quad	.LVL149-1-.Ltext0
 6941      00000000 
 6942 1285 1C0A0000 		.quad	.LVL173-.Ltext0
 6942      00000000 
 6943 128d 0100     		.value	0x1
 6944 128f 5E       		.byte	0x5e
 6945 1290 00000000 		.quad	0x0
 6945      00000000 
 6946 1298 00000000 		.quad	0x0
 6946      00000000 
 6947              	.LLST77:
 6948 12a0 AA080000 		.quad	.LVL147-.Ltext0
 6948      00000000 
 6949 12a8 C7080000 		.quad	.LVL149-1-.Ltext0
 6949      00000000 
 6950 12b0 0500     		.value	0x5
 6951 12b2 72       		.byte	0x72
 6952 12b3 07       		.sleb128 7
 6953 12b4 33       		.byte	0x33
 6954 12b5 25       		.byte	0x25
 6955 12b6 9F       		.byte	0x9f
 6956 12b7 C7080000 		.quad	.LVL149-1-.Ltext0
 6956      00000000 
 6957 12bf 49090000 		.quad	.LVL153-.Ltext0
 6957      00000000 
 6958 12c7 0500     		.value	0x5
 6959 12c9 7D       		.byte	0x7d
 6960 12ca 07       		.sleb128 7
 6961 12cb 33       		.byte	0x33
 6962 12cc 25       		.byte	0x25
 6963 12cd 9F       		.byte	0x9f
 6964 12ce 00000000 		.quad	0x0
 6964      00000000 
 6965 12d6 00000000 		.quad	0x0
 6965      00000000 
 6966              	.LLST78:
 6967 12de 4B090000 		.quad	.LVL154-.Ltext0
 6967      00000000 
 6968 12e6 5B090000 		.quad	.LVL155-.Ltext0
 6968      00000000 
 6969 12ee 0200     		.value	0x2
 6970 12f0 30       		.byte	0x30
 6971 12f1 9F       		.byte	0x9f
 6972 12f2 63090000 		.quad	.LVL156-.Ltext0
 6972      00000000 
 6973 12fa 6E090000 		.quad	.LVL158-.Ltext0
GAS LISTING /tmp/ccK2IhnQ.s 			page 147


 6973      00000000 
 6974 1302 0100     		.value	0x1
 6975 1304 53       		.byte	0x53
 6976 1305 E6090000 		.quad	.LVL167-.Ltext0
 6976      00000000 
 6977 130d 000A0000 		.quad	.LVL169-.Ltext0
 6977      00000000 
 6978 1315 0100     		.value	0x1
 6979 1317 53       		.byte	0x53
 6980 1318 00000000 		.quad	0x0
 6980      00000000 
 6981 1320 00000000 		.quad	0x0
 6981      00000000 
 6982              	.LLST79:
 6983 1328 31090000 		.quad	.LVL152-.Ltext0
 6983      00000000 
 6984 1330 4B090000 		.quad	.LVL154-.Ltext0
 6984      00000000 
 6985 1338 0200     		.value	0x2
 6986 133a 30       		.byte	0x30
 6987 133b 9F       		.byte	0x9f
 6988 133c 040A0000 		.quad	.LVL170-.Ltext0
 6988      00000000 
 6989 1344 0D0A0000 		.quad	.LVL171-.Ltext0
 6989      00000000 
 6990 134c 0100     		.value	0x1
 6991 134e 5D       		.byte	0x5d
 6992 134f 00000000 		.quad	0x0
 6992      00000000 
 6993 1357 00000000 		.quad	0x0
 6993      00000000 
 6994              	.LLST80:
 6995 135f 5B090000 		.quad	.LVL155-.Ltext0
 6995      00000000 
 6996 1367 6E090000 		.quad	.LVL158-.Ltext0
 6996      00000000 
 6997 136f 0200     		.value	0x2
 6998 1371 38       		.byte	0x38
 6999 1372 9F       		.byte	0x9f
 7000 1373 7A090000 		.quad	.LVL159-.Ltext0
 7000      00000000 
 7001 137b 84090000 		.quad	.LVL160-.Ltext0
 7001      00000000 
 7002 1383 0200     		.value	0x2
 7003 1385 31       		.byte	0x31
 7004 1386 9F       		.byte	0x9f
 7005 1387 84090000 		.quad	.LVL160-.Ltext0
 7005      00000000 
 7006 138f 8E090000 		.quad	.LVL161-.Ltext0
 7006      00000000 
 7007 1397 0200     		.value	0x2
 7008 1399 32       		.byte	0x32
 7009 139a 9F       		.byte	0x9f
 7010 139b 8E090000 		.quad	.LVL161-.Ltext0
 7010      00000000 
 7011 13a3 98090000 		.quad	.LVL162-.Ltext0
 7011      00000000 
GAS LISTING /tmp/ccK2IhnQ.s 			page 148


 7012 13ab 0200     		.value	0x2
 7013 13ad 33       		.byte	0x33
 7014 13ae 9F       		.byte	0x9f
 7015 13af 98090000 		.quad	.LVL162-.Ltext0
 7015      00000000 
 7016 13b7 A2090000 		.quad	.LVL163-.Ltext0
 7016      00000000 
 7017 13bf 0200     		.value	0x2
 7018 13c1 34       		.byte	0x34
 7019 13c2 9F       		.byte	0x9f
 7020 13c3 A2090000 		.quad	.LVL163-.Ltext0
 7020      00000000 
 7021 13cb AF090000 		.quad	.LVL164-.Ltext0
 7021      00000000 
 7022 13d3 0200     		.value	0x2
 7023 13d5 35       		.byte	0x35
 7024 13d6 9F       		.byte	0x9f
 7025 13d7 AF090000 		.quad	.LVL164-.Ltext0
 7025      00000000 
 7026 13df BC090000 		.quad	.LVL165-.Ltext0
 7026      00000000 
 7027 13e7 0200     		.value	0x2
 7028 13e9 36       		.byte	0x36
 7029 13ea 9F       		.byte	0x9f
 7030 13eb BC090000 		.quad	.LVL165-.Ltext0
 7030      00000000 
 7031 13f3 C9090000 		.quad	.LVL166-.Ltext0
 7031      00000000 
 7032 13fb 0200     		.value	0x2
 7033 13fd 37       		.byte	0x37
 7034 13fe 9F       		.byte	0x9f
 7035 13ff C9090000 		.quad	.LVL166-.Ltext0
 7035      00000000 
 7036 1407 000A0000 		.quad	.LVL169-.Ltext0
 7036      00000000 
 7037 140f 0200     		.value	0x2
 7038 1411 38       		.byte	0x38
 7039 1412 9F       		.byte	0x9f
 7040 1413 00000000 		.quad	0x0
 7040      00000000 
 7041 141b 00000000 		.quad	0x0
 7041      00000000 
 7042              	.LLST81:
 7043 1423 31090000 		.quad	.LVL152-.Ltext0
 7043      00000000 
 7044 142b 4B090000 		.quad	.LVL154-.Ltext0
 7044      00000000 
 7045 1433 0200     		.value	0x2
 7046 1435 30       		.byte	0x30
 7047 1436 9F       		.byte	0x9f
 7048 1437 4B090000 		.quad	.LVL154-.Ltext0
 7048      00000000 
 7049 143f 0D0A0000 		.quad	.LVL171-.Ltext0
 7049      00000000 
 7050 1447 0100     		.value	0x1
 7051 1449 56       		.byte	0x56
 7052 144a 00000000 		.quad	0x0
GAS LISTING /tmp/ccK2IhnQ.s 			page 149


 7052      00000000 
 7053 1452 00000000 		.quad	0x0
 7053      00000000 
 7054              	.LLST82:
 7055 145a 5B090000 		.quad	.LVL155-.Ltext0
 7055      00000000 
 7056 1462 6E090000 		.quad	.LVL158-.Ltext0
 7056      00000000 
 7057 146a 0100     		.value	0x1
 7058 146c 61       		.byte	0x61
 7059 146d 7A090000 		.quad	.LVL159-.Ltext0
 7059      00000000 
 7060 1475 84090000 		.quad	.LVL160-.Ltext0
 7060      00000000 
 7061 147d 0900     		.value	0x9
 7062 147f 70       		.byte	0x70
 7063 1480 00       		.sleb128 0
 7064 1481 32       		.byte	0x32
 7065 1482 24       		.byte	0x24
 7066 1483 91       		.byte	0x91
 7067 1484 E07D     		.sleb128 -288
 7068 1486 06       		.byte	0x6
 7069 1487 22       		.byte	0x22
 7070 1488 84090000 		.quad	.LVL160-.Ltext0
 7070      00000000 
 7071 1490 E5090000 		.quad	.LVL167-1-.Ltext0
 7071      00000000 
 7072 1498 0100     		.value	0x1
 7073 149a 61       		.byte	0x61
 7074 149b 00000000 		.quad	0x0
 7074      00000000 
 7075 14a3 00000000 		.quad	0x0
 7075      00000000 
 7076              		.file 2 "heatmap.h"
 7077              		.file 3 "/usr/lib/gcc/x86_64-redhat-linux/4.4.7/include/stddef.h"
 7078              		.section	.debug_info
 7079 0000 F30B0000 		.long	0xbf3
 7080 0004 0300     		.value	0x3
 7081 0006 00000000 		.long	.Ldebug_abbrev0
 7082 000a 08       		.byte	0x8
 7083 000b 01       		.uleb128 0x1
 7084 000c 00000000 		.long	.LASF61
 7085 0010 01       		.byte	0x1
 7086 0011 00000000 		.long	.LASF62
 7087 0015 00000000 		.long	.LASF63
 7088 0019 00000000 		.quad	.Ltext0
 7088      00000000 
 7089 0021 00000000 		.quad	.Letext0
 7089      00000000 
 7090 0029 00000000 		.long	.Ldebug_line0
 7091 002d 02       		.uleb128 0x2
 7092 002e 08       		.byte	0x8
 7093 002f 05       		.byte	0x5
 7094 0030 00000000 		.long	.LASF0
 7095 0034 03       		.uleb128 0x3
 7096 0035 00000000 		.long	.LASF4
 7097 0039 03       		.byte	0x3
GAS LISTING /tmp/ccK2IhnQ.s 			page 150


 7098 003a D3       		.byte	0xd3
 7099 003b 3F000000 		.long	0x3f
 7100 003f 02       		.uleb128 0x2
 7101 0040 08       		.byte	0x8
 7102 0041 07       		.byte	0x7
 7103 0042 00000000 		.long	.LASF1
 7104 0046 04       		.uleb128 0x4
 7105 0047 04       		.byte	0x4
 7106 0048 05       		.byte	0x5
 7107 0049 696E7400 		.string	"int"
 7108 004d 05       		.uleb128 0x5
 7109 004e 18       		.byte	0x18
 7110 004f 02       		.byte	0x2
 7111 0050 27       		.byte	0x27
 7112 0051 82000000 		.long	0x82
 7113 0055 06       		.uleb128 0x6
 7114 0056 62756600 		.string	"buf"
 7115 005a 02       		.byte	0x2
 7116 005b 28       		.byte	0x28
 7117 005c 82000000 		.long	0x82
 7118 0060 00       		.sleb128 0
 7119 0061 06       		.uleb128 0x6
 7120 0062 6D617800 		.string	"max"
 7121 0066 02       		.byte	0x2
 7122 0067 29       		.byte	0x29
 7123 0068 88000000 		.long	0x88
 7124 006c 08       		.sleb128 8
 7125 006d 06       		.uleb128 0x6
 7126 006e 7700     		.string	"w"
 7127 0070 02       		.byte	0x2
 7128 0071 2A       		.byte	0x2a
 7129 0072 8F000000 		.long	0x8f
 7130 0076 0C       		.sleb128 12
 7131 0077 06       		.uleb128 0x6
 7132 0078 6800     		.string	"h"
 7133 007a 02       		.byte	0x2
 7134 007b 2A       		.byte	0x2a
 7135 007c 8F000000 		.long	0x8f
 7136 0080 10       		.sleb128 16
 7137 0081 00       		.byte	0x0
 7138 0082 07       		.uleb128 0x7
 7139 0083 08       		.byte	0x8
 7140 0084 88000000 		.long	0x88
 7141 0088 02       		.uleb128 0x2
 7142 0089 04       		.byte	0x4
 7143 008a 04       		.byte	0x4
 7144 008b 00000000 		.long	.LASF2
 7145 008f 02       		.uleb128 0x2
 7146 0090 04       		.byte	0x4
 7147 0091 07       		.byte	0x7
 7148 0092 00000000 		.long	.LASF3
 7149 0096 03       		.uleb128 0x3
 7150 0097 00000000 		.long	.LASF5
 7151 009b 02       		.byte	0x2
 7152 009c 2B       		.byte	0x2b
 7153 009d 4D000000 		.long	0x4d
 7154 00a1 05       		.uleb128 0x5
GAS LISTING /tmp/ccK2IhnQ.s 			page 151


 7155 00a2 10       		.byte	0x10
 7156 00a3 02       		.byte	0x2
 7157 00a4 31       		.byte	0x31
 7158 00a5 CA000000 		.long	0xca
 7159 00a9 06       		.uleb128 0x6
 7160 00aa 62756600 		.string	"buf"
 7161 00ae 02       		.byte	0x2
 7162 00af 32       		.byte	0x32
 7163 00b0 82000000 		.long	0x82
 7164 00b4 00       		.sleb128 0
 7165 00b5 06       		.uleb128 0x6
 7166 00b6 7700     		.string	"w"
 7167 00b8 02       		.byte	0x2
 7168 00b9 33       		.byte	0x33
 7169 00ba 8F000000 		.long	0x8f
 7170 00be 08       		.sleb128 8
 7171 00bf 06       		.uleb128 0x6
 7172 00c0 6800     		.string	"h"
 7173 00c2 02       		.byte	0x2
 7174 00c3 33       		.byte	0x33
 7175 00c4 8F000000 		.long	0x8f
 7176 00c8 0C       		.sleb128 12
 7177 00c9 00       		.byte	0x0
 7178 00ca 03       		.uleb128 0x3
 7179 00cb 00000000 		.long	.LASF6
 7180 00cf 02       		.byte	0x2
 7181 00d0 34       		.byte	0x34
 7182 00d1 A1000000 		.long	0xa1
 7183 00d5 05       		.uleb128 0x5
 7184 00d6 10       		.byte	0x10
 7185 00d7 02       		.byte	0x2
 7186 00d8 3F       		.byte	0x3f
 7187 00d9 F6000000 		.long	0xf6
 7188 00dd 08       		.uleb128 0x8
 7189 00de 00000000 		.long	.LASF7
 7190 00e2 02       		.byte	0x2
 7191 00e3 40       		.byte	0x40
 7192 00e4 F6000000 		.long	0xf6
 7193 00e8 00       		.sleb128 0
 7194 00e9 08       		.uleb128 0x8
 7195 00ea 00000000 		.long	.LASF8
 7196 00ee 02       		.byte	0x2
 7197 00ef 41       		.byte	0x41
 7198 00f0 34000000 		.long	0x34
 7199 00f4 08       		.sleb128 8
 7200 00f5 00       		.byte	0x0
 7201 00f6 07       		.uleb128 0x7
 7202 00f7 08       		.byte	0x8
 7203 00f8 FC000000 		.long	0xfc
 7204 00fc 09       		.uleb128 0x9
 7205 00fd 01010000 		.long	0x101
 7206 0101 02       		.uleb128 0x2
 7207 0102 01       		.byte	0x1
 7208 0103 08       		.byte	0x8
 7209 0104 00000000 		.long	.LASF9
 7210 0108 03       		.uleb128 0x3
 7211 0109 00000000 		.long	.LASF10
GAS LISTING /tmp/ccK2IhnQ.s 			page 152


 7212 010d 02       		.byte	0x2
 7213 010e 42       		.byte	0x42
 7214 010f D5000000 		.long	0xd5
 7215 0113 02       		.uleb128 0x2
 7216 0114 08       		.byte	0x8
 7217 0115 05       		.byte	0x5
 7218 0116 00000000 		.long	.LASF11
 7219 011a 02       		.uleb128 0x2
 7220 011b 02       		.byte	0x2
 7221 011c 07       		.byte	0x7
 7222 011d 00000000 		.long	.LASF12
 7223 0121 02       		.uleb128 0x2
 7224 0122 01       		.byte	0x1
 7225 0123 06       		.byte	0x6
 7226 0124 00000000 		.long	.LASF13
 7227 0128 02       		.uleb128 0x2
 7228 0129 02       		.byte	0x2
 7229 012a 05       		.byte	0x5
 7230 012b 00000000 		.long	.LASF14
 7231 012f 02       		.uleb128 0x2
 7232 0130 01       		.byte	0x1
 7233 0131 06       		.byte	0x6
 7234 0132 00000000 		.long	.LASF15
 7235 0136 02       		.uleb128 0x2
 7236 0137 08       		.byte	0x8
 7237 0138 07       		.byte	0x7
 7238 0139 00000000 		.long	.LASF16
 7239 013d 02       		.uleb128 0x2
 7240 013e 08       		.byte	0x8
 7241 013f 04       		.byte	0x4
 7242 0140 00000000 		.long	.LASF17
 7243 0144 0A       		.uleb128 0xa
 7244 0145 01       		.byte	0x1
 7245 0146 00000000 		.long	.LASF21
 7246 014a 01       		.byte	0x1
 7247 014b 84       		.byte	0x84
 7248 014c 01       		.byte	0x1
 7249 014d 00000000 		.quad	.LFB28
 7249      00000000 
 7250 0155 00000000 		.quad	.LFE28
 7250      00000000 
 7251 015d 01       		.byte	0x1
 7252 015e 9C       		.byte	0x9c
 7253 015f 16020000 		.long	0x216
 7254 0163 0B       		.uleb128 0xb
 7255 0164 6800     		.string	"h"
 7256 0166 01       		.byte	0x1
 7257 0167 84       		.byte	0x84
 7258 0168 16020000 		.long	0x216
 7259 016c 01       		.byte	0x1
 7260 016d 55       		.byte	0x55
 7261 016e 0C       		.uleb128 0xc
 7262 016f 7800     		.string	"x"
 7263 0171 01       		.byte	0x1
 7264 0172 84       		.byte	0x84
 7265 0173 8F000000 		.long	0x8f
 7266 0177 00000000 		.long	.LLST0
GAS LISTING /tmp/ccK2IhnQ.s 			page 153


 7267 017b 0C       		.uleb128 0xc
 7268 017c 7900     		.string	"y"
 7269 017e 01       		.byte	0x1
 7270 017f 84       		.byte	0x84
 7271 0180 8F000000 		.long	0x8f
 7272 0184 00000000 		.long	.LLST1
 7273 0188 0D       		.uleb128 0xd
 7274 0189 00000000 		.long	.LASF18
 7275 018d 01       		.byte	0x1
 7276 018e 84       		.byte	0x84
 7277 018f 1C020000 		.long	0x21c
 7278 0193 00000000 		.long	.LLST2
 7279 0197 0E       		.uleb128 0xe
 7280 0198 00000000 		.long	.Ldebug_ranges0+0x0
 7281 019c 0F       		.uleb128 0xf
 7282 019d 783000   		.string	"x0"
 7283 01a0 01       		.byte	0x1
 7284 01a1 8F       		.byte	0x8f
 7285 01a2 27020000 		.long	0x227
 7286 01a6 00000000 		.long	.LLST3
 7287 01aa 0F       		.uleb128 0xf
 7288 01ab 793000   		.string	"y0"
 7289 01ae 01       		.byte	0x1
 7290 01af 90       		.byte	0x90
 7291 01b0 27020000 		.long	0x227
 7292 01b4 00000000 		.long	.LLST4
 7293 01b8 0F       		.uleb128 0xf
 7294 01b9 783100   		.string	"x1"
 7295 01bc 01       		.byte	0x1
 7296 01bd 91       		.byte	0x91
 7297 01be 27020000 		.long	0x227
 7298 01c2 00000000 		.long	.LLST5
 7299 01c6 0F       		.uleb128 0xf
 7300 01c7 793100   		.string	"y1"
 7301 01ca 01       		.byte	0x1
 7302 01cb 92       		.byte	0x92
 7303 01cc 27020000 		.long	0x227
 7304 01d0 00000000 		.long	.LLST6
 7305 01d4 0F       		.uleb128 0xf
 7306 01d5 697900   		.string	"iy"
 7307 01d8 01       		.byte	0x1
 7308 01d9 94       		.byte	0x94
 7309 01da 8F000000 		.long	0x8f
 7310 01de 00000000 		.long	.LLST7
 7311 01e2 0E       		.uleb128 0xe
 7312 01e3 00000000 		.long	.Ldebug_ranges0+0x30
 7313 01e7 10       		.uleb128 0x10
 7314 01e8 00000000 		.long	.LASF19
 7315 01ec 01       		.byte	0x1
 7316 01ed 98       		.byte	0x98
 7317 01ee 82000000 		.long	0x82
 7318 01f2 00000000 		.long	.LLST8
 7319 01f6 10       		.uleb128 0x10
 7320 01f7 00000000 		.long	.LASF20
 7321 01fb 01       		.byte	0x1
 7322 01fc 99       		.byte	0x99
 7323 01fd 2C020000 		.long	0x22c
GAS LISTING /tmp/ccK2IhnQ.s 			page 154


 7324 0201 00000000 		.long	.LLST9
 7325 0205 0F       		.uleb128 0xf
 7326 0206 697800   		.string	"ix"
 7327 0209 01       		.byte	0x1
 7328 020a 9B       		.byte	0x9b
 7329 020b 8F000000 		.long	0x8f
 7330 020f 00000000 		.long	.LLST10
 7331 0213 00       		.byte	0x0
 7332 0214 00       		.byte	0x0
 7333 0215 00       		.byte	0x0
 7334 0216 07       		.uleb128 0x7
 7335 0217 08       		.byte	0x8
 7336 0218 96000000 		.long	0x96
 7337 021c 07       		.uleb128 0x7
 7338 021d 08       		.byte	0x8
 7339 021e 22020000 		.long	0x222
 7340 0222 09       		.uleb128 0x9
 7341 0223 CA000000 		.long	0xca
 7342 0227 09       		.uleb128 0x9
 7343 0228 8F000000 		.long	0x8f
 7344 022c 07       		.uleb128 0x7
 7345 022d 08       		.byte	0x8
 7346 022e 32020000 		.long	0x232
 7347 0232 09       		.uleb128 0x9
 7348 0233 88000000 		.long	0x88
 7349 0237 0A       		.uleb128 0xa
 7350 0238 01       		.byte	0x1
 7351 0239 00000000 		.long	.LASF22
 7352 023d 01       		.byte	0x1
 7353 023e 7F       		.byte	0x7f
 7354 023f 01       		.byte	0x1
 7355 0240 00000000 		.quad	.LFB27
 7355      00000000 
 7356 0248 00000000 		.quad	.LFE27
 7356      00000000 
 7357 0250 01       		.byte	0x1
 7358 0251 9C       		.byte	0x9c
 7359 0252 78020000 		.long	0x278
 7360 0256 0B       		.uleb128 0xb
 7361 0257 6800     		.string	"h"
 7362 0259 01       		.byte	0x1
 7363 025a 7F       		.byte	0x7f
 7364 025b 16020000 		.long	0x216
 7365 025f 01       		.byte	0x1
 7366 0260 55       		.byte	0x55
 7367 0261 0B       		.uleb128 0xb
 7368 0262 7800     		.string	"x"
 7369 0264 01       		.byte	0x1
 7370 0265 7F       		.byte	0x7f
 7371 0266 8F000000 		.long	0x8f
 7372 026a 01       		.byte	0x1
 7373 026b 54       		.byte	0x54
 7374 026c 0B       		.uleb128 0xb
 7375 026d 7900     		.string	"y"
 7376 026f 01       		.byte	0x1
 7377 0270 7F       		.byte	0x7f
 7378 0271 8F000000 		.long	0x8f
GAS LISTING /tmp/ccK2IhnQ.s 			page 155


 7379 0275 01       		.byte	0x1
 7380 0276 51       		.byte	0x51
 7381 0277 00       		.byte	0x0
 7382 0278 0A       		.uleb128 0xa
 7383 0279 01       		.byte	0x1
 7384 027a 00000000 		.long	.LASF23
 7385 027e 01       		.byte	0x1
 7386 027f B6       		.byte	0xb6
 7387 0280 01       		.byte	0x1
 7388 0281 00000000 		.quad	.LFB30
 7388      00000000 
 7389 0289 00000000 		.quad	.LFE30
 7389      00000000 
 7390 0291 01       		.byte	0x1
 7391 0292 9C       		.byte	0x9c
 7392 0293 55030000 		.long	0x355
 7393 0297 0B       		.uleb128 0xb
 7394 0298 6800     		.string	"h"
 7395 029a 01       		.byte	0x1
 7396 029b B6       		.byte	0xb6
 7397 029c 16020000 		.long	0x216
 7398 02a0 01       		.byte	0x1
 7399 02a1 55       		.byte	0x55
 7400 02a2 0C       		.uleb128 0xc
 7401 02a3 7800     		.string	"x"
 7402 02a5 01       		.byte	0x1
 7403 02a6 B6       		.byte	0xb6
 7404 02a7 8F000000 		.long	0x8f
 7405 02ab 00000000 		.long	.LLST11
 7406 02af 0C       		.uleb128 0xc
 7407 02b0 7900     		.string	"y"
 7408 02b2 01       		.byte	0x1
 7409 02b3 B6       		.byte	0xb6
 7410 02b4 8F000000 		.long	0x8f
 7411 02b8 00000000 		.long	.LLST12
 7412 02bc 0B       		.uleb128 0xb
 7413 02bd 7700     		.string	"w"
 7414 02bf 01       		.byte	0x1
 7415 02c0 B6       		.byte	0xb6
 7416 02c1 88000000 		.long	0x88
 7417 02c5 01       		.byte	0x1
 7418 02c6 61       		.byte	0x61
 7419 02c7 0D       		.uleb128 0xd
 7420 02c8 00000000 		.long	.LASF18
 7421 02cc 01       		.byte	0x1
 7422 02cd B6       		.byte	0xb6
 7423 02ce 1C020000 		.long	0x21c
 7424 02d2 00000000 		.long	.LLST13
 7425 02d6 0E       		.uleb128 0xe
 7426 02d7 00000000 		.long	.Ldebug_ranges0+0x60
 7427 02db 0F       		.uleb128 0xf
 7428 02dc 783000   		.string	"x0"
 7429 02df 01       		.byte	0x1
 7430 02e0 C4       		.byte	0xc4
 7431 02e1 27020000 		.long	0x227
 7432 02e5 00000000 		.long	.LLST14
 7433 02e9 0F       		.uleb128 0xf
GAS LISTING /tmp/ccK2IhnQ.s 			page 156


 7434 02ea 793000   		.string	"y0"
 7435 02ed 01       		.byte	0x1
 7436 02ee C5       		.byte	0xc5
 7437 02ef 27020000 		.long	0x227
 7438 02f3 00000000 		.long	.LLST15
 7439 02f7 0F       		.uleb128 0xf
 7440 02f8 783100   		.string	"x1"
 7441 02fb 01       		.byte	0x1
 7442 02fc C6       		.byte	0xc6
 7443 02fd 27020000 		.long	0x227
 7444 0301 00000000 		.long	.LLST16
 7445 0305 0F       		.uleb128 0xf
 7446 0306 793100   		.string	"y1"
 7447 0309 01       		.byte	0x1
 7448 030a C7       		.byte	0xc7
 7449 030b 27020000 		.long	0x227
 7450 030f 00000000 		.long	.LLST17
 7451 0313 0F       		.uleb128 0xf
 7452 0314 697900   		.string	"iy"
 7453 0317 01       		.byte	0x1
 7454 0318 C9       		.byte	0xc9
 7455 0319 8F000000 		.long	0x8f
 7456 031d 00000000 		.long	.LLST18
 7457 0321 0E       		.uleb128 0xe
 7458 0322 00000000 		.long	.Ldebug_ranges0+0x90
 7459 0326 10       		.uleb128 0x10
 7460 0327 00000000 		.long	.LASF19
 7461 032b 01       		.byte	0x1
 7462 032c CD       		.byte	0xcd
 7463 032d 82000000 		.long	0x82
 7464 0331 00000000 		.long	.LLST19
 7465 0335 10       		.uleb128 0x10
 7466 0336 00000000 		.long	.LASF20
 7467 033a 01       		.byte	0x1
 7468 033b CE       		.byte	0xce
 7469 033c 2C020000 		.long	0x22c
 7470 0340 00000000 		.long	.LLST20
 7471 0344 0F       		.uleb128 0xf
 7472 0345 697800   		.string	"ix"
 7473 0348 01       		.byte	0x1
 7474 0349 D0       		.byte	0xd0
 7475 034a 8F000000 		.long	0x8f
 7476 034e 00000000 		.long	.LLST21
 7477 0352 00       		.byte	0x0
 7478 0353 00       		.byte	0x0
 7479 0354 00       		.byte	0x0
 7480 0355 0A       		.uleb128 0xa
 7481 0356 01       		.byte	0x1
 7482 0357 00000000 		.long	.LASF24
 7483 035b 01       		.byte	0x1
 7484 035c AB       		.byte	0xab
 7485 035d 01       		.byte	0x1
 7486 035e 00000000 		.quad	.LFB29
 7486      00000000 
 7487 0366 00000000 		.quad	.LFE29
 7487      00000000 
 7488 036e 01       		.byte	0x1
GAS LISTING /tmp/ccK2IhnQ.s 			page 157


 7489 036f 9C       		.byte	0x9c
 7490 0370 A1030000 		.long	0x3a1
 7491 0374 0B       		.uleb128 0xb
 7492 0375 6800     		.string	"h"
 7493 0377 01       		.byte	0x1
 7494 0378 AB       		.byte	0xab
 7495 0379 16020000 		.long	0x216
 7496 037d 01       		.byte	0x1
 7497 037e 55       		.byte	0x55
 7498 037f 0B       		.uleb128 0xb
 7499 0380 7800     		.string	"x"
 7500 0382 01       		.byte	0x1
 7501 0383 AB       		.byte	0xab
 7502 0384 8F000000 		.long	0x8f
 7503 0388 01       		.byte	0x1
 7504 0389 54       		.byte	0x54
 7505 038a 0B       		.uleb128 0xb
 7506 038b 7900     		.string	"y"
 7507 038d 01       		.byte	0x1
 7508 038e AB       		.byte	0xab
 7509 038f 8F000000 		.long	0x8f
 7510 0393 01       		.byte	0x1
 7511 0394 51       		.byte	0x51
 7512 0395 0B       		.uleb128 0xb
 7513 0396 7700     		.string	"w"
 7514 0398 01       		.byte	0x1
 7515 0399 AB       		.byte	0xab
 7516 039a 88000000 		.long	0x88
 7517 039e 01       		.byte	0x1
 7518 039f 61       		.byte	0x61
 7519 03a0 00       		.byte	0x0
 7520 03a1 11       		.uleb128 0x11
 7521 03a2 00000000 		.long	.LASF64
 7522 03a6 01       		.byte	0x1
 7523 03a7 3601     		.value	0x136
 7524 03a9 01       		.byte	0x1
 7525 03aa 88000000 		.long	0x88
 7526 03ae 00000000 		.quad	.LFB37
 7526      00000000 
 7527 03b6 00000000 		.quad	.LFE37
 7527      00000000 
 7528 03be 01       		.byte	0x1
 7529 03bf 9C       		.byte	0x9c
 7530 03c0 D3030000 		.long	0x3d3
 7531 03c4 12       		.uleb128 0x12
 7532 03c5 00000000 		.long	.LASF25
 7533 03c9 01       		.byte	0x1
 7534 03ca 3601     		.value	0x136
 7535 03cc 88000000 		.long	0x88
 7536 03d0 01       		.byte	0x1
 7537 03d1 61       		.byte	0x61
 7538 03d2 00       		.byte	0x0
 7539 03d3 13       		.uleb128 0x13
 7540 03d4 01       		.byte	0x1
 7541 03d5 00000000 		.long	.LASF26
 7542 03d9 01       		.byte	0x1
 7543 03da 7201     		.value	0x172
GAS LISTING /tmp/ccK2IhnQ.s 			page 158


 7544 03dc 01       		.byte	0x1
 7545 03dd 00000000 		.quad	.LFB42
 7545      00000000 
 7546 03e5 00000000 		.quad	.LFE42
 7546      00000000 
 7547 03ed 01       		.byte	0x1
 7548 03ee 9C       		.byte	0x9c
 7549 03ef 03040000 		.long	0x403
 7550 03f3 14       		.uleb128 0x14
 7551 03f4 637300   		.string	"cs"
 7552 03f7 01       		.byte	0x1
 7553 03f8 7201     		.value	0x172
 7554 03fa 03040000 		.long	0x403
 7555 03fe 00000000 		.long	.LLST22
 7556 0402 00       		.byte	0x0
 7557 0403 07       		.uleb128 0x7
 7558 0404 08       		.byte	0x8
 7559 0405 08010000 		.long	0x108
 7560 0409 13       		.uleb128 0x13
 7561 040a 01       		.byte	0x1
 7562 040b 00000000 		.long	.LASF27
 7563 040f 01       		.byte	0x1
 7564 0410 5A01     		.value	0x15a
 7565 0412 01       		.byte	0x1
 7566 0413 00000000 		.quad	.LFB40
 7566      00000000 
 7567 041b 00000000 		.quad	.LFE40
 7567      00000000 
 7568 0423 01       		.byte	0x1
 7569 0424 9C       		.byte	0x9c
 7570 0425 38040000 		.long	0x438
 7571 0429 14       		.uleb128 0x14
 7572 042a 7300     		.string	"s"
 7573 042c 01       		.byte	0x1
 7574 042d 5A01     		.value	0x15a
 7575 042f 38040000 		.long	0x438
 7576 0433 00000000 		.long	.LLST23
 7577 0437 00       		.byte	0x0
 7578 0438 07       		.uleb128 0x7
 7579 0439 08       		.byte	0x8
 7580 043a CA000000 		.long	0xca
 7581 043e 0A       		.uleb128 0xa
 7582 043f 01       		.byte	0x1
 7583 0440 00000000 		.long	.LASF28
 7584 0444 01       		.byte	0x1
 7585 0445 45       		.byte	0x45
 7586 0446 01       		.byte	0x1
 7587 0447 00000000 		.quad	.LFB24
 7587      00000000 
 7588 044f 00000000 		.quad	.LFE24
 7588      00000000 
 7589 0457 01       		.byte	0x1
 7590 0458 9C       		.byte	0x9c
 7591 0459 6B040000 		.long	0x46b
 7592 045d 0C       		.uleb128 0xc
 7593 045e 6800     		.string	"h"
 7594 0460 01       		.byte	0x1
GAS LISTING /tmp/ccK2IhnQ.s 			page 159


 7595 0461 45       		.byte	0x45
 7596 0462 16020000 		.long	0x216
 7597 0466 00000000 		.long	.LLST24
 7598 046a 00       		.byte	0x0
 7599 046b 15       		.uleb128 0x15
 7600 046c 01       		.byte	0x1
 7601 046d 00000000 		.long	.LASF30
 7602 0471 01       		.byte	0x1
 7603 0472 6001     		.value	0x160
 7604 0474 01       		.byte	0x1
 7605 0475 03040000 		.long	0x403
 7606 0479 00000000 		.quad	.LFB41
 7606      00000000 
 7607 0481 00000000 		.quad	.LFE41
 7607      00000000 
 7608 0489 01       		.byte	0x1
 7609 048a 9C       		.byte	0x9c
 7610 048b CF040000 		.long	0x4cf
 7611 048f 16       		.uleb128 0x16
 7612 0490 00000000 		.long	.LASF29
 7613 0494 01       		.byte	0x1
 7614 0495 6001     		.value	0x160
 7615 0497 F6000000 		.long	0xf6
 7616 049b 00000000 		.long	.LLST25
 7617 049f 16       		.uleb128 0x16
 7618 04a0 00000000 		.long	.LASF8
 7619 04a4 01       		.byte	0x1
 7620 04a5 6001     		.value	0x160
 7621 04a7 34000000 		.long	0x34
 7622 04ab 00000000 		.long	.LLST26
 7623 04af 17       		.uleb128 0x17
 7624 04b0 637300   		.string	"cs"
 7625 04b3 01       		.byte	0x1
 7626 04b4 6201     		.value	0x162
 7627 04b6 03040000 		.long	0x403
 7628 04ba 00000000 		.long	.LLST27
 7629 04be 18       		.uleb128 0x18
 7630 04bf 00000000 		.long	.LASF7
 7631 04c3 01       		.byte	0x1
 7632 04c4 6301     		.value	0x163
 7633 04c6 CF040000 		.long	0x4cf
 7634 04ca 00000000 		.long	.LLST28
 7635 04ce 00       		.byte	0x0
 7636 04cf 07       		.uleb128 0x7
 7637 04d0 08       		.byte	0x8
 7638 04d1 01010000 		.long	0x101
 7639 04d5 19       		.uleb128 0x19
 7640 04d6 01       		.byte	0x1
 7641 04d7 00000000 		.long	.LASF31
 7642 04db 01       		.byte	0x1
 7643 04dc EF       		.byte	0xef
 7644 04dd 01       		.byte	0x1
 7645 04de CF040000 		.long	0x4cf
 7646 04e2 00000000 		.quad	.LFB33
 7646      00000000 
 7647 04ea 00000000 		.quad	.LFE33
 7647      00000000 
GAS LISTING /tmp/ccK2IhnQ.s 			page 160


 7648 04f2 01       		.byte	0x1
 7649 04f3 9C       		.byte	0x9c
 7650 04f4 9D050000 		.long	0x59d
 7651 04f8 0C       		.uleb128 0xc
 7652 04f9 6800     		.string	"h"
 7653 04fb 01       		.byte	0x1
 7654 04fc EF       		.byte	0xef
 7655 04fd 9D050000 		.long	0x59d
 7656 0501 00000000 		.long	.LLST29
 7657 0505 0D       		.uleb128 0xd
 7658 0506 00000000 		.long	.LASF32
 7659 050a 01       		.byte	0x1
 7660 050b EF       		.byte	0xef
 7661 050c A8050000 		.long	0x5a8
 7662 0510 00000000 		.long	.LLST30
 7663 0514 0D       		.uleb128 0xd
 7664 0515 00000000 		.long	.LASF33
 7665 0519 01       		.byte	0x1
 7666 051a EF       		.byte	0xef
 7667 051b 88000000 		.long	0x88
 7668 051f 00000000 		.long	.LLST31
 7669 0523 0D       		.uleb128 0xd
 7670 0524 00000000 		.long	.LASF34
 7671 0528 01       		.byte	0x1
 7672 0529 EF       		.byte	0xef
 7673 052a CF040000 		.long	0x4cf
 7674 052e 00000000 		.long	.LLST32
 7675 0532 0F       		.uleb128 0xf
 7676 0533 7900     		.string	"y"
 7677 0535 01       		.byte	0x1
 7678 0536 F1       		.byte	0xf1
 7679 0537 8F000000 		.long	0x8f
 7680 053b 00000000 		.long	.LLST33
 7681 053f 1A       		.uleb128 0x1a
 7682 0540 00000000 		.quad	.LBB10
 7682      00000000 
 7683 0548 00000000 		.quad	.LBE10
 7683      00000000 
 7684 0550 10       		.uleb128 0x10
 7685 0551 00000000 		.long	.LASF35
 7686 0555 01       		.byte	0x1
 7687 0556 FF       		.byte	0xff
 7688 0557 82000000 		.long	0x82
 7689 055b 00000000 		.long	.LLST34
 7690 055f 18       		.uleb128 0x18
 7691 0560 00000000 		.long	.LASF36
 7692 0564 01       		.byte	0x1
 7693 0565 0001     		.value	0x100
 7694 0567 CF040000 		.long	0x4cf
 7695 056b 00000000 		.long	.LLST35
 7696 056f 17       		.uleb128 0x17
 7697 0570 7800     		.string	"x"
 7698 0572 01       		.byte	0x1
 7699 0573 0201     		.value	0x102
 7700 0575 8F000000 		.long	0x8f
 7701 0579 00000000 		.long	.LLST36
 7702 057d 0E       		.uleb128 0xe
GAS LISTING /tmp/ccK2IhnQ.s 			page 161


 7703 057e 00000000 		.long	.Ldebug_ranges0+0xc0
 7704 0582 1B       		.uleb128 0x1b
 7705 0583 76616C00 		.string	"val"
 7706 0587 01       		.byte	0x1
 7707 0588 0701     		.value	0x107
 7708 058a 32020000 		.long	0x232
 7709 058e 1B       		.uleb128 0x1b
 7710 058f 69647800 		.string	"idx"
 7711 0593 01       		.byte	0x1
 7712 0594 0D01     		.value	0x10d
 7713 0596 B3050000 		.long	0x5b3
 7714 059a 00       		.byte	0x0
 7715 059b 00       		.byte	0x0
 7716 059c 00       		.byte	0x0
 7717 059d 07       		.uleb128 0x7
 7718 059e 08       		.byte	0x8
 7719 059f A3050000 		.long	0x5a3
 7720 05a3 09       		.uleb128 0x9
 7721 05a4 96000000 		.long	0x96
 7722 05a8 07       		.uleb128 0x7
 7723 05a9 08       		.byte	0x8
 7724 05aa AE050000 		.long	0x5ae
 7725 05ae 09       		.uleb128 0x9
 7726 05af 08010000 		.long	0x108
 7727 05b3 09       		.uleb128 0x9
 7728 05b4 34000000 		.long	0x34
 7729 05b8 19       		.uleb128 0x19
 7730 05b9 01       		.byte	0x1
 7731 05ba 00000000 		.long	.LASF37
 7732 05be 01       		.byte	0x1
 7733 05bf E3       		.byte	0xe3
 7734 05c0 01       		.byte	0x1
 7735 05c1 CF040000 		.long	0x4cf
 7736 05c5 00000000 		.quad	.LFB32
 7736      00000000 
 7737 05cd 00000000 		.quad	.LFE32
 7737      00000000 
 7738 05d5 01       		.byte	0x1
 7739 05d6 9C       		.byte	0x9c
 7740 05d7 01060000 		.long	0x601
 7741 05db 0B       		.uleb128 0xb
 7742 05dc 6800     		.string	"h"
 7743 05de 01       		.byte	0x1
 7744 05df E3       		.byte	0xe3
 7745 05e0 9D050000 		.long	0x59d
 7746 05e4 01       		.byte	0x1
 7747 05e5 55       		.byte	0x55
 7748 05e6 1C       		.uleb128 0x1c
 7749 05e7 00000000 		.long	.LASF32
 7750 05eb 01       		.byte	0x1
 7751 05ec E3       		.byte	0xe3
 7752 05ed A8050000 		.long	0x5a8
 7753 05f1 01       		.byte	0x1
 7754 05f2 54       		.byte	0x54
 7755 05f3 1C       		.uleb128 0x1c
 7756 05f4 00000000 		.long	.LASF34
 7757 05f8 01       		.byte	0x1
GAS LISTING /tmp/ccK2IhnQ.s 			page 162


 7758 05f9 E3       		.byte	0xe3
 7759 05fa CF040000 		.long	0x4cf
 7760 05fe 01       		.byte	0x1
 7761 05ff 51       		.byte	0x51
 7762 0600 00       		.byte	0x0
 7763 0601 19       		.uleb128 0x19
 7764 0602 01       		.byte	0x1
 7765 0603 00000000 		.long	.LASF38
 7766 0607 01       		.byte	0x1
 7767 0608 DE       		.byte	0xde
 7768 0609 01       		.byte	0x1
 7769 060a CF040000 		.long	0x4cf
 7770 060e 00000000 		.quad	.LFB31
 7770      00000000 
 7771 0616 00000000 		.quad	.LFE31
 7771      00000000 
 7772 061e 01       		.byte	0x1
 7773 061f 9C       		.byte	0x9c
 7774 0620 3F060000 		.long	0x63f
 7775 0624 0B       		.uleb128 0xb
 7776 0625 6800     		.string	"h"
 7777 0627 01       		.byte	0x1
 7778 0628 DE       		.byte	0xde
 7779 0629 9D050000 		.long	0x59d
 7780 062d 01       		.byte	0x1
 7781 062e 55       		.byte	0x55
 7782 062f 0D       		.uleb128 0xd
 7783 0630 00000000 		.long	.LASF34
 7784 0634 01       		.byte	0x1
 7785 0635 DE       		.byte	0xde
 7786 0636 CF040000 		.long	0x4cf
 7787 063a 00000000 		.long	.LLST37
 7788 063e 00       		.byte	0x0
 7789 063f 13       		.uleb128 0x13
 7790 0640 01       		.byte	0x1
 7791 0641 00000000 		.long	.LASF39
 7792 0645 01       		.byte	0x1
 7793 0646 1E01     		.value	0x11e
 7794 0648 01       		.byte	0x1
 7795 0649 00000000 		.quad	.LFB34
 7795      00000000 
 7796 0651 00000000 		.quad	.LFE34
 7796      00000000 
 7797 0659 01       		.byte	0x1
 7798 065a 9C       		.byte	0x9c
 7799 065b 94060000 		.long	0x694
 7800 065f 12       		.uleb128 0x12
 7801 0660 00000000 		.long	.LASF18
 7802 0664 01       		.byte	0x1
 7803 0665 1E01     		.value	0x11e
 7804 0667 38040000 		.long	0x438
 7805 066b 01       		.byte	0x1
 7806 066c 55       		.byte	0x55
 7807 066d 1D       		.uleb128 0x1d
 7808 066e 7700     		.string	"w"
 7809 0670 01       		.byte	0x1
 7810 0671 1E01     		.value	0x11e
GAS LISTING /tmp/ccK2IhnQ.s 			page 163


 7811 0673 8F000000 		.long	0x8f
 7812 0677 01       		.byte	0x1
 7813 0678 54       		.byte	0x54
 7814 0679 1D       		.uleb128 0x1d
 7815 067a 6800     		.string	"h"
 7816 067c 01       		.byte	0x1
 7817 067d 1E01     		.value	0x11e
 7818 067f 8F000000 		.long	0x8f
 7819 0683 01       		.byte	0x1
 7820 0684 51       		.byte	0x51
 7821 0685 12       		.uleb128 0x12
 7822 0686 00000000 		.long	.LASF40
 7823 068a 01       		.byte	0x1
 7824 068b 1E01     		.value	0x11e
 7825 068d 82000000 		.long	0x82
 7826 0691 01       		.byte	0x1
 7827 0692 52       		.byte	0x52
 7828 0693 00       		.byte	0x0
 7829 0694 15       		.uleb128 0x15
 7830 0695 01       		.byte	0x1
 7831 0696 00000000 		.long	.LASF41
 7832 069a 01       		.byte	0x1
 7833 069b 2801     		.value	0x128
 7834 069d 01       		.byte	0x1
 7835 069e 38040000 		.long	0x438
 7836 06a2 00000000 		.quad	.LFB35
 7836      00000000 
 7837 06aa 00000000 		.quad	.LFE35
 7837      00000000 
 7838 06b2 01       		.byte	0x1
 7839 06b3 9C       		.byte	0x9c
 7840 06b4 F5060000 		.long	0x6f5
 7841 06b8 14       		.uleb128 0x14
 7842 06b9 7700     		.string	"w"
 7843 06bb 01       		.byte	0x1
 7844 06bc 2801     		.value	0x128
 7845 06be 8F000000 		.long	0x8f
 7846 06c2 00000000 		.long	.LLST38
 7847 06c6 14       		.uleb128 0x14
 7848 06c7 6800     		.string	"h"
 7849 06c9 01       		.byte	0x1
 7850 06ca 2801     		.value	0x128
 7851 06cc 8F000000 		.long	0x8f
 7852 06d0 00000000 		.long	.LLST39
 7853 06d4 16       		.uleb128 0x16
 7854 06d5 00000000 		.long	.LASF40
 7855 06d9 01       		.byte	0x1
 7856 06da 2801     		.value	0x128
 7857 06dc 82000000 		.long	0x82
 7858 06e0 00000000 		.long	.LLST40
 7859 06e4 18       		.uleb128 0x18
 7860 06e5 00000000 		.long	.LASF18
 7861 06e9 01       		.byte	0x1
 7862 06ea 2A01     		.value	0x12a
 7863 06ec 38040000 		.long	0x438
 7864 06f0 00000000 		.long	.LLST41
 7865 06f4 00       		.byte	0x0
GAS LISTING /tmp/ccK2IhnQ.s 			page 164


 7866 06f5 15       		.uleb128 0x15
 7867 06f6 01       		.byte	0x1
 7868 06f7 00000000 		.long	.LASF42
 7869 06fb 01       		.byte	0x1
 7870 06fc 4001     		.value	0x140
 7871 06fe 01       		.byte	0x1
 7872 06ff 38040000 		.long	0x438
 7873 0703 00000000 		.quad	.LFB39
 7873      00000000 
 7874 070b 00000000 		.quad	.LFE39
 7874      00000000 
 7875 0713 01       		.byte	0x1
 7876 0714 9C       		.byte	0x9c
 7877 0715 C5070000 		.long	0x7c5
 7878 0719 14       		.uleb128 0x14
 7879 071a 7200     		.string	"r"
 7880 071c 01       		.byte	0x1
 7881 071d 4001     		.value	0x140
 7882 071f 8F000000 		.long	0x8f
 7883 0723 00000000 		.long	.LLST42
 7884 0727 16       		.uleb128 0x16
 7885 0728 00000000 		.long	.LASF43
 7886 072c 01       		.byte	0x1
 7887 072d 4001     		.value	0x140
 7888 072f D5070000 		.long	0x7d5
 7889 0733 00000000 		.long	.LLST43
 7890 0737 17       		.uleb128 0x17
 7891 0738 7900     		.string	"y"
 7892 073a 01       		.byte	0x1
 7893 073b 4201     		.value	0x142
 7894 073d 8F000000 		.long	0x8f
 7895 0741 00000000 		.long	.LLST44
 7896 0745 17       		.uleb128 0x17
 7897 0746 6400     		.string	"d"
 7898 0748 01       		.byte	0x1
 7899 0749 4301     		.value	0x143
 7900 074b 8F000000 		.long	0x8f
 7901 074f 00000000 		.long	.LLST45
 7902 0753 18       		.uleb128 0x18
 7903 0754 00000000 		.long	.LASF18
 7904 0758 01       		.byte	0x1
 7905 0759 4501     		.value	0x145
 7906 075b 82000000 		.long	0x82
 7907 075f 00000000 		.long	.LLST46
 7908 0763 1A       		.uleb128 0x1a
 7909 0764 00000000 		.quad	.LBB16
 7909      00000000 
 7910 076c 00000000 		.quad	.LBE16
 7910      00000000 
 7911 0774 18       		.uleb128 0x18
 7912 0775 00000000 		.long	.LASF19
 7913 0779 01       		.byte	0x1
 7914 077a 4A01     		.value	0x14a
 7915 077c 82000000 		.long	0x82
 7916 0780 00000000 		.long	.LLST47
 7917 0784 17       		.uleb128 0x17
 7918 0785 7800     		.string	"x"
GAS LISTING /tmp/ccK2IhnQ.s 			page 165


 7919 0787 01       		.byte	0x1
 7920 0788 4B01     		.value	0x14b
 7921 078a 8F000000 		.long	0x8f
 7922 078e 00000000 		.long	.LLST48
 7923 0792 0E       		.uleb128 0xe
 7924 0793 00000000 		.long	.Ldebug_ranges0+0x120
 7925 0797 1E       		.uleb128 0x1e
 7926 0798 00000000 		.long	.LASF25
 7927 079c 01       		.byte	0x1
 7928 079d 4D01     		.value	0x14d
 7929 079f 32020000 		.long	0x232
 7930 07a3 17       		.uleb128 0x17
 7931 07a4 647300   		.string	"ds"
 7932 07a7 01       		.byte	0x1
 7933 07a8 4E01     		.value	0x14e
 7934 07aa 32020000 		.long	0x232
 7935 07ae 00000000 		.long	.LLST49
 7936 07b2 18       		.uleb128 0x18
 7937 07b3 00000000 		.long	.LASF44
 7938 07b7 01       		.byte	0x1
 7939 07b8 5001     		.value	0x150
 7940 07ba 32020000 		.long	0x232
 7941 07be 00000000 		.long	.LLST50
 7942 07c2 00       		.byte	0x0
 7943 07c3 00       		.byte	0x0
 7944 07c4 00       		.byte	0x0
 7945 07c5 1F       		.uleb128 0x1f
 7946 07c6 01       		.byte	0x1
 7947 07c7 88000000 		.long	0x88
 7948 07cb D5070000 		.long	0x7d5
 7949 07cf 20       		.uleb128 0x20
 7950 07d0 88000000 		.long	0x88
 7951 07d4 00       		.byte	0x0
 7952 07d5 07       		.uleb128 0x7
 7953 07d6 08       		.byte	0x8
 7954 07d7 C5070000 		.long	0x7c5
 7955 07db 15       		.uleb128 0x15
 7956 07dc 01       		.byte	0x1
 7957 07dd 00000000 		.long	.LASF45
 7958 07e1 01       		.byte	0x1
 7959 07e2 3B01     		.value	0x13b
 7960 07e4 01       		.byte	0x1
 7961 07e5 38040000 		.long	0x438
 7962 07e9 00000000 		.quad	.LFB38
 7962      00000000 
 7963 07f1 00000000 		.quad	.LFE38
 7963      00000000 
 7964 07f9 01       		.byte	0x1
 7965 07fa 9C       		.byte	0x9c
 7966 07fb 0C080000 		.long	0x80c
 7967 07ff 1D       		.uleb128 0x1d
 7968 0800 7200     		.string	"r"
 7969 0802 01       		.byte	0x1
 7970 0803 3B01     		.value	0x13b
 7971 0805 8F000000 		.long	0x8f
 7972 0809 01       		.byte	0x1
 7973 080a 55       		.byte	0x55
GAS LISTING /tmp/ccK2IhnQ.s 			page 166


 7974 080b 00       		.byte	0x0
 7975 080c 15       		.uleb128 0x15
 7976 080d 01       		.byte	0x1
 7977 080e 00000000 		.long	.LASF46
 7978 0812 01       		.byte	0x1
 7979 0813 2F01     		.value	0x12f
 7980 0815 01       		.byte	0x1
 7981 0816 38040000 		.long	0x438
 7982 081a 00000000 		.quad	.LFB36
 7982      00000000 
 7983 0822 00000000 		.quad	.LFE36
 7983      00000000 
 7984 082a 01       		.byte	0x1
 7985 082b 9C       		.byte	0x9c
 7986 082c 6D080000 		.long	0x86d
 7987 0830 14       		.uleb128 0x14
 7988 0831 7700     		.string	"w"
 7989 0833 01       		.byte	0x1
 7990 0834 2F01     		.value	0x12f
 7991 0836 8F000000 		.long	0x8f
 7992 083a 00000000 		.long	.LLST51
 7993 083e 14       		.uleb128 0x14
 7994 083f 6800     		.string	"h"
 7995 0841 01       		.byte	0x1
 7996 0842 2F01     		.value	0x12f
 7997 0844 8F000000 		.long	0x8f
 7998 0848 00000000 		.long	.LLST52
 7999 084c 16       		.uleb128 0x16
 8000 084d 00000000 		.long	.LASF40
 8001 0851 01       		.byte	0x1
 8002 0852 2F01     		.value	0x12f
 8003 0854 82000000 		.long	0x82
 8004 0858 00000000 		.long	.LLST53
 8005 085c 18       		.uleb128 0x18
 8006 085d 00000000 		.long	.LASF47
 8007 0861 01       		.byte	0x1
 8008 0862 3101     		.value	0x131
 8009 0864 82000000 		.long	0x82
 8010 0868 00000000 		.long	.LLST54
 8011 086c 00       		.byte	0x0
 8012 086d 0A       		.uleb128 0xa
 8013 086e 01       		.byte	0x1
 8014 086f 00000000 		.long	.LASF48
 8015 0873 01       		.byte	0x1
 8016 0874 36       		.byte	0x36
 8017 0875 01       		.byte	0x1
 8018 0876 00000000 		.quad	.LFB22
 8018      00000000 
 8019 087e 00000000 		.quad	.LFE22
 8019      00000000 
 8020 0886 01       		.byte	0x1
 8021 0887 9C       		.byte	0x9c
 8022 0888 B5080000 		.long	0x8b5
 8023 088c 0C       		.uleb128 0xc
 8024 088d 686D00   		.string	"hm"
 8025 0890 01       		.byte	0x1
 8026 0891 36       		.byte	0x36
GAS LISTING /tmp/ccK2IhnQ.s 			page 167


 8027 0892 16020000 		.long	0x216
 8028 0896 00000000 		.long	.LLST55
 8029 089a 0C       		.uleb128 0xc
 8030 089b 7700     		.string	"w"
 8031 089d 01       		.byte	0x1
 8032 089e 36       		.byte	0x36
 8033 089f 8F000000 		.long	0x8f
 8034 08a3 00000000 		.long	.LLST56
 8035 08a7 0C       		.uleb128 0xc
 8036 08a8 6800     		.string	"h"
 8037 08aa 01       		.byte	0x1
 8038 08ab 36       		.byte	0x36
 8039 08ac 8F000000 		.long	0x8f
 8040 08b0 00000000 		.long	.LLST57
 8041 08b4 00       		.byte	0x0
 8042 08b5 19       		.uleb128 0x19
 8043 08b6 01       		.byte	0x1
 8044 08b7 00000000 		.long	.LASF49
 8045 08bb 01       		.byte	0x1
 8046 08bc 3E       		.byte	0x3e
 8047 08bd 01       		.byte	0x1
 8048 08be 16020000 		.long	0x216
 8049 08c2 00000000 		.quad	.LFB23
 8049      00000000 
 8050 08ca 00000000 		.quad	.LFE23
 8050      00000000 
 8051 08d2 01       		.byte	0x1
 8052 08d3 9C       		.byte	0x9c
 8053 08d4 01090000 		.long	0x901
 8054 08d8 0C       		.uleb128 0xc
 8055 08d9 7700     		.string	"w"
 8056 08db 01       		.byte	0x1
 8057 08dc 3E       		.byte	0x3e
 8058 08dd 8F000000 		.long	0x8f
 8059 08e1 00000000 		.long	.LLST58
 8060 08e5 0C       		.uleb128 0xc
 8061 08e6 6800     		.string	"h"
 8062 08e8 01       		.byte	0x1
 8063 08e9 3E       		.byte	0x3e
 8064 08ea 8F000000 		.long	0x8f
 8065 08ee 00000000 		.long	.LLST59
 8066 08f2 0F       		.uleb128 0xf
 8067 08f3 686D00   		.string	"hm"
 8068 08f6 01       		.byte	0x1
 8069 08f7 40       		.byte	0x40
 8070 08f8 16020000 		.long	0x216
 8071 08fc 00000000 		.long	.LLST60
 8072 0900 00       		.byte	0x0
 8073 0901 21       		.uleb128 0x21
 8074 0902 00000000 		.long	.LASF65
 8075 0906 01       		.byte	0x1
 8076 0907 01       		.byte	0x1
 8077 0908 00000000 		.quad	.LFB43
 8077      00000000 
 8078 0910 00000000 		.quad	.LFE43
 8078      00000000 
 8079 0918 01       		.byte	0x1
GAS LISTING /tmp/ccK2IhnQ.s 			page 168


 8080 0919 9C       		.byte	0x9c
 8081 091a CF090000 		.long	0x9cf
 8082 091e 22       		.uleb128 0x22
 8083 091f 00000000 		.long	.LASF66
 8084 0923 3A0A0000 		.long	0xa3a
 8085 0927 01       		.byte	0x1
 8086 0928 00000000 		.long	.LLST61
 8087 092c 10       		.uleb128 0x10
 8088 092d 00000000 		.long	.LASF50
 8089 0931 01       		.byte	0x1
 8090 0932 55       		.byte	0x55
 8091 0933 240A0000 		.long	0xa24
 8092 0937 00000000 		.long	.LLST62
 8093 093b 10       		.uleb128 0x10
 8094 093c 00000000 		.long	.LASF51
 8095 0940 01       		.byte	0x1
 8096 0941 54       		.byte	0x54
 8097 0942 27020000 		.long	0x227
 8098 0946 00000000 		.long	.LLST63
 8099 094a 10       		.uleb128 0x10
 8100 094b 00000000 		.long	.LASF52
 8101 094f 01       		.byte	0x1
 8102 0950 51       		.byte	0x51
 8103 0951 8F000000 		.long	0x8f
 8104 0955 00000000 		.long	.LLST64
 8105 0959 0F       		.uleb128 0xf
 8106 095a 797300   		.string	"ys"
 8107 095d 01       		.byte	0x1
 8108 095e 51       		.byte	0x51
 8109 095f 1E0A0000 		.long	0xa1e
 8110 0963 00000000 		.long	.LLST65
 8111 0967 0F       		.uleb128 0xf
 8112 0968 787300   		.string	"xs"
 8113 096b 01       		.byte	0x1
 8114 096c 51       		.byte	0x51
 8115 096d 1E0A0000 		.long	0xa1e
 8116 0971 00000000 		.long	.LLST66
 8117 0975 0F       		.uleb128 0xf
 8118 0976 6800     		.string	"h"
 8119 0978 01       		.byte	0x1
 8120 0979 51       		.byte	0x51
 8121 097a 16020000 		.long	0x216
 8122 097e 00000000 		.long	.LLST67
 8123 0982 1A       		.uleb128 0x1a
 8124 0983 00000000 		.quad	.LBB21
 8124      00000000 
 8125 098b 00000000 		.quad	.LBE21
 8125      00000000 
 8126 0993 0F       		.uleb128 0xf
 8127 0994 69647800 		.string	"idx"
 8128 0998 01       		.byte	0x1
 8129 0999 5A       		.byte	0x5a
 8130 099a 46000000 		.long	0x46
 8131 099e 00000000 		.long	.LLST68
 8132 09a2 10       		.uleb128 0x10
 8133 09a3 00000000 		.long	.LASF53
 8134 09a7 01       		.byte	0x1
GAS LISTING /tmp/ccK2IhnQ.s 			page 169


 8135 09a8 5B       		.byte	0x5b
 8136 09a9 8F000000 		.long	0x8f
 8137 09ad 00000000 		.long	.LLST69
 8138 09b1 0F       		.uleb128 0xf
 8139 09b2 656E6400 		.string	"end"
 8140 09b6 01       		.byte	0x1
 8141 09b7 5C       		.byte	0x5c
 8142 09b8 8F000000 		.long	0x8f
 8143 09bc 00000000 		.long	.LLST70
 8144 09c0 0F       		.uleb128 0xf
 8145 09c1 6900     		.string	"i"
 8146 09c3 01       		.byte	0x1
 8147 09c4 60       		.byte	0x60
 8148 09c5 8F000000 		.long	0x8f
 8149 09c9 00000000 		.long	.LLST71
 8150 09cd 00       		.byte	0x0
 8151 09ce 00       		.byte	0x0
 8152 09cf 23       		.uleb128 0x23
 8153 09d0 00000000 		.long	.LASF67
 8154 09d4 28       		.byte	0x28
 8155 09d5 1E0A0000 		.long	0xa1e
 8156 09d9 06       		.uleb128 0x6
 8157 09da 6800     		.string	"h"
 8158 09dc 01       		.byte	0x1
 8159 09dd 58       		.byte	0x58
 8160 09de 16020000 		.long	0x216
 8161 09e2 00       		.sleb128 0
 8162 09e3 06       		.uleb128 0x6
 8163 09e4 787300   		.string	"xs"
 8164 09e7 01       		.byte	0x1
 8165 09e8 58       		.byte	0x58
 8166 09e9 1E0A0000 		.long	0xa1e
 8167 09ed 08       		.sleb128 8
 8168 09ee 06       		.uleb128 0x6
 8169 09ef 797300   		.string	"ys"
 8170 09f2 01       		.byte	0x1
 8171 09f3 58       		.byte	0x58
 8172 09f4 1E0A0000 		.long	0xa1e
 8173 09f8 10       		.sleb128 16
 8174 09f9 08       		.uleb128 0x8
 8175 09fa 00000000 		.long	.LASF50
 8176 09fe 01       		.byte	0x1
 8177 09ff 58       		.byte	0x58
 8178 0a00 340A0000 		.long	0xa34
 8179 0a04 18       		.sleb128 24
 8180 0a05 08       		.uleb128 0x8
 8181 0a06 00000000 		.long	.LASF52
 8182 0a0a 01       		.byte	0x1
 8183 0a0b 58       		.byte	0x58
 8184 0a0c 8F000000 		.long	0x8f
 8185 0a10 20       		.sleb128 32
 8186 0a11 08       		.uleb128 0x8
 8187 0a12 00000000 		.long	.LASF51
 8188 0a16 01       		.byte	0x1
 8189 0a17 58       		.byte	0x58
 8190 0a18 27020000 		.long	0x227
 8191 0a1c 24       		.sleb128 36
GAS LISTING /tmp/ccK2IhnQ.s 			page 170


 8192 0a1d 00       		.byte	0x0
 8193 0a1e 07       		.uleb128 0x7
 8194 0a1f 08       		.byte	0x8
 8195 0a20 8F000000 		.long	0x8f
 8196 0a24 24       		.uleb128 0x24
 8197 0a25 96000000 		.long	0x96
 8198 0a29 340A0000 		.long	0xa34
 8199 0a2d 25       		.uleb128 0x25
 8200 0a2e 3F000000 		.long	0x3f
 8201 0a32 07       		.byte	0x7
 8202 0a33 00       		.byte	0x0
 8203 0a34 07       		.uleb128 0x7
 8204 0a35 08       		.byte	0x8
 8205 0a36 240A0000 		.long	0xa24
 8206 0a3a 07       		.uleb128 0x7
 8207 0a3b 08       		.byte	0x8
 8208 0a3c CF090000 		.long	0x9cf
 8209 0a40 0A       		.uleb128 0xa
 8210 0a41 01       		.byte	0x1
 8211 0a42 00000000 		.long	.LASF54
 8212 0a46 01       		.byte	0x1
 8213 0a47 51       		.byte	0x51
 8214 0a48 01       		.byte	0x1
 8215 0a49 00000000 		.quad	.LFB26
 8215      00000000 
 8216 0a51 00000000 		.quad	.LFE26
 8216      00000000 
 8217 0a59 01       		.byte	0x1
 8218 0a5a 9C       		.byte	0x9c
 8219 0a5b 060B0000 		.long	0xb06
 8220 0a5f 0C       		.uleb128 0xc
 8221 0a60 6800     		.string	"h"
 8222 0a62 01       		.byte	0x1
 8223 0a63 51       		.byte	0x51
 8224 0a64 16020000 		.long	0x216
 8225 0a68 00000000 		.long	.LLST72
 8226 0a6c 0C       		.uleb128 0xc
 8227 0a6d 787300   		.string	"xs"
 8228 0a70 01       		.byte	0x1
 8229 0a71 51       		.byte	0x51
 8230 0a72 1E0A0000 		.long	0xa1e
 8231 0a76 00000000 		.long	.LLST73
 8232 0a7a 0C       		.uleb128 0xc
 8233 0a7b 797300   		.string	"ys"
 8234 0a7e 01       		.byte	0x1
 8235 0a7f 51       		.byte	0x51
 8236 0a80 1E0A0000 		.long	0xa1e
 8237 0a84 00000000 		.long	.LLST74
 8238 0a88 0D       		.uleb128 0xd
 8239 0a89 00000000 		.long	.LASF52
 8240 0a8d 01       		.byte	0x1
 8241 0a8e 51       		.byte	0x51
 8242 0a8f 8F000000 		.long	0x8f
 8243 0a93 00000000 		.long	.LLST75
 8244 0a97 0D       		.uleb128 0xd
 8245 0a98 00000000 		.long	.LASF18
 8246 0a9c 01       		.byte	0x1
GAS LISTING /tmp/ccK2IhnQ.s 			page 171


 8247 0a9d 51       		.byte	0x51
 8248 0a9e 1C020000 		.long	0x21c
 8249 0aa2 00000000 		.long	.LLST76
 8250 0aa6 10       		.uleb128 0x10
 8251 0aa7 00000000 		.long	.LASF51
 8252 0aab 01       		.byte	0x1
 8253 0aac 54       		.byte	0x54
 8254 0aad 27020000 		.long	0x227
 8255 0ab1 00000000 		.long	.LLST77
 8256 0ab5 26       		.uleb128 0x26
 8257 0ab6 00000000 		.long	.LASF50
 8258 0aba 01       		.byte	0x1
 8259 0abb 55       		.byte	0x55
 8260 0abc 240A0000 		.long	0xa24
 8261 0ac0 03       		.byte	0x3
 8262 0ac1 91       		.byte	0x91
 8263 0ac2 E07D     		.sleb128 -288
 8264 0ac4 0F       		.uleb128 0xf
 8265 0ac5 7800     		.string	"x"
 8266 0ac7 01       		.byte	0x1
 8267 0ac8 68       		.byte	0x68
 8268 0ac9 8F000000 		.long	0x8f
 8269 0acd 00000000 		.long	.LLST78
 8270 0ad1 0F       		.uleb128 0xf
 8271 0ad2 7900     		.string	"y"
 8272 0ad4 01       		.byte	0x1
 8273 0ad5 68       		.byte	0x68
 8274 0ad6 8F000000 		.long	0x8f
 8275 0ada 00000000 		.long	.LLST79
 8276 0ade 0F       		.uleb128 0xf
 8277 0adf 6B00     		.string	"k"
 8278 0ae1 01       		.byte	0x1
 8279 0ae2 68       		.byte	0x68
 8280 0ae3 8F000000 		.long	0x8f
 8281 0ae7 00000000 		.long	.LLST80
 8282 0aeb 0F       		.uleb128 0xf
 8283 0aec 6900     		.string	"i"
 8284 0aee 01       		.byte	0x1
 8285 0aef 68       		.byte	0x68
 8286 0af0 8F000000 		.long	0x8f
 8287 0af4 00000000 		.long	.LLST81
 8288 0af8 0F       		.uleb128 0xf
 8289 0af9 7700     		.string	"w"
 8290 0afb 01       		.byte	0x1
 8291 0afc 69       		.byte	0x69
 8292 0afd 88000000 		.long	0x88
 8293 0b01 00000000 		.long	.LLST82
 8294 0b05 00       		.byte	0x0
 8295 0b06 0A       		.uleb128 0xa
 8296 0b07 01       		.byte	0x1
 8297 0b08 00000000 		.long	.LASF55
 8298 0b0c 01       		.byte	0x1
 8299 0b0d 4C       		.byte	0x4c
 8300 0b0e 01       		.byte	0x1
 8301 0b0f 00000000 		.quad	.LFB25
 8301      00000000 
 8302 0b17 00000000 		.quad	.LFE25
GAS LISTING /tmp/ccK2IhnQ.s 			page 172


 8302      00000000 
 8303 0b1f 01       		.byte	0x1
 8304 0b20 9C       		.byte	0x9c
 8305 0b21 560B0000 		.long	0xb56
 8306 0b25 0B       		.uleb128 0xb
 8307 0b26 6800     		.string	"h"
 8308 0b28 01       		.byte	0x1
 8309 0b29 4C       		.byte	0x4c
 8310 0b2a 16020000 		.long	0x216
 8311 0b2e 01       		.byte	0x1
 8312 0b2f 55       		.byte	0x55
 8313 0b30 0B       		.uleb128 0xb
 8314 0b31 787300   		.string	"xs"
 8315 0b34 01       		.byte	0x1
 8316 0b35 4C       		.byte	0x4c
 8317 0b36 1E0A0000 		.long	0xa1e
 8318 0b3a 01       		.byte	0x1
 8319 0b3b 54       		.byte	0x54
 8320 0b3c 0B       		.uleb128 0xb
 8321 0b3d 797300   		.string	"ys"
 8322 0b40 01       		.byte	0x1
 8323 0b41 4C       		.byte	0x4c
 8324 0b42 1E0A0000 		.long	0xa1e
 8325 0b46 01       		.byte	0x1
 8326 0b47 51       		.byte	0x51
 8327 0b48 1C       		.uleb128 0x1c
 8328 0b49 00000000 		.long	.LASF52
 8329 0b4d 01       		.byte	0x1
 8330 0b4e 4C       		.byte	0x4c
 8331 0b4f 8F000000 		.long	0x8f
 8332 0b53 01       		.byte	0x1
 8333 0b54 52       		.byte	0x52
 8334 0b55 00       		.byte	0x0
 8335 0b56 27       		.uleb128 0x27
 8336 0b57 00000000 		.long	.LASF60
 8337 0b5b 02       		.byte	0x2
 8338 0b5c B1       		.byte	0xb1
 8339 0b5d A8050000 		.long	0x5a8
 8340 0b61 01       		.byte	0x1
 8341 0b62 01       		.byte	0x1
 8342 0b63 24       		.uleb128 0x24
 8343 0b64 88000000 		.long	0x88
 8344 0b68 730B0000 		.long	0xb73
 8345 0b6c 25       		.uleb128 0x25
 8346 0b6d 3F000000 		.long	0x3f
 8347 0b71 50       		.byte	0x50
 8348 0b72 00       		.byte	0x0
 8349 0b73 26       		.uleb128 0x26
 8350 0b74 00000000 		.long	.LASF56
 8351 0b78 01       		.byte	0x1
 8352 0b79 26       		.byte	0x26
 8353 0b7a 630B0000 		.long	0xb63
 8354 0b7e 09       		.byte	0x9
 8355 0b7f 03       		.byte	0x3
 8356 0b80 00000000 		.quad	stamp_default_4_data
 8356      00000000 
 8357 0b88 26       		.uleb128 0x26
GAS LISTING /tmp/ccK2IhnQ.s 			page 173


 8358 0b89 00000000 		.long	.LASF57
 8359 0b8d 01       		.byte	0x1
 8360 0b8e 32       		.byte	0x32
 8361 0b8f CA000000 		.long	0xca
 8362 0b93 09       		.byte	0x9
 8363 0b94 03       		.byte	0x3
 8364 0b95 00000000 		.quad	stamp_default_4
 8364      00000000 
 8365 0b9d 24       		.uleb128 0x24
 8366 0b9e 01010000 		.long	0x101
 8367 0ba2 AE0B0000 		.long	0xbae
 8368 0ba6 28       		.uleb128 0x28
 8369 0ba7 3F000000 		.long	0x3f
 8370 0bab 0310     		.value	0x1003
 8371 0bad 00       		.byte	0x0
 8372 0bae 29       		.uleb128 0x29
 8373 0baf 00000000 		.long	.LASF58
 8374 0bb3 01       		.byte	0x1
 8375 0bb4 7A01     		.value	0x17a
 8376 0bb6 C40B0000 		.long	0xbc4
 8377 0bba 09       		.byte	0x9
 8378 0bbb 03       		.byte	0x3
 8379 0bbc 00000000 		.quad	mixed_data
 8379      00000000 
 8380 0bc4 09       		.uleb128 0x9
 8381 0bc5 9D0B0000 		.long	0xb9d
 8382 0bc9 29       		.uleb128 0x29
 8383 0bca 00000000 		.long	.LASF59
 8384 0bce 01       		.byte	0x1
 8385 0bcf 7B01     		.value	0x17b
 8386 0bd1 AE050000 		.long	0x5ae
 8387 0bd5 09       		.byte	0x9
 8388 0bd6 03       		.byte	0x3
 8389 0bd7 00000000 		.quad	cs_spectral_mixed
 8389      00000000 
 8390 0bdf 2A       		.uleb128 0x2a
 8391 0be0 00000000 		.long	.LASF60
 8392 0be4 01       		.byte	0x1
 8393 0be5 7C01     		.value	0x17c
 8394 0be7 A8050000 		.long	0x5a8
 8395 0beb 01       		.byte	0x1
 8396 0bec 09       		.byte	0x9
 8397 0bed 03       		.byte	0x3
 8398 0bee 00000000 		.quad	heatmap_cs_default
 8398      00000000 
 8399 0bf6 00       		.byte	0x0
 8400              		.section	.debug_abbrev
 8401 0000 01       		.uleb128 0x1
 8402 0001 11       		.uleb128 0x11
 8403 0002 01       		.byte	0x1
 8404 0003 25       		.uleb128 0x25
 8405 0004 0E       		.uleb128 0xe
 8406 0005 13       		.uleb128 0x13
 8407 0006 0B       		.uleb128 0xb
 8408 0007 03       		.uleb128 0x3
 8409 0008 0E       		.uleb128 0xe
 8410 0009 1B       		.uleb128 0x1b
GAS LISTING /tmp/ccK2IhnQ.s 			page 174


 8411 000a 0E       		.uleb128 0xe
 8412 000b 11       		.uleb128 0x11
 8413 000c 01       		.uleb128 0x1
 8414 000d 12       		.uleb128 0x12
 8415 000e 01       		.uleb128 0x1
 8416 000f 10       		.uleb128 0x10
 8417 0010 06       		.uleb128 0x6
 8418 0011 00       		.byte	0x0
 8419 0012 00       		.byte	0x0
 8420 0013 02       		.uleb128 0x2
 8421 0014 24       		.uleb128 0x24
 8422 0015 00       		.byte	0x0
 8423 0016 0B       		.uleb128 0xb
 8424 0017 0B       		.uleb128 0xb
 8425 0018 3E       		.uleb128 0x3e
 8426 0019 0B       		.uleb128 0xb
 8427 001a 03       		.uleb128 0x3
 8428 001b 0E       		.uleb128 0xe
 8429 001c 00       		.byte	0x0
 8430 001d 00       		.byte	0x0
 8431 001e 03       		.uleb128 0x3
 8432 001f 16       		.uleb128 0x16
 8433 0020 00       		.byte	0x0
 8434 0021 03       		.uleb128 0x3
 8435 0022 0E       		.uleb128 0xe
 8436 0023 3A       		.uleb128 0x3a
 8437 0024 0B       		.uleb128 0xb
 8438 0025 3B       		.uleb128 0x3b
 8439 0026 0B       		.uleb128 0xb
 8440 0027 49       		.uleb128 0x49
 8441 0028 13       		.uleb128 0x13
 8442 0029 00       		.byte	0x0
 8443 002a 00       		.byte	0x0
 8444 002b 04       		.uleb128 0x4
 8445 002c 24       		.uleb128 0x24
 8446 002d 00       		.byte	0x0
 8447 002e 0B       		.uleb128 0xb
 8448 002f 0B       		.uleb128 0xb
 8449 0030 3E       		.uleb128 0x3e
 8450 0031 0B       		.uleb128 0xb
 8451 0032 03       		.uleb128 0x3
 8452 0033 08       		.uleb128 0x8
 8453 0034 00       		.byte	0x0
 8454 0035 00       		.byte	0x0
 8455 0036 05       		.uleb128 0x5
 8456 0037 13       		.uleb128 0x13
 8457 0038 01       		.byte	0x1
 8458 0039 0B       		.uleb128 0xb
 8459 003a 0B       		.uleb128 0xb
 8460 003b 3A       		.uleb128 0x3a
 8461 003c 0B       		.uleb128 0xb
 8462 003d 3B       		.uleb128 0x3b
 8463 003e 0B       		.uleb128 0xb
 8464 003f 01       		.uleb128 0x1
 8465 0040 13       		.uleb128 0x13
 8466 0041 00       		.byte	0x0
 8467 0042 00       		.byte	0x0
GAS LISTING /tmp/ccK2IhnQ.s 			page 175


 8468 0043 06       		.uleb128 0x6
 8469 0044 0D       		.uleb128 0xd
 8470 0045 00       		.byte	0x0
 8471 0046 03       		.uleb128 0x3
 8472 0047 08       		.uleb128 0x8
 8473 0048 3A       		.uleb128 0x3a
 8474 0049 0B       		.uleb128 0xb
 8475 004a 3B       		.uleb128 0x3b
 8476 004b 0B       		.uleb128 0xb
 8477 004c 49       		.uleb128 0x49
 8478 004d 13       		.uleb128 0x13
 8479 004e 38       		.uleb128 0x38
 8480 004f 0D       		.uleb128 0xd
 8481 0050 00       		.byte	0x0
 8482 0051 00       		.byte	0x0
 8483 0052 07       		.uleb128 0x7
 8484 0053 0F       		.uleb128 0xf
 8485 0054 00       		.byte	0x0
 8486 0055 0B       		.uleb128 0xb
 8487 0056 0B       		.uleb128 0xb
 8488 0057 49       		.uleb128 0x49
 8489 0058 13       		.uleb128 0x13
 8490 0059 00       		.byte	0x0
 8491 005a 00       		.byte	0x0
 8492 005b 08       		.uleb128 0x8
 8493 005c 0D       		.uleb128 0xd
 8494 005d 00       		.byte	0x0
 8495 005e 03       		.uleb128 0x3
 8496 005f 0E       		.uleb128 0xe
 8497 0060 3A       		.uleb128 0x3a
 8498 0061 0B       		.uleb128 0xb
 8499 0062 3B       		.uleb128 0x3b
 8500 0063 0B       		.uleb128 0xb
 8501 0064 49       		.uleb128 0x49
 8502 0065 13       		.uleb128 0x13
 8503 0066 38       		.uleb128 0x38
 8504 0067 0D       		.uleb128 0xd
 8505 0068 00       		.byte	0x0
 8506 0069 00       		.byte	0x0
 8507 006a 09       		.uleb128 0x9
 8508 006b 26       		.uleb128 0x26
 8509 006c 00       		.byte	0x0
 8510 006d 49       		.uleb128 0x49
 8511 006e 13       		.uleb128 0x13
 8512 006f 00       		.byte	0x0
 8513 0070 00       		.byte	0x0
 8514 0071 0A       		.uleb128 0xa
 8515 0072 2E       		.uleb128 0x2e
 8516 0073 01       		.byte	0x1
 8517 0074 3F       		.uleb128 0x3f
 8518 0075 0C       		.uleb128 0xc
 8519 0076 03       		.uleb128 0x3
 8520 0077 0E       		.uleb128 0xe
 8521 0078 3A       		.uleb128 0x3a
 8522 0079 0B       		.uleb128 0xb
 8523 007a 3B       		.uleb128 0x3b
 8524 007b 0B       		.uleb128 0xb
GAS LISTING /tmp/ccK2IhnQ.s 			page 176


 8525 007c 27       		.uleb128 0x27
 8526 007d 0C       		.uleb128 0xc
 8527 007e 11       		.uleb128 0x11
 8528 007f 01       		.uleb128 0x1
 8529 0080 12       		.uleb128 0x12
 8530 0081 01       		.uleb128 0x1
 8531 0082 40       		.uleb128 0x40
 8532 0083 0A       		.uleb128 0xa
 8533 0084 01       		.uleb128 0x1
 8534 0085 13       		.uleb128 0x13
 8535 0086 00       		.byte	0x0
 8536 0087 00       		.byte	0x0
 8537 0088 0B       		.uleb128 0xb
 8538 0089 05       		.uleb128 0x5
 8539 008a 00       		.byte	0x0
 8540 008b 03       		.uleb128 0x3
 8541 008c 08       		.uleb128 0x8
 8542 008d 3A       		.uleb128 0x3a
 8543 008e 0B       		.uleb128 0xb
 8544 008f 3B       		.uleb128 0x3b
 8545 0090 0B       		.uleb128 0xb
 8546 0091 49       		.uleb128 0x49
 8547 0092 13       		.uleb128 0x13
 8548 0093 02       		.uleb128 0x2
 8549 0094 0A       		.uleb128 0xa
 8550 0095 00       		.byte	0x0
 8551 0096 00       		.byte	0x0
 8552 0097 0C       		.uleb128 0xc
 8553 0098 05       		.uleb128 0x5
 8554 0099 00       		.byte	0x0
 8555 009a 03       		.uleb128 0x3
 8556 009b 08       		.uleb128 0x8
 8557 009c 3A       		.uleb128 0x3a
 8558 009d 0B       		.uleb128 0xb
 8559 009e 3B       		.uleb128 0x3b
 8560 009f 0B       		.uleb128 0xb
 8561 00a0 49       		.uleb128 0x49
 8562 00a1 13       		.uleb128 0x13
 8563 00a2 02       		.uleb128 0x2
 8564 00a3 06       		.uleb128 0x6
 8565 00a4 00       		.byte	0x0
 8566 00a5 00       		.byte	0x0
 8567 00a6 0D       		.uleb128 0xd
 8568 00a7 05       		.uleb128 0x5
 8569 00a8 00       		.byte	0x0
 8570 00a9 03       		.uleb128 0x3
 8571 00aa 0E       		.uleb128 0xe
 8572 00ab 3A       		.uleb128 0x3a
 8573 00ac 0B       		.uleb128 0xb
 8574 00ad 3B       		.uleb128 0x3b
 8575 00ae 0B       		.uleb128 0xb
 8576 00af 49       		.uleb128 0x49
 8577 00b0 13       		.uleb128 0x13
 8578 00b1 02       		.uleb128 0x2
 8579 00b2 06       		.uleb128 0x6
 8580 00b3 00       		.byte	0x0
 8581 00b4 00       		.byte	0x0
GAS LISTING /tmp/ccK2IhnQ.s 			page 177


 8582 00b5 0E       		.uleb128 0xe
 8583 00b6 0B       		.uleb128 0xb
 8584 00b7 01       		.byte	0x1
 8585 00b8 55       		.uleb128 0x55
 8586 00b9 06       		.uleb128 0x6
 8587 00ba 00       		.byte	0x0
 8588 00bb 00       		.byte	0x0
 8589 00bc 0F       		.uleb128 0xf
 8590 00bd 34       		.uleb128 0x34
 8591 00be 00       		.byte	0x0
 8592 00bf 03       		.uleb128 0x3
 8593 00c0 08       		.uleb128 0x8
 8594 00c1 3A       		.uleb128 0x3a
 8595 00c2 0B       		.uleb128 0xb
 8596 00c3 3B       		.uleb128 0x3b
 8597 00c4 0B       		.uleb128 0xb
 8598 00c5 49       		.uleb128 0x49
 8599 00c6 13       		.uleb128 0x13
 8600 00c7 02       		.uleb128 0x2
 8601 00c8 06       		.uleb128 0x6
 8602 00c9 00       		.byte	0x0
 8603 00ca 00       		.byte	0x0
 8604 00cb 10       		.uleb128 0x10
 8605 00cc 34       		.uleb128 0x34
 8606 00cd 00       		.byte	0x0
 8607 00ce 03       		.uleb128 0x3
 8608 00cf 0E       		.uleb128 0xe
 8609 00d0 3A       		.uleb128 0x3a
 8610 00d1 0B       		.uleb128 0xb
 8611 00d2 3B       		.uleb128 0x3b
 8612 00d3 0B       		.uleb128 0xb
 8613 00d4 49       		.uleb128 0x49
 8614 00d5 13       		.uleb128 0x13
 8615 00d6 02       		.uleb128 0x2
 8616 00d7 06       		.uleb128 0x6
 8617 00d8 00       		.byte	0x0
 8618 00d9 00       		.byte	0x0
 8619 00da 11       		.uleb128 0x11
 8620 00db 2E       		.uleb128 0x2e
 8621 00dc 01       		.byte	0x1
 8622 00dd 03       		.uleb128 0x3
 8623 00de 0E       		.uleb128 0xe
 8624 00df 3A       		.uleb128 0x3a
 8625 00e0 0B       		.uleb128 0xb
 8626 00e1 3B       		.uleb128 0x3b
 8627 00e2 05       		.uleb128 0x5
 8628 00e3 27       		.uleb128 0x27
 8629 00e4 0C       		.uleb128 0xc
 8630 00e5 49       		.uleb128 0x49
 8631 00e6 13       		.uleb128 0x13
 8632 00e7 11       		.uleb128 0x11
 8633 00e8 01       		.uleb128 0x1
 8634 00e9 12       		.uleb128 0x12
 8635 00ea 01       		.uleb128 0x1
 8636 00eb 40       		.uleb128 0x40
 8637 00ec 0A       		.uleb128 0xa
 8638 00ed 01       		.uleb128 0x1
GAS LISTING /tmp/ccK2IhnQ.s 			page 178


 8639 00ee 13       		.uleb128 0x13
 8640 00ef 00       		.byte	0x0
 8641 00f0 00       		.byte	0x0
 8642 00f1 12       		.uleb128 0x12
 8643 00f2 05       		.uleb128 0x5
 8644 00f3 00       		.byte	0x0
 8645 00f4 03       		.uleb128 0x3
 8646 00f5 0E       		.uleb128 0xe
 8647 00f6 3A       		.uleb128 0x3a
 8648 00f7 0B       		.uleb128 0xb
 8649 00f8 3B       		.uleb128 0x3b
 8650 00f9 05       		.uleb128 0x5
 8651 00fa 49       		.uleb128 0x49
 8652 00fb 13       		.uleb128 0x13
 8653 00fc 02       		.uleb128 0x2
 8654 00fd 0A       		.uleb128 0xa
 8655 00fe 00       		.byte	0x0
 8656 00ff 00       		.byte	0x0
 8657 0100 13       		.uleb128 0x13
 8658 0101 2E       		.uleb128 0x2e
 8659 0102 01       		.byte	0x1
 8660 0103 3F       		.uleb128 0x3f
 8661 0104 0C       		.uleb128 0xc
 8662 0105 03       		.uleb128 0x3
 8663 0106 0E       		.uleb128 0xe
 8664 0107 3A       		.uleb128 0x3a
 8665 0108 0B       		.uleb128 0xb
 8666 0109 3B       		.uleb128 0x3b
 8667 010a 05       		.uleb128 0x5
 8668 010b 27       		.uleb128 0x27
 8669 010c 0C       		.uleb128 0xc
 8670 010d 11       		.uleb128 0x11
 8671 010e 01       		.uleb128 0x1
 8672 010f 12       		.uleb128 0x12
 8673 0110 01       		.uleb128 0x1
 8674 0111 40       		.uleb128 0x40
 8675 0112 0A       		.uleb128 0xa
 8676 0113 01       		.uleb128 0x1
 8677 0114 13       		.uleb128 0x13
 8678 0115 00       		.byte	0x0
 8679 0116 00       		.byte	0x0
 8680 0117 14       		.uleb128 0x14
 8681 0118 05       		.uleb128 0x5
 8682 0119 00       		.byte	0x0
 8683 011a 03       		.uleb128 0x3
 8684 011b 08       		.uleb128 0x8
 8685 011c 3A       		.uleb128 0x3a
 8686 011d 0B       		.uleb128 0xb
 8687 011e 3B       		.uleb128 0x3b
 8688 011f 05       		.uleb128 0x5
 8689 0120 49       		.uleb128 0x49
 8690 0121 13       		.uleb128 0x13
 8691 0122 02       		.uleb128 0x2
 8692 0123 06       		.uleb128 0x6
 8693 0124 00       		.byte	0x0
 8694 0125 00       		.byte	0x0
 8695 0126 15       		.uleb128 0x15
GAS LISTING /tmp/ccK2IhnQ.s 			page 179


 8696 0127 2E       		.uleb128 0x2e
 8697 0128 01       		.byte	0x1
 8698 0129 3F       		.uleb128 0x3f
 8699 012a 0C       		.uleb128 0xc
 8700 012b 03       		.uleb128 0x3
 8701 012c 0E       		.uleb128 0xe
 8702 012d 3A       		.uleb128 0x3a
 8703 012e 0B       		.uleb128 0xb
 8704 012f 3B       		.uleb128 0x3b
 8705 0130 05       		.uleb128 0x5
 8706 0131 27       		.uleb128 0x27
 8707 0132 0C       		.uleb128 0xc
 8708 0133 49       		.uleb128 0x49
 8709 0134 13       		.uleb128 0x13
 8710 0135 11       		.uleb128 0x11
 8711 0136 01       		.uleb128 0x1
 8712 0137 12       		.uleb128 0x12
 8713 0138 01       		.uleb128 0x1
 8714 0139 40       		.uleb128 0x40
 8715 013a 0A       		.uleb128 0xa
 8716 013b 01       		.uleb128 0x1
 8717 013c 13       		.uleb128 0x13
 8718 013d 00       		.byte	0x0
 8719 013e 00       		.byte	0x0
 8720 013f 16       		.uleb128 0x16
 8721 0140 05       		.uleb128 0x5
 8722 0141 00       		.byte	0x0
 8723 0142 03       		.uleb128 0x3
 8724 0143 0E       		.uleb128 0xe
 8725 0144 3A       		.uleb128 0x3a
 8726 0145 0B       		.uleb128 0xb
 8727 0146 3B       		.uleb128 0x3b
 8728 0147 05       		.uleb128 0x5
 8729 0148 49       		.uleb128 0x49
 8730 0149 13       		.uleb128 0x13
 8731 014a 02       		.uleb128 0x2
 8732 014b 06       		.uleb128 0x6
 8733 014c 00       		.byte	0x0
 8734 014d 00       		.byte	0x0
 8735 014e 17       		.uleb128 0x17
 8736 014f 34       		.uleb128 0x34
 8737 0150 00       		.byte	0x0
 8738 0151 03       		.uleb128 0x3
 8739 0152 08       		.uleb128 0x8
 8740 0153 3A       		.uleb128 0x3a
 8741 0154 0B       		.uleb128 0xb
 8742 0155 3B       		.uleb128 0x3b
 8743 0156 05       		.uleb128 0x5
 8744 0157 49       		.uleb128 0x49
 8745 0158 13       		.uleb128 0x13
 8746 0159 02       		.uleb128 0x2
 8747 015a 06       		.uleb128 0x6
 8748 015b 00       		.byte	0x0
 8749 015c 00       		.byte	0x0
 8750 015d 18       		.uleb128 0x18
 8751 015e 34       		.uleb128 0x34
 8752 015f 00       		.byte	0x0
GAS LISTING /tmp/ccK2IhnQ.s 			page 180


 8753 0160 03       		.uleb128 0x3
 8754 0161 0E       		.uleb128 0xe
 8755 0162 3A       		.uleb128 0x3a
 8756 0163 0B       		.uleb128 0xb
 8757 0164 3B       		.uleb128 0x3b
 8758 0165 05       		.uleb128 0x5
 8759 0166 49       		.uleb128 0x49
 8760 0167 13       		.uleb128 0x13
 8761 0168 02       		.uleb128 0x2
 8762 0169 06       		.uleb128 0x6
 8763 016a 00       		.byte	0x0
 8764 016b 00       		.byte	0x0
 8765 016c 19       		.uleb128 0x19
 8766 016d 2E       		.uleb128 0x2e
 8767 016e 01       		.byte	0x1
 8768 016f 3F       		.uleb128 0x3f
 8769 0170 0C       		.uleb128 0xc
 8770 0171 03       		.uleb128 0x3
 8771 0172 0E       		.uleb128 0xe
 8772 0173 3A       		.uleb128 0x3a
 8773 0174 0B       		.uleb128 0xb
 8774 0175 3B       		.uleb128 0x3b
 8775 0176 0B       		.uleb128 0xb
 8776 0177 27       		.uleb128 0x27
 8777 0178 0C       		.uleb128 0xc
 8778 0179 49       		.uleb128 0x49
 8779 017a 13       		.uleb128 0x13
 8780 017b 11       		.uleb128 0x11
 8781 017c 01       		.uleb128 0x1
 8782 017d 12       		.uleb128 0x12
 8783 017e 01       		.uleb128 0x1
 8784 017f 40       		.uleb128 0x40
 8785 0180 0A       		.uleb128 0xa
 8786 0181 01       		.uleb128 0x1
 8787 0182 13       		.uleb128 0x13
 8788 0183 00       		.byte	0x0
 8789 0184 00       		.byte	0x0
 8790 0185 1A       		.uleb128 0x1a
 8791 0186 0B       		.uleb128 0xb
 8792 0187 01       		.byte	0x1
 8793 0188 11       		.uleb128 0x11
 8794 0189 01       		.uleb128 0x1
 8795 018a 12       		.uleb128 0x12
 8796 018b 01       		.uleb128 0x1
 8797 018c 00       		.byte	0x0
 8798 018d 00       		.byte	0x0
 8799 018e 1B       		.uleb128 0x1b
 8800 018f 34       		.uleb128 0x34
 8801 0190 00       		.byte	0x0
 8802 0191 03       		.uleb128 0x3
 8803 0192 08       		.uleb128 0x8
 8804 0193 3A       		.uleb128 0x3a
 8805 0194 0B       		.uleb128 0xb
 8806 0195 3B       		.uleb128 0x3b
 8807 0196 05       		.uleb128 0x5
 8808 0197 49       		.uleb128 0x49
 8809 0198 13       		.uleb128 0x13
GAS LISTING /tmp/ccK2IhnQ.s 			page 181


 8810 0199 00       		.byte	0x0
 8811 019a 00       		.byte	0x0
 8812 019b 1C       		.uleb128 0x1c
 8813 019c 05       		.uleb128 0x5
 8814 019d 00       		.byte	0x0
 8815 019e 03       		.uleb128 0x3
 8816 019f 0E       		.uleb128 0xe
 8817 01a0 3A       		.uleb128 0x3a
 8818 01a1 0B       		.uleb128 0xb
 8819 01a2 3B       		.uleb128 0x3b
 8820 01a3 0B       		.uleb128 0xb
 8821 01a4 49       		.uleb128 0x49
 8822 01a5 13       		.uleb128 0x13
 8823 01a6 02       		.uleb128 0x2
 8824 01a7 0A       		.uleb128 0xa
 8825 01a8 00       		.byte	0x0
 8826 01a9 00       		.byte	0x0
 8827 01aa 1D       		.uleb128 0x1d
 8828 01ab 05       		.uleb128 0x5
 8829 01ac 00       		.byte	0x0
 8830 01ad 03       		.uleb128 0x3
 8831 01ae 08       		.uleb128 0x8
 8832 01af 3A       		.uleb128 0x3a
 8833 01b0 0B       		.uleb128 0xb
 8834 01b1 3B       		.uleb128 0x3b
 8835 01b2 05       		.uleb128 0x5
 8836 01b3 49       		.uleb128 0x49
 8837 01b4 13       		.uleb128 0x13
 8838 01b5 02       		.uleb128 0x2
 8839 01b6 0A       		.uleb128 0xa
 8840 01b7 00       		.byte	0x0
 8841 01b8 00       		.byte	0x0
 8842 01b9 1E       		.uleb128 0x1e
 8843 01ba 34       		.uleb128 0x34
 8844 01bb 00       		.byte	0x0
 8845 01bc 03       		.uleb128 0x3
 8846 01bd 0E       		.uleb128 0xe
 8847 01be 3A       		.uleb128 0x3a
 8848 01bf 0B       		.uleb128 0xb
 8849 01c0 3B       		.uleb128 0x3b
 8850 01c1 05       		.uleb128 0x5
 8851 01c2 49       		.uleb128 0x49
 8852 01c3 13       		.uleb128 0x13
 8853 01c4 00       		.byte	0x0
 8854 01c5 00       		.byte	0x0
 8855 01c6 1F       		.uleb128 0x1f
 8856 01c7 15       		.uleb128 0x15
 8857 01c8 01       		.byte	0x1
 8858 01c9 27       		.uleb128 0x27
 8859 01ca 0C       		.uleb128 0xc
 8860 01cb 49       		.uleb128 0x49
 8861 01cc 13       		.uleb128 0x13
 8862 01cd 01       		.uleb128 0x1
 8863 01ce 13       		.uleb128 0x13
 8864 01cf 00       		.byte	0x0
 8865 01d0 00       		.byte	0x0
 8866 01d1 20       		.uleb128 0x20
GAS LISTING /tmp/ccK2IhnQ.s 			page 182


 8867 01d2 05       		.uleb128 0x5
 8868 01d3 00       		.byte	0x0
 8869 01d4 49       		.uleb128 0x49
 8870 01d5 13       		.uleb128 0x13
 8871 01d6 00       		.byte	0x0
 8872 01d7 00       		.byte	0x0
 8873 01d8 21       		.uleb128 0x21
 8874 01d9 2E       		.uleb128 0x2e
 8875 01da 01       		.byte	0x1
 8876 01db 03       		.uleb128 0x3
 8877 01dc 0E       		.uleb128 0xe
 8878 01dd 27       		.uleb128 0x27
 8879 01de 0C       		.uleb128 0xc
 8880 01df 34       		.uleb128 0x34
 8881 01e0 0C       		.uleb128 0xc
 8882 01e1 11       		.uleb128 0x11
 8883 01e2 01       		.uleb128 0x1
 8884 01e3 12       		.uleb128 0x12
 8885 01e4 01       		.uleb128 0x1
 8886 01e5 40       		.uleb128 0x40
 8887 01e6 0A       		.uleb128 0xa
 8888 01e7 01       		.uleb128 0x1
 8889 01e8 13       		.uleb128 0x13
 8890 01e9 00       		.byte	0x0
 8891 01ea 00       		.byte	0x0
 8892 01eb 22       		.uleb128 0x22
 8893 01ec 05       		.uleb128 0x5
 8894 01ed 00       		.byte	0x0
 8895 01ee 03       		.uleb128 0x3
 8896 01ef 0E       		.uleb128 0xe
 8897 01f0 49       		.uleb128 0x49
 8898 01f1 13       		.uleb128 0x13
 8899 01f2 34       		.uleb128 0x34
 8900 01f3 0C       		.uleb128 0xc
 8901 01f4 02       		.uleb128 0x2
 8902 01f5 06       		.uleb128 0x6
 8903 01f6 00       		.byte	0x0
 8904 01f7 00       		.byte	0x0
 8905 01f8 23       		.uleb128 0x23
 8906 01f9 13       		.uleb128 0x13
 8907 01fa 01       		.byte	0x1
 8908 01fb 03       		.uleb128 0x3
 8909 01fc 0E       		.uleb128 0xe
 8910 01fd 0B       		.uleb128 0xb
 8911 01fe 0B       		.uleb128 0xb
 8912 01ff 01       		.uleb128 0x1
 8913 0200 13       		.uleb128 0x13
 8914 0201 00       		.byte	0x0
 8915 0202 00       		.byte	0x0
 8916 0203 24       		.uleb128 0x24
 8917 0204 01       		.uleb128 0x1
 8918 0205 01       		.byte	0x1
 8919 0206 49       		.uleb128 0x49
 8920 0207 13       		.uleb128 0x13
 8921 0208 01       		.uleb128 0x1
 8922 0209 13       		.uleb128 0x13
 8923 020a 00       		.byte	0x0
GAS LISTING /tmp/ccK2IhnQ.s 			page 183


 8924 020b 00       		.byte	0x0
 8925 020c 25       		.uleb128 0x25
 8926 020d 21       		.uleb128 0x21
 8927 020e 00       		.byte	0x0
 8928 020f 49       		.uleb128 0x49
 8929 0210 13       		.uleb128 0x13
 8930 0211 2F       		.uleb128 0x2f
 8931 0212 0B       		.uleb128 0xb
 8932 0213 00       		.byte	0x0
 8933 0214 00       		.byte	0x0
 8934 0215 26       		.uleb128 0x26
 8935 0216 34       		.uleb128 0x34
 8936 0217 00       		.byte	0x0
 8937 0218 03       		.uleb128 0x3
 8938 0219 0E       		.uleb128 0xe
 8939 021a 3A       		.uleb128 0x3a
 8940 021b 0B       		.uleb128 0xb
 8941 021c 3B       		.uleb128 0x3b
 8942 021d 0B       		.uleb128 0xb
 8943 021e 49       		.uleb128 0x49
 8944 021f 13       		.uleb128 0x13
 8945 0220 02       		.uleb128 0x2
 8946 0221 0A       		.uleb128 0xa
 8947 0222 00       		.byte	0x0
 8948 0223 00       		.byte	0x0
 8949 0224 27       		.uleb128 0x27
 8950 0225 34       		.uleb128 0x34
 8951 0226 00       		.byte	0x0
 8952 0227 03       		.uleb128 0x3
 8953 0228 0E       		.uleb128 0xe
 8954 0229 3A       		.uleb128 0x3a
 8955 022a 0B       		.uleb128 0xb
 8956 022b 3B       		.uleb128 0x3b
 8957 022c 0B       		.uleb128 0xb
 8958 022d 49       		.uleb128 0x49
 8959 022e 13       		.uleb128 0x13
 8960 022f 3F       		.uleb128 0x3f
 8961 0230 0C       		.uleb128 0xc
 8962 0231 3C       		.uleb128 0x3c
 8963 0232 0C       		.uleb128 0xc
 8964 0233 00       		.byte	0x0
 8965 0234 00       		.byte	0x0
 8966 0235 28       		.uleb128 0x28
 8967 0236 21       		.uleb128 0x21
 8968 0237 00       		.byte	0x0
 8969 0238 49       		.uleb128 0x49
 8970 0239 13       		.uleb128 0x13
 8971 023a 2F       		.uleb128 0x2f
 8972 023b 05       		.uleb128 0x5
 8973 023c 00       		.byte	0x0
 8974 023d 00       		.byte	0x0
 8975 023e 29       		.uleb128 0x29
 8976 023f 34       		.uleb128 0x34
 8977 0240 00       		.byte	0x0
 8978 0241 03       		.uleb128 0x3
 8979 0242 0E       		.uleb128 0xe
 8980 0243 3A       		.uleb128 0x3a
GAS LISTING /tmp/ccK2IhnQ.s 			page 184


 8981 0244 0B       		.uleb128 0xb
 8982 0245 3B       		.uleb128 0x3b
 8983 0246 05       		.uleb128 0x5
 8984 0247 49       		.uleb128 0x49
 8985 0248 13       		.uleb128 0x13
 8986 0249 02       		.uleb128 0x2
 8987 024a 0A       		.uleb128 0xa
 8988 024b 00       		.byte	0x0
 8989 024c 00       		.byte	0x0
 8990 024d 2A       		.uleb128 0x2a
 8991 024e 34       		.uleb128 0x34
 8992 024f 00       		.byte	0x0
 8993 0250 03       		.uleb128 0x3
 8994 0251 0E       		.uleb128 0xe
 8995 0252 3A       		.uleb128 0x3a
 8996 0253 0B       		.uleb128 0xb
 8997 0254 3B       		.uleb128 0x3b
 8998 0255 05       		.uleb128 0x5
 8999 0256 49       		.uleb128 0x49
 9000 0257 13       		.uleb128 0x13
 9001 0258 3F       		.uleb128 0x3f
 9002 0259 0C       		.uleb128 0xc
 9003 025a 02       		.uleb128 0x2
 9004 025b 0A       		.uleb128 0xa
 9005 025c 00       		.byte	0x0
 9006 025d 00       		.byte	0x0
 9007 025e 00       		.byte	0x0
 9008              		.section	.debug_pubnames,"",@progbits
 9009 0000 3C020000 		.long	0x23c
 9010 0004 0200     		.value	0x2
 9011 0006 00000000 		.long	.Ldebug_info0
 9012 000a F70B0000 		.long	0xbf7
 9013 000e 44010000 		.long	0x144
 9014 0012 68656174 		.string	"heatmap_add_point_with_stamp"
 9014      6D61705F 
 9014      6164645F 
 9014      706F696E 
 9014      745F7769 
 9015 002f 37020000 		.long	0x237
 9016 0033 68656174 		.string	"heatmap_add_point"
 9016      6D61705F 
 9016      6164645F 
 9016      706F696E 
 9016      7400
 9017 0045 78020000 		.long	0x278
 9018 0049 68656174 		.string	"heatmap_add_weighted_point_with_stamp"
 9018      6D61705F 
 9018      6164645F 
 9018      77656967 
 9018      68746564 
 9019 006f 55030000 		.long	0x355
 9020 0073 68656174 		.string	"heatmap_add_weighted_point"
 9020      6D61705F 
 9020      6164645F 
 9020      77656967 
 9020      68746564 
 9021 008e D3030000 		.long	0x3d3
GAS LISTING /tmp/ccK2IhnQ.s 			page 185


 9022 0092 68656174 		.string	"heatmap_colorscheme_free"
 9022      6D61705F 
 9022      636F6C6F 
 9022      72736368 
 9022      656D655F 
 9023 00ab 09040000 		.long	0x409
 9024 00af 68656174 		.string	"heatmap_stamp_free"
 9024      6D61705F 
 9024      7374616D 
 9024      705F6672 
 9024      656500
 9025 00c2 3E040000 		.long	0x43e
 9026 00c6 68656174 		.string	"heatmap_free"
 9026      6D61705F 
 9026      66726565 
 9026      00
 9027 00d3 6B040000 		.long	0x46b
 9028 00d7 68656174 		.string	"heatmap_colorscheme_load"
 9028      6D61705F 
 9028      636F6C6F 
 9028      72736368 
 9028      656D655F 
 9029 00f0 D5040000 		.long	0x4d5
 9030 00f4 68656174 		.string	"heatmap_render_saturated_to"
 9030      6D61705F 
 9030      72656E64 
 9030      65725F73 
 9030      61747572 
 9031 0110 B8050000 		.long	0x5b8
 9032 0114 68656174 		.string	"heatmap_render_to"
 9032      6D61705F 
 9032      72656E64 
 9032      65725F74 
 9032      6F00
 9033 0126 01060000 		.long	0x601
 9034 012a 68656174 		.string	"heatmap_render_default_to"
 9034      6D61705F 
 9034      72656E64 
 9034      65725F64 
 9034      65666175 
 9035 0144 3F060000 		.long	0x63f
 9036 0148 68656174 		.string	"heatmap_stamp_init"
 9036      6D61705F 
 9036      7374616D 
 9036      705F696E 
 9036      697400
 9037 015b 94060000 		.long	0x694
 9038 015f 68656174 		.string	"heatmap_stamp_new_with"
 9038      6D61705F 
 9038      7374616D 
 9038      705F6E65 
 9038      775F7769 
 9039 0176 F5060000 		.long	0x6f5
 9040 017a 68656174 		.string	"heatmap_stamp_gen_nonlinear"
 9040      6D61705F 
 9040      7374616D 
 9040      705F6765 
GAS LISTING /tmp/ccK2IhnQ.s 			page 186


 9040      6E5F6E6F 
 9041 0196 DB070000 		.long	0x7db
 9042 019a 68656174 		.string	"heatmap_stamp_gen"
 9042      6D61705F 
 9042      7374616D 
 9042      705F6765 
 9042      6E00
 9043 01ac 0C080000 		.long	0x80c
 9044 01b0 68656174 		.string	"heatmap_stamp_load"
 9044      6D61705F 
 9044      7374616D 
 9044      705F6C6F 
 9044      616400
 9045 01c3 6D080000 		.long	0x86d
 9046 01c7 68656174 		.string	"heatmap_init"
 9046      6D61705F 
 9046      696E6974 
 9046      00
 9047 01d4 B5080000 		.long	0x8b5
 9048 01d8 68656174 		.string	"heatmap_new"
 9048      6D61705F 
 9048      6E657700 
 9049 01e4 400A0000 		.long	0xa40
 9050 01e8 68656174 		.string	"heatmap_add_points_omp_with_stamp"
 9050      6D61705F 
 9050      6164645F 
 9050      706F696E 
 9050      74735F6F 
 9051 020a 060B0000 		.long	0xb06
 9052 020e 68656174 		.string	"heatmap_add_points_omp"
 9052      6D61705F 
 9052      6164645F 
 9052      706F696E 
 9052      74735F6F 
 9053 0225 DF0B0000 		.long	0xbdf
 9054 0229 68656174 		.string	"heatmap_cs_default"
 9054      6D61705F 
 9054      63735F64 
 9054      65666175 
 9054      6C7400
 9055 023c 00000000 		.long	0x0
 9056              		.section	.debug_pubtypes,"",@progbits
 9057 0000 68000000 		.long	0x68
 9058 0004 0200     		.value	0x2
 9059 0006 00000000 		.long	.Ldebug_info0
 9060 000a F70B0000 		.long	0xbf7
 9061 000e 34000000 		.long	0x34
 9062 0012 73697A65 		.string	"size_t"
 9062      5F7400
 9063 0019 96000000 		.long	0x96
 9064 001d 68656174 		.string	"heatmap_t"
 9064      6D61705F 
 9064      7400
 9065 0027 CA000000 		.long	0xca
 9066 002b 68656174 		.string	"heatmap_stamp_t"
 9066      6D61705F 
 9066      7374616D 
GAS LISTING /tmp/ccK2IhnQ.s 			page 187


 9066      705F7400 
 9067 003b 08010000 		.long	0x108
 9068 003f 68656174 		.string	"heatmap_colorscheme_t"
 9068      6D61705F 
 9068      636F6C6F 
 9068      72736368 
 9068      656D655F 
 9069 0055 CF090000 		.long	0x9cf
 9070 0059 2E6F6D70 		.string	".omp_data_s.21"
 9070      5F646174 
 9070      615F732E 
 9070      323100
 9071 0068 00000000 		.long	0x0
 9072              		.section	.debug_aranges,"",@progbits
 9073 0000 2C000000 		.long	0x2c
 9074 0004 0200     		.value	0x2
 9075 0006 00000000 		.long	.Ldebug_info0
 9076 000a 08       		.byte	0x8
 9077 000b 00       		.byte	0x0
 9078 000c 0000     		.value	0x0
 9079 000e 0000     		.value	0x0
 9080 0010 00000000 		.quad	.Ltext0
 9080      00000000 
 9081 0018 2C0A0000 		.quad	.Letext0-.Ltext0
 9081      00000000 
 9082 0020 00000000 		.quad	0x0
 9082      00000000 
 9083 0028 00000000 		.quad	0x0
 9083      00000000 
 9084              		.section	.debug_ranges,"",@progbits
 9085              	.Ldebug_ranges0:
 9086 0000 24000000 		.quad	.LBB2-.Ltext0
 9086      00000000 
 9087 0008 0F010000 		.quad	.LBE2-.Ltext0
 9087      00000000 
 9088 0010 1A010000 		.quad	.LBB5-.Ltext0
 9088      00000000 
 9089 0018 25010000 		.quad	.LBE5-.Ltext0
 9089      00000000 
 9090 0020 00000000 		.quad	0x0
 9090      00000000 
 9091 0028 00000000 		.quad	0x0
 9091      00000000 
 9092 0030 82000000 		.quad	.LBB4-.Ltext0
 9092      00000000 
 9093 0038 85000000 		.quad	.LBE4-.Ltext0
 9093      00000000 
 9094 0040 9C000000 		.quad	.LBB3-.Ltext0
 9094      00000000 
 9095 0048 03010000 		.quad	.LBE3-.Ltext0
 9095      00000000 
 9096 0050 00000000 		.quad	0x0
 9096      00000000 
 9097 0058 00000000 		.quad	0x0
 9097      00000000 
 9098 0060 64010000 		.quad	.LBB6-.Ltext0
 9098      00000000 
GAS LISTING /tmp/ccK2IhnQ.s 			page 188


 9099 0068 53020000 		.quad	.LBE6-.Ltext0
 9099      00000000 
 9100 0070 5E020000 		.quad	.LBB9-.Ltext0
 9100      00000000 
 9101 0078 69020000 		.quad	.LBE9-.Ltext0
 9101      00000000 
 9102 0080 00000000 		.quad	0x0
 9102      00000000 
 9103 0088 00000000 		.quad	0x0
 9103      00000000 
 9104 0090 C2010000 		.quad	.LBB8-.Ltext0
 9104      00000000 
 9105 0098 C5010000 		.quad	.LBE8-.Ltext0
 9105      00000000 
 9106 00a0 DC010000 		.quad	.LBB7-.Ltext0
 9106      00000000 
 9107 00a8 47020000 		.quad	.LBE7-.Ltext0
 9107      00000000 
 9108 00b0 00000000 		.quad	0x0
 9108      00000000 
 9109 00b8 00000000 		.quad	0x0
 9109      00000000 
 9110 00c0 C8030000 		.quad	.LBB11-.Ltext0
 9110      00000000 
 9111 00c8 E8030000 		.quad	.LBE11-.Ltext0
 9111      00000000 
 9112 00d0 3C040000 		.quad	.LBB15-.Ltext0
 9112      00000000 
 9113 00d8 90040000 		.quad	.LBE15-.Ltext0
 9113      00000000 
 9114 00e0 31040000 		.quad	.LBB14-.Ltext0
 9114      00000000 
 9115 00e8 38040000 		.quad	.LBE14-.Ltext0
 9115      00000000 
 9116 00f0 24040000 		.quad	.LBB13-.Ltext0
 9116      00000000 
 9117 00f8 29040000 		.quad	.LBE13-.Ltext0
 9117      00000000 
 9118 0100 10040000 		.quad	.LBB12-.Ltext0
 9118      00000000 
 9119 0108 1C040000 		.quad	.LBE12-.Ltext0
 9119      00000000 
 9120 0110 00000000 		.quad	0x0
 9120      00000000 
 9121 0118 00000000 		.quad	0x0
 9121      00000000 
 9122 0120 EF050000 		.quad	.LBB17-.Ltext0
 9122      00000000 
 9123 0128 00060000 		.quad	.LBE17-.Ltext0
 9123      00000000 
 9124 0130 68060000 		.quad	.LBB20-.Ltext0
 9124      00000000 
 9125 0138 6D060000 		.quad	.LBE20-.Ltext0
 9125      00000000 
 9126 0140 61060000 		.quad	.LBB19-.Ltext0
 9126      00000000 
 9127 0148 65060000 		.quad	.LBE19-.Ltext0
GAS LISTING /tmp/ccK2IhnQ.s 			page 189


 9127      00000000 
 9128 0150 29060000 		.quad	.LBB18-.Ltext0
 9128      00000000 
 9129 0158 5D060000 		.quad	.LBE18-.Ltext0
 9129      00000000 
 9130 0160 00000000 		.quad	0x0
 9130      00000000 
 9131 0168 00000000 		.quad	0x0
 9131      00000000 
 9132              		.section	.debug_str,"MS",@progbits,1
 9133              	.LASF8:
 9134 0000 6E636F6C 		.string	"ncolors"
 9134      6F727300 
 9135              	.LASF4:
 9136 0008 73697A65 		.string	"size_t"
 9136      5F7400
 9137              	.LASF58:
 9138 000f 6D697865 		.string	"mixed_data"
 9138      645F6461 
 9138      746100
 9139              	.LASF30:
 9140 001a 68656174 		.string	"heatmap_colorscheme_load"
 9140      6D61705F 
 9140      636F6C6F 
 9140      72736368 
 9140      656D655F 
 9141              	.LASF16:
 9142 0033 6C6F6E67 		.string	"long long unsigned int"
 9142      206C6F6E 
 9142      6720756E 
 9142      7369676E 
 9142      65642069 
 9143              	.LASF23:
 9144 004a 68656174 		.string	"heatmap_add_weighted_point_with_stamp"
 9144      6D61705F 
 9144      6164645F 
 9144      77656967 
 9144      68746564 
 9145              	.LASF38:
 9146 0070 68656174 		.string	"heatmap_render_default_to"
 9146      6D61705F 
 9146      72656E64 
 9146      65725F64 
 9146      65666175 
 9147              	.LASF60:
 9148 008a 68656174 		.string	"heatmap_cs_default"
 9148      6D61705F 
 9148      63735F64 
 9148      65666175 
 9148      6C7400
 9149              	.LASF11:
 9150 009d 6C6F6E67 		.string	"long long int"
 9150      206C6F6E 
 9150      6720696E 
 9150      7400
 9151              	.LASF13:
 9152 00ab 7369676E 		.string	"signed char"
GAS LISTING /tmp/ccK2IhnQ.s 			page 190


 9152      65642063 
 9152      68617200 
 9153              	.LASF50:
 9154 00b7 6C6F6361 		.string	"local_heatmap"
 9154      6C5F6865 
 9154      61746D61 
 9154      7000
 9155              	.LASF34:
 9156 00c5 636F6C6F 		.string	"colorbuf"
 9156      72627566 
 9156      00
 9157              	.LASF0:
 9158 00ce 6C6F6E67 		.string	"long int"
 9158      20696E74 
 9158      00
 9159              	.LASF62:
 9160 00d7 68656174 		.string	"heatmap_block.c"
 9160      6D61705F 
 9160      626C6F63 
 9160      6B2E6300 
 9161              	.LASF39:
 9162 00e7 68656174 		.string	"heatmap_stamp_init"
 9162      6D61705F 
 9162      7374616D 
 9162      705F696E 
 9162      697400
 9163              	.LASF17:
 9164 00fa 646F7562 		.string	"double"
 9164      6C6500
 9165              	.LASF27:
 9166 0101 68656174 		.string	"heatmap_stamp_free"
 9166      6D61705F 
 9166      7374616D 
 9166      705F6672 
 9166      656500
 9167              	.LASF19:
 9168 0114 6C696E65 		.string	"line"
 9168      00
 9169              	.LASF10:
 9170 0119 68656174 		.string	"heatmap_colorscheme_t"
 9170      6D61705F 
 9170      636F6C6F 
 9170      72736368 
 9170      656D655F 
 9171              	.LASF18:
 9172 012f 7374616D 		.string	"stamp"
 9172      7000
 9173              	.LASF36:
 9174 0135 636F6C6F 		.string	"colorline"
 9174      726C696E 
 9174      6500
 9175              	.LASF3:
 9176 013f 756E7369 		.string	"unsigned int"
 9176      676E6564 
 9176      20696E74 
 9176      00
 9177              	.LASF56:
GAS LISTING /tmp/ccK2IhnQ.s 			page 191


 9178 014c 7374616D 		.string	"stamp_default_4_data"
 9178      705F6465 
 9178      6661756C 
 9178      745F345F 
 9178      64617461 
 9179              	.LASF1:
 9180 0161 6C6F6E67 		.string	"long unsigned int"
 9180      20756E73 
 9180      69676E65 
 9180      6420696E 
 9180      7400
 9181              	.LASF45:
 9182 0173 68656174 		.string	"heatmap_stamp_gen"
 9182      6D61705F 
 9182      7374616D 
 9182      705F6765 
 9182      6E00
 9183              	.LASF52:
 9184 0185 6E756D5F 		.string	"num_points"
 9184      706F696E 
 9184      747300
 9185              	.LASF57:
 9186 0190 7374616D 		.string	"stamp_default_4"
 9186      705F6465 
 9186      6661756C 
 9186      745F3400 
 9187              	.LASF40:
 9188 01a0 64617461 		.string	"data"
 9188      00
 9189              	.LASF12:
 9190 01a5 73686F72 		.string	"short unsigned int"
 9190      7420756E 
 9190      7369676E 
 9190      65642069 
 9190      6E7400
 9191              	.LASF64:
 9192 01b8 6C696E65 		.string	"linear_dist"
 9192      61725F64 
 9192      69737400 
 9193              	.LASF35:
 9194 01c4 6275666C 		.string	"bufline"
 9194      696E6500 
 9195              	.LASF24:
 9196 01cc 68656174 		.string	"heatmap_add_weighted_point"
 9196      6D61705F 
 9196      6164645F 
 9196      77656967 
 9196      68746564 
 9197              	.LASF55:
 9198 01e7 68656174 		.string	"heatmap_add_points_omp"
 9198      6D61705F 
 9198      6164645F 
 9198      706F696E 
 9198      74735F6F 
 9199              	.LASF47:
 9200 01fe 636F7079 		.string	"copy"
 9200      00
GAS LISTING /tmp/ccK2IhnQ.s 			page 192


 9201              	.LASF51:
 9202 0203 626C6F63 		.string	"block_length"
 9202      6B5F6C65 
 9202      6E677468 
 9202      00
 9203              	.LASF21:
 9204 0210 68656174 		.string	"heatmap_add_point_with_stamp"
 9204      6D61705F 
 9204      6164645F 
 9204      706F696E 
 9204      745F7769 
 9205              	.LASF63:
 9206 022d 2F686F6D 		.string	"/home/hshu1/15618/project/15618fp/heatmap"
 9206      652F6873 
 9206      6875312F 
 9206      31353631 
 9206      382F7072 
 9207              	.LASF54:
 9208 0257 68656174 		.string	"heatmap_add_points_omp_with_stamp"
 9208      6D61705F 
 9208      6164645F 
 9208      706F696E 
 9208      74735F6F 
 9209              	.LASF7:
 9210 0279 636F6C6F 		.string	"colors"
 9210      727300
 9211              	.LASF20:
 9212 0280 7374616D 		.string	"stampline"
 9212      706C696E 
 9212      6500
 9213              	.LASF2:
 9214 028a 666C6F61 		.string	"float"
 9214      7400
 9215              	.LASF31:
 9216 0290 68656174 		.string	"heatmap_render_saturated_to"
 9216      6D61705F 
 9216      72656E64 
 9216      65725F73 
 9216      61747572 
 9217              	.LASF22:
 9218 02ac 68656174 		.string	"heatmap_add_point"
 9218      6D61705F 
 9218      6164645F 
 9218      706F696E 
 9218      7400
 9219              	.LASF46:
 9220 02be 68656174 		.string	"heatmap_stamp_load"
 9220      6D61705F 
 9220      7374616D 
 9220      705F6C6F 
 9220      616400
 9221              	.LASF9:
 9222 02d1 756E7369 		.string	"unsigned char"
 9222      676E6564 
 9222      20636861 
 9222      7200
 9223              	.LASF14:
GAS LISTING /tmp/ccK2IhnQ.s 			page 193


 9224 02df 73686F72 		.string	"short int"
 9224      7420696E 
 9224      7400
 9225              	.LASF65:
 9226 02e9 68656174 		.string	"heatmap_add_points_omp_with_stamp.omp_fn.0"
 9226      6D61705F 
 9226      6164645F 
 9226      706F696E 
 9226      74735F6F 
 9227              	.LASF44:
 9228 0314 636C616D 		.string	"clamped_ds"
 9228      7065645F 
 9228      647300
 9229              	.LASF29:
 9230 031f 696E5F63 		.string	"in_colors"
 9230      6F6C6F72 
 9230      7300
 9231              	.LASF26:
 9232 0329 68656174 		.string	"heatmap_colorscheme_free"
 9232      6D61705F 
 9232      636F6C6F 
 9232      72736368 
 9232      656D655F 
 9233              	.LASF48:
 9234 0342 68656174 		.string	"heatmap_init"
 9234      6D61705F 
 9234      696E6974 
 9234      00
 9235              	.LASF61:
 9236 034f 474E5520 		.string	"GNU C 4.4.7 20120313 (Red Hat 4.4.7-4)"
 9236      4320342E 
 9236      342E3720 
 9236      32303132 
 9236      30333133 
 9237              	.LASF15:
 9238 0376 63686172 		.string	"char"
 9238      00
 9239              	.LASF28:
 9240 037b 68656174 		.string	"heatmap_free"
 9240      6D61705F 
 9240      66726565 
 9240      00
 9241              	.LASF66:
 9242 0388 2E6F6D70 		.string	".omp_data_i"
 9242      5F646174 
 9242      615F6900 
 9243              	.LASF6:
 9244 0394 68656174 		.string	"heatmap_stamp_t"
 9244      6D61705F 
 9244      7374616D 
 9244      705F7400 
 9245              	.LASF49:
 9246 03a4 68656174 		.string	"heatmap_new"
 9246      6D61705F 
 9246      6E657700 
 9247              	.LASF25:
 9248 03b0 64697374 		.string	"dist"
GAS LISTING /tmp/ccK2IhnQ.s 			page 194


 9248      00
 9249              	.LASF37:
 9250 03b5 68656174 		.string	"heatmap_render_to"
 9250      6D61705F 
 9250      72656E64 
 9250      65725F74 
 9250      6F00
 9251              	.LASF42:
 9252 03c7 68656174 		.string	"heatmap_stamp_gen_nonlinear"
 9252      6D61705F 
 9252      7374616D 
 9252      705F6765 
 9252      6E5F6E6F 
 9253              	.LASF67:
 9254 03e3 2E6F6D70 		.string	".omp_data_s.21"
 9254      5F646174 
 9254      615F732E 
 9254      323100
 9255              	.LASF41:
 9256 03f2 68656174 		.string	"heatmap_stamp_new_with"
 9256      6D61705F 
 9256      7374616D 
 9256      705F6E65 
 9256      775F7769 
 9257              	.LASF5:
 9258 0409 68656174 		.string	"heatmap_t"
 9258      6D61705F 
 9258      7400
 9259              	.LASF33:
 9260 0413 73617475 		.string	"saturation"
 9260      72617469 
 9260      6F6E00
 9261              	.LASF32:
 9262 041e 636F6C6F 		.string	"colorscheme"
 9262      72736368 
 9262      656D6500 
 9263              	.LASF43:
 9264 042a 64697374 		.string	"distshape"
 9264      73686170 
 9264      6500
 9265              	.LASF53:
 9266 0434 73746172 		.string	"start"
 9266      7400
 9267              	.LASF59:
 9268 043a 63735F73 		.string	"cs_spectral_mixed"
 9268      70656374 
 9268      72616C5F 
 9268      6D697865 
 9268      6400
 9269              		.ident	"GCC: (GNU) 4.4.7 20120313 (Red Hat 4.4.7-4)"
 9270              		.section	.note.GNU-stack,"",@progbits
