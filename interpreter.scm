(define (repl)
  (display ">>")
  (let ((exp (read)))
	(cond ((eq? exp '(exit)) 'done)
		  (else (display (top-eval exp))
				(newline)
				(repl))
		  )))

(define (my-load filename)
  (load-repl (open-input-file filename)))

(define (load-repl port)
  (let ((exp (read port)))
	(cond ((eof-object? exp) 'done)
		  (else (let ((res (top-eval exp)))
				  (display res)
				  (load-repl port)))
		  )))

(define (insert! val L)
  (set-cdr! L (cons (car L) (cdr L)))
  (set-car! L val))

(define (bind formals actuals)
  (cond ((null? formals) '())
		(else (cons (list (car formals) (car actuals))
					(bind (cdr formals) (cdr actuals))))
		))

(define (top-eval exp)
  (cond ((not (pair? exp)) (my-eval exp *global-env*))
		((eq? (car exp) 'define)
		 (cond ((not (pair? (cadr exp))) 
				(insert! (list (cadr exp) (my-eval (caddr exp) *global-env*)) *global-env*)
				(cadr exp))
			   (else (display "else")
					 (newline)
					 (car (cadr exp)))
			   ))
		(else (my-eval exp *global-env*))
		))

(define (my-eval exp env)
  (cond
	((symbol? exp) (lookup exp env))
	((not (pair? exp)) exp)
	((eq? (car exp) 'quote) (cadr exp))
	((eq? (car exp) 'if)
	 (handle-if (cadr exp) (caddr exp) (cadddr exp) env))
	((eq? (car exp) 'cond)
	 (handle-cond (cdr exp) env))
	((eq? (car exp) 'lambda)
	 (list 'closure exp env))
	((eq? (car exp) 'letrec)
	 (handle-letrec (cadr exp) (cddr exp) env))
	(else
	  (handle-call (map (lambda (sub-exp) (my-eval sub-exp env)) exp)))
	))

(define (lookup var env)
  (let ((item (assoc var env)))
	(cond ((not item) (display "Error: Undefined symbol ")
					  (display var)
					  (newline))
		  (else (cadr item))
		  )))

(define (handle-if test then-exp else-exp env)
  (if (my-eval test env)
	(my-eval then-exp env)
	(my-eval else-exp env)))

(define (handle-cond cond-clause env)
  (if (eq? cond-clause '())
	'(cond)
	(if (eq? (caar cond-clause) 'else)
	  (cond-body (cdar cond-clause) env)
	  (if (my-eval (caar cond-clause) env)
		(cond-body (cdar cond-clause) env)
		(handle-cond (cdr cond-clause) env)
		))))

(define (cond-body body env)
  (if (not (pair? (cdr body)))
	(my-eval (car body) env)
	(cond-body (cdr body) env)
	))

(define (handle-letrec defs body env)
  (display "to be done")
  (newline))

(define (handle-call evald-exps)
  (let ((fn (car evald-exps))
		(args (cdr evald-exps)))
	(cond
	  ((eq? (car fn) 'closure)
	   (let ((formals (cadr (cadr fn)))
			 (body (cddr (cadr fn)))
			 (env (caddr fn)))
		 (handle-block body (append (bind formals args) env))))
	  ((eq? (car fn) 'primitive-function)
	   (apply (cadr fn) args))
	  (else (display "Error: Calling non-function"))
	  )))

(define (handle-block block env)
  (cond ((null? block) (display "Error: Can not have empty block or body"))
		((null? (cdr block)) (my-eval (car block) env))
		(else (my-eval (car block) env)
			  (handle-block (cdr (block) env)))
		))

(define *global-env*
  (list 
	(list 'car (list 'primitive-function car))
	(list 'cdr (list 'primitive-function cdr))
	(list 'set-car! (list 'primitive-function set-car!))
	(list 'set-cdr! (list 'primitive-function set-cdr!))
	(list 'cons (list 'primitive-function cons))
	(list 'list (list 'primitive-function list))
	(list '+ (list 'primitive-function +))
	(list '- (list 'primitive-function -))
	(list '* (list 'primitive-function *))
	(list '= (list 'primitive-function =))
	(list '< (list 'primitive-function <))
	(list '> (list 'primitive-function >))
	(list '<= (list 'primitive-function  <=))
	(list '>= (list 'primitive-function >=))
	(list 'eq? (list 'primitive-function eq?))
	(list 'pair? (list 'primitive-function pair?))
	(list 'symbol? (list 'primitive-function symbol?))
	(list 'null? (list 'primitive-function null?))
	(list 'read (list 'primitive-function read))
	(list 'display (list 'primitive-function  display))
	(list 'open-input-file (list 'primitive-function open-input-file))
	(list 'close-input-port (list 'primitive-function close-input-port))
	(list 'eof-object? (list 'primitive-function eof-object?))
	(list 'load (list 'primitive-function my-load))
	))
