; The MSX Red Book
; Chapter 7 - 40 Column Graphics Text

                            ORG     0E000H
                            LOAD    0E000H

                    ; ******************************
                    ; *   BIOS STANDARD ROUTINES   *
                    ; ******************************

                    RDSLT:  EQU     000CH
                    CNVCHR: EQU     00ABH
                    MAPXYC: EQU     0111H
                    SETC:   EQU     0120H

                    ; ******************************
                    ; *     WORKSPACE VARIABLES    *
                    ; ******************************

                    FORCLR: EQU     0F3E9H
                    ATRBYT: EQU     0F3F2H
                    CGPNT:  EQU     0F91FH
                    PATWRK: EQU     0FC40H
                    SCRMOD: EQU     0FCAFH
                    GRPACX: EQU     0FCB7H
                    GRPACY: EQU     0FCB9H

                    ; ******************************
                    ; *      CONTROL CHARACTERS    *
                    ; ******************************

                    CR:     EQU     13

E000    FE03        GFORTY: CP      3                   ; String type?
E002    C0                  RET     NZ                  ;
E003    3AAFFC              LD      A,(SCRMOD)          ; Mode
E006    FE02                CP      2                   ; Graphics?
E008    C0                  RET     NZ                  ;
E009    EB                  EX      DE,HL               ; HL->Descriptor
E00A    46                  LD      B,(HL)              ; B=String len
E00B    23                  INC     HL                  ;
E00C    5E                  LD      E,(HL)              ; Address LSB
E00D    23                  INC     HL                  ;
E00E    56                  LD      D,(HL)              ; DE->String
E00F    04                  INC     B                   ;
E010    05          GF2:    DEC     B                   ; Finished?
E011    C8                  RET     Z                   ;
E012    1A                  LD      A,(DE)              ; A=Chr from string
E013    CD19E0              CALL    GPRINT              ; Print it
E016    13                  INC     DE                  ;
E017    18F7                JR      GF2                 ; Next chr
E019    F5          GPRINT: PUSH    AF                  ;
E01A    C5                  PUSH    BC                  ;
E01B    D5                  PUSH    DE                  ;
E01C    E5                  PUSH    HL                  ;
E01D    FDE5                PUSH    IY                  ;
E01F    ED4BB7FC            LD      BC,(GRPACX)         ; BC=X coord
E023    ED5BB9FC            LD      DE,(GRPACY)         ; DE=Y coord
E027    CD39E0              CALL    GDC                 ; Decode chr
E02A    ED43B7FC            LD      (GRPACX),BC         ; New X coord
E02E    ED53B9FC            LD      (GRPACY),DE         ; New Y coord
E032    FDE1                POP     IY                  ;
E034    E1                  POP     HL                  ;
E035    D1                  POP     DE                  ;
E036    C1                  POP     BC                  ;
E037    F1                  POP     AF                  ;
E038    C9                  RET                         ;

