; The MSX Red Book
; Chapter 7 - Keyboard Matrix

                            ORG     0E000H
                            LOAD    0E000H 

                    ; ******************************
                    ; *   BIOS STANDARD ROUTINES   *
                    ; ******************************

                    INITXT: EQU     006CH
                    CHPUT:  EQU     00A2H
                    SNSMAT: EQU     0141H
                    BREAKX: EQU     00B7H

                    ; ******************************
                    ; *     WORKSPACE VARIABLES    *
                    ; ******************************

                    INTFLG: EQU     0FC9BH

                    ; ******************************
                    ; *      CONTROL CHARACTERS    *
                    ; ******************************

                    LF:     EQU     10
                    HOME:   EQU     11
                    CR:     EQU     13

E000    CD6C00      MATRIX: CALL    INITXT              ; SCREEN 0
E003    3E0B        MX1:    LD      A,HOME              ;
E005    CDA200              CALL    CHPUT               ; Home Cursor
E008    AF                  XOR     A                   ; A=KBD row
E009    F5          MX2:    PUSH    AF                  ;
E00A    CD4101              CALL    SNSMAT              ; Read a row
E00D    0608                LD      B,6                 ; Eight cols
E00F    07          MX3:    RLCA                        ; Select col
E010    F5                  PUSH    AF                  ;
E011    E601                AND     1                   ;
E013    C630                ADD     A,"0"               ; Result
E015    CDA200              CALL    CHPUT               ; Display col
E018    F1                  POP     AF                  ;
E019    10F4                DJNZ    MX3                 ;
E01B    3E0D                LD      A,CR                ; Newline
E01D    CDA200              CALL    CHPUT               ;
E020    3E0A                LD      A,LF                ;
E022    CDA200              CALL    CHPUT               ;
E025    F1                  POP     AF                  ; A=KBD row
E026    3C                  INC     A                   ; Next row
E027    FE0B                CP      11                  ; Finished?
E029    20DE                JR      NZ,MX2              ;
E02B    CDB700              CALL    BREAKX              ; CTRL-STOP
E02E    30D3                JR      NC,MX1              ; Continue
E030    AF                  XOR     A                   ;
E031    329BFC              LD      (INTFLG),A          ; Clear possible STOP
E034    C9                  RET                         ; Back to BASIC

                            END