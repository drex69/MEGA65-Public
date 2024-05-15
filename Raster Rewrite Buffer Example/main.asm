; Raster Rewrite Buffer Example

!cpu m65
!to "rrb_example.prg", cbm

* = $2001

!basic
          
!source "macros.asm"

!address  ROWS = $19

!address  SCREEN_MEM = $0044000
!address  COLOUR_MEM = $004a000

!address  SCREEN_RAM = $00010000
!address  COLOUR_RAM = $ff080000

!address  LINESTEP = $58                ; 88
!address  CHRCOUNT = LINESTEP / 2       ; 2c
!address  TOTAL_BYTES = ROWS * LINESTEP ; 898
        
        
        ; disable H640
        lda #$80
        trb $d031        
        
        ; set screen pointer > $00010000
        lda #$00
        sta $d060
        lda #$00
        sta $d061
        lda #$01
        sta $d062
        lda $d063
        and #%11110000
        sta $d063        
   
        ; set linestep
        lda #LINESTEP
        sta $d058
        lda #$00
        sta $d059        
    
        ; set chrcount
        lda #CHRCOUNT
        sta $d05e
        lda $d063
        and #%11001111
        sta $d063             

        ; enable chr16
        lda $d054
        ora #$5
        sta $d054
        
        
        ; load in sprite data > address 5.0000
        +DMA_Job $00, $40 * $01 , $01, sprite_data, $01, $00050000        

        ; fill screen & colour memory with '0' [898 bytes]
        +DMA_Job $03, TOTAL_BYTES, $01, $00000000, $01, SCREEN_MEM    ;screen 
        +DMA_Job $03, TOTAL_BYTES, $01, $00000000, $01, COLOUR_MEM    ;colour 
        
        ;rts
        
        ; fill base layer with 'char'
        !for i = 0 to 24
          
          +DMA_Job $03, $28, $01, $00000001e, $02, SCREEN_MEM + (i * LINESTEP)       

        !end
        
        ; copy rrb data, into, screen & colour memory
        +DMA_Job $00, $08, $01, scr_rrb_data, $01, $00044050 + (LINESTEP * $b)         
        +DMA_Job $00, $08, $01, col_rrb_data, $01, $0004a050 + (LINESTEP * $b)       
        
        ; copy screen & colour memory, to screen & colour ram
        +DMA_Job $00, TOTAL_BYTES, $01, SCREEN_MEM, $01, SCREEN_RAM         
        +DMA_Job $00, TOTAL_BYTES, $01, COLOUR_MEM, $01, COLOUR_RAM              
        
        rts


scr_rrb_data
  !byte $a0,$00,$00,$14,$40,$01,$00,$00
col_rrb_data
  !byte $98,$ff,$00,$00,$10,$00,$00,$00
  
sprite_data
  !fill $40,$01
  
