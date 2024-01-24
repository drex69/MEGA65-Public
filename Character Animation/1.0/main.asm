; CHARACTER ANIMATION ;

!cpu m65
!to "tut2.prg", cbm

* = $2001

!basic

!source "d:\c64 studio code\_default\constants.asm"
!source "d:\c64 studio code\_default\my_macros.asm"
!source "d:\c64 studio code\_default\vic2_macros.asm"
!source "d:\c64 studio code\_default\vic3_macros.asm"
!source "d:\c64 studio code\_default\vic4_macros.asm"
  
  +V3_Disable_H640
  
  +V4_Set_Char_Per_Row $00,$28
  +V4_Set_Byte_Per_Row $00,$28
  
  +V4_Set_CharacterSet_Ptr $00,$38,$00
  
  +V3_Disable_Fast
  
  lda #$f
  sta $d020
  sta $d021
  
  lda $d016
  ora #$10        ;Turn ON MCM
  sta $d016
  
  lda #$9
  sta $d022       ;MULTI1 COLOR [AA]
  
  lda #$a
  sta $d023       ;MULTI1 COLOR [BB]
  
  lda #$00
  sta $40
  lda #$00
  sta $41
  lda #$f8
  sta $42
  lda #$0f
  sta $43
  
  ldz #$0
  
  lda #$f         ;CHAR COLOR
  sta [$40],z

  lda #$10;0
  ldx #$0
  ldy #$0
-  
  ldx $d012
  cpx #$0
  bne -
  
  +Delay
  
  sta $800,y
  iny
  ;inz 
  inc 
  cmp #$16;5
  bne -
  
  lda #$10;0
  jmp -
  
  rts
 
* = $3800 - 2
!binary "multi.64c"
