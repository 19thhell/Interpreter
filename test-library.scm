(define (test-library)
  (let* ((first (append (list (lambda (x) (+ x 1))
							  (lambda (y) (+ y 2)))
						(list (lambda (x) (+ x 3))
							  (lambda (y) (+ y 4)))))
		 (second (map (lambda (fun) (fun 3)) first))
		 (third (map (lambda (num) (cadr (assoc num '((4 zebra)
													  (5 owl)
													  (6 giraffe)
													  (7 lion)))))
					 second)))
	(if (or #f (equal? '(((1 2) (3 4) 5)) '(((1 2) (3 4) 5))))
	  (cond ((and (equal? 1 1) (equal? 2 3)) #f)
			(else (display "Should return (zebra owl giraffe line)")
				  (newline)
				  third))
	  #f)))
