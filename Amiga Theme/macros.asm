
zp2_lsb = $30
zp2_msb = $31
zp2_bnk = $32
zp2_rmb = $33

zp1_lsb = $40
zp1_msb = $41
zp1_bnk = $42
zp1_rmb = $43

;LINESTEPMSB, LINESTEPLSB
!macro V4_Set_Byte_Per_Row .msb, .lsb {                              

      ;number of bytes to advance, to next row > LINESTEP 
      lda #.lsb      
      sta $d058

      lda #.msb
      sta $d059
}


;CHRCOUNT
!macro V4_Set_Char_Per_Row .msb, .lsb {    
                        
      ;number of characters, in a row > CHRCOUNT
      lda #.lsb      
      sta $d05e

      lda $d063
      and #$cf
      ora #.msb
      sta $d063      
}

;SCRNPTRMB, SCRNPTRBNK, SCRNPTRMSB, SCRNPTRLSB 
!macro V4_Set_Scrn_Ptr .rmb, .bnk, .msb, .lsb {

      ;set screen, to a another part of memory
      lda #.lsb    
      sta $d060
      
      lda #.msb
      sta $d061

      lda #.bnk
      sta $d062
 
      lda $d063
      and #$f0      
      ora #.rmb
      sta $d063
}

!macro Addr_To_ZP1 .rmb, .bank, .msb, .lsb {
      
      lda #.lsb
      sta zp1_lsb
      lda #.msb
      sta zp1_msb
      lda #.bank
      sta zp1_bnk
      lda #.rmb
      sta zp1_rmb
}

!macro Addr_To_ZP2 .rmb, .bank, .msb, .lsb {
      
      lda #.lsb
      sta zp2_lsb
      lda #.msb
      sta zp2_msb
      lda #.bank
      sta zp2_bnk
      lda #.rmb
      sta zp2_rmb
}

!macro GenRndNumM65 {

 -    bit $d7fe       ;wait for bit 7, to clear
      bmi -  
  
      lda $d7ef       ;then, read random value from this address       
}

!macro DMA_Job com, skip, amount, source_hibank, source_lobank, source_addr, dest_hibank, dest_lobank, dest_addr {
  
          sta $d707
          !byte $0b              ; F011 [a][b] [11 \ 12 byte version]
          !byte $85              ; skip token
          !byte skip             ; skip amount
          !byte $80              ; rmb token
          !byte source_hibank    ; Source hibank [Copy]
          !byte $81              ; rmb token
          !byte dest_hibank      ; Destination hibank
          !byte $00              ; end of token list
          !byte com              ; Command low byte: [FILL $03 | COPY $00]
          !word amount           ; Amount of bytes, to be Filled \ Copied
          !word source_addr      ; Source address [COPY] \ [Fill] value
          !byte source_lobank    ; Source bank [COPY]
          !word dest_addr        ; Destination address
          !byte dest_lobank      ; Destination lobank
          !byte $00              ; Command high byte
          !word $0000            ; Modulo (ignored due to selected commmand)
}