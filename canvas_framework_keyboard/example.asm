.586
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern fprintf: proc
extern fscanf: proc
extern fopen: proc
extern fclose:proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "A-maze-ing",0
area_width EQU 1000
area_height EQU 580
area DD 0

prima_tasta DD 1
max_time EQU 120
times_up dd 0

format_integer db "%d", 0
write_mode db "w", 0
read_mode db "r", 0
file_name db "highscores.txt", 0
file_ptr DD 0

X dd 0
minim dd 120

counter DD 0 ; numara evenimentele de tip timer
counter2 DD 0
total_time DD 0

game_end DD 0
game_start DD 0
won dd 0
lose dd 0

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

powerup_width equ 30
powerup_height equ 30
symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc
include powerup.inc
pos_ax dd 81
pos_ay dd 445

pos_bx dd 114
pos_by dd 445

pos_cx dd 81
pos_cy dd 478

pos_dx dd 114
pos_dy dd 445

;definim culorile
character_color dd 148bbah
verde equ 3d7a44h
gri equ 0E3E3E3h
albastru equ 148bbah
galben equ 0f7f307h
gri2 equ 0E3E3E4h
portocaliu equ 0f5a70ch
rosu equ 0ab1822h
verde_light equ 78f21bh
negru equ 0a0a0ah
alb equ 0ffffffh
movv equ 733273h
maro equ 0a86a28h
lava_color equ 0a32b07h
.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]	; citim simbolul de afisat
	cmp eax, '?'
	je make_powerup
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	jmp draw_text
make_powerup:
	mov eax, 0
	lea esi, powerup
	jmp draw_powerup	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], gri
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
draw_powerup:
	mov ebx, powerup_width
	mul ebx
	mov ebx, powerup_height
	mul ebx;
	add esi, eax
	mov ecx, powerup_height
	bucla_powerup_linii:
	mov edi, [ebp + arg2] ; pointer la matricea de pixeli
	mov eax, [ebp + arg4] ; pointer la coord y
	add eax, powerup_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, powerup_width
bucla_powerup_coloane:
	cmp byte ptr [esi], 1
	je powerup_pixel_galben
	mov dword ptr [edi], gri
	jmp powerup_pixel_next
powerup_pixel_galben:
	mov dword ptr [edi], portocaliu
powerup_pixel_next:
	inc esi
	add edi, 4
	loop bucla_powerup_coloane
	pop ecx
	loop bucla_powerup_linii
	popa
	mov esp, ebp
	pop ebp
	ret	
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

draw_horizontal_line macro posx, posy, len, color
local et1
    push ecx
	mov eax, posy
	mov ebx, area_width
	mul ebx
	add eax, posx
	shl eax, 2
	add eax, area
	mov ecx, len
	mov edx, color
et1:
    mov dword ptr[eax], edx
	add eax, 4
    loop et1
	pop ecx
endm

draw_horizontal_lines proc 
  ;params: posx, posy, len, color, number
  push ebp
  mov ebp, esp
  mov ecx, [ebp+24]
  et:
     draw_horizontal_line [ebp+8], [ebp+12], [ebp+16], [ebp+20]
	 mov edx, [ebp+12]
	 inc edx
	 mov [ebp+12], edx
	 loop et
  mov esp, ebp
  pop ebp  
  ret 20	 
draw_horizontal_lines endp

draw_rectangle macro xa, ya, xb, yc, color
;macro-ul va desena un dreptunghi intre punctele:
;   A   B
;   C   D
    push eax
	push edx
	
	mov eax, yc
	sub eax, ya
	
	mov edx, xb
	sub edx, xa
	
	push eax
	push color
	push edx
	push ya
	push xa
	call draw_horizontal_lines
	
	pop edx
	pop eax
	
endm

respawn macro	
	
	draw_rectangle pos_ax, pos_ay, pos_bx, pos_cy, gri
	push 33
	push gri
	push 1
	push pos_by
	push pos_bx
	call draw_horizontal_lines
	draw_horizontal_line pos_cx, pos_cy, 33, gri
	
	mov pos_ax, 81
	mov pos_ay, 445
    mov pos_bx, 114
    mov pos_by, 445
    mov pos_cx, 81
    mov pos_cy, 478
    mov pos_dx, 114
    mov pos_dy, 445
	draw_rectangle pos_ax, pos_ay, pos_bx, pos_cy, character_color
	
