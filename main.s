Stack_Size      EQU      0x00000400

                AREA     STACK, NOINIT, READWRITE, ALIGN=3
__stack_limit
Stack_Mem       SPACE    Stack_Size
__initial_sp

                AREA     RESET, DATA, READONLY
                EXPORT   __Vectors
                EXPORT   __Vectors_End

__Vectors       DCD      __initial_sp                        ;     Top of Stack
                DCD      Reset_Handler                       ;     Reset Handler
                DCD      0                         ; -14 NMI Handler
                DCD      0                   ; -13 Hard Fault Handler
                DCD      0                                   ;     Reserved
                DCD      0                                   ;     Reserved
                DCD      0                                   ;     Reserved
                DCD      0                                   ;     Reserved
                DCD      0                                   ;     Reserved
                DCD      0                                   ;     Reserved
                DCD      0                                   ;     Reserved
                DCD      0                         ;  -5 SVCall Handler
                DCD      0                                   ;     Reserved
                DCD      0                                   ;     Reserved
                DCD      0                      ;  -2 PendSV Handler
                DCD      0                     ;  -1 SysTick Handler

                ; Interrupts
                DCD      Button_Handler                  ;   0 Interrupt 0
                     
__Vectors_End

				AREA     |.text|, CODE, READONLY

; Reset Handler
Reset_Handler   PROC
                EXPORT   Reset_Handler
				ldr		r0,=0xE000E100
				movs	r1, #1
				str		r1,[r0]
				CPSIE	i
				ldr		r0,=__main
				bx		r0
				ENDP


					AREA     button, CODE, READONLY
Button_Handler		PROC
					EXPORT  Button_Handler
					ldr		r0,=0x40010010
					ldr		r1,[r0]
					push	{r4,r5}
					movs	r2,#0xFF
					ands    r1,r1,r2
					; increment random number
					ldr		r2,=random_number
					ldr		r3,[r2]
					adds	r3,r3,#1
					str		r3,[r2]
					
					cmp     r1,#0x04;A button	
					beq		start_game
					;cmp  	r6,#0x00000008 	;B button
					;beq		pause_game
					cmp		r1,#0x40	;left button
					beq		left_button
					cmp		r1,#0x80	;right button
					beq		right_button
					cmp		r1,#0x10	;upper button
					beq		up_button
					b		goto_main

start_game			ldr		r4,=start_flag
					movs	r5,#1
					str		r5,[r4]
					b		goto_main


left_button			movs	r2,#0
left_end_check		ldr		r3,=block_address	; to checking is block achieved left side
					ldr		r3,[r3,r2]			
					lsrs	r3,r3,#2
					ldr		r4,=0xFFF
					ands	r4,r4,r3
take_mod1			cmp		r4,#12				; taking mod to check
					blo		end_of_modulo1		
					subs	r4,r4,#13
					b		take_mod1
end_of_modulo1		cmp		r4,#1
					beq		goto_main
					adds	r2,r2,#0x4
					cmp		r2,#0x10
					bne		left_end_check
					
					ldr		r2,=start_index		; taking start address of the 4x4 matrix
					ldr		r3,[r2]				
					subs	r3,r3,#1			; adding start address of the 4x4 matrix
					str		r3,[r2]
					
					b		keep_prev_block
					
right_button		movs	r2,#0
right_end_check		ldr		r3,=block_address	; to checking is block achieved left side
					ldr		r3,[r3,r2]
					lsrs	r3,r3,#2
					ldr		r4,=0xFFF
					ands	r4,r4,r3
take_mod			cmp		r4,#12
					blo		end_of_modulo		
					subs	r4,r4,#13
					b		take_mod
end_of_modulo		cmp		r4,#10
					beq		goto_main
					adds	r2,r2,#0x4
					cmp		r2,#0x10
					bne		right_end_check


					ldr		r2,=start_index		; taking start address of the 4x4 matrix
					ldr		r3,[r2]
					adds	r3,r3,#1			; adding start address of the 4x4 matrix
					str		r3,[r2]
					
keep_prev_block		movs	r2,#0				; to store the block address before move
store_old_block		ldr 	r3,=block_address
					ldr		r5,[r3,r2]
					ldr		r3,=block_ex_address
					str		r5,[r3,r2]
					adds	r2,r2,#0x4
					cmp		r2,#0x10
					bne		store_old_block
					
					
					
					b		goto_main
up_button			ldr		r2,=block_type
					ldr		r2,[r2]
					ldr		r4,=block_orient
					
					push	{r2,r3,r4}
					movs	r2,#0
