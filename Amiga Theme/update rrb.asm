Gen_Ball_Y_Offset_Data
        
        +Addr_To_ZP1 $00,$00,$00,$00
        +Addr_To_ZP2 $0f,$f8,$00,$00

        ; Check for direction
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

        rts

Gen_Balls
        
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
        
;        ; UP
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
        
        jsr Gen_Ball_Y_Offset_Data
        
        iny
        cpy #OBJ_SIZE
        beq +
        jmp --
+
        rts

Gen_Ball_Bottom        

        ldy #$0
-
        lda timing_max,y
        sta timing_max+1,y
        
        lda timing_current,y
        sta timing_current+1,y        

        clc
        lda obj_row,y
        adc #$1
        sta obj_row+1,y
        
        lda obj_dir_y,y
        sta obj_dir_y+1,y  
  
        lda obj_dir_x,y
        sta obj_dir_x+1,y  
 
        lda obj_x,y
        sta obj_x+1,y         
        
        lda obj_y,y
        sta obj_y+1,y 

        clc
        lda obj_tile_id,y
        adc #$1
        sta obj_tile_id+1,y 

        lda obj_tile_addr,y
        sta obj_tile_addr+1,y
       
        lda obj_gotox,y
        sta obj_gotox+1,y
       
        lda obj_mask,y
        sta obj_mask+1,y

        lda obj_flip,y
        sta obj_flip+1,y
        
        lda obj_colour,y
        sta obj_colour+1,y        
        
        iny
        iny
        cpy #$28
        bne -

        rts