endm
; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click, 3 - s-a apasat o tasta)
; arg2 - x (in cazul apasarii unei taste, x contine codul ascii al tastei care a fost apasata)
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	cmp eax, 3
	jz evt_tasta
	;mai jos e codul care intializeaza fereastra
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push gri
	push area
	call memset
	add esp, 12
	draw_rectangle pos_ax, pos_ay, pos_bx, pos_cy, character_color
	
	;desenez LABIRINTUL
	
	;marginile
	draw_rectangle 20, 69, 50, 529, verde
    draw_rectangle 50, 497, 650, 529, verde
    draw_rectangle 620, 69, 650, 497, verde	
	draw_rectangle 20, 37, 650, 70, verde
	
	;interiorul
	draw_rectangle 49, 412, 181, 421, verde
	draw_rectangle 255, 131, 270, 498, verde
	draw_rectangle 111, 361, 259, 370, verde
	draw_rectangle 50, 308, 161, 317, verde
	draw_rectangle 126, 231, 260, 242, verde
	draw_rectangle 126, 122, 135, 231, verde
	draw_rectangle 195, 70, 203, 149, verde
	draw_rectangle 350, 132, 360, 226, verde
	draw_rectangle 360, 132, 456, 141, verde
	draw_rectangle 409, 180, 505, 187, verde
	draw_rectangle 503, 68, 512, 187, verde
	draw_rectangle 350, 222, 462, 228, verde
	draw_rectangle 455, 225, 462, 368, verde
	draw_rectangle 269, 269, 403, 278, verde
	draw_rectangle 325, 316, 400, 323, verde
	draw_rectangle 325, 316, 333, 447, verde
	draw_rectangle 381, 363, 456, 368, verde
	draw_rectangle 325, 439, 459, 447, verde
	draw_rectangle 505, 186, 512, 404, verde
	draw_rectangle 381, 368, 389, 404, verde
	draw_rectangle 381, 400, 508, 404, verde
	draw_rectangle 381, 368, 389, 398, verde
	draw_rectangle 381, 400, 460, 404, verde
	draw_rectangle 459, 439, 561, 447, verde
	draw_rectangle 556, 252, 564, 447, verde
	
	draw_rectangle 209, 278, 226, 291, lava_color
	draw_rectangle 212, 203, 224, 217, lava_color
	draw_rectangle 289, 178, 300, 193, lava_color
	draw_rectangle 57, 168, 73, 185, lava_color
	draw_rectangle 227, 470, 245, 488, lava_color
    draw_rectangle 528, 197, 544, 216, lava_color
	draw_rectangle 566, 116, 582, 135, lava_color
	draw_rectangle 569, 410, 579, 424, lava_color
	draw_rectangle 600, 360, 611, 373, lava_color
	draw_rectangle 569, 302, 581, 320, lava_color
	
    make_text_macro '?', area, 142, 445
   	
	draw_rectangle 620, 150, 651, 190, gri ;finish
	
	
	push 40
	push gri2
	push 1
	push 149
	push 651
	call draw_horizontal_lines
	
	;desenez chenar de culori
	make_text_macro 'A', area, 714, 434
	make_text_macro 'L', area, 724, 434
	make_text_macro 'E', area, 734, 434
	make_text_macro 'G', area, 744, 434
	make_text_macro 'E', area, 754, 434
	make_text_macro ' ', area, 764, 434
	make_text_macro 'O', area, 774, 434
	make_text_macro ' ', area, 784, 434
	make_text_macro 'C', area, 794, 434
	make_text_macro 'U', area, 804, 434
	make_text_macro 'L', area, 814, 434
	make_text_macro 'O', area, 824, 434
	make_text_macro 'A', area, 834, 434
	make_text_macro 'R', area, 844, 434
	make_text_macro 'E', area, 854, 434
	
	draw_rectangle 690, 470, 730, 510, alb
	draw_rectangle 740, 470, 780, 510, verde_light
	draw_rectangle 790, 470, 830, 510, rosu
	draw_rectangle 840, 470, 880, 510, albastru
	draw_rectangle 890, 470, 930, 510, movv
	draw_rectangle 940, 470, 980, 510, negru
	

	
	
	jmp afisare_litere
	
	