E039    CDAB00      GDC:    CALL    CNVCHR              ; Check graphic
E03C    D0                  RET     NC                  ; NC=Header
E03D    2007                JR      NZ,GD2              ; NZ=Converted
E03F    FE0D                CP      CR                  ; Carriage Return?
E041    2873                JR      Z,GCRLF             ;
E043    FE20                CP      20H                 ; Other control?
E045    D8                  RET     C                   ; Ignore
E046    6F          GD2:    LD      L,A                 ;
E047    2600                LD      H,0                 ; HL=Chr code
E049    29                  ADD     HL,HL               ;
E04A    29                  ADD     HL,HL               ;
E04B    29                  ADD     HL,HL               ; HL=Chr*8
E04C    C5                  PUSH    BC                  ; X coord
E04D    D5                  PUSH    DE                  ; Y coord
E04E    ED5B20F9            LD      DE,(CGPNT+1)        ; Character set
E052    19                  ADD     HL,DE               ; HL->Pattern
E053    1140FC              LD      DE,PATWRK           ; DE->Buffer
E056    0608                LD      B,8                 ; Eight byte pattern
E058    C5          GD3:    PUSH    BC                  ;
E059    D5                  PUSH    DE                  ;
E05A    3A1FF9              LD      A,(CGPNT)           ; Slot ID
E05D    CD0C00              CALL    RDSLT               ; Get pattern
E060    FB                  EI                          ;
E061    D1                  POP     DE                  ;
E062    C1                  POP     BC                  ;
E063    12                  LD      (DE),A              ; Put in buffer
E064    13                  INC     DE                  ;
E065    23                  INC     HL                  ;
E066    10F0                DJNZ    GD3                 ; Next
E068    D1                  POP     DE                  ;
E069    C1                  POP     BC                  ;
E06A    3AE9F3              LD      A,(FORCLR)          ; Current colour
E06D    32F2F3              LS      (ATRBYT),A          ; Set ink
E070    FD2140FC            LD      IY,PATWRK           ; IY->Patterns
E074    D5                  PUSH    DE                  ;
E075    2608                LD      H,8                 ; Max dot rows
E077    CB7A        GD4:    BIT     7,D                 ; Pos Y coord?
E079    202A                JR      NZ,GD8              ;
E07B    CDBFE0              CALL    BMDROW              ; Bottom most row?
E07E    382B                JR      C,GD9               ; C=Y too large
E080    C5                  PUSH    BC                  ;
E081    2E06                LD      L,6                 ; Max dot cols
E083    FD7E00              LD      A,(IY+0)            ; A=Pattern row
E086    CB78        GD5:    BIT     7,B                 ; Pos X coord
E088    2015                JR      NZ,GD6              ;
E08A    CDC8E0              CALL    RMDCOL              ; Rightmost col?
E08D    3815                JR      C,GD7               ; C=X too large
E08F    CB7F                BIT     7,A                 ; Pattern bit
E091    280C                JR      Z,GD6               ; Z=0 Pixel
E093    F5                  PUSH    AF                  ;
E094    D5                  PUSH    DE                  ;
E095    E5                  PUSH    HL                  ;
E096    CD1101              CALL    MAPXYC              ; Map coords
E099    CD2001              CALL    SETC                ; Set pixel
E09C    E1                  POP     HL                  ;
E09D    D1                  POP     DE                  ;
E09E    F1                  POP     AF                  ;
E09F    07          GD6:    RLCA                        ; Shift pattern
E0A0    03                  INC     BC                  ; X=X+1
E0A1    2D                  DEC     L                   ; Finished dot cols?
E0A2    20E2                JR      NZ,GD5              ;
E0A4    C1          GD7:    POP     BC                  ; Initial X coord
E0A5    FD23        GD8:    INC     IY                  ; Next pattern byte
E0A7    13                  INC     DE                  ; Y=Y+1
E0A8    25                  DEC     H                   ; Finished dot rows?
E0A9    20CC                JR      NZ,GD4              ;
E0AB    D1          GD9:    POP     DE                  ; Initial Y coord
E0AC    210600              LD      HL,6                ; Step
E0AF    09                  ADD     HL,BC               ; X=X+6
E0B0    44                  LD      B,H                 ;
E0B1    4D                  LD      C,L                 ; BC=New X coord
E0B2    CDC8E0              CALL    RMDCOL              ; Rightmost col?
E0B5    D0                  RET     NC                  ;

E0B6    010000      GCRLF:  LD      BC,0                ; X=0
E0B9    210800              LD      HL,8                ;
E0BC    19                  ADD     HL,DE               ;
E0BD    EB                  EX      DE,HL               ; Y=Y+8
E0BE    C9                  RET                         ;

E0BF    E5          BMDROW: PUSH    HL                  ;
E0C0    21BF00              LD      HL,191              ; Bottom dot row
E0C3    B7                  OR      A                   ;
E0C4    ED52                SBC     HL,DE               ; Check Y coord
E0C6    E1                  POP     HL                  ;
E0C7    C9                  RET                         ; C=Below screen

E0C8    E5          RMDCOL: PUSH    HL                  ;
E0C9    21EF00              LD      HL,239              ; Rightmost dot col
E0CC    B7                  OR      A                   ;
E0CD    ED42                SBC     HL,BC               ; Check X coord
E0CF    E1                  POP     HL                  ;
E0D0    C9                  RET                         ; C=Beyond right

                            END