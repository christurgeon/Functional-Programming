;; Contract: evaluate : list -> boolean
;; Purpose: evaluate a list of lists representing a boolean expression
;; Example: (evaluate (myor true false)) should produce #t
;; Definition:
(define (evaluate expr)
  (cond ((or (equal? expr `true) (equal? expr #t)) #t )
        ((or (equal? expr `false) (equal? expr #f)) #f )
        ((equal? (car expr) `myignore) #f )
        ((equal? (car expr) `mynot) (not (evaluate (cdr expr))) )
        ((equal? (car expr) `myand) (and (evaluate (cadr expr)) (evaluate (caddr expr))) )
        ((equal? (car expr) `myor)  (or  (evaluate (cadr expr)) (evaluate (caddr expr))) )
        ((equal? (car expr) `mylet) (evaluate (instantiate (cadr expr) (evaluate (caddr expr)) (cadddr expr))) )
  )
)

;; Contract: instantiate : list -> list
;; Purpose: (1)create a new list containing elements of expr
;;             but with occurrences of var replaced with val
;;          (2)It will only resolve mylet declaration for current
;;             var name and current scope of var (will ignore
;;             nested variable with same var name)
;; Example: (instantiate x true (myand true x)) should produce (myand true true) 
;; Definition:
(define (instantiate var val expr)
  (cond ((null? expr) expr)
        ((list? (car expr)) (cons (instantiate var val (car expr)) (instantiate var val (cdr expr))) )
        ((and (eq? (car expr) `mylet) (eq? (cadr expr) var)) expr ) 
        ((eq? (car expr) var) (cons val (instantiate var val (cdr expr))) )
        ((and (equal? (car expr) `mylet) (equal? (cadr expr) var)) expr )
        ((equal? (car expr) var) (append (list val) (cdr expr)) )
        (else
         (cons (car expr) (instantiate var val (cdr expr))) )
  )
)

;; Contract: myinterpreter : list -> list
;; Purpose: convert a list of boolean expressions to a list of boolean
;;          values with the same respective location within result list
;; Example: (myinterpreter ((prog (myor false false)) (prog (myand true false)))) should produce (#f #f)
;; Definition:
(define (myinterpreter x)
  (if (null? x) `()
      (cons (evaluate (cadar x)) (myinterpreter (cdr x))))
  )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; TEST CASES BELOW ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

;;(myinterpreter '(
;;(prog (myor (myand true (myignore (myor true false))) (myand true false)))
;;(prog (mylet z (myor false true) (myand z true)))
;;(prog (mylet a true (myor (mylet b (myand true false) (myor false b)) (myand false a))))
;;(prog (mylet x true (myor (mylet x (myand true false) (myand true x)) (myand true x))))
;;(prog true)
;;(prog false)
;;(prog (myand (myor true true) (mylet x false (myor x true))))
;;))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;