GAS LISTING /tmp/ccOaNtkH.s 			page 1


   1              		.file	"heatmap_block.c"
   2              		.section	.debug_abbrev,"",@progbits
   3              	.Ldebug_abbrev0:
   4              		.section	.debug_info,"",@progbits
   5              	.Ldebug_info0:
   6              		.section	.debug_line,"",@progbits
   7              	.Ldebug_line0:
   8 0000 2D020000 		.text
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
  32:heatmap_block.c **** #define NUM_OF_BLOCKS 32
  33:heatmap_block.c **** 
  34:heatmap_block.c **** /* Having a default stamp ready makes it easier for simple usage of the library
  35:heatmap_block.c ****  * since there is no need to create a new stamp.
  36:heatmap_block.c ****  */
  37:heatmap_block.c **** static float stamp_default_4_data[] = {
GAS LISTING /tmp/ccOaNtkH.s 			page 2


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
GAS LISTING /tmp/ccOaNtkH.s 			page 3


  95:heatmap_block.c ****         unsigned i;
  96:heatmap_block.c ****         for (i = start; i < end; i++)
  97:heatmap_block.c ****         {
  98:heatmap_block.c ****             heatmap_add_weighted_point_with_stamp(local_heatmap + idx, xs[i], ys[i], 1.0, stamp);
  99:heatmap_block.c ****             // local_heatmap[idx].buf[ys[i] * h->w + xs[i]] += 1.0;
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
 115:heatmap_block.c **** /*
 116:heatmap_block.c ****             if (w > 0)
 117:heatmap_block.c ****             {
 118:heatmap_block.c ****                 heatmap_add_weighted_point_with_stamp(h, x, y, w, stamp);
 119:heatmap_block.c ****             }
 120:heatmap_block.c **** */
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
GAS LISTING /tmp/ccOaNtkH.s 			page 4


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
GAS LISTING /tmp/ccOaNtkH.s 			page 5


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
GAS LISTING /tmp/ccOaNtkH.s 			page 6


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
GAS LISTING /tmp/ccOaNtkH.s 			page 7


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
GAS LISTING /tmp/ccOaNtkH.s 			page 8


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
GAS LISTING /tmp/ccOaNtkH.s 			page 9


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
GAS LISTING /tmp/ccOaNtkH.s 			page 10


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
GAS LISTING /tmp/ccOaNtkH.s 			page 11


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
GAS LISTING /tmp/ccOaNtkH.s 			page 12


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
GAS LISTING /tmp/ccOaNtkH.s 			page 13


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
GAS LISTING /tmp/ccOaNtkH.s 			page 14


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
GAS LISTING /tmp/ccOaNtkH.s 			page 15


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
GAS LISTING /tmp/ccOaNtkH.s 			page 16


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
GAS LISTING /tmp/ccOaNtkH.s 			page 17


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
GAS LISTING /tmp/ccOaNtkH.s 			page 18


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
GAS LISTING /tmp/ccOaNtkH.s 			page 19


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
GAS LISTING /tmp/ccOaNtkH.s 			page 20


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
GAS LISTING /tmp/ccOaNtkH.s 			page 21


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
GAS LISTING /tmp/ccOaNtkH.s 			page 22


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
GAS LISTING /tmp/ccOaNtkH.s 			page 23


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
GAS LISTING /tmp/ccOaNtkH.s 			page 24


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
GAS LISTING /tmp/ccOaNtkH.s 			page 25


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
GAS LISTING /tmp/ccOaNtkH.s 			page 26


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
GAS LISTING /tmp/ccOaNtkH.s 			page 27


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
GAS LISTING /tmp/ccOaNtkH.s 			page 28


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
GAS LISTING /tmp/ccOaNtkH.s 			page 29


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
GAS LISTING /tmp/ccOaNtkH.s 			page 30


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
GAS LISTING /tmp/ccOaNtkH.s 			page 31


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
GAS LISTING /tmp/ccOaNtkH.s 			page 32


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
GAS LISTING /tmp/ccOaNtkH.s 			page 33


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
GAS LISTING /tmp/ccOaNtkH.s 			page 34


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
GAS LISTING /tmp/ccOaNtkH.s 			page 35


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
GAS LISTING /tmp/ccOaNtkH.s 			page 36


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
 1297 07fd 448B672C 		movl	44(%rdi), %r12d
 1298              	.LVL134:
 1299              	.LBB21:
  90:heatmap_block.c ****         int idx = omp_get_thread_num();
 1300              		.loc 1 90 0
 1301 0801 E8000000 		call	omp_get_thread_num@PLT
 1301      00
 1302              	.LVL135:
  91:heatmap_block.c ****         unsigned start = idx * block_length;
 1303              		.loc 1 91 0
 1304 0806 89C5     		movl	%eax, %ebp
  92:heatmap_block.c ****         unsigned end = start + block_length <= num_points ? start + block_length : num_points;
 1305              		.loc 1 92 0
 1306 0808 8B5328   		movl	40(%rbx), %edx
  94:heatmap_block.c ****         heatmap_init(&local_heatmap[idx], h->w, h->h);
 1307              		.loc 1 94 0
 1308 080b 488B0B   		movq	(%rbx), %rcx
  91:heatmap_block.c ****         unsigned start = idx * block_length;
 1309              		.loc 1 91 0
 1310 080e 410FAFEC 		imull	%r12d, %ebp
GAS LISTING /tmp/ccOaNtkH.s 			page 37


 1311              	.LVL136:
  94:heatmap_block.c ****         heatmap_init(&local_heatmap[idx], h->w, h->h);
 1312              		.loc 1 94 0
 1313 0812 4898     		cltq
 1314 0814 488B7B20 		movq	32(%rbx), %rdi
 1315 0818 4C8D2C40 		leaq	(%rax,%rax,2), %r13
 1316 081c 8B710C   		movl	12(%rcx), %esi
  92:heatmap_block.c ****         unsigned end = start + block_length <= num_points ? start + block_length : num_points;
 1317              		.loc 1 92 0
 1318 081f 468D6425 		leal	0(%rbp,%r12), %r12d
 1318      00
 1319              	.LVL137:
 1320 0824 4139D4   		cmpl	%edx, %r12d
 1321 0827 440F47E2 		cmova	%edx, %r12d
 1322              	.LVL138:
  94:heatmap_block.c ****         heatmap_init(&local_heatmap[idx], h->w, h->h);
 1323              		.loc 1 94 0
 1324 082b 8B5110   		movl	16(%rcx), %edx
 1325 082e 49C1E503 		salq	$3, %r13
 1326 0832 4C01EF   		addq	%r13, %rdi
 1327 0835 E8000000 		call	heatmap_init@PLT
 1327      00
 1328              	.LVL139:
  97:heatmap_block.c ****         for (i = start; i < end; i++)
 1329              		.loc 1 97 0
 1330 083a 4439E5   		cmpl	%r12d, %ebp
 1331 083d 7331     		jae	.L117
 1332              	.LVL140:
 1333 083f 90       		.p2align 4,,10
 1334              		.p2align 3
 1335              	.L118:
  99:heatmap_block.c ****             heatmap_add_weighted_point_with_stamp(local_heatmap + idx, xs[i], ys[i], 1.0, stamp);
 1336              		.loc 1 99 0
 1337 0840 488B5310 		movq	16(%rbx), %rdx
 1338 0844 488B7308 		movq	8(%rbx), %rsi
 1339 0848 89E8     		mov	%ebp, %eax
 1340 084a 488B7B20 		movq	32(%rbx), %rdi
 1341 084e 488B4B18 		movq	24(%rbx), %rcx
  97:heatmap_block.c ****         for (i = start; i < end; i++)
 1342              		.loc 1 97 0
 1343 0852 83C501   		addl	$1, %ebp
 1344              	.LVL141:
  99:heatmap_block.c ****             heatmap_add_weighted_point_with_stamp(local_heatmap + idx, xs[i], ys[i], 1.0, stamp);
 1345              		.loc 1 99 0
 1346 0855 F30F1005 		movss	.LC3(%rip), %xmm0
 1346      00000000 
 1347 085d 8B1482   		movl	(%rdx,%rax,4), %edx
 1348 0860 8B3486   		movl	(%rsi,%rax,4), %esi
 1349 0863 4C01EF   		addq	%r13, %rdi
 1350 0866 E8000000 		call	heatmap_add_weighted_point_with_stamp@PLT
 1350      00
 1351              	.LVL142:
  97:heatmap_block.c ****         for (i = start; i < end; i++)
 1352              		.loc 1 97 0
 1353 086b 4139EC   		cmpl	%ebp, %r12d
 1354 086e 77D0     		ja	.L118
 1355              	.L117:
GAS LISTING /tmp/ccOaNtkH.s 			page 38


 1356              	.LBE21:
  88:heatmap_block.c ****     #pragma omp parallel
 1357              		.loc 1 88 0
 1358 0870 4883C408 		addq	$8, %rsp
 1359              		.cfi_def_cfa_offset 40
 1360 0874 5B       		popq	%rbx
 1361              		.cfi_def_cfa_offset 32
 1362              	.LVL143:
 1363 0875 5D       		popq	%rbp
 1364              		.cfi_def_cfa_offset 24
 1365              	.LVL144:
 1366 0876 415C     		popq	%r12
 1367              		.cfi_def_cfa_offset 16
 1368              	.LVL145:
 1369 0878 415D     		popq	%r13
 1370              		.cfi_def_cfa_offset 8
 1371 087a C3       		ret
 1372              		.cfi_endproc
 1373              	.LFE43:
 1374              		.size	heatmap_add_points_omp_with_stamp.omp_fn.0, .-heatmap_add_points_omp_with_stamp.omp_fn.0
 1375 087b 0F1F4400 		.p2align 4,,15
 1375      00
 1376              	.globl heatmap_add_points_omp_with_stamp
 1377              		.type	heatmap_add_points_omp_with_stamp, @function
 1378              	heatmap_add_points_omp_with_stamp:
 1379              	.LFB26:
  82:heatmap_block.c **** {
 1380              		.loc 1 82 0
 1381              		.cfi_startproc
 1382              	.LVL146:
 1383 0880 53       		pushq	%rbx
 1384              		.cfi_def_cfa_offset 16
 1385              		.cfi_offset 3, -16
 1386 0881 4889FB   		movq	%rdi, %rbx
  87:heatmap_block.c ****     omp_set_num_threads(NUM_OF_BLOCKS);
 1387              		.loc 1 87 0
 1388 0884 BF200000 		movl	$32, %edi
 1388      00
 1389              	.LVL147:
  82:heatmap_block.c **** {
 1390              		.loc 1 82 0
 1391 0889 4881EC50 		subq	$848, %rsp
 1391      030000
 1392              		.cfi_def_cfa_offset 864
  87:heatmap_block.c ****     omp_set_num_threads(NUM_OF_BLOCKS);
 1393              		.loc 1 87 0
 1394 0890 48895424 		movq	%rdx, 16(%rsp)
 1394      10
 1395 0895 894C2408 		movl	%ecx, 8(%rsp)
 1396 0899 48897424 		movq	%rsi, 24(%rsp)
 1396      18
 1397 089e 4C890424 		movq	%r8, (%rsp)
 1398 08a2 E8000000 		call	omp_set_num_threads@PLT
 1398      00
 1399              	.LVL148:
  88:heatmap_block.c ****     #pragma omp parallel
 1400              		.loc 1 88 0
GAS LISTING /tmp/ccOaNtkH.s 			page 39


 1401 08a7 8B4C2408 		movl	8(%rsp), %ecx
 1402 08ab 488B7424 		movq	24(%rsp), %rsi
 1402      18
 1403 08b0 488D3D39 		leaq	heatmap_add_points_omp_with_stamp.omp_fn.0(%rip), %rdi
 1403      FFFFFF
 1404 08b7 488B5424 		movq	16(%rsp), %rdx
 1404      10
 1405 08bc 4C8B0424 		movq	(%rsp), %r8
 1406 08c0 48899C24 		movq	%rbx, 800(%rsp)
 1406      20030000 
 1407 08c8 488D9C24 		leaq	800(%rsp), %rbx
 1407      20030000 
 1408              	.LVL149:
 1409 08d0 8D411F   		leal	31(%rcx), %eax
 1410 08d3 4889B424 		movq	%rsi, 808(%rsp)
 1410      28030000 
 1411 08db 898C2448 		movl	%ecx, 840(%rsp)
 1411      030000
 1412 08e2 4889DE   		movq	%rbx, %rsi
 1413 08e5 48899424 		movq	%rdx, 816(%rsp)
 1413      30030000 
 1414 08ed 31D2     		xorl	%edx, %edx
 1415 08ef C1E805   		shrl	$5, %eax
 1416 08f2 4C898424 		movq	%r8, 824(%rsp)
 1416      38030000 
 1417 08fa 8984244C 		movl	%eax, 844(%rsp)
 1417      030000
 1418 0901 488D4424 		leaq	32(%rsp), %rax
 1418      20
 1419 0906 48898424 		movq	%rax, 832(%rsp)
 1419      40030000 
 1420 090e E8000000 		call	GOMP_parallel_start@PLT
 1420      00
 1421              	.LVL150:
 1422 0913 4889DF   		movq	%rbx, %rdi
 1423 0916 E8D5FEFF 		call	heatmap_add_points_omp_with_stamp.omp_fn.0
 1423      FF
 1424 091b E8000000 		call	GOMP_parallel_end@PLT
 1424      00
 1425              	.LVL151:
 124:heatmap_block.c **** }
 1426              		.loc 1 124 0
 1427 0920 4881C450 		addq	$848, %rsp
 1427      030000
 1428              		.cfi_def_cfa_offset 16
 1429 0927 5B       		popq	%rbx
 1430              		.cfi_def_cfa_offset 8
 1431              	.LVL152:
 1432 0928 C3       		ret
 1433              		.cfi_endproc
 1434              	.LFE26:
 1435              		.size	heatmap_add_points_omp_with_stamp, .-heatmap_add_points_omp_with_stamp
 1436 0929 0F1F8000 		.p2align 4,,15
 1436      000000
 1437              	.globl heatmap_add_points_omp
 1438              		.type	heatmap_add_points_omp, @function
 1439              	heatmap_add_points_omp:
GAS LISTING /tmp/ccOaNtkH.s 			page 40


 1440              	.LFB25:
  77:heatmap_block.c **** {
 1441              		.loc 1 77 0
 1442              		.cfi_startproc
 1443              	.LVL153:
  78:heatmap_block.c ****     heatmap_add_points_omp_with_stamp(h, xs, ys, num_points, &stamp_default_4);
 1444              		.loc 1 78 0
 1445 0930 4C8D0500 		leaq	stamp_default_4(%rip), %r8
 1445      000000
 1446 0937 E9000000 		jmp	heatmap_add_points_omp_with_stamp@PLT
 1446      00
 1447              		.cfi_endproc
 1448              	.LFE25:
 1449              		.size	heatmap_add_points_omp, .-heatmap_add_points_omp
 1450              	.globl heatmap_cs_default
 1451              		.section	.data.rel.local,"aw",@progbits
 1452              		.align 8
 1453              		.type	heatmap_cs_default, @object
 1454              		.size	heatmap_cs_default, 8
 1455              	heatmap_cs_default:
 1456 0000 00000000 		.quad	cs_spectral_mixed
 1456      00000000 
 1457 0008 00000000 		.align 16
 1457      00000000 
 1458              		.type	stamp_default_4, @object
 1459              		.size	stamp_default_4, 16
 1460              	stamp_default_4:
 1461 0010 00000000 		.quad	stamp_default_4_data
 1461      00000000 
 1462 0018 09000000 		.long	9
 1463 001c 09000000 		.long	9
 1464              		.section	.data.rel.ro.local,"aw",@progbits
 1465              		.align 16
 1466              		.type	cs_spectral_mixed, @object
 1467              		.size	cs_spectral_mixed, 16
 1468              	cs_spectral_mixed:
 1469 0000 00000000 		.quad	mixed_data
 1469      00000000 
 1470 0008 01040000 		.quad	1025
 1470      00000000 
 1471              		.data
 1472              		.align 32
 1473              		.type	stamp_default_4_data, @object
 1474              		.size	stamp_default_4_data, 324
 1475              	stamp_default_4_data:
 1476 0000 00000000 		.long	0
 1477 0004 00000000 		.long	0
 1478 0008 8D36D83D 		.long	1037579917
 1479 000c 8796333E 		.long	1043568263
 1480 0010 CDCC4C3E 		.long	1045220557
 1481 0014 8796333E 		.long	1043568263
 1482 0018 8D36D83D 		.long	1037579917
 1483 001c 00000000 		.long	0
 1484 0020 00000000 		.long	0
 1485 0024 00000000 		.long	0
 1486 0028 731B1B3E 		.long	1041963891
 1487 002c A1CA8E3E 		.long	1049545377
GAS LISTING /tmp/ccOaNtkH.s 			page 41


 1488 0030 CB2EBC3E 		.long	1052520139
 1489 0034 CDCCCC3E 		.long	1053609165
 1490 0038 CB2EBC3E 		.long	1052520139
 1491 003c A1CA8E3E 		.long	1049545377
 1492 0040 731B1B3E 		.long	1041963891
 1493 0044 00000000 		.long	0
 1494 0048 8D36D83D 		.long	1037579917
 1495 004c A1CA8E3E 		.long	1049545377
 1496 0050 7C5EDE3E 		.long	1054760572
 1497 0054 69830D3F 		.long	1057850217
 1498 0058 9A99193F 		.long	1058642330
 1499 005c 69830D3F 		.long	1057850217
 1500 0060 7C5EDE3E 		.long	1054760572
 1501 0064 A1CA8E3E 		.long	1049545377
 1502 0068 8D36D83D 		.long	1037579917
 1503 006c 8796333E 		.long	1043568263
 1504 0070 CB2EBC3E 		.long	1052520139
 1505 0074 69830D3F 		.long	1057850217
 1506 0078 9F97373F 		.long	1060607903
 1507 007c CDCC4C3F 		.long	1061997773
 1508 0080 9F97373F 		.long	1060607903
 1509 0084 69830D3F 		.long	1057850217
 1510 0088 CB2EBC3E 		.long	1052520139
 1511 008c 8796333E 		.long	1043568263
 1512 0090 CDCC4C3E 		.long	1045220557
 1513 0094 CDCCCC3E 		.long	1053609165
 1514 0098 9A99193F 		.long	1058642330
 1515 009c CDCC4C3F 		.long	1061997773
 1516 00a0 0000803F 		.long	1065353216
 1517 00a4 CDCC4C3F 		.long	1061997773
 1518 00a8 9A99193F 		.long	1058642330
 1519 00ac CDCCCC3E 		.long	1053609165
 1520 00b0 CDCC4C3E 		.long	1045220557
 1521 00b4 8796333E 		.long	1043568263
 1522 00b8 CB2EBC3E 		.long	1052520139
 1523 00bc 69830D3F 		.long	1057850217
 1524 00c0 9F97373F 		.long	1060607903
 1525 00c4 CDCC4C3F 		.long	1061997773
 1526 00c8 9F97373F 		.long	1060607903
 1527 00cc 69830D3F 		.long	1057850217
 1528 00d0 CB2EBC3E 		.long	1052520139
 1529 00d4 8796333E 		.long	1043568263
 1530 00d8 8D36D83D 		.long	1037579917
 1531 00dc A1CA8E3E 		.long	1049545377
 1532 00e0 7C5EDE3E 		.long	1054760572
 1533 00e4 69830D3F 		.long	1057850217
 1534 00e8 9A99193F 		.long	1058642330
 1535 00ec 69830D3F 		.long	1057850217
 1536 00f0 7C5EDE3E 		.long	1054760572
 1537 00f4 A1CA8E3E 		.long	1049545377
 1538 00f8 8D36D83D 		.long	1037579917
 1539 00fc 00000000 		.long	0
 1540 0100 731B1B3E 		.long	1041963891
 1541 0104 A1CA8E3E 		.long	1049545377
 1542 0108 CB2EBC3E 		.long	1052520139
 1543 010c CDCCCC3E 		.long	1053609165
 1544 0110 CB2EBC3E 		.long	1052520139
GAS LISTING /tmp/ccOaNtkH.s 			page 42


 1545 0114 A1CA8E3E 		.long	1049545377
 1546 0118 731B1B3E 		.long	1041963891
 1547 011c 00000000 		.long	0
 1548 0120 00000000 		.long	0
 1549 0124 00000000 		.long	0
 1550 0128 8D36D83D 		.long	1037579917
 1551 012c 8796333E 		.long	1043568263
 1552 0130 CDCC4C3E 		.long	1045220557
 1553 0134 8796333E 		.long	1043568263
 1554 0138 8D36D83D 		.long	1037579917
 1555 013c 00000000 		.long	0
 1556 0140 00000000 		.long	0
 1557              		.section	.rodata
 1558              		.align 32
 1559              		.type	mixed_data, @object
 1560              		.size	mixed_data, 4100
 1561              	mixed_data:
 1562 0000 00       		.byte	0
 1563 0001 00       		.byte	0
 1564 0002 00       		.byte	0
 1565 0003 00       		.byte	0
 1566 0004 5E       		.byte	94
 1567 0005 4F       		.byte	79
 1568 0006 A2       		.byte	-94
 1569 0007 00       		.byte	0
 1570 0008 5D       		.byte	93
 1571 0009 4F       		.byte	79
 1572 000a A2       		.byte	-94
 1573 000b 07       		.byte	7
 1574 000c 5D       		.byte	93
 1575 000d 50       		.byte	80
 1576 000e A2       		.byte	-94
 1577 000f 0E       		.byte	14
 1578 0010 5C       		.byte	92
 1579 0011 50       		.byte	80
 1580 0012 A3       		.byte	-93
 1581 0013 16       		.byte	22
 1582 0014 5C       		.byte	92
 1583 0015 51       		.byte	81
 1584 0016 A3       		.byte	-93
 1585 0017 1D       		.byte	29
 1586 0018 5B       		.byte	91
 1587 0019 51       		.byte	81
 1588 001a A4       		.byte	-92
 1589 001b 25       		.byte	37
 1590 001c 5B       		.byte	91
 1591 001d 52       		.byte	82
 1592 001e A4       		.byte	-92
 1593 001f 2C       		.byte	44
 1594 0020 5A       		.byte	90
 1595 0021 52       		.byte	82
 1596 0022 A4       		.byte	-92
 1597 0023 34       		.byte	52
 1598 0024 5A       		.byte	90
 1599 0025 53       		.byte	83
 1600 0026 A5       		.byte	-91
 1601 0027 3B       		.byte	59
GAS LISTING /tmp/ccOaNtkH.s 			page 43


 1602 0028 59       		.byte	89
 1603 0029 53       		.byte	83
 1604 002a A5       		.byte	-91
 1605 002b 43       		.byte	67
 1606 002c 59       		.byte	89
 1607 002d 54       		.byte	84
 1608 002e A6       		.byte	-90
 1609 002f 4A       		.byte	74
 1610 0030 58       		.byte	88
 1611 0031 54       		.byte	84
 1612 0032 A6       		.byte	-90
 1613 0033 52       		.byte	82
 1614 0034 58       		.byte	88
 1615 0035 55       		.byte	85
 1616 0036 A6       		.byte	-90
 1617 0037 59       		.byte	89
 1618 0038 57       		.byte	87
 1619 0039 55       		.byte	85
 1620 003a A7       		.byte	-89
 1621 003b 61       		.byte	97
 1622 003c 57       		.byte	87
 1623 003d 56       		.byte	86
 1624 003e A7       		.byte	-89
 1625 003f 68       		.byte	104
 1626 0040 56       		.byte	86
 1627 0041 56       		.byte	86
 1628 0042 A7       		.byte	-89
 1629 0043 70       		.byte	112
 1630 0044 56       		.byte	86
 1631 0045 57       		.byte	87
 1632 0046 A8       		.byte	-88
 1633 0047 77       		.byte	119
 1634 0048 55       		.byte	85
 1635 0049 57       		.byte	87
 1636 004a A8       		.byte	-88
 1637 004b 7F       		.byte	127
 1638 004c 55       		.byte	85
 1639 004d 58       		.byte	88
 1640 004e A8       		.byte	-88
 1641 004f 86       		.byte	-122
 1642 0050 54       		.byte	84
 1643 0051 58       		.byte	88
 1644 0052 A9       		.byte	-87
 1645 0053 8D       		.byte	-115
 1646 0054 54       		.byte	84
 1647 0055 59       		.byte	89
 1648 0056 A9       		.byte	-87
 1649 0057 95       		.byte	-107
 1650 0058 53       		.byte	83
 1651 0059 59       		.byte	89
 1652 005a A9       		.byte	-87
 1653 005b 9C       		.byte	-100
 1654 005c 53       		.byte	83
 1655 005d 5A       		.byte	90
 1656 005e AA       		.byte	-86
 1657 005f A4       		.byte	-92
 1658 0060 53       		.byte	83
GAS LISTING /tmp/ccOaNtkH.s 			page 44


 1659 0061 5A       		.byte	90
 1660 0062 AA       		.byte	-86
 1661 0063 AB       		.byte	-85
 1662 0064 52       		.byte	82
 1663 0065 5B       		.byte	91
 1664 0066 AA       		.byte	-86
 1665 0067 B3       		.byte	-77
 1666 0068 52       		.byte	82
 1667 0069 5B       		.byte	91
 1668 006a AB       		.byte	-85
 1669 006b BA       		.byte	-70
 1670 006c 51       		.byte	81
 1671 006d 5C       		.byte	92
 1672 006e AB       		.byte	-85
 1673 006f C2       		.byte	-62
 1674 0070 51       		.byte	81
 1675 0071 5C       		.byte	92
 1676 0072 AB       		.byte	-85
 1677 0073 C9       		.byte	-55
 1678 0074 50       		.byte	80
 1679 0075 5D       		.byte	93
 1680 0076 AC       		.byte	-84
 1681 0077 D1       		.byte	-47
 1682 0078 50       		.byte	80
 1683 0079 5D       		.byte	93
 1684 007a AC       		.byte	-84
 1685 007b D8       		.byte	-40
 1686 007c 4F       		.byte	79
 1687 007d 5E       		.byte	94
 1688 007e AC       		.byte	-84
 1689 007f E0       		.byte	-32
 1690 0080 4F       		.byte	79
 1691 0081 5E       		.byte	94
 1692 0082 AC       		.byte	-84
 1693 0083 E7       		.byte	-25
 1694 0084 4E       		.byte	78
 1695 0085 5F       		.byte	95
 1696 0086 AD       		.byte	-83
 1697 0087 EF       		.byte	-17
 1698 0088 4E       		.byte	78
 1699 0089 5F       		.byte	95
 1700 008a AD       		.byte	-83
 1701 008b F6       		.byte	-10
 1702 008c 4D       		.byte	77
 1703 008d 5F       		.byte	95
 1704 008e AD       		.byte	-83
 1705 008f FE       		.byte	-2
 1706 0090 4D       		.byte	77
 1707 0091 60       		.byte	96
 1708 0092 AE       		.byte	-82
 1709 0093 FF       		.byte	-1
 1710 0094 4C       		.byte	76
 1711 0095 60       		.byte	96
 1712 0096 AE       		.byte	-82
 1713 0097 FF       		.byte	-1
 1714 0098 4C       		.byte	76
 1715 0099 61       		.byte	97
GAS LISTING /tmp/ccOaNtkH.s 			page 45


 1716 009a AE       		.byte	-82
 1717 009b FF       		.byte	-1
 1718 009c 4B       		.byte	75
 1719 009d 61       		.byte	97
 1720 009e AE       		.byte	-82
 1721 009f FF       		.byte	-1
 1722 00a0 4B       		.byte	75
 1723 00a1 62       		.byte	98
 1724 00a2 AF       		.byte	-81
 1725 00a3 FF       		.byte	-1
 1726 00a4 4A       		.byte	74
 1727 00a5 62       		.byte	98
 1728 00a6 AF       		.byte	-81
 1729 00a7 FF       		.byte	-1
 1730 00a8 4A       		.byte	74
 1731 00a9 63       		.byte	99
 1732 00aa AF       		.byte	-81
 1733 00ab FF       		.byte	-1
 1734 00ac 49       		.byte	73
 1735 00ad 63       		.byte	99
 1736 00ae AF       		.byte	-81
 1737 00af FF       		.byte	-1
 1738 00b0 49       		.byte	73
 1739 00b1 64       		.byte	100
 1740 00b2 B0       		.byte	-80
 1741 00b3 FF       		.byte	-1
 1742 00b4 48       		.byte	72
 1743 00b5 64       		.byte	100
 1744 00b6 B0       		.byte	-80
 1745 00b7 FF       		.byte	-1
 1746 00b8 48       		.byte	72
 1747 00b9 65       		.byte	101
 1748 00ba B0       		.byte	-80
 1749 00bb FF       		.byte	-1
 1750 00bc 48       		.byte	72
 1751 00bd 65       		.byte	101
 1752 00be B0       		.byte	-80
 1753 00bf FF       		.byte	-1
 1754 00c0 47       		.byte	71
 1755 00c1 65       		.byte	101
 1756 00c2 B0       		.byte	-80
 1757 00c3 FF       		.byte	-1
 1758 00c4 47       		.byte	71
 1759 00c5 66       		.byte	102
 1760 00c6 B1       		.byte	-79
 1761 00c7 FF       		.byte	-1
 1762 00c8 46       		.byte	70
 1763 00c9 66       		.byte	102
 1764 00ca B1       		.byte	-79
 1765 00cb FF       		.byte	-1
 1766 00cc 46       		.byte	70
 1767 00cd 67       		.byte	103
 1768 00ce B1       		.byte	-79
 1769 00cf FF       		.byte	-1
 1770 00d0 45       		.byte	69
 1771 00d1 67       		.byte	103
 1772 00d2 B1       		.byte	-79
GAS LISTING /tmp/ccOaNtkH.s 			page 46


 1773 00d3 FF       		.byte	-1
 1774 00d4 3C       		.byte	60
 1775 00d5 73       		.byte	115
 1776 00d6 B7       		.byte	-73
 1777 00d7 FF       		.byte	-1
 1778 00d8 3C       		.byte	60
 1779 00d9 73       		.byte	115
 1780 00da B7       		.byte	-73
 1781 00db FF       		.byte	-1
 1782 00dc 3B       		.byte	59
 1783 00dd 74       		.byte	116
 1784 00de B7       		.byte	-73
 1785 00df FF       		.byte	-1
 1786 00e0 3B       		.byte	59
 1787 00e1 74       		.byte	116
 1788 00e2 B7       		.byte	-73
 1789 00e3 FF       		.byte	-1
 1790 00e4 3A       		.byte	58
 1791 00e5 75       		.byte	117
 1792 00e6 B8       		.byte	-72
 1793 00e7 FF       		.byte	-1
 1794 00e8 3A       		.byte	58
 1795 00e9 75       		.byte	117
 1796 00ea B8       		.byte	-72
 1797 00eb FF       		.byte	-1
 1798 00ec 3A       		.byte	58
 1799 00ed 76       		.byte	118
 1800 00ee B8       		.byte	-72
 1801 00ef FF       		.byte	-1
 1802 00f0 39       		.byte	57
 1803 00f1 76       		.byte	118
 1804 00f2 B8       		.byte	-72
 1805 00f3 FF       		.byte	-1
 1806 00f4 39       		.byte	57
 1807 00f5 76       		.byte	118
 1808 00f6 B8       		.byte	-72
 1809 00f7 FF       		.byte	-1
 1810 00f8 38       		.byte	56
 1811 00f9 77       		.byte	119
 1812 00fa B8       		.byte	-72
 1813 00fb FF       		.byte	-1
 1814 00fc 38       		.byte	56
 1815 00fd 77       		.byte	119
 1816 00fe B9       		.byte	-71
 1817 00ff FF       		.byte	-1
 1818 0100 38       		.byte	56
 1819 0101 78       		.byte	120
 1820 0102 B9       		.byte	-71
 1821 0103 FF       		.byte	-1
 1822 0104 37       		.byte	55
 1823 0105 78       		.byte	120
 1824 0106 B9       		.byte	-71
 1825 0107 FF       		.byte	-1
 1826 0108 37       		.byte	55
 1827 0109 79       		.byte	121
 1828 010a B9       		.byte	-71
 1829 010b FF       		.byte	-1
GAS LISTING /tmp/ccOaNtkH.s 			page 47


 1830 010c 37       		.byte	55
 1831 010d 79       		.byte	121
 1832 010e B9       		.byte	-71
 1833 010f FF       		.byte	-1
 1834 0110 36       		.byte	54
 1835 0111 79       		.byte	121
 1836 0112 B9       		.byte	-71
 1837 0113 FF       		.byte	-1
 1838 0114 36       		.byte	54
 1839 0115 7A       		.byte	122
 1840 0116 BA       		.byte	-70
 1841 0117 FF       		.byte	-1
 1842 0118 36       		.byte	54
 1843 0119 7A       		.byte	122
 1844 011a BA       		.byte	-70
 1845 011b FF       		.byte	-1
 1846 011c 35       		.byte	53
 1847 011d 7B       		.byte	123
 1848 011e BA       		.byte	-70
 1849 011f FF       		.byte	-1
 1850 0120 35       		.byte	53
 1851 0121 7B       		.byte	123
 1852 0122 BA       		.byte	-70
 1853 0123 FF       		.byte	-1
 1854 0124 35       		.byte	53
 1855 0125 7C       		.byte	124
 1856 0126 BA       		.byte	-70
 1857 0127 FF       		.byte	-1
 1858 0128 34       		.byte	52
 1859 0129 7C       		.byte	124
 1860 012a BA       		.byte	-70
 1861 012b FF       		.byte	-1
 1862 012c 34       		.byte	52
 1863 012d 7C       		.byte	124
 1864 012e BA       		.byte	-70
 1865 012f FF       		.byte	-1
 1866 0130 34       		.byte	52
 1867 0131 7D       		.byte	125
 1868 0132 BA       		.byte	-70
 1869 0133 FF       		.byte	-1
 1870 0134 34       		.byte	52
 1871 0135 7D       		.byte	125
 1872 0136 BB       		.byte	-69
 1873 0137 FF       		.byte	-1
 1874 0138 33       		.byte	51
 1875 0139 7E       		.byte	126
 1876 013a BB       		.byte	-69
 1877 013b FF       		.byte	-1
 1878 013c 33       		.byte	51
 1879 013d 7E       		.byte	126
 1880 013e BB       		.byte	-69
 1881 013f FF       		.byte	-1
 1882 0140 33       		.byte	51
 1883 0141 7E       		.byte	126
 1884 0142 BB       		.byte	-69
 1885 0143 FF       		.byte	-1
 1886 0144 33       		.byte	51
GAS LISTING /tmp/ccOaNtkH.s 			page 48


 1887 0145 7F       		.byte	127
 1888 0146 BB       		.byte	-69
 1889 0147 FF       		.byte	-1
 1890 0148 32       		.byte	50
 1891 0149 7F       		.byte	127
 1892 014a BB       		.byte	-69
 1893 014b FF       		.byte	-1
 1894 014c 32       		.byte	50
 1895 014d 80       		.byte	-128
 1896 014e BB       		.byte	-69
 1897 014f FF       		.byte	-1
 1898 0150 32       		.byte	50
 1899 0151 80       		.byte	-128
 1900 0152 BB       		.byte	-69
 1901 0153 FF       		.byte	-1
 1902 0154 32       		.byte	50
 1903 0155 80       		.byte	-128
 1904 0156 BB       		.byte	-69
 1905 0157 FF       		.byte	-1
 1906 0158 32       		.byte	50
 1907 0159 81       		.byte	-127
 1908 015a BB       		.byte	-69
 1909 015b FF       		.byte	-1
 1910 015c 32       		.byte	50
 1911 015d 81       		.byte	-127
 1912 015e BC       		.byte	-68
 1913 015f FF       		.byte	-1
 1914 0160 32       		.byte	50
 1915 0161 82       		.byte	-126
 1916 0162 BC       		.byte	-68
 1917 0163 FF       		.byte	-1
 1918 0164 31       		.byte	49
 1919 0165 82       		.byte	-126
 1920 0166 BC       		.byte	-68
 1921 0167 FF       		.byte	-1
 1922 0168 31       		.byte	49
 1923 0169 82       		.byte	-126
 1924 016a BC       		.byte	-68
 1925 016b FF       		.byte	-1
 1926 016c 31       		.byte	49
 1927 016d 83       		.byte	-125
 1928 016e BC       		.byte	-68
 1929 016f FF       		.byte	-1
 1930 0170 31       		.byte	49
 1931 0171 83       		.byte	-125
 1932 0172 BC       		.byte	-68
 1933 0173 FF       		.byte	-1
 1934 0174 31       		.byte	49
 1935 0175 84       		.byte	-124
 1936 0176 BC       		.byte	-68
 1937 0177 FF       		.byte	-1
 1938 0178 31       		.byte	49
 1939 0179 84       		.byte	-124
 1940 017a BC       		.byte	-68
 1941 017b FF       		.byte	-1
 1942 017c 31       		.byte	49
 1943 017d 84       		.byte	-124
GAS LISTING /tmp/ccOaNtkH.s 			page 49


 1944 017e BC       		.byte	-68
 1945 017f FF       		.byte	-1
 1946 0180 31       		.byte	49
 1947 0181 85       		.byte	-123
 1948 0182 BC       		.byte	-68
 1949 0183 FF       		.byte	-1
 1950 0184 31       		.byte	49
 1951 0185 85       		.byte	-123
 1952 0186 BC       		.byte	-68
 1953 0187 FF       		.byte	-1
 1954 0188 31       		.byte	49
 1955 0189 85       		.byte	-123
 1956 018a BC       		.byte	-68
 1957 018b FF       		.byte	-1
 1958 018c 31       		.byte	49
 1959 018d 86       		.byte	-122
 1960 018e BC       		.byte	-68
 1961 018f FF       		.byte	-1
 1962 0190 31       		.byte	49
 1963 0191 86       		.byte	-122
 1964 0192 BC       		.byte	-68
 1965 0193 FF       		.byte	-1
 1966 0194 31       		.byte	49
 1967 0195 87       		.byte	-121
 1968 0196 BC       		.byte	-68
 1969 0197 FF       		.byte	-1
 1970 0198 31       		.byte	49
 1971 0199 87       		.byte	-121
 1972 019a BC       		.byte	-68
 1973 019b FF       		.byte	-1
 1974 019c 31       		.byte	49
 1975 019d 87       		.byte	-121
 1976 019e BC       		.byte	-68
 1977 019f FF       		.byte	-1
 1978 01a0 31       		.byte	49
 1979 01a1 88       		.byte	-120
 1980 01a2 BD       		.byte	-67
 1981 01a3 FF       		.byte	-1
 1982 01a4 2F       		.byte	47
 1983 01a5 88       		.byte	-120
 1984 01a6 BD       		.byte	-67
 1985 01a7 FF       		.byte	-1
 1986 01a8 2E       		.byte	46
 1987 01a9 89       		.byte	-119
 1988 01aa BD       		.byte	-67
 1989 01ab FF       		.byte	-1
 1990 01ac 2D       		.byte	45
 1991 01ad 8A       		.byte	-118
 1992 01ae BD       		.byte	-67
 1993 01af FF       		.byte	-1
 1994 01b0 2B       		.byte	43
 1995 01b1 8A       		.byte	-118
 1996 01b2 BD       		.byte	-67
 1997 01b3 FF       		.byte	-1
 1998 01b4 2A       		.byte	42
 1999 01b5 8B       		.byte	-117
 2000 01b6 BE       		.byte	-66
GAS LISTING /tmp/ccOaNtkH.s 			page 50


 2001 01b7 FF       		.byte	-1
 2002 01b8 29       		.byte	41
 2003 01b9 8B       		.byte	-117
 2004 01ba BE       		.byte	-66
 2005 01bb FF       		.byte	-1
 2006 01bc 27       		.byte	39
 2007 01bd 8C       		.byte	-116
 2008 01be BE       		.byte	-66
 2009 01bf FF       		.byte	-1
 2010 01c0 26       		.byte	38
 2011 01c1 8C       		.byte	-116
 2012 01c2 BE       		.byte	-66
 2013 01c3 FF       		.byte	-1
 2014 01c4 24       		.byte	36
 2015 01c5 8D       		.byte	-115
 2016 01c6 BE       		.byte	-66
 2017 01c7 FF       		.byte	-1
 2018 01c8 23       		.byte	35
 2019 01c9 8D       		.byte	-115
 2020 01ca BE       		.byte	-66
 2021 01cb FF       		.byte	-1
 2022 01cc 21       		.byte	33
 2023 01cd 8E       		.byte	-114
 2024 01ce BE       		.byte	-66
 2025 01cf FF       		.byte	-1
 2026 01d0 1F       		.byte	31
 2027 01d1 8E       		.byte	-114
 2028 01d2 BE       		.byte	-66
 2029 01d3 FF       		.byte	-1
 2030 01d4 1E       		.byte	30
 2031 01d5 8F       		.byte	-113
 2032 01d6 BE       		.byte	-66
 2033 01d7 FF       		.byte	-1
 2034 01d8 1C       		.byte	28
 2035 01d9 8F       		.byte	-113
 2036 01da BE       		.byte	-66
 2037 01db FF       		.byte	-1
 2038 01dc 1A       		.byte	26
 2039 01dd 90       		.byte	-112
 2040 01de BF       		.byte	-65
 2041 01df FF       		.byte	-1
 2042 01e0 18       		.byte	24
 2043 01e1 91       		.byte	-111
 2044 01e2 BF       		.byte	-65
 2045 01e3 FF       		.byte	-1
 2046 01e4 16       		.byte	22
 2047 01e5 91       		.byte	-111
 2048 01e6 BF       		.byte	-65
 2049 01e7 FF       		.byte	-1
 2050 01e8 14       		.byte	20
 2051 01e9 92       		.byte	-110
 2052 01ea BF       		.byte	-65
 2053 01eb FF       		.byte	-1
 2054 01ec 11       		.byte	17
 2055 01ed 92       		.byte	-110
 2056 01ee BF       		.byte	-65
 2057 01ef FF       		.byte	-1
GAS LISTING /tmp/ccOaNtkH.s 			page 51


 2058 01f0 0F       		.byte	15
 2059 01f1 93       		.byte	-109
 2060 01f2 BF       		.byte	-65
 2061 01f3 FF       		.byte	-1
 2062 01f4 0C       		.byte	12
 2063 01f5 93       		.byte	-109
 2064 01f6 BF       		.byte	-65
 2065 01f7 FF       		.byte	-1
 2066 01f8 0A       		.byte	10
 2067 01f9 94       		.byte	-108
 2068 01fa BF       		.byte	-65
 2069 01fb FF       		.byte	-1
 2070 01fc 0A       		.byte	10
 2071 01fd 94       		.byte	-108
 2072 01fe BF       		.byte	-65
 2073 01ff FF       		.byte	-1
 2074 0200 0A       		.byte	10
 2075 0201 95       		.byte	-107
 2076 0202 BF       		.byte	-65
 2077 0203 FF       		.byte	-1
 2078 0204 0A       		.byte	10
 2079 0205 95       		.byte	-107
 2080 0206 BF       		.byte	-65
 2081 0207 FF       		.byte	-1
 2082 0208 0A       		.byte	10
 2083 0209 96       		.byte	-106
 2084 020a BF       		.byte	-65
 2085 020b FF       		.byte	-1
 2086 020c 0A       		.byte	10
 2087 020d 96       		.byte	-106
 2088 020e BE       		.byte	-66
 2089 020f FF       		.byte	-1
 2090 0210 0A       		.byte	10
 2091 0211 97       		.byte	-105
 2092 0212 BE       		.byte	-66
 2093 0213 FF       		.byte	-1
 2094 0214 0A       		.byte	10
 2095 0215 97       		.byte	-105
 2096 0216 BE       		.byte	-66
 2097 0217 FF       		.byte	-1
 2098 0218 0A       		.byte	10
 2099 0219 98       		.byte	-104
 2100 021a BE       		.byte	-66
 2101 021b FF       		.byte	-1
 2102 021c 0A       		.byte	10
 2103 021d 98       		.byte	-104
 2104 021e BE       		.byte	-66
 2105 021f FF       		.byte	-1
 2106 0220 0A       		.byte	10
 2107 0221 99       		.byte	-103
 2108 0222 BE       		.byte	-66
 2109 0223 FF       		.byte	-1
 2110 0224 0A       		.byte	10
 2111 0225 99       		.byte	-103
 2112 0226 BE       		.byte	-66
 2113 0227 FF       		.byte	-1
 2114 0228 0A       		.byte	10
GAS LISTING /tmp/ccOaNtkH.s 			page 52


 2115 0229 9A       		.byte	-102
 2116 022a BE       		.byte	-66
 2117 022b FF       		.byte	-1
 2118 022c 0A       		.byte	10
 2119 022d 9A       		.byte	-102
 2120 022e BE       		.byte	-66
 2121 022f FF       		.byte	-1
 2122 0230 0A       		.byte	10
 2123 0231 9B       		.byte	-101
 2124 0232 BE       		.byte	-66
 2125 0233 FF       		.byte	-1
 2126 0234 0A       		.byte	10
 2127 0235 9B       		.byte	-101
 2128 0236 BD       		.byte	-67
 2129 0237 FF       		.byte	-1
 2130 0238 0A       		.byte	10
 2131 0239 9C       		.byte	-100
 2132 023a BD       		.byte	-67
 2133 023b FF       		.byte	-1
 2134 023c 0A       		.byte	10
 2135 023d 9C       		.byte	-100
 2136 023e BD       		.byte	-67
 2137 023f FF       		.byte	-1
 2138 0240 0A       		.byte	10
 2139 0241 9D       		.byte	-99
 2140 0242 BD       		.byte	-67
 2141 0243 FF       		.byte	-1
 2142 0244 0A       		.byte	10
 2143 0245 9D       		.byte	-99
 2144 0246 BD       		.byte	-67
 2145 0247 FF       		.byte	-1
 2146 0248 0A       		.byte	10
 2147 0249 9E       		.byte	-98
 2148 024a BD       		.byte	-67
 2149 024b FF       		.byte	-1
 2150 024c 0A       		.byte	10
 2151 024d 9E       		.byte	-98
 2152 024e BC       		.byte	-68
 2153 024f FF       		.byte	-1
 2154 0250 0A       		.byte	10
 2155 0251 9E       		.byte	-98
 2156 0252 BC       		.byte	-68
 2157 0253 FF       		.byte	-1
 2158 0254 0A       		.byte	10
 2159 0255 9F       		.byte	-97
 2160 0256 BC       		.byte	-68
 2161 0257 FF       		.byte	-1
 2162 0258 0A       		.byte	10
 2163 0259 9F       		.byte	-97
 2164 025a BC       		.byte	-68
 2165 025b FF       		.byte	-1
 2166 025c 0A       		.byte	10
 2167 025d A0       		.byte	-96
 2168 025e BC       		.byte	-68
 2169 025f FF       		.byte	-1
 2170 0260 0A       		.byte	10
 2171 0261 A0       		.byte	-96
GAS LISTING /tmp/ccOaNtkH.s 			page 53


 2172 0262 BB       		.byte	-69
 2173 0263 FF       		.byte	-1
 2174 0264 0A       		.byte	10
 2175 0265 A1       		.byte	-95
 2176 0266 BB       		.byte	-69
 2177 0267 FF       		.byte	-1
 2178 0268 0A       		.byte	10
 2179 0269 A1       		.byte	-95
 2180 026a BB       		.byte	-69
 2181 026b FF       		.byte	-1
 2182 026c 14       		.byte	20
 2183 026d AD       		.byte	-83
 2184 026e B6       		.byte	-74
 2185 026f FF       		.byte	-1
 2186 0270 16       		.byte	22
 2187 0271 AE       		.byte	-82
 2188 0272 B6       		.byte	-74
 2189 0273 FF       		.byte	-1
 2190 0274 19       		.byte	25
 2191 0275 AE       		.byte	-82
 2192 0276 B5       		.byte	-75
 2193 0277 FF       		.byte	-1
 2194 0278 1C       		.byte	28
 2195 0279 AF       		.byte	-81
 2196 027a B5       		.byte	-75
 2197 027b FF       		.byte	-1
 2198 027c 1E       		.byte	30
 2199 027d AF       		.byte	-81
 2200 027e B5       		.byte	-75
 2201 027f FF       		.byte	-1
 2202 0280 21       		.byte	33
 2203 0281 B0       		.byte	-80
 2204 0282 B4       		.byte	-76
 2205 0283 FF       		.byte	-1
 2206 0284 23       		.byte	35
 2207 0285 B0       		.byte	-80
 2208 0286 B4       		.byte	-76
 2209 0287 FF       		.byte	-1
 2210 0288 25       		.byte	37
 2211 0289 B0       		.byte	-80
 2212 028a B4       		.byte	-76
 2213 028b FF       		.byte	-1
 2214 028c 27       		.byte	39
 2215 028d B1       		.byte	-79
 2216 028e B4       		.byte	-76
 2217 028f FF       		.byte	-1
 2218 0290 29       		.byte	41
 2219 0291 B1       		.byte	-79
 2220 0292 B3       		.byte	-77
 2221 0293 FF       		.byte	-1
 2222 0294 2B       		.byte	43
 2223 0295 B2       		.byte	-78
 2224 0296 B3       		.byte	-77
 2225 0297 FF       		.byte	-1
 2226 0298 2D       		.byte	45
 2227 0299 B2       		.byte	-78
 2228 029a B3       		.byte	-77
GAS LISTING /tmp/ccOaNtkH.s 			page 54


 2229 029b FF       		.byte	-1
 2230 029c 2E       		.byte	46
 2231 029d B3       		.byte	-77
 2232 029e B2       		.byte	-78
 2233 029f FF       		.byte	-1
 2234 02a0 30       		.byte	48
 2235 02a1 B3       		.byte	-77
 2236 02a2 B2       		.byte	-78
 2237 02a3 FF       		.byte	-1
 2238 02a4 32       		.byte	50
 2239 02a5 B3       		.byte	-77
 2240 02a6 B2       		.byte	-78
 2241 02a7 FF       		.byte	-1
 2242 02a8 33       		.byte	51
 2243 02a9 B4       		.byte	-76
 2244 02aa B1       		.byte	-79
 2245 02ab FF       		.byte	-1
 2246 02ac 35       		.byte	53
 2247 02ad B4       		.byte	-76
 2248 02ae B1       		.byte	-79
 2249 02af FF       		.byte	-1
 2250 02b0 36       		.byte	54
 2251 02b1 B5       		.byte	-75
 2252 02b2 B1       		.byte	-79
 2253 02b3 FF       		.byte	-1
 2254 02b4 38       		.byte	56
 2255 02b5 B5       		.byte	-75
 2256 02b6 B0       		.byte	-80
 2257 02b7 FF       		.byte	-1
 2258 02b8 3A       		.byte	58
 2259 02b9 B6       		.byte	-74
 2260 02ba B0       		.byte	-80
 2261 02bb FF       		.byte	-1
 2262 02bc 3B       		.byte	59
 2263 02bd B6       		.byte	-74
 2264 02be B0       		.byte	-80
 2265 02bf FF       		.byte	-1
 2266 02c0 3D       		.byte	61
 2267 02c1 B6       		.byte	-74
 2268 02c2 AF       		.byte	-81
 2269 02c3 FF       		.byte	-1
 2270 02c4 3E       		.byte	62
 2271 02c5 B7       		.byte	-73
 2272 02c6 AF       		.byte	-81
 2273 02c7 FF       		.byte	-1
 2274 02c8 40       		.byte	64
 2275 02c9 B7       		.byte	-73
 2276 02ca AF       		.byte	-81
 2277 02cb FF       		.byte	-1
 2278 02cc 41       		.byte	65
 2279 02cd B8       		.byte	-72
 2280 02ce AE       		.byte	-82
 2281 02cf FF       		.byte	-1
 2282 02d0 42       		.byte	66
 2283 02d1 B8       		.byte	-72
 2284 02d2 AE       		.byte	-82
 2285 02d3 FF       		.byte	-1
GAS LISTING /tmp/ccOaNtkH.s 			page 55


 2286 02d4 44       		.byte	68
 2287 02d5 B8       		.byte	-72
 2288 02d6 AE       		.byte	-82
 2289 02d7 FF       		.byte	-1
 2290 02d8 45       		.byte	69
 2291 02d9 B9       		.byte	-71
 2292 02da AD       		.byte	-83
 2293 02db FF       		.byte	-1
 2294 02dc 47       		.byte	71
 2295 02dd B9       		.byte	-71
 2296 02de AD       		.byte	-83
 2297 02df FF       		.byte	-1
 2298 02e0 48       		.byte	72
 2299 02e1 BA       		.byte	-70
 2300 02e2 AD       		.byte	-83
 2301 02e3 FF       		.byte	-1
 2302 02e4 4A       		.byte	74
 2303 02e5 BA       		.byte	-70
 2304 02e6 AC       		.byte	-84
 2305 02e7 FF       		.byte	-1
 2306 02e8 4B       		.byte	75
 2307 02e9 BA       		.byte	-70
 2308 02ea AC       		.byte	-84
 2309 02eb FF       		.byte	-1
 2310 02ec 4C       		.byte	76
 2311 02ed BB       		.byte	-69
 2312 02ee AB       		.byte	-85
 2313 02ef FF       		.byte	-1
 2314 02f0 4E       		.byte	78
 2315 02f1 BB       		.byte	-69
 2316 02f2 AB       		.byte	-85
 2317 02f3 FF       		.byte	-1
 2318 02f4 4F       		.byte	79
 2319 02f5 BB       		.byte	-69
 2320 02f6 AB       		.byte	-85
 2321 02f7 FF       		.byte	-1
 2322 02f8 50       		.byte	80
 2323 02f9 BC       		.byte	-68
 2324 02fa AA       		.byte	-86
 2325 02fb FF       		.byte	-1
 2326 02fc 52       		.byte	82
 2327 02fd BC       		.byte	-68
 2328 02fe AA       		.byte	-86
 2329 02ff FF       		.byte	-1
 2330 0300 53       		.byte	83
 2331 0301 BD       		.byte	-67
 2332 0302 AA       		.byte	-86
 2333 0303 FF       		.byte	-1
 2334 0304 55       		.byte	85
 2335 0305 BD       		.byte	-67
 2336 0306 A9       		.byte	-87
 2337 0307 FF       		.byte	-1
 2338 0308 56       		.byte	86
 2339 0309 BD       		.byte	-67
 2340 030a A9       		.byte	-87
 2341 030b FF       		.byte	-1
 2342 030c 57       		.byte	87
GAS LISTING /tmp/ccOaNtkH.s 			page 56


 2343 030d BE       		.byte	-66
 2344 030e A9       		.byte	-87
 2345 030f FF       		.byte	-1
 2346 0310 59       		.byte	89
 2347 0311 BE       		.byte	-66
 2348 0312 A8       		.byte	-88
 2349 0313 FF       		.byte	-1
 2350 0314 5A       		.byte	90
 2351 0315 BE       		.byte	-66
 2352 0316 A8       		.byte	-88
 2353 0317 FF       		.byte	-1
 2354 0318 5B       		.byte	91
 2355 0319 BF       		.byte	-65
 2356 031a A7       		.byte	-89
 2357 031b FF       		.byte	-1
 2358 031c 5D       		.byte	93
 2359 031d BF       		.byte	-65
 2360 031e A7       		.byte	-89
 2361 031f FF       		.byte	-1
 2362 0320 5E       		.byte	94
 2363 0321 BF       		.byte	-65
 2364 0322 A7       		.byte	-89
 2365 0323 FF       		.byte	-1
 2366 0324 5F       		.byte	95
 2367 0325 C0       		.byte	-64
 2368 0326 A6       		.byte	-90
 2369 0327 FF       		.byte	-1
 2370 0328 61       		.byte	97
 2371 0329 C0       		.byte	-64
 2372 032a A6       		.byte	-90
 2373 032b FF       		.byte	-1
 2374 032c 62       		.byte	98
 2375 032d C1       		.byte	-63
 2376 032e A6       		.byte	-90
 2377 032f FF       		.byte	-1
 2378 0330 63       		.byte	99
 2379 0331 C1       		.byte	-63
 2380 0332 A5       		.byte	-91
 2381 0333 FF       		.byte	-1
 2382 0334 64       		.byte	100
 2383 0335 C1       		.byte	-63
 2384 0336 A5       		.byte	-91
 2385 0337 FF       		.byte	-1
 2386 0338 66       		.byte	102
 2387 0339 C2       		.byte	-62
 2388 033a A4       		.byte	-92
 2389 033b FF       		.byte	-1
 2390 033c 66       		.byte	102
 2391 033d C2       		.byte	-62
 2392 033e A4       		.byte	-92
 2393 033f FF       		.byte	-1
 2394 0340 67       		.byte	103
 2395 0341 C2       		.byte	-62
 2396 0342 A4       		.byte	-92
 2397 0343 FF       		.byte	-1
 2398 0344 67       		.byte	103
 2399 0345 C2       		.byte	-62
GAS LISTING /tmp/ccOaNtkH.s 			page 57


 2400 0346 A4       		.byte	-92
 2401 0347 FF       		.byte	-1
 2402 0348 68       		.byte	104
 2403 0349 C2       		.byte	-62
 2404 034a A4       		.byte	-92
 2405 034b FF       		.byte	-1
 2406 034c 68       		.byte	104
 2407 034d C3       		.byte	-61
 2408 034e A4       		.byte	-92
 2409 034f FF       		.byte	-1
 2410 0350 69       		.byte	105
 2411 0351 C3       		.byte	-61
 2412 0352 A4       		.byte	-92
 2413 0353 FF       		.byte	-1
 2414 0354 69       		.byte	105
 2415 0355 C3       		.byte	-61
 2416 0356 A4       		.byte	-92
 2417 0357 FF       		.byte	-1
 2418 0358 6A       		.byte	106
 2419 0359 C3       		.byte	-61
 2420 035a A4       		.byte	-92
 2421 035b FF       		.byte	-1
 2422 035c 6A       		.byte	106
 2423 035d C4       		.byte	-60
 2424 035e A4       		.byte	-92
 2425 035f FF       		.byte	-1
 2426 0360 6B       		.byte	107
 2427 0361 C4       		.byte	-60
 2428 0362 A4       		.byte	-92
 2429 0363 FF       		.byte	-1
 2430 0364 6C       		.byte	108
 2431 0365 C4       		.byte	-60
 2432 0366 A4       		.byte	-92
 2433 0367 FF       		.byte	-1
 2434 0368 6C       		.byte	108
 2435 0369 C4       		.byte	-60
 2436 036a A4       		.byte	-92
 2437 036b FF       		.byte	-1
 2438 036c 6D       		.byte	109
 2439 036d C4       		.byte	-60
 2440 036e A4       		.byte	-92
 2441 036f FF       		.byte	-1
 2442 0370 6D       		.byte	109
 2443 0371 C5       		.byte	-59
 2444 0372 A4       		.byte	-92
 2445 0373 FF       		.byte	-1
 2446 0374 6E       		.byte	110
 2447 0375 C5       		.byte	-59
 2448 0376 A4       		.byte	-92
 2449 0377 FF       		.byte	-1
 2450 0378 6E       		.byte	110
 2451 0379 C5       		.byte	-59
 2452 037a A4       		.byte	-92
 2453 037b FF       		.byte	-1
 2454 037c 6F       		.byte	111
 2455 037d C5       		.byte	-59
 2456 037e A4       		.byte	-92
GAS LISTING /tmp/ccOaNtkH.s 			page 58


 2457 037f FF       		.byte	-1
 2458 0380 6F       		.byte	111
 2459 0381 C6       		.byte	-58
 2460 0382 A4       		.byte	-92
 2461 0383 FF       		.byte	-1
 2462 0384 70       		.byte	112
 2463 0385 C6       		.byte	-58
 2464 0386 A4       		.byte	-92
 2465 0387 FF       		.byte	-1
 2466 0388 70       		.byte	112
 2467 0389 C6       		.byte	-58
 2468 038a A4       		.byte	-92
 2469 038b FF       		.byte	-1
 2470 038c 71       		.byte	113
 2471 038d C6       		.byte	-58
 2472 038e A4       		.byte	-92
 2473 038f FF       		.byte	-1
 2474 0390 71       		.byte	113
 2475 0391 C6       		.byte	-58
 2476 0392 A4       		.byte	-92
 2477 0393 FF       		.byte	-1
 2478 0394 72       		.byte	114
 2479 0395 C7       		.byte	-57
 2480 0396 A4       		.byte	-92
 2481 0397 FF       		.byte	-1
 2482 0398 73       		.byte	115
 2483 0399 C7       		.byte	-57
 2484 039a A4       		.byte	-92
 2485 039b FF       		.byte	-1
 2486 039c 73       		.byte	115
 2487 039d C7       		.byte	-57
 2488 039e A4       		.byte	-92
 2489 039f FF       		.byte	-1
 2490 03a0 74       		.byte	116
 2491 03a1 C7       		.byte	-57
 2492 03a2 A4       		.byte	-92
 2493 03a3 FF       		.byte	-1
 2494 03a4 74       		.byte	116
 2495 03a5 C8       		.byte	-56
 2496 03a6 A4       		.byte	-92
 2497 03a7 FF       		.byte	-1
 2498 03a8 75       		.byte	117
 2499 03a9 C8       		.byte	-56
 2500 03aa A4       		.byte	-92
 2501 03ab FF       		.byte	-1
 2502 03ac 75       		.byte	117
 2503 03ad C8       		.byte	-56
 2504 03ae A4       		.byte	-92
 2505 03af FF       		.byte	-1
 2506 03b0 76       		.byte	118
 2507 03b1 C8       		.byte	-56
 2508 03b2 A4       		.byte	-92
 2509 03b3 FF       		.byte	-1
 2510 03b4 76       		.byte	118
 2511 03b5 C8       		.byte	-56
 2512 03b6 A4       		.byte	-92
 2513 03b7 FF       		.byte	-1
GAS LISTING /tmp/ccOaNtkH.s 			page 59


 2514 03b8 77       		.byte	119
 2515 03b9 C9       		.byte	-55
 2516 03ba A4       		.byte	-92
 2517 03bb FF       		.byte	-1
 2518 03bc 77       		.byte	119
 2519 03bd C9       		.byte	-55
 2520 03be A4       		.byte	-92
 2521 03bf FF       		.byte	-1
 2522 03c0 78       		.byte	120
 2523 03c1 C9       		.byte	-55
 2524 03c2 A4       		.byte	-92
 2525 03c3 FF       		.byte	-1
 2526 03c4 78       		.byte	120
 2527 03c5 C9       		.byte	-55
 2528 03c6 A4       		.byte	-92
 2529 03c7 FF       		.byte	-1
 2530 03c8 79       		.byte	121
 2531 03c9 C9       		.byte	-55
 2532 03ca A4       		.byte	-92
 2533 03cb FF       		.byte	-1
 2534 03cc 7A       		.byte	122
 2535 03cd CA       		.byte	-54
 2536 03ce A4       		.byte	-92
 2537 03cf FF       		.byte	-1
 2538 03d0 7A       		.byte	122
 2539 03d1 CA       		.byte	-54
 2540 03d2 A4       		.byte	-92
 2541 03d3 FF       		.byte	-1
 2542 03d4 7B       		.byte	123
 2543 03d5 CA       		.byte	-54
 2544 03d6 A4       		.byte	-92
 2545 03d7 FF       		.byte	-1
 2546 03d8 7B       		.byte	123
 2547 03d9 CA       		.byte	-54
 2548 03da A4       		.byte	-92
 2549 03db FF       		.byte	-1
 2550 03dc 7C       		.byte	124
 2551 03dd CB       		.byte	-53
 2552 03de A4       		.byte	-92
 2553 03df FF       		.byte	-1
 2554 03e0 7C       		.byte	124
 2555 03e1 CB       		.byte	-53
 2556 03e2 A4       		.byte	-92
 2557 03e3 FF       		.byte	-1
 2558 03e4 7D       		.byte	125
 2559 03e5 CB       		.byte	-53
 2560 03e6 A4       		.byte	-92
 2561 03e7 FF       		.byte	-1
 2562 03e8 7D       		.byte	125
 2563 03e9 CB       		.byte	-53
 2564 03ea A4       		.byte	-92
 2565 03eb FF       		.byte	-1
 2566 03ec 7E       		.byte	126
 2567 03ed CB       		.byte	-53
 2568 03ee A4       		.byte	-92
 2569 03ef FF       		.byte	-1
 2570 03f0 7E       		.byte	126
GAS LISTING /tmp/ccOaNtkH.s 			page 60


 2571 03f1 CC       		.byte	-52
 2572 03f2 A4       		.byte	-92
 2573 03f3 FF       		.byte	-1
 2574 03f4 7F       		.byte	127
 2575 03f5 CC       		.byte	-52
 2576 03f6 A4       		.byte	-92
 2577 03f7 FF       		.byte	-1
 2578 03f8 7F       		.byte	127
 2579 03f9 CC       		.byte	-52
 2580 03fa A3       		.byte	-93
 2581 03fb FF       		.byte	-1
 2582 03fc 80       		.byte	-128
 2583 03fd CC       		.byte	-52
 2584 03fe A3       		.byte	-93
 2585 03ff FF       		.byte	-1
 2586 0400 81       		.byte	-127
 2587 0401 CC       		.byte	-52
 2588 0402 A3       		.byte	-93
 2589 0403 FF       		.byte	-1
 2590 0404 8F       		.byte	-113
 2591 0405 D2       		.byte	-46
 2592 0406 A3       		.byte	-93
 2593 0407 FF       		.byte	-1
 2594 0408 8F       		.byte	-113
 2595 0409 D2       		.byte	-46
 2596 040a A3       		.byte	-93
 2597 040b FF       		.byte	-1
 2598 040c 90       		.byte	-112
 2599 040d D2       		.byte	-46
 2600 040e A3       		.byte	-93
 2601 040f FF       		.byte	-1
 2602 0410 90       		.byte	-112
 2603 0411 D3       		.byte	-45
 2604 0412 A3       		.byte	-93
 2605 0413 FF       		.byte	-1
 2606 0414 91       		.byte	-111
 2607 0415 D3       		.byte	-45
 2608 0416 A3       		.byte	-93
 2609 0417 FF       		.byte	-1
 2610 0418 92       		.byte	-110
 2611 0419 D3       		.byte	-45
 2612 041a A3       		.byte	-93
 2613 041b FF       		.byte	-1
 2614 041c 92       		.byte	-110
 2615 041d D3       		.byte	-45
 2616 041e A3       		.byte	-93
 2617 041f FF       		.byte	-1
 2618 0420 93       		.byte	-109
 2619 0421 D4       		.byte	-44
 2620 0422 A3       		.byte	-93
 2621 0423 FF       		.byte	-1
 2622 0424 93       		.byte	-109
 2623 0425 D4       		.byte	-44
 2624 0426 A3       		.byte	-93
 2625 0427 FF       		.byte	-1
 2626 0428 94       		.byte	-108
 2627 0429 D4       		.byte	-44
GAS LISTING /tmp/ccOaNtkH.s 			page 61


 2628 042a A3       		.byte	-93
 2629 042b FF       		.byte	-1
 2630 042c 94       		.byte	-108
 2631 042d D4       		.byte	-44
 2632 042e A3       		.byte	-93
 2633 042f FF       		.byte	-1
 2634 0430 95       		.byte	-107
 2635 0431 D4       		.byte	-44
 2636 0432 A3       		.byte	-93
 2637 0433 FF       		.byte	-1
 2638 0434 95       		.byte	-107
 2639 0435 D5       		.byte	-43
 2640 0436 A3       		.byte	-93
 2641 0437 FF       		.byte	-1
 2642 0438 96       		.byte	-106
 2643 0439 D5       		.byte	-43
 2644 043a A3       		.byte	-93
 2645 043b FF       		.byte	-1
 2646 043c 96       		.byte	-106
 2647 043d D5       		.byte	-43
 2648 043e A3       		.byte	-93
 2649 043f FF       		.byte	-1
 2650 0440 97       		.byte	-105
 2651 0441 D5       		.byte	-43
 2652 0442 A3       		.byte	-93
 2653 0443 FF       		.byte	-1
 2654 0444 97       		.byte	-105
 2655 0445 D5       		.byte	-43
 2656 0446 A3       		.byte	-93
 2657 0447 FF       		.byte	-1
 2658 0448 98       		.byte	-104
 2659 0449 D6       		.byte	-42
 2660 044a A3       		.byte	-93
 2661 044b FF       		.byte	-1
 2662 044c 99       		.byte	-103
 2663 044d D6       		.byte	-42
 2664 044e A3       		.byte	-93
 2665 044f FF       		.byte	-1
 2666 0450 99       		.byte	-103
 2667 0451 D6       		.byte	-42
 2668 0452 A3       		.byte	-93
 2669 0453 FF       		.byte	-1
 2670 0454 9A       		.byte	-102
 2671 0455 D6       		.byte	-42
 2672 0456 A3       		.byte	-93
 2673 0457 FF       		.byte	-1
 2674 0458 9A       		.byte	-102
 2675 0459 D6       		.byte	-42
 2676 045a A3       		.byte	-93
 2677 045b FF       		.byte	-1
 2678 045c 9B       		.byte	-101
 2679 045d D7       		.byte	-41
 2680 045e A3       		.byte	-93
 2681 045f FF       		.byte	-1
 2682 0460 9B       		.byte	-101
 2683 0461 D7       		.byte	-41
 2684 0462 A3       		.byte	-93
GAS LISTING /tmp/ccOaNtkH.s 			page 62


 2685 0463 FF       		.byte	-1
 2686 0464 9C       		.byte	-100
 2687 0465 D7       		.byte	-41
 2688 0466 A3       		.byte	-93
 2689 0467 FF       		.byte	-1
 2690 0468 9C       		.byte	-100
 2691 0469 D7       		.byte	-41
 2692 046a A3       		.byte	-93
 2693 046b FF       		.byte	-1
 2694 046c 9D       		.byte	-99
 2695 046d D7       		.byte	-41
 2696 046e A3       		.byte	-93
 2697 046f FF       		.byte	-1
 2698 0470 9D       		.byte	-99
 2699 0471 D8       		.byte	-40
 2700 0472 A3       		.byte	-93
 2701 0473 FF       		.byte	-1
 2702 0474 9E       		.byte	-98
 2703 0475 D8       		.byte	-40
 2704 0476 A3       		.byte	-93
 2705 0477 FF       		.byte	-1
 2706 0478 9E       		.byte	-98
 2707 0479 D8       		.byte	-40
 2708 047a A3       		.byte	-93
 2709 047b FF       		.byte	-1
 2710 047c 9F       		.byte	-97
 2711 047d D8       		.byte	-40
 2712 047e A3       		.byte	-93
 2713 047f FF       		.byte	-1
 2714 0480 A0       		.byte	-96
 2715 0481 D8       		.byte	-40
 2716 0482 A3       		.byte	-93
 2717 0483 FF       		.byte	-1
 2718 0484 A0       		.byte	-96
 2719 0485 D9       		.byte	-39
 2720 0486 A3       		.byte	-93
 2721 0487 FF       		.byte	-1
 2722 0488 A1       		.byte	-95
 2723 0489 D9       		.byte	-39
 2724 048a A3       		.byte	-93
 2725 048b FF       		.byte	-1
 2726 048c A1       		.byte	-95
 2727 048d D9       		.byte	-39
 2728 048e A3       		.byte	-93
 2729 048f FF       		.byte	-1
 2730 0490 A2       		.byte	-94
 2731 0491 D9       		.byte	-39
 2732 0492 A3       		.byte	-93
 2733 0493 FF       		.byte	-1
 2734 0494 A2       		.byte	-94
 2735 0495 D9       		.byte	-39
 2736 0496 A3       		.byte	-93
 2737 0497 FF       		.byte	-1
 2738 0498 A3       		.byte	-93
 2739 0499 DA       		.byte	-38
 2740 049a A3       		.byte	-93
 2741 049b FF       		.byte	-1
GAS LISTING /tmp/ccOaNtkH.s 			page 63


 2742 049c A3       		.byte	-93
 2743 049d DA       		.byte	-38
 2744 049e A3       		.byte	-93
 2745 049f FF       		.byte	-1
 2746 04a0 A4       		.byte	-92
 2747 04a1 DA       		.byte	-38
 2748 04a2 A3       		.byte	-93
 2749 04a3 FF       		.byte	-1
 2750 04a4 A4       		.byte	-92
 2751 04a5 DA       		.byte	-38
 2752 04a6 A3       		.byte	-93
 2753 04a7 FF       		.byte	-1
 2754 04a8 A5       		.byte	-91
 2755 04a9 DA       		.byte	-38
 2756 04aa A3       		.byte	-93
 2757 04ab FF       		.byte	-1
 2758 04ac A6       		.byte	-90
 2759 04ad DB       		.byte	-37
 2760 04ae A3       		.byte	-93
 2761 04af FF       		.byte	-1
 2762 04b0 A6       		.byte	-90
 2763 04b1 DB       		.byte	-37
 2764 04b2 A3       		.byte	-93
 2765 04b3 FF       		.byte	-1
 2766 04b4 A7       		.byte	-89
 2767 04b5 DB       		.byte	-37
 2768 04b6 A3       		.byte	-93
 2769 04b7 FF       		.byte	-1
 2770 04b8 A7       		.byte	-89
 2771 04b9 DB       		.byte	-37
 2772 04ba A3       		.byte	-93
 2773 04bb FF       		.byte	-1
 2774 04bc A8       		.byte	-88
 2775 04bd DB       		.byte	-37
 2776 04be A3       		.byte	-93
 2777 04bf FF       		.byte	-1
 2778 04c0 A8       		.byte	-88
 2779 04c1 DC       		.byte	-36
 2780 04c2 A3       		.byte	-93
 2781 04c3 FF       		.byte	-1
 2782 04c4 A9       		.byte	-87
 2783 04c5 DC       		.byte	-36
 2784 04c6 A3       		.byte	-93
 2785 04c7 FF       		.byte	-1
 2786 04c8 A9       		.byte	-87
 2787 04c9 DC       		.byte	-36
 2788 04ca A3       		.byte	-93
 2789 04cb FF       		.byte	-1
 2790 04cc AA       		.byte	-86
 2791 04cd DC       		.byte	-36
 2792 04ce A3       		.byte	-93
 2793 04cf FF       		.byte	-1
 2794 04d0 AA       		.byte	-86
 2795 04d1 DC       		.byte	-36
 2796 04d2 A3       		.byte	-93
 2797 04d3 FF       		.byte	-1
 2798 04d4 AB       		.byte	-85
GAS LISTING /tmp/ccOaNtkH.s 			page 64


 2799 04d5 DD       		.byte	-35
 2800 04d6 A3       		.byte	-93
 2801 04d7 FF       		.byte	-1
 2802 04d8 AB       		.byte	-85
 2803 04d9 DD       		.byte	-35
 2804 04da A3       		.byte	-93
 2805 04db FF       		.byte	-1
 2806 04dc AC       		.byte	-84
 2807 04dd DD       		.byte	-35
 2808 04de A3       		.byte	-93
 2809 04df FF       		.byte	-1
 2810 04e0 AC       		.byte	-84
 2811 04e1 DD       		.byte	-35
 2812 04e2 A3       		.byte	-93
 2813 04e3 FF       		.byte	-1
 2814 04e4 AC       		.byte	-84
 2815 04e5 DE       		.byte	-34
 2816 04e6 A3       		.byte	-93
 2817 04e7 FF       		.byte	-1
 2818 04e8 AD       		.byte	-83
 2819 04e9 DE       		.byte	-34
 2820 04ea A3       		.byte	-93
 2821 04eb FF       		.byte	-1
 2822 04ec AD       		.byte	-83
 2823 04ed DE       		.byte	-34
 2824 04ee A3       		.byte	-93
 2825 04ef FF       		.byte	-1
 2826 04f0 AD       		.byte	-83
 2827 04f1 DE       		.byte	-34
 2828 04f2 A3       		.byte	-93
 2829 04f3 FF       		.byte	-1
 2830 04f4 AE       		.byte	-82
 2831 04f5 DE       		.byte	-34
 2832 04f6 A3       		.byte	-93
 2833 04f7 FF       		.byte	-1
 2834 04f8 AE       		.byte	-82
 2835 04f9 DF       		.byte	-33
 2836 04fa A3       		.byte	-93
 2837 04fb FF       		.byte	-1
 2838 04fc AF       		.byte	-81
 2839 04fd DF       		.byte	-33
 2840 04fe A3       		.byte	-93
 2841 04ff FF       		.byte	-1
 2842 0500 AF       		.byte	-81
 2843 0501 DF       		.byte	-33
 2844 0502 A3       		.byte	-93
 2845 0503 FF       		.byte	-1
 2846 0504 AF       		.byte	-81
 2847 0505 DF       		.byte	-33
 2848 0506 A2       		.byte	-94
 2849 0507 FF       		.byte	-1
 2850 0508 B0       		.byte	-80
 2851 0509 DF       		.byte	-33
 2852 050a A2       		.byte	-94
 2853 050b FF       		.byte	-1
 2854 050c B0       		.byte	-80
 2855 050d E0       		.byte	-32
GAS LISTING /tmp/ccOaNtkH.s 			page 65


 2856 050e A2       		.byte	-94
 2857 050f FF       		.byte	-1
 2858 0510 B1       		.byte	-79
 2859 0511 E0       		.byte	-32
 2860 0512 A2       		.byte	-94
 2861 0513 FF       		.byte	-1
 2862 0514 B1       		.byte	-79
 2863 0515 E0       		.byte	-32
 2864 0516 A2       		.byte	-94
 2865 0517 FF       		.byte	-1
 2866 0518 B1       		.byte	-79
 2867 0519 E0       		.byte	-32
 2868 051a A2       		.byte	-94
 2869 051b FF       		.byte	-1
 2870 051c B2       		.byte	-78
 2871 051d E0       		.byte	-32
 2872 051e A2       		.byte	-94
 2873 051f FF       		.byte	-1
 2874 0520 B2       		.byte	-78
 2875 0521 E1       		.byte	-31
 2876 0522 A2       		.byte	-94
 2877 0523 FF       		.byte	-1
 2878 0524 B3       		.byte	-77
 2879 0525 E1       		.byte	-31
 2880 0526 A2       		.byte	-94
 2881 0527 FF       		.byte	-1
 2882 0528 B3       		.byte	-77
 2883 0529 E1       		.byte	-31
 2884 052a A2       		.byte	-94
 2885 052b FF       		.byte	-1
 2886 052c B3       		.byte	-77
 2887 052d E1       		.byte	-31
 2888 052e A2       		.byte	-94
 2889 052f FF       		.byte	-1
 2890 0530 B4       		.byte	-76
 2891 0531 E1       		.byte	-31
 2892 0532 A1       		.byte	-95
 2893 0533 FF       		.byte	-1
 2894 0534 B4       		.byte	-76
 2895 0535 E2       		.byte	-30
 2896 0536 A1       		.byte	-95
 2897 0537 FF       		.byte	-1
 2898 0538 B5       		.byte	-75
 2899 0539 E2       		.byte	-30
 2900 053a A1       		.byte	-95
 2901 053b FF       		.byte	-1
 2902 053c B5       		.byte	-75
 2903 053d E2       		.byte	-30
 2904 053e A1       		.byte	-95
 2905 053f FF       		.byte	-1
 2906 0540 B6       		.byte	-74
 2907 0541 E2       		.byte	-30
 2908 0542 A1       		.byte	-95
 2909 0543 FF       		.byte	-1
 2910 0544 B6       		.byte	-74
 2911 0545 E2       		.byte	-30
 2912 0546 A1       		.byte	-95
GAS LISTING /tmp/ccOaNtkH.s 			page 66


 2913 0547 FF       		.byte	-1
 2914 0548 B6       		.byte	-74
 2915 0549 E3       		.byte	-29
 2916 054a A1       		.byte	-95
 2917 054b FF       		.byte	-1
 2918 054c B7       		.byte	-73
 2919 054d E3       		.byte	-29
 2920 054e A1       		.byte	-95
 2921 054f FF       		.byte	-1
 2922 0550 B7       		.byte	-73
 2923 0551 E3       		.byte	-29
 2924 0552 A1       		.byte	-95
 2925 0553 FF       		.byte	-1
 2926 0554 B8       		.byte	-72
 2927 0555 E3       		.byte	-29
 2928 0556 A1       		.byte	-95
 2929 0557 FF       		.byte	-1
 2930 0558 B8       		.byte	-72
 2931 0559 E3       		.byte	-29
 2932 055a A0       		.byte	-96
 2933 055b FF       		.byte	-1
 2934 055c B9       		.byte	-71
 2935 055d E4       		.byte	-28
 2936 055e A0       		.byte	-96
 2937 055f FF       		.byte	-1
 2938 0560 B9       		.byte	-71
 2939 0561 E4       		.byte	-28
 2940 0562 A0       		.byte	-96
 2941 0563 FF       		.byte	-1
 2942 0564 B9       		.byte	-71
 2943 0565 E4       		.byte	-28
 2944 0566 A0       		.byte	-96
 2945 0567 FF       		.byte	-1
 2946 0568 BA       		.byte	-70
 2947 0569 E4       		.byte	-28
 2948 056a A0       		.byte	-96
 2949 056b FF       		.byte	-1
 2950 056c BA       		.byte	-70
 2951 056d E4       		.byte	-28
 2952 056e A0       		.byte	-96
 2953 056f FF       		.byte	-1
 2954 0570 BB       		.byte	-69
 2955 0571 E5       		.byte	-27
 2956 0572 A0       		.byte	-96
 2957 0573 FF       		.byte	-1
 2958 0574 BB       		.byte	-69
 2959 0575 E5       		.byte	-27
 2960 0576 A0       		.byte	-96
 2961 0577 FF       		.byte	-1
 2962 0578 BC       		.byte	-68
 2963 0579 E5       		.byte	-27
 2964 057a A0       		.byte	-96
 2965 057b FF       		.byte	-1
 2966 057c BC       		.byte	-68
 2967 057d E5       		.byte	-27
 2968 057e A0       		.byte	-96
 2969 057f FF       		.byte	-1
GAS LISTING /tmp/ccOaNtkH.s 			page 67


 2970 0580 BD       		.byte	-67
 2971 0581 E5       		.byte	-27
 2972 0582 9F       		.byte	-97
 2973 0583 FF       		.byte	-1
 2974 0584 BD       		.byte	-67
 2975 0585 E6       		.byte	-26
 2976 0586 9F       		.byte	-97
 2977 0587 FF       		.byte	-1
 2978 0588 BD       		.byte	-67
 2979 0589 E6       		.byte	-26
 2980 058a 9F       		.byte	-97
 2981 058b FF       		.byte	-1
 2982 058c BE       		.byte	-66
 2983 058d E6       		.byte	-26
 2984 058e 9F       		.byte	-97
 2985 058f FF       		.byte	-1
 2986 0590 BE       		.byte	-66
 2987 0591 E6       		.byte	-26
 2988 0592 9F       		.byte	-97
 2989 0593 FF       		.byte	-1
 2990 0594 BF       		.byte	-65
 2991 0595 E6       		.byte	-26
 2992 0596 9F       		.byte	-97
 2993 0597 FF       		.byte	-1
 2994 0598 BF       		.byte	-65
 2995 0599 E7       		.byte	-25
 2996 059a 9F       		.byte	-97
 2997 059b FF       		.byte	-1
 2998 059c C0       		.byte	-64
 2999 059d E7       		.byte	-25
 3000 059e 9F       		.byte	-97
 3001 059f FF       		.byte	-1
 3002 05a0 CC       		.byte	-52
 3003 05a1 EC       		.byte	-20
 3004 05a2 9C       		.byte	-100
 3005 05a3 FF       		.byte	-1
 3006 05a4 CD       		.byte	-51
 3007 05a5 EC       		.byte	-20
 3008 05a6 9C       		.byte	-100
 3009 05a7 FF       		.byte	-1
 3010 05a8 CD       		.byte	-51
 3011 05a9 EC       		.byte	-20
 3012 05aa 9C       		.byte	-100
 3013 05ab FF       		.byte	-1
 3014 05ac CD       		.byte	-51
 3015 05ad EC       		.byte	-20
 3016 05ae 9C       		.byte	-100
 3017 05af FF       		.byte	-1
 3018 05b0 CE       		.byte	-50
 3019 05b1 EC       		.byte	-20
 3020 05b2 9C       		.byte	-100
 3021 05b3 FF       		.byte	-1
 3022 05b4 CE       		.byte	-50
 3023 05b5 ED       		.byte	-19
 3024 05b6 9C       		.byte	-100
 3025 05b7 FF       		.byte	-1
 3026 05b8 CF       		.byte	-49
GAS LISTING /tmp/ccOaNtkH.s 			page 68


 3027 05b9 ED       		.byte	-19
 3028 05ba 9C       		.byte	-100
 3029 05bb FF       		.byte	-1
 3030 05bc CF       		.byte	-49
 3031 05bd ED       		.byte	-19
 3032 05be 9C       		.byte	-100
 3033 05bf FF       		.byte	-1
 3034 05c0 D0       		.byte	-48
 3035 05c1 ED       		.byte	-19
 3036 05c2 9C       		.byte	-100
 3037 05c3 FF       		.byte	-1
 3038 05c4 D0       		.byte	-48
 3039 05c5 ED       		.byte	-19
 3040 05c6 9B       		.byte	-101
 3041 05c7 FF       		.byte	-1
 3042 05c8 D1       		.byte	-47
 3043 05c9 EE       		.byte	-18
 3044 05ca 9B       		.byte	-101
 3045 05cb FF       		.byte	-1
 3046 05cc D1       		.byte	-47
 3047 05cd EE       		.byte	-18
 3048 05ce 9B       		.byte	-101
 3049 05cf FF       		.byte	-1
 3050 05d0 D2       		.byte	-46
 3051 05d1 EE       		.byte	-18
 3052 05d2 9B       		.byte	-101
 3053 05d3 FF       		.byte	-1
 3054 05d4 D2       		.byte	-46
 3055 05d5 EE       		.byte	-18
 3056 05d6 9B       		.byte	-101
 3057 05d7 FF       		.byte	-1
 3058 05d8 D3       		.byte	-45
 3059 05d9 EE       		.byte	-18
 3060 05da 9B       		.byte	-101
 3061 05db FF       		.byte	-1
 3062 05dc D3       		.byte	-45
 3063 05dd EE       		.byte	-18
 3064 05de 9B       		.byte	-101
 3065 05df FF       		.byte	-1
 3066 05e0 D4       		.byte	-44
 3067 05e1 EF       		.byte	-17
 3068 05e2 9B       		.byte	-101
 3069 05e3 FF       		.byte	-1
 3070 05e4 D4       		.byte	-44
 3071 05e5 EF       		.byte	-17
 3072 05e6 9B       		.byte	-101
 3073 05e7 FF       		.byte	-1
 3074 05e8 D5       		.byte	-43
 3075 05e9 EF       		.byte	-17
 3076 05ea 9B       		.byte	-101
 3077 05eb FF       		.byte	-1
 3078 05ec D5       		.byte	-43
 3079 05ed EF       		.byte	-17
 3080 05ee 9A       		.byte	-102
 3081 05ef FF       		.byte	-1
 3082 05f0 D6       		.byte	-42
 3083 05f1 EF       		.byte	-17
GAS LISTING /tmp/ccOaNtkH.s 			page 69


 3084 05f2 9A       		.byte	-102
 3085 05f3 FF       		.byte	-1
 3086 05f4 D6       		.byte	-42
 3087 05f5 F0       		.byte	-16
 3088 05f6 9A       		.byte	-102
 3089 05f7 FF       		.byte	-1
 3090 05f8 D7       		.byte	-41
 3091 05f9 F0       		.byte	-16
 3092 05fa 9A       		.byte	-102
 3093 05fb FF       		.byte	-1
 3094 05fc D7       		.byte	-41
 3095 05fd F0       		.byte	-16
 3096 05fe 9A       		.byte	-102
 3097 05ff FF       		.byte	-1
 3098 0600 D8       		.byte	-40
 3099 0601 F0       		.byte	-16
 3100 0602 9A       		.byte	-102
 3101 0603 FF       		.byte	-1
 3102 0604 D8       		.byte	-40
 3103 0605 F0       		.byte	-16
 3104 0606 9A       		.byte	-102
 3105 0607 FF       		.byte	-1
 3106 0608 D9       		.byte	-39
 3107 0609 F0       		.byte	-16
 3108 060a 9A       		.byte	-102
 3109 060b FF       		.byte	-1
 3110 060c D9       		.byte	-39
 3111 060d F1       		.byte	-15
 3112 060e 9A       		.byte	-102
 3113 060f FF       		.byte	-1
 3114 0610 DA       		.byte	-38
 3115 0611 F1       		.byte	-15
 3116 0612 9A       		.byte	-102
 3117 0613 FF       		.byte	-1
 3118 0614 DA       		.byte	-38
 3119 0615 F1       		.byte	-15
 3120 0616 99       		.byte	-103
 3121 0617 FF       		.byte	-1
 3122 0618 DB       		.byte	-37
 3123 0619 F1       		.byte	-15
 3124 061a 99       		.byte	-103
 3125 061b FF       		.byte	-1
 3126 061c DB       		.byte	-37
 3127 061d F1       		.byte	-15
 3128 061e 99       		.byte	-103
 3129 061f FF       		.byte	-1
 3130 0620 DC       		.byte	-36
 3131 0621 F1       		.byte	-15
 3132 0622 99       		.byte	-103
 3133 0623 FF       		.byte	-1
 3134 0624 DC       		.byte	-36
 3135 0625 F2       		.byte	-14
 3136 0626 99       		.byte	-103
 3137 0627 FF       		.byte	-1
 3138 0628 DD       		.byte	-35
 3139 0629 F2       		.byte	-14
 3140 062a 99       		.byte	-103
GAS LISTING /tmp/ccOaNtkH.s 			page 70


 3141 062b FF       		.byte	-1
 3142 062c DD       		.byte	-35
 3143 062d F2       		.byte	-14
 3144 062e 99       		.byte	-103
 3145 062f FF       		.byte	-1
 3146 0630 DE       		.byte	-34
 3147 0631 F2       		.byte	-14
 3148 0632 99       		.byte	-103
 3149 0633 FF       		.byte	-1
 3150 0634 DE       		.byte	-34
 3151 0635 F2       		.byte	-14
 3152 0636 99       		.byte	-103
 3153 0637 FF       		.byte	-1
 3154 0638 DF       		.byte	-33
 3155 0639 F2       		.byte	-14
 3156 063a 99       		.byte	-103
 3157 063b FF       		.byte	-1
 3158 063c DF       		.byte	-33
 3159 063d F3       		.byte	-13
 3160 063e 99       		.byte	-103
 3161 063f FF       		.byte	-1
 3162 0640 E0       		.byte	-32
 3163 0641 F3       		.byte	-13
 3164 0642 98       		.byte	-104
 3165 0643 FF       		.byte	-1
 3166 0644 E0       		.byte	-32
 3167 0645 F3       		.byte	-13
 3168 0646 98       		.byte	-104
 3169 0647 FF       		.byte	-1
 3170 0648 E1       		.byte	-31
 3171 0649 F3       		.byte	-13
 3172 064a 98       		.byte	-104
 3173 064b FF       		.byte	-1
 3174 064c E1       		.byte	-31
 3175 064d F3       		.byte	-13
 3176 064e 98       		.byte	-104
 3177 064f FF       		.byte	-1
 3178 0650 E2       		.byte	-30
 3179 0651 F3       		.byte	-13
 3180 0652 98       		.byte	-104
 3181 0653 FF       		.byte	-1
 3182 0654 E3       		.byte	-29
 3183 0655 F4       		.byte	-12
 3184 0656 98       		.byte	-104
 3185 0657 FF       		.byte	-1
 3186 0658 E3       		.byte	-29
 3187 0659 F4       		.byte	-12
 3188 065a 98       		.byte	-104
 3189 065b FF       		.byte	-1
 3190 065c E4       		.byte	-28
 3191 065d F4       		.byte	-12
 3192 065e 98       		.byte	-104
 3193 065f FF       		.byte	-1
 3194 0660 E4       		.byte	-28
 3195 0661 F4       		.byte	-12
 3196 0662 98       		.byte	-104
 3197 0663 FF       		.byte	-1
GAS LISTING /tmp/ccOaNtkH.s 			page 71


 3198 0664 E5       		.byte	-27
 3199 0665 F4       		.byte	-12
 3200 0666 98       		.byte	-104
 3201 0667 FF       		.byte	-1
 3202 0668 E5       		.byte	-27
 3203 0669 F4       		.byte	-12
 3204 066a 98       		.byte	-104
 3205 066b FF       		.byte	-1
 3206 066c E6       		.byte	-26
 3207 066d F4       		.byte	-12
 3208 066e 97       		.byte	-105
 3209 066f FF       		.byte	-1
 3210 0670 E6       		.byte	-26
 3211 0671 F4       		.byte	-12
 3212 0672 97       		.byte	-105
 3213 0673 FF       		.byte	-1
 3214 0674 E6       		.byte	-26
 3215 0675 F4       		.byte	-12
 3216 0676 97       		.byte	-105
 3217 0677 FF       		.byte	-1
 3218 0678 E6       		.byte	-26
 3219 0679 F4       		.byte	-12
 3220 067a 97       		.byte	-105
 3221 067b FF       		.byte	-1
 3222 067c E6       		.byte	-26
 3223 067d F4       		.byte	-12
 3224 067e 97       		.byte	-105
 3225 067f FF       		.byte	-1
 3226 0680 E6       		.byte	-26
 3227 0681 F4       		.byte	-12
 3228 0682 97       		.byte	-105
 3229 0683 FF       		.byte	-1
 3230 0684 E6       		.byte	-26
 3231 0685 F4       		.byte	-12
 3232 0686 97       		.byte	-105
 3233 0687 FF       		.byte	-1
 3234 0688 E6       		.byte	-26
 3235 0689 F4       		.byte	-12
 3236 068a 97       		.byte	-105
 3237 068b FF       		.byte	-1
 3238 068c E6       		.byte	-26
 3239 068d F4       		.byte	-12
 3240 068e 97       		.byte	-105
 3241 068f FF       		.byte	-1
 3242 0690 E7       		.byte	-25
 3243 0691 F4       		.byte	-12
 3244 0692 97       		.byte	-105
 3245 0693 FF       		.byte	-1
 3246 0694 E7       		.byte	-25
 3247 0695 F4       		.byte	-12
 3248 0696 97       		.byte	-105
 3249 0697 FF       		.byte	-1
 3250 0698 E7       		.byte	-25
 3251 0699 F4       		.byte	-12
 3252 069a 97       		.byte	-105
 3253 069b FF       		.byte	-1
 3254 069c E7       		.byte	-25
GAS LISTING /tmp/ccOaNtkH.s 			page 72


 3255 069d F3       		.byte	-13
 3256 069e 97       		.byte	-105
 3257 069f FF       		.byte	-1
 3258 06a0 E7       		.byte	-25
 3259 06a1 F3       		.byte	-13
 3260 06a2 97       		.byte	-105
 3261 06a3 FF       		.byte	-1
 3262 06a4 E7       		.byte	-25
 3263 06a5 F3       		.byte	-13
 3264 06a6 97       		.byte	-105
 3265 06a7 FF       		.byte	-1
 3266 06a8 E7       		.byte	-25
 3267 06a9 F3       		.byte	-13
 3268 06aa 97       		.byte	-105
 3269 06ab FF       		.byte	-1
 3270 06ac E7       		.byte	-25
 3271 06ad F3       		.byte	-13
 3272 06ae 96       		.byte	-106
 3273 06af FF       		.byte	-1
 3274 06b0 E7       		.byte	-25
 3275 06b1 F3       		.byte	-13
 3276 06b2 96       		.byte	-106
 3277 06b3 FF       		.byte	-1
 3278 06b4 E8       		.byte	-24
 3279 06b5 F3       		.byte	-13
 3280 06b6 96       		.byte	-106
 3281 06b7 FF       		.byte	-1
 3282 06b8 E8       		.byte	-24
 3283 06b9 F3       		.byte	-13
 3284 06ba 96       		.byte	-106
 3285 06bb FF       		.byte	-1
 3286 06bc E8       		.byte	-24
 3287 06bd F3       		.byte	-13
 3288 06be 96       		.byte	-106
 3289 06bf FF       		.byte	-1
 3290 06c0 E8       		.byte	-24
 3291 06c1 F3       		.byte	-13
 3292 06c2 96       		.byte	-106
 3293 06c3 FF       		.byte	-1
 3294 06c4 E8       		.byte	-24
 3295 06c5 F3       		.byte	-13
 3296 06c6 96       		.byte	-106
 3297 06c7 FF       		.byte	-1
 3298 06c8 E8       		.byte	-24
 3299 06c9 F3       		.byte	-13
 3300 06ca 96       		.byte	-106
 3301 06cb FF       		.byte	-1
 3302 06cc E8       		.byte	-24
 3303 06cd F3       		.byte	-13
 3304 06ce 96       		.byte	-106
 3305 06cf FF       		.byte	-1
 3306 06d0 E8       		.byte	-24
 3307 06d1 F2       		.byte	-14
 3308 06d2 96       		.byte	-106
 3309 06d3 FF       		.byte	-1
 3310 06d4 E8       		.byte	-24
 3311 06d5 F2       		.byte	-14
GAS LISTING /tmp/ccOaNtkH.s 			page 73


 3312 06d6 96       		.byte	-106
 3313 06d7 FF       		.byte	-1
 3314 06d8 E9       		.byte	-23
 3315 06d9 F2       		.byte	-14
 3316 06da 96       		.byte	-106
 3317 06db FF       		.byte	-1
 3318 06dc E9       		.byte	-23
 3319 06dd F2       		.byte	-14
 3320 06de 96       		.byte	-106
 3321 06df FF       		.byte	-1
 3322 06e0 E9       		.byte	-23
 3323 06e1 F2       		.byte	-14
 3324 06e2 96       		.byte	-106
 3325 06e3 FF       		.byte	-1
 3326 06e4 E9       		.byte	-23
 3327 06e5 F2       		.byte	-14
 3328 06e6 96       		.byte	-106
 3329 06e7 FF       		.byte	-1
 3330 06e8 E9       		.byte	-23
 3331 06e9 F2       		.byte	-14
 3332 06ea 96       		.byte	-106
 3333 06eb FF       		.byte	-1
 3334 06ec E9       		.byte	-23
 3335 06ed F2       		.byte	-14
 3336 06ee 96       		.byte	-106
 3337 06ef FF       		.byte	-1
 3338 06f0 E9       		.byte	-23
 3339 06f1 F2       		.byte	-14
 3340 06f2 96       		.byte	-106
 3341 06f3 FF       		.byte	-1
 3342 06f4 E9       		.byte	-23
 3343 06f5 F2       		.byte	-14
 3344 06f6 95       		.byte	-107
 3345 06f7 FF       		.byte	-1
 3346 06f8 E9       		.byte	-23
 3347 06f9 F2       		.byte	-14
 3348 06fa 95       		.byte	-107
 3349 06fb FF       		.byte	-1
 3350 06fc EA       		.byte	-22
 3351 06fd F2       		.byte	-14
 3352 06fe 95       		.byte	-107
 3353 06ff FF       		.byte	-1
 3354 0700 EA       		.byte	-22
 3355 0701 F1       		.byte	-15
 3356 0702 95       		.byte	-107
 3357 0703 FF       		.byte	-1
 3358 0704 EA       		.byte	-22
 3359 0705 F1       		.byte	-15
 3360 0706 95       		.byte	-107
 3361 0707 FF       		.byte	-1
 3362 0708 EA       		.byte	-22
 3363 0709 F1       		.byte	-15
 3364 070a 95       		.byte	-107
 3365 070b FF       		.byte	-1
 3366 070c EA       		.byte	-22
 3367 070d F1       		.byte	-15
 3368 070e 95       		.byte	-107
GAS LISTING /tmp/ccOaNtkH.s 			page 74


 3369 070f FF       		.byte	-1
 3370 0710 EA       		.byte	-22
 3371 0711 F1       		.byte	-15
 3372 0712 95       		.byte	-107
 3373 0713 FF       		.byte	-1
 3374 0714 EA       		.byte	-22
 3375 0715 F1       		.byte	-15
 3376 0716 95       		.byte	-107
 3377 0717 FF       		.byte	-1
 3378 0718 EA       		.byte	-22
 3379 0719 F1       		.byte	-15
 3380 071a 95       		.byte	-107
 3381 071b FF       		.byte	-1
 3382 071c EA       		.byte	-22
 3383 071d F1       		.byte	-15
 3384 071e 95       		.byte	-107
 3385 071f FF       		.byte	-1
 3386 0720 EB       		.byte	-21
 3387 0721 F1       		.byte	-15
 3388 0722 95       		.byte	-107
 3389 0723 FF       		.byte	-1
 3390 0724 EB       		.byte	-21
 3391 0725 F1       		.byte	-15
 3392 0726 95       		.byte	-107
 3393 0727 FF       		.byte	-1
 3394 0728 EB       		.byte	-21
 3395 0729 F1       		.byte	-15
 3396 072a 95       		.byte	-107
 3397 072b FF       		.byte	-1
 3398 072c EB       		.byte	-21
 3399 072d F1       		.byte	-15
 3400 072e 95       		.byte	-107
 3401 072f FF       		.byte	-1
 3402 0730 EB       		.byte	-21
 3403 0731 F0       		.byte	-16
 3404 0732 95       		.byte	-107
 3405 0733 FF       		.byte	-1
 3406 0734 EB       		.byte	-21
 3407 0735 F0       		.byte	-16
 3408 0736 95       		.byte	-107
 3409 0737 FF       		.byte	-1
 3410 0738 EB       		.byte	-21
 3411 0739 F0       		.byte	-16
 3412 073a 95       		.byte	-107
 3413 073b FF       		.byte	-1
 3414 073c EB       		.byte	-21
 3415 073d F0       		.byte	-16
 3416 073e 95       		.byte	-107
 3417 073f FF       		.byte	-1
 3418 0740 EB       		.byte	-21
 3419 0741 F0       		.byte	-16
 3420 0742 95       		.byte	-107
 3421 0743 FF       		.byte	-1
 3422 0744 EC       		.byte	-20
 3423 0745 F0       		.byte	-16
 3424 0746 94       		.byte	-108
 3425 0747 FF       		.byte	-1
GAS LISTING /tmp/ccOaNtkH.s 			page 75


 3426 0748 EC       		.byte	-20
 3427 0749 F0       		.byte	-16
 3428 074a 94       		.byte	-108
 3429 074b FF       		.byte	-1
 3430 074c EC       		.byte	-20
 3431 074d F0       		.byte	-16
 3432 074e 94       		.byte	-108
 3433 074f FF       		.byte	-1
 3434 0750 EC       		.byte	-20
 3435 0751 F0       		.byte	-16
 3436 0752 94       		.byte	-108
 3437 0753 FF       		.byte	-1
 3438 0754 EC       		.byte	-20
 3439 0755 F0       		.byte	-16
 3440 0756 94       		.byte	-108
 3441 0757 FF       		.byte	-1
 3442 0758 EC       		.byte	-20
 3443 0759 F0       		.byte	-16
 3444 075a 94       		.byte	-108
 3445 075b FF       		.byte	-1
 3446 075c EC       		.byte	-20
 3447 075d F0       		.byte	-16
 3448 075e 94       		.byte	-108
 3449 075f FF       		.byte	-1
 3450 0760 EC       		.byte	-20
 3451 0761 EF       		.byte	-17
 3452 0762 94       		.byte	-108
 3453 0763 FF       		.byte	-1
 3454 0764 EC       		.byte	-20
 3455 0765 EF       		.byte	-17
 3456 0766 94       		.byte	-108
 3457 0767 FF       		.byte	-1
 3458 0768 EC       		.byte	-20
 3459 0769 EF       		.byte	-17
 3460 076a 94       		.byte	-108
 3461 076b FF       		.byte	-1
 3462 076c ED       		.byte	-19
 3463 076d EF       		.byte	-17
 3464 076e 94       		.byte	-108
 3465 076f FF       		.byte	-1
 3466 0770 ED       		.byte	-19
 3467 0771 EF       		.byte	-17
 3468 0772 94       		.byte	-108
 3469 0773 FF       		.byte	-1
 3470 0774 ED       		.byte	-19
 3471 0775 EF       		.byte	-17
 3472 0776 94       		.byte	-108
 3473 0777 FF       		.byte	-1
 3474 0778 ED       		.byte	-19
 3475 0779 EF       		.byte	-17
 3476 077a 94       		.byte	-108
 3477 077b FF       		.byte	-1
 3478 077c ED       		.byte	-19
 3479 077d EF       		.byte	-17
 3480 077e 94       		.byte	-108
 3481 077f FF       		.byte	-1
 3482 0780 ED       		.byte	-19
GAS LISTING /tmp/ccOaNtkH.s 			page 76


 3483 0781 EF       		.byte	-17
 3484 0782 94       		.byte	-108
 3485 0783 FF       		.byte	-1
 3486 0784 ED       		.byte	-19
 3487 0785 EF       		.byte	-17
 3488 0786 94       		.byte	-108
 3489 0787 FF       		.byte	-1
 3490 0788 ED       		.byte	-19
 3491 0789 EF       		.byte	-17
 3492 078a 94       		.byte	-108
 3493 078b FF       		.byte	-1
 3494 078c ED       		.byte	-19
 3495 078d EF       		.byte	-17
 3496 078e 94       		.byte	-108
 3497 078f FF       		.byte	-1
 3498 0790 ED       		.byte	-19
 3499 0791 EE       		.byte	-18
 3500 0792 94       		.byte	-108
 3501 0793 FF       		.byte	-1
 3502 0794 EE       		.byte	-18
 3503 0795 EE       		.byte	-18
 3504 0796 94       		.byte	-108
 3505 0797 FF       		.byte	-1
 3506 0798 EE       		.byte	-18
 3507 0799 EE       		.byte	-18
 3508 079a 94       		.byte	-108
 3509 079b FF       		.byte	-1
 3510 079c EE       		.byte	-18
 3511 079d EE       		.byte	-18
 3512 079e 94       		.byte	-108
 3513 079f FF       		.byte	-1
 3514 07a0 EE       		.byte	-18
 3515 07a1 EE       		.byte	-18
 3516 07a2 94       		.byte	-108
 3517 07a3 FF       		.byte	-1
 3518 07a4 EE       		.byte	-18
 3519 07a5 EE       		.byte	-18
 3520 07a6 93       		.byte	-109
 3521 07a7 FF       		.byte	-1
 3522 07a8 EE       		.byte	-18
 3523 07a9 EE       		.byte	-18
 3524 07aa 93       		.byte	-109
 3525 07ab FF       		.byte	-1
 3526 07ac EE       		.byte	-18
 3527 07ad EE       		.byte	-18
 3528 07ae 93       		.byte	-109
 3529 07af FF       		.byte	-1
 3530 07b0 EE       		.byte	-18
 3531 07b1 EE       		.byte	-18
 3532 07b2 93       		.byte	-109
 3533 07b3 FF       		.byte	-1
 3534 07b4 EE       		.byte	-18
 3535 07b5 EE       		.byte	-18
 3536 07b6 93       		.byte	-109
 3537 07b7 FF       		.byte	-1
 3538 07b8 EE       		.byte	-18
 3539 07b9 EE       		.byte	-18
GAS LISTING /tmp/ccOaNtkH.s 			page 77


 3540 07ba 93       		.byte	-109
 3541 07bb FF       		.byte	-1
 3542 07bc EF       		.byte	-17
 3543 07bd EE       		.byte	-18
 3544 07be 93       		.byte	-109
 3545 07bf FF       		.byte	-1
 3546 07c0 EF       		.byte	-17
 3547 07c1 ED       		.byte	-19
 3548 07c2 93       		.byte	-109
 3549 07c3 FF       		.byte	-1
 3550 07c4 EF       		.byte	-17
 3551 07c5 ED       		.byte	-19
 3552 07c6 93       		.byte	-109
 3553 07c7 FF       		.byte	-1
 3554 07c8 EF       		.byte	-17
 3555 07c9 ED       		.byte	-19
 3556 07ca 93       		.byte	-109
 3557 07cb FF       		.byte	-1
 3558 07cc EF       		.byte	-17
 3559 07cd ED       		.byte	-19
 3560 07ce 93       		.byte	-109
 3561 07cf FF       		.byte	-1
 3562 07d0 EF       		.byte	-17
 3563 07d1 ED       		.byte	-19
 3564 07d2 93       		.byte	-109
 3565 07d3 FF       		.byte	-1
 3566 07d4 EF       		.byte	-17
 3567 07d5 ED       		.byte	-19
 3568 07d6 93       		.byte	-109
 3569 07d7 FF       		.byte	-1
 3570 07d8 EF       		.byte	-17
 3571 07d9 ED       		.byte	-19
 3572 07da 93       		.byte	-109
 3573 07db FF       		.byte	-1
 3574 07dc EF       		.byte	-17
 3575 07dd ED       		.byte	-19
 3576 07de 93       		.byte	-109
 3577 07df FF       		.byte	-1
 3578 07e0 EF       		.byte	-17
 3579 07e1 ED       		.byte	-19
 3580 07e2 93       		.byte	-109
 3581 07e3 FF       		.byte	-1
 3582 07e4 F0       		.byte	-16
 3583 07e5 ED       		.byte	-19
 3584 07e6 93       		.byte	-109
 3585 07e7 FF       		.byte	-1
 3586 07e8 F0       		.byte	-16
 3587 07e9 ED       		.byte	-19
 3588 07ea 93       		.byte	-109
 3589 07eb FF       		.byte	-1
 3590 07ec F0       		.byte	-16
 3591 07ed ED       		.byte	-19
 3592 07ee 93       		.byte	-109
 3593 07ef FF       		.byte	-1
 3594 07f0 F0       		.byte	-16
 3595 07f1 EC       		.byte	-20
 3596 07f2 93       		.byte	-109
GAS LISTING /tmp/ccOaNtkH.s 			page 78


 3597 07f3 FF       		.byte	-1
 3598 07f4 F0       		.byte	-16
 3599 07f5 EC       		.byte	-20
 3600 07f6 93       		.byte	-109
 3601 07f7 FF       		.byte	-1
 3602 07f8 F0       		.byte	-16
 3603 07f9 EC       		.byte	-20
 3604 07fa 93       		.byte	-109
 3605 07fb FF       		.byte	-1
 3606 07fc F0       		.byte	-16
 3607 07fd EC       		.byte	-20
 3608 07fe 93       		.byte	-109
 3609 07ff FF       		.byte	-1
 3610 0800 F0       		.byte	-16
 3611 0801 EC       		.byte	-20
 3612 0802 93       		.byte	-109
 3613 0803 FF       		.byte	-1
 3614 0804 F5       		.byte	-11
 3615 0805 E8       		.byte	-24
 3616 0806 91       		.byte	-111
 3617 0807 FF       		.byte	-1
 3618 0808 F5       		.byte	-11
 3619 0809 E8       		.byte	-24
 3620 080a 91       		.byte	-111
 3621 080b FF       		.byte	-1
 3622 080c F5       		.byte	-11
 3623 080d E8       		.byte	-24
 3624 080e 91       		.byte	-111
 3625 080f FF       		.byte	-1
 3626 0810 F5       		.byte	-11
 3627 0811 E8       		.byte	-24
 3628 0812 91       		.byte	-111
 3629 0813 FF       		.byte	-1
 3630 0814 F5       		.byte	-11
 3631 0815 E8       		.byte	-24
 3632 0816 91       		.byte	-111
 3633 0817 FF       		.byte	-1
 3634 0818 F6       		.byte	-10
 3635 0819 E7       		.byte	-25
 3636 081a 91       		.byte	-111
 3637 081b FF       		.byte	-1
 3638 081c F6       		.byte	-10
 3639 081d E7       		.byte	-25
 3640 081e 91       		.byte	-111
 3641 081f FF       		.byte	-1
 3642 0820 F6       		.byte	-10
 3643 0821 E7       		.byte	-25
 3644 0822 91       		.byte	-111
 3645 0823 FF       		.byte	-1
 3646 0824 F6       		.byte	-10
 3647 0825 E7       		.byte	-25
 3648 0826 91       		.byte	-111
 3649 0827 FF       		.byte	-1
 3650 0828 F6       		.byte	-10
 3651 0829 E7       		.byte	-25
 3652 082a 91       		.byte	-111
 3653 082b FF       		.byte	-1
GAS LISTING /tmp/ccOaNtkH.s 			page 79


 3654 082c F6       		.byte	-10
 3655 082d E7       		.byte	-25
 3656 082e 91       		.byte	-111
 3657 082f FF       		.byte	-1
 3658 0830 F6       		.byte	-10
 3659 0831 E7       		.byte	-25
 3660 0832 91       		.byte	-111
 3661 0833 FF       		.byte	-1
 3662 0834 F6       		.byte	-10
 3663 0835 E7       		.byte	-25
 3664 0836 91       		.byte	-111
 3665 0837 FF       		.byte	-1
 3666 0838 F6       		.byte	-10
 3667 0839 E7       		.byte	-25
 3668 083a 91       		.byte	-111
 3669 083b FF       		.byte	-1
 3670 083c F6       		.byte	-10
 3671 083d E7       		.byte	-25
 3672 083e 91       		.byte	-111
 3673 083f FF       		.byte	-1
 3674 0840 F6       		.byte	-10
 3675 0841 E7       		.byte	-25
 3676 0842 91       		.byte	-111
 3677 0843 FF       		.byte	-1
 3678 0844 F7       		.byte	-9
 3679 0845 E7       		.byte	-25
 3680 0846 91       		.byte	-111
 3681 0847 FF       		.byte	-1
 3682 0848 F7       		.byte	-9
 3683 0849 E6       		.byte	-26
 3684 084a 91       		.byte	-111
 3685 084b FF       		.byte	-1
 3686 084c F7       		.byte	-9
 3687 084d E6       		.byte	-26
 3688 084e 91       		.byte	-111
 3689 084f FF       		.byte	-1
 3690 0850 F7       		.byte	-9
 3691 0851 E6       		.byte	-26
 3692 0852 91       		.byte	-111
 3693 0853 FF       		.byte	-1
 3694 0854 F7       		.byte	-9
 3695 0855 E6       		.byte	-26
 3696 0856 91       		.byte	-111
 3697 0857 FF       		.byte	-1
 3698 0858 F7       		.byte	-9
 3699 0859 E6       		.byte	-26
 3700 085a 90       		.byte	-112
 3701 085b FF       		.byte	-1
 3702 085c F7       		.byte	-9
 3703 085d E6       		.byte	-26
 3704 085e 90       		.byte	-112
 3705 085f FF       		.byte	-1
 3706 0860 F7       		.byte	-9
 3707 0861 E6       		.byte	-26
 3708 0862 90       		.byte	-112
 3709 0863 FF       		.byte	-1
 3710 0864 F7       		.byte	-9
GAS LISTING /tmp/ccOaNtkH.s 			page 80


 3711 0865 E6       		.byte	-26
 3712 0866 90       		.byte	-112
 3713 0867 FF       		.byte	-1
 3714 0868 F7       		.byte	-9
 3715 0869 E6       		.byte	-26
 3716 086a 90       		.byte	-112
 3717 086b FF       		.byte	-1
 3718 086c F7       		.byte	-9
 3719 086d E6       		.byte	-26
 3720 086e 90       		.byte	-112
 3721 086f FF       		.byte	-1
 3722 0870 F8       		.byte	-8
 3723 0871 E6       		.byte	-26
 3724 0872 90       		.byte	-112
 3725 0873 FF       		.byte	-1
 3726 0874 F8       		.byte	-8
 3727 0875 E6       		.byte	-26
 3728 0876 90       		.byte	-112
 3729 0877 FF       		.byte	-1
 3730 0878 F8       		.byte	-8
 3731 0879 E5       		.byte	-27
 3732 087a 90       		.byte	-112
 3733 087b FF       		.byte	-1
 3734 087c F8       		.byte	-8
 3735 087d E5       		.byte	-27
 3736 087e 90       		.byte	-112
 3737 087f FF       		.byte	-1
 3738 0880 F8       		.byte	-8
 3739 0881 E5       		.byte	-27
 3740 0882 90       		.byte	-112
 3741 0883 FF       		.byte	-1
 3742 0884 F8       		.byte	-8
 3743 0885 E5       		.byte	-27
 3744 0886 90       		.byte	-112
 3745 0887 FF       		.byte	-1
 3746 0888 F8       		.byte	-8
 3747 0889 E5       		.byte	-27
 3748 088a 90       		.byte	-112
 3749 088b FF       		.byte	-1
 3750 088c F8       		.byte	-8
 3751 088d E5       		.byte	-27
 3752 088e 90       		.byte	-112
 3753 088f FF       		.byte	-1
 3754 0890 F8       		.byte	-8
 3755 0891 E5       		.byte	-27
 3756 0892 90       		.byte	-112
 3757 0893 FF       		.byte	-1
 3758 0894 F8       		.byte	-8
 3759 0895 E5       		.byte	-27
 3760 0896 90       		.byte	-112
 3761 0897 FF       		.byte	-1
 3762 0898 F8       		.byte	-8
 3763 0899 E5       		.byte	-27
 3764 089a 90       		.byte	-112
 3765 089b FF       		.byte	-1
 3766 089c F8       		.byte	-8
 3767 089d E5       		.byte	-27
GAS LISTING /tmp/ccOaNtkH.s 			page 81


 3768 089e 90       		.byte	-112
 3769 089f FF       		.byte	-1
 3770 08a0 F9       		.byte	-7
 3771 08a1 E5       		.byte	-27
 3772 08a2 90       		.byte	-112
 3773 08a3 FF       		.byte	-1
 3774 08a4 F9       		.byte	-7
 3775 08a5 E5       		.byte	-27
 3776 08a6 90       		.byte	-112
 3777 08a7 FF       		.byte	-1
 3778 08a8 F9       		.byte	-7
 3779 08a9 E5       		.byte	-27
 3780 08aa 90       		.byte	-112
 3781 08ab FF       		.byte	-1
 3782 08ac F9       		.byte	-7
 3783 08ad E4       		.byte	-28
 3784 08ae 90       		.byte	-112
 3785 08af FF       		.byte	-1
 3786 08b0 F9       		.byte	-7
 3787 08b1 E4       		.byte	-28
 3788 08b2 90       		.byte	-112
 3789 08b3 FF       		.byte	-1
 3790 08b4 F9       		.byte	-7
 3791 08b5 E4       		.byte	-28
 3792 08b6 90       		.byte	-112
 3793 08b7 FF       		.byte	-1
 3794 08b8 F9       		.byte	-7
 3795 08b9 E4       		.byte	-28
 3796 08ba 90       		.byte	-112
 3797 08bb FF       		.byte	-1
 3798 08bc F9       		.byte	-7
 3799 08bd E4       		.byte	-28
 3800 08be 90       		.byte	-112
 3801 08bf FF       		.byte	-1
 3802 08c0 F9       		.byte	-7
 3803 08c1 E4       		.byte	-28
 3804 08c2 90       		.byte	-112
 3805 08c3 FF       		.byte	-1
 3806 08c4 F9       		.byte	-7
 3807 08c5 E4       		.byte	-28
 3808 08c6 90       		.byte	-112
 3809 08c7 FF       		.byte	-1
 3810 08c8 F9       		.byte	-7
 3811 08c9 E4       		.byte	-28
 3812 08ca 90       		.byte	-112
 3813 08cb FF       		.byte	-1
 3814 08cc F9       		.byte	-7
 3815 08cd E4       		.byte	-28
 3816 08ce 90       		.byte	-112
 3817 08cf FF       		.byte	-1
 3818 08d0 FA       		.byte	-6
 3819 08d1 E4       		.byte	-28
 3820 08d2 90       		.byte	-112
 3821 08d3 FF       		.byte	-1
 3822 08d4 FA       		.byte	-6
 3823 08d5 E4       		.byte	-28
 3824 08d6 90       		.byte	-112
GAS LISTING /tmp/ccOaNtkH.s 			page 82


 3825 08d7 FF       		.byte	-1
 3826 08d8 FA       		.byte	-6
 3827 08d9 E4       		.byte	-28
 3828 08da 90       		.byte	-112
 3829 08db FF       		.byte	-1
 3830 08dc FA       		.byte	-6
 3831 08dd E3       		.byte	-29
 3832 08de 90       		.byte	-112
 3833 08df FF       		.byte	-1
 3834 08e0 FA       		.byte	-6
 3835 08e1 E3       		.byte	-29
 3836 08e2 90       		.byte	-112
 3837 08e3 FF       		.byte	-1
 3838 08e4 FA       		.byte	-6
 3839 08e5 E3       		.byte	-29
 3840 08e6 90       		.byte	-112
 3841 08e7 FF       		.byte	-1
 3842 08e8 FA       		.byte	-6
 3843 08e9 E3       		.byte	-29
 3844 08ea 90       		.byte	-112
 3845 08eb FF       		.byte	-1
 3846 08ec FA       		.byte	-6
 3847 08ed E3       		.byte	-29
 3848 08ee 90       		.byte	-112
 3849 08ef FF       		.byte	-1
 3850 08f0 FA       		.byte	-6
 3851 08f1 E3       		.byte	-29
 3852 08f2 90       		.byte	-112
 3853 08f3 FF       		.byte	-1
 3854 08f4 FA       		.byte	-6
 3855 08f5 E3       		.byte	-29
 3856 08f6 90       		.byte	-112
 3857 08f7 FF       		.byte	-1
 3858 08f8 FA       		.byte	-6
 3859 08f9 E3       		.byte	-29
 3860 08fa 90       		.byte	-112
 3861 08fb FF       		.byte	-1
 3862 08fc FA       		.byte	-6
 3863 08fd E3       		.byte	-29
 3864 08fe 90       		.byte	-112
 3865 08ff FF       		.byte	-1
 3866 0900 FB       		.byte	-5
 3867 0901 E3       		.byte	-29
 3868 0902 90       		.byte	-112
 3869 0903 FF       		.byte	-1
 3870 0904 FB       		.byte	-5
 3871 0905 E3       		.byte	-29
 3872 0906 90       		.byte	-112
 3873 0907 FF       		.byte	-1
 3874 0908 FB       		.byte	-5
 3875 0909 E3       		.byte	-29
 3876 090a 90       		.byte	-112
 3877 090b FF       		.byte	-1
 3878 090c FB       		.byte	-5
 3879 090d E2       		.byte	-30
 3880 090e 90       		.byte	-112
 3881 090f FF       		.byte	-1
GAS LISTING /tmp/ccOaNtkH.s 			page 83


 3882 0910 FB       		.byte	-5
 3883 0911 E2       		.byte	-30
 3884 0912 90       		.byte	-112
 3885 0913 FF       		.byte	-1
 3886 0914 FB       		.byte	-5
 3887 0915 E2       		.byte	-30
 3888 0916 90       		.byte	-112
 3889 0917 FF       		.byte	-1
 3890 0918 FB       		.byte	-5
 3891 0919 E2       		.byte	-30
 3892 091a 90       		.byte	-112
 3893 091b FF       		.byte	-1
 3894 091c FB       		.byte	-5
 3895 091d E2       		.byte	-30
 3896 091e 90       		.byte	-112
 3897 091f FF       		.byte	-1
 3898 0920 FB       		.byte	-5
 3899 0921 E2       		.byte	-30
 3900 0922 90       		.byte	-112
 3901 0923 FF       		.byte	-1
 3902 0924 FB       		.byte	-5
 3903 0925 E2       		.byte	-30
 3904 0926 90       		.byte	-112
 3905 0927 FF       		.byte	-1
 3906 0928 FB       		.byte	-5
 3907 0929 E2       		.byte	-30
 3908 092a 90       		.byte	-112
 3909 092b FF       		.byte	-1
 3910 092c FB       		.byte	-5
 3911 092d E2       		.byte	-30
 3912 092e 90       		.byte	-112
 3913 092f FF       		.byte	-1
 3914 0930 FB       		.byte	-5
 3915 0931 E2       		.byte	-30
 3916 0932 90       		.byte	-112
 3917 0933 FF       		.byte	-1
 3918 0934 FC       		.byte	-4
 3919 0935 E2       		.byte	-30
 3920 0936 90       		.byte	-112
 3921 0937 FF       		.byte	-1
 3922 0938 FC       		.byte	-4
 3923 0939 E2       		.byte	-30
 3924 093a 90       		.byte	-112
 3925 093b FF       		.byte	-1
 3926 093c FC       		.byte	-4
 3927 093d E1       		.byte	-31
 3928 093e 90       		.byte	-112
 3929 093f FF       		.byte	-1
 3930 0940 FC       		.byte	-4
 3931 0941 E1       		.byte	-31
 3932 0942 90       		.byte	-112
 3933 0943 FF       		.byte	-1
 3934 0944 FC       		.byte	-4
 3935 0945 E1       		.byte	-31
 3936 0946 90       		.byte	-112
 3937 0947 FF       		.byte	-1
 3938 0948 FC       		.byte	-4
GAS LISTING /tmp/ccOaNtkH.s 			page 84


 3939 0949 E1       		.byte	-31
 3940 094a 90       		.byte	-112
 3941 094b FF       		.byte	-1
 3942 094c FC       		.byte	-4
 3943 094d E1       		.byte	-31
 3944 094e 90       		.byte	-112
 3945 094f FF       		.byte	-1
 3946 0950 FC       		.byte	-4
 3947 0951 E1       		.byte	-31
 3948 0952 90       		.byte	-112
 3949 0953 FF       		.byte	-1
 3950 0954 FC       		.byte	-4
 3951 0955 E1       		.byte	-31
 3952 0956 90       		.byte	-112
 3953 0957 FF       		.byte	-1
 3954 0958 FC       		.byte	-4
 3955 0959 E1       		.byte	-31
 3956 095a 90       		.byte	-112
 3957 095b FF       		.byte	-1
 3958 095c FC       		.byte	-4
 3959 095d E1       		.byte	-31
 3960 095e 90       		.byte	-112
 3961 095f FF       		.byte	-1
 3962 0960 FC       		.byte	-4
 3963 0961 E1       		.byte	-31
 3964 0962 90       		.byte	-112
 3965 0963 FF       		.byte	-1
 3966 0964 FC       		.byte	-4
 3967 0965 E1       		.byte	-31
 3968 0966 90       		.byte	-112
 3969 0967 FF       		.byte	-1
 3970 0968 FD       		.byte	-3
 3971 0969 E1       		.byte	-31
 3972 096a 90       		.byte	-112
 3973 096b FF       		.byte	-1
 3974 096c FD       		.byte	-3
 3975 096d E1       		.byte	-31
 3976 096e 90       		.byte	-112
 3977 096f FF       		.byte	-1
 3978 0970 FD       		.byte	-3
 3979 0971 E0       		.byte	-32
 3980 0972 90       		.byte	-112
 3981 0973 FF       		.byte	-1
 3982 0974 FD       		.byte	-3
 3983 0975 E0       		.byte	-32
 3984 0976 90       		.byte	-112
 3985 0977 FF       		.byte	-1
 3986 0978 FD       		.byte	-3
 3987 0979 E0       		.byte	-32
 3988 097a 90       		.byte	-112
 3989 097b FF       		.byte	-1
 3990 097c FD       		.byte	-3
 3991 097d E0       		.byte	-32
 3992 097e 90       		.byte	-112
 3993 097f FF       		.byte	-1
 3994 0980 FD       		.byte	-3
 3995 0981 E0       		.byte	-32
GAS LISTING /tmp/ccOaNtkH.s 			page 85


 3996 0982 90       		.byte	-112
 3997 0983 FF       		.byte	-1
 3998 0984 FD       		.byte	-3
 3999 0985 E0       		.byte	-32
 4000 0986 90       		.byte	-112
 4001 0987 FF       		.byte	-1
 4002 0988 FD       		.byte	-3
 4003 0989 E0       		.byte	-32
 4004 098a 90       		.byte	-112
 4005 098b FF       		.byte	-1
 4006 098c FD       		.byte	-3
 4007 098d E0       		.byte	-32
 4008 098e 90       		.byte	-112
 4009 098f FF       		.byte	-1
 4010 0990 FD       		.byte	-3
 4011 0991 E0       		.byte	-32
 4012 0992 90       		.byte	-112
 4013 0993 FF       		.byte	-1
 4014 0994 FD       		.byte	-3
 4015 0995 E0       		.byte	-32
 4016 0996 90       		.byte	-112
 4017 0997 FF       		.byte	-1
 4018 0998 FD       		.byte	-3
 4019 0999 E0       		.byte	-32
 4020 099a 90       		.byte	-112
 4021 099b FF       		.byte	-1
 4022 099c FD       		.byte	-3
 4023 099d E0       		.byte	-32
 4024 099e 90       		.byte	-112
 4025 099f FF       		.byte	-1
 4026 09a0 FD       		.byte	-3
 4027 09a1 DF       		.byte	-33
 4028 09a2 8F       		.byte	-113
 4029 09a3 FF       		.byte	-1
 4030 09a4 FD       		.byte	-3
 4031 09a5 DF       		.byte	-33
 4032 09a6 8F       		.byte	-113
 4033 09a7 FF       		.byte	-1
 4034 09a8 FD       		.byte	-3
 4035 09a9 DF       		.byte	-33
 4036 09aa 8E       		.byte	-114
 4037 09ab FF       		.byte	-1
 4038 09ac FD       		.byte	-3
 4039 09ad DE       		.byte	-34
 4040 09ae 8E       		.byte	-114
 4041 09af FF       		.byte	-1
 4042 09b0 FD       		.byte	-3
 4043 09b1 DE       		.byte	-34
 4044 09b2 8D       		.byte	-115
 4045 09b3 FF       		.byte	-1
 4046 09b4 FD       		.byte	-3
 4047 09b5 DD       		.byte	-35
 4048 09b6 8D       		.byte	-115
 4049 09b7 FF       		.byte	-1
 4050 09b8 FD       		.byte	-3
 4051 09b9 DD       		.byte	-35
 4052 09ba 8D       		.byte	-115
GAS LISTING /tmp/ccOaNtkH.s 			page 86


 4053 09bb FF       		.byte	-1
 4054 09bc FD       		.byte	-3
 4055 09bd DD       		.byte	-35
 4056 09be 8C       		.byte	-116
 4057 09bf FF       		.byte	-1
 4058 09c0 FD       		.byte	-3
 4059 09c1 DC       		.byte	-36
 4060 09c2 8C       		.byte	-116
 4061 09c3 FF       		.byte	-1
 4062 09c4 FD       		.byte	-3
 4063 09c5 DC       		.byte	-36
 4064 09c6 8B       		.byte	-117
 4065 09c7 FF       		.byte	-1
 4066 09c8 FD       		.byte	-3
 4067 09c9 DC       		.byte	-36
 4068 09ca 8B       		.byte	-117
 4069 09cb FF       		.byte	-1
 4070 09cc FD       		.byte	-3
 4071 09cd DB       		.byte	-37
 4072 09ce 8A       		.byte	-118
 4073 09cf FF       		.byte	-1
 4074 09d0 FD       		.byte	-3
 4075 09d1 DB       		.byte	-37
 4076 09d2 8A       		.byte	-118
 4077 09d3 FF       		.byte	-1
 4078 09d4 FD       		.byte	-3
 4079 09d5 DA       		.byte	-38
 4080 09d6 8A       		.byte	-118
 4081 09d7 FF       		.byte	-1
 4082 09d8 FD       		.byte	-3
 4083 09d9 DA       		.byte	-38
 4084 09da 89       		.byte	-119
 4085 09db FF       		.byte	-1
 4086 09dc FD       		.byte	-3
 4087 09dd DA       		.byte	-38
 4088 09de 89       		.byte	-119
 4089 09df FF       		.byte	-1
 4090 09e0 FD       		.byte	-3
 4091 09e1 D9       		.byte	-39
 4092 09e2 88       		.byte	-120
 4093 09e3 FF       		.byte	-1
 4094 09e4 FD       		.byte	-3
 4095 09e5 D9       		.byte	-39
 4096 09e6 88       		.byte	-120
 4097 09e7 FF       		.byte	-1
 4098 09e8 FD       		.byte	-3
 4099 09e9 D9       		.byte	-39
 4100 09ea 87       		.byte	-121
 4101 09eb FF       		.byte	-1
 4102 09ec FD       		.byte	-3
 4103 09ed D8       		.byte	-40
 4104 09ee 87       		.byte	-121
 4105 09ef FF       		.byte	-1
 4106 09f0 FD       		.byte	-3
 4107 09f1 D8       		.byte	-40
 4108 09f2 87       		.byte	-121
 4109 09f3 FF       		.byte	-1
GAS LISTING /tmp/ccOaNtkH.s 			page 87


 4110 09f4 FD       		.byte	-3
 4111 09f5 D7       		.byte	-41
 4112 09f6 86       		.byte	-122
 4113 09f7 FF       		.byte	-1
 4114 09f8 FD       		.byte	-3
 4115 09f9 D7       		.byte	-41
 4116 09fa 86       		.byte	-122
 4117 09fb FF       		.byte	-1
 4118 09fc FD       		.byte	-3
 4119 09fd D7       		.byte	-41
 4120 09fe 85       		.byte	-123
 4121 09ff FF       		.byte	-1
 4122 0a00 FD       		.byte	-3
 4123 0a01 D6       		.byte	-42
 4124 0a02 85       		.byte	-123
 4125 0a03 FF       		.byte	-1
 4126 0a04 FD       		.byte	-3
 4127 0a05 D6       		.byte	-42
 4128 0a06 85       		.byte	-123
 4129 0a07 FF       		.byte	-1
 4130 0a08 FD       		.byte	-3
 4131 0a09 D6       		.byte	-42
 4132 0a0a 84       		.byte	-124
 4133 0a0b FF       		.byte	-1
 4134 0a0c FD       		.byte	-3
 4135 0a0d D5       		.byte	-43
 4136 0a0e 84       		.byte	-124
 4137 0a0f FF       		.byte	-1
 4138 0a10 FD       		.byte	-3
 4139 0a11 D5       		.byte	-43
 4140 0a12 83       		.byte	-125
 4141 0a13 FF       		.byte	-1
 4142 0a14 FD       		.byte	-3
 4143 0a15 D4       		.byte	-44
 4144 0a16 83       		.byte	-125
 4145 0a17 FF       		.byte	-1
 4146 0a18 FD       		.byte	-3
 4147 0a19 D4       		.byte	-44
 4148 0a1a 83       		.byte	-125
 4149 0a1b FF       		.byte	-1
 4150 0a1c FD       		.byte	-3
 4151 0a1d D4       		.byte	-44
 4152 0a1e 82       		.byte	-126
 4153 0a1f FF       		.byte	-1
 4154 0a20 FD       		.byte	-3
 4155 0a21 D3       		.byte	-45
 4156 0a22 82       		.byte	-126
 4157 0a23 FF       		.byte	-1
 4158 0a24 FD       		.byte	-3
 4159 0a25 D3       		.byte	-45
 4160 0a26 81       		.byte	-127
 4161 0a27 FF       		.byte	-1
 4162 0a28 FD       		.byte	-3
 4163 0a29 D3       		.byte	-45
 4164 0a2a 81       		.byte	-127
 4165 0a2b FF       		.byte	-1
 4166 0a2c FD       		.byte	-3
GAS LISTING /tmp/ccOaNtkH.s 			page 88


 4167 0a2d D2       		.byte	-46
 4168 0a2e 81       		.byte	-127
 4169 0a2f FF       		.byte	-1
 4170 0a30 FD       		.byte	-3
 4171 0a31 D2       		.byte	-46
 4172 0a32 80       		.byte	-128
 4173 0a33 FF       		.byte	-1
 4174 0a34 FD       		.byte	-3
 4175 0a35 D1       		.byte	-47
 4176 0a36 80       		.byte	-128
 4177 0a37 FF       		.byte	-1
 4178 0a38 FD       		.byte	-3
 4179 0a39 D1       		.byte	-47
 4180 0a3a 7F       		.byte	127
 4181 0a3b FF       		.byte	-1
 4182 0a3c FD       		.byte	-3
 4183 0a3d D1       		.byte	-47
 4184 0a3e 7F       		.byte	127
 4185 0a3f FF       		.byte	-1
 4186 0a40 FD       		.byte	-3
 4187 0a41 D0       		.byte	-48
 4188 0a42 7F       		.byte	127
 4189 0a43 FF       		.byte	-1
 4190 0a44 FD       		.byte	-3
 4191 0a45 D0       		.byte	-48
 4192 0a46 7E       		.byte	126
 4193 0a47 FF       		.byte	-1
 4194 0a48 FD       		.byte	-3
 4195 0a49 CF       		.byte	-49
 4196 0a4a 7E       		.byte	126
 4197 0a4b FF       		.byte	-1
 4198 0a4c FD       		.byte	-3
 4199 0a4d CF       		.byte	-49
 4200 0a4e 7D       		.byte	125
 4201 0a4f FF       		.byte	-1
 4202 0a50 FD       		.byte	-3
 4203 0a51 CF       		.byte	-49
 4204 0a52 7D       		.byte	125
 4205 0a53 FF       		.byte	-1
 4206 0a54 FD       		.byte	-3
 4207 0a55 CE       		.byte	-50
 4208 0a56 7D       		.byte	125
 4209 0a57 FF       		.byte	-1
 4210 0a58 FD       		.byte	-3
 4211 0a59 CE       		.byte	-50
 4212 0a5a 7C       		.byte	124
 4213 0a5b FF       		.byte	-1
 4214 0a5c FD       		.byte	-3
 4215 0a5d CD       		.byte	-51
 4216 0a5e 7C       		.byte	124
 4217 0a5f FF       		.byte	-1
 4218 0a60 FD       		.byte	-3
 4219 0a61 CD       		.byte	-51
 4220 0a62 7B       		.byte	123
 4221 0a63 FF       		.byte	-1
 4222 0a64 FD       		.byte	-3
 4223 0a65 CD       		.byte	-51
GAS LISTING /tmp/ccOaNtkH.s 			page 89


 4224 0a66 7B       		.byte	123
 4225 0a67 FF       		.byte	-1
 4226 0a68 FD       		.byte	-3
 4227 0a69 CC       		.byte	-52
 4228 0a6a 7B       		.byte	123
 4229 0a6b FF       		.byte	-1
 4230 0a6c FD       		.byte	-3
 4231 0a6d C2       		.byte	-62
 4232 0a6e 71       		.byte	113
 4233 0a6f FF       		.byte	-1
 4234 0a70 FD       		.byte	-3
 4235 0a71 C2       		.byte	-62
 4236 0a72 71       		.byte	113
 4237 0a73 FF       		.byte	-1
 4238 0a74 FD       		.byte	-3
 4239 0a75 C1       		.byte	-63
 4240 0a76 70       		.byte	112
 4241 0a77 FF       		.byte	-1
 4242 0a78 FD       		.byte	-3
 4243 0a79 C1       		.byte	-63
 4244 0a7a 70       		.byte	112
 4245 0a7b FF       		.byte	-1
 4246 0a7c FD       		.byte	-3
 4247 0a7d C0       		.byte	-64
 4248 0a7e 70       		.byte	112
 4249 0a7f FF       		.byte	-1
 4250 0a80 FD       		.byte	-3
 4251 0a81 C0       		.byte	-64
 4252 0a82 6F       		.byte	111
 4253 0a83 FF       		.byte	-1
 4254 0a84 FD       		.byte	-3
 4255 0a85 C0       		.byte	-64
 4256 0a86 6F       		.byte	111
 4257 0a87 FF       		.byte	-1
 4258 0a88 FD       		.byte	-3
 4259 0a89 BF       		.byte	-65
 4260 0a8a 6E       		.byte	110
 4261 0a8b FF       		.byte	-1
 4262 0a8c FD       		.byte	-3
 4263 0a8d BF       		.byte	-65
 4264 0a8e 6E       		.byte	110
 4265 0a8f FF       		.byte	-1
 4266 0a90 FD       		.byte	-3
 4267 0a91 BE       		.byte	-66
 4268 0a92 6E       		.byte	110
 4269 0a93 FF       		.byte	-1
 4270 0a94 FD       		.byte	-3
 4271 0a95 BE       		.byte	-66
 4272 0a96 6D       		.byte	109
 4273 0a97 FF       		.byte	-1
 4274 0a98 FD       		.byte	-3
 4275 0a99 BE       		.byte	-66
 4276 0a9a 6D       		.byte	109
 4277 0a9b FF       		.byte	-1
 4278 0a9c FD       		.byte	-3
 4279 0a9d BD       		.byte	-67
 4280 0a9e 6D       		.byte	109
GAS LISTING /tmp/ccOaNtkH.s 			page 90


 4281 0a9f FF       		.byte	-1
 4282 0aa0 FD       		.byte	-3
 4283 0aa1 BD       		.byte	-67
 4284 0aa2 6C       		.byte	108
 4285 0aa3 FF       		.byte	-1
 4286 0aa4 FD       		.byte	-3
 4287 0aa5 BC       		.byte	-68
 4288 0aa6 6C       		.byte	108
 4289 0aa7 FF       		.byte	-1
 4290 0aa8 FD       		.byte	-3
 4291 0aa9 BC       		.byte	-68
 4292 0aaa 6C       		.byte	108
 4293 0aab FF       		.byte	-1
 4294 0aac FD       		.byte	-3
 4295 0aad BC       		.byte	-68
 4296 0aae 6B       		.byte	107
 4297 0aaf FF       		.byte	-1
 4298 0ab0 FD       		.byte	-3
 4299 0ab1 BB       		.byte	-69
 4300 0ab2 6B       		.byte	107
 4301 0ab3 FF       		.byte	-1
 4302 0ab4 FD       		.byte	-3
 4303 0ab5 BB       		.byte	-69
 4304 0ab6 6B       		.byte	107
 4305 0ab7 FF       		.byte	-1
 4306 0ab8 FD       		.byte	-3
 4307 0ab9 BA       		.byte	-70
 4308 0aba 6A       		.byte	106
 4309 0abb FF       		.byte	-1
 4310 0abc FD       		.byte	-3
 4311 0abd BA       		.byte	-70
 4312 0abe 6A       		.byte	106
 4313 0abf FF       		.byte	-1
 4314 0ac0 FD       		.byte	-3
 4315 0ac1 BA       		.byte	-70
 4316 0ac2 6A       		.byte	106
 4317 0ac3 FF       		.byte	-1
 4318 0ac4 FD       		.byte	-3
 4319 0ac5 B9       		.byte	-71
 4320 0ac6 69       		.byte	105
 4321 0ac7 FF       		.byte	-1
 4322 0ac8 FD       		.byte	-3
 4323 0ac9 B9       		.byte	-71
 4324 0aca 69       		.byte	105
 4325 0acb FF       		.byte	-1
 4326 0acc FD       		.byte	-3
 4327 0acd B8       		.byte	-72
 4328 0ace 69       		.byte	105
 4329 0acf FF       		.byte	-1
 4330 0ad0 FD       		.byte	-3
 4331 0ad1 B8       		.byte	-72
 4332 0ad2 68       		.byte	104
 4333 0ad3 FF       		.byte	-1
 4334 0ad4 FD       		.byte	-3
 4335 0ad5 B8       		.byte	-72
 4336 0ad6 68       		.byte	104
 4337 0ad7 FF       		.byte	-1
GAS LISTING /tmp/ccOaNtkH.s 			page 91


 4338 0ad8 FD       		.byte	-3
 4339 0ad9 B7       		.byte	-73
 4340 0ada 68       		.byte	104
 4341 0adb FF       		.byte	-1
 4342 0adc FD       		.byte	-3
 4343 0add B7       		.byte	-73
 4344 0ade 67       		.byte	103
 4345 0adf FF       		.byte	-1
 4346 0ae0 FD       		.byte	-3
 4347 0ae1 B6       		.byte	-74
 4348 0ae2 67       		.byte	103
 4349 0ae3 FF       		.byte	-1
 4350 0ae4 FD       		.byte	-3
 4351 0ae5 B6       		.byte	-74
 4352 0ae6 67       		.byte	103
 4353 0ae7 FF       		.byte	-1
 4354 0ae8 FD       		.byte	-3
 4355 0ae9 B6       		.byte	-74
 4356 0aea 66       		.byte	102
 4357 0aeb FF       		.byte	-1
 4358 0aec FD       		.byte	-3
 4359 0aed B5       		.byte	-75
 4360 0aee 66       		.byte	102
 4361 0aef FF       		.byte	-1
 4362 0af0 FD       		.byte	-3
 4363 0af1 B5       		.byte	-75
 4364 0af2 66       		.byte	102
 4365 0af3 FF       		.byte	-1
 4366 0af4 FD       		.byte	-3
 4367 0af5 B4       		.byte	-76
 4368 0af6 65       		.byte	101
 4369 0af7 FF       		.byte	-1
 4370 0af8 FD       		.byte	-3
 4371 0af9 B4       		.byte	-76
 4372 0afa 65       		.byte	101
 4373 0afb FF       		.byte	-1
 4374 0afc FD       		.byte	-3
 4375 0afd B4       		.byte	-76
 4376 0afe 65       		.byte	101
 4377 0aff FF       		.byte	-1
 4378 0b00 FD       		.byte	-3
 4379 0b01 B3       		.byte	-77
 4380 0b02 64       		.byte	100
 4381 0b03 FF       		.byte	-1
 4382 0b04 FD       		.byte	-3
 4383 0b05 B3       		.byte	-77
 4384 0b06 64       		.byte	100
 4385 0b07 FF       		.byte	-1
 4386 0b08 FD       		.byte	-3
 4387 0b09 B2       		.byte	-78
 4388 0b0a 64       		.byte	100
 4389 0b0b FF       		.byte	-1
 4390 0b0c FD       		.byte	-3
 4391 0b0d B2       		.byte	-78
 4392 0b0e 64       		.byte	100
 4393 0b0f FF       		.byte	-1
 4394 0b10 FD       		.byte	-3
GAS LISTING /tmp/ccOaNtkH.s 			page 92


 4395 0b11 B2       		.byte	-78
 4396 0b12 63       		.byte	99
 4397 0b13 FF       		.byte	-1
 4398 0b14 FD       		.byte	-3
 4399 0b15 B1       		.byte	-79
 4400 0b16 63       		.byte	99
 4401 0b17 FF       		.byte	-1
 4402 0b18 FD       		.byte	-3
 4403 0b19 B1       		.byte	-79
 4404 0b1a 63       		.byte	99
 4405 0b1b FF       		.byte	-1
 4406 0b1c FD       		.byte	-3
 4407 0b1d B0       		.byte	-80
 4408 0b1e 62       		.byte	98
 4409 0b1f FF       		.byte	-1
 4410 0b20 FD       		.byte	-3
 4411 0b21 B0       		.byte	-80
 4412 0b22 62       		.byte	98
 4413 0b23 FF       		.byte	-1
 4414 0b24 FD       		.byte	-3
 4415 0b25 AF       		.byte	-81
 4416 0b26 62       		.byte	98
 4417 0b27 FF       		.byte	-1
 4418 0b28 FD       		.byte	-3
 4419 0b29 AF       		.byte	-81
 4420 0b2a 62       		.byte	98
 4421 0b2b FF       		.byte	-1
 4422 0b2c FD       		.byte	-3
 4423 0b2d AF       		.byte	-81
 4424 0b2e 61       		.byte	97
 4425 0b2f FF       		.byte	-1
 4426 0b30 FD       		.byte	-3
 4427 0b31 AE       		.byte	-82
 4428 0b32 61       		.byte	97
 4429 0b33 FF       		.byte	-1
 4430 0b34 FD       		.byte	-3
 4431 0b35 AE       		.byte	-82
 4432 0b36 61       		.byte	97
 4433 0b37 FF       		.byte	-1
 4434 0b38 FC       		.byte	-4
 4435 0b39 AD       		.byte	-83
 4436 0b3a 60       		.byte	96
 4437 0b3b FF       		.byte	-1
 4438 0b3c FC       		.byte	-4
 4439 0b3d AD       		.byte	-83
 4440 0b3e 60       		.byte	96
 4441 0b3f FF       		.byte	-1
 4442 0b40 FC       		.byte	-4
 4443 0b41 AC       		.byte	-84
 4444 0b42 60       		.byte	96
 4445 0b43 FF       		.byte	-1
 4446 0b44 FC       		.byte	-4
 4447 0b45 AC       		.byte	-84
 4448 0b46 5F       		.byte	95
 4449 0b47 FF       		.byte	-1
 4450 0b48 FC       		.byte	-4
 4451 0b49 AC       		.byte	-84
GAS LISTING /tmp/ccOaNtkH.s 			page 93


 4452 0b4a 5F       		.byte	95
 4453 0b4b FF       		.byte	-1
 4454 0b4c FC       		.byte	-4
 4455 0b4d AB       		.byte	-85
 4456 0b4e 5F       		.byte	95
 4457 0b4f FF       		.byte	-1
 4458 0b50 FC       		.byte	-4
 4459 0b51 AB       		.byte	-85
 4460 0b52 5E       		.byte	94
 4461 0b53 FF       		.byte	-1
 4462 0b54 FC       		.byte	-4
 4463 0b55 AA       		.byte	-86
 4464 0b56 5E       		.byte	94
 4465 0b57 FF       		.byte	-1
 4466 0b58 FC       		.byte	-4
 4467 0b59 AA       		.byte	-86
 4468 0b5a 5E       		.byte	94
 4469 0b5b FF       		.byte	-1
 4470 0b5c FC       		.byte	-4
 4471 0b5d A9       		.byte	-87
 4472 0b5e 5D       		.byte	93
 4473 0b5f FF       		.byte	-1
 4474 0b60 FC       		.byte	-4
 4475 0b61 A9       		.byte	-87
 4476 0b62 5D       		.byte	93
 4477 0b63 FF       		.byte	-1
 4478 0b64 FC       		.byte	-4
 4479 0b65 A8       		.byte	-88
 4480 0b66 5D       		.byte	93
 4481 0b67 FF       		.byte	-1
 4482 0b68 FC       		.byte	-4
 4483 0b69 A8       		.byte	-88
 4484 0b6a 5C       		.byte	92
 4485 0b6b FF       		.byte	-1
 4486 0b6c FC       		.byte	-4
 4487 0b6d A7       		.byte	-89
 4488 0b6e 5C       		.byte	92
 4489 0b6f FF       		.byte	-1
 4490 0b70 FC       		.byte	-4
 4491 0b71 A7       		.byte	-89
 4492 0b72 5C       		.byte	92
 4493 0b73 FF       		.byte	-1
 4494 0b74 FC       		.byte	-4
 4495 0b75 A6       		.byte	-90
 4496 0b76 5B       		.byte	91
 4497 0b77 FF       		.byte	-1
 4498 0b78 FC       		.byte	-4
 4499 0b79 A6       		.byte	-90
 4500 0b7a 5B       		.byte	91
 4501 0b7b FF       		.byte	-1
 4502 0b7c FC       		.byte	-4
 4503 0b7d A5       		.byte	-91
 4504 0b7e 5B       		.byte	91
 4505 0b7f FF       		.byte	-1
 4506 0b80 FB       		.byte	-5
 4507 0b81 A5       		.byte	-91
 4508 0b82 5A       		.byte	90
GAS LISTING /tmp/ccOaNtkH.s 			page 94


 4509 0b83 FF       		.byte	-1
 4510 0b84 FB       		.byte	-5
 4511 0b85 A4       		.byte	-92
 4512 0b86 5A       		.byte	90
 4513 0b87 FF       		.byte	-1
 4514 0b88 FB       		.byte	-5
 4515 0b89 A4       		.byte	-92
 4516 0b8a 5A       		.byte	90
 4517 0b8b FF       		.byte	-1
 4518 0b8c FB       		.byte	-5
 4519 0b8d A3       		.byte	-93
 4520 0b8e 59       		.byte	89
 4521 0b8f FF       		.byte	-1
 4522 0b90 FB       		.byte	-5
 4523 0b91 A3       		.byte	-93
 4524 0b92 59       		.byte	89
 4525 0b93 FF       		.byte	-1
 4526 0b94 FB       		.byte	-5
 4527 0b95 A2       		.byte	-94
 4528 0b96 59       		.byte	89
 4529 0b97 FF       		.byte	-1
 4530 0b98 FB       		.byte	-5
 4531 0b99 A2       		.byte	-94
 4532 0b9a 59       		.byte	89
 4533 0b9b FF       		.byte	-1
 4534 0b9c FB       		.byte	-5
 4535 0b9d A2       		.byte	-94
 4536 0b9e 58       		.byte	88
 4537 0b9f FF       		.byte	-1
 4538 0ba0 FB       		.byte	-5
 4539 0ba1 A1       		.byte	-95
 4540 0ba2 58       		.byte	88
 4541 0ba3 FF       		.byte	-1
 4542 0ba4 FB       		.byte	-5
 4543 0ba5 A1       		.byte	-95
 4544 0ba6 58       		.byte	88
 4545 0ba7 FF       		.byte	-1
 4546 0ba8 FB       		.byte	-5
 4547 0ba9 A0       		.byte	-96
 4548 0baa 57       		.byte	87
 4549 0bab FF       		.byte	-1
 4550 0bac FB       		.byte	-5
 4551 0bad A0       		.byte	-96
 4552 0bae 57       		.byte	87
 4553 0baf FF       		.byte	-1
 4554 0bb0 FB       		.byte	-5
 4555 0bb1 9F       		.byte	-97
 4556 0bb2 57       		.byte	87
 4557 0bb3 FF       		.byte	-1
 4558 0bb4 FB       		.byte	-5
 4559 0bb5 9F       		.byte	-97
 4560 0bb6 57       		.byte	87
 4561 0bb7 FF       		.byte	-1
 4562 0bb8 FB       		.byte	-5
 4563 0bb9 9E       		.byte	-98
 4564 0bba 56       		.byte	86
 4565 0bbb FF       		.byte	-1
GAS LISTING /tmp/ccOaNtkH.s 			page 95


 4566 0bbc FB       		.byte	-5
 4567 0bbd 9E       		.byte	-98
 4568 0bbe 56       		.byte	86
 4569 0bbf FF       		.byte	-1
 4570 0bc0 FB       		.byte	-5
 4571 0bc1 9D       		.byte	-99
 4572 0bc2 56       		.byte	86
 4573 0bc3 FF       		.byte	-1
 4574 0bc4 FA       		.byte	-6
 4575 0bc5 9D       		.byte	-99
 4576 0bc6 55       		.byte	85
 4577 0bc7 FF       		.byte	-1
 4578 0bc8 FA       		.byte	-6
 4579 0bc9 9C       		.byte	-100
 4580 0bca 55       		.byte	85
 4581 0bcb FF       		.byte	-1
 4582 0bcc FA       		.byte	-6
 4583 0bcd 9C       		.byte	-100
 4584 0bce 55       		.byte	85
 4585 0bcf FF       		.byte	-1
 4586 0bd0 FA       		.byte	-6
 4587 0bd1 9B       		.byte	-101
 4588 0bd2 55       		.byte	85
 4589 0bd3 FF       		.byte	-1
 4590 0bd4 FA       		.byte	-6
 4591 0bd5 9B       		.byte	-101
 4592 0bd6 54       		.byte	84
 4593 0bd7 FF       		.byte	-1
 4594 0bd8 FA       		.byte	-6
 4595 0bd9 9A       		.byte	-102
 4596 0bda 54       		.byte	84
 4597 0bdb FF       		.byte	-1
 4598 0bdc FA       		.byte	-6
 4599 0bdd 9A       		.byte	-102
 4600 0bde 54       		.byte	84
 4601 0bdf FF       		.byte	-1
 4602 0be0 FA       		.byte	-6
 4603 0be1 99       		.byte	-103
 4604 0be2 54       		.byte	84
 4605 0be3 FF       		.byte	-1
 4606 0be4 FA       		.byte	-6
 4607 0be5 99       		.byte	-103
 4608 0be6 53       		.byte	83
 4609 0be7 FF       		.byte	-1
 4610 0be8 FA       		.byte	-6
 4611 0be9 98       		.byte	-104
 4612 0bea 53       		.byte	83
 4613 0beb FF       		.byte	-1
 4614 0bec FA       		.byte	-6
 4615 0bed 98       		.byte	-104
 4616 0bee 53       		.byte	83
 4617 0bef FF       		.byte	-1
 4618 0bf0 FA       		.byte	-6
 4619 0bf1 97       		.byte	-105
 4620 0bf2 53       		.byte	83
 4621 0bf3 FF       		.byte	-1
 4622 0bf4 FA       		.byte	-6
GAS LISTING /tmp/ccOaNtkH.s 			page 96


 4623 0bf5 97       		.byte	-105
 4624 0bf6 52       		.byte	82
 4625 0bf7 FF       		.byte	-1
 4626 0bf8 FA       		.byte	-6
 4627 0bf9 96       		.byte	-106
 4628 0bfa 52       		.byte	82
 4629 0bfb FF       		.byte	-1
 4630 0bfc FA       		.byte	-6
 4631 0bfd 96       		.byte	-106
 4632 0bfe 52       		.byte	82
 4633 0bff FF       		.byte	-1
 4634 0c00 F9       		.byte	-7
 4635 0c01 95       		.byte	-107
 4636 0c02 52       		.byte	82
 4637 0c03 FF       		.byte	-1
 4638 0c04 F8       		.byte	-8
 4639 0c05 88       		.byte	-120
 4640 0c06 4B       		.byte	75
 4641 0c07 FF       		.byte	-1
 4642 0c08 F8       		.byte	-8
 4643 0c09 87       		.byte	-121
 4644 0c0a 4B       		.byte	75
 4645 0c0b FF       		.byte	-1
 4646 0c0c F7       		.byte	-9
 4647 0c0d 87       		.byte	-121
 4648 0c0e 4B       		.byte	75
 4649 0c0f FF       		.byte	-1
 4650 0c10 F7       		.byte	-9
 4651 0c11 86       		.byte	-122
 4652 0c12 4B       		.byte	75
 4653 0c13 FF       		.byte	-1
 4654 0c14 F7       		.byte	-9
 4655 0c15 86       		.byte	-122
 4656 0c16 4A       		.byte	74
 4657 0c17 FF       		.byte	-1
 4658 0c18 F7       		.byte	-9
 4659 0c19 85       		.byte	-123
 4660 0c1a 4A       		.byte	74
 4661 0c1b FF       		.byte	-1
 4662 0c1c F7       		.byte	-9
 4663 0c1d 85       		.byte	-123
 4664 0c1e 4A       		.byte	74
 4665 0c1f FF       		.byte	-1
 4666 0c20 F7       		.byte	-9
 4667 0c21 84       		.byte	-124
 4668 0c22 4A       		.byte	74
 4669 0c23 FF       		.byte	-1
 4670 0c24 F7       		.byte	-9
 4671 0c25 84       		.byte	-124
 4672 0c26 4A       		.byte	74
 4673 0c27 FF       		.byte	-1
 4674 0c28 F7       		.byte	-9
 4675 0c29 83       		.byte	-125
 4676 0c2a 49       		.byte	73
 4677 0c2b FF       		.byte	-1
 4678 0c2c F7       		.byte	-9
 4679 0c2d 83       		.byte	-125
GAS LISTING /tmp/ccOaNtkH.s 			page 97


 4680 0c2e 49       		.byte	73
 4681 0c2f FF       		.byte	-1
 4682 0c30 F7       		.byte	-9
 4683 0c31 82       		.byte	-126
 4684 0c32 49       		.byte	73
 4685 0c33 FF       		.byte	-1
 4686 0c34 F7       		.byte	-9
 4687 0c35 82       		.byte	-126
 4688 0c36 49       		.byte	73
 4689 0c37 FF       		.byte	-1
 4690 0c38 F7       		.byte	-9
 4691 0c39 81       		.byte	-127
 4692 0c3a 48       		.byte	72
 4693 0c3b FF       		.byte	-1
 4694 0c3c F7       		.byte	-9
 4695 0c3d 81       		.byte	-127
 4696 0c3e 48       		.byte	72
 4697 0c3f FF       		.byte	-1
 4698 0c40 F7       		.byte	-9
 4699 0c41 80       		.byte	-128
 4700 0c42 48       		.byte	72
 4701 0c43 FF       		.byte	-1
 4702 0c44 F6       		.byte	-10
 4703 0c45 80       		.byte	-128
 4704 0c46 48       		.byte	72
 4705 0c47 FF       		.byte	-1
 4706 0c48 F6       		.byte	-10
 4707 0c49 7F       		.byte	127
 4708 0c4a 48       		.byte	72
 4709 0c4b FF       		.byte	-1
 4710 0c4c F6       		.byte	-10
 4711 0c4d 7E       		.byte	126
 4712 0c4e 47       		.byte	71
 4713 0c4f FF       		.byte	-1
 4714 0c50 F6       		.byte	-10
 4715 0c51 7E       		.byte	126
 4716 0c52 47       		.byte	71
 4717 0c53 FF       		.byte	-1
 4718 0c54 F6       		.byte	-10
 4719 0c55 7D       		.byte	125
 4720 0c56 47       		.byte	71
 4721 0c57 FF       		.byte	-1
 4722 0c58 F6       		.byte	-10
 4723 0c59 7D       		.byte	125
 4724 0c5a 47       		.byte	71
 4725 0c5b FF       		.byte	-1
 4726 0c5c F6       		.byte	-10
 4727 0c5d 7C       		.byte	124
 4728 0c5e 47       		.byte	71
 4729 0c5f FF       		.byte	-1
 4730 0c60 F6       		.byte	-10
 4731 0c61 7C       		.byte	124
 4732 0c62 47       		.byte	71
 4733 0c63 FF       		.byte	-1
 4734 0c64 F6       		.byte	-10
 4735 0c65 7B       		.byte	123
 4736 0c66 46       		.byte	70
GAS LISTING /tmp/ccOaNtkH.s 			page 98


 4737 0c67 FF       		.byte	-1
 4738 0c68 F6       		.byte	-10
 4739 0c69 7B       		.byte	123
 4740 0c6a 46       		.byte	70
 4741 0c6b FF       		.byte	-1
 4742 0c6c F6       		.byte	-10
 4743 0c6d 7A       		.byte	122
 4744 0c6e 46       		.byte	70
 4745 0c6f FF       		.byte	-1
 4746 0c70 F6       		.byte	-10
 4747 0c71 7A       		.byte	122
 4748 0c72 46       		.byte	70
 4749 0c73 FF       		.byte	-1
 4750 0c74 F6       		.byte	-10
 4751 0c75 79       		.byte	121
 4752 0c76 46       		.byte	70
 4753 0c77 FF       		.byte	-1
 4754 0c78 F5       		.byte	-11
 4755 0c79 79       		.byte	121
 4756 0c7a 46       		.byte	70
 4757 0c7b FF       		.byte	-1
 4758 0c7c F5       		.byte	-11
 4759 0c7d 78       		.byte	120
 4760 0c7e 45       		.byte	69
 4761 0c7f FF       		.byte	-1
 4762 0c80 F5       		.byte	-11
 4763 0c81 78       		.byte	120
 4764 0c82 45       		.byte	69
 4765 0c83 FF       		.byte	-1
 4766 0c84 F5       		.byte	-11
 4767 0c85 77       		.byte	119
 4768 0c86 45       		.byte	69
 4769 0c87 FF       		.byte	-1
 4770 0c88 F5       		.byte	-11
 4771 0c89 77       		.byte	119
 4772 0c8a 45       		.byte	69
 4773 0c8b FF       		.byte	-1
 4774 0c8c F5       		.byte	-11
 4775 0c8d 76       		.byte	118
 4776 0c8e 45       		.byte	69
 4777 0c8f FF       		.byte	-1
 4778 0c90 F5       		.byte	-11
 4779 0c91 75       		.byte	117
 4780 0c92 45       		.byte	69
 4781 0c93 FF       		.byte	-1
 4782 0c94 F5       		.byte	-11
 4783 0c95 75       		.byte	117
 4784 0c96 44       		.byte	68
 4785 0c97 FF       		.byte	-1
 4786 0c98 F5       		.byte	-11
 4787 0c99 74       		.byte	116
 4788 0c9a 44       		.byte	68
 4789 0c9b FF       		.byte	-1
 4790 0c9c F5       		.byte	-11
 4791 0c9d 74       		.byte	116
 4792 0c9e 44       		.byte	68
 4793 0c9f FF       		.byte	-1
GAS LISTING /tmp/ccOaNtkH.s 			page 99


 4794 0ca0 F5       		.byte	-11
 4795 0ca1 73       		.byte	115
 4796 0ca2 44       		.byte	68
 4797 0ca3 FF       		.byte	-1
 4798 0ca4 F5       		.byte	-11
 4799 0ca5 73       		.byte	115
 4800 0ca6 44       		.byte	68
 4801 0ca7 FF       		.byte	-1
 4802 0ca8 F4       		.byte	-12
 4803 0ca9 72       		.byte	114
 4804 0caa 44       		.byte	68
 4805 0cab FF       		.byte	-1
 4806 0cac F4       		.byte	-12
 4807 0cad 72       		.byte	114
 4808 0cae 44       		.byte	68
 4809 0caf FF       		.byte	-1
 4810 0cb0 F4       		.byte	-12
 4811 0cb1 71       		.byte	113
 4812 0cb2 43       		.byte	67
 4813 0cb3 FF       		.byte	-1
 4814 0cb4 F4       		.byte	-12
 4815 0cb5 71       		.byte	113
 4816 0cb6 43       		.byte	67
 4817 0cb7 FF       		.byte	-1
 4818 0cb8 F4       		.byte	-12
 4819 0cb9 70       		.byte	112
 4820 0cba 43       		.byte	67
 4821 0cbb FF       		.byte	-1
 4822 0cbc F4       		.byte	-12
 4823 0cbd 6F       		.byte	111
 4824 0cbe 43       		.byte	67
 4825 0cbf FF       		.byte	-1
 4826 0cc0 F4       		.byte	-12
 4827 0cc1 6F       		.byte	111
 4828 0cc2 43       		.byte	67
 4829 0cc3 FF       		.byte	-1
 4830 0cc4 F4       		.byte	-12
 4831 0cc5 6E       		.byte	110
 4832 0cc6 43       		.byte	67
 4833 0cc7 FF       		.byte	-1
 4834 0cc8 F4       		.byte	-12
 4835 0cc9 6E       		.byte	110
 4836 0cca 43       		.byte	67
 4837 0ccb FF       		.byte	-1
 4838 0ccc F4       		.byte	-12
 4839 0ccd 6D       		.byte	109
 4840 0cce 43       		.byte	67
 4841 0ccf FF       		.byte	-1
 4842 0cd0 F4       		.byte	-12
 4843 0cd1 6D       		.byte	109
 4844 0cd2 43       		.byte	67
 4845 0cd3 FF       		.byte	-1
 4846 0cd4 F3       		.byte	-13
 4847 0cd5 6C       		.byte	108
 4848 0cd6 43       		.byte	67
 4849 0cd7 FF       		.byte	-1
 4850 0cd8 F3       		.byte	-13
GAS LISTING /tmp/ccOaNtkH.s 			page 100


 4851 0cd9 6C       		.byte	108
 4852 0cda 43       		.byte	67
 4853 0cdb FF       		.byte	-1
 4854 0cdc F3       		.byte	-13
 4855 0cdd 6B       		.byte	107
 4856 0cde 43       		.byte	67
 4857 0cdf FF       		.byte	-1
 4858 0ce0 F3       		.byte	-13
 4859 0ce1 6B       		.byte	107
 4860 0ce2 43       		.byte	67
 4861 0ce3 FF       		.byte	-1
 4862 0ce4 F3       		.byte	-13
 4863 0ce5 6B       		.byte	107
 4864 0ce6 43       		.byte	67
 4865 0ce7 FF       		.byte	-1
 4866 0ce8 F2       		.byte	-14
 4867 0ce9 6A       		.byte	106
 4868 0cea 43       		.byte	67
 4869 0ceb FF       		.byte	-1
 4870 0cec F2       		.byte	-14
 4871 0ced 6A       		.byte	106
 4872 0cee 43       		.byte	67
 4873 0cef FF       		.byte	-1
 4874 0cf0 F2       		.byte	-14
 4875 0cf1 6A       		.byte	106
 4876 0cf2 43       		.byte	67
 4877 0cf3 FF       		.byte	-1
 4878 0cf4 F2       		.byte	-14
 4879 0cf5 69       		.byte	105
 4880 0cf6 43       		.byte	67
 4881 0cf7 FF       		.byte	-1
 4882 0cf8 F2       		.byte	-14
 4883 0cf9 69       		.byte	105
 4884 0cfa 43       		.byte	67
 4885 0cfb FF       		.byte	-1
 4886 0cfc F1       		.byte	-15
 4887 0cfd 68       		.byte	104
 4888 0cfe 44       		.byte	68
 4889 0cff FF       		.byte	-1
 4890 0d00 F1       		.byte	-15
 4891 0d01 68       		.byte	104
 4892 0d02 44       		.byte	68
 4893 0d03 FF       		.byte	-1
 4894 0d04 F1       		.byte	-15
 4895 0d05 68       		.byte	104
 4896 0d06 44       		.byte	68
 4897 0d07 FF       		.byte	-1
 4898 0d08 F1       		.byte	-15
 4899 0d09 67       		.byte	103
 4900 0d0a 44       		.byte	68
 4901 0d0b FF       		.byte	-1
 4902 0d0c F1       		.byte	-15
 4903 0d0d 67       		.byte	103
 4904 0d0e 44       		.byte	68
 4905 0d0f FF       		.byte	-1
 4906 0d10 F0       		.byte	-16
 4907 0d11 66       		.byte	102
GAS LISTING /tmp/ccOaNtkH.s 			page 101


 4908 0d12 44       		.byte	68
 4909 0d13 FF       		.byte	-1
 4910 0d14 F0       		.byte	-16
 4911 0d15 66       		.byte	102
 4912 0d16 44       		.byte	68
 4913 0d17 FF       		.byte	-1
 4914 0d18 F0       		.byte	-16
 4915 0d19 66       		.byte	102
 4916 0d1a 44       		.byte	68
 4917 0d1b FF       		.byte	-1
 4918 0d1c F0       		.byte	-16
 4919 0d1d 65       		.byte	101
 4920 0d1e 44       		.byte	68
 4921 0d1f FF       		.byte	-1
 4922 0d20 F0       		.byte	-16
 4923 0d21 65       		.byte	101
 4924 0d22 44       		.byte	68
 4925 0d23 FF       		.byte	-1
 4926 0d24 EF       		.byte	-17
 4927 0d25 65       		.byte	101
 4928 0d26 45       		.byte	69
 4929 0d27 FF       		.byte	-1
 4930 0d28 EF       		.byte	-17
 4931 0d29 64       		.byte	100
 4932 0d2a 45       		.byte	69
 4933 0d2b FF       		.byte	-1
 4934 0d2c EF       		.byte	-17
 4935 0d2d 64       		.byte	100
 4936 0d2e 45       		.byte	69
 4937 0d2f FF       		.byte	-1
 4938 0d30 EF       		.byte	-17
 4939 0d31 63       		.byte	99
 4940 0d32 45       		.byte	69
 4941 0d33 FF       		.byte	-1
 4942 0d34 EE       		.byte	-18
 4943 0d35 63       		.byte	99
 4944 0d36 45       		.byte	69
 4945 0d37 FF       		.byte	-1
 4946 0d38 EE       		.byte	-18
 4947 0d39 63       		.byte	99
 4948 0d3a 45       		.byte	69
 4949 0d3b FF       		.byte	-1
 4950 0d3c EE       		.byte	-18
 4951 0d3d 62       		.byte	98
 4952 0d3e 45       		.byte	69
 4953 0d3f FF       		.byte	-1
 4954 0d40 EE       		.byte	-18
 4955 0d41 62       		.byte	98
 4956 0d42 45       		.byte	69
 4957 0d43 FF       		.byte	-1
 4958 0d44 EE       		.byte	-18
 4959 0d45 62       		.byte	98
 4960 0d46 45       		.byte	69
 4961 0d47 FF       		.byte	-1
 4962 0d48 ED       		.byte	-19
 4963 0d49 61       		.byte	97
 4964 0d4a 45       		.byte	69
GAS LISTING /tmp/ccOaNtkH.s 			page 102


 4965 0d4b FF       		.byte	-1
 4966 0d4c ED       		.byte	-19
 4967 0d4d 61       		.byte	97
 4968 0d4e 46       		.byte	70
 4969 0d4f FF       		.byte	-1
 4970 0d50 ED       		.byte	-19
 4971 0d51 60       		.byte	96
 4972 0d52 46       		.byte	70
 4973 0d53 FF       		.byte	-1
 4974 0d54 ED       		.byte	-19
 4975 0d55 60       		.byte	96
 4976 0d56 46       		.byte	70
 4977 0d57 FF       		.byte	-1
 4978 0d58 EC       		.byte	-20
 4979 0d59 60       		.byte	96
 4980 0d5a 46       		.byte	70
 4981 0d5b FF       		.byte	-1
 4982 0d5c EC       		.byte	-20
 4983 0d5d 5F       		.byte	95
 4984 0d5e 46       		.byte	70
 4985 0d5f FF       		.byte	-1
 4986 0d60 EC       		.byte	-20
 4987 0d61 5F       		.byte	95
 4988 0d62 46       		.byte	70
 4989 0d63 FF       		.byte	-1
 4990 0d64 EC       		.byte	-20
 4991 0d65 5F       		.byte	95
 4992 0d66 46       		.byte	70
 4993 0d67 FF       		.byte	-1
 4994 0d68 EC       		.byte	-20
 4995 0d69 5E       		.byte	94
 4996 0d6a 46       		.byte	70
 4997 0d6b FF       		.byte	-1
 4998 0d6c EB       		.byte	-21
 4999 0d6d 5E       		.byte	94
 5000 0d6e 46       		.byte	70
 5001 0d6f FF       		.byte	-1
 5002 0d70 EB       		.byte	-21
 5003 0d71 5E       		.byte	94
 5004 0d72 46       		.byte	70
 5005 0d73 FF       		.byte	-1
 5006 0d74 EB       		.byte	-21
 5007 0d75 5D       		.byte	93
 5008 0d76 47       		.byte	71
 5009 0d77 FF       		.byte	-1
 5010 0d78 EB       		.byte	-21
 5011 0d79 5D       		.byte	93
 5012 0d7a 47       		.byte	71
 5013 0d7b FF       		.byte	-1
 5014 0d7c EA       		.byte	-22
 5015 0d7d 5C       		.byte	92
 5016 0d7e 47       		.byte	71
 5017 0d7f FF       		.byte	-1
 5018 0d80 EA       		.byte	-22
 5019 0d81 5C       		.byte	92
 5020 0d82 47       		.byte	71
 5021 0d83 FF       		.byte	-1
GAS LISTING /tmp/ccOaNtkH.s 			page 103


 5022 0d84 EA       		.byte	-22
 5023 0d85 5C       		.byte	92
 5024 0d86 47       		.byte	71
 5025 0d87 FF       		.byte	-1
 5026 0d88 EA       		.byte	-22
 5027 0d89 5B       		.byte	91
 5028 0d8a 47       		.byte	71
 5029 0d8b FF       		.byte	-1
 5030 0d8c E9       		.byte	-23
 5031 0d8d 5B       		.byte	91
 5032 0d8e 47       		.byte	71
 5033 0d8f FF       		.byte	-1
 5034 0d90 E9       		.byte	-23
 5035 0d91 5B       		.byte	91
 5036 0d92 47       		.byte	71
 5037 0d93 FF       		.byte	-1
 5038 0d94 E9       		.byte	-23
 5039 0d95 5A       		.byte	90
 5040 0d96 47       		.byte	71
 5041 0d97 FF       		.byte	-1
 5042 0d98 E9       		.byte	-23
 5043 0d99 5A       		.byte	90
 5044 0d9a 47       		.byte	71
 5045 0d9b FF       		.byte	-1
 5046 0d9c E9       		.byte	-23
 5047 0d9d 59       		.byte	89
 5048 0d9e 48       		.byte	72
 5049 0d9f FF       		.byte	-1
 5050 0da0 E2       		.byte	-30
 5051 0da1 50       		.byte	80
 5052 0da2 4A       		.byte	74
 5053 0da3 FF       		.byte	-1
 5054 0da4 E2       		.byte	-30
 5055 0da5 4F       		.byte	79
 5056 0da6 4A       		.byte	74
 5057 0da7 FF       		.byte	-1
 5058 0da8 E2       		.byte	-30
 5059 0da9 4F       		.byte	79
 5060 0daa 4A       		.byte	74
 5061 0dab FF       		.byte	-1
 5062 0dac E1       		.byte	-31
 5063 0dad 4F       		.byte	79
 5064 0dae 4A       		.byte	74
 5065 0daf FF       		.byte	-1
 5066 0db0 E1       		.byte	-31
 5067 0db1 4E       		.byte	78
 5068 0db2 4A       		.byte	74
 5069 0db3 FF       		.byte	-1
 5070 0db4 E1       		.byte	-31
 5071 0db5 4E       		.byte	78
 5072 0db6 4A       		.byte	74
 5073 0db7 FF       		.byte	-1
 5074 0db8 E1       		.byte	-31
 5075 0db9 4D       		.byte	77
 5076 0dba 4B       		.byte	75
 5077 0dbb FF       		.byte	-1
 5078 0dbc E0       		.byte	-32
GAS LISTING /tmp/ccOaNtkH.s 			page 104


 5079 0dbd 4D       		.byte	77
 5080 0dbe 4B       		.byte	75
 5081 0dbf FF       		.byte	-1
 5082 0dc0 E0       		.byte	-32
 5083 0dc1 4D       		.byte	77
 5084 0dc2 4B       		.byte	75
 5085 0dc3 FF       		.byte	-1
 5086 0dc4 E0       		.byte	-32
 5087 0dc5 4C       		.byte	76
 5088 0dc6 4B       		.byte	75
 5089 0dc7 FF       		.byte	-1
 5090 0dc8 E0       		.byte	-32
 5091 0dc9 4C       		.byte	76
 5092 0dca 4B       		.byte	75
 5093 0dcb FF       		.byte	-1
 5094 0dcc DF       		.byte	-33
 5095 0dcd 4C       		.byte	76
 5096 0dce 4B       		.byte	75
 5097 0dcf FF       		.byte	-1
 5098 0dd0 DF       		.byte	-33
 5099 0dd1 4B       		.byte	75
 5100 0dd2 4B       		.byte	75
 5101 0dd3 FF       		.byte	-1
 5102 0dd4 DF       		.byte	-33
 5103 0dd5 4B       		.byte	75
 5104 0dd6 4B       		.byte	75
 5105 0dd7 FF       		.byte	-1
 5106 0dd8 DF       		.byte	-33
 5107 0dd9 4B       		.byte	75
 5108 0dda 4B       		.byte	75
 5109 0ddb FF       		.byte	-1
 5110 0ddc DE       		.byte	-34
 5111 0ddd 4A       		.byte	74
 5112 0dde 4B       		.byte	75
 5113 0ddf FF       		.byte	-1
 5114 0de0 DE       		.byte	-34
 5115 0de1 4A       		.byte	74
 5116 0de2 4B       		.byte	75
 5117 0de3 FF       		.byte	-1
 5118 0de4 DE       		.byte	-34
 5119 0de5 49       		.byte	73
 5120 0de6 4C       		.byte	76
 5121 0de7 FF       		.byte	-1
 5122 0de8 DE       		.byte	-34
 5123 0de9 49       		.byte	73
 5124 0dea 4C       		.byte	76
 5125 0deb FF       		.byte	-1
 5126 0dec DD       		.byte	-35
 5127 0ded 49       		.byte	73
 5128 0dee 4C       		.byte	76
 5129 0def FF       		.byte	-1
 5130 0df0 DD       		.byte	-35
 5131 0df1 48       		.byte	72
 5132 0df2 4C       		.byte	76
 5133 0df3 FF       		.byte	-1
 5134 0df4 DD       		.byte	-35
 5135 0df5 48       		.byte	72
GAS LISTING /tmp/ccOaNtkH.s 			page 105


 5136 0df6 4C       		.byte	76
 5137 0df7 FF       		.byte	-1
 5138 0df8 DC       		.byte	-36
 5139 0df9 48       		.byte	72
 5140 0dfa 4C       		.byte	76
 5141 0dfb FF       		.byte	-1
 5142 0dfc DC       		.byte	-36
 5143 0dfd 47       		.byte	71
 5144 0dfe 4C       		.byte	76
 5145 0dff FF       		.byte	-1
 5146 0e00 DC       		.byte	-36
 5147 0e01 47       		.byte	71
 5148 0e02 4C       		.byte	76
 5149 0e03 FF       		.byte	-1
 5150 0e04 DC       		.byte	-36
 5151 0e05 47       		.byte	71
 5152 0e06 4C       		.byte	76
 5153 0e07 FF       		.byte	-1
 5154 0e08 DB       		.byte	-37
 5155 0e09 46       		.byte	70
 5156 0e0a 4C       		.byte	76
 5157 0e0b FF       		.byte	-1
 5158 0e0c DB       		.byte	-37
 5159 0e0d 46       		.byte	70
 5160 0e0e 4C       		.byte	76
 5161 0e0f FF       		.byte	-1
 5162 0e10 DB       		.byte	-37
 5163 0e11 46       		.byte	70
 5164 0e12 4D       		.byte	77
 5165 0e13 FF       		.byte	-1
 5166 0e14 DB       		.byte	-37
 5167 0e15 45       		.byte	69
 5168 0e16 4D       		.byte	77
 5169 0e17 FF       		.byte	-1
 5170 0e18 DA       		.byte	-38
 5171 0e19 45       		.byte	69
 5172 0e1a 4D       		.byte	77
 5173 0e1b FF       		.byte	-1
 5174 0e1c DA       		.byte	-38
 5175 0e1d 44       		.byte	68
 5176 0e1e 4D       		.byte	77
 5177 0e1f FF       		.byte	-1
 5178 0e20 DA       		.byte	-38
 5179 0e21 44       		.byte	68
 5180 0e22 4D       		.byte	77
 5181 0e23 FF       		.byte	-1
 5182 0e24 D9       		.byte	-39
 5183 0e25 44       		.byte	68
 5184 0e26 4D       		.byte	77
 5185 0e27 FF       		.byte	-1
 5186 0e28 D9       		.byte	-39
 5187 0e29 43       		.byte	67
 5188 0e2a 4D       		.byte	77
 5189 0e2b FF       		.byte	-1
 5190 0e2c D9       		.byte	-39
 5191 0e2d 43       		.byte	67
 5192 0e2e 4D       		.byte	77
GAS LISTING /tmp/ccOaNtkH.s 			page 106


 5193 0e2f FF       		.byte	-1
 5194 0e30 D9       		.byte	-39
 5195 0e31 43       		.byte	67
 5196 0e32 4D       		.byte	77
 5197 0e33 FF       		.byte	-1
 5198 0e34 D8       		.byte	-40
 5199 0e35 42       		.byte	66
 5200 0e36 4D       		.byte	77
 5201 0e37 FF       		.byte	-1
 5202 0e38 D8       		.byte	-40
 5203 0e39 42       		.byte	66
 5204 0e3a 4D       		.byte	77
 5205 0e3b FF       		.byte	-1
 5206 0e3c D8       		.byte	-40
 5207 0e3d 42       		.byte	66
 5208 0e3e 4E       		.byte	78
 5209 0e3f FF       		.byte	-1
 5210 0e40 D8       		.byte	-40
 5211 0e41 41       		.byte	65
 5212 0e42 4E       		.byte	78
 5213 0e43 FF       		.byte	-1
 5214 0e44 D7       		.byte	-41
 5215 0e45 41       		.byte	65
 5216 0e46 4E       		.byte	78
 5217 0e47 FF       		.byte	-1
 5218 0e48 D7       		.byte	-41
 5219 0e49 41       		.byte	65
 5220 0e4a 4E       		.byte	78
 5221 0e4b FF       		.byte	-1
 5222 0e4c D7       		.byte	-41
 5223 0e4d 40       		.byte	64
 5224 0e4e 4E       		.byte	78
 5225 0e4f FF       		.byte	-1
 5226 0e50 D6       		.byte	-42
 5227 0e51 40       		.byte	64
 5228 0e52 4E       		.byte	78
 5229 0e53 FF       		.byte	-1
 5230 0e54 D6       		.byte	-42
 5231 0e55 3F       		.byte	63
 5232 0e56 4E       		.byte	78
 5233 0e57 FF       		.byte	-1
 5234 0e58 D6       		.byte	-42
 5235 0e59 3F       		.byte	63
 5236 0e5a 4E       		.byte	78
 5237 0e5b FF       		.byte	-1
 5238 0e5c D6       		.byte	-42
 5239 0e5d 3F       		.byte	63
 5240 0e5e 4E       		.byte	78
 5241 0e5f FF       		.byte	-1
 5242 0e60 D5       		.byte	-43
 5243 0e61 3E       		.byte	62
 5244 0e62 4E       		.byte	78
 5245 0e63 FF       		.byte	-1
 5246 0e64 D5       		.byte	-43
 5247 0e65 3E       		.byte	62
 5248 0e66 4E       		.byte	78
 5249 0e67 FF       		.byte	-1
GAS LISTING /tmp/ccOaNtkH.s 			page 107


 5250 0e68 D5       		.byte	-43
 5251 0e69 3E       		.byte	62
 5252 0e6a 4E       		.byte	78
 5253 0e6b FF       		.byte	-1
 5254 0e6c D4       		.byte	-44
 5255 0e6d 3D       		.byte	61
 5256 0e6e 4E       		.byte	78
 5257 0e6f FF       		.byte	-1
 5258 0e70 D4       		.byte	-44
 5259 0e71 3D       		.byte	61
 5260 0e72 4E       		.byte	78
 5261 0e73 FF       		.byte	-1
 5262 0e74 D3       		.byte	-45
 5263 0e75 3D       		.byte	61
 5264 0e76 4E       		.byte	78
 5265 0e77 FF       		.byte	-1
 5266 0e78 D3       		.byte	-45
 5267 0e79 3C       		.byte	60
 5268 0e7a 4E       		.byte	78
 5269 0e7b FF       		.byte	-1
 5270 0e7c D3       		.byte	-45
 5271 0e7d 3C       		.byte	60
 5272 0e7e 4E       		.byte	78
 5273 0e7f FF       		.byte	-1
 5274 0e80 D2       		.byte	-46
 5275 0e81 3B       		.byte	59
 5276 0e82 4E       		.byte	78
 5277 0e83 FF       		.byte	-1
 5278 0e84 D2       		.byte	-46
 5279 0e85 3B       		.byte	59
 5280 0e86 4E       		.byte	78
 5281 0e87 FF       		.byte	-1
 5282 0e88 D1       		.byte	-47
 5283 0e89 3B       		.byte	59
 5284 0e8a 4E       		.byte	78
 5285 0e8b FF       		.byte	-1
 5286 0e8c D1       		.byte	-47
 5287 0e8d 3A       		.byte	58
 5288 0e8e 4E       		.byte	78
 5289 0e8f FF       		.byte	-1
 5290 0e90 D1       		.byte	-47
 5291 0e91 3A       		.byte	58
 5292 0e92 4E       		.byte	78
 5293 0e93 FF       		.byte	-1
 5294 0e94 D0       		.byte	-48
 5295 0e95 39       		.byte	57
 5296 0e96 4E       		.byte	78
 5297 0e97 FF       		.byte	-1
 5298 0e98 D0       		.byte	-48
 5299 0e99 39       		.byte	57
 5300 0e9a 4D       		.byte	77
 5301 0e9b FF       		.byte	-1
 5302 0e9c CF       		.byte	-49
 5303 0e9d 39       		.byte	57
 5304 0e9e 4D       		.byte	77
 5305 0e9f FF       		.byte	-1
 5306 0ea0 CF       		.byte	-49
GAS LISTING /tmp/ccOaNtkH.s 			page 108


 5307 0ea1 38       		.byte	56
 5308 0ea2 4D       		.byte	77
 5309 0ea3 FF       		.byte	-1
 5310 0ea4 CE       		.byte	-50
 5311 0ea5 38       		.byte	56
 5312 0ea6 4D       		.byte	77
 5313 0ea7 FF       		.byte	-1
 5314 0ea8 CE       		.byte	-50
 5315 0ea9 38       		.byte	56
 5316 0eaa 4D       		.byte	77
 5317 0eab FF       		.byte	-1
 5318 0eac CE       		.byte	-50
 5319 0ead 37       		.byte	55
 5320 0eae 4D       		.byte	77
 5321 0eaf FF       		.byte	-1
 5322 0eb0 CD       		.byte	-51
 5323 0eb1 37       		.byte	55
 5324 0eb2 4D       		.byte	77
 5325 0eb3 FF       		.byte	-1
 5326 0eb4 CD       		.byte	-51
 5327 0eb5 36       		.byte	54
 5328 0eb6 4D       		.byte	77
 5329 0eb7 FF       		.byte	-1
 5330 0eb8 CC       		.byte	-52
 5331 0eb9 36       		.byte	54
 5332 0eba 4D       		.byte	77
 5333 0ebb FF       		.byte	-1
 5334 0ebc CC       		.byte	-52
 5335 0ebd 36       		.byte	54
 5336 0ebe 4D       		.byte	77
 5337 0ebf FF       		.byte	-1
 5338 0ec0 CB       		.byte	-53
 5339 0ec1 35       		.byte	53
 5340 0ec2 4D       		.byte	77
 5341 0ec3 FF       		.byte	-1
 5342 0ec4 CB       		.byte	-53
 5343 0ec5 35       		.byte	53
 5344 0ec6 4C       		.byte	76
 5345 0ec7 FF       		.byte	-1
 5346 0ec8 CB       		.byte	-53
 5347 0ec9 34       		.byte	52
 5348 0eca 4C       		.byte	76
 5349 0ecb FF       		.byte	-1
 5350 0ecc CA       		.byte	-54
 5351 0ecd 34       		.byte	52
 5352 0ece 4C       		.byte	76
 5353 0ecf FF       		.byte	-1
 5354 0ed0 CA       		.byte	-54
 5355 0ed1 34       		.byte	52
 5356 0ed2 4C       		.byte	76
 5357 0ed3 FF       		.byte	-1
 5358 0ed4 C9       		.byte	-55
 5359 0ed5 33       		.byte	51
 5360 0ed6 4C       		.byte	76
 5361 0ed7 FF       		.byte	-1
 5362 0ed8 C9       		.byte	-55
 5363 0ed9 33       		.byte	51
GAS LISTING /tmp/ccOaNtkH.s 			page 109


 5364 0eda 4C       		.byte	76
 5365 0edb FF       		.byte	-1
 5366 0edc C8       		.byte	-56
 5367 0edd 32       		.byte	50
 5368 0ede 4C       		.byte	76
 5369 0edf FF       		.byte	-1
 5370 0ee0 C8       		.byte	-56
 5371 0ee1 32       		.byte	50
 5372 0ee2 4C       		.byte	76
 5373 0ee3 FF       		.byte	-1
 5374 0ee4 C8       		.byte	-56
 5375 0ee5 32       		.byte	50
 5376 0ee6 4C       		.byte	76
 5377 0ee7 FF       		.byte	-1
 5378 0ee8 C7       		.byte	-57
 5379 0ee9 31       		.byte	49
 5380 0eea 4C       		.byte	76
 5381 0eeb FF       		.byte	-1
 5382 0eec C7       		.byte	-57
 5383 0eed 31       		.byte	49
 5384 0eee 4C       		.byte	76
 5385 0eef FF       		.byte	-1
 5386 0ef0 C6       		.byte	-58
 5387 0ef1 30       		.byte	48
 5388 0ef2 4B       		.byte	75
 5389 0ef3 FF       		.byte	-1
 5390 0ef4 C6       		.byte	-58
 5391 0ef5 30       		.byte	48
 5392 0ef6 4B       		.byte	75
 5393 0ef7 FF       		.byte	-1
 5394 0ef8 C6       		.byte	-58
 5395 0ef9 30       		.byte	48
 5396 0efa 4B       		.byte	75
 5397 0efb FF       		.byte	-1
 5398 0efc C5       		.byte	-59
 5399 0efd 2F       		.byte	47
 5400 0efe 4B       		.byte	75
 5401 0eff FF       		.byte	-1
 5402 0f00 C5       		.byte	-59
 5403 0f01 2F       		.byte	47
 5404 0f02 4B       		.byte	75
 5405 0f03 FF       		.byte	-1
 5406 0f04 C4       		.byte	-60
 5407 0f05 2E       		.byte	46
 5408 0f06 4B       		.byte	75
 5409 0f07 FF       		.byte	-1
 5410 0f08 C4       		.byte	-60
 5411 0f09 2E       		.byte	46
 5412 0f0a 4B       		.byte	75
 5413 0f0b FF       		.byte	-1
 5414 0f0c C3       		.byte	-61
 5415 0f0d 2E       		.byte	46
 5416 0f0e 4B       		.byte	75
 5417 0f0f FF       		.byte	-1
 5418 0f10 C3       		.byte	-61
 5419 0f11 2D       		.byte	45
 5420 0f12 4B       		.byte	75
GAS LISTING /tmp/ccOaNtkH.s 			page 110


 5421 0f13 FF       		.byte	-1
 5422 0f14 C3       		.byte	-61
 5423 0f15 2D       		.byte	45
 5424 0f16 4B       		.byte	75
 5425 0f17 FF       		.byte	-1
 5426 0f18 C2       		.byte	-62
 5427 0f19 2C       		.byte	44
 5428 0f1a 4A       		.byte	74
 5429 0f1b FF       		.byte	-1
 5430 0f1c C2       		.byte	-62
 5431 0f1d 2C       		.byte	44
 5432 0f1e 4A       		.byte	74
 5433 0f1f FF       		.byte	-1
 5434 0f20 C1       		.byte	-63
 5435 0f21 2B       		.byte	43
 5436 0f22 4A       		.byte	74
 5437 0f23 FF       		.byte	-1
 5438 0f24 C1       		.byte	-63
 5439 0f25 2B       		.byte	43
 5440 0f26 4A       		.byte	74
 5441 0f27 FF       		.byte	-1
 5442 0f28 C0       		.byte	-64
 5443 0f29 2B       		.byte	43
 5444 0f2a 4A       		.byte	74
 5445 0f2b FF       		.byte	-1
 5446 0f2c C0       		.byte	-64
 5447 0f2d 2A       		.byte	42
 5448 0f2e 4A       		.byte	74
 5449 0f2f FF       		.byte	-1
 5450 0f30 C0       		.byte	-64
 5451 0f31 2A       		.byte	42
 5452 0f32 4A       		.byte	74
 5453 0f33 FF       		.byte	-1
 5454 0f34 BF       		.byte	-65
 5455 0f35 29       		.byte	41
 5456 0f36 4A       		.byte	74
 5457 0f37 FF       		.byte	-1
 5458 0f38 B4       		.byte	-76
 5459 0f39 1D       		.byte	29
 5460 0f3a 47       		.byte	71
 5461 0f3b FF       		.byte	-1
 5462 0f3c B3       		.byte	-77
 5463 0f3d 1C       		.byte	28
 5464 0f3e 47       		.byte	71
 5465 0f3f FF       		.byte	-1
 5466 0f40 B3       		.byte	-77
 5467 0f41 1C       		.byte	28
 5468 0f42 47       		.byte	71
 5469 0f43 FF       		.byte	-1
 5470 0f44 B2       		.byte	-78
 5471 0f45 1B       		.byte	27
 5472 0f46 47       		.byte	71
 5473 0f47 FF       		.byte	-1
 5474 0f48 B2       		.byte	-78
 5475 0f49 1B       		.byte	27
 5476 0f4a 47       		.byte	71
 5477 0f4b FF       		.byte	-1
GAS LISTING /tmp/ccOaNtkH.s 			page 111


 5478 0f4c B1       		.byte	-79
 5479 0f4d 1B       		.byte	27
 5480 0f4e 47       		.byte	71
 5481 0f4f FF       		.byte	-1
 5482 0f50 B1       		.byte	-79
 5483 0f51 1A       		.byte	26
 5484 0f52 46       		.byte	70
 5485 0f53 FF       		.byte	-1
 5486 0f54 B1       		.byte	-79
 5487 0f55 1A       		.byte	26
 5488 0f56 46       		.byte	70
 5489 0f57 FF       		.byte	-1
 5490 0f58 B0       		.byte	-80
 5491 0f59 19       		.byte	25
 5492 0f5a 46       		.byte	70
 5493 0f5b FF       		.byte	-1
 5494 0f5c B0       		.byte	-80
 5495 0f5d 19       		.byte	25
 5496 0f5e 46       		.byte	70
 5497 0f5f FF       		.byte	-1
 5498 0f60 AF       		.byte	-81
 5499 0f61 18       		.byte	24
 5500 0f62 46       		.byte	70
 5501 0f63 FF       		.byte	-1
 5502 0f64 AF       		.byte	-81
 5503 0f65 18       		.byte	24
 5504 0f66 46       		.byte	70
 5505 0f67 FF       		.byte	-1
 5506 0f68 AE       		.byte	-82
 5507 0f69 17       		.byte	23
 5508 0f6a 46       		.byte	70
 5509 0f6b FF       		.byte	-1
 5510 0f6c AE       		.byte	-82
 5511 0f6d 17       		.byte	23
 5512 0f6e 46       		.byte	70
 5513 0f6f FF       		.byte	-1
 5514 0f70 AE       		.byte	-82
 5515 0f71 17       		.byte	23
 5516 0f72 46       		.byte	70
 5517 0f73 FF       		.byte	-1
 5518 0f74 AD       		.byte	-83
 5519 0f75 16       		.byte	22
 5520 0f76 46       		.byte	70
 5521 0f77 FF       		.byte	-1
 5522 0f78 AD       		.byte	-83
 5523 0f79 16       		.byte	22
 5524 0f7a 45       		.byte	69
 5525 0f7b FF       		.byte	-1
 5526 0f7c AC       		.byte	-84
 5527 0f7d 15       		.byte	21
 5528 0f7e 45       		.byte	69
 5529 0f7f FF       		.byte	-1
 5530 0f80 AC       		.byte	-84
 5531 0f81 15       		.byte	21
 5532 0f82 45       		.byte	69
 5533 0f83 FF       		.byte	-1
 5534 0f84 AB       		.byte	-85
GAS LISTING /tmp/ccOaNtkH.s 			page 112


 5535 0f85 14       		.byte	20
 5536 0f86 45       		.byte	69
 5537 0f87 FF       		.byte	-1
 5538 0f88 AB       		.byte	-85
 5539 0f89 14       		.byte	20
 5540 0f8a 45       		.byte	69
 5541 0f8b FF       		.byte	-1
 5542 0f8c AB       		.byte	-85
 5543 0f8d 13       		.byte	19
 5544 0f8e 45       		.byte	69
 5545 0f8f FF       		.byte	-1
 5546 0f90 AA       		.byte	-86
 5547 0f91 13       		.byte	19
 5548 0f92 45       		.byte	69
 5549 0f93 FF       		.byte	-1
 5550 0f94 AA       		.byte	-86
 5551 0f95 12       		.byte	18
 5552 0f96 45       		.byte	69
 5553 0f97 FF       		.byte	-1
 5554 0f98 A9       		.byte	-87
 5555 0f99 12       		.byte	18
 5556 0f9a 45       		.byte	69
 5557 0f9b FF       		.byte	-1
 5558 0f9c A9       		.byte	-87
 5559 0f9d 11       		.byte	17
 5560 0f9e 44       		.byte	68
 5561 0f9f FF       		.byte	-1
 5562 0fa0 A8       		.byte	-88
 5563 0fa1 11       		.byte	17
 5564 0fa2 44       		.byte	68
 5565 0fa3 FF       		.byte	-1
 5566 0fa4 A8       		.byte	-88
 5567 0fa5 10       		.byte	16
 5568 0fa6 44       		.byte	68
 5569 0fa7 FF       		.byte	-1
 5570 0fa8 A8       		.byte	-88
 5571 0fa9 10       		.byte	16
 5572 0faa 44       		.byte	68
 5573 0fab FF       		.byte	-1
 5574 0fac A7       		.byte	-89
 5575 0fad 0F       		.byte	15
 5576 0fae 44       		.byte	68
 5577 0faf FF       		.byte	-1
 5578 0fb0 A7       		.byte	-89
 5579 0fb1 0E       		.byte	14
 5580 0fb2 44       		.byte	68
 5581 0fb3 FF       		.byte	-1
 5582 0fb4 A6       		.byte	-90
 5583 0fb5 0E       		.byte	14
 5584 0fb6 44       		.byte	68
 5585 0fb7 FF       		.byte	-1
 5586 0fb8 A6       		.byte	-90
 5587 0fb9 0D       		.byte	13
 5588 0fba 44       		.byte	68
 5589 0fbb FF       		.byte	-1
 5590 0fbc A5       		.byte	-91
 5591 0fbd 0D       		.byte	13
GAS LISTING /tmp/ccOaNtkH.s 			page 113


 5592 0fbe 44       		.byte	68
 5593 0fbf FF       		.byte	-1
 5594 0fc0 A5       		.byte	-91
 5595 0fc1 0C       		.byte	12
 5596 0fc2 43       		.byte	67
 5597 0fc3 FF       		.byte	-1
 5598 0fc4 A4       		.byte	-92
 5599 0fc5 0C       		.byte	12
 5600 0fc6 43       		.byte	67
 5601 0fc7 FF       		.byte	-1
 5602 0fc8 A4       		.byte	-92
 5603 0fc9 0B       		.byte	11
 5604 0fca 43       		.byte	67
 5605 0fcb FF       		.byte	-1
 5606 0fcc A4       		.byte	-92
 5607 0fcd 0A       		.byte	10
 5608 0fce 43       		.byte	67
 5609 0fcf FF       		.byte	-1
 5610 0fd0 A3       		.byte	-93
 5611 0fd1 0A       		.byte	10
 5612 0fd2 43       		.byte	67
 5613 0fd3 FF       		.byte	-1
 5614 0fd4 A3       		.byte	-93
 5615 0fd5 09       		.byte	9
 5616 0fd6 43       		.byte	67
 5617 0fd7 FF       		.byte	-1
 5618 0fd8 A2       		.byte	-94
 5619 0fd9 08       		.byte	8
 5620 0fda 43       		.byte	67
 5621 0fdb FF       		.byte	-1
 5622 0fdc A2       		.byte	-94
 5623 0fdd 07       		.byte	7
 5624 0fde 43       		.byte	67
 5625 0fdf FF       		.byte	-1
 5626 0fe0 A1       		.byte	-95
 5627 0fe1 07       		.byte	7
 5628 0fe2 43       		.byte	67
 5629 0fe3 FF       		.byte	-1
 5630 0fe4 A1       		.byte	-95
 5631 0fe5 06       		.byte	6
 5632 0fe6 42       		.byte	66
 5633 0fe7 FF       		.byte	-1
 5634 0fe8 A1       		.byte	-95
 5635 0fe9 05       		.byte	5
 5636 0fea 42       		.byte	66
 5637 0feb FF       		.byte	-1
 5638 0fec A0       		.byte	-96
 5639 0fed 05       		.byte	5
 5640 0fee 42       		.byte	66
 5641 0fef FF       		.byte	-1
 5642 0ff0 A0       		.byte	-96
 5643 0ff1 04       		.byte	4
 5644 0ff2 42       		.byte	66
 5645 0ff3 FF       		.byte	-1
 5646 0ff4 9F       		.byte	-97
 5647 0ff5 03       		.byte	3
 5648 0ff6 42       		.byte	66
GAS LISTING /tmp/ccOaNtkH.s 			page 114


 5649 0ff7 FF       		.byte	-1
 5650 0ff8 9F       		.byte	-97
 5651 0ff9 02       		.byte	2
 5652 0ffa 42       		.byte	66
 5653 0ffb FF       		.byte	-1
 5654 0ffc 9E       		.byte	-98
 5655 0ffd 02       		.byte	2
 5656 0ffe 42       		.byte	66
 5657 0fff FF       		.byte	-1
 5658 1000 9E       		.byte	-98
 5659 1001 01       		.byte	1
 5660 1002 42       		.byte	66
 5661 1003 FF       		.byte	-1
 5662              		.section	.rodata.cst4,"aM",@progbits,4
 5663              		.align 4
 5664              	.LC0:
 5665 0000 0000003F 		.long	1056964608
 5666              		.align 4
 5667              	.LC1:
 5668 0004 0000005F 		.long	1593835520
 5669              		.align 4
 5670              	.LC3:
 5671 0008 0000803F 		.long	1065353216
 5672              		.text
 5673              	.Letext0:
 5674              		.section	.debug_loc,"",@progbits
 5675              	.Ldebug_loc0:
 5676              	.LLST0:
 5677 0000 00000000 		.quad	.LVL0-.Ltext0
 5677      00000000 
 5678 0008 7D000000 		.quad	.LVL5-.Ltext0
 5678      00000000 
 5679 0010 0100     		.value	0x1
 5680 0012 54       		.byte	0x54
 5681 0013 1A010000 		.quad	.LVL11-.Ltext0
 5681      00000000 
 5682 001b 25010000 		.quad	.LFE28-.Ltext0
 5682      00000000 
 5683 0023 0100     		.value	0x1
 5684 0025 54       		.byte	0x54
 5685 0026 00000000 		.quad	0x0
 5685      00000000 
 5686 002e 00000000 		.quad	0x0
 5686      00000000 
 5687              	.LLST1:
 5688 0036 00000000 		.quad	.LVL0-.Ltext0
 5688      00000000 
 5689 003e 82000000 		.quad	.LVL6-.Ltext0
 5689      00000000 
 5690 0046 0100     		.value	0x1
 5691 0048 51       		.byte	0x51
 5692 0049 1A010000 		.quad	.LVL11-.Ltext0
 5692      00000000 
 5693 0051 25010000 		.quad	.LFE28-.Ltext0
 5693      00000000 
 5694 0059 0100     		.value	0x1
 5695 005b 51       		.byte	0x51
GAS LISTING /tmp/ccOaNtkH.s 			page 115


 5696 005c 00000000 		.quad	0x0
 5696      00000000 
 5697 0064 00000000 		.quad	0x0
 5697      00000000 
 5698              	.LLST2:
 5699 006c 00000000 		.quad	.LVL0-.Ltext0
 5699      00000000 
 5700 0074 B2000000 		.quad	.LVL7-.Ltext0
 5700      00000000 
 5701 007c 0100     		.value	0x1
 5702 007e 52       		.byte	0x52
 5703 007f 1A010000 		.quad	.LVL11-.Ltext0
 5703      00000000 
 5704 0087 25010000 		.quad	.LFE28-.Ltext0
 5704      00000000 
 5705 008f 0100     		.value	0x1
 5706 0091 52       		.byte	0x52
 5707 0092 00000000 		.quad	0x0
 5707      00000000 
 5708 009a 00000000 		.quad	0x0
 5708      00000000 
 5709              	.LLST3:
 5710 00a2 43000000 		.quad	.LVL1-.Ltext0
 5710      00000000 
 5711 00aa 0F010000 		.quad	.LVL10-.Ltext0
 5711      00000000 
 5712 00b2 0100     		.value	0x1
 5713 00b4 56       		.byte	0x56
 5714 00b5 1A010000 		.quad	.LVL11-.Ltext0
 5714      00000000 
 5715 00bd 25010000 		.quad	.LFE28-.Ltext0
 5715      00000000 
 5716 00c5 0100     		.value	0x1
 5717 00c7 56       		.byte	0x56
 5718 00c8 00000000 		.quad	0x0
 5718      00000000 
 5719 00d0 00000000 		.quad	0x0
 5719      00000000 
 5720              	.LLST4:
 5721 00d8 53000000 		.quad	.LVL2-.Ltext0
 5721      00000000 
 5722 00e0 B2000000 		.quad	.LVL7-.Ltext0
 5722      00000000 
 5723 00e8 0100     		.value	0x1
 5724 00ea 59       		.byte	0x59
 5725 00eb 1A010000 		.quad	.LVL11-.Ltext0
 5725      00000000 
 5726 00f3 25010000 		.quad	.LFE28-.Ltext0
 5726      00000000 
 5727 00fb 0100     		.value	0x1
 5728 00fd 59       		.byte	0x59
 5729 00fe 00000000 		.quad	0x0
 5729      00000000 
 5730 0106 00000000 		.quad	0x0
 5730      00000000 
 5731              	.LLST5:
 5732 010e 63000000 		.quad	.LVL3-.Ltext0
GAS LISTING /tmp/ccOaNtkH.s 			page 116


 5732      00000000 
 5733 0116 0F010000 		.quad	.LVL10-.Ltext0
 5733      00000000 
 5734 011e 0100     		.value	0x1
 5735 0120 5D       		.byte	0x5d
 5736 0121 1A010000 		.quad	.LVL11-.Ltext0
 5736      00000000 
 5737 0129 25010000 		.quad	.LFE28-.Ltext0
 5737      00000000 
 5738 0131 0100     		.value	0x1
 5739 0133 5D       		.byte	0x5d
 5740 0134 00000000 		.quad	0x0
 5740      00000000 
 5741 013c 00000000 		.quad	0x0
 5741      00000000 
 5742              	.LLST6:
 5743 0144 70000000 		.quad	.LVL4-.Ltext0
 5743      00000000 
 5744 014c 0F010000 		.quad	.LVL10-.Ltext0
 5744      00000000 
 5745 0154 0100     		.value	0x1
 5746 0156 53       		.byte	0x53
 5747 0157 00000000 		.quad	0x0
 5747      00000000 
 5748 015f 00000000 		.quad	0x0
 5748      00000000 
 5749              	.LLST7:
 5750 0167 70000000 		.quad	.LVL4-.Ltext0
 5750      00000000 
 5751 016f 0F010000 		.quad	.LVL10-.Ltext0
 5751      00000000 
 5752 0177 0100     		.value	0x1
 5753 0179 59       		.byte	0x59
 5754 017a 00000000 		.quad	0x0
 5754      00000000 
 5755 0182 00000000 		.quad	0x0
 5755      00000000 
 5756              	.LLST8:
 5757 018a B2000000 		.quad	.LVL7-.Ltext0
 5757      00000000 
 5758 0192 DC000000 		.quad	.LVL8-.Ltext0
 5758      00000000 
 5759 019a 1C00     		.value	0x1c
 5760 019c 7F       		.byte	0x7f
 5761 019d 00       		.sleb128 0
 5762 019e 79       		.byte	0x79
 5763 019f 00       		.sleb128 0
 5764 01a0 22       		.byte	0x22
 5765 01a1 75       		.byte	0x75
 5766 01a2 0C       		.sleb128 12
 5767 01a3 94       		.byte	0x94
 5768 01a4 04       		.byte	0x4
 5769 01a5 1E       		.byte	0x1e
 5770 01a6 08       		.byte	0x8
 5771 01a7 20       		.byte	0x20
 5772 01a8 24       		.byte	0x24
 5773 01a9 08       		.byte	0x8
GAS LISTING /tmp/ccOaNtkH.s 			page 117


 5774 01aa 20       		.byte	0x20
 5775 01ab 25       		.byte	0x25
 5776 01ac 91       		.byte	0x91
 5777 01ad B87F     		.sleb128 -72
 5778 01af 06       		.byte	0x6
 5779 01b0 22       		.byte	0x22
 5780 01b1 32       		.byte	0x32
 5781 01b2 24       		.byte	0x24
 5782 01b3 75       		.byte	0x75
 5783 01b4 00       		.sleb128 0
 5784 01b5 06       		.byte	0x6
 5785 01b6 22       		.byte	0x22
 5786 01b7 9F       		.byte	0x9f
 5787 01b8 00000000 		.quad	0x0
 5787      00000000 
 5788 01c0 00000000 		.quad	0x0
 5788      00000000 
 5789              	.LLST9:
 5790 01c8 B2000000 		.quad	.LVL7-.Ltext0
 5790      00000000 
 5791 01d0 DC000000 		.quad	.LVL8-.Ltext0
 5791      00000000 
 5792 01d8 1500     		.value	0x15
 5793 01da 79       		.byte	0x79
 5794 01db 00       		.sleb128 0
 5795 01dc 7C       		.byte	0x7c
 5796 01dd 00       		.sleb128 0
 5797 01de 1E       		.byte	0x1e
 5798 01df 08       		.byte	0x8
 5799 01e0 20       		.byte	0x20
 5800 01e1 24       		.byte	0x24
 5801 01e2 08       		.byte	0x8
 5802 01e3 20       		.byte	0x20
 5803 01e4 25       		.byte	0x25
 5804 01e5 91       		.byte	0x91
 5805 01e6 40       		.sleb128 -64
 5806 01e7 06       		.byte	0x6
 5807 01e8 22       		.byte	0x22
 5808 01e9 32       		.byte	0x32
 5809 01ea 24       		.byte	0x24
 5810 01eb 7E       		.byte	0x7e
 5811 01ec 00       		.sleb128 0
 5812 01ed 22       		.byte	0x22
 5813 01ee 9F       		.byte	0x9f
 5814 01ef 00000000 		.quad	0x0
 5814      00000000 
 5815 01f7 00000000 		.quad	0x0
 5815      00000000 
 5816              	.LLST10:
 5817 01ff B2000000 		.quad	.LVL7-.Ltext0
 5817      00000000 
 5818 0207 DC000000 		.quad	.LVL8-.Ltext0
 5818      00000000 
 5819 020f 0100     		.value	0x1
 5820 0211 56       		.byte	0x56
 5821 0212 00000000 		.quad	0x0
 5821      00000000 
GAS LISTING /tmp/ccOaNtkH.s 			page 118


 5822 021a 00000000 		.quad	0x0
 5822      00000000 
 5823              	.LLST11:
 5824 0222 40010000 		.quad	.LVL13-.Ltext0
 5824      00000000 
 5825 022a BD010000 		.quad	.LVL18-.Ltext0
 5825      00000000 
 5826 0232 0100     		.value	0x1
 5827 0234 54       		.byte	0x54
 5828 0235 5E020000 		.quad	.LVL24-.Ltext0
 5828      00000000 
 5829 023d 69020000 		.quad	.LFE30-.Ltext0
 5829      00000000 
 5830 0245 0100     		.value	0x1
 5831 0247 54       		.byte	0x54
 5832 0248 00000000 		.quad	0x0
 5832      00000000 
 5833 0250 00000000 		.quad	0x0
 5833      00000000 
 5834              	.LLST12:
 5835 0258 40010000 		.quad	.LVL13-.Ltext0
 5835      00000000 
 5836 0260 C2010000 		.quad	.LVL19-.Ltext0
 5836      00000000 
 5837 0268 0100     		.value	0x1
 5838 026a 51       		.byte	0x51
 5839 026b 5E020000 		.quad	.LVL24-.Ltext0
 5839      00000000 
 5840 0273 69020000 		.quad	.LFE30-.Ltext0
 5840      00000000 
 5841 027b 0100     		.value	0x1
 5842 027d 51       		.byte	0x51
 5843 027e 00000000 		.quad	0x0
 5843      00000000 
 5844 0286 00000000 		.quad	0x0
 5844      00000000 
 5845              	.LLST13:
 5846 028e 40010000 		.quad	.LVL13-.Ltext0
 5846      00000000 
 5847 0296 F2010000 		.quad	.LVL20-.Ltext0
 5847      00000000 
 5848 029e 0100     		.value	0x1
 5849 02a0 52       		.byte	0x52
 5850 02a1 5E020000 		.quad	.LVL24-.Ltext0
 5850      00000000 
 5851 02a9 69020000 		.quad	.LFE30-.Ltext0
 5851      00000000 
 5852 02b1 0100     		.value	0x1
 5853 02b3 52       		.byte	0x52
 5854 02b4 00000000 		.quad	0x0
 5854      00000000 
 5855 02bc 00000000 		.quad	0x0
 5855      00000000 
 5856              	.LLST14:
 5857 02c4 83010000 		.quad	.LVL14-.Ltext0
 5857      00000000 
 5858 02cc 53020000 		.quad	.LVL23-.Ltext0
GAS LISTING /tmp/ccOaNtkH.s 			page 119


 5858      00000000 
 5859 02d4 0100     		.value	0x1
 5860 02d6 56       		.byte	0x56
 5861 02d7 5E020000 		.quad	.LVL24-.Ltext0
 5861      00000000 
 5862 02df 69020000 		.quad	.LFE30-.Ltext0
 5862      00000000 
 5863 02e7 0100     		.value	0x1
 5864 02e9 56       		.byte	0x56
 5865 02ea 00000000 		.quad	0x0
 5865      00000000 
 5866 02f2 00000000 		.quad	0x0
 5866      00000000 
 5867              	.LLST15:
 5868 02fa 93010000 		.quad	.LVL15-.Ltext0
 5868      00000000 
 5869 0302 F2010000 		.quad	.LVL20-.Ltext0
 5869      00000000 
 5870 030a 0100     		.value	0x1
 5871 030c 59       		.byte	0x59
 5872 030d 5E020000 		.quad	.LVL24-.Ltext0
 5872      00000000 
 5873 0315 69020000 		.quad	.LFE30-.Ltext0
 5873      00000000 
 5874 031d 0100     		.value	0x1
 5875 031f 59       		.byte	0x59
 5876 0320 00000000 		.quad	0x0
 5876      00000000 
 5877 0328 00000000 		.quad	0x0
 5877      00000000 
 5878              	.LLST16:
 5879 0330 A3010000 		.quad	.LVL16-.Ltext0
 5879      00000000 
 5880 0338 53020000 		.quad	.LVL23-.Ltext0
 5880      00000000 
 5881 0340 0100     		.value	0x1
 5882 0342 5D       		.byte	0x5d
 5883 0343 5E020000 		.quad	.LVL24-.Ltext0
 5883      00000000 
 5884 034b 69020000 		.quad	.LFE30-.Ltext0
 5884      00000000 
 5885 0353 0100     		.value	0x1
 5886 0355 5D       		.byte	0x5d
 5887 0356 00000000 		.quad	0x0
 5887      00000000 
 5888 035e 00000000 		.quad	0x0
 5888      00000000 
 5889              	.LLST17:
 5890 0366 B0010000 		.quad	.LVL17-.Ltext0
 5890      00000000 
 5891 036e 53020000 		.quad	.LVL23-.Ltext0
 5891      00000000 
 5892 0376 0100     		.value	0x1
 5893 0378 53       		.byte	0x53
 5894 0379 00000000 		.quad	0x0
 5894      00000000 
 5895 0381 00000000 		.quad	0x0
GAS LISTING /tmp/ccOaNtkH.s 			page 120


 5895      00000000 
 5896              	.LLST18:
 5897 0389 B0010000 		.quad	.LVL17-.Ltext0
 5897      00000000 
 5898 0391 53020000 		.quad	.LVL23-.Ltext0
 5898      00000000 
 5899 0399 0100     		.value	0x1
 5900 039b 59       		.byte	0x59
 5901 039c 00000000 		.quad	0x0
 5901      00000000 
 5902 03a4 00000000 		.quad	0x0
 5902      00000000 
 5903              	.LLST19:
 5904 03ac F2010000 		.quad	.LVL20-.Ltext0
 5904      00000000 
 5905 03b4 1C020000 		.quad	.LVL21-.Ltext0
 5905      00000000 
 5906 03bc 1C00     		.value	0x1c
 5907 03be 7F       		.byte	0x7f
 5908 03bf 00       		.sleb128 0
 5909 03c0 79       		.byte	0x79
 5910 03c1 00       		.sleb128 0
 5911 03c2 22       		.byte	0x22
 5912 03c3 75       		.byte	0x75
 5913 03c4 0C       		.sleb128 12
 5914 03c5 94       		.byte	0x94
 5915 03c6 04       		.byte	0x4
 5916 03c7 1E       		.byte	0x1e
 5917 03c8 08       		.byte	0x8
 5918 03c9 20       		.byte	0x20
 5919 03ca 24       		.byte	0x24
 5920 03cb 08       		.byte	0x8
 5921 03cc 20       		.byte	0x20
 5922 03cd 25       		.byte	0x25
 5923 03ce 91       		.byte	0x91
 5924 03cf B87F     		.sleb128 -72
 5925 03d1 06       		.byte	0x6
 5926 03d2 22       		.byte	0x22
 5927 03d3 32       		.byte	0x32
 5928 03d4 24       		.byte	0x24
 5929 03d5 75       		.byte	0x75
 5930 03d6 00       		.sleb128 0
 5931 03d7 06       		.byte	0x6
 5932 03d8 22       		.byte	0x22
 5933 03d9 9F       		.byte	0x9f
 5934 03da 00000000 		.quad	0x0
 5934      00000000 
 5935 03e2 00000000 		.quad	0x0
 5935      00000000 
 5936              	.LLST20:
 5937 03ea F2010000 		.quad	.LVL20-.Ltext0
 5937      00000000 
 5938 03f2 1C020000 		.quad	.LVL21-.Ltext0
 5938      00000000 
 5939 03fa 1500     		.value	0x15
 5940 03fc 79       		.byte	0x79
 5941 03fd 00       		.sleb128 0
GAS LISTING /tmp/ccOaNtkH.s 			page 121


 5942 03fe 7C       		.byte	0x7c
 5943 03ff 00       		.sleb128 0
 5944 0400 1E       		.byte	0x1e
 5945 0401 08       		.byte	0x8
 5946 0402 20       		.byte	0x20
 5947 0403 24       		.byte	0x24
 5948 0404 08       		.byte	0x8
 5949 0405 20       		.byte	0x20
 5950 0406 25       		.byte	0x25
 5951 0407 91       		.byte	0x91
 5952 0408 40       		.sleb128 -64
 5953 0409 06       		.byte	0x6
 5954 040a 22       		.byte	0x22
 5955 040b 32       		.byte	0x32
 5956 040c 24       		.byte	0x24
 5957 040d 7E       		.byte	0x7e
 5958 040e 00       		.sleb128 0
 5959 040f 22       		.byte	0x22
 5960 0410 9F       		.byte	0x9f
 5961 0411 00000000 		.quad	0x0
 5961      00000000 
 5962 0419 00000000 		.quad	0x0
 5962      00000000 
 5963              	.LLST21:
 5964 0421 F2010000 		.quad	.LVL20-.Ltext0
 5964      00000000 
 5965 0429 1C020000 		.quad	.LVL21-.Ltext0
 5965      00000000 
 5966 0431 0100     		.value	0x1
 5967 0433 56       		.byte	0x56
 5968 0434 00000000 		.quad	0x0
 5968      00000000 
 5969 043c 00000000 		.quad	0x0
 5969      00000000 
 5970              	.LLST22:
 5971 0444 90020000 		.quad	.LVL27-.Ltext0
 5971      00000000 
 5972 044c 97020000 		.quad	.LVL28-.Ltext0
 5972      00000000 
 5973 0454 0100     		.value	0x1
 5974 0456 55       		.byte	0x55
 5975 0457 97020000 		.quad	.LVL28-.Ltext0
 5975      00000000 
 5976 045f A0020000 		.quad	.LVL29-.Ltext0
 5976      00000000 
 5977 0467 0100     		.value	0x1
 5978 0469 53       		.byte	0x53
 5979 046a A0020000 		.quad	.LVL29-.Ltext0
 5979      00000000 
 5980 0472 A5020000 		.quad	.LFE42-.Ltext0
 5980      00000000 
 5981 047a 0100     		.value	0x1
 5982 047c 55       		.byte	0x55
 5983 047d 00000000 		.quad	0x0
 5983      00000000 
 5984 0485 00000000 		.quad	0x0
 5984      00000000 
GAS LISTING /tmp/ccOaNtkH.s 			page 122


 5985              	.LLST23:
 5986 048d B0020000 		.quad	.LVL30-.Ltext0
 5986      00000000 
 5987 0495 B7020000 		.quad	.LVL31-.Ltext0
 5987      00000000 
 5988 049d 0100     		.value	0x1
 5989 049f 55       		.byte	0x55
 5990 04a0 B7020000 		.quad	.LVL31-.Ltext0
 5990      00000000 
 5991 04a8 C0020000 		.quad	.LVL32-.Ltext0
 5991      00000000 
 5992 04b0 0100     		.value	0x1
 5993 04b2 53       		.byte	0x53
 5994 04b3 C0020000 		.quad	.LVL32-.Ltext0
 5994      00000000 
 5995 04bb C5020000 		.quad	.LFE40-.Ltext0
 5995      00000000 
 5996 04c3 0100     		.value	0x1
 5997 04c5 55       		.byte	0x55
 5998 04c6 00000000 		.quad	0x0
 5998      00000000 
 5999 04ce 00000000 		.quad	0x0
 5999      00000000 
 6000              	.LLST24:
 6001 04d6 D0020000 		.quad	.LVL33-.Ltext0
 6001      00000000 
 6002 04de D7020000 		.quad	.LVL34-.Ltext0
 6002      00000000 
 6003 04e6 0100     		.value	0x1
 6004 04e8 55       		.byte	0x55
 6005 04e9 D7020000 		.quad	.LVL34-.Ltext0
 6005      00000000 
 6006 04f1 E0020000 		.quad	.LVL35-.Ltext0
 6006      00000000 
 6007 04f9 0100     		.value	0x1
 6008 04fb 53       		.byte	0x53
 6009 04fc E0020000 		.quad	.LVL35-.Ltext0
 6009      00000000 
 6010 0504 E5020000 		.quad	.LFE24-.Ltext0
 6010      00000000 
 6011 050c 0100     		.value	0x1
 6012 050e 55       		.byte	0x55
 6013 050f 00000000 		.quad	0x0
 6013      00000000 
 6014 0517 00000000 		.quad	0x0
 6014      00000000 
 6015              	.LLST25:
 6016 051f F0020000 		.quad	.LVL36-.Ltext0
 6016      00000000 
 6017 0527 2A030000 		.quad	.LVL38-.Ltext0
 6017      00000000 
 6018 052f 0100     		.value	0x1
 6019 0531 55       		.byte	0x55
 6020 0532 2A030000 		.quad	.LVL38-.Ltext0
 6020      00000000 
 6021 053a 76030000 		.quad	.LVL46-.Ltext0
 6021      00000000 
GAS LISTING /tmp/ccOaNtkH.s 			page 123


 6022 0542 0100     		.value	0x1
 6023 0544 5D       		.byte	0x5d
 6024 0545 85030000 		.quad	.LVL48-.Ltext0
 6024      00000000 
 6025 054d 9C030000 		.quad	.LFE41-.Ltext0
 6025      00000000 
 6026 0555 0100     		.value	0x1
 6027 0557 5D       		.byte	0x5d
 6028 0558 00000000 		.quad	0x0
 6028      00000000 
 6029 0560 00000000 		.quad	0x0
 6029      00000000 
 6030              	.LLST26:
 6031 0568 F0020000 		.quad	.LVL36-.Ltext0
 6031      00000000 
 6032 0570 1E030000 		.quad	.LVL37-.Ltext0
 6032      00000000 
 6033 0578 0100     		.value	0x1
 6034 057a 54       		.byte	0x54
 6035 057b 1E030000 		.quad	.LVL37-.Ltext0
 6035      00000000 
 6036 0583 71030000 		.quad	.LVL45-.Ltext0
 6036      00000000 
 6037 058b 0100     		.value	0x1
 6038 058d 5C       		.byte	0x5c
 6039 058e 85030000 		.quad	.LVL48-.Ltext0
 6039      00000000 
 6040 0596 9C030000 		.quad	.LFE41-.Ltext0
 6040      00000000 
 6041 059e 0100     		.value	0x1
 6042 05a0 5C       		.byte	0x5c
 6043 05a1 00000000 		.quad	0x0
 6043      00000000 
 6044 05a9 00000000 		.quad	0x0
 6044      00000000 
 6045              	.LLST27:
 6046 05b1 38030000 		.quad	.LVL39-.Ltext0
 6046      00000000 
 6047 05b9 3C030000 		.quad	.LVL40-1-.Ltext0
 6047      00000000 
 6048 05c1 0100     		.value	0x1
 6049 05c3 50       		.byte	0x50
 6050 05c4 3C030000 		.quad	.LVL40-1-.Ltext0
 6050      00000000 
 6051 05cc 5F030000 		.quad	.LVL43-.Ltext0
 6051      00000000 
 6052 05d4 0100     		.value	0x1
 6053 05d6 53       		.byte	0x53
 6054 05d7 5F030000 		.quad	.LVL43-.Ltext0
 6054      00000000 
 6055 05df 80030000 		.quad	.LVL47-.Ltext0
 6055      00000000 
 6056 05e7 0100     		.value	0x1
 6057 05e9 5F       		.byte	0x5f
 6058 05ea 85030000 		.quad	.LVL48-.Ltext0
 6058      00000000 
 6059 05f2 8D030000 		.quad	.LVL49-.Ltext0
GAS LISTING /tmp/ccOaNtkH.s 			page 124


 6059      00000000 
 6060 05fa 0100     		.value	0x1
 6061 05fc 53       		.byte	0x53
 6062 05fd 8D030000 		.quad	.LVL49-.Ltext0
 6062      00000000 
 6063 0605 9C030000 		.quad	.LFE41-.Ltext0
 6063      00000000 
 6064 060d 0100     		.value	0x1
 6065 060f 5F       		.byte	0x5f
 6066 0610 00000000 		.quad	0x0
 6066      00000000 
 6067 0618 00000000 		.quad	0x0
 6067      00000000 
 6068              	.LLST28:
 6069 0620 43030000 		.quad	.LVL41-.Ltext0
 6069      00000000 
 6070 0628 57030000 		.quad	.LVL42-1-.Ltext0
 6070      00000000 
 6071 0630 0100     		.value	0x1
 6072 0632 50       		.byte	0x50
 6073 0633 57030000 		.quad	.LVL42-1-.Ltext0
 6073      00000000 
 6074 063b 67030000 		.quad	.LVL44-.Ltext0
 6074      00000000 
 6075 0643 0100     		.value	0x1
 6076 0645 56       		.byte	0x56
 6077 0646 85030000 		.quad	.LVL48-.Ltext0
 6077      00000000 
 6078 064e 91030000 		.quad	.LVL50-1-.Ltext0
 6078      00000000 
 6079 0656 0100     		.value	0x1
 6080 0658 50       		.byte	0x50
 6081 0659 91030000 		.quad	.LVL50-1-.Ltext0
 6081      00000000 
 6082 0661 9C030000 		.quad	.LFE41-.Ltext0
 6082      00000000 
 6083 0669 0100     		.value	0x1
 6084 066b 56       		.byte	0x56
 6085 066c 00000000 		.quad	0x0
 6085      00000000 
 6086 0674 00000000 		.quad	0x0
 6086      00000000 
 6087              	.LLST29:
 6088 067c A0030000 		.quad	.LVL51-.Ltext0
 6088      00000000 
 6089 0684 B7030000 		.quad	.LVL52-.Ltext0
 6089      00000000 
 6090 068c 0100     		.value	0x1
 6091 068e 55       		.byte	0x55
 6092 068f B7030000 		.quad	.LVL52-.Ltext0
 6092      00000000 
 6093 0697 A5040000 		.quad	.LVL67-.Ltext0
 6093      00000000 
 6094 069f 0100     		.value	0x1
 6095 06a1 53       		.byte	0x53
 6096 06a2 A9040000 		.quad	.LVL68-.Ltext0
 6096      00000000 
GAS LISTING /tmp/ccOaNtkH.s 			page 125


 6097 06aa D9040000 		.quad	.LFE33-.Ltext0
 6097      00000000 
 6098 06b2 0100     		.value	0x1
 6099 06b4 53       		.byte	0x53
 6100 06b5 00000000 		.quad	0x0
 6100      00000000 
 6101 06bd 00000000 		.quad	0x0
 6101      00000000 
 6102              	.LLST30:
 6103 06c5 A0030000 		.quad	.LVL51-.Ltext0
 6103      00000000 
 6104 06cd B7030000 		.quad	.LVL52-.Ltext0
 6104      00000000 
 6105 06d5 0100     		.value	0x1
 6106 06d7 54       		.byte	0x54
 6107 06d8 A9040000 		.quad	.LVL68-.Ltext0
 6107      00000000 
 6108 06e0 C3040000 		.quad	.LVL70-1-.Ltext0
 6108      00000000 
 6109 06e8 0100     		.value	0x1
 6110 06ea 54       		.byte	0x54
 6111 06eb 00000000 		.quad	0x0
 6111      00000000 
 6112 06f3 00000000 		.quad	0x0
 6112      00000000 
 6113              	.LLST31:
 6114 06fb A0030000 		.quad	.LVL51-.Ltext0
 6114      00000000 
 6115 0703 B7030000 		.quad	.LVL52-.Ltext0
 6115      00000000 
 6116 070b 0100     		.value	0x1
 6117 070d 61       		.byte	0x61
 6118 070e A9040000 		.quad	.LVL68-.Ltext0
 6118      00000000 
 6119 0716 C3040000 		.quad	.LVL70-1-.Ltext0
 6119      00000000 
 6120 071e 0100     		.value	0x1
 6121 0720 61       		.byte	0x61
 6122 0721 00000000 		.quad	0x0
 6122      00000000 
 6123 0729 00000000 		.quad	0x0
 6123      00000000 
 6124              	.LLST32:
 6125 0731 A0030000 		.quad	.LVL51-.Ltext0
 6125      00000000 
 6126 0739 B7030000 		.quad	.LVL52-.Ltext0
 6126      00000000 
 6127 0741 0100     		.value	0x1
 6128 0743 51       		.byte	0x51
 6129 0744 B7030000 		.quad	.LVL52-.Ltext0
 6129      00000000 
 6130 074c AC040000 		.quad	.LVL69-.Ltext0
 6130      00000000 
 6131 0754 0100     		.value	0x1
 6132 0756 50       		.byte	0x50
 6133 0757 AC040000 		.quad	.LVL69-.Ltext0
 6133      00000000 
GAS LISTING /tmp/ccOaNtkH.s 			page 126


 6134 075f C3040000 		.quad	.LVL70-1-.Ltext0
 6134      00000000 
 6135 0767 0100     		.value	0x1
 6136 0769 51       		.byte	0x51
 6137 076a C4040000 		.quad	.LVL70-.Ltext0
 6137      00000000 
 6138 0772 D9040000 		.quad	.LFE33-.Ltext0
 6138      00000000 
 6139 077a 0100     		.value	0x1
 6140 077c 50       		.byte	0x50
 6141 077d 00000000 		.quad	0x0
 6141      00000000 
 6142 0785 00000000 		.quad	0x0
 6142      00000000 
 6143              	.LLST33:
 6144 078d B7030000 		.quad	.LVL52-.Ltext0
 6144      00000000 
 6145 0795 E2030000 		.quad	.LVL53-.Ltext0
 6145      00000000 
 6146 079d 0200     		.value	0x2
 6147 079f 30       		.byte	0x30
 6148 07a0 9F       		.byte	0x9f
 6149 07a1 97040000 		.quad	.LVL65-.Ltext0
 6149      00000000 
 6150 07a9 A0040000 		.quad	.LVL66-.Ltext0
 6150      00000000 
 6151 07b1 0100     		.value	0x1
 6152 07b3 5C       		.byte	0x5c
 6153 07b4 00000000 		.quad	0x0
 6153      00000000 
 6154 07bc 00000000 		.quad	0x0
 6154      00000000 
 6155              	.LLST34:
 6156 07c4 ED030000 		.quad	.LVL54-.Ltext0
 6156      00000000 
 6157 07cc F7030000 		.quad	.LVL55-.Ltext0
 6157      00000000 
 6158 07d4 1200     		.value	0x12
 6159 07d6 7C       		.byte	0x7c
 6160 07d7 00       		.sleb128 0
 6161 07d8 75       		.byte	0x75
 6162 07d9 00       		.sleb128 0
 6163 07da 1E       		.byte	0x1e
 6164 07db 08       		.byte	0x8
 6165 07dc 20       		.byte	0x20
 6166 07dd 24       		.byte	0x24
 6167 07de 08       		.byte	0x8
 6168 07df 20       		.byte	0x20
 6169 07e0 25       		.byte	0x25
 6170 07e1 32       		.byte	0x32
 6171 07e2 24       		.byte	0x24
 6172 07e3 73       		.byte	0x73
 6173 07e4 00       		.sleb128 0
 6174 07e5 06       		.byte	0x6
 6175 07e6 22       		.byte	0x22
 6176 07e7 9F       		.byte	0x9f
 6177 07e8 F7030000 		.quad	.LVL55-.Ltext0
GAS LISTING /tmp/ccOaNtkH.s 			page 127


 6177      00000000 
 6178 07f0 FF030000 		.quad	.LVL56-.Ltext0
 6178      00000000 
 6179 07f8 0F00     		.value	0xf
 6180 07fa 75       		.byte	0x75
 6181 07fb 00       		.sleb128 0
 6182 07fc 08       		.byte	0x8
 6183 07fd 20       		.byte	0x20
 6184 07fe 24       		.byte	0x24
 6185 07ff 08       		.byte	0x8
 6186 0800 20       		.byte	0x20
 6187 0801 25       		.byte	0x25
 6188 0802 32       		.byte	0x32
 6189 0803 24       		.byte	0x24
 6190 0804 73       		.byte	0x73
 6191 0805 00       		.sleb128 0
 6192 0806 06       		.byte	0x6
 6193 0807 22       		.byte	0x22
 6194 0808 9F       		.byte	0x9f
 6195 0809 FF030000 		.quad	.LVL56-.Ltext0
 6195      00000000 
 6196 0811 0E040000 		.quad	.LVL57-.Ltext0
 6196      00000000 
 6197 0819 0F00     		.value	0xf
 6198 081b 71       		.byte	0x71
 6199 081c 00       		.sleb128 0
 6200 081d 08       		.byte	0x8
 6201 081e 20       		.byte	0x20
 6202 081f 24       		.byte	0x24
 6203 0820 08       		.byte	0x8
 6204 0821 20       		.byte	0x20
 6205 0822 25       		.byte	0x25
 6206 0823 32       		.byte	0x32
 6207 0824 24       		.byte	0x24
 6208 0825 73       		.byte	0x73
 6209 0826 00       		.sleb128 0
 6210 0827 06       		.byte	0x6
 6211 0828 22       		.byte	0x22
 6212 0829 9F       		.byte	0x9f
 6213 082a 00000000 		.quad	0x0
 6213      00000000 
 6214 0832 00000000 		.quad	0x0
 6214      00000000 
 6215              	.LLST35:
 6216 083a ED030000 		.quad	.LVL54-.Ltext0
 6216      00000000 
 6217 0842 F7030000 		.quad	.LVL55-.Ltext0
 6217      00000000 
 6218 084a 1100     		.value	0x11
 6219 084c 7C       		.byte	0x7c
 6220 084d 00       		.sleb128 0
 6221 084e 75       		.byte	0x75
 6222 084f 00       		.sleb128 0
 6223 0850 1E       		.byte	0x1e
 6224 0851 32       		.byte	0x32
 6225 0852 24       		.byte	0x24
 6226 0853 08       		.byte	0x8
GAS LISTING /tmp/ccOaNtkH.s 			page 128


 6227 0854 20       		.byte	0x20
 6228 0855 24       		.byte	0x24
 6229 0856 08       		.byte	0x8
 6230 0857 20       		.byte	0x20
 6231 0858 25       		.byte	0x25
 6232 0859 70       		.byte	0x70
 6233 085a 00       		.sleb128 0
 6234 085b 22       		.byte	0x22
 6235 085c 9F       		.byte	0x9f
 6236 085d F7030000 		.quad	.LVL55-.Ltext0
 6236      00000000 
 6237 0865 FF030000 		.quad	.LVL56-.Ltext0
 6237      00000000 
 6238 086d 0E00     		.value	0xe
 6239 086f 75       		.byte	0x75
 6240 0870 00       		.sleb128 0
 6241 0871 32       		.byte	0x32
 6242 0872 24       		.byte	0x24
 6243 0873 08       		.byte	0x8
 6244 0874 20       		.byte	0x20
 6245 0875 24       		.byte	0x24
 6246 0876 08       		.byte	0x8
 6247 0877 20       		.byte	0x20
 6248 0878 25       		.byte	0x25
 6249 0879 70       		.byte	0x70
 6250 087a 00       		.sleb128 0
 6251 087b 22       		.byte	0x22
 6252 087c 9F       		.byte	0x9f
 6253 087d FF030000 		.quad	.LVL56-.Ltext0
 6253      00000000 
 6254 0885 0E040000 		.quad	.LVL57-.Ltext0
 6254      00000000 
 6255 088d 0E00     		.value	0xe
 6256 088f 71       		.byte	0x71
 6257 0890 00       		.sleb128 0
 6258 0891 32       		.byte	0x32
 6259 0892 24       		.byte	0x24
 6260 0893 08       		.byte	0x8
 6261 0894 20       		.byte	0x20
 6262 0895 24       		.byte	0x24
 6263 0896 08       		.byte	0x8
 6264 0897 20       		.byte	0x20
 6265 0898 25       		.byte	0x25
 6266 0899 70       		.byte	0x70
 6267 089a 00       		.sleb128 0
 6268 089b 22       		.byte	0x22
 6269 089c 9F       		.byte	0x9f
 6270 089d 00000000 		.quad	0x0
 6270      00000000 
 6271 08a5 00000000 		.quad	0x0
 6271      00000000 
 6272              	.LLST36:
 6273 08ad ED030000 		.quad	.LVL54-.Ltext0
 6273      00000000 
 6274 08b5 0E040000 		.quad	.LVL57-.Ltext0
 6274      00000000 
 6275 08bd 0200     		.value	0x2
GAS LISTING /tmp/ccOaNtkH.s 			page 129


 6276 08bf 30       		.byte	0x30
 6277 08c0 9F       		.byte	0x9f
 6278 08c1 29040000 		.quad	.LVL58-.Ltext0
 6278      00000000 
 6279 08c9 31040000 		.quad	.LVL59-.Ltext0
 6279      00000000 
 6280 08d1 0100     		.value	0x1
 6281 08d3 58       		.byte	0x58
 6282 08d4 87040000 		.quad	.LVL63-.Ltext0
 6282      00000000 
 6283 08dc 93040000 		.quad	.LVL64-.Ltext0
 6283      00000000 
 6284 08e4 0100     		.value	0x1
 6285 08e6 58       		.byte	0x58
 6286 08e7 00000000 		.quad	0x0
 6286      00000000 
 6287 08ef 00000000 		.quad	0x0
 6287      00000000 
 6288              	.LLST37:
 6289 08f7 10050000 		.quad	.LVL72-.Ltext0
 6289      00000000 
 6290 08ff 1D050000 		.quad	.LVL73-.Ltext0
 6290      00000000 
 6291 0907 0100     		.value	0x1
 6292 0909 54       		.byte	0x54
 6293 090a 1D050000 		.quad	.LVL73-.Ltext0
 6293      00000000 
 6294 0912 22050000 		.quad	.LFE31-.Ltext0
 6294      00000000 
 6295 091a 0100     		.value	0x1
 6296 091c 51       		.byte	0x51
 6297 091d 00000000 		.quad	0x0
 6297      00000000 
 6298 0925 00000000 		.quad	0x0
 6298      00000000 
 6299              	.LLST38:
 6300 092d 40050000 		.quad	.LVL75-.Ltext0
 6300      00000000 
 6301 0935 65050000 		.quad	.LVL76-.Ltext0
 6301      00000000 
 6302 093d 0100     		.value	0x1
 6303 093f 55       		.byte	0x55
 6304 0940 65050000 		.quad	.LVL76-.Ltext0
 6304      00000000 
 6305 0948 85050000 		.quad	.LVL80-.Ltext0
 6305      00000000 
 6306 0950 0100     		.value	0x1
 6307 0952 53       		.byte	0x53
 6308 0953 00000000 		.quad	0x0
 6308      00000000 
 6309 095b 00000000 		.quad	0x0
 6309      00000000 
 6310              	.LLST39:
 6311 0963 40050000 		.quad	.LVL75-.Ltext0
 6311      00000000 
 6312 096b 69050000 		.quad	.LVL77-1-.Ltext0
 6312      00000000 
GAS LISTING /tmp/ccOaNtkH.s 			page 130


 6313 0973 0100     		.value	0x1
 6314 0975 54       		.byte	0x54
 6315 0976 69050000 		.quad	.LVL77-1-.Ltext0
 6315      00000000 
 6316 097e 8F050000 		.quad	.LVL82-.Ltext0
 6316      00000000 
 6317 0986 0100     		.value	0x1
 6318 0988 5C       		.byte	0x5c
 6319 0989 00000000 		.quad	0x0
 6319      00000000 
 6320 0991 00000000 		.quad	0x0
 6320      00000000 
 6321              	.LLST40:
 6322 0999 40050000 		.quad	.LVL75-.Ltext0
 6322      00000000 
 6323 09a1 69050000 		.quad	.LVL77-1-.Ltext0
 6323      00000000 
 6324 09a9 0100     		.value	0x1
 6325 09ab 51       		.byte	0x51
 6326 09ac 69050000 		.quad	.LVL77-1-.Ltext0
 6326      00000000 
 6327 09b4 94050000 		.quad	.LVL83-.Ltext0
 6327      00000000 
 6328 09bc 0100     		.value	0x1
 6329 09be 5D       		.byte	0x5d
 6330 09bf 00000000 		.quad	0x0
 6330      00000000 
 6331 09c7 00000000 		.quad	0x0
 6331      00000000 
 6332              	.LLST41:
 6333 09cf 70050000 		.quad	.LVL78-.Ltext0
 6333      00000000 
 6334 09d7 7C050000 		.quad	.LVL79-1-.Ltext0
 6334      00000000 
 6335 09df 0100     		.value	0x1
 6336 09e1 50       		.byte	0x50
 6337 09e2 7C050000 		.quad	.LVL79-1-.Ltext0
 6337      00000000 
 6338 09ea 8A050000 		.quad	.LVL81-.Ltext0
 6338      00000000 
 6339 09f2 0100     		.value	0x1
 6340 09f4 56       		.byte	0x56
 6341 09f5 8A050000 		.quad	.LVL81-.Ltext0
 6341      00000000 
 6342 09fd 99050000 		.quad	.LFE35-.Ltext0
 6342      00000000 
 6343 0a05 0100     		.value	0x1
 6344 0a07 50       		.byte	0x50
 6345 0a08 00000000 		.quad	0x0
 6345      00000000 
 6346 0a10 00000000 		.quad	0x0
 6346      00000000 
 6347              	.LLST42:
 6348 0a18 A0050000 		.quad	.LVL84-.Ltext0
 6348      00000000 
 6349 0a20 BA050000 		.quad	.LVL87-.Ltext0
 6349      00000000 
GAS LISTING /tmp/ccOaNtkH.s 			page 131


 6350 0a28 0100     		.value	0x1
 6351 0a2a 55       		.byte	0x55
 6352 0a2b BA050000 		.quad	.LVL87-.Ltext0
 6352      00000000 
 6353 0a33 8D060000 		.quad	.LVL102-.Ltext0
 6353      00000000 
 6354 0a3b 0100     		.value	0x1
 6355 0a3d 56       		.byte	0x56
 6356 0a3e 9A060000 		.quad	.LVL104-.Ltext0
 6356      00000000 
 6357 0a46 A0060000 		.quad	.LVL106-.Ltext0
 6357      00000000 
 6358 0a4e 0100     		.value	0x1
 6359 0a50 56       		.byte	0x56
 6360 0a51 00000000 		.quad	0x0
 6360      00000000 
 6361 0a59 00000000 		.quad	0x0
 6361      00000000 
 6362              	.LLST43:
 6363 0a61 A0050000 		.quad	.LVL84-.Ltext0
 6363      00000000 
 6364 0a69 B0050000 		.quad	.LVL85-.Ltext0
 6364      00000000 
 6365 0a71 0100     		.value	0x1
 6366 0a73 54       		.byte	0x54
 6367 0a74 B0050000 		.quad	.LVL85-.Ltext0
 6367      00000000 
 6368 0a7c 8F060000 		.quad	.LVL103-.Ltext0
 6368      00000000 
 6369 0a84 0100     		.value	0x1
 6370 0a86 5C       		.byte	0x5c
 6371 0a87 9A060000 		.quad	.LVL104-.Ltext0
 6371      00000000 
 6372 0a8f A2060000 		.quad	.LVL107-.Ltext0
 6372      00000000 
 6373 0a97 0100     		.value	0x1
 6374 0a99 5C       		.byte	0x5c
 6375 0a9a 00000000 		.quad	0x0
 6375      00000000 
 6376 0aa2 00000000 		.quad	0x0
 6376      00000000 
 6377              	.LLST44:
 6378 0aaa D4050000 		.quad	.LVL89-.Ltext0
 6378      00000000 
 6379 0ab2 FA050000 		.quad	.LVL91-.Ltext0
 6379      00000000 
 6380 0aba 0200     		.value	0x2
 6381 0abc 30       		.byte	0x30
 6382 0abd 9F       		.byte	0x9f
 6383 0abe 74060000 		.quad	.LVL99-.Ltext0
 6383      00000000 
 6384 0ac6 7E060000 		.quad	.LVL100-.Ltext0
 6384      00000000 
 6385 0ace 0300     		.value	0x3
 6386 0ad0 91       		.byte	0x91
 6387 0ad1 B07F     		.sleb128 -80
 6388 0ad3 00000000 		.quad	0x0
GAS LISTING /tmp/ccOaNtkH.s 			page 132


 6388      00000000 
 6389 0adb 00000000 		.quad	0x0
 6389      00000000 
 6390              	.LLST45:
 6391 0ae3 B8050000 		.quad	.LVL86-.Ltext0
 6391      00000000 
 6392 0aeb 8C060000 		.quad	.LVL101-.Ltext0
 6392      00000000 
 6393 0af3 0100     		.value	0x1
 6394 0af5 53       		.byte	0x53
 6395 0af6 8C060000 		.quad	.LVL101-.Ltext0
 6395      00000000 
 6396 0afe 99060000 		.quad	.LVL104-1-.Ltext0
 6396      00000000 
 6397 0b06 0100     		.value	0x1
 6398 0b08 54       		.byte	0x54
 6399 0b09 9A060000 		.quad	.LVL104-.Ltext0
 6399      00000000 
 6400 0b11 9F060000 		.quad	.LVL105-.Ltext0
 6400      00000000 
 6401 0b19 0100     		.value	0x1
 6402 0b1b 53       		.byte	0x53
 6403 0b1c 00000000 		.quad	0x0
 6403      00000000 
 6404 0b24 00000000 		.quad	0x0
 6404      00000000 
 6405              	.LLST46:
 6406 0b2c CE050000 		.quad	.LVL88-.Ltext0
 6406      00000000 
 6407 0b34 DF050000 		.quad	.LVL90-.Ltext0
 6407      00000000 
 6408 0b3c 0100     		.value	0x1
 6409 0b3e 50       		.byte	0x50
 6410 0b3f DF050000 		.quad	.LVL90-.Ltext0
 6410      00000000 
 6411 0b47 A9060000 		.quad	.LFE39-.Ltext0
 6411      00000000 
 6412 0b4f 0300     		.value	0x3
 6413 0b51 91       		.byte	0x91
 6414 0b52 B87F     		.sleb128 -72
 6415 0b54 00000000 		.quad	0x0
 6415      00000000 
 6416 0b5c 00000000 		.quad	0x0
 6416      00000000 
 6417              	.LLST47:
 6418 0b64 18060000 		.quad	.LVL92-.Ltext0
 6418      00000000 
 6419 0b6c 1E060000 		.quad	.LVL93-.Ltext0
 6419      00000000 
 6420 0b74 0100     		.value	0x1
 6421 0b76 5E       		.byte	0x5e
 6422 0b77 1E060000 		.quad	.LVL93-.Ltext0
 6422      00000000 
 6423 0b7f 24060000 		.quad	.LVL94-.Ltext0
 6423      00000000 
 6424 0b87 0300     		.value	0x3
 6425 0b89 7E       		.byte	0x7e
GAS LISTING /tmp/ccOaNtkH.s 			page 133


 6426 0b8a 04       		.sleb128 4
 6427 0b8b 9F       		.byte	0x9f
 6428 0b8c 61060000 		.quad	.LVL98-.Ltext0
 6428      00000000 
 6429 0b94 7E060000 		.quad	.LVL100-.Ltext0
 6429      00000000 
 6430 0b9c 0300     		.value	0x3
 6431 0b9e 7E       		.byte	0x7e
 6432 0b9f 04       		.sleb128 4
 6433 0ba0 9F       		.byte	0x9f
 6434 0ba1 00000000 		.quad	0x0
 6434      00000000 
 6435 0ba9 00000000 		.quad	0x0
 6435      00000000 
 6436              	.LLST48:
 6437 0bb1 18060000 		.quad	.LVL92-.Ltext0
 6437      00000000 
 6438 0bb9 1E060000 		.quad	.LVL93-.Ltext0
 6438      00000000 
 6439 0bc1 0200     		.value	0x2
 6440 0bc3 30       		.byte	0x30
 6441 0bc4 9F       		.byte	0x9f
 6442 0bc5 1E060000 		.quad	.LVL93-.Ltext0
 6442      00000000 
 6443 0bcd 24060000 		.quad	.LVL94-.Ltext0
 6443      00000000 
 6444 0bd5 0100     		.value	0x1
 6445 0bd7 5D       		.byte	0x5d
 6446 0bd8 61060000 		.quad	.LVL98-.Ltext0
 6446      00000000 
 6447 0be0 7E060000 		.quad	.LVL100-.Ltext0
 6447      00000000 
 6448 0be8 0100     		.value	0x1
 6449 0bea 5D       		.byte	0x5d
 6450 0beb 00000000 		.quad	0x0
 6450      00000000 
 6451 0bf3 00000000 		.quad	0x0
 6451      00000000 
 6452              	.LLST49:
 6453 0bfb 41060000 		.quad	.LVL95-.Ltext0
 6453      00000000 
 6454 0c03 5D060000 		.quad	.LVL97-.Ltext0
 6454      00000000 
 6455 0c0b 0100     		.value	0x1
 6456 0c0d 61       		.byte	0x61
 6457 0c0e 00000000 		.quad	0x0
 6457      00000000 
 6458 0c16 00000000 		.quad	0x0
 6458      00000000 
 6459              	.LLST50:
 6460 0c1e 1E060000 		.quad	.LVL93-.Ltext0
 6460      00000000 
 6461 0c26 24060000 		.quad	.LVL94-.Ltext0
 6461      00000000 
 6462 0c2e 0100     		.value	0x1
 6463 0c30 62       		.byte	0x62
 6464 0c31 55060000 		.quad	.LVL96-.Ltext0
GAS LISTING /tmp/ccOaNtkH.s 			page 134


 6464      00000000 
 6465 0c39 7E060000 		.quad	.LVL100-.Ltext0
 6465      00000000 
 6466 0c41 0100     		.value	0x1
 6467 0c43 62       		.byte	0x62
 6468 0c44 00000000 		.quad	0x0
 6468      00000000 
 6469 0c4c 00000000 		.quad	0x0
 6469      00000000 
 6470              	.LLST51:
 6471 0c54 C0060000 		.quad	.LVL109-.Ltext0
 6471      00000000 
 6472 0c5c F4060000 		.quad	.LVL110-.Ltext0
 6472      00000000 
 6473 0c64 0100     		.value	0x1
 6474 0c66 55       		.byte	0x55
 6475 0c67 F4060000 		.quad	.LVL110-.Ltext0
 6475      00000000 
 6476 0c6f 1A070000 		.quad	.LVL115-.Ltext0
 6476      00000000 
 6477 0c77 0100     		.value	0x1
 6478 0c79 53       		.byte	0x53
 6479 0c7a 1A070000 		.quad	.LVL115-.Ltext0
 6479      00000000 
 6480 0c82 32070000 		.quad	.LFE36-.Ltext0
 6480      00000000 
 6481 0c8a 0100     		.value	0x1
 6482 0c8c 55       		.byte	0x55
 6483 0c8d 00000000 		.quad	0x0
 6483      00000000 
 6484 0c95 00000000 		.quad	0x0
 6484      00000000 
 6485              	.LLST52:
 6486 0c9d C0060000 		.quad	.LVL109-.Ltext0
 6486      00000000 
 6487 0ca5 F8060000 		.quad	.LVL111-1-.Ltext0
 6487      00000000 
 6488 0cad 0100     		.value	0x1
 6489 0caf 54       		.byte	0x54
 6490 0cb0 F8060000 		.quad	.LVL111-1-.Ltext0
 6490      00000000 
 6491 0cb8 16070000 		.quad	.LVL114-.Ltext0
 6491      00000000 
 6492 0cc0 0100     		.value	0x1
 6493 0cc2 56       		.byte	0x56
 6494 0cc3 16070000 		.quad	.LVL114-.Ltext0
 6494      00000000 
 6495 0ccb 32070000 		.quad	.LFE36-.Ltext0
 6495      00000000 
 6496 0cd3 0100     		.value	0x1
 6497 0cd5 54       		.byte	0x54
 6498 0cd6 00000000 		.quad	0x0
 6498      00000000 
 6499 0cde 00000000 		.quad	0x0
 6499      00000000 
 6500              	.LLST53:
 6501 0ce6 C0060000 		.quad	.LVL109-.Ltext0
GAS LISTING /tmp/ccOaNtkH.s 			page 135


 6501      00000000 
 6502 0cee F8060000 		.quad	.LVL111-1-.Ltext0
 6502      00000000 
 6503 0cf6 0100     		.value	0x1
 6504 0cf8 51       		.byte	0x51
 6505 0cf9 F8060000 		.quad	.LVL111-1-.Ltext0
 6505      00000000 
 6506 0d01 24070000 		.quad	.LVL117-.Ltext0
 6506      00000000 
 6507 0d09 0100     		.value	0x1
 6508 0d0b 5D       		.byte	0x5d
 6509 0d0c 00000000 		.quad	0x0
 6509      00000000 
 6510 0d14 00000000 		.quad	0x0
 6510      00000000 
 6511              	.LLST54:
 6512 0d1c FF060000 		.quad	.LVL112-.Ltext0
 6512      00000000 
 6513 0d24 09070000 		.quad	.LVL113-1-.Ltext0
 6513      00000000 
 6514 0d2c 0100     		.value	0x1
 6515 0d2e 50       		.byte	0x50
 6516 0d2f 09070000 		.quad	.LVL113-1-.Ltext0
 6516      00000000 
 6517 0d37 1F070000 		.quad	.LVL116-.Ltext0
 6517      00000000 
 6518 0d3f 0100     		.value	0x1
 6519 0d41 5C       		.byte	0x5c
 6520 0d42 1F070000 		.quad	.LVL116-.Ltext0
 6520      00000000 
 6521 0d4a 32070000 		.quad	.LFE36-.Ltext0
 6521      00000000 
 6522 0d52 0100     		.value	0x1
 6523 0d54 51       		.byte	0x51
 6524 0d55 00000000 		.quad	0x0
 6524      00000000 
 6525 0d5d 00000000 		.quad	0x0
 6525      00000000 
 6526              	.LLST55:
 6527 0d65 40070000 		.quad	.LVL118-.Ltext0
 6527      00000000 
 6528 0d6d 6F070000 		.quad	.LVL119-.Ltext0
 6528      00000000 
 6529 0d75 0100     		.value	0x1
 6530 0d77 55       		.byte	0x55
 6531 0d78 6F070000 		.quad	.LVL119-.Ltext0
 6531      00000000 
 6532 0d80 94070000 		.quad	.LVL123-.Ltext0
 6532      00000000 
 6533 0d88 0100     		.value	0x1
 6534 0d8a 53       		.byte	0x53
 6535 0d8b 00000000 		.quad	0x0
 6535      00000000 
 6536 0d93 00000000 		.quad	0x0
 6536      00000000 
 6537              	.LLST56:
 6538 0d9b 40070000 		.quad	.LVL118-.Ltext0
GAS LISTING /tmp/ccOaNtkH.s 			page 136


 6538      00000000 
 6539 0da3 7C070000 		.quad	.LVL120-.Ltext0
 6539      00000000 
 6540 0dab 0100     		.value	0x1
 6541 0dad 54       		.byte	0x54
 6542 0dae 7C070000 		.quad	.LVL120-.Ltext0
 6542      00000000 
 6543 0db6 90070000 		.quad	.LVL122-.Ltext0
 6543      00000000 
 6544 0dbe 0100     		.value	0x1
 6545 0dc0 56       		.byte	0x56
 6546 0dc1 90070000 		.quad	.LVL122-.Ltext0
 6546      00000000 
 6547 0dc9 94070000 		.quad	.LVL123-.Ltext0
 6547      00000000 
 6548 0dd1 0200     		.value	0x2
 6549 0dd3 73       		.byte	0x73
 6550 0dd4 0C       		.sleb128 12
 6551 0dd5 00000000 		.quad	0x0
 6551      00000000 
 6552 0ddd 00000000 		.quad	0x0
 6552      00000000 
 6553              	.LLST57:
 6554 0de5 40070000 		.quad	.LVL118-.Ltext0
 6554      00000000 
 6555 0ded 80070000 		.quad	.LVL121-1-.Ltext0
 6555      00000000 
 6556 0df5 0100     		.value	0x1
 6557 0df7 51       		.byte	0x51
 6558 0df8 80070000 		.quad	.LVL121-1-.Ltext0
 6558      00000000 
 6559 0e00 99070000 		.quad	.LVL124-.Ltext0
 6559      00000000 
 6560 0e08 0100     		.value	0x1
 6561 0e0a 5C       		.byte	0x5c
 6562 0e0b 00000000 		.quad	0x0
 6562      00000000 
 6563 0e13 00000000 		.quad	0x0
 6563      00000000 
 6564              	.LLST58:
 6565 0e1b A0070000 		.quad	.LVL125-.Ltext0
 6565      00000000 
 6566 0e23 B6070000 		.quad	.LVL126-.Ltext0
 6566      00000000 
 6567 0e2b 0100     		.value	0x1
 6568 0e2d 55       		.byte	0x55
 6569 0e2e B6070000 		.quad	.LVL126-.Ltext0
 6569      00000000 
 6570 0e36 D9070000 		.quad	.LVL130-.Ltext0
 6570      00000000 
 6571 0e3e 0100     		.value	0x1
 6572 0e40 53       		.byte	0x53
 6573 0e41 00000000 		.quad	0x0
 6573      00000000 
 6574 0e49 00000000 		.quad	0x0
 6574      00000000 
 6575              	.LLST59:
GAS LISTING /tmp/ccOaNtkH.s 			page 137


 6576 0e51 A0070000 		.quad	.LVL125-.Ltext0
 6576      00000000 
 6577 0e59 C1070000 		.quad	.LVL127-1-.Ltext0
 6577      00000000 
 6578 0e61 0100     		.value	0x1
 6579 0e63 54       		.byte	0x54
 6580 0e64 C1070000 		.quad	.LVL127-1-.Ltext0
 6580      00000000 
 6581 0e6c E3070000 		.quad	.LVL132-.Ltext0
 6581      00000000 
 6582 0e74 0100     		.value	0x1
 6583 0e76 5C       		.byte	0x5c
 6584 0e77 00000000 		.quad	0x0
 6584      00000000 
 6585 0e7f 00000000 		.quad	0x0
 6585      00000000 
 6586              	.LLST60:
 6587 0e87 C8070000 		.quad	.LVL128-.Ltext0
 6587      00000000 
 6588 0e8f D1070000 		.quad	.LVL129-1-.Ltext0
 6588      00000000 
 6589 0e97 0100     		.value	0x1
 6590 0e99 50       		.byte	0x50
 6591 0e9a D1070000 		.quad	.LVL129-1-.Ltext0
 6591      00000000 
 6592 0ea2 DE070000 		.quad	.LVL131-.Ltext0
 6592      00000000 
 6593 0eaa 0100     		.value	0x1
 6594 0eac 56       		.byte	0x56
 6595 0ead DE070000 		.quad	.LVL131-.Ltext0
 6595      00000000 
 6596 0eb5 E8070000 		.quad	.LFE23-.Ltext0
 6596      00000000 
 6597 0ebd 0100     		.value	0x1
 6598 0ebf 50       		.byte	0x50
 6599 0ec0 00000000 		.quad	0x0
 6599      00000000 
 6600 0ec8 00000000 		.quad	0x0
 6600      00000000 
 6601              	.LLST61:
 6602 0ed0 F0070000 		.quad	.LVL133-.Ltext0
 6602      00000000 
 6603 0ed8 05080000 		.quad	.LVL135-1-.Ltext0
 6603      00000000 
 6604 0ee0 0100     		.value	0x1
 6605 0ee2 55       		.byte	0x55
 6606 0ee3 05080000 		.quad	.LVL135-1-.Ltext0
 6606      00000000 
 6607 0eeb 75080000 		.quad	.LVL143-.Ltext0
 6607      00000000 
 6608 0ef3 0100     		.value	0x1
 6609 0ef5 53       		.byte	0x53
 6610 0ef6 00000000 		.quad	0x0
 6610      00000000 
 6611 0efe 00000000 		.quad	0x0
 6611      00000000 
 6612              	.LLST62:
GAS LISTING /tmp/ccOaNtkH.s 			page 138


 6613 0f06 F0070000 		.quad	.LVL133-.Ltext0
 6613      00000000 
 6614 0f0e 05080000 		.quad	.LVL135-1-.Ltext0
 6614      00000000 
 6615 0f16 0500     		.value	0x5
 6616 0f18 75       		.byte	0x75
 6617 0f19 00       		.sleb128 0
 6618 0f1a 23       		.byte	0x23
 6619 0f1b 20       		.uleb128 0x20
 6620 0f1c 06       		.byte	0x6
 6621 0f1d 05080000 		.quad	.LVL135-1-.Ltext0
 6621      00000000 
 6622 0f25 75080000 		.quad	.LVL143-.Ltext0
 6622      00000000 
 6623 0f2d 0500     		.value	0x5
 6624 0f2f 73       		.byte	0x73
 6625 0f30 00       		.sleb128 0
 6626 0f31 23       		.byte	0x23
 6627 0f32 20       		.uleb128 0x20
 6628 0f33 06       		.byte	0x6
 6629 0f34 00000000 		.quad	0x0
 6629      00000000 
 6630 0f3c 00000000 		.quad	0x0
 6630      00000000 
 6631              	.LLST63:
 6632 0f44 01080000 		.quad	.LVL134-.Ltext0
 6632      00000000 
 6633 0f4c 05080000 		.quad	.LVL135-1-.Ltext0
 6633      00000000 
 6634 0f54 0200     		.value	0x2
 6635 0f56 75       		.byte	0x75
 6636 0f57 2C       		.sleb128 44
 6637 0f58 05080000 		.quad	.LVL135-1-.Ltext0
 6637      00000000 
 6638 0f60 24080000 		.quad	.LVL137-.Ltext0
 6638      00000000 
 6639 0f68 0100     		.value	0x1
 6640 0f6a 5C       		.byte	0x5c
 6641 0f6b 00000000 		.quad	0x0
 6641      00000000 
 6642 0f73 00000000 		.quad	0x0
 6642      00000000 
 6643              	.LLST64:
 6644 0f7b F0070000 		.quad	.LVL133-.Ltext0
 6644      00000000 
 6645 0f83 05080000 		.quad	.LVL135-1-.Ltext0
 6645      00000000 
 6646 0f8b 0400     		.value	0x4
 6647 0f8d 75       		.byte	0x75
 6648 0f8e 00       		.sleb128 0
 6649 0f8f 23       		.byte	0x23
 6650 0f90 18       		.uleb128 0x18
 6651 0f91 05080000 		.quad	.LVL135-1-.Ltext0
 6651      00000000 
 6652 0f99 75080000 		.quad	.LVL143-.Ltext0
 6652      00000000 
 6653 0fa1 0400     		.value	0x4
GAS LISTING /tmp/ccOaNtkH.s 			page 139


 6654 0fa3 73       		.byte	0x73
 6655 0fa4 00       		.sleb128 0
 6656 0fa5 23       		.byte	0x23
 6657 0fa6 18       		.uleb128 0x18
 6658 0fa7 00000000 		.quad	0x0
 6658      00000000 
 6659 0faf 00000000 		.quad	0x0
 6659      00000000 
 6660              	.LLST65:
 6661 0fb7 F0070000 		.quad	.LVL133-.Ltext0
 6661      00000000 
 6662 0fbf 05080000 		.quad	.LVL135-1-.Ltext0
 6662      00000000 
 6663 0fc7 0400     		.value	0x4
 6664 0fc9 75       		.byte	0x75
 6665 0fca 00       		.sleb128 0
 6666 0fcb 23       		.byte	0x23
 6667 0fcc 28       		.uleb128 0x28
 6668 0fcd 05080000 		.quad	.LVL135-1-.Ltext0
 6668      00000000 
 6669 0fd5 75080000 		.quad	.LVL143-.Ltext0
 6669      00000000 
 6670 0fdd 0400     		.value	0x4
 6671 0fdf 73       		.byte	0x73
 6672 0fe0 00       		.sleb128 0
 6673 0fe1 23       		.byte	0x23
 6674 0fe2 28       		.uleb128 0x28
 6675 0fe3 00000000 		.quad	0x0
 6675      00000000 
 6676 0feb 00000000 		.quad	0x0
 6676      00000000 
 6677              	.LLST66:
 6678 0ff3 F0070000 		.quad	.LVL133-.Ltext0
 6678      00000000 
 6679 0ffb 05080000 		.quad	.LVL135-1-.Ltext0
 6679      00000000 
 6680 1003 0400     		.value	0x4
 6681 1005 75       		.byte	0x75
 6682 1006 00       		.sleb128 0
 6683 1007 23       		.byte	0x23
 6684 1008 10       		.uleb128 0x10
 6685 1009 05080000 		.quad	.LVL135-1-.Ltext0
 6685      00000000 
 6686 1011 75080000 		.quad	.LVL143-.Ltext0
 6686      00000000 
 6687 1019 0400     		.value	0x4
 6688 101b 73       		.byte	0x73
 6689 101c 00       		.sleb128 0
 6690 101d 23       		.byte	0x23
 6691 101e 10       		.uleb128 0x10
 6692 101f 00000000 		.quad	0x0
 6692      00000000 
 6693 1027 00000000 		.quad	0x0
 6693      00000000 
 6694              	.LLST67:
 6695 102f F0070000 		.quad	.LVL133-.Ltext0
 6695      00000000 
GAS LISTING /tmp/ccOaNtkH.s 			page 140


 6696 1037 05080000 		.quad	.LVL135-1-.Ltext0
 6696      00000000 
 6697 103f 0400     		.value	0x4
 6698 1041 75       		.byte	0x75
 6699 1042 00       		.sleb128 0
 6700 1043 23       		.byte	0x23
 6701 1044 08       		.uleb128 0x8
 6702 1045 05080000 		.quad	.LVL135-1-.Ltext0
 6702      00000000 
 6703 104d 75080000 		.quad	.LVL143-.Ltext0
 6703      00000000 
 6704 1055 0400     		.value	0x4
 6705 1057 73       		.byte	0x73
 6706 1058 00       		.sleb128 0
 6707 1059 23       		.byte	0x23
 6708 105a 08       		.uleb128 0x8
 6709 105b 00000000 		.quad	0x0
 6709      00000000 
 6710 1063 00000000 		.quad	0x0
 6710      00000000 
 6711              	.LLST68:
 6712 106b F0070000 		.quad	.LVL133-.Ltext0
 6712      00000000 
 6713 1073 05080000 		.quad	.LVL135-1-.Ltext0
 6713      00000000 
 6714 107b 0200     		.value	0x2
 6715 107d 75       		.byte	0x75
 6716 107e 00       		.sleb128 0
 6717 107f 05080000 		.quad	.LVL135-1-.Ltext0
 6717      00000000 
 6718 1087 75080000 		.quad	.LVL143-.Ltext0
 6718      00000000 
 6719 108f 0200     		.value	0x2
 6720 1091 73       		.byte	0x73
 6721 1092 00       		.sleb128 0
 6722 1093 00000000 		.quad	0x0
 6722      00000000 
 6723 109b 00000000 		.quad	0x0
 6723      00000000 
 6724              	.LLST69:
 6725 10a3 06080000 		.quad	.LVL135-.Ltext0
 6725      00000000 
 6726 10ab 39080000 		.quad	.LVL139-1-.Ltext0
 6726      00000000 
 6727 10b3 0100     		.value	0x1
 6728 10b5 50       		.byte	0x50
 6729 10b6 00000000 		.quad	0x0
 6729      00000000 
 6730 10be 00000000 		.quad	0x0
 6730      00000000 
 6731              	.LLST70:
 6732 10c6 12080000 		.quad	.LVL136-.Ltext0
 6732      00000000 
 6733 10ce 3F080000 		.quad	.LVL140-.Ltext0
 6733      00000000 
 6734 10d6 0100     		.value	0x1
 6735 10d8 56       		.byte	0x56
GAS LISTING /tmp/ccOaNtkH.s 			page 141


 6736 10d9 00000000 		.quad	0x0
 6736      00000000 
 6737 10e1 00000000 		.quad	0x0
 6737      00000000 
 6738              	.LLST71:
 6739 10e9 2B080000 		.quad	.LVL138-.Ltext0
 6739      00000000 
 6740 10f1 78080000 		.quad	.LVL145-.Ltext0
 6740      00000000 
 6741 10f9 0100     		.value	0x1
 6742 10fb 5C       		.byte	0x5c
 6743 10fc 00000000 		.quad	0x0
 6743      00000000 
 6744 1104 00000000 		.quad	0x0
 6744      00000000 
 6745              	.LLST72:
 6746 110c 3A080000 		.quad	.LVL139-.Ltext0
 6746      00000000 
 6747 1114 55080000 		.quad	.LVL141-.Ltext0
 6747      00000000 
 6748 111c 0100     		.value	0x1
 6749 111e 56       		.byte	0x56
 6750 111f 55080000 		.quad	.LVL141-.Ltext0
 6750      00000000 
 6751 1127 6A080000 		.quad	.LVL142-1-.Ltext0
 6751      00000000 
 6752 112f 0100     		.value	0x1
 6753 1131 50       		.byte	0x50
 6754 1132 6A080000 		.quad	.LVL142-1-.Ltext0
 6754      00000000 
 6755 113a 6B080000 		.quad	.LVL142-.Ltext0
 6755      00000000 
 6756 1142 0300     		.value	0x3
 6757 1144 76       		.byte	0x76
 6758 1145 7F       		.sleb128 -1
 6759 1146 9F       		.byte	0x9f
 6760 1147 6B080000 		.quad	.LVL142-.Ltext0
 6760      00000000 
 6761 114f 76080000 		.quad	.LVL144-.Ltext0
 6761      00000000 
 6762 1157 0100     		.value	0x1
 6763 1159 56       		.byte	0x56
 6764 115a 00000000 		.quad	0x0
 6764      00000000 
 6765 1162 00000000 		.quad	0x0
 6765      00000000 
 6766              	.LLST73:
 6767 116a 80080000 		.quad	.LVL146-.Ltext0
 6767      00000000 
 6768 1172 89080000 		.quad	.LVL147-.Ltext0
 6768      00000000 
 6769 117a 0100     		.value	0x1
 6770 117c 55       		.byte	0x55
 6771 117d 89080000 		.quad	.LVL147-.Ltext0
 6771      00000000 
 6772 1185 D0080000 		.quad	.LVL149-.Ltext0
 6772      00000000 
GAS LISTING /tmp/ccOaNtkH.s 			page 142


 6773 118d 0100     		.value	0x1
 6774 118f 53       		.byte	0x53
 6775 1190 D0080000 		.quad	.LVL149-.Ltext0
 6775      00000000 
 6776 1198 12090000 		.quad	.LVL150-1-.Ltext0
 6776      00000000 
 6777 11a0 0200     		.value	0x2
 6778 11a2 73       		.byte	0x73
 6779 11a3 00       		.sleb128 0
 6780 11a4 20090000 		.quad	.LVL151-.Ltext0
 6780      00000000 
 6781 11ac 28090000 		.quad	.LVL152-.Ltext0
 6781      00000000 
 6782 11b4 0200     		.value	0x2
 6783 11b6 73       		.byte	0x73
 6784 11b7 00       		.sleb128 0
 6785 11b8 28090000 		.quad	.LVL152-.Ltext0
 6785      00000000 
 6786 11c0 29090000 		.quad	.LFE26-.Ltext0
 6786      00000000 
 6787 11c8 0200     		.value	0x2
 6788 11ca 91       		.byte	0x91
 6789 11cb 40       		.sleb128 -64
 6790 11cc 00000000 		.quad	0x0
 6790      00000000 
 6791 11d4 00000000 		.quad	0x0
 6791      00000000 
 6792              	.LLST74:
 6793 11dc 80080000 		.quad	.LVL146-.Ltext0
 6793      00000000 
 6794 11e4 A6080000 		.quad	.LVL148-1-.Ltext0
 6794      00000000 
 6795 11ec 0100     		.value	0x1
 6796 11ee 54       		.byte	0x54
 6797 11ef 20090000 		.quad	.LVL151-.Ltext0
 6797      00000000 
 6798 11f7 29090000 		.quad	.LFE26-.Ltext0
 6798      00000000 
 6799 11ff 0200     		.value	0x2
 6800 1201 91       		.byte	0x91
 6801 1202 48       		.sleb128 -56
 6802 1203 00000000 		.quad	0x0
 6802      00000000 
 6803 120b 00000000 		.quad	0x0
 6803      00000000 
 6804              	.LLST75:
 6805 1213 80080000 		.quad	.LVL146-.Ltext0
 6805      00000000 
 6806 121b A6080000 		.quad	.LVL148-1-.Ltext0
 6806      00000000 
 6807 1223 0100     		.value	0x1
 6808 1225 51       		.byte	0x51
 6809 1226 20090000 		.quad	.LVL151-.Ltext0
 6809      00000000 
 6810 122e 29090000 		.quad	.LFE26-.Ltext0
 6810      00000000 
 6811 1236 0200     		.value	0x2
GAS LISTING /tmp/ccOaNtkH.s 			page 143


 6812 1238 91       		.byte	0x91
 6813 1239 50       		.sleb128 -48
 6814 123a 00000000 		.quad	0x0
 6814      00000000 
 6815 1242 00000000 		.quad	0x0
 6815      00000000 
 6816              	.LLST76:
 6817 124a 80080000 		.quad	.LVL146-.Ltext0
 6817      00000000 
 6818 1252 A6080000 		.quad	.LVL148-1-.Ltext0
 6818      00000000 
 6819 125a 0100     		.value	0x1
 6820 125c 52       		.byte	0x52
 6821 125d 20090000 		.quad	.LVL151-.Ltext0
 6821      00000000 
 6822 1265 29090000 		.quad	.LFE26-.Ltext0
 6822      00000000 
 6823 126d 0200     		.value	0x2
 6824 126f 91       		.byte	0x91
 6825 1270 68       		.sleb128 -24
 6826 1271 00000000 		.quad	0x0
 6826      00000000 
 6827 1279 00000000 		.quad	0x0
 6827      00000000 
 6828              	.LLST77:
 6829 1281 80080000 		.quad	.LVL146-.Ltext0
 6829      00000000 
 6830 1289 A6080000 		.quad	.LVL148-1-.Ltext0
 6830      00000000 
 6831 1291 0100     		.value	0x1
 6832 1293 58       		.byte	0x58
 6833 1294 20090000 		.quad	.LVL151-.Ltext0
 6833      00000000 
 6834 129c 29090000 		.quad	.LFE26-.Ltext0
 6834      00000000 
 6835 12a4 0200     		.value	0x2
 6836 12a6 91       		.byte	0x91
 6837 12a7 58       		.sleb128 -40
 6838 12a8 00000000 		.quad	0x0
 6838      00000000 
 6839 12b0 00000000 		.quad	0x0
 6839      00000000 
 6840              	.LLST78:
 6841 12b8 80080000 		.quad	.LVL146-.Ltext0
 6841      00000000 
 6842 12c0 A6080000 		.quad	.LVL148-1-.Ltext0
 6842      00000000 
 6843 12c8 0500     		.value	0x5
 6844 12ca 72       		.byte	0x72
 6845 12cb 1F       		.sleb128 31
 6846 12cc 35       		.byte	0x35
 6847 12cd 25       		.byte	0x25
 6848 12ce 9F       		.byte	0x9f
 6849 12cf 00000000 		.quad	0x0
 6849      00000000 
 6850 12d7 00000000 		.quad	0x0
 6850      00000000 
GAS LISTING /tmp/ccOaNtkH.s 			page 144


 6851              		.file 2 "heatmap.h"
 6852              		.file 3 "/usr/lib/gcc/x86_64-redhat-linux/4.4.7/include/stddef.h"
 6853              		.section	.debug_info
 6854 0000 FB0B0000 		.long	0xbfb
 6855 0004 0300     		.value	0x3
 6856 0006 00000000 		.long	.Ldebug_abbrev0
 6857 000a 08       		.byte	0x8
 6858 000b 01       		.uleb128 0x1
 6859 000c 00000000 		.long	.LASF61
 6860 0010 01       		.byte	0x1
 6861 0011 00000000 		.long	.LASF62
 6862 0015 00000000 		.long	.LASF63
 6863 0019 00000000 		.quad	.Ltext0
 6863      00000000 
 6864 0021 00000000 		.quad	.Letext0
 6864      00000000 
 6865 0029 00000000 		.long	.Ldebug_line0
 6866 002d 02       		.uleb128 0x2
 6867 002e 08       		.byte	0x8
 6868 002f 05       		.byte	0x5
 6869 0030 00000000 		.long	.LASF0
 6870 0034 03       		.uleb128 0x3
 6871 0035 00000000 		.long	.LASF4
 6872 0039 03       		.byte	0x3
 6873 003a D3       		.byte	0xd3
 6874 003b 3F000000 		.long	0x3f
 6875 003f 02       		.uleb128 0x2
 6876 0040 08       		.byte	0x8
 6877 0041 07       		.byte	0x7
 6878 0042 00000000 		.long	.LASF1
 6879 0046 04       		.uleb128 0x4
 6880 0047 04       		.byte	0x4
 6881 0048 05       		.byte	0x5
 6882 0049 696E7400 		.string	"int"
 6883 004d 05       		.uleb128 0x5
 6884 004e 18       		.byte	0x18
 6885 004f 02       		.byte	0x2
 6886 0050 27       		.byte	0x27
 6887 0051 82000000 		.long	0x82
 6888 0055 06       		.uleb128 0x6
 6889 0056 62756600 		.string	"buf"
 6890 005a 02       		.byte	0x2
 6891 005b 28       		.byte	0x28
 6892 005c 82000000 		.long	0x82
 6893 0060 00       		.sleb128 0
 6894 0061 06       		.uleb128 0x6
 6895 0062 6D617800 		.string	"max"
 6896 0066 02       		.byte	0x2
 6897 0067 29       		.byte	0x29
 6898 0068 88000000 		.long	0x88
 6899 006c 08       		.sleb128 8
 6900 006d 06       		.uleb128 0x6
 6901 006e 7700     		.string	"w"
 6902 0070 02       		.byte	0x2
 6903 0071 2A       		.byte	0x2a
 6904 0072 8F000000 		.long	0x8f
 6905 0076 0C       		.sleb128 12
GAS LISTING /tmp/ccOaNtkH.s 			page 145


 6906 0077 06       		.uleb128 0x6
 6907 0078 6800     		.string	"h"
 6908 007a 02       		.byte	0x2
 6909 007b 2A       		.byte	0x2a
 6910 007c 8F000000 		.long	0x8f
 6911 0080 10       		.sleb128 16
 6912 0081 00       		.byte	0x0
 6913 0082 07       		.uleb128 0x7
 6914 0083 08       		.byte	0x8
 6915 0084 88000000 		.long	0x88
 6916 0088 02       		.uleb128 0x2
 6917 0089 04       		.byte	0x4
 6918 008a 04       		.byte	0x4
 6919 008b 00000000 		.long	.LASF2
 6920 008f 02       		.uleb128 0x2
 6921 0090 04       		.byte	0x4
 6922 0091 07       		.byte	0x7
 6923 0092 00000000 		.long	.LASF3
 6924 0096 03       		.uleb128 0x3
 6925 0097 00000000 		.long	.LASF5
 6926 009b 02       		.byte	0x2
 6927 009c 2B       		.byte	0x2b
 6928 009d 4D000000 		.long	0x4d
 6929 00a1 05       		.uleb128 0x5
 6930 00a2 10       		.byte	0x10
 6931 00a3 02       		.byte	0x2
 6932 00a4 31       		.byte	0x31
 6933 00a5 CA000000 		.long	0xca
 6934 00a9 06       		.uleb128 0x6
 6935 00aa 62756600 		.string	"buf"
 6936 00ae 02       		.byte	0x2
 6937 00af 32       		.byte	0x32
 6938 00b0 82000000 		.long	0x82
 6939 00b4 00       		.sleb128 0
 6940 00b5 06       		.uleb128 0x6
 6941 00b6 7700     		.string	"w"
 6942 00b8 02       		.byte	0x2
 6943 00b9 33       		.byte	0x33
 6944 00ba 8F000000 		.long	0x8f
 6945 00be 08       		.sleb128 8
 6946 00bf 06       		.uleb128 0x6
 6947 00c0 6800     		.string	"h"
 6948 00c2 02       		.byte	0x2
 6949 00c3 33       		.byte	0x33
 6950 00c4 8F000000 		.long	0x8f
 6951 00c8 0C       		.sleb128 12
 6952 00c9 00       		.byte	0x0
 6953 00ca 03       		.uleb128 0x3
 6954 00cb 00000000 		.long	.LASF6
 6955 00cf 02       		.byte	0x2
 6956 00d0 34       		.byte	0x34
 6957 00d1 A1000000 		.long	0xa1
 6958 00d5 05       		.uleb128 0x5
 6959 00d6 10       		.byte	0x10
 6960 00d7 02       		.byte	0x2
 6961 00d8 3F       		.byte	0x3f
 6962 00d9 F6000000 		.long	0xf6
GAS LISTING /tmp/ccOaNtkH.s 			page 146


 6963 00dd 08       		.uleb128 0x8
 6964 00de 00000000 		.long	.LASF7
 6965 00e2 02       		.byte	0x2
 6966 00e3 40       		.byte	0x40
 6967 00e4 F6000000 		.long	0xf6
 6968 00e8 00       		.sleb128 0
 6969 00e9 08       		.uleb128 0x8
 6970 00ea 00000000 		.long	.LASF8
 6971 00ee 02       		.byte	0x2
 6972 00ef 41       		.byte	0x41
 6973 00f0 34000000 		.long	0x34
 6974 00f4 08       		.sleb128 8
 6975 00f5 00       		.byte	0x0
 6976 00f6 07       		.uleb128 0x7
 6977 00f7 08       		.byte	0x8
 6978 00f8 FC000000 		.long	0xfc
 6979 00fc 09       		.uleb128 0x9
 6980 00fd 01010000 		.long	0x101
 6981 0101 02       		.uleb128 0x2
 6982 0102 01       		.byte	0x1
 6983 0103 08       		.byte	0x8
 6984 0104 00000000 		.long	.LASF9
 6985 0108 03       		.uleb128 0x3
 6986 0109 00000000 		.long	.LASF10
 6987 010d 02       		.byte	0x2
 6988 010e 42       		.byte	0x42
 6989 010f D5000000 		.long	0xd5
 6990 0113 02       		.uleb128 0x2
 6991 0114 08       		.byte	0x8
 6992 0115 05       		.byte	0x5
 6993 0116 00000000 		.long	.LASF11
 6994 011a 02       		.uleb128 0x2
 6995 011b 02       		.byte	0x2
 6996 011c 07       		.byte	0x7
 6997 011d 00000000 		.long	.LASF12
 6998 0121 02       		.uleb128 0x2
 6999 0122 01       		.byte	0x1
 7000 0123 06       		.byte	0x6
 7001 0124 00000000 		.long	.LASF13
 7002 0128 02       		.uleb128 0x2
 7003 0129 02       		.byte	0x2
 7004 012a 05       		.byte	0x5
 7005 012b 00000000 		.long	.LASF14
 7006 012f 02       		.uleb128 0x2
 7007 0130 01       		.byte	0x1
 7008 0131 06       		.byte	0x6
 7009 0132 00000000 		.long	.LASF15
 7010 0136 02       		.uleb128 0x2
 7011 0137 08       		.byte	0x8
 7012 0138 07       		.byte	0x7
 7013 0139 00000000 		.long	.LASF16
 7014 013d 02       		.uleb128 0x2
 7015 013e 08       		.byte	0x8
 7016 013f 04       		.byte	0x4
 7017 0140 00000000 		.long	.LASF17
 7018 0144 0A       		.uleb128 0xa
 7019 0145 01       		.byte	0x1
GAS LISTING /tmp/ccOaNtkH.s 			page 147


 7020 0146 00000000 		.long	.LASF21
 7021 014a 01       		.byte	0x1
 7022 014b 84       		.byte	0x84
 7023 014c 01       		.byte	0x1
 7024 014d 00000000 		.quad	.LFB28
 7024      00000000 
 7025 0155 00000000 		.quad	.LFE28
 7025      00000000 
 7026 015d 01       		.byte	0x1
 7027 015e 9C       		.byte	0x9c
 7028 015f 16020000 		.long	0x216
 7029 0163 0B       		.uleb128 0xb
 7030 0164 6800     		.string	"h"
 7031 0166 01       		.byte	0x1
 7032 0167 84       		.byte	0x84
 7033 0168 16020000 		.long	0x216
 7034 016c 01       		.byte	0x1
 7035 016d 55       		.byte	0x55
 7036 016e 0C       		.uleb128 0xc
 7037 016f 7800     		.string	"x"
 7038 0171 01       		.byte	0x1
 7039 0172 84       		.byte	0x84
 7040 0173 8F000000 		.long	0x8f
 7041 0177 00000000 		.long	.LLST0
 7042 017b 0C       		.uleb128 0xc
 7043 017c 7900     		.string	"y"
 7044 017e 01       		.byte	0x1
 7045 017f 84       		.byte	0x84
 7046 0180 8F000000 		.long	0x8f
 7047 0184 00000000 		.long	.LLST1
 7048 0188 0D       		.uleb128 0xd
 7049 0189 00000000 		.long	.LASF18
 7050 018d 01       		.byte	0x1
 7051 018e 84       		.byte	0x84
 7052 018f 1C020000 		.long	0x21c
 7053 0193 00000000 		.long	.LLST2
 7054 0197 0E       		.uleb128 0xe
 7055 0198 00000000 		.long	.Ldebug_ranges0+0x0
 7056 019c 0F       		.uleb128 0xf
 7057 019d 783000   		.string	"x0"
 7058 01a0 01       		.byte	0x1
 7059 01a1 8F       		.byte	0x8f
 7060 01a2 27020000 		.long	0x227
 7061 01a6 00000000 		.long	.LLST3
 7062 01aa 0F       		.uleb128 0xf
 7063 01ab 793000   		.string	"y0"
 7064 01ae 01       		.byte	0x1
 7065 01af 90       		.byte	0x90
 7066 01b0 27020000 		.long	0x227
 7067 01b4 00000000 		.long	.LLST4
 7068 01b8 0F       		.uleb128 0xf
 7069 01b9 783100   		.string	"x1"
 7070 01bc 01       		.byte	0x1
 7071 01bd 91       		.byte	0x91
 7072 01be 27020000 		.long	0x227
 7073 01c2 00000000 		.long	.LLST5
 7074 01c6 0F       		.uleb128 0xf
GAS LISTING /tmp/ccOaNtkH.s 			page 148


 7075 01c7 793100   		.string	"y1"
 7076 01ca 01       		.byte	0x1
 7077 01cb 92       		.byte	0x92
 7078 01cc 27020000 		.long	0x227
 7079 01d0 00000000 		.long	.LLST6
 7080 01d4 0F       		.uleb128 0xf
 7081 01d5 697900   		.string	"iy"
 7082 01d8 01       		.byte	0x1
 7083 01d9 94       		.byte	0x94
 7084 01da 8F000000 		.long	0x8f
 7085 01de 00000000 		.long	.LLST7
 7086 01e2 0E       		.uleb128 0xe
 7087 01e3 00000000 		.long	.Ldebug_ranges0+0x30
 7088 01e7 10       		.uleb128 0x10
 7089 01e8 00000000 		.long	.LASF19
 7090 01ec 01       		.byte	0x1
 7091 01ed 98       		.byte	0x98
 7092 01ee 82000000 		.long	0x82
 7093 01f2 00000000 		.long	.LLST8
 7094 01f6 10       		.uleb128 0x10
 7095 01f7 00000000 		.long	.LASF20
 7096 01fb 01       		.byte	0x1
 7097 01fc 99       		.byte	0x99
 7098 01fd 2C020000 		.long	0x22c
 7099 0201 00000000 		.long	.LLST9
 7100 0205 0F       		.uleb128 0xf
 7101 0206 697800   		.string	"ix"
 7102 0209 01       		.byte	0x1
 7103 020a 9B       		.byte	0x9b
 7104 020b 8F000000 		.long	0x8f
 7105 020f 00000000 		.long	.LLST10
 7106 0213 00       		.byte	0x0
 7107 0214 00       		.byte	0x0
 7108 0215 00       		.byte	0x0
 7109 0216 07       		.uleb128 0x7
 7110 0217 08       		.byte	0x8
 7111 0218 96000000 		.long	0x96
 7112 021c 07       		.uleb128 0x7
 7113 021d 08       		.byte	0x8
 7114 021e 22020000 		.long	0x222
 7115 0222 09       		.uleb128 0x9
 7116 0223 CA000000 		.long	0xca
 7117 0227 09       		.uleb128 0x9
 7118 0228 8F000000 		.long	0x8f
 7119 022c 07       		.uleb128 0x7
 7120 022d 08       		.byte	0x8
 7121 022e 32020000 		.long	0x232
 7122 0232 09       		.uleb128 0x9
 7123 0233 88000000 		.long	0x88
 7124 0237 0A       		.uleb128 0xa
 7125 0238 01       		.byte	0x1
 7126 0239 00000000 		.long	.LASF22
 7127 023d 01       		.byte	0x1
 7128 023e 7F       		.byte	0x7f
 7129 023f 01       		.byte	0x1
 7130 0240 00000000 		.quad	.LFB27
 7130      00000000 
GAS LISTING /tmp/ccOaNtkH.s 			page 149


 7131 0248 00000000 		.quad	.LFE27
 7131      00000000 
 7132 0250 01       		.byte	0x1
 7133 0251 9C       		.byte	0x9c
 7134 0252 78020000 		.long	0x278
 7135 0256 0B       		.uleb128 0xb
 7136 0257 6800     		.string	"h"
 7137 0259 01       		.byte	0x1
 7138 025a 7F       		.byte	0x7f
 7139 025b 16020000 		.long	0x216
 7140 025f 01       		.byte	0x1
 7141 0260 55       		.byte	0x55
 7142 0261 0B       		.uleb128 0xb
 7143 0262 7800     		.string	"x"
 7144 0264 01       		.byte	0x1
 7145 0265 7F       		.byte	0x7f
 7146 0266 8F000000 		.long	0x8f
 7147 026a 01       		.byte	0x1
 7148 026b 54       		.byte	0x54
 7149 026c 0B       		.uleb128 0xb
 7150 026d 7900     		.string	"y"
 7151 026f 01       		.byte	0x1
 7152 0270 7F       		.byte	0x7f
 7153 0271 8F000000 		.long	0x8f
 7154 0275 01       		.byte	0x1
 7155 0276 51       		.byte	0x51
 7156 0277 00       		.byte	0x0
 7157 0278 0A       		.uleb128 0xa
 7158 0279 01       		.byte	0x1
 7159 027a 00000000 		.long	.LASF23
 7160 027e 01       		.byte	0x1
 7161 027f B6       		.byte	0xb6
 7162 0280 01       		.byte	0x1
 7163 0281 00000000 		.quad	.LFB30
 7163      00000000 
 7164 0289 00000000 		.quad	.LFE30
 7164      00000000 
 7165 0291 01       		.byte	0x1
 7166 0292 9C       		.byte	0x9c
 7167 0293 55030000 		.long	0x355
 7168 0297 0B       		.uleb128 0xb
 7169 0298 6800     		.string	"h"
 7170 029a 01       		.byte	0x1
 7171 029b B6       		.byte	0xb6
 7172 029c 16020000 		.long	0x216
 7173 02a0 01       		.byte	0x1
 7174 02a1 55       		.byte	0x55
 7175 02a2 0C       		.uleb128 0xc
 7176 02a3 7800     		.string	"x"
 7177 02a5 01       		.byte	0x1
 7178 02a6 B6       		.byte	0xb6
 7179 02a7 8F000000 		.long	0x8f
 7180 02ab 00000000 		.long	.LLST11
 7181 02af 0C       		.uleb128 0xc
 7182 02b0 7900     		.string	"y"
 7183 02b2 01       		.byte	0x1
 7184 02b3 B6       		.byte	0xb6
GAS LISTING /tmp/ccOaNtkH.s 			page 150


 7185 02b4 8F000000 		.long	0x8f
 7186 02b8 00000000 		.long	.LLST12
 7187 02bc 0B       		.uleb128 0xb
 7188 02bd 7700     		.string	"w"
 7189 02bf 01       		.byte	0x1
 7190 02c0 B6       		.byte	0xb6
 7191 02c1 88000000 		.long	0x88
 7192 02c5 01       		.byte	0x1
 7193 02c6 61       		.byte	0x61
 7194 02c7 0D       		.uleb128 0xd
 7195 02c8 00000000 		.long	.LASF18
 7196 02cc 01       		.byte	0x1
 7197 02cd B6       		.byte	0xb6
 7198 02ce 1C020000 		.long	0x21c
 7199 02d2 00000000 		.long	.LLST13
 7200 02d6 0E       		.uleb128 0xe
 7201 02d7 00000000 		.long	.Ldebug_ranges0+0x60
 7202 02db 0F       		.uleb128 0xf
 7203 02dc 783000   		.string	"x0"
 7204 02df 01       		.byte	0x1
 7205 02e0 C4       		.byte	0xc4
 7206 02e1 27020000 		.long	0x227
 7207 02e5 00000000 		.long	.LLST14
 7208 02e9 0F       		.uleb128 0xf
 7209 02ea 793000   		.string	"y0"
 7210 02ed 01       		.byte	0x1
 7211 02ee C5       		.byte	0xc5
 7212 02ef 27020000 		.long	0x227
 7213 02f3 00000000 		.long	.LLST15
 7214 02f7 0F       		.uleb128 0xf
 7215 02f8 783100   		.string	"x1"
 7216 02fb 01       		.byte	0x1
 7217 02fc C6       		.byte	0xc6
 7218 02fd 27020000 		.long	0x227
 7219 0301 00000000 		.long	.LLST16
 7220 0305 0F       		.uleb128 0xf
 7221 0306 793100   		.string	"y1"
 7222 0309 01       		.byte	0x1
 7223 030a C7       		.byte	0xc7
 7224 030b 27020000 		.long	0x227
 7225 030f 00000000 		.long	.LLST17
 7226 0313 0F       		.uleb128 0xf
 7227 0314 697900   		.string	"iy"
 7228 0317 01       		.byte	0x1
 7229 0318 C9       		.byte	0xc9
 7230 0319 8F000000 		.long	0x8f
 7231 031d 00000000 		.long	.LLST18
 7232 0321 0E       		.uleb128 0xe
 7233 0322 00000000 		.long	.Ldebug_ranges0+0x90
 7234 0326 10       		.uleb128 0x10
 7235 0327 00000000 		.long	.LASF19
 7236 032b 01       		.byte	0x1
 7237 032c CD       		.byte	0xcd
 7238 032d 82000000 		.long	0x82
 7239 0331 00000000 		.long	.LLST19
 7240 0335 10       		.uleb128 0x10
 7241 0336 00000000 		.long	.LASF20
GAS LISTING /tmp/ccOaNtkH.s 			page 151


 7242 033a 01       		.byte	0x1
 7243 033b CE       		.byte	0xce
 7244 033c 2C020000 		.long	0x22c
 7245 0340 00000000 		.long	.LLST20
 7246 0344 0F       		.uleb128 0xf
 7247 0345 697800   		.string	"ix"
 7248 0348 01       		.byte	0x1
 7249 0349 D0       		.byte	0xd0
 7250 034a 8F000000 		.long	0x8f
 7251 034e 00000000 		.long	.LLST21
 7252 0352 00       		.byte	0x0
 7253 0353 00       		.byte	0x0
 7254 0354 00       		.byte	0x0
 7255 0355 0A       		.uleb128 0xa
 7256 0356 01       		.byte	0x1
 7257 0357 00000000 		.long	.LASF24
 7258 035b 01       		.byte	0x1
 7259 035c AB       		.byte	0xab
 7260 035d 01       		.byte	0x1
 7261 035e 00000000 		.quad	.LFB29
 7261      00000000 
 7262 0366 00000000 		.quad	.LFE29
 7262      00000000 
 7263 036e 01       		.byte	0x1
 7264 036f 9C       		.byte	0x9c
 7265 0370 A1030000 		.long	0x3a1
 7266 0374 0B       		.uleb128 0xb
 7267 0375 6800     		.string	"h"
 7268 0377 01       		.byte	0x1
 7269 0378 AB       		.byte	0xab
 7270 0379 16020000 		.long	0x216
 7271 037d 01       		.byte	0x1
 7272 037e 55       		.byte	0x55
 7273 037f 0B       		.uleb128 0xb
 7274 0380 7800     		.string	"x"
 7275 0382 01       		.byte	0x1
 7276 0383 AB       		.byte	0xab
 7277 0384 8F000000 		.long	0x8f
 7278 0388 01       		.byte	0x1
 7279 0389 54       		.byte	0x54
 7280 038a 0B       		.uleb128 0xb
 7281 038b 7900     		.string	"y"
 7282 038d 01       		.byte	0x1
 7283 038e AB       		.byte	0xab
 7284 038f 8F000000 		.long	0x8f
 7285 0393 01       		.byte	0x1
 7286 0394 51       		.byte	0x51
 7287 0395 0B       		.uleb128 0xb
 7288 0396 7700     		.string	"w"
 7289 0398 01       		.byte	0x1
 7290 0399 AB       		.byte	0xab
 7291 039a 88000000 		.long	0x88
 7292 039e 01       		.byte	0x1
 7293 039f 61       		.byte	0x61
 7294 03a0 00       		.byte	0x0
 7295 03a1 11       		.uleb128 0x11
 7296 03a2 00000000 		.long	.LASF64
GAS LISTING /tmp/ccOaNtkH.s 			page 152


 7297 03a6 01       		.byte	0x1
 7298 03a7 3601     		.value	0x136
 7299 03a9 01       		.byte	0x1
 7300 03aa 88000000 		.long	0x88
 7301 03ae 00000000 		.quad	.LFB37
 7301      00000000 
 7302 03b6 00000000 		.quad	.LFE37
 7302      00000000 
 7303 03be 01       		.byte	0x1
 7304 03bf 9C       		.byte	0x9c
 7305 03c0 D3030000 		.long	0x3d3
 7306 03c4 12       		.uleb128 0x12
 7307 03c5 00000000 		.long	.LASF25
 7308 03c9 01       		.byte	0x1
 7309 03ca 3601     		.value	0x136
 7310 03cc 88000000 		.long	0x88
 7311 03d0 01       		.byte	0x1
 7312 03d1 61       		.byte	0x61
 7313 03d2 00       		.byte	0x0
 7314 03d3 13       		.uleb128 0x13
 7315 03d4 01       		.byte	0x1
 7316 03d5 00000000 		.long	.LASF26
 7317 03d9 01       		.byte	0x1
 7318 03da 7201     		.value	0x172
 7319 03dc 01       		.byte	0x1
 7320 03dd 00000000 		.quad	.LFB42
 7320      00000000 
 7321 03e5 00000000 		.quad	.LFE42
 7321      00000000 
 7322 03ed 01       		.byte	0x1
 7323 03ee 9C       		.byte	0x9c
 7324 03ef 03040000 		.long	0x403
 7325 03f3 14       		.uleb128 0x14
 7326 03f4 637300   		.string	"cs"
 7327 03f7 01       		.byte	0x1
 7328 03f8 7201     		.value	0x172
 7329 03fa 03040000 		.long	0x403
 7330 03fe 00000000 		.long	.LLST22
 7331 0402 00       		.byte	0x0
 7332 0403 07       		.uleb128 0x7
 7333 0404 08       		.byte	0x8
 7334 0405 08010000 		.long	0x108
 7335 0409 13       		.uleb128 0x13
 7336 040a 01       		.byte	0x1
 7337 040b 00000000 		.long	.LASF27
 7338 040f 01       		.byte	0x1
 7339 0410 5A01     		.value	0x15a
 7340 0412 01       		.byte	0x1
 7341 0413 00000000 		.quad	.LFB40
 7341      00000000 
 7342 041b 00000000 		.quad	.LFE40
 7342      00000000 
 7343 0423 01       		.byte	0x1
 7344 0424 9C       		.byte	0x9c
 7345 0425 38040000 		.long	0x438
 7346 0429 14       		.uleb128 0x14
 7347 042a 7300     		.string	"s"
GAS LISTING /tmp/ccOaNtkH.s 			page 153


 7348 042c 01       		.byte	0x1
 7349 042d 5A01     		.value	0x15a
 7350 042f 38040000 		.long	0x438
 7351 0433 00000000 		.long	.LLST23
 7352 0437 00       		.byte	0x0
 7353 0438 07       		.uleb128 0x7
 7354 0439 08       		.byte	0x8
 7355 043a CA000000 		.long	0xca
 7356 043e 0A       		.uleb128 0xa
 7357 043f 01       		.byte	0x1
 7358 0440 00000000 		.long	.LASF28
 7359 0444 01       		.byte	0x1
 7360 0445 45       		.byte	0x45
 7361 0446 01       		.byte	0x1
 7362 0447 00000000 		.quad	.LFB24
 7362      00000000 
 7363 044f 00000000 		.quad	.LFE24
 7363      00000000 
 7364 0457 01       		.byte	0x1
 7365 0458 9C       		.byte	0x9c
 7366 0459 6B040000 		.long	0x46b
 7367 045d 0C       		.uleb128 0xc
 7368 045e 6800     		.string	"h"
 7369 0460 01       		.byte	0x1
 7370 0461 45       		.byte	0x45
 7371 0462 16020000 		.long	0x216
 7372 0466 00000000 		.long	.LLST24
 7373 046a 00       		.byte	0x0
 7374 046b 15       		.uleb128 0x15
 7375 046c 01       		.byte	0x1
 7376 046d 00000000 		.long	.LASF30
 7377 0471 01       		.byte	0x1
 7378 0472 6001     		.value	0x160
 7379 0474 01       		.byte	0x1
 7380 0475 03040000 		.long	0x403
 7381 0479 00000000 		.quad	.LFB41
 7381      00000000 
 7382 0481 00000000 		.quad	.LFE41
 7382      00000000 
 7383 0489 01       		.byte	0x1
 7384 048a 9C       		.byte	0x9c
 7385 048b CF040000 		.long	0x4cf
 7386 048f 16       		.uleb128 0x16
 7387 0490 00000000 		.long	.LASF29
 7388 0494 01       		.byte	0x1
 7389 0495 6001     		.value	0x160
 7390 0497 F6000000 		.long	0xf6
 7391 049b 00000000 		.long	.LLST25
 7392 049f 16       		.uleb128 0x16
 7393 04a0 00000000 		.long	.LASF8
 7394 04a4 01       		.byte	0x1
 7395 04a5 6001     		.value	0x160
 7396 04a7 34000000 		.long	0x34
 7397 04ab 00000000 		.long	.LLST26
 7398 04af 17       		.uleb128 0x17
 7399 04b0 637300   		.string	"cs"
 7400 04b3 01       		.byte	0x1
GAS LISTING /tmp/ccOaNtkH.s 			page 154


 7401 04b4 6201     		.value	0x162
 7402 04b6 03040000 		.long	0x403
 7403 04ba 00000000 		.long	.LLST27
 7404 04be 18       		.uleb128 0x18
 7405 04bf 00000000 		.long	.LASF7
 7406 04c3 01       		.byte	0x1
 7407 04c4 6301     		.value	0x163
 7408 04c6 CF040000 		.long	0x4cf
 7409 04ca 00000000 		.long	.LLST28
 7410 04ce 00       		.byte	0x0
 7411 04cf 07       		.uleb128 0x7
 7412 04d0 08       		.byte	0x8
 7413 04d1 01010000 		.long	0x101
 7414 04d5 19       		.uleb128 0x19
 7415 04d6 01       		.byte	0x1
 7416 04d7 00000000 		.long	.LASF31
 7417 04db 01       		.byte	0x1
 7418 04dc EF       		.byte	0xef
 7419 04dd 01       		.byte	0x1
 7420 04de CF040000 		.long	0x4cf
 7421 04e2 00000000 		.quad	.LFB33
 7421      00000000 
 7422 04ea 00000000 		.quad	.LFE33
 7422      00000000 
 7423 04f2 01       		.byte	0x1
 7424 04f3 9C       		.byte	0x9c
 7425 04f4 9D050000 		.long	0x59d
 7426 04f8 0C       		.uleb128 0xc
 7427 04f9 6800     		.string	"h"
 7428 04fb 01       		.byte	0x1
 7429 04fc EF       		.byte	0xef
 7430 04fd 9D050000 		.long	0x59d
 7431 0501 00000000 		.long	.LLST29
 7432 0505 0D       		.uleb128 0xd
 7433 0506 00000000 		.long	.LASF32
 7434 050a 01       		.byte	0x1
 7435 050b EF       		.byte	0xef
 7436 050c A8050000 		.long	0x5a8
 7437 0510 00000000 		.long	.LLST30
 7438 0514 0D       		.uleb128 0xd
 7439 0515 00000000 		.long	.LASF33
 7440 0519 01       		.byte	0x1
 7441 051a EF       		.byte	0xef
 7442 051b 88000000 		.long	0x88
 7443 051f 00000000 		.long	.LLST31
 7444 0523 0D       		.uleb128 0xd
 7445 0524 00000000 		.long	.LASF34
 7446 0528 01       		.byte	0x1
 7447 0529 EF       		.byte	0xef
 7448 052a CF040000 		.long	0x4cf
 7449 052e 00000000 		.long	.LLST32
 7450 0532 0F       		.uleb128 0xf
 7451 0533 7900     		.string	"y"
 7452 0535 01       		.byte	0x1
 7453 0536 F1       		.byte	0xf1
 7454 0537 8F000000 		.long	0x8f
 7455 053b 00000000 		.long	.LLST33
GAS LISTING /tmp/ccOaNtkH.s 			page 155


 7456 053f 1A       		.uleb128 0x1a
 7457 0540 00000000 		.quad	.LBB10
 7457      00000000 
 7458 0548 00000000 		.quad	.LBE10
 7458      00000000 
 7459 0550 10       		.uleb128 0x10
 7460 0551 00000000 		.long	.LASF35
 7461 0555 01       		.byte	0x1
 7462 0556 FF       		.byte	0xff
 7463 0557 82000000 		.long	0x82
 7464 055b 00000000 		.long	.LLST34
 7465 055f 18       		.uleb128 0x18
 7466 0560 00000000 		.long	.LASF36
 7467 0564 01       		.byte	0x1
 7468 0565 0001     		.value	0x100
 7469 0567 CF040000 		.long	0x4cf
 7470 056b 00000000 		.long	.LLST35
 7471 056f 17       		.uleb128 0x17
 7472 0570 7800     		.string	"x"
 7473 0572 01       		.byte	0x1
 7474 0573 0201     		.value	0x102
 7475 0575 8F000000 		.long	0x8f
 7476 0579 00000000 		.long	.LLST36
 7477 057d 0E       		.uleb128 0xe
 7478 057e 00000000 		.long	.Ldebug_ranges0+0xc0
 7479 0582 1B       		.uleb128 0x1b
 7480 0583 76616C00 		.string	"val"
 7481 0587 01       		.byte	0x1
 7482 0588 0701     		.value	0x107
 7483 058a 32020000 		.long	0x232
 7484 058e 1B       		.uleb128 0x1b
 7485 058f 69647800 		.string	"idx"
 7486 0593 01       		.byte	0x1
 7487 0594 0D01     		.value	0x10d
 7488 0596 B3050000 		.long	0x5b3
 7489 059a 00       		.byte	0x0
 7490 059b 00       		.byte	0x0
 7491 059c 00       		.byte	0x0
 7492 059d 07       		.uleb128 0x7
 7493 059e 08       		.byte	0x8
 7494 059f A3050000 		.long	0x5a3
 7495 05a3 09       		.uleb128 0x9
 7496 05a4 96000000 		.long	0x96
 7497 05a8 07       		.uleb128 0x7
 7498 05a9 08       		.byte	0x8
 7499 05aa AE050000 		.long	0x5ae
 7500 05ae 09       		.uleb128 0x9
 7501 05af 08010000 		.long	0x108
 7502 05b3 09       		.uleb128 0x9
 7503 05b4 34000000 		.long	0x34
 7504 05b8 19       		.uleb128 0x19
 7505 05b9 01       		.byte	0x1
 7506 05ba 00000000 		.long	.LASF37
 7507 05be 01       		.byte	0x1
 7508 05bf E3       		.byte	0xe3
 7509 05c0 01       		.byte	0x1
 7510 05c1 CF040000 		.long	0x4cf
GAS LISTING /tmp/ccOaNtkH.s 			page 156


 7511 05c5 00000000 		.quad	.LFB32
 7511      00000000 
 7512 05cd 00000000 		.quad	.LFE32
 7512      00000000 
 7513 05d5 01       		.byte	0x1
 7514 05d6 9C       		.byte	0x9c
 7515 05d7 01060000 		.long	0x601
 7516 05db 0B       		.uleb128 0xb
 7517 05dc 6800     		.string	"h"
 7518 05de 01       		.byte	0x1
 7519 05df E3       		.byte	0xe3
 7520 05e0 9D050000 		.long	0x59d
 7521 05e4 01       		.byte	0x1
 7522 05e5 55       		.byte	0x55
 7523 05e6 1C       		.uleb128 0x1c
 7524 05e7 00000000 		.long	.LASF32
 7525 05eb 01       		.byte	0x1
 7526 05ec E3       		.byte	0xe3
 7527 05ed A8050000 		.long	0x5a8
 7528 05f1 01       		.byte	0x1
 7529 05f2 54       		.byte	0x54
 7530 05f3 1C       		.uleb128 0x1c
 7531 05f4 00000000 		.long	.LASF34
 7532 05f8 01       		.byte	0x1
 7533 05f9 E3       		.byte	0xe3
 7534 05fa CF040000 		.long	0x4cf
 7535 05fe 01       		.byte	0x1
 7536 05ff 51       		.byte	0x51
 7537 0600 00       		.byte	0x0
 7538 0601 19       		.uleb128 0x19
 7539 0602 01       		.byte	0x1
 7540 0603 00000000 		.long	.LASF38
 7541 0607 01       		.byte	0x1
 7542 0608 DE       		.byte	0xde
 7543 0609 01       		.byte	0x1
 7544 060a CF040000 		.long	0x4cf
 7545 060e 00000000 		.quad	.LFB31
 7545      00000000 
 7546 0616 00000000 		.quad	.LFE31
 7546      00000000 
 7547 061e 01       		.byte	0x1
 7548 061f 9C       		.byte	0x9c
 7549 0620 3F060000 		.long	0x63f
 7550 0624 0B       		.uleb128 0xb
 7551 0625 6800     		.string	"h"
 7552 0627 01       		.byte	0x1
 7553 0628 DE       		.byte	0xde
 7554 0629 9D050000 		.long	0x59d
 7555 062d 01       		.byte	0x1
 7556 062e 55       		.byte	0x55
 7557 062f 0D       		.uleb128 0xd
 7558 0630 00000000 		.long	.LASF34
 7559 0634 01       		.byte	0x1
 7560 0635 DE       		.byte	0xde
 7561 0636 CF040000 		.long	0x4cf
 7562 063a 00000000 		.long	.LLST37
 7563 063e 00       		.byte	0x0
GAS LISTING /tmp/ccOaNtkH.s 			page 157


 7564 063f 13       		.uleb128 0x13
 7565 0640 01       		.byte	0x1
 7566 0641 00000000 		.long	.LASF39
 7567 0645 01       		.byte	0x1
 7568 0646 1E01     		.value	0x11e
 7569 0648 01       		.byte	0x1
 7570 0649 00000000 		.quad	.LFB34
 7570      00000000 
 7571 0651 00000000 		.quad	.LFE34
 7571      00000000 
 7572 0659 01       		.byte	0x1
 7573 065a 9C       		.byte	0x9c
 7574 065b 94060000 		.long	0x694
 7575 065f 12       		.uleb128 0x12
 7576 0660 00000000 		.long	.LASF18
 7577 0664 01       		.byte	0x1
 7578 0665 1E01     		.value	0x11e
 7579 0667 38040000 		.long	0x438
 7580 066b 01       		.byte	0x1
 7581 066c 55       		.byte	0x55
 7582 066d 1D       		.uleb128 0x1d
 7583 066e 7700     		.string	"w"
 7584 0670 01       		.byte	0x1
 7585 0671 1E01     		.value	0x11e
 7586 0673 8F000000 		.long	0x8f
 7587 0677 01       		.byte	0x1
 7588 0678 54       		.byte	0x54
 7589 0679 1D       		.uleb128 0x1d
 7590 067a 6800     		.string	"h"
 7591 067c 01       		.byte	0x1
 7592 067d 1E01     		.value	0x11e
 7593 067f 8F000000 		.long	0x8f
 7594 0683 01       		.byte	0x1
 7595 0684 51       		.byte	0x51
 7596 0685 12       		.uleb128 0x12
 7597 0686 00000000 		.long	.LASF40
 7598 068a 01       		.byte	0x1
 7599 068b 1E01     		.value	0x11e
 7600 068d 82000000 		.long	0x82
 7601 0691 01       		.byte	0x1
 7602 0692 52       		.byte	0x52
 7603 0693 00       		.byte	0x0
 7604 0694 15       		.uleb128 0x15
 7605 0695 01       		.byte	0x1
 7606 0696 00000000 		.long	.LASF41
 7607 069a 01       		.byte	0x1
 7608 069b 2801     		.value	0x128
 7609 069d 01       		.byte	0x1
 7610 069e 38040000 		.long	0x438
 7611 06a2 00000000 		.quad	.LFB35
 7611      00000000 
 7612 06aa 00000000 		.quad	.LFE35
 7612      00000000 
 7613 06b2 01       		.byte	0x1
 7614 06b3 9C       		.byte	0x9c
 7615 06b4 F5060000 		.long	0x6f5
 7616 06b8 14       		.uleb128 0x14
GAS LISTING /tmp/ccOaNtkH.s 			page 158


 7617 06b9 7700     		.string	"w"
 7618 06bb 01       		.byte	0x1
 7619 06bc 2801     		.value	0x128
 7620 06be 8F000000 		.long	0x8f
 7621 06c2 00000000 		.long	.LLST38
 7622 06c6 14       		.uleb128 0x14
 7623 06c7 6800     		.string	"h"
 7624 06c9 01       		.byte	0x1
 7625 06ca 2801     		.value	0x128
 7626 06cc 8F000000 		.long	0x8f
 7627 06d0 00000000 		.long	.LLST39
 7628 06d4 16       		.uleb128 0x16
 7629 06d5 00000000 		.long	.LASF40
 7630 06d9 01       		.byte	0x1
 7631 06da 2801     		.value	0x128
 7632 06dc 82000000 		.long	0x82
 7633 06e0 00000000 		.long	.LLST40
 7634 06e4 18       		.uleb128 0x18
 7635 06e5 00000000 		.long	.LASF18
 7636 06e9 01       		.byte	0x1
 7637 06ea 2A01     		.value	0x12a
 7638 06ec 38040000 		.long	0x438
 7639 06f0 00000000 		.long	.LLST41
 7640 06f4 00       		.byte	0x0
 7641 06f5 15       		.uleb128 0x15
 7642 06f6 01       		.byte	0x1
 7643 06f7 00000000 		.long	.LASF42
 7644 06fb 01       		.byte	0x1
 7645 06fc 4001     		.value	0x140
 7646 06fe 01       		.byte	0x1
 7647 06ff 38040000 		.long	0x438
 7648 0703 00000000 		.quad	.LFB39
 7648      00000000 
 7649 070b 00000000 		.quad	.LFE39
 7649      00000000 
 7650 0713 01       		.byte	0x1
 7651 0714 9C       		.byte	0x9c
 7652 0715 C5070000 		.long	0x7c5
 7653 0719 14       		.uleb128 0x14
 7654 071a 7200     		.string	"r"
 7655 071c 01       		.byte	0x1
 7656 071d 4001     		.value	0x140
 7657 071f 8F000000 		.long	0x8f
 7658 0723 00000000 		.long	.LLST42
 7659 0727 16       		.uleb128 0x16
 7660 0728 00000000 		.long	.LASF43
 7661 072c 01       		.byte	0x1
 7662 072d 4001     		.value	0x140
 7663 072f D5070000 		.long	0x7d5
 7664 0733 00000000 		.long	.LLST43
 7665 0737 17       		.uleb128 0x17
 7666 0738 7900     		.string	"y"
 7667 073a 01       		.byte	0x1
 7668 073b 4201     		.value	0x142
 7669 073d 8F000000 		.long	0x8f
 7670 0741 00000000 		.long	.LLST44
 7671 0745 17       		.uleb128 0x17
GAS LISTING /tmp/ccOaNtkH.s 			page 159


 7672 0746 6400     		.string	"d"
 7673 0748 01       		.byte	0x1
 7674 0749 4301     		.value	0x143
 7675 074b 8F000000 		.long	0x8f
 7676 074f 00000000 		.long	.LLST45
 7677 0753 18       		.uleb128 0x18
 7678 0754 00000000 		.long	.LASF18
 7679 0758 01       		.byte	0x1
 7680 0759 4501     		.value	0x145
 7681 075b 82000000 		.long	0x82
 7682 075f 00000000 		.long	.LLST46
 7683 0763 1A       		.uleb128 0x1a
 7684 0764 00000000 		.quad	.LBB16
 7684      00000000 
 7685 076c 00000000 		.quad	.LBE16
 7685      00000000 
 7686 0774 18       		.uleb128 0x18
 7687 0775 00000000 		.long	.LASF19
 7688 0779 01       		.byte	0x1
 7689 077a 4A01     		.value	0x14a
 7690 077c 82000000 		.long	0x82
 7691 0780 00000000 		.long	.LLST47
 7692 0784 17       		.uleb128 0x17
 7693 0785 7800     		.string	"x"
 7694 0787 01       		.byte	0x1
 7695 0788 4B01     		.value	0x14b
 7696 078a 8F000000 		.long	0x8f
 7697 078e 00000000 		.long	.LLST48
 7698 0792 0E       		.uleb128 0xe
 7699 0793 00000000 		.long	.Ldebug_ranges0+0x120
 7700 0797 1E       		.uleb128 0x1e
 7701 0798 00000000 		.long	.LASF25
 7702 079c 01       		.byte	0x1
 7703 079d 4D01     		.value	0x14d
 7704 079f 32020000 		.long	0x232
 7705 07a3 17       		.uleb128 0x17
 7706 07a4 647300   		.string	"ds"
 7707 07a7 01       		.byte	0x1
 7708 07a8 4E01     		.value	0x14e
 7709 07aa 32020000 		.long	0x232
 7710 07ae 00000000 		.long	.LLST49
 7711 07b2 18       		.uleb128 0x18
 7712 07b3 00000000 		.long	.LASF44
 7713 07b7 01       		.byte	0x1
 7714 07b8 5001     		.value	0x150
 7715 07ba 32020000 		.long	0x232
 7716 07be 00000000 		.long	.LLST50
 7717 07c2 00       		.byte	0x0
 7718 07c3 00       		.byte	0x0
 7719 07c4 00       		.byte	0x0
 7720 07c5 1F       		.uleb128 0x1f
 7721 07c6 01       		.byte	0x1
 7722 07c7 88000000 		.long	0x88
 7723 07cb D5070000 		.long	0x7d5
 7724 07cf 20       		.uleb128 0x20
 7725 07d0 88000000 		.long	0x88
 7726 07d4 00       		.byte	0x0
GAS LISTING /tmp/ccOaNtkH.s 			page 160


 7727 07d5 07       		.uleb128 0x7
 7728 07d6 08       		.byte	0x8
 7729 07d7 C5070000 		.long	0x7c5
 7730 07db 15       		.uleb128 0x15
 7731 07dc 01       		.byte	0x1
 7732 07dd 00000000 		.long	.LASF45
 7733 07e1 01       		.byte	0x1
 7734 07e2 3B01     		.value	0x13b
 7735 07e4 01       		.byte	0x1
 7736 07e5 38040000 		.long	0x438
 7737 07e9 00000000 		.quad	.LFB38
 7737      00000000 
 7738 07f1 00000000 		.quad	.LFE38
 7738      00000000 
 7739 07f9 01       		.byte	0x1
 7740 07fa 9C       		.byte	0x9c
 7741 07fb 0C080000 		.long	0x80c
 7742 07ff 1D       		.uleb128 0x1d
 7743 0800 7200     		.string	"r"
 7744 0802 01       		.byte	0x1
 7745 0803 3B01     		.value	0x13b
 7746 0805 8F000000 		.long	0x8f
 7747 0809 01       		.byte	0x1
 7748 080a 55       		.byte	0x55
 7749 080b 00       		.byte	0x0
 7750 080c 15       		.uleb128 0x15
 7751 080d 01       		.byte	0x1
 7752 080e 00000000 		.long	.LASF46
 7753 0812 01       		.byte	0x1
 7754 0813 2F01     		.value	0x12f
 7755 0815 01       		.byte	0x1
 7756 0816 38040000 		.long	0x438
 7757 081a 00000000 		.quad	.LFB36
 7757      00000000 
 7758 0822 00000000 		.quad	.LFE36
 7758      00000000 
 7759 082a 01       		.byte	0x1
 7760 082b 9C       		.byte	0x9c
 7761 082c 6D080000 		.long	0x86d
 7762 0830 14       		.uleb128 0x14
 7763 0831 7700     		.string	"w"
 7764 0833 01       		.byte	0x1
 7765 0834 2F01     		.value	0x12f
 7766 0836 8F000000 		.long	0x8f
 7767 083a 00000000 		.long	.LLST51
 7768 083e 14       		.uleb128 0x14
 7769 083f 6800     		.string	"h"
 7770 0841 01       		.byte	0x1
 7771 0842 2F01     		.value	0x12f
 7772 0844 8F000000 		.long	0x8f
 7773 0848 00000000 		.long	.LLST52
 7774 084c 16       		.uleb128 0x16
 7775 084d 00000000 		.long	.LASF40
 7776 0851 01       		.byte	0x1
 7777 0852 2F01     		.value	0x12f
 7778 0854 82000000 		.long	0x82
 7779 0858 00000000 		.long	.LLST53
GAS LISTING /tmp/ccOaNtkH.s 			page 161


 7780 085c 18       		.uleb128 0x18
 7781 085d 00000000 		.long	.LASF47
 7782 0861 01       		.byte	0x1
 7783 0862 3101     		.value	0x131
 7784 0864 82000000 		.long	0x82
 7785 0868 00000000 		.long	.LLST54
 7786 086c 00       		.byte	0x0
 7787 086d 0A       		.uleb128 0xa
 7788 086e 01       		.byte	0x1
 7789 086f 00000000 		.long	.LASF48
 7790 0873 01       		.byte	0x1
 7791 0874 36       		.byte	0x36
 7792 0875 01       		.byte	0x1
 7793 0876 00000000 		.quad	.LFB22
 7793      00000000 
 7794 087e 00000000 		.quad	.LFE22
 7794      00000000 
 7795 0886 01       		.byte	0x1
 7796 0887 9C       		.byte	0x9c
 7797 0888 B5080000 		.long	0x8b5
 7798 088c 0C       		.uleb128 0xc
 7799 088d 686D00   		.string	"hm"
 7800 0890 01       		.byte	0x1
 7801 0891 36       		.byte	0x36
 7802 0892 16020000 		.long	0x216
 7803 0896 00000000 		.long	.LLST55
 7804 089a 0C       		.uleb128 0xc
 7805 089b 7700     		.string	"w"
 7806 089d 01       		.byte	0x1
 7807 089e 36       		.byte	0x36
 7808 089f 8F000000 		.long	0x8f
 7809 08a3 00000000 		.long	.LLST56
 7810 08a7 0C       		.uleb128 0xc
 7811 08a8 6800     		.string	"h"
 7812 08aa 01       		.byte	0x1
 7813 08ab 36       		.byte	0x36
 7814 08ac 8F000000 		.long	0x8f
 7815 08b0 00000000 		.long	.LLST57
 7816 08b4 00       		.byte	0x0
 7817 08b5 19       		.uleb128 0x19
 7818 08b6 01       		.byte	0x1
 7819 08b7 00000000 		.long	.LASF49
 7820 08bb 01       		.byte	0x1
 7821 08bc 3E       		.byte	0x3e
 7822 08bd 01       		.byte	0x1
 7823 08be 16020000 		.long	0x216
 7824 08c2 00000000 		.quad	.LFB23
 7824      00000000 
 7825 08ca 00000000 		.quad	.LFE23
 7825      00000000 
 7826 08d2 01       		.byte	0x1
 7827 08d3 9C       		.byte	0x9c
 7828 08d4 01090000 		.long	0x901
 7829 08d8 0C       		.uleb128 0xc
 7830 08d9 7700     		.string	"w"
 7831 08db 01       		.byte	0x1
 7832 08dc 3E       		.byte	0x3e
GAS LISTING /tmp/ccOaNtkH.s 			page 162


 7833 08dd 8F000000 		.long	0x8f
 7834 08e1 00000000 		.long	.LLST58
 7835 08e5 0C       		.uleb128 0xc
 7836 08e6 6800     		.string	"h"
 7837 08e8 01       		.byte	0x1
 7838 08e9 3E       		.byte	0x3e
 7839 08ea 8F000000 		.long	0x8f
 7840 08ee 00000000 		.long	.LLST59
 7841 08f2 0F       		.uleb128 0xf
 7842 08f3 686D00   		.string	"hm"
 7843 08f6 01       		.byte	0x1
 7844 08f7 40       		.byte	0x40
 7845 08f8 16020000 		.long	0x216
 7846 08fc 00000000 		.long	.LLST60
 7847 0900 00       		.byte	0x0
 7848 0901 21       		.uleb128 0x21
 7849 0902 00000000 		.long	.LASF65
 7850 0906 01       		.byte	0x1
 7851 0907 01       		.byte	0x1
 7852 0908 00000000 		.quad	.LFB43
 7852      00000000 
 7853 0910 00000000 		.quad	.LFE43
 7853      00000000 
 7854 0918 01       		.byte	0x1
 7855 0919 9C       		.byte	0x9c
 7856 091a DE090000 		.long	0x9de
 7857 091e 22       		.uleb128 0x22
 7858 091f 00000000 		.long	.LASF66
 7859 0923 550A0000 		.long	0xa55
 7860 0927 01       		.byte	0x1
 7861 0928 00000000 		.long	.LLST61
 7862 092c 10       		.uleb128 0x10
 7863 092d 00000000 		.long	.LASF50
 7864 0931 01       		.byte	0x1
 7865 0932 55       		.byte	0x55
 7866 0933 3F0A0000 		.long	0xa3f
 7867 0937 00000000 		.long	.LLST62
 7868 093b 10       		.uleb128 0x10
 7869 093c 00000000 		.long	.LASF51
 7870 0940 01       		.byte	0x1
 7871 0941 54       		.byte	0x54
 7872 0942 27020000 		.long	0x227
 7873 0946 00000000 		.long	.LLST63
 7874 094a 10       		.uleb128 0x10
 7875 094b 00000000 		.long	.LASF18
 7876 094f 01       		.byte	0x1
 7877 0950 51       		.byte	0x51
 7878 0951 1C020000 		.long	0x21c
 7879 0955 00000000 		.long	.LLST64
 7880 0959 10       		.uleb128 0x10
 7881 095a 00000000 		.long	.LASF52
 7882 095e 01       		.byte	0x1
 7883 095f 51       		.byte	0x51
 7884 0960 8F000000 		.long	0x8f
 7885 0964 00000000 		.long	.LLST65
 7886 0968 0F       		.uleb128 0xf
 7887 0969 797300   		.string	"ys"
GAS LISTING /tmp/ccOaNtkH.s 			page 163


 7888 096c 01       		.byte	0x1
 7889 096d 51       		.byte	0x51
 7890 096e 390A0000 		.long	0xa39
 7891 0972 00000000 		.long	.LLST66
 7892 0976 0F       		.uleb128 0xf
 7893 0977 787300   		.string	"xs"
 7894 097a 01       		.byte	0x1
 7895 097b 51       		.byte	0x51
 7896 097c 390A0000 		.long	0xa39
 7897 0980 00000000 		.long	.LLST67
 7898 0984 0F       		.uleb128 0xf
 7899 0985 6800     		.string	"h"
 7900 0987 01       		.byte	0x1
 7901 0988 51       		.byte	0x51
 7902 0989 16020000 		.long	0x216
 7903 098d 00000000 		.long	.LLST68
 7904 0991 1A       		.uleb128 0x1a
 7905 0992 00000000 		.quad	.LBB21
 7905      00000000 
 7906 099a 00000000 		.quad	.LBE21
 7906      00000000 
 7907 09a2 0F       		.uleb128 0xf
 7908 09a3 69647800 		.string	"idx"
 7909 09a7 01       		.byte	0x1
 7910 09a8 5A       		.byte	0x5a
 7911 09a9 46000000 		.long	0x46
 7912 09ad 00000000 		.long	.LLST69
 7913 09b1 10       		.uleb128 0x10
 7914 09b2 00000000 		.long	.LASF53
 7915 09b6 01       		.byte	0x1
 7916 09b7 5B       		.byte	0x5b
 7917 09b8 8F000000 		.long	0x8f
 7918 09bc 00000000 		.long	.LLST70
 7919 09c0 0F       		.uleb128 0xf
 7920 09c1 656E6400 		.string	"end"
 7921 09c5 01       		.byte	0x1
 7922 09c6 5C       		.byte	0x5c
 7923 09c7 8F000000 		.long	0x8f
 7924 09cb 00000000 		.long	.LLST71
 7925 09cf 0F       		.uleb128 0xf
 7926 09d0 6900     		.string	"i"
 7927 09d2 01       		.byte	0x1
 7928 09d3 60       		.byte	0x60
 7929 09d4 8F000000 		.long	0x8f
 7930 09d8 00000000 		.long	.LLST72
 7931 09dc 00       		.byte	0x0
 7932 09dd 00       		.byte	0x0
 7933 09de 23       		.uleb128 0x23
 7934 09df 00000000 		.long	.LASF67
 7935 09e3 30       		.byte	0x30
 7936 09e4 390A0000 		.long	0xa39
 7937 09e8 06       		.uleb128 0x6
 7938 09e9 6800     		.string	"h"
 7939 09eb 01       		.byte	0x1
 7940 09ec 58       		.byte	0x58
 7941 09ed 16020000 		.long	0x216
 7942 09f1 00       		.sleb128 0
GAS LISTING /tmp/ccOaNtkH.s 			page 164


 7943 09f2 06       		.uleb128 0x6
 7944 09f3 787300   		.string	"xs"
 7945 09f6 01       		.byte	0x1
 7946 09f7 58       		.byte	0x58
 7947 09f8 390A0000 		.long	0xa39
 7948 09fc 08       		.sleb128 8
 7949 09fd 06       		.uleb128 0x6
 7950 09fe 797300   		.string	"ys"
 7951 0a01 01       		.byte	0x1
 7952 0a02 58       		.byte	0x58
 7953 0a03 390A0000 		.long	0xa39
 7954 0a07 10       		.sleb128 16
 7955 0a08 08       		.uleb128 0x8
 7956 0a09 00000000 		.long	.LASF18
 7957 0a0d 01       		.byte	0x1
 7958 0a0e 58       		.byte	0x58
 7959 0a0f 1C020000 		.long	0x21c
 7960 0a13 18       		.sleb128 24
 7961 0a14 08       		.uleb128 0x8
 7962 0a15 00000000 		.long	.LASF50
 7963 0a19 01       		.byte	0x1
 7964 0a1a 58       		.byte	0x58
 7965 0a1b 4F0A0000 		.long	0xa4f
 7966 0a1f 20       		.sleb128 32
 7967 0a20 08       		.uleb128 0x8
 7968 0a21 00000000 		.long	.LASF52
 7969 0a25 01       		.byte	0x1
 7970 0a26 58       		.byte	0x58
 7971 0a27 8F000000 		.long	0x8f
 7972 0a2b 28       		.sleb128 40
 7973 0a2c 08       		.uleb128 0x8
 7974 0a2d 00000000 		.long	.LASF51
 7975 0a31 01       		.byte	0x1
 7976 0a32 58       		.byte	0x58
 7977 0a33 27020000 		.long	0x227
 7978 0a37 2C       		.sleb128 44
 7979 0a38 00       		.byte	0x0
 7980 0a39 07       		.uleb128 0x7
 7981 0a3a 08       		.byte	0x8
 7982 0a3b 8F000000 		.long	0x8f
 7983 0a3f 24       		.uleb128 0x24
 7984 0a40 96000000 		.long	0x96
 7985 0a44 4F0A0000 		.long	0xa4f
 7986 0a48 25       		.uleb128 0x25
 7987 0a49 3F000000 		.long	0x3f
 7988 0a4d 1F       		.byte	0x1f
 7989 0a4e 00       		.byte	0x0
 7990 0a4f 07       		.uleb128 0x7
 7991 0a50 08       		.byte	0x8
 7992 0a51 3F0A0000 		.long	0xa3f
 7993 0a55 07       		.uleb128 0x7
 7994 0a56 08       		.byte	0x8
 7995 0a57 DE090000 		.long	0x9de
 7996 0a5b 0A       		.uleb128 0xa
 7997 0a5c 01       		.byte	0x1
 7998 0a5d 00000000 		.long	.LASF54
 7999 0a61 01       		.byte	0x1
GAS LISTING /tmp/ccOaNtkH.s 			page 165


 8000 0a62 51       		.byte	0x51
 8001 0a63 01       		.byte	0x1
 8002 0a64 00000000 		.quad	.LFB26
 8002      00000000 
 8003 0a6c 00000000 		.quad	.LFE26
 8003      00000000 
 8004 0a74 01       		.byte	0x1
 8005 0a75 9C       		.byte	0x9c
 8006 0a76 0E0B0000 		.long	0xb0e
 8007 0a7a 0C       		.uleb128 0xc
 8008 0a7b 6800     		.string	"h"
 8009 0a7d 01       		.byte	0x1
 8010 0a7e 51       		.byte	0x51
 8011 0a7f 16020000 		.long	0x216
 8012 0a83 00000000 		.long	.LLST73
 8013 0a87 0C       		.uleb128 0xc
 8014 0a88 787300   		.string	"xs"
 8015 0a8b 01       		.byte	0x1
 8016 0a8c 51       		.byte	0x51
 8017 0a8d 390A0000 		.long	0xa39
 8018 0a91 00000000 		.long	.LLST74
 8019 0a95 0C       		.uleb128 0xc
 8020 0a96 797300   		.string	"ys"
 8021 0a99 01       		.byte	0x1
 8022 0a9a 51       		.byte	0x51
 8023 0a9b 390A0000 		.long	0xa39
 8024 0a9f 00000000 		.long	.LLST75
 8025 0aa3 0D       		.uleb128 0xd
 8026 0aa4 00000000 		.long	.LASF52
 8027 0aa8 01       		.byte	0x1
 8028 0aa9 51       		.byte	0x51
 8029 0aaa 8F000000 		.long	0x8f
 8030 0aae 00000000 		.long	.LLST76
 8031 0ab2 0D       		.uleb128 0xd
 8032 0ab3 00000000 		.long	.LASF18
 8033 0ab7 01       		.byte	0x1
 8034 0ab8 51       		.byte	0x51
 8035 0ab9 1C020000 		.long	0x21c
 8036 0abd 00000000 		.long	.LLST77
 8037 0ac1 10       		.uleb128 0x10
 8038 0ac2 00000000 		.long	.LASF51
 8039 0ac6 01       		.byte	0x1
 8040 0ac7 54       		.byte	0x54
 8041 0ac8 27020000 		.long	0x227
 8042 0acc 00000000 		.long	.LLST78
 8043 0ad0 26       		.uleb128 0x26
 8044 0ad1 00000000 		.long	.LASF50
 8045 0ad5 01       		.byte	0x1
 8046 0ad6 55       		.byte	0x55
 8047 0ad7 3F0A0000 		.long	0xa3f
 8048 0adb 03       		.byte	0x3
 8049 0adc 91       		.byte	0x91
 8050 0add C079     		.sleb128 -832
 8051 0adf 27       		.uleb128 0x27
 8052 0ae0 7800     		.string	"x"
 8053 0ae2 01       		.byte	0x1
 8054 0ae3 68       		.byte	0x68
GAS LISTING /tmp/ccOaNtkH.s 			page 166


 8055 0ae4 8F000000 		.long	0x8f
 8056 0ae8 28       		.uleb128 0x28
 8057 0ae9 7900     		.string	"y"
 8058 0aeb 01       		.byte	0x1
 8059 0aec 68       		.byte	0x68
 8060 0aed 8F000000 		.long	0x8f
 8061 0af1 00       		.byte	0x0
 8062 0af2 27       		.uleb128 0x27
 8063 0af3 6B00     		.string	"k"
 8064 0af5 01       		.byte	0x1
 8065 0af6 68       		.byte	0x68
 8066 0af7 8F000000 		.long	0x8f
 8067 0afb 27       		.uleb128 0x27
 8068 0afc 6900     		.string	"i"
 8069 0afe 01       		.byte	0x1
 8070 0aff 68       		.byte	0x68
 8071 0b00 8F000000 		.long	0x8f
 8072 0b04 27       		.uleb128 0x27
 8073 0b05 7700     		.string	"w"
 8074 0b07 01       		.byte	0x1
 8075 0b08 69       		.byte	0x69
 8076 0b09 88000000 		.long	0x88
 8077 0b0d 00       		.byte	0x0
 8078 0b0e 0A       		.uleb128 0xa
 8079 0b0f 01       		.byte	0x1
 8080 0b10 00000000 		.long	.LASF55
 8081 0b14 01       		.byte	0x1
 8082 0b15 4C       		.byte	0x4c
 8083 0b16 01       		.byte	0x1
 8084 0b17 00000000 		.quad	.LFB25
 8084      00000000 
 8085 0b1f 00000000 		.quad	.LFE25
 8085      00000000 
 8086 0b27 01       		.byte	0x1
 8087 0b28 9C       		.byte	0x9c
 8088 0b29 5E0B0000 		.long	0xb5e
 8089 0b2d 0B       		.uleb128 0xb
 8090 0b2e 6800     		.string	"h"
 8091 0b30 01       		.byte	0x1
 8092 0b31 4C       		.byte	0x4c
 8093 0b32 16020000 		.long	0x216
 8094 0b36 01       		.byte	0x1
 8095 0b37 55       		.byte	0x55
 8096 0b38 0B       		.uleb128 0xb
 8097 0b39 787300   		.string	"xs"
 8098 0b3c 01       		.byte	0x1
 8099 0b3d 4C       		.byte	0x4c
 8100 0b3e 390A0000 		.long	0xa39
 8101 0b42 01       		.byte	0x1
 8102 0b43 54       		.byte	0x54
 8103 0b44 0B       		.uleb128 0xb
 8104 0b45 797300   		.string	"ys"
 8105 0b48 01       		.byte	0x1
 8106 0b49 4C       		.byte	0x4c
 8107 0b4a 390A0000 		.long	0xa39
 8108 0b4e 01       		.byte	0x1
 8109 0b4f 51       		.byte	0x51
GAS LISTING /tmp/ccOaNtkH.s 			page 167


 8110 0b50 1C       		.uleb128 0x1c
 8111 0b51 00000000 		.long	.LASF52
 8112 0b55 01       		.byte	0x1
 8113 0b56 4C       		.byte	0x4c
 8114 0b57 8F000000 		.long	0x8f
 8115 0b5b 01       		.byte	0x1
 8116 0b5c 52       		.byte	0x52
 8117 0b5d 00       		.byte	0x0
 8118 0b5e 29       		.uleb128 0x29
 8119 0b5f 00000000 		.long	.LASF60
 8120 0b63 02       		.byte	0x2
 8121 0b64 AC       		.byte	0xac
 8122 0b65 A8050000 		.long	0x5a8
 8123 0b69 01       		.byte	0x1
 8124 0b6a 01       		.byte	0x1
 8125 0b6b 24       		.uleb128 0x24
 8126 0b6c 88000000 		.long	0x88
 8127 0b70 7B0B0000 		.long	0xb7b
 8128 0b74 25       		.uleb128 0x25
 8129 0b75 3F000000 		.long	0x3f
 8130 0b79 50       		.byte	0x50
 8131 0b7a 00       		.byte	0x0
 8132 0b7b 26       		.uleb128 0x26
 8133 0b7c 00000000 		.long	.LASF56
 8134 0b80 01       		.byte	0x1
 8135 0b81 26       		.byte	0x26
 8136 0b82 6B0B0000 		.long	0xb6b
 8137 0b86 09       		.byte	0x9
 8138 0b87 03       		.byte	0x3
 8139 0b88 00000000 		.quad	stamp_default_4_data
 8139      00000000 
 8140 0b90 26       		.uleb128 0x26
 8141 0b91 00000000 		.long	.LASF57
 8142 0b95 01       		.byte	0x1
 8143 0b96 32       		.byte	0x32
 8144 0b97 CA000000 		.long	0xca
 8145 0b9b 09       		.byte	0x9
 8146 0b9c 03       		.byte	0x3
 8147 0b9d 00000000 		.quad	stamp_default_4
 8147      00000000 
 8148 0ba5 24       		.uleb128 0x24
 8149 0ba6 01010000 		.long	0x101
 8150 0baa B60B0000 		.long	0xbb6
 8151 0bae 2A       		.uleb128 0x2a
 8152 0baf 3F000000 		.long	0x3f
 8153 0bb3 0310     		.value	0x1003
 8154 0bb5 00       		.byte	0x0
 8155 0bb6 2B       		.uleb128 0x2b
 8156 0bb7 00000000 		.long	.LASF58
 8157 0bbb 01       		.byte	0x1
 8158 0bbc 7A01     		.value	0x17a
 8159 0bbe CC0B0000 		.long	0xbcc
 8160 0bc2 09       		.byte	0x9
 8161 0bc3 03       		.byte	0x3
 8162 0bc4 00000000 		.quad	mixed_data
 8162      00000000 
 8163 0bcc 09       		.uleb128 0x9
GAS LISTING /tmp/ccOaNtkH.s 			page 168


 8164 0bcd A50B0000 		.long	0xba5
 8165 0bd1 2B       		.uleb128 0x2b
 8166 0bd2 00000000 		.long	.LASF59
 8167 0bd6 01       		.byte	0x1
 8168 0bd7 7B01     		.value	0x17b
 8169 0bd9 AE050000 		.long	0x5ae
 8170 0bdd 09       		.byte	0x9
 8171 0bde 03       		.byte	0x3
 8172 0bdf 00000000 		.quad	cs_spectral_mixed
 8172      00000000 
 8173 0be7 2C       		.uleb128 0x2c
 8174 0be8 00000000 		.long	.LASF60
 8175 0bec 01       		.byte	0x1
 8176 0bed 7C01     		.value	0x17c
 8177 0bef A8050000 		.long	0x5a8
 8178 0bf3 01       		.byte	0x1
 8179 0bf4 09       		.byte	0x9
 8180 0bf5 03       		.byte	0x3
 8181 0bf6 00000000 		.quad	heatmap_cs_default
 8181      00000000 
 8182 0bfe 00       		.byte	0x0
 8183              		.section	.debug_abbrev
 8184 0000 01       		.uleb128 0x1
 8185 0001 11       		.uleb128 0x11
 8186 0002 01       		.byte	0x1
 8187 0003 25       		.uleb128 0x25
 8188 0004 0E       		.uleb128 0xe
 8189 0005 13       		.uleb128 0x13
 8190 0006 0B       		.uleb128 0xb
 8191 0007 03       		.uleb128 0x3
 8192 0008 0E       		.uleb128 0xe
 8193 0009 1B       		.uleb128 0x1b
 8194 000a 0E       		.uleb128 0xe
 8195 000b 11       		.uleb128 0x11
 8196 000c 01       		.uleb128 0x1
 8197 000d 12       		.uleb128 0x12
 8198 000e 01       		.uleb128 0x1
 8199 000f 10       		.uleb128 0x10
 8200 0010 06       		.uleb128 0x6
 8201 0011 00       		.byte	0x0
 8202 0012 00       		.byte	0x0
 8203 0013 02       		.uleb128 0x2
 8204 0014 24       		.uleb128 0x24
 8205 0015 00       		.byte	0x0
 8206 0016 0B       		.uleb128 0xb
 8207 0017 0B       		.uleb128 0xb
 8208 0018 3E       		.uleb128 0x3e
 8209 0019 0B       		.uleb128 0xb
 8210 001a 03       		.uleb128 0x3
 8211 001b 0E       		.uleb128 0xe
 8212 001c 00       		.byte	0x0
 8213 001d 00       		.byte	0x0
 8214 001e 03       		.uleb128 0x3
 8215 001f 16       		.uleb128 0x16
 8216 0020 00       		.byte	0x0
 8217 0021 03       		.uleb128 0x3
 8218 0022 0E       		.uleb128 0xe
GAS LISTING /tmp/ccOaNtkH.s 			page 169


 8219 0023 3A       		.uleb128 0x3a
 8220 0024 0B       		.uleb128 0xb
 8221 0025 3B       		.uleb128 0x3b
 8222 0026 0B       		.uleb128 0xb
 8223 0027 49       		.uleb128 0x49
 8224 0028 13       		.uleb128 0x13
 8225 0029 00       		.byte	0x0
 8226 002a 00       		.byte	0x0
 8227 002b 04       		.uleb128 0x4
 8228 002c 24       		.uleb128 0x24
 8229 002d 00       		.byte	0x0
 8230 002e 0B       		.uleb128 0xb
 8231 002f 0B       		.uleb128 0xb
 8232 0030 3E       		.uleb128 0x3e
 8233 0031 0B       		.uleb128 0xb
 8234 0032 03       		.uleb128 0x3
 8235 0033 08       		.uleb128 0x8
 8236 0034 00       		.byte	0x0
 8237 0035 00       		.byte	0x0
 8238 0036 05       		.uleb128 0x5
 8239 0037 13       		.uleb128 0x13
 8240 0038 01       		.byte	0x1
 8241 0039 0B       		.uleb128 0xb
 8242 003a 0B       		.uleb128 0xb
 8243 003b 3A       		.uleb128 0x3a
 8244 003c 0B       		.uleb128 0xb
 8245 003d 3B       		.uleb128 0x3b
 8246 003e 0B       		.uleb128 0xb
 8247 003f 01       		.uleb128 0x1
 8248 0040 13       		.uleb128 0x13
 8249 0041 00       		.byte	0x0
 8250 0042 00       		.byte	0x0
 8251 0043 06       		.uleb128 0x6
 8252 0044 0D       		.uleb128 0xd
 8253 0045 00       		.byte	0x0
 8254 0046 03       		.uleb128 0x3
 8255 0047 08       		.uleb128 0x8
 8256 0048 3A       		.uleb128 0x3a
 8257 0049 0B       		.uleb128 0xb
 8258 004a 3B       		.uleb128 0x3b
 8259 004b 0B       		.uleb128 0xb
 8260 004c 49       		.uleb128 0x49
 8261 004d 13       		.uleb128 0x13
 8262 004e 38       		.uleb128 0x38
 8263 004f 0D       		.uleb128 0xd
 8264 0050 00       		.byte	0x0
 8265 0051 00       		.byte	0x0
 8266 0052 07       		.uleb128 0x7
 8267 0053 0F       		.uleb128 0xf
 8268 0054 00       		.byte	0x0
 8269 0055 0B       		.uleb128 0xb
 8270 0056 0B       		.uleb128 0xb
 8271 0057 49       		.uleb128 0x49
 8272 0058 13       		.uleb128 0x13
 8273 0059 00       		.byte	0x0
 8274 005a 00       		.byte	0x0
 8275 005b 08       		.uleb128 0x8
GAS LISTING /tmp/ccOaNtkH.s 			page 170


 8276 005c 0D       		.uleb128 0xd
 8277 005d 00       		.byte	0x0
 8278 005e 03       		.uleb128 0x3
 8279 005f 0E       		.uleb128 0xe
 8280 0060 3A       		.uleb128 0x3a
 8281 0061 0B       		.uleb128 0xb
 8282 0062 3B       		.uleb128 0x3b
 8283 0063 0B       		.uleb128 0xb
 8284 0064 49       		.uleb128 0x49
 8285 0065 13       		.uleb128 0x13
 8286 0066 38       		.uleb128 0x38
 8287 0067 0D       		.uleb128 0xd
 8288 0068 00       		.byte	0x0
 8289 0069 00       		.byte	0x0
 8290 006a 09       		.uleb128 0x9
 8291 006b 26       		.uleb128 0x26
 8292 006c 00       		.byte	0x0
 8293 006d 49       		.uleb128 0x49
 8294 006e 13       		.uleb128 0x13
 8295 006f 00       		.byte	0x0
 8296 0070 00       		.byte	0x0
 8297 0071 0A       		.uleb128 0xa
 8298 0072 2E       		.uleb128 0x2e
 8299 0073 01       		.byte	0x1
 8300 0074 3F       		.uleb128 0x3f
 8301 0075 0C       		.uleb128 0xc
 8302 0076 03       		.uleb128 0x3
 8303 0077 0E       		.uleb128 0xe
 8304 0078 3A       		.uleb128 0x3a
 8305 0079 0B       		.uleb128 0xb
 8306 007a 3B       		.uleb128 0x3b
 8307 007b 0B       		.uleb128 0xb
 8308 007c 27       		.uleb128 0x27
 8309 007d 0C       		.uleb128 0xc
 8310 007e 11       		.uleb128 0x11
 8311 007f 01       		.uleb128 0x1
 8312 0080 12       		.uleb128 0x12
 8313 0081 01       		.uleb128 0x1
 8314 0082 40       		.uleb128 0x40
 8315 0083 0A       		.uleb128 0xa
 8316 0084 01       		.uleb128 0x1
 8317 0085 13       		.uleb128 0x13
 8318 0086 00       		.byte	0x0
 8319 0087 00       		.byte	0x0
 8320 0088 0B       		.uleb128 0xb
 8321 0089 05       		.uleb128 0x5
 8322 008a 00       		.byte	0x0
 8323 008b 03       		.uleb128 0x3
 8324 008c 08       		.uleb128 0x8
 8325 008d 3A       		.uleb128 0x3a
 8326 008e 0B       		.uleb128 0xb
 8327 008f 3B       		.uleb128 0x3b
 8328 0090 0B       		.uleb128 0xb
 8329 0091 49       		.uleb128 0x49
 8330 0092 13       		.uleb128 0x13
 8331 0093 02       		.uleb128 0x2
 8332 0094 0A       		.uleb128 0xa
GAS LISTING /tmp/ccOaNtkH.s 			page 171


 8333 0095 00       		.byte	0x0
 8334 0096 00       		.byte	0x0
 8335 0097 0C       		.uleb128 0xc
 8336 0098 05       		.uleb128 0x5
 8337 0099 00       		.byte	0x0
 8338 009a 03       		.uleb128 0x3
 8339 009b 08       		.uleb128 0x8
 8340 009c 3A       		.uleb128 0x3a
 8341 009d 0B       		.uleb128 0xb
 8342 009e 3B       		.uleb128 0x3b
 8343 009f 0B       		.uleb128 0xb
 8344 00a0 49       		.uleb128 0x49
 8345 00a1 13       		.uleb128 0x13
 8346 00a2 02       		.uleb128 0x2
 8347 00a3 06       		.uleb128 0x6
 8348 00a4 00       		.byte	0x0
 8349 00a5 00       		.byte	0x0
 8350 00a6 0D       		.uleb128 0xd
 8351 00a7 05       		.uleb128 0x5
 8352 00a8 00       		.byte	0x0
 8353 00a9 03       		.uleb128 0x3
 8354 00aa 0E       		.uleb128 0xe
 8355 00ab 3A       		.uleb128 0x3a
 8356 00ac 0B       		.uleb128 0xb
 8357 00ad 3B       		.uleb128 0x3b
 8358 00ae 0B       		.uleb128 0xb
 8359 00af 49       		.uleb128 0x49
 8360 00b0 13       		.uleb128 0x13
 8361 00b1 02       		.uleb128 0x2
 8362 00b2 06       		.uleb128 0x6
 8363 00b3 00       		.byte	0x0
 8364 00b4 00       		.byte	0x0
 8365 00b5 0E       		.uleb128 0xe
 8366 00b6 0B       		.uleb128 0xb
 8367 00b7 01       		.byte	0x1
 8368 00b8 55       		.uleb128 0x55
 8369 00b9 06       		.uleb128 0x6
 8370 00ba 00       		.byte	0x0
 8371 00bb 00       		.byte	0x0
 8372 00bc 0F       		.uleb128 0xf
 8373 00bd 34       		.uleb128 0x34
 8374 00be 00       		.byte	0x0
 8375 00bf 03       		.uleb128 0x3
 8376 00c0 08       		.uleb128 0x8
 8377 00c1 3A       		.uleb128 0x3a
 8378 00c2 0B       		.uleb128 0xb
 8379 00c3 3B       		.uleb128 0x3b
 8380 00c4 0B       		.uleb128 0xb
 8381 00c5 49       		.uleb128 0x49
 8382 00c6 13       		.uleb128 0x13
 8383 00c7 02       		.uleb128 0x2
 8384 00c8 06       		.uleb128 0x6
 8385 00c9 00       		.byte	0x0
 8386 00ca 00       		.byte	0x0
 8387 00cb 10       		.uleb128 0x10
 8388 00cc 34       		.uleb128 0x34
 8389 00cd 00       		.byte	0x0
GAS LISTING /tmp/ccOaNtkH.s 			page 172


 8390 00ce 03       		.uleb128 0x3
 8391 00cf 0E       		.uleb128 0xe
 8392 00d0 3A       		.uleb128 0x3a
 8393 00d1 0B       		.uleb128 0xb
 8394 00d2 3B       		.uleb128 0x3b
 8395 00d3 0B       		.uleb128 0xb
 8396 00d4 49       		.uleb128 0x49
 8397 00d5 13       		.uleb128 0x13
 8398 00d6 02       		.uleb128 0x2
 8399 00d7 06       		.uleb128 0x6
 8400 00d8 00       		.byte	0x0
 8401 00d9 00       		.byte	0x0
 8402 00da 11       		.uleb128 0x11
 8403 00db 2E       		.uleb128 0x2e
 8404 00dc 01       		.byte	0x1
 8405 00dd 03       		.uleb128 0x3
 8406 00de 0E       		.uleb128 0xe
 8407 00df 3A       		.uleb128 0x3a
 8408 00e0 0B       		.uleb128 0xb
 8409 00e1 3B       		.uleb128 0x3b
 8410 00e2 05       		.uleb128 0x5
 8411 00e3 27       		.uleb128 0x27
 8412 00e4 0C       		.uleb128 0xc
 8413 00e5 49       		.uleb128 0x49
 8414 00e6 13       		.uleb128 0x13
 8415 00e7 11       		.uleb128 0x11
 8416 00e8 01       		.uleb128 0x1
 8417 00e9 12       		.uleb128 0x12
 8418 00ea 01       		.uleb128 0x1
 8419 00eb 40       		.uleb128 0x40
 8420 00ec 0A       		.uleb128 0xa
 8421 00ed 01       		.uleb128 0x1
 8422 00ee 13       		.uleb128 0x13
 8423 00ef 00       		.byte	0x0
 8424 00f0 00       		.byte	0x0
 8425 00f1 12       		.uleb128 0x12
 8426 00f2 05       		.uleb128 0x5
 8427 00f3 00       		.byte	0x0
 8428 00f4 03       		.uleb128 0x3
 8429 00f5 0E       		.uleb128 0xe
 8430 00f6 3A       		.uleb128 0x3a
 8431 00f7 0B       		.uleb128 0xb
 8432 00f8 3B       		.uleb128 0x3b
 8433 00f9 05       		.uleb128 0x5
 8434 00fa 49       		.uleb128 0x49
 8435 00fb 13       		.uleb128 0x13
 8436 00fc 02       		.uleb128 0x2
 8437 00fd 0A       		.uleb128 0xa
 8438 00fe 00       		.byte	0x0
 8439 00ff 00       		.byte	0x0
 8440 0100 13       		.uleb128 0x13
 8441 0101 2E       		.uleb128 0x2e
 8442 0102 01       		.byte	0x1
 8443 0103 3F       		.uleb128 0x3f
 8444 0104 0C       		.uleb128 0xc
 8445 0105 03       		.uleb128 0x3
 8446 0106 0E       		.uleb128 0xe
GAS LISTING /tmp/ccOaNtkH.s 			page 173


 8447 0107 3A       		.uleb128 0x3a
 8448 0108 0B       		.uleb128 0xb
 8449 0109 3B       		.uleb128 0x3b
 8450 010a 05       		.uleb128 0x5
 8451 010b 27       		.uleb128 0x27
 8452 010c 0C       		.uleb128 0xc
 8453 010d 11       		.uleb128 0x11
 8454 010e 01       		.uleb128 0x1
 8455 010f 12       		.uleb128 0x12
 8456 0110 01       		.uleb128 0x1
 8457 0111 40       		.uleb128 0x40
 8458 0112 0A       		.uleb128 0xa
 8459 0113 01       		.uleb128 0x1
 8460 0114 13       		.uleb128 0x13
 8461 0115 00       		.byte	0x0
 8462 0116 00       		.byte	0x0
 8463 0117 14       		.uleb128 0x14
 8464 0118 05       		.uleb128 0x5
 8465 0119 00       		.byte	0x0
 8466 011a 03       		.uleb128 0x3
 8467 011b 08       		.uleb128 0x8
 8468 011c 3A       		.uleb128 0x3a
 8469 011d 0B       		.uleb128 0xb
 8470 011e 3B       		.uleb128 0x3b
 8471 011f 05       		.uleb128 0x5
 8472 0120 49       		.uleb128 0x49
 8473 0121 13       		.uleb128 0x13
 8474 0122 02       		.uleb128 0x2
 8475 0123 06       		.uleb128 0x6
 8476 0124 00       		.byte	0x0
 8477 0125 00       		.byte	0x0
 8478 0126 15       		.uleb128 0x15
 8479 0127 2E       		.uleb128 0x2e
 8480 0128 01       		.byte	0x1
 8481 0129 3F       		.uleb128 0x3f
 8482 012a 0C       		.uleb128 0xc
 8483 012b 03       		.uleb128 0x3
 8484 012c 0E       		.uleb128 0xe
 8485 012d 3A       		.uleb128 0x3a
 8486 012e 0B       		.uleb128 0xb
 8487 012f 3B       		.uleb128 0x3b
 8488 0130 05       		.uleb128 0x5
 8489 0131 27       		.uleb128 0x27
 8490 0132 0C       		.uleb128 0xc
 8491 0133 49       		.uleb128 0x49
 8492 0134 13       		.uleb128 0x13
 8493 0135 11       		.uleb128 0x11
 8494 0136 01       		.uleb128 0x1
 8495 0137 12       		.uleb128 0x12
 8496 0138 01       		.uleb128 0x1
 8497 0139 40       		.uleb128 0x40
 8498 013a 0A       		.uleb128 0xa
 8499 013b 01       		.uleb128 0x1
 8500 013c 13       		.uleb128 0x13
 8501 013d 00       		.byte	0x0
 8502 013e 00       		.byte	0x0
 8503 013f 16       		.uleb128 0x16
GAS LISTING /tmp/ccOaNtkH.s 			page 174


 8504 0140 05       		.uleb128 0x5
 8505 0141 00       		.byte	0x0
 8506 0142 03       		.uleb128 0x3
 8507 0143 0E       		.uleb128 0xe
 8508 0144 3A       		.uleb128 0x3a
 8509 0145 0B       		.uleb128 0xb
 8510 0146 3B       		.uleb128 0x3b
 8511 0147 05       		.uleb128 0x5
 8512 0148 49       		.uleb128 0x49
 8513 0149 13       		.uleb128 0x13
 8514 014a 02       		.uleb128 0x2
 8515 014b 06       		.uleb128 0x6
 8516 014c 00       		.byte	0x0
 8517 014d 00       		.byte	0x0
 8518 014e 17       		.uleb128 0x17
 8519 014f 34       		.uleb128 0x34
 8520 0150 00       		.byte	0x0
 8521 0151 03       		.uleb128 0x3
 8522 0152 08       		.uleb128 0x8
 8523 0153 3A       		.uleb128 0x3a
 8524 0154 0B       		.uleb128 0xb
 8525 0155 3B       		.uleb128 0x3b
 8526 0156 05       		.uleb128 0x5
 8527 0157 49       		.uleb128 0x49
 8528 0158 13       		.uleb128 0x13
 8529 0159 02       		.uleb128 0x2
 8530 015a 06       		.uleb128 0x6
 8531 015b 00       		.byte	0x0
 8532 015c 00       		.byte	0x0
 8533 015d 18       		.uleb128 0x18
 8534 015e 34       		.uleb128 0x34
 8535 015f 00       		.byte	0x0
 8536 0160 03       		.uleb128 0x3
 8537 0161 0E       		.uleb128 0xe
 8538 0162 3A       		.uleb128 0x3a
 8539 0163 0B       		.uleb128 0xb
 8540 0164 3B       		.uleb128 0x3b
 8541 0165 05       		.uleb128 0x5
 8542 0166 49       		.uleb128 0x49
 8543 0167 13       		.uleb128 0x13
 8544 0168 02       		.uleb128 0x2
 8545 0169 06       		.uleb128 0x6
 8546 016a 00       		.byte	0x0
 8547 016b 00       		.byte	0x0
 8548 016c 19       		.uleb128 0x19
 8549 016d 2E       		.uleb128 0x2e
 8550 016e 01       		.byte	0x1
 8551 016f 3F       		.uleb128 0x3f
 8552 0170 0C       		.uleb128 0xc
 8553 0171 03       		.uleb128 0x3
 8554 0172 0E       		.uleb128 0xe
 8555 0173 3A       		.uleb128 0x3a
 8556 0174 0B       		.uleb128 0xb
 8557 0175 3B       		.uleb128 0x3b
 8558 0176 0B       		.uleb128 0xb
 8559 0177 27       		.uleb128 0x27
 8560 0178 0C       		.uleb128 0xc
GAS LISTING /tmp/ccOaNtkH.s 			page 175


 8561 0179 49       		.uleb128 0x49
 8562 017a 13       		.uleb128 0x13
 8563 017b 11       		.uleb128 0x11
 8564 017c 01       		.uleb128 0x1
 8565 017d 12       		.uleb128 0x12
 8566 017e 01       		.uleb128 0x1
 8567 017f 40       		.uleb128 0x40
 8568 0180 0A       		.uleb128 0xa
 8569 0181 01       		.uleb128 0x1
 8570 0182 13       		.uleb128 0x13
 8571 0183 00       		.byte	0x0
 8572 0184 00       		.byte	0x0
 8573 0185 1A       		.uleb128 0x1a
 8574 0186 0B       		.uleb128 0xb
 8575 0187 01       		.byte	0x1
 8576 0188 11       		.uleb128 0x11
 8577 0189 01       		.uleb128 0x1
 8578 018a 12       		.uleb128 0x12
 8579 018b 01       		.uleb128 0x1
 8580 018c 00       		.byte	0x0
 8581 018d 00       		.byte	0x0
 8582 018e 1B       		.uleb128 0x1b
 8583 018f 34       		.uleb128 0x34
 8584 0190 00       		.byte	0x0
 8585 0191 03       		.uleb128 0x3
 8586 0192 08       		.uleb128 0x8
 8587 0193 3A       		.uleb128 0x3a
 8588 0194 0B       		.uleb128 0xb
 8589 0195 3B       		.uleb128 0x3b
 8590 0196 05       		.uleb128 0x5
 8591 0197 49       		.uleb128 0x49
 8592 0198 13       		.uleb128 0x13
 8593 0199 00       		.byte	0x0
 8594 019a 00       		.byte	0x0
 8595 019b 1C       		.uleb128 0x1c
 8596 019c 05       		.uleb128 0x5
 8597 019d 00       		.byte	0x0
 8598 019e 03       		.uleb128 0x3
 8599 019f 0E       		.uleb128 0xe
 8600 01a0 3A       		.uleb128 0x3a
 8601 01a1 0B       		.uleb128 0xb
 8602 01a2 3B       		.uleb128 0x3b
 8603 01a3 0B       		.uleb128 0xb
 8604 01a4 49       		.uleb128 0x49
 8605 01a5 13       		.uleb128 0x13
 8606 01a6 02       		.uleb128 0x2
 8607 01a7 0A       		.uleb128 0xa
 8608 01a8 00       		.byte	0x0
 8609 01a9 00       		.byte	0x0
 8610 01aa 1D       		.uleb128 0x1d
 8611 01ab 05       		.uleb128 0x5
 8612 01ac 00       		.byte	0x0
 8613 01ad 03       		.uleb128 0x3
 8614 01ae 08       		.uleb128 0x8
 8615 01af 3A       		.uleb128 0x3a
 8616 01b0 0B       		.uleb128 0xb
 8617 01b1 3B       		.uleb128 0x3b
GAS LISTING /tmp/ccOaNtkH.s 			page 176


 8618 01b2 05       		.uleb128 0x5
 8619 01b3 49       		.uleb128 0x49
 8620 01b4 13       		.uleb128 0x13
 8621 01b5 02       		.uleb128 0x2
 8622 01b6 0A       		.uleb128 0xa
 8623 01b7 00       		.byte	0x0
 8624 01b8 00       		.byte	0x0
 8625 01b9 1E       		.uleb128 0x1e
 8626 01ba 34       		.uleb128 0x34
 8627 01bb 00       		.byte	0x0
 8628 01bc 03       		.uleb128 0x3
 8629 01bd 0E       		.uleb128 0xe
 8630 01be 3A       		.uleb128 0x3a
 8631 01bf 0B       		.uleb128 0xb
 8632 01c0 3B       		.uleb128 0x3b
 8633 01c1 05       		.uleb128 0x5
 8634 01c2 49       		.uleb128 0x49
 8635 01c3 13       		.uleb128 0x13
 8636 01c4 00       		.byte	0x0
 8637 01c5 00       		.byte	0x0
 8638 01c6 1F       		.uleb128 0x1f
 8639 01c7 15       		.uleb128 0x15
 8640 01c8 01       		.byte	0x1
 8641 01c9 27       		.uleb128 0x27
 8642 01ca 0C       		.uleb128 0xc
 8643 01cb 49       		.uleb128 0x49
 8644 01cc 13       		.uleb128 0x13
 8645 01cd 01       		.uleb128 0x1
 8646 01ce 13       		.uleb128 0x13
 8647 01cf 00       		.byte	0x0
 8648 01d0 00       		.byte	0x0
 8649 01d1 20       		.uleb128 0x20
 8650 01d2 05       		.uleb128 0x5
 8651 01d3 00       		.byte	0x0
 8652 01d4 49       		.uleb128 0x49
 8653 01d5 13       		.uleb128 0x13
 8654 01d6 00       		.byte	0x0
 8655 01d7 00       		.byte	0x0
 8656 01d8 21       		.uleb128 0x21
 8657 01d9 2E       		.uleb128 0x2e
 8658 01da 01       		.byte	0x1
 8659 01db 03       		.uleb128 0x3
 8660 01dc 0E       		.uleb128 0xe
 8661 01dd 27       		.uleb128 0x27
 8662 01de 0C       		.uleb128 0xc
 8663 01df 34       		.uleb128 0x34
 8664 01e0 0C       		.uleb128 0xc
 8665 01e1 11       		.uleb128 0x11
 8666 01e2 01       		.uleb128 0x1
 8667 01e3 12       		.uleb128 0x12
 8668 01e4 01       		.uleb128 0x1
 8669 01e5 40       		.uleb128 0x40
 8670 01e6 0A       		.uleb128 0xa
 8671 01e7 01       		.uleb128 0x1
 8672 01e8 13       		.uleb128 0x13
 8673 01e9 00       		.byte	0x0
 8674 01ea 00       		.byte	0x0
GAS LISTING /tmp/ccOaNtkH.s 			page 177


 8675 01eb 22       		.uleb128 0x22
 8676 01ec 05       		.uleb128 0x5
 8677 01ed 00       		.byte	0x0
 8678 01ee 03       		.uleb128 0x3
 8679 01ef 0E       		.uleb128 0xe
 8680 01f0 49       		.uleb128 0x49
 8681 01f1 13       		.uleb128 0x13
 8682 01f2 34       		.uleb128 0x34
 8683 01f3 0C       		.uleb128 0xc
 8684 01f4 02       		.uleb128 0x2
 8685 01f5 06       		.uleb128 0x6
 8686 01f6 00       		.byte	0x0
 8687 01f7 00       		.byte	0x0
 8688 01f8 23       		.uleb128 0x23
 8689 01f9 13       		.uleb128 0x13
 8690 01fa 01       		.byte	0x1
 8691 01fb 03       		.uleb128 0x3
 8692 01fc 0E       		.uleb128 0xe
 8693 01fd 0B       		.uleb128 0xb
 8694 01fe 0B       		.uleb128 0xb
 8695 01ff 01       		.uleb128 0x1
 8696 0200 13       		.uleb128 0x13
 8697 0201 00       		.byte	0x0
 8698 0202 00       		.byte	0x0
 8699 0203 24       		.uleb128 0x24
 8700 0204 01       		.uleb128 0x1
 8701 0205 01       		.byte	0x1
 8702 0206 49       		.uleb128 0x49
 8703 0207 13       		.uleb128 0x13
 8704 0208 01       		.uleb128 0x1
 8705 0209 13       		.uleb128 0x13
 8706 020a 00       		.byte	0x0
 8707 020b 00       		.byte	0x0
 8708 020c 25       		.uleb128 0x25
 8709 020d 21       		.uleb128 0x21
 8710 020e 00       		.byte	0x0
 8711 020f 49       		.uleb128 0x49
 8712 0210 13       		.uleb128 0x13
 8713 0211 2F       		.uleb128 0x2f
 8714 0212 0B       		.uleb128 0xb
 8715 0213 00       		.byte	0x0
 8716 0214 00       		.byte	0x0
 8717 0215 26       		.uleb128 0x26
 8718 0216 34       		.uleb128 0x34
 8719 0217 00       		.byte	0x0
 8720 0218 03       		.uleb128 0x3
 8721 0219 0E       		.uleb128 0xe
 8722 021a 3A       		.uleb128 0x3a
 8723 021b 0B       		.uleb128 0xb
 8724 021c 3B       		.uleb128 0x3b
 8725 021d 0B       		.uleb128 0xb
 8726 021e 49       		.uleb128 0x49
 8727 021f 13       		.uleb128 0x13
 8728 0220 02       		.uleb128 0x2
 8729 0221 0A       		.uleb128 0xa
 8730 0222 00       		.byte	0x0
 8731 0223 00       		.byte	0x0
GAS LISTING /tmp/ccOaNtkH.s 			page 178


 8732 0224 27       		.uleb128 0x27
 8733 0225 34       		.uleb128 0x34
 8734 0226 00       		.byte	0x0
 8735 0227 03       		.uleb128 0x3
 8736 0228 08       		.uleb128 0x8
 8737 0229 3A       		.uleb128 0x3a
 8738 022a 0B       		.uleb128 0xb
 8739 022b 3B       		.uleb128 0x3b
 8740 022c 0B       		.uleb128 0xb
 8741 022d 49       		.uleb128 0x49
 8742 022e 13       		.uleb128 0x13
 8743 022f 00       		.byte	0x0
 8744 0230 00       		.byte	0x0
 8745 0231 28       		.uleb128 0x28
 8746 0232 34       		.uleb128 0x34
 8747 0233 00       		.byte	0x0
 8748 0234 03       		.uleb128 0x3
 8749 0235 08       		.uleb128 0x8
 8750 0236 3A       		.uleb128 0x3a
 8751 0237 0B       		.uleb128 0xb
 8752 0238 3B       		.uleb128 0x3b
 8753 0239 0B       		.uleb128 0xb
 8754 023a 49       		.uleb128 0x49
 8755 023b 13       		.uleb128 0x13
 8756 023c 1C       		.uleb128 0x1c
 8757 023d 0B       		.uleb128 0xb
 8758 023e 00       		.byte	0x0
 8759 023f 00       		.byte	0x0
 8760 0240 29       		.uleb128 0x29
 8761 0241 34       		.uleb128 0x34
 8762 0242 00       		.byte	0x0
 8763 0243 03       		.uleb128 0x3
 8764 0244 0E       		.uleb128 0xe
 8765 0245 3A       		.uleb128 0x3a
 8766 0246 0B       		.uleb128 0xb
 8767 0247 3B       		.uleb128 0x3b
 8768 0248 0B       		.uleb128 0xb
 8769 0249 49       		.uleb128 0x49
 8770 024a 13       		.uleb128 0x13
 8771 024b 3F       		.uleb128 0x3f
 8772 024c 0C       		.uleb128 0xc
 8773 024d 3C       		.uleb128 0x3c
 8774 024e 0C       		.uleb128 0xc
 8775 024f 00       		.byte	0x0
 8776 0250 00       		.byte	0x0
 8777 0251 2A       		.uleb128 0x2a
 8778 0252 21       		.uleb128 0x21
 8779 0253 00       		.byte	0x0
 8780 0254 49       		.uleb128 0x49
 8781 0255 13       		.uleb128 0x13
 8782 0256 2F       		.uleb128 0x2f
 8783 0257 05       		.uleb128 0x5
 8784 0258 00       		.byte	0x0
 8785 0259 00       		.byte	0x0
 8786 025a 2B       		.uleb128 0x2b
 8787 025b 34       		.uleb128 0x34
 8788 025c 00       		.byte	0x0
GAS LISTING /tmp/ccOaNtkH.s 			page 179


 8789 025d 03       		.uleb128 0x3
 8790 025e 0E       		.uleb128 0xe
 8791 025f 3A       		.uleb128 0x3a
 8792 0260 0B       		.uleb128 0xb
 8793 0261 3B       		.uleb128 0x3b
 8794 0262 05       		.uleb128 0x5
 8795 0263 49       		.uleb128 0x49
 8796 0264 13       		.uleb128 0x13
 8797 0265 02       		.uleb128 0x2
 8798 0266 0A       		.uleb128 0xa
 8799 0267 00       		.byte	0x0
 8800 0268 00       		.byte	0x0
 8801 0269 2C       		.uleb128 0x2c
 8802 026a 34       		.uleb128 0x34
 8803 026b 00       		.byte	0x0
 8804 026c 03       		.uleb128 0x3
 8805 026d 0E       		.uleb128 0xe
 8806 026e 3A       		.uleb128 0x3a
 8807 026f 0B       		.uleb128 0xb
 8808 0270 3B       		.uleb128 0x3b
 8809 0271 05       		.uleb128 0x5
 8810 0272 49       		.uleb128 0x49
 8811 0273 13       		.uleb128 0x13
 8812 0274 3F       		.uleb128 0x3f
 8813 0275 0C       		.uleb128 0xc
 8814 0276 02       		.uleb128 0x2
 8815 0277 0A       		.uleb128 0xa
 8816 0278 00       		.byte	0x0
 8817 0279 00       		.byte	0x0
 8818 027a 00       		.byte	0x0
 8819              		.section	.debug_pubnames,"",@progbits
 8820 0000 3C020000 		.long	0x23c
 8821 0004 0200     		.value	0x2
 8822 0006 00000000 		.long	.Ldebug_info0
 8823 000a FF0B0000 		.long	0xbff
 8824 000e 44010000 		.long	0x144
 8825 0012 68656174 		.string	"heatmap_add_point_with_stamp"
 8825      6D61705F 
 8825      6164645F 
 8825      706F696E 
 8825      745F7769 
 8826 002f 37020000 		.long	0x237
 8827 0033 68656174 		.string	"heatmap_add_point"
 8827      6D61705F 
 8827      6164645F 
 8827      706F696E 
 8827      7400
 8828 0045 78020000 		.long	0x278
 8829 0049 68656174 		.string	"heatmap_add_weighted_point_with_stamp"
 8829      6D61705F 
 8829      6164645F 
 8829      77656967 
 8829      68746564 
 8830 006f 55030000 		.long	0x355
 8831 0073 68656174 		.string	"heatmap_add_weighted_point"
 8831      6D61705F 
 8831      6164645F 
GAS LISTING /tmp/ccOaNtkH.s 			page 180


 8831      77656967 
 8831      68746564 
 8832 008e D3030000 		.long	0x3d3
 8833 0092 68656174 		.string	"heatmap_colorscheme_free"
 8833      6D61705F 
 8833      636F6C6F 
 8833      72736368 
 8833      656D655F 
 8834 00ab 09040000 		.long	0x409
 8835 00af 68656174 		.string	"heatmap_stamp_free"
 8835      6D61705F 
 8835      7374616D 
 8835      705F6672 
 8835      656500
 8836 00c2 3E040000 		.long	0x43e
 8837 00c6 68656174 		.string	"heatmap_free"
 8837      6D61705F 
 8837      66726565 
 8837      00
 8838 00d3 6B040000 		.long	0x46b
 8839 00d7 68656174 		.string	"heatmap_colorscheme_load"
 8839      6D61705F 
 8839      636F6C6F 
 8839      72736368 
 8839      656D655F 
 8840 00f0 D5040000 		.long	0x4d5
 8841 00f4 68656174 		.string	"heatmap_render_saturated_to"
 8841      6D61705F 
 8841      72656E64 
 8841      65725F73 
 8841      61747572 
 8842 0110 B8050000 		.long	0x5b8
 8843 0114 68656174 		.string	"heatmap_render_to"
 8843      6D61705F 
 8843      72656E64 
 8843      65725F74 
 8843      6F00
 8844 0126 01060000 		.long	0x601
 8845 012a 68656174 		.string	"heatmap_render_default_to"
 8845      6D61705F 
 8845      72656E64 
 8845      65725F64 
 8845      65666175 
 8846 0144 3F060000 		.long	0x63f
 8847 0148 68656174 		.string	"heatmap_stamp_init"
 8847      6D61705F 
 8847      7374616D 
 8847      705F696E 
 8847      697400
 8848 015b 94060000 		.long	0x694
 8849 015f 68656174 		.string	"heatmap_stamp_new_with"
 8849      6D61705F 
 8849      7374616D 
 8849      705F6E65 
 8849      775F7769 
 8850 0176 F5060000 		.long	0x6f5
 8851 017a 68656174 		.string	"heatmap_stamp_gen_nonlinear"
GAS LISTING /tmp/ccOaNtkH.s 			page 181


 8851      6D61705F 
 8851      7374616D 
 8851      705F6765 
 8851      6E5F6E6F 
 8852 0196 DB070000 		.long	0x7db
 8853 019a 68656174 		.string	"heatmap_stamp_gen"
 8853      6D61705F 
 8853      7374616D 
 8853      705F6765 
 8853      6E00
 8854 01ac 0C080000 		.long	0x80c
 8855 01b0 68656174 		.string	"heatmap_stamp_load"
 8855      6D61705F 
 8855      7374616D 
 8855      705F6C6F 
 8855      616400
 8856 01c3 6D080000 		.long	0x86d
 8857 01c7 68656174 		.string	"heatmap_init"
 8857      6D61705F 
 8857      696E6974 
 8857      00
 8858 01d4 B5080000 		.long	0x8b5
 8859 01d8 68656174 		.string	"heatmap_new"
 8859      6D61705F 
 8859      6E657700 
 8860 01e4 5B0A0000 		.long	0xa5b
 8861 01e8 68656174 		.string	"heatmap_add_points_omp_with_stamp"
 8861      6D61705F 
 8861      6164645F 
 8861      706F696E 
 8861      74735F6F 
 8862 020a 0E0B0000 		.long	0xb0e
 8863 020e 68656174 		.string	"heatmap_add_points_omp"
 8863      6D61705F 
 8863      6164645F 
 8863      706F696E 
 8863      74735F6F 
 8864 0225 E70B0000 		.long	0xbe7
 8865 0229 68656174 		.string	"heatmap_cs_default"
 8865      6D61705F 
 8865      63735F64 
 8865      65666175 
 8865      6C7400
 8866 023c 00000000 		.long	0x0
 8867              		.section	.debug_pubtypes,"",@progbits
 8868 0000 68000000 		.long	0x68
 8869 0004 0200     		.value	0x2
 8870 0006 00000000 		.long	.Ldebug_info0
 8871 000a FF0B0000 		.long	0xbff
 8872 000e 34000000 		.long	0x34
 8873 0012 73697A65 		.string	"size_t"
 8873      5F7400
 8874 0019 96000000 		.long	0x96
 8875 001d 68656174 		.string	"heatmap_t"
 8875      6D61705F 
 8875      7400
 8876 0027 CA000000 		.long	0xca
GAS LISTING /tmp/ccOaNtkH.s 			page 182


 8877 002b 68656174 		.string	"heatmap_stamp_t"
 8877      6D61705F 
 8877      7374616D 
 8877      705F7400 
 8878 003b 08010000 		.long	0x108
 8879 003f 68656174 		.string	"heatmap_colorscheme_t"
 8879      6D61705F 
 8879      636F6C6F 
 8879      72736368 
 8879      656D655F 
 8880 0055 DE090000 		.long	0x9de
 8881 0059 2E6F6D70 		.string	".omp_data_s.20"
 8881      5F646174 
 8881      615F732E 
 8881      323000
 8882 0068 00000000 		.long	0x0
 8883              		.section	.debug_aranges,"",@progbits
 8884 0000 2C000000 		.long	0x2c
 8885 0004 0200     		.value	0x2
 8886 0006 00000000 		.long	.Ldebug_info0
 8887 000a 08       		.byte	0x8
 8888 000b 00       		.byte	0x0
 8889 000c 0000     		.value	0x0
 8890 000e 0000     		.value	0x0
 8891 0010 00000000 		.quad	.Ltext0
 8891      00000000 
 8892 0018 3C090000 		.quad	.Letext0-.Ltext0
 8892      00000000 
 8893 0020 00000000 		.quad	0x0
 8893      00000000 
 8894 0028 00000000 		.quad	0x0
 8894      00000000 
 8895              		.section	.debug_ranges,"",@progbits
 8896              	.Ldebug_ranges0:
 8897 0000 24000000 		.quad	.LBB2-.Ltext0
 8897      00000000 
 8898 0008 0F010000 		.quad	.LBE2-.Ltext0
 8898      00000000 
 8899 0010 1A010000 		.quad	.LBB5-.Ltext0
 8899      00000000 
 8900 0018 25010000 		.quad	.LBE5-.Ltext0
 8900      00000000 
 8901 0020 00000000 		.quad	0x0
 8901      00000000 
 8902 0028 00000000 		.quad	0x0
 8902      00000000 
 8903 0030 82000000 		.quad	.LBB4-.Ltext0
 8903      00000000 
 8904 0038 85000000 		.quad	.LBE4-.Ltext0
 8904      00000000 
 8905 0040 9C000000 		.quad	.LBB3-.Ltext0
 8905      00000000 
 8906 0048 03010000 		.quad	.LBE3-.Ltext0
 8906      00000000 
 8907 0050 00000000 		.quad	0x0
 8907      00000000 
 8908 0058 00000000 		.quad	0x0
GAS LISTING /tmp/ccOaNtkH.s 			page 183


 8908      00000000 
 8909 0060 64010000 		.quad	.LBB6-.Ltext0
 8909      00000000 
 8910 0068 53020000 		.quad	.LBE6-.Ltext0
 8910      00000000 
 8911 0070 5E020000 		.quad	.LBB9-.Ltext0
 8911      00000000 
 8912 0078 69020000 		.quad	.LBE9-.Ltext0
 8912      00000000 
 8913 0080 00000000 		.quad	0x0
 8913      00000000 
 8914 0088 00000000 		.quad	0x0
 8914      00000000 
 8915 0090 C2010000 		.quad	.LBB8-.Ltext0
 8915      00000000 
 8916 0098 C5010000 		.quad	.LBE8-.Ltext0
 8916      00000000 
 8917 00a0 DC010000 		.quad	.LBB7-.Ltext0
 8917      00000000 
 8918 00a8 47020000 		.quad	.LBE7-.Ltext0
 8918      00000000 
 8919 00b0 00000000 		.quad	0x0
 8919      00000000 
 8920 00b8 00000000 		.quad	0x0
 8920      00000000 
 8921 00c0 C8030000 		.quad	.LBB11-.Ltext0
 8921      00000000 
 8922 00c8 E8030000 		.quad	.LBE11-.Ltext0
 8922      00000000 
 8923 00d0 3C040000 		.quad	.LBB15-.Ltext0
 8923      00000000 
 8924 00d8 90040000 		.quad	.LBE15-.Ltext0
 8924      00000000 
 8925 00e0 31040000 		.quad	.LBB14-.Ltext0
 8925      00000000 
 8926 00e8 38040000 		.quad	.LBE14-.Ltext0
 8926      00000000 
 8927 00f0 24040000 		.quad	.LBB13-.Ltext0
 8927      00000000 
 8928 00f8 29040000 		.quad	.LBE13-.Ltext0
 8928      00000000 
 8929 0100 10040000 		.quad	.LBB12-.Ltext0
 8929      00000000 
 8930 0108 1C040000 		.quad	.LBE12-.Ltext0
 8930      00000000 
 8931 0110 00000000 		.quad	0x0
 8931      00000000 
 8932 0118 00000000 		.quad	0x0
 8932      00000000 
 8933 0120 EF050000 		.quad	.LBB17-.Ltext0
 8933      00000000 
 8934 0128 00060000 		.quad	.LBE17-.Ltext0
 8934      00000000 
 8935 0130 68060000 		.quad	.LBB20-.Ltext0
 8935      00000000 
 8936 0138 6D060000 		.quad	.LBE20-.Ltext0
 8936      00000000 
GAS LISTING /tmp/ccOaNtkH.s 			page 184


 8937 0140 61060000 		.quad	.LBB19-.Ltext0
 8937      00000000 
 8938 0148 65060000 		.quad	.LBE19-.Ltext0
 8938      00000000 
 8939 0150 29060000 		.quad	.LBB18-.Ltext0
 8939      00000000 
 8940 0158 5D060000 		.quad	.LBE18-.Ltext0
 8940      00000000 
 8941 0160 00000000 		.quad	0x0
 8941      00000000 
 8942 0168 00000000 		.quad	0x0
 8942      00000000 
 8943              		.section	.debug_str,"MS",@progbits,1
 8944              	.LASF8:
 8945 0000 6E636F6C 		.string	"ncolors"
 8945      6F727300 
 8946              	.LASF4:
 8947 0008 73697A65 		.string	"size_t"
 8947      5F7400
 8948              	.LASF58:
 8949 000f 6D697865 		.string	"mixed_data"
 8949      645F6461 
 8949      746100
 8950              	.LASF30:
 8951 001a 68656174 		.string	"heatmap_colorscheme_load"
 8951      6D61705F 
 8951      636F6C6F 
 8951      72736368 
 8951      656D655F 
 8952              	.LASF16:
 8953 0033 6C6F6E67 		.string	"long long unsigned int"
 8953      206C6F6E 
 8953      6720756E 
 8953      7369676E 
 8953      65642069 
 8954              	.LASF23:
 8955 004a 68656174 		.string	"heatmap_add_weighted_point_with_stamp"
 8955      6D61705F 
 8955      6164645F 
 8955      77656967 
 8955      68746564 
 8956              	.LASF38:
 8957 0070 68656174 		.string	"heatmap_render_default_to"
 8957      6D61705F 
 8957      72656E64 
 8957      65725F64 
 8957      65666175 
 8958              	.LASF60:
 8959 008a 68656174 		.string	"heatmap_cs_default"
 8959      6D61705F 
 8959      63735F64 
 8959      65666175 
 8959      6C7400
 8960              	.LASF11:
 8961 009d 6C6F6E67 		.string	"long long int"
 8961      206C6F6E 
 8961      6720696E 
GAS LISTING /tmp/ccOaNtkH.s 			page 185


 8961      7400
 8962              	.LASF13:
 8963 00ab 7369676E 		.string	"signed char"
 8963      65642063 
 8963      68617200 
 8964              	.LASF50:
 8965 00b7 6C6F6361 		.string	"local_heatmap"
 8965      6C5F6865 
 8965      61746D61 
 8965      7000
 8966              	.LASF34:
 8967 00c5 636F6C6F 		.string	"colorbuf"
 8967      72627566 
 8967      00
 8968              	.LASF0:
 8969 00ce 6C6F6E67 		.string	"long int"
 8969      20696E74 
 8969      00
 8970              	.LASF62:
 8971 00d7 68656174 		.string	"heatmap_block.c"
 8971      6D61705F 
 8971      626C6F63 
 8971      6B2E6300 
 8972              	.LASF39:
 8973 00e7 68656174 		.string	"heatmap_stamp_init"
 8973      6D61705F 
 8973      7374616D 
 8973      705F696E 
 8973      697400
 8974              	.LASF17:
 8975 00fa 646F7562 		.string	"double"
 8975      6C6500
 8976              	.LASF27:
 8977 0101 68656174 		.string	"heatmap_stamp_free"
 8977      6D61705F 
 8977      7374616D 
 8977      705F6672 
 8977      656500
 8978              	.LASF19:
 8979 0114 6C696E65 		.string	"line"
 8979      00
 8980              	.LASF10:
 8981 0119 68656174 		.string	"heatmap_colorscheme_t"
 8981      6D61705F 
 8981      636F6C6F 
 8981      72736368 
 8981      656D655F 
 8982              	.LASF18:
 8983 012f 7374616D 		.string	"stamp"
 8983      7000
 8984              	.LASF36:
 8985 0135 636F6C6F 		.string	"colorline"
 8985      726C696E 
 8985      6500
 8986              	.LASF3:
 8987 013f 756E7369 		.string	"unsigned int"
 8987      676E6564 
GAS LISTING /tmp/ccOaNtkH.s 			page 186


 8987      20696E74 
 8987      00
 8988              	.LASF56:
 8989 014c 7374616D 		.string	"stamp_default_4_data"
 8989      705F6465 
 8989      6661756C 
 8989      745F345F 
 8989      64617461 
 8990              	.LASF1:
 8991 0161 6C6F6E67 		.string	"long unsigned int"
 8991      20756E73 
 8991      69676E65 
 8991      6420696E 
 8991      7400
 8992              	.LASF45:
 8993 0173 68656174 		.string	"heatmap_stamp_gen"
 8993      6D61705F 
 8993      7374616D 
 8993      705F6765 
 8993      6E00
 8994              	.LASF52:
 8995 0185 6E756D5F 		.string	"num_points"
 8995      706F696E 
 8995      747300
 8996              	.LASF57:
 8997 0190 7374616D 		.string	"stamp_default_4"
 8997      705F6465 
 8997      6661756C 
 8997      745F3400 
 8998              	.LASF40:
 8999 01a0 64617461 		.string	"data"
 8999      00
 9000              	.LASF12:
 9001 01a5 73686F72 		.string	"short unsigned int"
 9001      7420756E 
 9001      7369676E 
 9001      65642069 
 9001      6E7400
 9002              	.LASF64:
 9003 01b8 6C696E65 		.string	"linear_dist"
 9003      61725F64 
 9003      69737400 
 9004              	.LASF35:
 9005 01c4 6275666C 		.string	"bufline"
 9005      696E6500 
 9006              	.LASF24:
 9007 01cc 68656174 		.string	"heatmap_add_weighted_point"
 9007      6D61705F 
 9007      6164645F 
 9007      77656967 
 9007      68746564 
 9008              	.LASF55:
 9009 01e7 68656174 		.string	"heatmap_add_points_omp"
 9009      6D61705F 
 9009      6164645F 
 9009      706F696E 
 9009      74735F6F 
GAS LISTING /tmp/ccOaNtkH.s 			page 187


 9010              	.LASF47:
 9011 01fe 636F7079 		.string	"copy"
 9011      00
 9012              	.LASF51:
 9013 0203 626C6F63 		.string	"block_length"
 9013      6B5F6C65 
 9013      6E677468 
 9013      00
 9014              	.LASF21:
 9015 0210 68656174 		.string	"heatmap_add_point_with_stamp"
 9015      6D61705F 
 9015      6164645F 
 9015      706F696E 
 9015      745F7769 
 9016              	.LASF63:
 9017 022d 2F686F6D 		.string	"/home/hshu1/15618/project/15618fp/heatmap"
 9017      652F6873 
 9017      6875312F 
 9017      31353631 
 9017      382F7072 
 9018              	.LASF54:
 9019 0257 68656174 		.string	"heatmap_add_points_omp_with_stamp"
 9019      6D61705F 
 9019      6164645F 
 9019      706F696E 
 9019      74735F6F 
 9020              	.LASF7:
 9021 0279 636F6C6F 		.string	"colors"
 9021      727300
 9022              	.LASF20:
 9023 0280 7374616D 		.string	"stampline"
 9023      706C696E 
 9023      6500
 9024              	.LASF2:
 9025 028a 666C6F61 		.string	"float"
 9025      7400
 9026              	.LASF31:
 9027 0290 68656174 		.string	"heatmap_render_saturated_to"
 9027      6D61705F 
 9027      72656E64 
 9027      65725F73 
 9027      61747572 
 9028              	.LASF22:
 9029 02ac 68656174 		.string	"heatmap_add_point"
 9029      6D61705F 
 9029      6164645F 
 9029      706F696E 
 9029      7400
 9030              	.LASF46:
 9031 02be 68656174 		.string	"heatmap_stamp_load"
 9031      6D61705F 
 9031      7374616D 
 9031      705F6C6F 
 9031      616400
 9032              	.LASF9:
 9033 02d1 756E7369 		.string	"unsigned char"
 9033      676E6564 
GAS LISTING /tmp/ccOaNtkH.s 			page 188


 9033      20636861 
 9033      7200
 9034              	.LASF14:
 9035 02df 73686F72 		.string	"short int"
 9035      7420696E 
 9035      7400
 9036              	.LASF65:
 9037 02e9 68656174 		.string	"heatmap_add_points_omp_with_stamp.omp_fn.0"
 9037      6D61705F 
 9037      6164645F 
 9037      706F696E 
 9037      74735F6F 
 9038              	.LASF44:
 9039 0314 636C616D 		.string	"clamped_ds"
 9039      7065645F 
 9039      647300
 9040              	.LASF29:
 9041 031f 696E5F63 		.string	"in_colors"
 9041      6F6C6F72 
 9041      7300
 9042              	.LASF26:
 9043 0329 68656174 		.string	"heatmap_colorscheme_free"
 9043      6D61705F 
 9043      636F6C6F 
 9043      72736368 
 9043      656D655F 
 9044              	.LASF48:
 9045 0342 68656174 		.string	"heatmap_init"
 9045      6D61705F 
 9045      696E6974 
 9045      00
 9046              	.LASF61:
 9047 034f 474E5520 		.string	"GNU C 4.4.7 20120313 (Red Hat 4.4.7-4)"
 9047      4320342E 
 9047      342E3720 
 9047      32303132 
 9047      30333133 
 9048              	.LASF15:
 9049 0376 63686172 		.string	"char"
 9049      00
 9050              	.LASF28:
 9051 037b 68656174 		.string	"heatmap_free"
 9051      6D61705F 
 9051      66726565 
 9051      00
 9052              	.LASF66:
 9053 0388 2E6F6D70 		.string	".omp_data_i"
 9053      5F646174 
 9053      615F6900 
 9054              	.LASF6:
 9055 0394 68656174 		.string	"heatmap_stamp_t"
 9055      6D61705F 
 9055      7374616D 
 9055      705F7400 
 9056              	.LASF49:
 9057 03a4 68656174 		.string	"heatmap_new"
 9057      6D61705F 
GAS LISTING /tmp/ccOaNtkH.s 			page 189


 9057      6E657700 
 9058              	.LASF25:
 9059 03b0 64697374 		.string	"dist"
 9059      00
 9060              	.LASF37:
 9061 03b5 68656174 		.string	"heatmap_render_to"
 9061      6D61705F 
 9061      72656E64 
 9061      65725F74 
 9061      6F00
 9062              	.LASF42:
 9063 03c7 68656174 		.string	"heatmap_stamp_gen_nonlinear"
 9063      6D61705F 
 9063      7374616D 
 9063      705F6765 
 9063      6E5F6E6F 
 9064              	.LASF67:
 9065 03e3 2E6F6D70 		.string	".omp_data_s.20"
 9065      5F646174 
 9065      615F732E 
 9065      323000
 9066              	.LASF41:
 9067 03f2 68656174 		.string	"heatmap_stamp_new_with"
 9067      6D61705F 
 9067      7374616D 
 9067      705F6E65 
 9067      775F7769 
 9068              	.LASF5:
 9069 0409 68656174 		.string	"heatmap_t"
 9069      6D61705F 
 9069      7400
 9070              	.LASF33:
 9071 0413 73617475 		.string	"saturation"
 9071      72617469 
 9071      6F6E00
 9072              	.LASF32:
 9073 041e 636F6C6F 		.string	"colorscheme"
 9073      72736368 
 9073      656D6500 
 9074              	.LASF43:
 9075 042a 64697374 		.string	"distshape"
 9075      73686170 
 9075      6500
 9076              	.LASF53:
 9077 0434 73746172 		.string	"start"
 9077      7400
 9078              	.LASF59:
 9079 043a 63735F73 		.string	"cs_spectral_mixed"
 9079      70656374 
 9079      72616C5F 
 9079      6D697865 
 9079      6400
 9080              		.ident	"GCC: (GNU) 4.4.7 20120313 (Red Hat 4.4.7-4)"
 9081              		.section	.note.GNU-stack,"",@progbits
