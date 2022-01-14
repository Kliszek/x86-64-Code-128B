;=====================================================================
; ECOAR - example Intel x86 assembly program
;
; Author:      Jakub Kliszko
; Date:        2022-xx-xx
; Description: Generate BMP file with Code 128B barcode of a given word
;
;=====================================================================

section	.text
global	encode128

encode128:
	push	ebp
	mov	ebp, esp

	mov	eax, 0			;return 0
	pop	ebp
	ret