;*****************************************************************************
; Author: Balin Becker
; Date: 05/10/2026
; Revision: 1.0
;
; Description:
;   A maze game. Find your way to the exit to win.
; Notes:
;   [o] is you
;   [ ] is navigable
;   [#] is a wall
;   [X] is the exit
;
;   WASD are used to navigate the maze.
;   You can't move through walls.
;   Reaching the exit wins the game.
;
;   Functions with changeable variables will have the variable after its header
;
;   KEY: (Most addresses are a key with a shorthand form of a word [ex: Enter = NTR])
;   M : MENU
;   G : GAME
;   GL : GAME LOOP
;   K : KEY
;   PRS : Press
;
; Register Usage:
; R0 Subroutine Returns [1:0]
; R1 Counter
; R2 
; R3 
; R4 
; R5 
; R6 
; R7 
;****************************************************************************/

.ORIG x3000

;Show Menu
;Wait for input (ENTER or ESC(?))
;Run game
MAIN_MENU
    JSR CLR_SCRN        ;Clear Screen

    JSR M_DISPLAY       ;Menu
    ADD R0 R0 #0        ;Update NZP
    BRz GL_ND
    
    ;GAMEPLAY
        ;Show hint
        ;Show Maze
        ;Player will start at S
        ;X is the end
        ;Pressing esc will go back to the menu
        ;Maze will update after something changes
            ;(Movement key is pressed and is valid)
            ;The screen refreshes with the hint reloading
            ;as well as the "new" maze with the player position updated
        ;Player char is swapped with the character it is moving to
            ;Players offset is saved
                ;Moving Up: Player Offset -Width
                ;Moving Down: Player Offset +Width
                ;Moving Left: Player Offset -1
                ;Moving Right: Player Offset +1
        ;Mazes have a solid border around the edge with the exception of the enterance and the exit
            ;Enterance and Exit are always in the top left and bottom right
    JSR G_GAME
    ADD R0 R0 #0
    BRz MAIN_MENU
    
    ;Win Screen
    JSR CLR_SCRN
    
    LEA R0  WINNER      ;R0 = Winner msg
    
    PUTS                ;Display Winner Msg
    
    AND R0  R0  #0
    ADD R0  R0  #10     ;R0 = Newline
    
    AND R1  R1  #0
    ADD R1  R1  #5      ;Number of new lines
    
GL_WIN_LOOP
    OUT
    ADD R1  R1  #-1
    BRp GL_WIN_LOOP 
    
GL_ND
    HALT

WINNER  .STRINGZ    "\nYou Win!"


;*****************************************************************************
; Description:
;   Displays and handles menu functionality
; Notes:
;   Returns win value [1:0]
;   1 : Reached the End
;   0 : Quit
;
; Register Usage:
; R0 Output
; R1 Input Check
; R2 Player Offset (From Maze Starting Pos)
; R3 Navigation Check
; R4 
; R5 
; R6 
; R7 
;****************************************************************************/
G_MAZE_SCALE    .FILL   #12 ;Make one more than actual size

G_GAME:
    ST  R1  G_GAME_R1
    ST  R2  G_GAME_R2
    ST  R3  G_GAME_R3
    ST  R7  G_GAME_R7

    AND R0  R0  #0      ;Reset Return Val

    ;Find Player
    LEA R2  G_MAZE
    LD  R1  G_MAZE_SCALE
    ADD R2  R2  R1  ;R2 = G_MAZE + SCALE
    
G_GAME_MLOOP
    JSR CLR_SCRN
    ADD R0  R0  #0  ;Update Returns
    BRp G_GAME_DONE
    
    LEA R0  G_HINT  ;Load Hint
    PUTS
    
    LEA R0  G_MAZE  ;Load Maze
    PUTS
    
    
G_GAME_ILOOP
    GETC            ;Get input
    
    ;INPUT CHECK
    LD  R1 G_GAME_W
    NOT R1 R1
    ADD R1 R1 #1
    ADD R1 R1 R0    ;R1 = -Up + Input
    BRz G_GAME_UP
    
    LD  R1 G_GAME_S
    NOT R1 R1
    ADD R1 R1 #1
    ADD R1 R1 R0    ;R1 = -Down + Input
    BRz G_GAME_DOWN
    
    LD  R1 G_GAME_A
    NOT R1 R1
    ADD R1 R1 #1
    ADD R1 R1 R0    ;R1 = -Right + Input
    BRz G_GAME_LEFT
    
    LD  R1 G_GAME_D
    NOT R1 R1
    ADD R1 R1 #1
    ADD R1 R1 R0    ;R1 = -Right + Input
    BRz G_GAME_RIGHT
    
    LD  R1  G_GAME_ESC
    NOT R1 R1
    ADD R1 R1 #1
    ADD R1 R1 R0
    BRz G_ESCAPE
    
    BR G_GAME_ILOOP

G_GAME_UP
    LD  R1  G_MAZE_SCALE
    NOT R1  R1
    ADD R1  R1  #1      ;R1 = -G_MAZE_SCALE
    
    ADD R1  R1  R2      ;R1 = Player Position - Scale; R1 = Up One
    
    JSR G_UPD_PLR
    
    BR G_GAME_MLOOP
    
G_GAME_DOWN
    LD  R1  G_MAZE_SCALE
    
    ADD R1  R1  R2      ;R1 = Player Position + Scale; R1 = Down One
    
    JSR G_UPD_PLR

    BR G_GAME_MLOOP
    
G_GAME_LEFT
    AND R1  R1  #0
    ADD R1  R1  #-1      ;R1 = 1
    
    ADD R1  R1  R2      ;R1 = Player Position - 1; R1 = Left One
    
    JSR G_UPD_PLR

    BR G_GAME_MLOOP
    
G_GAME_RIGHT
    AND R1  R1  #0
    ADD R1  R1  #1      ;R1 = 1
    
    ADD R1  R1  R2      ;R1 = Player Position + 1; R1 = Right One
    
    JSR G_UPD_PLR
    
    BR G_GAME_MLOOP
    
    
G_ESCAPE
    AND R0 R0 #0    ;R0 = 0
    
G_GAME_DONE
    LD  R1  G_GAME_R1
    LD  R2  G_GAME_R2
    LD  R3  G_GAME_R3
    LD  R7  G_GAME_R7
    
    RET
G_GAME_R1   .BLKW   1
G_GAME_R2   .BLKW   1
G_GAME_R3   .BLKW   1
G_GAME_R7   .BLKW   1
    
G_HINT      .STRINGZ    "Get to the Exit!\n"

G_GAME_W    .FILL   #119 ;w
G_GAME_S    .FILL   #115 ;s
G_GAME_A    .FILL   #97  ;a
G_GAME_D    .FILL   #100 ;d
G_GAME_ESC  .FILL   #27  ;ESC

;If I do randomized mazes switch to BLKW for Height * Width (11 * 11)
G_MAZE        .STRINGZ    "###########\no   # #   #\n### # # # #\n# # #   # #\n# # # ### #\n#   #   # #\n# ####### #\n#   #     #\n### # ### #\n#     #   X\n###########\n"
; ###########\n
; o   # #   #\n
; ### # # # #\n
; # # #   # #\n
; # # # ### #\n
; #   #   # #\n
; # ####### #\n
; #   #     #\n
; ### # ### #\n
; #     #   X\n
; ###########\n


PRS_NTR     .STRINGZ    "-Press Enter to Continue-"
PRS_ESC     .STRINGZ    "<- Esc to go back"

;*****************************************************************************
; Description:
;   Checks and Moves player
; Notes:
;   If the passed New Position is valid, then the player will switch
;   Returns 1 if player moved on an exit
;
; Register Usage:
; R0 
; R1 New Position
; R2 Player Position
; R3 Navigation Value
; R4 Temp - Player Contents
; R5 Temp - New Pos Contents
; R6 
; R7 
;****************************************************************************/
G_MAZE_NAV      .FILL   #32
G_MAZE_EXIT     .FILL   #88

G_UPD_PLR:
    ST  R3  G_UPD_PLR_R3
    ST  R4  G_UPD_PLR_R4
    ST  R5  G_UPD_PLR_R5
    
    AND R0  R0  #0      ;R0 = 0 By default, 
    
    LD  R3  G_MAZE_NAV
    NOT R3  R3
    ADD R3  R3  #1      ;R3 = -G_MAZE_NAV
    
    LDR R4  R1  #0
    ADD R4  R4  R3      ;R4 = New Pos Val - G_MAZE_NAV
    BRz    G_UPD_PLR_MOVE
    
    ;else, check if X
    LD  R3  G_MAZE_EXIT
    NOT R3  R3
    ADD R3  R3  #1      ;R3 = -G_MAZE_EXIT
    
    LDR R4  R1  #0
    ADD R4  R4  R3      ;R4 = New Pos Val - G_MAZE_EXIT
    BRz    G_UPD_PLR_WIN
    
    BRnp   G_UPD_PLR_DONE
    
G_UPD_PLR_MOVE  
    
    LDR R4  R2  #0      ;R4 = Player Contents
    LDR R5  R1  #0      ;R5 = New Pos Contents
    
    STR R4  R1  #0
    STR R5  R2  #0
    
    ADD R2  R1  #0      ;R2 = R1
    BR G_UPD_PLR_DONE
    
G_UPD_PLR_WIN
    ADD R0  R0  #1
    
G_UPD_PLR_DONE
    LD  R3  G_UPD_PLR_R3
    LD  R4  G_UPD_PLR_R4
    LD  R5  G_UPD_PLR_R5
    
    RET
    
G_UPD_PLR_R3    .BLKW   1
G_UPD_PLR_R4    .BLKW   1
G_UPD_PLR_R5    .BLKW   1

;*****************************************************************************
; Description:
;   Displays and handles menu functionality
; Notes:
;   NZP will need to be updated upon return
;   R0 is reserved for console outputs and the return value [1:0]
;   1 : Play
;   0 : Quit
;
; Register Usage:
; R0 Output
; R1 Newline Char
; R2 Input Check
; R3 
; R4 
; R5 
; R6 
; R7 
;****************************************************************************/
M_DISPLAY:
    ;Store Old Registers
    ST  R1  M_DISPLAY_R1
    
    AND R1 R1 #0
    ADD R1 R1 #10           ;R1 = newline
    
    LEA R0  M_TITLE         ;Load Title
    PUTS                    ;Display Title
    
    LEA R0  M_HTP           ;Load Guide
    PUTS    
    
    ADD R0 R1 #0            ;R0 = R1
    OUT
    
    LEA R0  PRS_NTR         ;Load Prompt
    PUTS                    ;Display
    
    ADD R0 R1 #0            ;R0 = R1
    OUT
    
    LEA R0  PRS_ESC         ;Load Prompt
    PUTS
    
M_DISPLAY_PQLOOP
    GETC                    ;Read Char
    
    ADD R2 R1 #0            ;R2 = R1
    NOT R2  R2              ;R2 = ~10
    ADD R2  R2  #1          ;R2 = -10
    ADD R2  R2  R0          ;R2 = -10 + R0
    BRz M_DISPLAY_PLAY
    
    LD  R2  M_ESC           ;R2 = 27
    NOT R2  R2              ;R2 = ~27
    ADD R2  R2  #1          ;R2 = -27
    ADD R2  R2  R0          ;R2 = -27 + R0
    BRz M_DISPLAY_QUIT
    BR  M_DISPLAY_PQLOOP
    
    
M_DISPLAY_QUIT
    AND R0  R0  #0
    BR  M_DISPLAY_DONE
    
M_DISPLAY_PLAY
    AND R0  R0  #0        ;R0 = 0
    ADD R0  R0  #1        ;R0 = 1
    BR  M_DISPLAY_DONE
    
M_DISPLAY_DONE
    ;Load Old Registers
    LD  R1  M_DISPLAY_R1
    
    RET
M_DISPLAY_R1    .BLKW   1

M_ESC       .FILL       #27
M_TITLE     .STRINGZ    "\n>======-MAZE-GAME-======<\n" ;25 Char long
M_HTP       .STRINGZ    "\n[o] is you\n[ ] is navigable\n[#] is a wall\n[X] is the exit\nWASD To Move\nReach the Exit to Win\n"

;*****************************************************************************
; Description:
;   Hides Previous Screen
; Notes:
;   Inserts a bunch of newlines
;   The amount can be changed by a variable at the top of the function
;
; Register Usage:
; R0 Newline
; R1 Line Counter
; R2 
; R3 
; R4 
; R5 
; R6 
; R7 
;****************************************************************************/
CLR_SCRN_LNS    .FILL #15   ;Number of lines to clear
CLR_SCRN:
    ST  R0  CLR_SCRN_R0
    ST  R1  CLR_SCRN_R1
    
    AND R0 R0 #0
    ADD R0 R0 #10           ;R0 = newline
    LD  R1  CLR_SCRN_LNS    ;Load # Lines

CLR_SCRN_LOOP
    BRz CLR_SCRN_DONE
    OUT                     ;Output newline
    ADD R1 R1 #-1           ;Decrement Counter
    BR  CLR_SCRN_LOOP

CLR_SCRN_DONE
    LD  R0  CLR_SCRN_R0
    LD  R1  CLR_SCRN_R1

    RET
CLR_SCRN_R1 .BLKW   1
CLR_SCRN_R0 .BLKW   1

.END