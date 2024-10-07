Gen_Rnd_Rows

        ; generate random rows
        ldy #$0
-        
        clc
        +GenRndNumM65
        and #%00011111
        cmp #$17
        bcs +
        
        cmp #$0
        bne ++
        
        lda #$1
        
        jmp ++
+
        sec
        sbc #$8
++
        sta obj_row,y
        iny
        cpy #$28
        bne -
        
        rts
        
Gen_Rnd_X_Positions

        ; generate random X positions
        ldy #$0
-        
        clc
        +GenRndNumM65
        cmp #$8
        bcs +

        lda #$8
+        
        sta obj_x,y
        iny
        cpy #$28
        bne -       

        rts

Gen_Rnd_Y_Directions

        ; generate random Y directions
        ldy #$0
-        
        clc
        +GenRndNumM65
        cmp #$80
        bcs +
        
        lda #$0
        jmp ++
+
        lda #$1
++
        sta obj_dir_y,y
        iny
        cpy #$28
        bne -
        
        rts
        
Gen_Rnd_X_Directions

        ; generate random X directions
        ldy #$0
-        
        clc
        +GenRndNumM65
        cmp #$80
        bcs +
        
        lda #$0
        jmp ++
+
        lda #$1
++
        sta obj_dir_x,y
        iny
        cpy #$28
        bne -    
        
        rts
        
Calc_Row_Addr

        +Addr_To_ZP1 $00, $00, $60, $00
        +Addr_To_ZP2 $0f, $f8, $00, $00

        ldx #$0
-       
        clc
        lda zp1_lsb
        sta scr_lo,x
        lda zp1_msb
        sta scr_hi,x
        
        lda zp2_lsb
        sta col_lo,x
        lda zp2_msb
        sta col_hi,x        
       
        clc
        lda zp1_lsb
        adc #BYTES_PER_ROW                  ;123 [bytes per row]
        sta zp1_lsb
        
        bcc +
        
        inc zp1_msb
+
        clc
        lda zp2_lsb
        adc #BYTES_PER_ROW                  ;123 [bytes per row]
        sta zp2_lsb
        
        bcc +
        
        inc zp2_msb
+
        inx
        cpx #ROWS;#$19
        bne -
        
        rts

Define_Palette

        ;reset palette
        lda #$00
        sta $d070
        
        ;program palette 10
        lda #$80
        tsb $d070
        
        ;define palette
        ldx #$0
        ldy #$0
        ;lda #$0
-
        stx $d100,y
        stx $d200,y
        stx $d300,y

        inx
        iny
        cpy #$10
        bne -
        
        ; blue
        lda #$00
        sta $d100,y
        
        lda #$07
        sta $d200,y
        
        lda #$0f
        sta $d300,y  
        
        iny
        
        ; green
        lda #$00
        sta $d100,y
        
        lda #$0f
        sta $d200,y
        
        lda #$00
        sta $d300,y
        
        iny
        
        ; yellow
        lda #$0f
        sta $d100,y
        
        lda #$0f
        sta $d200,y
        
        lda #$00
        sta $d300,y        
        
        iny
        
        ; red
        lda #$0f
        sta $d100,y
        
        lda #$00
        sta $d200,y
        
        lda #$00
        sta $d300,y        
        
        
        ;set palette 10 for usage
        lda $d070
        ora #$22;
        sta $d070
        
        rts

Base_Text

        ; put text 'mega65' into base layer
        +Addr_To_ZP1 $00,$00,$00,$00
        
        ldx #$0
        ldy #$0
--
        lda scr_lo,x
        sta zp1_lsb
        lda scr_hi,x
        sta zp1_msb
        
        ldz #$0
-        
        lda text,y
        sta [zp1_lsb],z
        
        iny
        inz
        inz
        
        cpy #$6
        bne +

        ldy #$0
+        
        cpz #$50
        bne -
        
        inx
        cpx #$19
        bne --

        ; use different colours, for the words 'Mega' & '65'
        +Addr_To_ZP1 $00,$00,$00,$00
        +Addr_To_ZP2 $0f,$f8,$00,$00
        
        ldx #$0
--
        lda scr_lo,x
        sta zp1_lsb
        lda scr_hi,x
        sta zp1_msb

        lda col_lo,x
        sta zp2_lsb
        lda col_hi,x
        sta zp2_msb        

        ldz #$0
-       
        clc
        lda [zp1_lsb],z
        cmp #$1a
        bcs +

        lda #$05
        jmp ++
+
        lda #$04
++      
        inz  
        sta [zp2_lsb],z
        dez
        
        inz
        inz
        
        cpz #$50
        bne -
        
        inx
        cpx #$19
        bne --
        
        rts
        