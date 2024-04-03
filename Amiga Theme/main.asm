; Amiga Theme
; By Drex
;
; 03/04/2024
; Code written, using C64 Studio \ ACME Assembler

!cpu m65
!to "Amiga Theme.prg", cbm

* = $2001

!basic

!source "macros.asm"


!address OBJ_SIZE = $28                               ;40
!address ROWS = $19                                   ;25
!address COLUMNS = $28                                ;40

!address OFFSET = OBJ_SIZE * 4 + 4
!address BYTES_PER_ROW = COLUMNS * 2 + OFFSET
!address CHARS_PER_ROW = BYTES_PER_ROW / 2 
!address TOTAL_BYTES = ROWS * BYTES_PER_ROW

!address SCREEN_MEM = $6000
!address COLOUR_MEM = $0000

!address GTX = $98

        ; NCM Mode
        ; Chars are 16 pixels wide, so 20 chars = 320
        ; chars per row = 20
        ; bytes per row = 40
        
        ;     screen =  0 - 79
        ; off screen = 80 - 163
        
        ; disable hotregs
        lda $d05d
        and #$7f
        sta $d05d
        
        ; force 40mhz
        lda #$41
        sta $00
        
        ; enable VIC IV
        lda #$47  
        sta $d02f
        lda #$53
        sta $d02f        

        ; enable RRB double buffer  [stops artifacts, on left hand edge of screen]
        lda #$80                    ;Clear bit7 = NORRDEL
        trb $d051
        
        ; enable FCLRHI & CHR16
        lda $d054
        ora #$5
        sta $d054

        ; define background colour
        lda #$b
        sta $d021

        ;disable 80 column mode
        lda $d031
        and #$7f       
        sta $d031 

        +V4_Set_Byte_Per_Row $00, BYTES_PER_ROW
        +V4_Set_Char_Per_Row $00, CHARS_PER_ROW

        ; set screen address > $6000
        +V4_Set_Scrn_Ptr $00, $00, $60, $00
        
        ; load in sprite data > address 5.0000
        +DMA_Job $00, $01, $40 * $09 , $00, $00, sprite_data, $00, $05, $0000
        
        ; fill screen & colour data with '0' [6100 bytes]
        +DMA_Job $03, $01, TOTAL_BYTES, $00, $00, $0000, $00, $00, SCREEN_MEM    ;screen 
        +DMA_Job $03, $01, TOTAL_BYTES, $00, $00, $0000, $ff, $08, COLOUR_MEM    ;colour 
        
        jsr Calc_Row_Addr

        jsr Define_Palette
        
        jsr Base_Text        
        
        jsr Gen_Rnd_Rows
        jsr Gen_Rnd_X_Positions
        jsr Gen_Rnd_Y_Directions
        jsr Gen_Rnd_X_Directions
        
; MAIN ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main

        lda #$00
        sta $d020  
-
        lda $d012
        cmp #$fe
        bne -
        
        ; DRAW ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ; Clear RRB data 80 - 163        
        !for i = 0 to 24

          +DMA_Job $03, $01, OFFSET, $00, $00, $0000, $00, $00, $6050 + i * BYTES_PER_ROW  ;screen 
          +DMA_Job $03, $01, OFFSET, $00, $00, $0000, $ff, $08, $0050 + i * BYTES_PER_ROW  ;colour           
        
        !end
        
        ; get variables, from top half of ball
        jsr Gen_Ball_Bottom
        
        ; copy obj RRB data, to screen & colour data
        jsr Gen_Balls
        
        ; UPDATE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        jsr Update_Y_Directions
        jsr Update_X_Directions        
        jsr Update_Timings
        jsr Update_Ball_Anim
        
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                
        jmp Main
        
        rts
        
;END OF MAIN
        
; DATA ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ball_anim_speed ;current = byte0 | reset = byte1
  !word $0606
  
text
  !byte $01,$0d,$05,$07,$01,$36,$35
  