evt_click:
	
	mov eax, [ebp+arg3]
    mov ebx, area_width
    mul ebx
    add eax, [ebp+arg2]
    shl eax, 2
	add eax, area
	 
	
    mov eax, dword ptr [eax]
	cmp eax, rosu
	jne next
	mov character_color, eax
	draw_rectangle pos_ax, pos_ay, pos_bx, pos_cy, rosu
	jmp afisare_litere
next:
	cmp eax, negru
	jne next1
	mov character_color, eax
	draw_rectangle pos_ax, pos_ay, pos_bx, pos_cy, negru
	jmp afisare_litere
next1:
    cmp eax, verde_light
	jne next2
	mov character_color, eax 
    draw_rectangle pos_ax, pos_ay, pos_bx, pos_cy, verde_light   	
	jmp afisare_litere
next2:
    cmp eax, alb
	jne next3
	mov character_color, eax
    draw_rectangle pos_ax, pos_ay, pos_bx, pos_cy, alb	
	jmp afisare_litere
next3:
    cmp eax, movv
	jne next4
	mov character_color, eax
    draw_rectangle pos_ax, pos_ay, pos_bx, pos_cy, movv	
	jmp afisare_litere
next4:
    cmp eax, albastru
	jne afisare_litere
	mov character_color, eax
    draw_rectangle pos_ax, pos_ay, pos_bx, pos_cy, albastru	
	jmp afisare_litere	
evt_tasta:
   
	mov game_start, 1
	mov eax, prima_tasta
	cmp eax, 1
	jne et4
	mov prima_tasta, 0
	
	mov counter, 0
	mov counter2, max_time
et4:	
    mov ebx, [ebp + arg2]
    cmp ebx, 57h
	je t_w
	cmp ebx, 53h
	je t_s
	cmp ebx, 44h
	je t_d
	cmp ebx, 41h
    je t_a
    cmp ebx, 0Dh
    je t_enter
    jmp cont
