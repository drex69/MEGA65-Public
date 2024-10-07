!cpu m65
!to "main.prg", cbm
; 2nd draft [Masking]

* = $2001

!basic

!source "my_macros.asm"

!address OBJ_SIZE = $28                               ;40
!address ROWS = $19                                   ;25
!address COLUMNS = $28                                ;40
!address OFFSET = OBJ_SIZE * 4 + 4                    ;164 ( 40 x 4) + 4 
!address BYTES_PER_ROW = COLUMNS * 2 + OFFSET         ;244 ( 40 x 2) + 164
!address CHARS_PER_ROW = BYTES_PER_ROW / 2            ;122  (244 / 2)

!address SCREEN_MEM = $6000
!address COLOUR_MEM = $0000

!address TOTAL_BYTES = ROWS * BYTES_PER_ROW           ;6100 ( 25 * 244)


        ; [2nd Draft] FCM chararacter, moving in the Y direction
        
        ;     screen =  0 - 79
        ; off screen = 80 - 163

        ; force 40mhz
        lda #$41
        sta $00
        
        ; enable VIC IV
        lda #$47  
        sta $d02f
        lda #$53
        sta $d02f        

        ; enable RRB double buffer  ; stops artifacts, on left hand edge of screen
        lda #$80                    ; Clear bit7 = NORRDEL
        trb $d051
        
        ; enable FCLRHI & CHR16
        lda $d054
        ora #$5
        sta $d054

        ; define background colour
        lda #$02
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
        +DMA_Job $00, $01, $40 * $03 , $00, $00, sprite_data, $00, $05, $0000
        
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

        ; Update Graphics ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        ; Clear RRB data 80 - 163
        !for i = 0 to 24

          +DMA_Job $03, $01, OFFSET, $00, $00, $0000, $00, $00, $6050 + i * BYTES_PER_ROW  ;screen 
          +DMA_Job $03, $01, OFFSET, $00, $00, $0000, $ff, $08, $0050 + i * BYTES_PER_ROW  ;colour           
        
        !end       
      
        ; Copy obj RRB data, to screen & colour data
        jsr Gen_Obj_Data
        
        ; Generate obj RRB Y offset data, to screen & colour data
        jsr Gen_Obj_Y_Data

        jsr Update_Y_Directions
        jsr Update_X_Directions        
        jsr Update_Timings    
        
        jmp Main
        
        rts
        
;END OF MAIN ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
Gen_Obj_Y_Data
        
        +Addr_To_ZP1 $00,$00,$00,$00
        +Addr_To_ZP2 $0f,$f8,$00,$00

        ldy #$0
--      
        ;; Check if space for an offset, is needed
        ;lda obj_y,y
        ;and #%11111100
        ;bne +
        ;jmp @end
;+        
        ; If it is, check if space is needed, above or below
        lda obj_dir_y,y
        bne +
        
        ; Space needed above
        ldx obj_row,y
        dex
        jmp ++
+        
        ; Space needed below
        ldx obj_row,y
        inx
++        
        ; Get row start address, for screen & colour
        lda scr_lo,x
        sta zp1_lsb
        lda scr_hi,x
        sta zp1_msb
        
        lda col_lo,x
        sta zp2_lsb
        lda col_hi,x
        sta zp2_msb
        
        ; Find a valid space
        ldz #$50
-
        lda [zp2_lsb],z
        cmp #$98
        bne +
        
        inz
        inz
        inz
        inz
        
        jmp -
+
        lda obj_x,y
        sta [zp1_lsb],z
        lda obj_gotox,y
        sta [zp2_lsb],z
        
        inz
        
        lda obj_y,y
        sta [zp1_lsb],z
        
        sec
        lda #$ff
        sbc obj_mask,y
        sta [zp2_lsb],z        
        
        inz
        
        ; tile number, based on direction
        lda obj_dir_y,y
        bne +
    
        ; UP
        sec
        lda obj_tile_id,y
        sbc #$1
        sta [zp1_lsb],z
        jmp ++
+
        ; DOWN
        lda obj_tile_id,y
        sta [zp1_lsb],z
++
        
        lda obj_flip,y
        sta [zp2_lsb],z
        
        inz
        
        lda obj_tile_addr,y
        sta [zp1_lsb],z        
        lda obj_colour,y
        sta [zp2_lsb],z

        inz
        
        ; Terminate Line
        lda #$40
        sta [zp1_lsb],z        
        lda #$10
        sta [zp2_lsb],z         
        
        inz
        
        lda #$01
        sta [zp1_lsb],z        
        lda #$00
        sta [zp2_lsb],z 
        
;@end   ; No offset needed
        
        iny
        cpy #OBJ_SIZE
        beq +
        jmp --

+
        rts
        

Gen_Obj_Data
        
        +Addr_To_ZP1 $00,$00,$00,$00
        +Addr_To_ZP2 $0f,$f8,$00,$00

        ldy #$0
--        
        ldx obj_row,y
        
        lda scr_lo,x
        sta zp1_lsb
        lda scr_hi,x
        sta zp1_msb
        
        lda col_lo,x
        sta zp2_lsb
        lda col_hi,x
        sta zp2_msb        
        
        ldz #$50
-       
        lda [zp2_lsb],z
        cmp #$98
        bne +
        
        inz
        inz
        inz
        inz
        
        jmp -
