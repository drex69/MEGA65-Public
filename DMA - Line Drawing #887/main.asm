; DMA Line Drawing v7.0
;
; Qty byte test
;
; Screen is configured > [320 x 200]

!cpu m65
!to "main.prg", cbm

* = $2001

!basic

!source "idma macros.asm"
!source "macros.asm"

!address SCREEN_MEM = $00000800
!address FCM_MEM    = $00050000
!address COLOUR_MEM = $ff080000


ROWS                = $19 ; 25
COLUMNS             = $28 ; 40
BYTES_PER_ROW       = $50 ; 80
CHARS_PER_ROW       = $28 ; 40

COLUMN_STEP         = ROWS * $40 - $08
ROW_STEP            = $0008 - $0008


          ; SETUP ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

          jsr SYSTEM.setup
          
          ; clear all screen & colour memory with '0'
          +IDMA_Job $03, $7d0, $01, $00000000, $1, SCREEN_MEM
          +IDMA_Job $03, $7d0, $01, $00000000, $1, COLOUR_MEM

          ; clear fcm data [64 bytes x 1000 chars] [40 x 25] with colour black '0'
          +IDMA_Job $03, $fa00, $01, $00000000, $01, FCM_MEM      
          
          ; place FCM tiles [ from top > bottom, left > right ]
          jsr TILES.generate

          ; DRAWING ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

          ; horizontal line > qty = $0140 [320]

          +EDMA_Set_Header $03,$01,$00
          
          +EDMA_Set_Dst_Address $00050320
          
          ; set colour
          lda #$02
          sta EDMA.src_addr + 0
          
          ; set qty > 320
          lda #$40
          sta EDMA.qty + 0
          
          lda #$01
          sta EDMA.qty + 1
          
          ; set line options > X positive
          lda #%10000000
          sta EDMA.dst_options
          
          +EDMA_Execute_Job (EDMA.job)

          ; vertical line  > qty = $00c8 [200]

          +EDMA_Set_Header $03,$01,$00
          
          +EDMA_Set_Dst_Address $000576c7
          
          ; set colour
          lda #$02
          sta EDMA.src_addr + 0
          
          ; set qty > 200
          lda #$c8
          sta EDMA.qty + 0
          
          lda #$00
          sta EDMA.qty + 1
          
          ; set line options > Y positive
          lda #%11000000
          sta EDMA.dst_options
          
          +EDMA_Execute_Job (EDMA.job)                    
                    
-         jmp -

          rts


!source "system.asm"
!source "tiles.asm"
!source "edma job list.asm"



