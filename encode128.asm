;=====================================================================
; ECOAR - example Intel x86 assembly program
;
; Author:      Jakub Kliszko
; Date:        2022-xx-xx
; Description: Generate BMP file with Code 128B barcode of a given word
;
;=====================================================================

section .data
DEST	dd 0
BWTH	dd 0
TEXT	dd 0
CDFILE	db 'code128b.bin',0
CODES times 856 db 0


section	.text
global	encode128

encode128:
	push ebp
	mov	ebp, esp

	mov eax, DWORD [ebp+8]
	mov [DEST], DWORD eax
	mov eax, DWORD [ebp+12]
	mov [BWTH], DWORD eax
	mov eax, DWORD [ebp+16]
	mov [TEXT], DWORD eax


	call analyze_input
	call load_codes
	call generate_header
	call paint_white
	mov edx, 30
	mov ebx, 1

	call generate_barcode	
	mov	eax, 0			;return 0

	mov ecx, 1
exit:					;ecx indicates how many values should be popped
	pop	ebp
	loop exit
	ret

load_codes:
	push eax
	push ebx
	push ecx
	push edx

	mov eax, 5
	mov ebx, CDFILE
	mov ecx, 0				;O_RDONLY flag
	mov edx, 0444o			;readable by everyone permissions
	int 80h

	cmp eax, 0				;checking if there was an error opening the file
	mov ecx, 3				;if error occurs, contitionally move this to eax
	cmovle eax, ecx
	mov ecx, 6				;popping 6 values in case of error
	jl exit
	
	mov ebx, eax
	mov eax, 3
	mov ecx, CODES
	mov edx, 855
	int 80h

	cmp eax, 0				;checking if there was an error reading the file
	mov eax, 4
	mov ecx, 6
	jl exit

	mov eax, 6				;closing the file, ebx still contains the descriptor
	int 80h

	mov ecx, 6
	cmp eax, 0				;checking if there was an error closing the file
	mov eax, 3
	jne exit

	pop edx
	pop ecx
	pop ebx
	pop eax
	ret

generate_header:
	push eax

	mov eax, [DEST]
	mov [eax], WORD 0x4d42
	mov [eax+2], DWORD 90054
	mov [eax+6], DWORD 0
	mov [eax+10], DWORD 54

	add eax, 14
	mov [eax], DWORD 40
	mov [eax+4], DWORD 600
	mov [eax+8], DWORD 50
	mov [eax+12], WORD 1
	mov [eax+14], WORD 24
	mov [eax+16], DWORD 0
	mov [eax+20], DWORD 90000
	mov [eax+24], DWORD 2835
	mov [eax+28], DWORD 2835
	mov [eax+32], DWORD 0
	mov [eax+36], DWORD 0

	pop eax
	ret


analyze_input:
	push ebx
	push eax
	push ecx
	push edx

	mov ebx, [TEXT]
	mov edx, 0
	mov ecx, 6				;pop six values in case of error (4 from this function, return address and the original stack base pointer)

  start_analyzing_input:
	cmp BYTE [ebx], 0
	je quit_analyzing_input
	cmp BYTE [ebx], 10		;LF
	je quit_analyzing_input	
	cmp BYTE [ebx], 13		;CR
	je quit_analyzing_input	

	mov eax, 2				;code error 2 - wrong characters in the string

	cmp BYTE [ebx], 32
	jl exit
	cmp BYTE [ebx], 127
	jg exit

	inc ebx
	inc edx
	jmp	start_analyzing_input

  quit_analyzing_input:
	mov eax, 1				;code error 1 - the string is too long

	imul edx, 11			;one symbol = 11 pixels
	add edx, 55				;quiet zone + start symbol + checksum + stop symbol + quiet zone
	imul edx, [BWTH]		;multiplying by bar width
	cmp edx, 600			;comparing the image length to maximal length (600 pixels)
	jg exit

	pop edx
	pop ecx
	pop eax
	pop ebx
	ret

paint_white:
	push eax
	push ebx

	mov eax, [DEST]
	add eax, 54
	mov ebx, eax
	add ebx, 90000
  paint_white_loop:
	mov [eax], DWORD 0xffffffff
	add eax, 4
	cmp eax, ebx
	jl paint_white_loop
	
	pop ebx
	pop eax
	ret

get_barcode:				;ebx should contain the character index
	shl ebx, 3
	add ebx, CODES
	ret
	
paint_bar:					;edx should contain the pixel offset from lhs
	push ebx
	push edx

	mov ebx, [DEST]
	add ebx, 54
	imul edx, 3
	add ebx, edx
	mov edx, ebx
	add edx, 90000			;edx contains the address of first pixel to paint
  paint_loop:
	mov [ebx], BYTE 0
	mov [ebx+1], BYTE 0
	mov [ebx+2], BYTE 0
	add ebx, 1800
	cmp ebx, edx
	jl paint_loop

	pop edx
	pop ebx
	ret

paint_char:					;ebx should contain the character code / edx should contain the pixel offset from lhs
	push eax
	push ebx

	call get_barcode

  whole_bar:
	movzx eax, BYTE [ebx]
	cmp eax, 0
	je quit_painting_char

	imul eax, [BWTH]			;al * BWTH (= how many 1-pixel bars to paint) is stored in AX!
	
	add eax, edx				;eax contains (the first) offset, which should not be painted

  black_part:
	call paint_bar
	inc edx
	cmp edx, eax
	
	jl black_part

	movzx eax, BYTE [ebx+1]
	cmp eax, 0
	je quit_painting_char
	imul eax, [BWTH]
	add edx, eax
	add ebx, 2
	jmp whole_bar

  quit_painting_char:

	pop ebx
	pop eax
	ret

generate_barcode:
	push ebx
	push eax
	push ecx
	push edx

	mov ebx, 104			;START_B symbol
	mov edx, 10
	imul edx, [BWTH]		;offset (quiet zone)

	call paint_char

	mov ecx, 0
	mov eax, 104			;checksum

  start_generation:
	mov ebx, [TEXT]
	movzx ebx, BYTE [ebx+ecx]

	cmp ebx, 0
	je finish_generating
	cmp ebx, 10		;LF
	je finish_generating
	cmp ebx, 13		;CR
	je finish_generating

	sub ebx, 32

	call paint_char

	inc ecx
	imul ebx, ecx
	add eax, ebx		;update checksum

	jmp	start_generation

  finish_generating:

	mov bl, 103			;ebx will be reassigned in a moment, it can hold the divider
	div bl				;checksum = reminder of eax/103
	movzx ebx, ah
	
	call paint_char

	mov ebx, 106
	call paint_char

	pop edx
	pop ecx
	pop eax
	pop ebx
	ret
