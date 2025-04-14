!zone SYSTEM

.setup

          ; turn off HOTREGS
          ;lda #$80
          ;trb $d05d
          
          ; change background colour
          lda #$0d
          sta $d020
          lda #$0f
          sta $d021

          ; CPU setting [$40 = custom \ 41 = 40mhz] 
          lda #$41
          sta $00
          
          ; disable H640
          lda #$80
          trb $d031
          
          ; set bytes per row
          lda #BYTES_PER_ROW
          sta $d058
          lda #$00
          sta $d059
          
          ; set chars per row
          lda #CHARS_PER_ROW
          sta $d05e
          
          lda $d063
          and #%11001111
          sta $d063

          ; number of rows
          lda #ROWS
          sta $d07b  
          
          ; enable chr16 + fcm_hi
          lda #$05
          tsb $d054

          ; set screen pointer
          lda #[[SCREEN_MEM >> 0] & $ff]
          sta $d060
          lda #[[SCREEN_MEM >> 8] & $ff]
          sta $d061
          lda #[[SCREEN_MEM >> 16] & $ff]
          sta $d062
          
          lda $d063
          and #%11110000
          sta $d063
          
          ; set correct text horizontal position
          lda #$50
          sta $d04c
          
          rts            
          
