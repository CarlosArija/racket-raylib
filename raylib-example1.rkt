#lang racket

(require raylib/generated/unsafe)
(InitWindow 800 450 "Hello")
(do ()
  
  ;END LOOP WHEN WINDOW SHOULD CLOSE
  [(WindowShouldClose)]
  
  ;DRAWING
  (BeginDrawing)
  (ClearBackground RAYWHITE)
  (DrawText "Congrats! You created your first window!" 190 200 20 LIGHTGRAY)
  (EndDrawing))

;CLOSE WINDOW AT END
(CloseWindow)