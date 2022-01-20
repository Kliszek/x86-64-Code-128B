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
	push	ebp
	mov	ebp, esp

	mov eax, DWORD [ebp+8]
	mov [DEST], DWORD eax
	mov eax, DWORD [ebp+12]
	mov [BWTH], DWORD eax
	mov eax, DWORD [ebp+16]
	mov [TEXT], DWORD eax


	call load_codes
	call generate_header
	mov	eax, 0			;return 0

	pop	ebp
	ret

load_codes:
	mov eax, 5
	mov ebx, CDFILE
	mov ecx, 0				;O_RDONLY flag
	mov edx, 0444o			;readable by everyone permissions
	int 80h
	
	mov ebx, eax
	mov eax, 3
	mov ecx, CODES
	mov edx, 855
	int 80h

	ret

generate_header:
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
	ret