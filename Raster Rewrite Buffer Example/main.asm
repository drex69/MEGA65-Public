; Raster Rewrite Buffer Example

!cpu m65
!to "rrb_example.prg", cbm

* = $2001

!basic
          
!source "macros.asm"


        ; SCREEN_MEM = $0044000
        ; COLOUR_MEM = $004a000

        ; SCREEN_RAM = $00010000
        ; COLOUR_RAM = $0ff80000

        ; LINESTEP = 500 ($1f4)
        ; CHRCOUNT = 128 ($80)
        ; TOTAL BYTES = 12500 ($30d4)

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
        
        ;+disable H640
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

        ; set linestep > 500
        lda #$f4
        sta $d058
        lda #$01
        sta $d059
     
        ; set chrcount > 128  
        lda #$80
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

        ; fill screen & colour memory with '0' [12500 bytes]
        +DMA_Job $03, $30d4, $01, $00000000, $01, $0044000    ;screen 
        +DMA_Job $03, $30d4, $01, $00000000, $01, $004a000    ;colour 
        
        ; fill base layer with 'char'
        !for i = 0 to 24
          
          +DMA_Job $03, $28, $01, $00000001e, $02, $0044000 + (i * $1f4)       

        !end
        
        ; copy rrb data, into, screen & colour memory
        +DMA_Job $00, $08, $01, scr_rrb_data, $01, $00044050 + ($1f4 * $b)         
        +DMA_Job $00, $08, $01, col_rrb_data, $01, $0004a050 + ($1f4 * $b)       
        
        ; copy screen & colour memory, to screen & colour ram
        +DMA_Job $00, $30d4, $01, $0044000, $01, $00010000         
        +DMA_Job $00, $30d4, $01, $004a000, $01, $ff080000              
        
        rts


scr_rrb_data
  !byte $a0,$00,$00,$14,$40,$01,$00,$00
col_rrb_data
  !byte $98,$ff,$00,$00,$10,$00,$00,$00
  
sprite_data
  !fill $40,$01
  