t_enter:
    mov eax, game_end
    cmp eax, 0
    je cont
    mov game_end, 0
	mov game_start, 0
    mov won, 0
    mov lose, 0
	mov counter, 0
	mov counter2, 0
	mov prima_tasta, 1
	mov times_up, 0
	mov eax, pos_ax
	dec eax
	mov pos_ax, eax
	mov eax, pos_ay
	dec eax
	mov pos_ay, eax
	
	mov eax, pos_bx
	inc eax
	mov pos_bx, eax
	mov eax, pos_by
	dec eax
	mov pos_by, eax
	
	mov eax, pos_cx
	dec eax
	mov pos_cx, eax
	mov eax, pos_cy
	inc eax
	mov pos_cy, eax
	
	mov eax, pos_dx
	inc eax
	mov pos_dx, eax
	mov eax, pos_dy
	inc eax
	mov pos_dy, eax
	draw_rectangle pos_ax, pos_ay, pos_bx, pos_cy, gri
	mov pos_ax, 81
	mov pos_ay, 445
    mov pos_bx, 114
    mov pos_by, 445
    mov pos_cx, 81
    mov pos_cy, 478
    mov pos_dx, 114
    mov pos_dy, 445
	draw_rectangle pos_ax, pos_ay, pos_bx, pos_cy, character_color
	 make_text_macro ' ', area, 694, 270
    make_text_macro ' ', area, 704, 270
    make_text_macro ' ', area, 714, 270
    make_text_macro ' ', area, 724, 270
    make_text_macro ' ', area, 734, 270
    make_text_macro ' ', area, 744, 270
    make_text_macro ' ', area, 754, 270
    make_text_macro ' ', area, 764, 270
    make_text_macro ' ', area, 774, 270
	make_text_macro ' ', area, 784, 270
	make_text_macro ' ', area, 794, 270
    make_text_macro ' ', area, 804, 270
	make_text_macro ' ', area, 814, 270
	make_text_macro ' ', area, 824, 270
	make_text_macro ' ', area, 834, 270
	make_text_macro ' ', area, 844, 270
	make_text_macro ' ', area, 854, 270
	make_text_macro ' ', area, 864, 270
	make_text_macro ' ', area, 874, 270
	make_text_macro ' ', area, 884, 270
	make_text_macro ' ', area, 894, 270
	make_text_macro ' ', area, 904, 270
	make_text_macro ' ', area, 914, 270
	make_text_macro ' ', area, 924, 270
	make_text_macro ' ', area, 934, 270
	make_text_macro ' ', area, 944, 270
	make_text_macro ' ', area, 954, 270
	
	make_text_macro ' ', area, 774, 290
	make_text_macro ' ', area, 784, 290
	make_text_macro ' ', area, 794, 290
    make_text_macro ' ', area, 804, 290
	make_text_macro ' ', area, 814, 290
	make_text_macro ' ', area, 824, 290
	make_text_macro ' ', area, 834, 290
	make_text_macro ' ', area, 844, 290
	make_text_macro ' ', area, 854, 290
	make_text_macro ' ', area, 864, 290
	
	make_text_macro ' ', area, 675, 73
	make_text_macro ' ', area, 685, 73
	make_text_macro ' ', area, 695, 73
	make_text_macro ' ', area, 705, 73
	
	make_text_macro ' ', area, 715, 73
	make_text_macro ' ', area, 725, 73
	make_text_macro ' ', area, 735, 73
	make_text_macro ' ', area, 745, 73
	make_text_macro ' ', area, 755, 73
	
	
	 make_text_macro ' ', area, 754, 134
	 make_text_macro ' ', area, 764, 134
	 make_text_macro ' ', area, 774, 134
	 make_text_macro ' ', area, 784, 134
	 make_text_macro ' ', area, 794, 134
	 make_text_macro ' ', area, 804, 134
	 make_text_macro ' ', area, 814, 134
	 make_text_macro ' ', area, 824, 134
	 make_text_macro ' ', area, 834, 134
	 make_text_macro ' ', area, 844, 134
	 
	 make_text_macro ' ', area, 710, 154
	 make_text_macro ' ', area, 720, 154
	 
	 make_text_macro ' ', area, 740, 154
	 make_text_macro ' ', area, 750, 154
	 make_text_macro ' ', area, 760, 154
	 make_text_macro ' ', area, 770, 154
	 make_text_macro ' ', area, 780, 154
	 make_text_macro ' ', area, 790, 154
	 
	 
	 make_text_macro ' ', area, 810, 154
	 make_text_macro ' ', area, 820, 154
	 make_text_macro ' ', area, 830, 154
	 
	 make_text_macro ' ', area, 850, 154
	 make_text_macro ' ', area, 860, 154
	 make_text_macro ' ', area, 870, 154
	 make_text_macro ' ', area, 880, 154
     make_text_macro ' ', area, 890, 154
     make_text_macro ' ', area, 900, 154
	 make_text_macro ' ', area, 910, 154
	 make_text_macro ' ', area, 920, 154	 
    jmp cont	
t_w:
    mov eax, game_end
	cmp eax, 1
	je evt_timer
	
	mov ecx, pos_bx
	sub ecx, pos_ax
    mov eax, pos_ay
	dec eax
	mov edx, area_width
	mul edx
	add eax, pos_ax
	shl eax, 2
	add eax, area
et:	mov ebx, dword ptr [eax]
	cmp ebx, verde
	je cont
	
	cmp ebx, lava_color
	jne label1
	respawn
label1:	
	add eax, 4
	dec ecx
	cmp ecx, 0
	jne et
		
	push 33
	push gri
	push 1
	push pos_by
	push pos_bx
	call draw_horizontal_lines
	draw_horizontal_line pos_cx, pos_cy, 33, gri
	
	mov eax, pos_ay
	dec eax
	mov pos_ay, eax
	mov pos_by, eax
	
	mov eax, pos_cy
	dec eax
	mov pos_cy, eax
	mov pos_dy, eax
	
	draw_horizontal_line pos_ax, pos_ay, 33, character_color
	jmp cont