timing_current         
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00  
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00     
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00    
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00  
timing_max         
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00    
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00   
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00    
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00   
  
  
obj_row       
  !byte $01,$00,$03,$00,$05,$00,$07,$00,$09,$00         ; screen row
  !byte $0b,$00,$0d,$00,$0f,$00,$11,$00,$13,$00         ; screen row  
  !byte $15,$00,$17,$00,$01,$01,$01,$01,$01,$01         ; screen row
  !byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02         ; screen row  
obj_dir_x       
  !byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02         ; direction X
  !byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02         ; direction X
  !byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02         ; direction X
  !byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02         ; direction X  
obj_dir_y       
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00         ; direction Y     
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00         ; direction Y   
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00         ; direction Y    
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00         ; direction Y     

;;;;;;;;;; RRB SCREEN ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
obj_x         
  !byte $a0,$0a,$a0,$0a,$a0,$a0,$a0,$a0,$a0,$a0         ; X position [LSB]
  !byte $a0,$0a,$a0,$0a,$a0,$a0,$a0,$a0,$a0,$a0         ; X position [LSB]
  !byte $a0,$0a,$a0,$0a,$a0,$a0,$a0,$a0,$a0,$a0         ; X position [LSB]
  !byte $a0,$0a,$a0,$0a,$a0,$a0,$a0,$a0,$a0,$a0         ; X position [LSB] 
obj_y         
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00         ; Y offset in screen row, & X position [MSB]
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00         ; Y offset in screen row, & X position [MSB]
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00         ; Y offset in screen row, & X position [MSB]
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00         ; Y offset in screen row, & X position [MSB]  
obj_tile_id   
  !byte $01,$02,$01,$02,$01,$02,$01,$02,$01,$02         ; tile number
  !byte $01,$02,$01,$02,$01,$02,$01,$02,$01,$02         ; tile number
  !byte $01,$02,$01,$02,$01,$02,$01,$02,$01,$02         ; tile number
  !byte $01,$02,$01,$02,$01,$02,$01,$02,$01,$02         ; tile number
obj_tile_addr 
  !byte $14,$14,$14,$14,$14,$14,$14,$14,$14,$14         ; tile address
  !byte $14,$14,$14,$14,$14,$14,$14,$14,$14,$14         ; tile address
  !byte $14,$14,$14,$14,$14,$14,$14,$14,$14,$14         ; tile address
  !byte $14,$14,$14,$14,$14,$14,$14,$14,$14,$14         ; tile address  

;;;;;;;;;; RRB COLOUR ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

obj_gotox
  !byte GTX,GTX,GTX,GTX,GTX,GTX,GTX,GTX,GTX,GTX         ;GOTOX + TRANSPARENCY + MASKING
  !byte GTX,GTX,GTX,GTX,GTX,GTX,GTX,GTX,GTX,GTX 
  !byte GTX,GTX,GTX,GTX,GTX,GTX,GTX,GTX,GTX,GTX
  !byte GTX,GTX,GTX,GTX,GTX,GTX,GTX,GTX,GTX,GTX 
obj_mask 
  !byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff         ; $00 > All masked     [No lines visible  ] 
  !byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff         ; $ff > Nothing masked [Every line visible]  
  !byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff         ; $3f > bits 7 & 6 masked
  !byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff 
obj_flip
  !byte $08,$08,$08,$08,$08,$08,$08,$08,$08,$08         ; enable NCM [16 x 8]
  !byte $08,$08,$08,$08,$08,$08,$08,$08,$08,$08
  !byte $08,$08,$08,$08,$08,$08,$08,$08,$08,$08
  !byte $08,$08,$08,$08,$08,$08,$08,$08,$08,$08  
obj_colour
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

scr_lo
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  !byte $00,$00,$00,$00,$00
scr_hi
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  !byte $00,$00,$00,$00,$00  
col_lo
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  !byte $00,$00,$00,$00,$00
col_hi
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  !byte $00,$00,$00,$00,$00

