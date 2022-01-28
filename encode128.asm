#=====================================================================
# ECOAR - example Intel x86 assembly program
#
# Author:      Jakub Kliszko
# Date:        2022-xx-xx
# Description: Generate BMP file with Code 128B barcode of a given word
#
#=====================================================================


		.text
		.global	encode128

encode128:
	push rbp
	mov	rbp, rsp

	mov r8, rdi		#destination
	mov r9, rsi		#bar width
	mov r10, rdx	#input address
	mov r11, rcx	#code table
	
	call analyze_input
	call generate_header
	call paint_white

	call generate_barcode	
	mov	rax, 0			#return 0

	mov rcx, 1
exit:					#ecx indicates how many values should be popped
	pop	rbp
	loop exit
	ret

generate_header:
	push rax

	mov rax, r8
	mov [rax], WORD PTR 0x4d42
	mov [rax+2], DWORD PTR 90054
	mov [rax+6], DWORD PTR 0
	mov [rax+10], DWORD PTR 54

	add rax, 14
	mov [rax], DWORD PTR 40
	mov [rax+4], DWORD PTR 600
	mov [rax+8], DWORD PTR 50
	mov [rax+12], WORD PTR 1
	mov [rax+14], WORD PTR 24
	mov [rax+16], DWORD PTR 0
	mov [rax+20], DWORD PTR 90000
	mov [rax+24], DWORD PTR 2835
	mov [rax+28], DWORD PTR 2835
	mov [rax+32], DWORD PTR 0
	mov [rax+36], DWORD PTR 0

	pop rax
	ret


analyze_input:
	push rbx
	push rax
	push rcx
	push rdx

	mov rbx, r10
	mov rdx, 0
	mov rcx, 6				#pop six values in case of error (4 from this function, return address and the original stack base pointer)

  start_analyzing_input:
	cmp BYTE PTR [rbx], 0
	je quit_analyzing_input
	cmp BYTE PTR [rbx], 10		#LF
	je quit_analyzing_input	
	cmp BYTE PTR [rbx], 13		#CR
	je quit_analyzing_input	

	mov rax, 2				#code error 2 - wrong characters in the string

	cmp BYTE PTR [rbx], 32
	jl exit
	cmp BYTE PTR [rbx], 127
	jg exit

	inc rbx
	inc rdx
	jmp	start_analyzing_input

  quit_analyzing_input:
	mov rax, 1				#code error 1 - the string is too long

	imul rdx, 11			#one symbol = 11 pixels
	add rdx, 55				#quiet zone + start symbol + checksum + stop symbol + quiet zone
	imul rdx, r9			#multiplying by bar width
	cmp rdx, 600			#comparing the image length to maximal length (600 pixels)
	jg exit

	pop rdx
	pop rcx
	pop rax
	pop rbx
	ret

paint_white:
	push rax
	push rbx

	mov rax, r8
	add rax, 54
	mov rbx, rax
	add rbx, 90000
  paint_white_loop:
	mov [rax], DWORD PTR 0xffffffff
	add rax, 4
	cmp rax, rbx
	jl paint_white_loop
	
	pop rbx
	pop rax
	ret

get_barcode:				#ebx should contain the character index
	shl rbx, 3
	add rbx, r11
	ret
	
paint_bar:					#edx should contain the pixel offset from lhs
	push rbx
	push rdx

	mov rbx, r8
	add rbx, 54
	imul rdx, 3
	add rbx, rdx
	mov rdx, rbx
	add rdx, 90000			#edx contains the address of first pixel to paint
  paint_loop:
	mov [rbx], BYTE PTR 0
	mov [rbx+1], BYTE PTR 0
	mov [rbx+2], BYTE PTR 0
	add rbx, 1800
	cmp rbx, rdx
	jl paint_loop

	pop rdx
	pop rbx
	ret

paint_char:					#ebx should contain the character code / edx should contain the pixel offset from lhs
	push rax
	push rbx

	call get_barcode

  whole_bar:
	movzx rax, BYTE PTR [rbx]
	cmp rax, 0
	je quit_painting_char

	imul rax, r9			#al * r9 (= how many 1-pixel bars to paint) is stored in AX!
	
	add rax, rdx				#eax contains (the first) offset, which should not be painted

  black_part:
	call paint_bar
	inc rdx
	cmp rdx, rax
	
	jl black_part

	movzx rax, BYTE PTR [rbx+1]
	cmp rax, 0
	je quit_painting_char
	imul rax, r9
	add rdx, rax
	add rbx, 2
	jmp whole_bar

  quit_painting_char:

	pop rbx
	pop rax
	ret

generate_barcode:
	push rbx
	push rax
	push rcx
	push rdx

	mov rbx, 104			#START_B symbol
	mov rdx, 10
	imul rdx, r9		#offset (quiet zone)

	call paint_char

	mov rcx, 0
	mov rax, 104			#checksum

  start_generation:
	mov rbx, r10
	movzx rbx, BYTE PTR [rbx+rcx]

	cmp rbx, 0
	je finish_generating
	cmp rbx, 10		#LF
	je finish_generating
	cmp rbx, 13		#CR
	je finish_generating

	sub rbx, 32

	call paint_char

	inc rcx
	imul rbx, rcx
	add rax, rbx		#update checksum

	jmp	start_generation

  finish_generating:

	mov bl, 103			#ebx will be reassigned in a moment, it can hold the divider
	div bl				#checksum = reminder of eax/103

	movzx ebx, ah		#automatically zero extend to rbx
	
	call paint_char

	mov rbx, 106
	call paint_char

	pop rdx
	pop rcx
	pop rax
	pop rbx
	ret
