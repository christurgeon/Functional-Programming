;; Constract: insert-at-index : (number or list) * list -> list 
;; Purpose: take elem and put it at index location in retlist (0-based indexing)
;; Example: (insert-at-index `(5) 1  `(1 2 3)) should produce (1 (5) 3) 
;; Definition:
(define (insert-at-index elem index retlist)
  (cond ((and (zero? index) (pair? elem))       (cons elem (cdr retlist)))
        ((and (zero? index) (not (pair? elem))) (cons (list elem) (cdr retlist)))
        (else
          (cons (car retlist) (insert-at-index elem (- index 1) (cdr retlist))))
  )
)

;; Contract: append-at-index :  (number) * list * list -> list
;; Purpose: take elem and append it to the list at index location in retlist (0-based indexing)
;; Example: (append-at-index 5 2 `(() () (1 2))) should produce (() () (1 2 5)) 
;; Definition:
(define (append-at-index elem index retlist)
  (cond ((null? retlist) (list elem))
        ((zero? index) (cons (append (car retlist) (list elem)) (cdr retlist)))
        (else
         (cons (car retlist)
               (append-at-index elem (- index 1) (cdr retlist)))))
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; Contract: lis_slow : list -> list
;; Purpose: take a list of numbers and return the longest non-decreasing subsequence (2^N)
;; Example: (lis_fast `(1 2 3 3 5 4 9)) should produce (1 2 3 3 5 9)
;; Definition:
(define (lis_slow sequence)
  (let ((all_subsequences (outer_loop_bf sequence `(()) 0)))
    (longest (cdr all_subsequences) (car all_subsequences))
  )
)

;; Contract: outer_loop_bf : list * list * number -> list
;; Purpose: iterate through sequence and crete sublists starting from index i
;; Example: (outer_loop_bf `(1 2 3) `(()) 0) should produce (() (1) (2) (1 2) (3) (1 3) (2 3) (1 2 3))
;; Definition:
(define (outer_loop_bf sequence lists i)
  (if (= i (length sequence)) lists
      (begin
        (outer_loop_bf sequence (append lists (inner_loop_bf sequence lists i 0)) (+ 1 i)))
  ) 
)

;; Contract: inner_loop_bf : list * list * number * number -> list
;; Purpose: Append element at index i to sublists of lists at index >= j 
;; Example: (inner_loop_bf `(1 2) `(() (1) (2) (1 2)) 0 2) should produce (() (1) (2 1) (1 2 1))
;; Definition:
(define (inner_loop_bf sequence lists i j)
  (if (= j (length lists)) lists
      (inner_loop_bf sequence
        (insert-at-index (append (list-ref lists j) (list (list-ref sequence i))) j lists)
        i
        (+ 1 j)
      )
  )
)

;; Contract: unsorted : list -> boolean
;; Purpose: return true if a list is unsorted, false otherwise
;; Example: (unsorted? `(1 2 2 3)) should produce false 
;; Definition:
(define (unsorted? lst)
  (cond ((null? lst) #f)
        ((eq? (length lst) 1) #f)
  ((>= (car (cdr lst)) (car lst))
    (unsorted? (cdr lst)))
  (else #t))
)

;; Contract: longest : list * list -> list 
;; Purpose: take in a list of lists and find the longest sorted list within it
;; Example: (longest `((1 2) (1 2 3) (1 2 3 4)) `((1 2)) should produce (1 2 3 4)
;; Definition:
(define (longest lis current_longest)
  (cond ((null? lis) current_longest)
        ((unsorted? (car lis)) (longest (cdr lis) current_longest))
        ((> (length (car lis)) (length current_longest)) (longest (cdr lis) (car lis)))
        ((<= (length (car lis)) (length current_longest)) (longest (cdr lis) current_longest))
  )
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; Contract: lis_fast : list -> list
;; Purpose: take a list of numbers and return the longest non-decreasing subsequence (Polynomial)
;; Example: (lis_fast `(1 2 3 3 5 4 9)) should produce (1 2 3 3 5 9)
;; Definition:
(define (lis_fast input_sequence)
  (if (null? input_sequence) `()
  (let
    ((solutions (append-at-index (car input_sequence) 0 (initialize_empty_list input_sequence `()) )))
    (longest (outer-loop input_sequence solutions 1) `())
  ))
)

;; Contract: initialize_empty_list : list * list -> list
;; Purpose: Take a list and return another list of same size where each element is empty list
;; Example: (initialize_empty_list `(1 2 3) `()) should produce (() () ())
;; Definition:
(define (initialize_empty_list origlist retlist)
  (if (null? origlist) retlist
      (initialize_empty_list (cdr origlist) (append retlist `(())))
  )
)

;; Contract: outer-loop : list * list * number -> list
;; Purpose: takes the input sequence list of non-decreasing sequences and index i and
;;          creates non-decreasing subsequences dynamically combining sublists at index < i
;;          with input sequence elements at location >= i
;; Example: (outer-loop `(1 3 1 6) `((1) (1 3) () ()) 2) should produce ((1) (1 3) (1 1) (1 3 6))
;; Definition:
(define (outer-loop input_sequence solutions i)
  (if (= i (length input_sequence)) solutions
        (begin
          (let
              ((inner_result (inner-loop input_sequence solutions 0 i)))   
              (outer-loop input_sequence (append-at-index (list-ref input_sequence i) i inner_result) (+ 1 i))
))))

;; Contract: inner-loop : list * list * number * number -> list
;; Purpose: Dynamic programming approach to appending values to non-decreasing subsequences
;;          in solutions from j_curr to i indeces of input_sequence.      
;; Example: (inner-loop `(1 3 1) `((1) (1 3) ()) 0 2) should produce ((1) (1 3) (1))
;; Definition:
(define (inner-loop input_sequence solutions j_curr i)
  (cond ((= j_curr i) solutions)
        ((and (>= (list-ref input_sequence i)    (list-ref input_sequence j_curr))
              (< (length (list-ref solutions i)) (length (list-ref solutions j_curr)))
        ) (inner-loop input_sequence (insert-at-index (list-ref solutions j_curr) i solutions) (+ 1 j_curr) i))     
        (else (inner-loop input_sequence solutions (+ 1 j_curr) i))
))