#lang racket

(require raylib/generated/unsafe)
(require raylib/raymath/unsafe)
(require ffi/unsafe)

(define screen-width 800)
(define screen-height 450)
(define max-buildings 100)
(define player (make-Rectangle 400.0 280.0 40.0 40.0))

(InitWindow screen-width screen-height "Basic Screen Manager")
(SetTargetFPS 60)

(define (make-buildings lst pos)
  (if (= (length lst) max-buildings)
      lst ;return the list if all buildings were created          
      (let* ([w (* 1.0 (GetRandomValue 50 200))]
             [h (* 1.0 (GetRandomValue 100 800))]
             [y (- screen-height 130.0 h)]
             [x (- pos 6000.0)])
        (make-buildings (cons (make-Rectangle x y w h) lst) (+ pos w)))))

(define (make-buildings2)
  (for/fold ([pos 0] [res '()] #:result res)
            ([i (in-range max-buildings)])
    (let ([w (* 1.0 (GetRandomValue 50 200))])
      (values
       (+ pos w)
       (let* ([h (* 1.0 (GetRandomValue 100 800))]
              [y (- screen-height 130.0 h)]
              [x (- pos 6000.0)])
         (cons (make-Rectangle x y w h) res))))))

(define buildings (make-buildings2))
(println (Rectangle-width (first buildings)))
 
(define (make-colors)
  (build-list max-buildings
              (λ (i) (make-Color (GetRandomValue 200 240)
                                 (GetRandomValue 200 240)
                                 (GetRandomValue 200 250)
                                 255))))

(define colors (make-colors))

(define camera
  (make-Camera2D
   (make-Vector2 (+ 20.0 (Rectangle-x player)) (+ 20.0 (Rectangle-y player)))
   (make-Vector2 (* 0.5 screen-width) (* 0.5 screen-height))
   0.0 1.0))

(struct current-state (ply cam))

(define (update-state s)
  (let* ([updated-ply (update-player (current-state-ply s))]
         [updated-cam (update-camera (current-state-cam s) updated-ply)])
    (struct-copy current-state s
                 [ply updated-ply]
                 [cam updated-cam])))

(define (update-player ply)
  (let ([old-x (Rectangle-x ply)])
    (let* ([new-x (if (IsKeyDown KEY_RIGHT) (+ old-x 2.0) old-x)]
           [new-x2 (if (IsKeyDown KEY_LEFT) (- new-x 2.0) new-x)])
      (struct-copy Rectangle ply [x new-x2]))))

(define (update-camera cam ply)
  (if (IsKeyDown KEY_R)
      (struct-copy Camera2D camera [target (Camera2D-target cam)])
      (let([old-target (Camera2D-target cam)]
           [old-rotation (Camera2D-rotation cam)]
           [old-zoom (Camera2D-zoom cam)])
        (let* ([new-target (make-Vector2 (+ 20.0 (Rectangle-x ply)) (+ 20.0 (Rectangle-y ply)))]
               [new-rotation (if (IsKeyDown KEY_A) (- old-rotation 1.0) old-rotation)]
               [new-rotation2 (if (IsKeyDown KEY_S) (+ new-rotation 1.0) new-rotation)]
               [new-rotation3 (Clamp new-rotation2 -40.0 40.0)]
               [new-zoom (+ old-zoom (* 0.05 (GetMouseWheelMove)))]
               [new-zoom2 (Clamp new-zoom 0.1 3.0)])
          ; *********** RESET CAMERA _ TODO ***********
          (struct-copy Camera2D cam
                       [target new-target]
                       [rotation new-rotation3]
                       [zoom new-zoom2])))))

;MAIN LOOP
(do(
    ;initialize and update state change every frame
    [state (current-state player camera) (update-state state)])
  
  ;END LOOP WHEN WINDOW SHOULD CLOSE
  [(WindowShouldClose)]

  
  ;DRAWING
  (BeginDrawing)
  (ClearBackground RAYWHITE)
  (BeginMode2D (current-state-cam state))
  (DrawRectangle -6000 320 13000 8000 DARKGRAY)
  (for ([b buildings][c colors])
    (DrawRectangleRec b c))

  (DrawRectangleRec (current-state-ply state) RED)
  (DrawLineV (make-Vector2
              (Vector2-x (Camera2D-target (current-state-cam state)))
              (* 10.0 (- screen-height)))
             (make-Vector2
              (Vector2-x (Camera2D-target (current-state-cam state)))
              (* 10.0 screen-height))
             GREEN)
  (DrawLineV (make-Vector2
              (* 10.0 (- screen-width))
              (Vector2-y (Camera2D-target (current-state-cam state))))
             (make-Vector2
              (* 10.0 screen-width)
              (Vector2-y (Camera2D-target (current-state-cam state))))
             GREEN)

  (EndMode2D)
  (DrawText "SCREEN AREA" 640 10 20 RED)

  (DrawRectangle 0 0 screen-width 5 RED)
  (DrawRectangle 0 5 5 (- screen-height 10) RED)
  (DrawRectangle (- screen-width 5) 5 5 (- screen-height 10) RED)
  (DrawRectangle 0 (- screen-height 5) screen-width 5 RED)

  (DrawRectangle 10 10 250 113 (Fade SKYBLUE 0.5))
  (DrawRectangleLines 10 10 250 113 BLUE)

  (DrawText "Free 2d camera controls:" 20 20 10 BLACK)
  (DrawText "- Right/Left to move Offset" 40 40 10 DARKGRAY)
  (DrawText "- Mouse Wheel to Zoom in-out" 40 60 10 DARKGRAY)
  (DrawText "- A / S to Rotate" 40 80 10 DARKGRAY)
  (DrawText "- R to reset Zoom and Rotation" 40 100 10 DARKGRAY)
  (EndDrawing))

;CLOSE WINDOW AT END
(CloseWindow)