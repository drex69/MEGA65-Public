
zp1_lsb = $40
zp1_msb = $41
zp1_bnk = $42
zp1_rmb = $43

!macro Addr_To_ZP1 DDCCBBAA {

      lda #[[DDCCBBAA >> 0] & $ff]
      sta zp1_lsb
      lda #[[DDCCBBAA >> 8] & $ff]
      sta zp1_msb
      lda #[[DDCCBBAA >> 16] & $ff]
      sta zp1_bnk          
      lda #[[DDCCBBAA >> 24] & $ff]
      sta zp1_rmb
}

!macro EDMA_Execute_Job .job {
          
          ; Enhanced DMA job ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          
          lda #$00          ; DMA list exists in BANK 0
          sta $D702
          lda #>.job        ; Set MSB of DMA list address
          sta $D701
          lda #<.job        ; Set LSB of DMA list address
          sta $d705         ; execute, enhanced dma job
}

!macro EDMA_Set_Header .com, .src_skip, .dst_skip {

          ; set (com, qty, src_skip, dst_skip)
          
          lda #.com
          sta EDMA.com 

          lda #.src_skip
          sta EDMA.src_addr_skip
          
          lda #.dst_skip
          sta EDMA.dst_addr_skip
}

!macro EDMA_Set_Src_Address .addr {

          lda .addr+0
          sta dma_src_addr+0
          lda .addr+1
          sta dma_src_addr+1
          lda .addr+2
          sta dma_src_addr_lo
          lda .addr+3
          sta dma_src_addr_hi
}

!macro EDMA_Set_Dst_Address .addr {

          lda #[[.addr >> 0] & $ff]
          sta EDMA.dst_addr+0
          lda #[[.addr >> 8] & $ff]
          sta EDMA.dst_addr+1
          lda #[[.addr >> 16] & $ff]
          sta EDMA.dst_addr_lo
          lda #[[.addr >> 24] & $ff]
          sta EDMA.dst_addr_hi            
}
