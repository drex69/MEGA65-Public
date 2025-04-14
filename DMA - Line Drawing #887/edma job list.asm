!zone EDMA

; EDMA [Enhanced Direct Memory Access] Job List;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.job
             
;;;;; DMA Line Drawing [SOURCE] ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                               
                    !byte $97                             ; set X column bytes [LSB] token
.src_x_lsb          !byte $00                             
                    !byte $98                             ; set X column bytes [MSB] token
.src_x_msb          !byte $00                             
                    !byte $99                             ; set Y row bytes [LSB] token
.src_y_lsb          !byte $00
                    !byte $9a                             ; set Y row bytes [MSB] token
.src_y_msb          !byte $00
                    !byte $9b                             ; set slope [LSB] token
.src_sl_lsb         !byte $00
                    !byte $9c                             ; set slope [MSB] token
.src_sl_msb         !byte $00
                    !byte $9d                             ; set slope accumulator [LSB] token
.src_sl_acc_lsb     !byte $00
                    !byte $9e                             ; set slope accumulator [MSB] token
.src_sl_acc_msb     !byte $00
                    !byte $9f                             ; options token
.src_options        !byte $00 

;;;;; DMA Line Drawing [DESTINATION] ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                            
                    !byte $87                             ; set X column bytes [LSB] token
.dst_x_lsb          !byte #<COLUMN_STEP                             
                    !byte $88                             ; set X column bytes [MSB] token
.dst_x_msb          !byte #>COLUMN_STEP                             
                    !byte $89                             ; set Y row bytes [LSB] token
.dst_y_lsb          !byte #<ROW_STEP
                    !byte $8a                             ; set Y row bytes [MSB] token
.dst_y_msb          !byte #>ROW_STEP
                    !byte $8b                             ; set slope [LSB] token
.dst_sl_lsb         !byte $00
                    !byte $8c                             ; set slope [MSB] token
.dst_sl_msb         !byte $00
                    !byte $8d                             ; set slope accumulator [LSB] token
.dst_sl_acc_lsb     !byte $00
                    !byte $8e                             ; set slope accumulator [MSB] token
.dst_sl_acc_msb     !byte $00
                    !byte $8f                             ; options token
.dst_options        !byte $00

;;;;; DMA General ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


                    !byte $0b                             ; F011 [a][b] [11 \ 12 byte version]
                    !byte $83                             ; source skip token
.src_addr_skip      !byte $00
                    !byte $85                             ; destination skip token
.dst_addr_skip      !byte $00                             
                    !byte $80                             ; source high bank token
.src_addr_hi        !byte $00                             
                    !byte $81                             ; destination high bank token
.dst_addr_hi        !byte $00                              

                    !byte $00                             ; end of token list
              
.com                !byte $00                             ; command low byte: FILL = $03, COPY = $00 
.qty                !word $0000                           ; amount of bytes, to Fill \ Copy
.src_addr           !word $0000                           ; source address [or byte > FILL]
.src_addr_lo        !byte $00                             ; source low bank 
.dst_addr           !word $0000                           ; destination address
.dst_addr_lo        !byte $00                             ; destination low bank
                    !byte $00                             ; command high byte
                    !word $0000                           ; modulo (ignored due to selected commmand)
                    