+
        lda obj_x,y
        sta [zp1_lsb],z
        lda obj_gotox,y
        sta [zp2_lsb],z
        
        inz

        lda obj_y,y
        sta [zp1_lsb],z        
        lda obj_mask,y
        sta [zp2_lsb],z        

        inz
        
        ; get direction (up \ down)
        lda obj_dir_y,y
        bne +
        
        ; UP
        lda obj_tile_id,y
        sta [zp1_lsb],z
        jmp ++
+
        ; DOWN
        lda obj_y,y
        and #%11111100
        bne +
        
        lda obj_tile_id,y
        sta [zp1_lsb],z
        jmp ++
+       
        sec
        lda obj_tile_id,y
        sbc #$1
        sta [zp1_lsb],z
++        
        lda obj_flip,y
        sta [zp2_lsb],z        
        
        inz
        
        lda obj_tile_addr,y
        sta [zp1_lsb],z        
        lda obj_colour,y
        sta [zp2_lsb],z 
 
        inz
        
        ; Terminate Line
        
        lda #$40
        sta [zp1_lsb],z        
        lda #$10
        sta [zp2_lsb],z         
        
        inz
        
        lda #$01
        sta [zp1_lsb],z        
        lda #$00
        sta [zp2_lsb],z
       
        iny
        cpy #OBJ_SIZE
        beq +
        jmp --
+
        rts
        
; DATA ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

text
  !byte $0d,$05,$07,$01,$36,$35

timing_current         
  !byte $00,$01,$01,$01,$01,$01,$01,$01,$01,$01  
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00   
  !byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01  
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
timing_max         
  !byte $00,$01,$01,$01,$01,$01,$01,$01,$01,$01  
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00   
  !byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01  
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00   
  
obj_row       
  !byte $00,$01,$02,$01,$01,$01,$01,$01,$01,$01         ; screen row
  !byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02         ; screen row  
  !byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01         ; screen row
  !byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02         ; screen row  
obj_dir_x       
  !byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02         ; direction X
  !byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02         ; direction X
  !byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02         ; direction X
  !byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02         ; direction X  
obj_dir_y       
  !byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01         ; direction Y     
  !byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01         ; direction Y
  !byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01         ; direction Y   
  !byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01         ; direction Y   

;;;;;;;;;; RRB SCREEN ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
obj_x         
  !byte $00,$a8,$10,$18,$20,$28,$30,$38,$40,$48         ; X position [LSB]
  !byte $50,$58,$60,$68,$70,$78,$80,$88,$90,$98         ; X position [LSB]
  !byte $a0,$a8,$b0,$b8,$c0,$c8,$d0,$d8,$e0,$e8         ; X position [LSB]
  !byte $f0,$f8,$00,$08,$10,$18,$20,$28,$30,$38         ; X position [LSB]  
obj_y         
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00         ; Y offset in screen row, & X position [MSB]
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00         ; Y offset in screen row, & X position [MSB]
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00         ; Y offset in screen row, & X position [MSB]
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00         ; Y offset in screen row, & X position [MSB]  
obj_tile_id   
  !byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01         ; tile number
  !byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01         ; tile number
  !byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01         ; tile number
  !byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01         ; tile number
obj_tile_addr 
  !byte $14,$14,$14,$14,$14,$14,$14,$14,$14,$14         ; tile address
  !byte $14,$14,$14,$14,$14,$14,$14,$14,$14,$14         ; tile address
  !byte $14,$14,$14,$14,$14,$14,$14,$14,$14,$14         ; tile address
  !byte $14,$14,$14,$14,$14,$14,$14,$14,$14,$14         ; tile address  

;;;;;;;;;; RRB COLOUR ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

obj_gotox
  !byte $98,$98,$98,$98,$98,$98,$98,$98,$98,$98         ;GOTOX + TRANSPARENCY + MASKING
  !byte $98,$98,$98,$98,$98,$98,$98,$98,$98,$98
  !byte $98,$98,$98,$98,$98,$98,$98,$98,$98,$98
  !byte $98,$98,$98,$98,$98,$98,$98,$98,$98,$98
obj_mask 
  !byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff         ; $00 > All masked     [No lines visible  ] 
  !byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff         ; $ff > Nothing masked [Every line visible]  
  !byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff         ; $3f > bits 7 & 6 masked
  !byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff 
obj_flip
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00  
obj_colour
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  !byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

  ;blank
  !byte $00,$00,$00,$00,$00,$00,$00,$00
  !byte $00,$00,$00,$00,$00,$00,$00,$00
  !byte $00,$00,$00,$00,$00,$00,$00,$00
  !byte $00,$00,$00,$00,$00,$00,$00,$00
  !byte $00,$00,$00,$00,$00,$00,$00,$00
  !byte $00,$00,$00,$00,$00,$00,$00,$00
  !byte $00,$00,$00,$00,$00,$00,$00,$00
  !byte $00,$00,$00,$00,$00,$00,$00,$00

  ;mega65 logo
  !byte $10,$10,$10,$10,$10,$10,$10,$10
  !byte $00,$00,$00,$00,$00,$00,$00,$00
  !byte $00,$11,$11,$11,$11,$11,$11,$11
  !byte $00,$00,$00,$00,$00,$00,$00,$00
  !byte $00,$00,$12,$12,$12,$12,$12,$12
  !byte $00,$00,$00,$00,$00,$00,$00,$00
  !byte $00,$00,$00,$13,$13,$13,$13,$13
  !byte $00,$00,$00,$00,$00,$00,$00,$00

  
!src "setup.asm"
!src "update.asm"