sprite_data

  ; blank
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

  ;frame 1 top
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$20,$22,$11,$01,$00,$00,$00,$10,$22,$22,$11,$11,$02,$00,$00,$11,$22,$22,$11,$11,$22,$00
  !byte $20,$22,$11,$11,$22,$22,$11,$01,$20,$22,$11,$11,$22,$22,$11,$01,$22,$22,$11,$11,$22,$22,$11,$11,$11,$11,$22,$22,$11,$11,$22,$22
  ;frame 1 bot
  !byte $11,$11,$22,$22,$11,$11,$22,$22,$11,$11,$22,$22,$11,$11,$22,$22,$22,$22,$11,$11,$22,$22,$11,$11,$20,$22,$11,$11,$22,$22,$11,$01
  !byte $20,$22,$11,$11,$22,$22,$11,$01,$00,$11,$22,$22,$11,$11,$22,$00,$00,$10,$22,$22,$11,$11,$02,$00,$00,$00,$20,$22,$11,$01,$00,$00
  ;frame 2 top
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$10,$22,$22,$01,$00,$00,$00,$10,$11,$22,$22,$11,$01,$00,$00,$11,$11,$22,$22,$11,$11,$00
  !byte $10,$22,$22,$11,$11,$22,$22,$01,$10,$22,$22,$11,$11,$22,$22,$01,$11,$22,$22,$11,$11,$22,$22,$11,$22,$11,$11,$22,$22,$11,$11,$22
  ;frame 2 bot
  !byte $22,$11,$11,$22,$22,$11,$11,$22,$22,$11,$11,$22,$22,$11,$11,$22,$11,$22,$22,$11,$11,$22,$22,$11,$10,$22,$22,$11,$11,$22,$22,$01
  !byte $10,$22,$22,$11,$11,$22,$22,$01,$00,$11,$11,$22,$22,$11,$11,$00,$00,$10,$11,$22,$22,$11,$01,$00,$00,$00,$10,$22,$22,$01,$00,$00
  ;frame 3 top
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$10,$11,$22,$02,$00,$00,$00,$20,$11,$11,$22,$22,$01,$00,$00,$22,$11,$11,$22,$22,$11,$00
  !byte $10,$11,$22,$22,$11,$11,$22,$02,$10,$11,$22,$22,$11,$11,$22,$02,$11,$11,$22,$22,$11,$11,$22,$22,$22,$22,$11,$11,$22,$22,$11,$11
  ;frame 3 bot
  !byte $22,$22,$11,$11,$22,$22,$11,$11,$22,$22,$11,$11,$22,$22,$11,$11,$11,$11,$22,$22,$11,$11,$22,$22,$10,$11,$22,$22,$11,$11,$22,$02
  !byte $10,$11,$22,$22,$11,$11,$22,$02,$00,$22,$11,$11,$22,$22,$11,$00,$00,$20,$11,$11,$22,$22,$01,$00,$00,$00,$10,$11,$22,$02,$00,$00
  ;frame 4 top
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$20,$11,$11,$02,$00,$00,$00,$20,$22,$11,$11,$22,$02,$00,$00,$22,$22,$11,$11,$22,$22,$00
  !byte $20,$11,$11,$22,$22,$11,$11,$02,$20,$11,$11,$22,$22,$11,$11,$02,$22,$11,$11,$22,$22,$11,$11,$22,$11,$22,$22,$11,$11,$22,$22,$11
  ;frame 4 bot
  !byte $11,$22,$22,$11,$11,$22,$22,$11,$11,$22,$22,$11,$11,$22,$22,$11,$22,$11,$11,$22,$22,$11,$11,$22,$20,$11,$11,$22,$22,$11,$11,$02
  !byte $20,$11,$11,$22,$22,$11,$11,$02,$00,$22,$22,$11,$11,$22,$22,$00,$00,$20,$22,$11,$11,$22,$02,$00,$00,$00,$20,$11,$11,$02,$00,$00

  
!src "setup.asm"
!src "update rrb.asm"
!src "update various.asm"
!src "update directions.asm"

