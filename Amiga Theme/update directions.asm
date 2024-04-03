Update_Y_Directions

        ; Update Y
        ldy #$0
- 
        lda timing_current,y
        bne ++      
        
        lda obj_dir_y,y
        cmp #$2
        beq ++
        
        cmp #$0
        bne +
        
        jsr Update_Up
        jmp ++
+
        jsr Update_Down
++        
        iny
        cpy #OBJ_SIZE
        bne -  
        
        rts
        
Update_X_Directions

        ; Update X
        ldy #$0
-
        lda timing_current,y
        bne ++
        
        lda obj_dir_x,y
        cmp #$2
        beq ++
        
        cmp #$0
        bne +
        
        jsr Update_Left
        jmp ++
+
        jsr Update_Right
++        
        iny
        cpy #OBJ_SIZE
        bne -

        rts
        
Update_Timings

        ; update timings
        ldy #$0
-
        sec
        lda timing_current,y
        sbc #$1
        cmp #$ff
        bne +

        lda timing_max,y
+        
        sta timing_current,y
        
        iny
        cpy #OBJ_SIZE
        bne -

        rts
        
Update_Up

        ; increase offset
        clc
        lda obj_y,y
        adc #$20
        sta obj_y,y
     
        ; update mask
        lda obj_mask,y
        lsr
        sta obj_mask,y
        
        ; check if offset = '0'
        lda obj_y,y
        and #%11111100
        bne +
        
        ; if it is, then decrease row by '1'
        sec
        lda obj_row,y
        sbc #$1
        sta obj_row,y
        
        ; set tile to fully visible        
        lda #$ff
        sta obj_mask,y
        
        ; check if row = '0'
        lda obj_row,y
        bne +
        
        ; if it is, then reverse direction
        lda #$1
        sta obj_dir_y,y
        
        jsr Gen_Rnd_Timing
+        
        rts
        
Update_Down

        ; decrease offset
        sec
        lda obj_y,y
        sbc #$20
        sta obj_y,y
        
        ; update mask
        lda obj_mask,y
        asl
        sta obj_mask,y        
        
        ; check if offset = '0'        
        lda obj_y,y
        and #%11111100
        bne +
        
        ; if it is, increase row by '1'
        clc
        lda obj_row,y
        adc #$1
        sta obj_row,y
        
        ; set tile to fully visible
        lda #$ff
        sta obj_mask,y        
        
        ; check if row = '24;
        lda obj_row,y
        cmp #$17
        bne +
        
        ; if it is, reverse direction
        lda #$0
        sta obj_dir_y,y
        
        jsr Gen_Rnd_Timing
+
        rts
        
Update_Left

        ;check if x = 0
        clc
        lda obj_x,y
        beq @Check_MSB
        jmp @Skip
        
@Check_MSB

        lda obj_y,y
        and #$3
        beq +
        
        ;MSB = 1
        sec
        lda obj_y,y
        sbc #$1
        sta obj_y,y
        jmp @Skip
+
        ;MSB = 0
        clc
        lda obj_dir_x,y
        adc #$1
        sta obj_dir_x,y
        
        jsr Gen_Rnd_Timing
        
        jsr Update_Right
        
@Skip
        ;update X position
        sec
        lda obj_x,y
        sbc #$1
        sta obj_x,y
        
        rts
        
Update_Right

        ;check MSB
        lda obj_y,y
        and #$3
        beq +

        ;MSB = 1
        lda obj_x,y
        cmp #$2f
        bne @Skip
        
        sec
        lda obj_dir_x,y
        sbc #$1
        sta obj_dir_x,y
        
        jsr Gen_Rnd_Timing
        
        jsr Update_Left
+        
        ;MSB = 0
        lda obj_x,y
        cmp #$ff
        bne @Skip
        
        clc
        lda obj_y,y
        adc #$1
        sta obj_y,y
@Skip
        ;update X position
        clc
        lda obj_x,y
        adc #$1
        sta obj_x,y  

        rts
        