t_s:
    mov eax, game_end
	cmp eax, 1
	je evt_timer
	
    mov ecx, pos_dx
	sub ecx, pos_cx
    mov eax, pos_cy
	inc eax
	mov edx, area_width
	mul edx
	add eax, pos_cx
	shl eax, 2
	add eax, area
ett:
    mov ebx, dword ptr [eax]
	cmp ebx, verde
	je cont
	
	cmp ebx, lava_color
	jne label2
	respawn
label2:	
	add eax, 4
	dec ecx
	cmp ecx, 0
	jne ett
	
	push 33
	push gri
	push 1
	push pos_by
	push pos_bx
	call draw_horizontal_lines
	draw_horizontal_line pos_ax, pos_ay, 33, gri
	draw_horizontal_line pos_cx, pos_cy, 33, character_color
	
	mov eax, pos_ay
	inc eax
	mov pos_ay, eax
	mov pos_by, eax
	
	mov eax, pos_cy
	inc eax
	mov pos_cy, eax
	mov pos_dy, eax
	
	draw_horizontal_line pos_cx, pos_cy, 33, character_color
	
    jmp cont

t_d:
    mov eax, game_end
	cmp eax, 1
	je evt_timer
	
	mov ecx, pos_dy
	sub ecx, pos_by
	
    mov eax, pos_by
	mov edx, area_width
	mul edx
	add eax, pos_bx
	inc eax
	shl eax, 2
	add eax, area
etttt:
    mov ebx, dword ptr [eax]
	cmp ebx, verde
	je cont
	
	cmp ebx, lava_color
	jne label3
	respawn
label3:	
	add eax, area_width
	add eax, area_width
	add eax, area_width
	add eax, area_width
	dec ecx
	cmp ecx, 0
	jne etttt
	
	
	cmp ebx, gri2
    jne cont2
	mov won, 1
	mov game_end, 1
	mov eax, max_time
	sub eax, counter2
	mov total_time, eax
	
	mov eax, total_time
	cmp eax, minim
	jge eti
	make_text_macro 'B', area, 329, 13
	make_text_macro 'E', area, 339, 13
	make_text_macro 'S', area, 349, 13
	make_text_macro 'T', area, 359, 13
	make_text_macro ' ', area, 369, 13
	make_text_macro 'T', area, 379, 13
	make_text_macro 'I', area, 389, 13
	make_text_macro 'M', area, 399, 13
	make_text_macro 'E', area, 409, 13
	make_text_macro ' ', area, 419, 13
	mov minim, eax
	
	cmp eax, x
	jg contt
	push offset write_mode
	push offset file_name
	call fopen
	add esp, 8
	mov file_ptr, eax
	
	push minim
	push offset format_integer
	push file_ptr
	call fprintf
	add esp, 12
	
	push file_ptr
	call fclose
	add esp, 4
	
contt:	
	
	mov ebx, 10
	mov eax, minim
	    ;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 449, 13
	    ;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 439, 13
	    ;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 429, 13
	make_text_macro ' ', area, 459, 13
	make_text_macro 'S', area, 469, 13
	make_text_macro 'E', area, 479, 13
	make_text_macro 'C', area, 489, 13
	make_text_macro 'U', area, 499, 13
	make_text_macro 'N', area, 509, 13
	make_text_macro 'D', area, 519, 13
	make_text_macro 'E', area, 529, 13
	
	
eti:	
	
	 make_text_macro 'F', area, 754, 134
	 make_text_macro 'E', area, 764, 134
	 make_text_macro 'L', area, 774, 134
	 make_text_macro 'I', area, 784, 134
	 make_text_macro 'C', area, 794, 134
	 make_text_macro 'I', area, 804, 134
	 make_text_macro 'T', area, 814, 134
	 make_text_macro 'A', area, 824, 134
	 make_text_macro 'R', area, 834, 134
	 make_text_macro 'I', area, 844, 134
	 
	 make_text_macro 'A', area, 710, 154
	 make_text_macro 'I', area, 720, 154
	 
	 make_text_macro 'E', area, 740, 154
	 make_text_macro 'V', area, 750, 154
	 make_text_macro 'A', area, 760, 154
	 make_text_macro 'D', area, 770, 154
	 make_text_macro 'A', area, 780, 154
	 make_text_macro 'T', area, 790, 154
	 
	 
	 make_text_macro 'D', area, 810, 154
	 make_text_macro 'I', area, 820, 154
	 make_text_macro 'N', area, 830, 154
	 
	 make_text_macro 'L', area, 850, 154
	 make_text_macro 'A', area, 860, 154
	 make_text_macro 'B', area, 870, 154
	 make_text_macro 'I', area, 880, 154
     make_text_macro 'R', area, 890, 154
     make_text_macro 'I', area, 900, 154
	 make_text_macro 'N', area, 910, 154
	 make_text_macro 'T', area, 920, 154	 
	jmp cont
