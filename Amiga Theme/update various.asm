
Gen_Rnd_Timing

        clc
        +GenRndNumM65
        cmp #$80
        bcc +

        lda #$1
        jmp ++
+        
        lda #$0
++        
        sta timing_max,y
        
        rts    
    
Update_Ball_Anim

        lda ball_anim_speed+0
        beq + 

        sbc #$1
        sta ball_anim_speed+0
        rts
+
        ;reset ball anim delay
        lda ball_anim_speed+1
        sta ball_anim_speed+0
        
        ldy #$0
-
        ;check X direction
        lda obj_dir_x,y
        beq @left

        ;RIGHT    
        lda obj_tile_id,y
        cmp #$07
        bne +
        
        lda #$01
        sta obj_tile_id,y
        jmp ++
+
        adc #$02
        sta obj_tile_id,y
        jmp ++
@left
        ;LEFT
        lda obj_tile_id,y
        cmp #$01
        bne +        

        lda #$07
        sta obj_tile_id,y
        jmp ++
+
        sbc #$02
        sta obj_tile_id,y
++        
        iny
        iny
        cpy #OBJ_SIZE
        bne -

        rts        
        