right_end_check2	ldr		r3,=block_address
					ldr		r3,[r3,r2]
					lsrs	r3,r3,#2
					ldr		r4,=0xFFF
					ands	r4,r4,r3
take_mod2			cmp		r4,#12
					blo		end_of_modulo2		
					subs	r4,r4,#13
					b		take_mod2
end_of_modulo2		cmp		r4,#10
					beq		goto_main2
					adds	r2,r2,#0x4
					cmp		r2,#0x10
					bne		right_end_check2				
					pop		{r2,r3,r4}
					
					push	{r2,r3,r4}
					movs	r2,#0
left_end_check2		ldr		r3,=block_address
					ldr		r3,[r3,r2]
					lsrs	r3,r3,#2
					ldr		r4,=0xFFF
					ands	r4,r4,r3
take_mod3			cmp		r4,#12
					blo		end_of_modulo3		
					subs	r4,r4,#13
					b		take_mod3
end_of_modulo3		cmp		r4,#1
					beq		goto_main2
					adds	r2,r2,#0x4
					cmp		r2,#0x10
					bne		left_end_check2				
					pop		{r2,r3,r4}
				
uzun_comp			ldr		r3,=uzun_blok
					cmp		r2,r3
					beq		two_orients
					b		z_comp
				
z_comp				ldr		r3,=z_blok
					cmp		r2,r3
					beq		two_orients
					b		ters_z_comp
				
ters_z_comp			ldr		r3,=ters_z_blok
					cmp		r2,r3
					beq		two_orients
					b		l_blok_comp
				
l_blok_comp			ldr		r3,=l_blok
					cmp		r2,r3
					beq		four_orients
					b		ters_l_blok_comp
				
ters_l_blok_comp	ldr		r3,=ters_l_blok
					cmp		r2,r3
					beq		four_orients
					b		garip_blok_comp
				
garip_blok_comp		ldr		r3,=garip_blok
					cmp		r2,r3
					beq		four_orients
					b		goto_main


goto_main2			pop		{r2,r3,r4}			
goto_main			pop		{r4,r5}
					str     r1,[r0]
					bx      lr
				
zeroize				movs	r5,#0
					str		r5,[r4]
					b		keep_prev_block
				
two_orients			ldr		r5,[r4]
					adds	r5,r5,#0x10
					cmp		r5,#0x20
					beq		zeroize
					str		r5,[r4]
					b		keep_prev_block
					
four_orients		ldr		r5,[r4]
					adds	r5,r5,#0x10
					cmp		r5,#0x40
					beq		zeroize
					str		r5,[r4]
					b		keep_prev_block
				
					ENDP
					


					AREA	proje, CODE, READONLY
					EXPORT	__main
					ENTRY
__main				PROC
					
wait				ldr		r0,=start_flag	; wait till the player press the button A
					ldr		r1,[r0]
					cmp		r1,#1
					bne		wait
	
	
	
					ldr		r0,=0xFFFFFFFF
					ldr		r1,=full_array
					ldr		r2,=1456
					ldr		r3,=1508
fill_bottom			str		r0,[r1,r2]	; fill the bottom of the 28x13 matrix in order to check collisions
					adds	r2,r2,#0x4
					cmp		r2,r3
					bne		fill_bottom
					
					
					
					
					
					
					
leave_block			movs	r2,#0
					ldr		r0,=block_ex_address	; to leave the previous blocks at the bottoms
					ldr		r1,=0x2000F000			; dummy address to prevent deleting ex previous blocks
ex_address_clear	str		r1,[r0,r2]				; store dummy address to block ex address pointer
					adds	r2,r2,#0x4
					cmp		r2,#0x10
					bne		ex_address_clear
					
					ldr		r0,=random_number		; take the random number to specify block type (long block,z block etc.)
					ldr		r1,[r0]
take_mod_random		cmp		r1,#6
					blo		end_of_mod_random	
					subs	r1,r1,#6
					b		take_mod_random
end_of_mod_random	ldr		r2,=block_no
					str		r1,[r2]
					adds	r1,r1,#1
					str		r1,[r0]
					

start				ldr		r2,=block_no		; specify the block type accorfing to random number
					ldr		r1,[r2]
					cmp		r1,#0
					bne		z_blok_no
					ldr		r3, =uzun_blok
					b		cont_selected_block
					
z_blok_no			cmp		r1,#1
					bne		ters_z_blok_no
					ldr		r3, =z_blok
					b		cont_selected_block		
					