cont2:	
	push 33
	push gri
	push 1
	push pos_ay
	push pos_ax
	call draw_horizontal_lines
	
	push 33
	push character_color
	push 1
	push pos_by
	push pos_bx
	call draw_horizontal_lines
	
	draw_horizontal_line pos_cx, pos_cy, 33, gri
		
	mov eax, pos_bx
	inc eax
	mov pos_bx, eax
	mov pos_dx, eax
	
	mov eax, pos_ax
	inc eax
	mov pos_ax, eax
	mov pos_cx, eax
	
	push 33
	push character_color
	push 1
	push pos_by
	push pos_bx
	call draw_horizontal_lines
	
    jmp cont
	
t_a:
    mov eax, game_end
	cmp eax, 1
	je evt_timer
	
    mov ecx, pos_cy
	sub ecx, pos_ay
	
    mov eax, pos_ay
	mov edx, area_width
	mul edx
	add eax, pos_ax
	dec eax
	shl eax, 2
	add eax, area
ettt:
    mov ebx, dword ptr [eax]
	cmp ebx, verde
	je cont
	cmp ebx, lava_color
	jne label4
	respawn
label4:	
	add eax, area_width
	add eax, area_width
	add eax, area_width
	add eax, area_width
	dec ecx
	cmp ecx, 0
	jne ettt
	
	push 33
	push gri
	push 1
	push pos_by
	push pos_bx
	call draw_horizontal_lines
	
	push 33
	push character_color
	push 1
	push pos_ay
	push pos_ax
	call draw_horizontal_lines
	
	draw_horizontal_line pos_cx, pos_cy, 33, gri
		
	mov eax, pos_ax
	dec eax
	mov pos_ax, eax
	mov pos_cx, eax
	
	mov eax, pos_bx
	dec eax
	mov pos_bx, eax
	mov pos_bx, eax
	
	push 33
	push character_color
	push 1
	push pos_by
	push pos_bx
	call draw_horizontal_lines
    jmp cont	
cont:
    		
    jmp afisare_litere	
evt_timer:
	inc counter
	mov eax, counter
	xor edx, edx
	mov ebx, 5
	div ebx
	cmp edx, 0
	jne afisare_litere
	mov eax, game_start
	cmp eax, 0
	je afisare_litere
	dec counter2
	cmp counter2, 0
	jne afisare_litere
	
	jmp t_up
