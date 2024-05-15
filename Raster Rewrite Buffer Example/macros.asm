
!macro DMA_Job com, amount, source_skip, source_addr, target_skip, target_addr {
  
          sta $d707                             ; enhanced [inline]
          !byte $0b                             ; F011 [a][b] [11 \ 12 byte version]
          !byte $83                             ; source skip token
          !byte source_skip                     ; source skip amount          
          !byte $85                             ; target skip token
          !byte target_skip                     ; target skip amount
          !byte $80                             ; source high bank token
          !byte [[source_addr >> 24]]           ; source high bank
          !byte $81                             ; target high bank token
          !byte [[target_addr >> 24]]           ; target high bank
          !byte $00                             ; end of token list
          !byte com                             ; command low byte: FILL = $03, COPY = $00 
          !word amount                          ; amount of bytes, to Fill \ Copy
          !word source_addr & $ffff             ; source address, for COPY \ Fill value
          !byte [[source_addr >> 16] & $ff]     ; source low bank
          !word target_addr & $ffff             ; target address
          !byte [[target_addr >> 16] & $ff]     ; target low bank
          !byte $00                             ; command high byte
          !word $0000                           ; modulo (ignored due to selected commmand)
} 