ters_z_blok_no		cmp		r1,#2
					bne		l_blok_no
					ldr		r3, =ters_z_blok
					b		cont_selected_block				
					
l_blok_no			cmp		r1,#3
					bne		ters_l_blok_no
					ldr		r3, =l_blok
					b		cont_selected_block				
					
ters_l_blok_no		cmp		r1,#4
					bne		garip_blok_no
					ldr		r3, =ters_l_blok
					b		cont_selected_block				

garip_blok_no		cmp		r1,#5
					bne		kare_blok_no
					ldr		r3, =garip_blok
					b		cont_selected_block
					
kare_blok_no		ldr		r3, =kare_blok
					
cont_selected_block	movs	r4,#0				
					ldr		r1,[r3]
					ldr		r1, =block_type
					str		r3,[r1]
					ldr		r1,[r1]
					ldr		r0,=block_orient	; take the orientation
					ldr		r0,[r0]	
					adds	r1,r1,r0			; access the block address according to orientation
					
					ldr		r2, =full_array
					ldr		r0,=start_index		; start index
tekrar				ldr     r3, [r1]        	; take the block matrix single element
					ldr		r5,[r0]				; take the start index
					cmp		r3,#3				; specify the if the simgle element of the which row in the block matrix 
index_comp1			bhi		index_comp2			
					b		block_end
index_comp2			cmp		r3,#7				
					bhi		index_comp3
					adds	r3,r3,#9			; if the block matrix element is 2nd row write to the ram (13-4)
					b		block_end
index_comp3			cmp		r3,#11
					bhi		index_comp4
					adds	r3,r3,#18
					b		block_end
index_comp4			adds	r3,r3,#27			;4x(13-4)
block_end			movs	r6,#0x4				
					adds	r3,r3,#1			; calculating the block write address in ram
					adds	r3,r3,r5			
					muls	r3,r6,r3
					adds	r3,r3,r2
					ldr		r5,=block_address
					str		r3,[r5,r4]				
					ldr		r5,=0xFFFFFFFF
					adds	r1,r1,#0x4
					str		r5,[r3]				; write block to the full array which is 28x13 array
					ldr		r5,=buffer_address	; adding down addresses to memory - will be used in collision check
					adds	r3,r3,#52
					str		r3,[r5,r4]
					adds	r4,r4,#0x4
					cmp		r4,#0x10
					bne		tekrar
					
					
					movs	r2,#0
					movs	r1,#0
clear_old_block2	movs	r0,#0
clear_old_block1	ldr 	r3,=block_ex_address	; clear ex addresses of the block while sliding or moving left or right
					ldr		r4,=block_address		
					ldr		r5,[r3,r1]
					ldr		r6,[r4,r0]
					cmp		r5,r6
					bne		do_not_change_flag		; if the block current address and next address is the same do not clear from ram
					movs	r2,#1
do_not_change_flag	adds	r0,r0,#0x4
					cmp		r0,#0x10
					bne		clear_old_block1
					cmp		r2,#1
					beq		continue_for
					movs	r4,#0
					str		r4,[r5]
continue_for		movs	r2,#0
					adds	r1,r1,#0x4
					cmp		r1,#0x10
					bne		clear_old_block2
					
					
					
					movs	r2,#0
store_old_block1	ldr 	r3,=block_address		; store ex block address
					ldr		r5,[r3,r2]
					ldr		r3,=block_ex_address
					str		r5,[r3,r2]
					adds	r2,r2,#0x4
					cmp		r2,#0x10
					bne		store_old_block1
					
					
					
					movs	r2,#0
					movs	r1,#0
specify_stop2		movs	r0,#0
specify_stop1		ldr 	r3,=buffer_address	; check if the block reached to other blocks
					ldr		r4,=block_address	
					ldr		r5,[r3,r1]
					ldr		r6,[r4,r0]
					cmp		r5,r6
					bne		do_not_change_flag2	; not to clear buffer addresses
					movs	r2,#1				
do_not_change_flag2	adds	r0,r0,#0x4
					cmp		r0,#0x10
					bne		specify_stop1
					cmp		r2,#0
					beq		continue_for2
					ldr		r4,=0x2000FFFF
					str		r4,[r5]
continue_for2		movs	r2,#0
					adds	r1,r1,#0x4
					cmp		r1,#0x10
					bne		specify_stop2
					
					
					
					
					
					movs	r3,#0
					ldr		r0,=buffer_address	; check if the blocks' buffer address is collides with other block or bottom
					ldr		r5,=start_index		; 
					ldr		r4,[r5]