afisare_litere:
    
    mov eax, game_start
	cmp eax, 0
	je begin
	 make_text_macro ' ', area, 701, 243
	make_text_macro ' ', area, 711, 243
	make_text_macro ' ', area, 721, 243
	make_text_macro ' ', area, 731, 243
	make_text_macro ' ', area, 741, 243
	make_text_macro ' ', area, 751, 243
	make_text_macro ' ', area, 761, 243
	make_text_macro ' ', area, 771, 243
	make_text_macro ' ', area, 781, 243
	make_text_macro ' ', area, 791, 243
	make_text_macro ' ', area, 801, 243
	make_text_macro ' ', area, 811, 243
	make_text_macro ' ', area, 821, 243
    make_text_macro ' ', area, 831, 243	
	make_text_macro ' ', area, 841, 243	
	make_text_macro ' ', area, 851, 243	
	make_text_macro ' ', area, 861, 243	
	make_text_macro ' ', area, 871, 243	
	make_text_macro ' ', area, 881, 243	
	make_text_macro ' ', area, 891, 243	
	make_text_macro ' ', area, 901, 243
    make_text_macro ' ', area, 911, 243	
    make_text_macro ' ', area, 921, 243
    make_text_macro ' ', area, 931, 243	
    make_text_macro ' ', area, 941, 243	
    make_text_macro ' ', area, 951, 243	
    make_text_macro ' ', area, 761, 263	
    make_text_macro ' ', area, 771, 263
	make_text_macro ' ', area, 781, 263	
	make_text_macro ' ', area, 791, 263	
	make_text_macro ' ', area, 801, 263	
	make_text_macro ' ', area, 811, 263	
	make_text_macro ' ', area, 821, 263
	make_text_macro ' ', area, 831, 263	
	make_text_macro ' ', area, 841, 263	
	make_text_macro ' ', area, 851, 263	
	make_text_macro ' ', area, 861, 263
	make_text_macro ' ', area, 871, 263	
	mov eax, times_up
	cmp eax, 1
	je t_up
	mov eax, won
	cmp eax, 1
	je fin
	;TIMER
	make_text_macro 'R', area, 675, 73
	make_text_macro 'E', area, 685, 73
	make_text_macro 'M', area, 695, 73
	make_text_macro 'A', area, 705, 73
	make_text_macro 'I', area, 715, 73
	make_text_macro 'N', area, 725, 73
	make_text_macro 'I', area, 735, 73
	make_text_macro 'N', area, 745, 73
	make_text_macro 'G', area, 755, 73
	
	make_text_macro 'T', area, 775, 73
	make_text_macro 'I', area, 785, 73
	make_text_macro 'M', area, 795, 73
	make_text_macro 'E', area, 805, 73
	
	mov ebx, 10
	mov eax, counter2
	    ;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 845, 73
	    ;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 835, 73
	    ;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 825, 73
	jmp cont3
t_up:
    mov eax, won
	cmp eax, 1
	je afisare_litere
	mov times_up, 1
	mov eax, game_start
	cmp eax, 0
	je fin
	mov game_end, 1
	mov lose, 1
    make_text_macro 'G', area, 675, 73
	make_text_macro 'A', area, 685, 73
	make_text_macro 'M', area, 695, 73
	make_text_macro 'E', area, 705, 73
	
	make_text_macro ' ', area, 715, 73
	make_text_macro 'O', area, 725, 73
	make_text_macro 'V', area, 735, 73
	make_text_macro 'E', area, 745, 73
	make_text_macro 'R', area, 755, 73
	
	make_text_macro ' ', area, 775, 73
	make_text_macro ' ', area, 785, 73
	make_text_macro ' ', area, 795, 73
	make_text_macro ' ', area, 805, 73
	make_text_macro ' ', area, 845, 73
	make_text_macro ' ', area, 835, 73
	make_text_macro ' ', area, 825, 73
	jmp cont3
fin:
    
    make_text_macro ' ', area, 675, 73
	make_text_macro ' ', area, 685, 73
	make_text_macro ' ', area, 695, 73
	make_text_macro ' ', area, 705, 73
	
	make_text_macro ' ', area, 715, 73
	make_text_macro ' ', area, 725, 73
	make_text_macro ' ', area, 735, 73
	make_text_macro ' ', area, 745, 73
	make_text_macro ' ', area, 755, 73
	
	make_text_macro ' ', area, 775, 73
	make_text_macro ' ', area, 785, 73
	make_text_macro ' ', area, 795, 73
	make_text_macro ' ', area, 805, 73
	make_text_macro ' ', area, 845, 73
	make_text_macro ' ', area, 835, 73
	make_text_macro ' ', area, 825, 73
	jmp cont3
