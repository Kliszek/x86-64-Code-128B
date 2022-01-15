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
	mov	eax, 0				;return 0

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