collision_check		ldr		r1,[r0,r3]
					ldr		r1,[r1]
					ldr		r2,=0xFFFFFFFF
					cmp		r1,r2
					beq		stop_adding
					adds	r3,r3,#0x4
					cmp		r3,#0x10
					bne		collision_check
					adds	r4,r4,#13
					b		continue_adding
stop_adding			movs	r4,#5
					str		r4,[r5]
					b		leave_block
continue_adding		str		r4,[r5]
					
					ldr		r0,=0x80000	
delay_part			subs	r0,r0,#1	; a simple delay to slow down the game
					cmp		r0,#0
					bne		delay_part

lcd_part			ldr		r0, =0x40010000
					ldr		r1, =full_array
					adds	r1,r1,#208
					
					movs	r5,#0			; row counter
continue_rendering2	movs	r6,#100			; column counter
					
continue_rendering1 ldr		r3,[r1]			; data in ram
					ldr		r4,=0x0000FFFF	; for the comparison
					ands	r3,r3,r4
					cmp		r3,r4
					bne		write_zero
					ldr		r4,=0xFF00FFFF
					b		next20
write_zero			ldr		r4,=0xFF000000
					
next20				movs	r2,#10			; to specify end of the row
					movs	r7,#10			; to spe
					
					adds	r2,r2,r5
					adds	r7,r7,r6
nr					str		r5,[r0]
nc					str		r6,[r0,#0x4]	;store column
					str		r4,[r0,#0x8]	;store pixel
					adds	r6,r6,#1
					cmp		r6,r7
					bne		nc
					adds	r5,r5,#1
					subs	r6,r6,#10
					cmp		r5,r2
					bne		nr
					
					subs	r5,r5,#10
					adds	r1,r1,#0x4	
					adds	r6,r6,#10
					cmp		r6,#230
					bne		continue_rendering1
					adds	r5,r5,#10
					cmp		r5,#240
					bne		continue_rendering2
					
					
					ldr     r2, =0xFFFF0000
					movs    r3, #0        ;row counter
nr3					str     r3, [r0]       ;store row to row register
					movs    r4, #210       ;col counter
nc3					str     r4, [r0, #0x4] ;store col to col register  
					str     r2, [r0, #0x8] ;store the pixel to pixel register
					adds    r4, r4, #1     ;increment the col counter
					cmp     r4, #215       ;check if we reached end of row
					bne     nc3
					adds    r3, r3, #1     ;increment the row counter
					cmp     r3, #240       ;check if we reached end of image
					bne     nr3
					

					ldr     r2, =0xFFFF0000
					movs    r3, #0        ;row counter
nr2					str     r3, [r0]       ;store row to row register
					movs    r4, #105       ;col counter
nc2					str     r4, [r0, #0x4] ;store col to col register  
					str     r2, [r0, #0x8] ;store the pixel to pixel register
					adds    r4, r4, #1     ;increment the col counter
					cmp     r4, #110       ;check if we reached end of row
					bne     nc2
					adds    r3, r3, #1     ;increment the row counter
					cmp     r3, #240       ;check if we reached end of image
					bne     nr2


					movs    r2, #1
					str     r2, [r0, #0xc] ;refresh screen
					
					movs    r2, #2
					str     r2, [r0, #0xc] ;clear screen
					
					
					
					
					
					b		start
					
stop    			b       stop		
uzun_blok			DCD		1,5,9,13,4,5,6,7
z_blok				DCD		4,5,9,10,2,5,6,9
ters_z_blok			DCD		6,7,9,10,1,5,6,10
l_blok				DCD		1,2,6,10,5,6,7,9,2,6,10,11,3,5,6,7
ters_l_blok			DCD		1,2,5,9,0,4,5,6,1,5,9,8,4,5,6,10
garip_blok			DCD		1,4,5,6,1,4,5,9,4,5,6,9,1,5,6,9
kare_blok			DCD		1,2,5,6
					ENDP

					AREA myData, DATA, READWRITE
					ALIGN
full_array			SPACE	12064
start_index			DCD		0
buffer_address 		DCD		0,0,0,0
block_address		DCD		0,0,0,0
block_ex_address 	DCD		0,0,0,0
block_type			DCD		0
block_orient		DCD		0
random_number		DCD		0
start_flag			DCD		0
block_no			DCD		0				
					END