begin:
    make_text_macro 'A', area, 701, 243
	make_text_macro 'P', area, 711, 243
	make_text_macro 'A', area, 721, 243
	make_text_macro 'S', area, 731, 243
	make_text_macro 'A', area, 741, 243
	make_text_macro ' ', area, 751, 243
	make_text_macro 'O', area, 761, 243
	make_text_macro 'R', area, 771, 243
	make_text_macro 'I', area, 781, 243
	make_text_macro 'C', area, 791, 243
	make_text_macro 'E', area, 801, 243
	make_text_macro ' ', area, 811, 243
	make_text_macro 'T', area, 821, 243
    make_text_macro 'A', area, 831, 243	
	make_text_macro 'S', area, 841, 243	
	make_text_macro 'T', area, 851, 243	
	make_text_macro 'A', area, 861, 243	
	make_text_macro ' ', area, 871, 243	
	make_text_macro 'P', area, 881, 243	
	make_text_macro 'E', area, 891, 243	
	make_text_macro 'N', area, 901, 243
    make_text_macro 'T', area, 911, 243	
    make_text_macro 'R', area, 921, 243
    make_text_macro 'U', area, 931, 243	
    make_text_macro ' ', area, 941, 243	
    make_text_macro 'A', area, 951, 243	
    make_text_macro 'I', area, 761, 263	
    make_text_macro 'N', area, 771, 263
	make_text_macro 'C', area, 781, 263	
	make_text_macro 'E', area, 791, 263	
	make_text_macro 'P', area, 801, 263	
	make_text_macro 'E', area, 811, 263	
	make_text_macro ' ', area, 821, 263
	make_text_macro 'J', area, 831, 263	
	make_text_macro 'O', area, 841, 263	
	make_text_macro 'C', area, 851, 263	
	make_text_macro 'U', area, 861, 263
	make_text_macro 'L', area, 871, 263
	
	make_text_macro 'A', area, 703, 364
	make_text_macro 'I', area, 713, 364
	make_text_macro ' ', area, 723, 364
	make_text_macro 'G', area, 733, 364
	make_text_macro 'R', area, 743, 364
	make_text_macro 'I', area, 753, 364
	make_text_macro 'J', area, 763, 364
	make_text_macro 'A', area, 773, 364
	make_text_macro ' ', area, 783, 364
	make_text_macro 'L', area, 793, 364
	make_text_macro 'A', area, 803, 364
	make_text_macro ' ', area, 813, 364
	make_text_macro 'L', area, 823, 364
	make_text_macro 'A', area, 833, 364
	make_text_macro 'V', area, 843, 364
	make_text_macro 'A', area, 853, 364
	
cont3:
    mov eax, game_end
    cmp eax, 1
    jne final_draw
    make_text_macro 'A', area, 694, 270
    make_text_macro 'P', area, 704, 270
    make_text_macro 'A', area, 714, 270
    make_text_macro 'S', area, 724, 270
    make_text_macro 'A', area, 734, 270
    make_text_macro ' ', area, 744, 270
    make_text_macro 'E', area, 754, 270
    make_text_macro 'N', area, 764, 270
    make_text_macro 'T', area, 774, 270
	make_text_macro 'E', area, 784, 270
	make_text_macro 'R', area, 794, 270
    make_text_macro ' ', area, 804, 270
	make_text_macro 'P', area, 814, 270
	make_text_macro 'E', area, 824, 270
	make_text_macro 'N', area, 834, 270
	make_text_macro 'T', area, 844, 270
	make_text_macro 'R', area, 854, 270
	make_text_macro 'U', area, 864, 270
	make_text_macro ' ', area, 874, 270
	make_text_macro 'A', area, 884, 270
	make_text_macro ' ', area, 894, 270
	make_text_macro 'I', area, 904, 270
	make_text_macro 'N', area, 914, 270
	make_text_macro 'C', area, 924, 270
	make_text_macro 'E', area, 934, 270
	make_text_macro 'P', area, 944, 270
	make_text_macro 'E', area, 954, 270
	
	make_text_macro 'U', area, 774, 290
	make_text_macro 'N', area, 784, 290
	make_text_macro ' ', area, 794, 290
    make_text_macro 'N', area, 804, 290
	make_text_macro 'O', area, 814, 290
	make_text_macro 'U', area, 824, 290
	make_text_macro ' ', area, 834, 290
	make_text_macro 'J', area, 844, 290
	make_text_macro 'O', area, 854, 290
	make_text_macro 'C', area, 864, 290
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp
 
start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	
	push offset read_mode
	push offset file_name
	call fopen
	add esp, 8
	mov file_ptr, eax
	cmp eax, 0
	je continuare
	push offset x
	push offset format_integer
	push file_ptr
	call fscanf
	add esp, 12

	push file_ptr
	call fclose
	add esp, 4
continuare:	

	
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	 
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	

	
	;terminarea programului
	push 0
	call exit
end start
