!zone TILES

          ;*****************************************************
          ;          
          ; Starting from the top left, this routine will stack
          ; the FCM tiles from top to bottom, left to right.
          ;
          ;*****************************************************          

.generate

          ldx #$00
          ldy #$00

          +Addr_To_ZP1 SCREEN_MEM

          lda zp1_lsb
          sta screen_start+0
          lda zp1_msb
          sta screen_start+1

-- 
          lda screen_start+0
          sta zp1_lsb
          lda screen_start+1
          sta zp1_msb

          ; for the current row, store tile id \ address
-     
          ldz #$00
          lda char_index+0
          sta [zp1_lsb],z
          inz
          lda char_index+1
          sta [zp1_lsb],z

          ; next row of current column

          clc
          lda zp1_lsb
          adc #BYTES_PER_ROW
          sta zp1_lsb
          bcc +

          inc zp1_msb

          ; increase tile id, and address if needed
+     
          clc
          lda char_index+0
          adc #$01
          sta char_index+0
          bcc +

          inc char_index+1
+
          ; check if all rows in the current column are done
          iny
          cpy #ROWS
          bne -

          ; if so, reset row > 0, then move to next column
            
          ldy #$00
            
          clc
          lda screen_start+0
          adc #$02
          sta screen_start+0
          bcc +

          inc screen_start+1
+      
          inx
          cpx #COLUMNS
          bne --

          rts

screen_start
      !word $0000
char_index
      !word $1400
      

