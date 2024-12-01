#lang racket

(require raylib/generated/unsafe)
(define screen-width 800)
(define screen-height 450)

(InitWindow screen-width screen-height "Basic Screen Manager")
(SetTargetFPS 60)

(struct current-state (state frames))
  
(define (update-state s)
  (let ([cs (current-state-state s)]
        [cf (current-state-frames s)])
    (case cs
      ['LOGO
       (if (> cf 120)
           (current-state 'TITLE 0)
           (current-state 'LOGO (+ cf 1)))]
      ['TITLE
       (if (or (IsKeyPressed KEY_ENTER)
               (IsGestureDetected GESTURE_TAP))
           (current-state 'GAMEPLAY 0)
           (current-state 'TITLE 0))]
      ['GAMEPLAY
       (if (or (IsKeyPressed KEY_ENTER)
               (IsGestureDetected GESTURE_TAP))
           (current-state 'ENDING 0)
           (current-state 'GAMEPLAY 0))]
      ['ENDING
       (if (or (IsKeyPressed KEY_ENTER)
               (IsGestureDetected GESTURE_TAP))
           (current-state 'TITLE 0)
           (current-state 'ENDING 0))])))

;MAIN LOOP
(do(
    ;initialize in LOGO screen and check for state change every frame
    [state (current-state 'LOGO 0) (update-state state)])
  
  ;END LOOP WHEN WINDOW SHOULD CLOSE
  [(WindowShouldClose)]

  
  ;DRAWING
  (BeginDrawing)
  (ClearBackground RAYWHITE)
  (case (current-state-state state)
    ['LOGO
     (DrawText "LOGO SCREEN" 20 20 40 LIGHTGRAY)
     (DrawText "WAIT for 2 SECONDS..." 290 220 20 GRAY)]
    ['TITLE
     (DrawRectangle 0 0 screen-width screen-height GREEN)
     (DrawText "TITLE SCREEN" 20 20 40 DARKGREEN)
     (DrawText "PRESS ENTER or TAP to JUMP to GAMEPLAY SCREEN" 120 220 20 DARKGREEN)]
    ['GAMEPLAY
     (DrawRectangle 0 0 screen-width screen-height PURPLE)
     (DrawText "GAMEPLAY SCREEN" 20 20 40 MAROON)
     (DrawText "PRESS ENTER or TAP to JUMP to ENDING SCREEN" 130 220 20 MAROON)]
    ['ENDING
     (DrawRectangle 0 0 screen-width screen-height BLUE)
     (DrawText "ENDING SCREEN" 20 20 40 DARKBLUE)
     (DrawText "PRESS ENTER or TAP to RETURN to TITLE SCREEN" 120 220 20 DARKBLUE)]
    )
  (EndDrawing))

;CLOSE WINDOW AT END
(CloseWindow)