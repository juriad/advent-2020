#lang racket

(define (load-file name) (call-with-input-file
                             name
                           (lambda (in) (read-string (* 1024 1024) in))))

(define (people g) (map
                    (lambda (p) (list->set (string->list p)))
                    (string-split g "\n")))

(define (fold1 proc lst) (if
                          (eq? (cdr lst) null)
                          (car lst)
                          (proc (car lst) (fold1 proc (cdr lst)))))

(define (groups str op) (map
                          (lambda (g) (fold1 op (people g)))
                          (string-split str "\n\n")))
                      
(define (sum-groups gs) (foldl +
                               0
                               (map set-count gs)
                               ))

(define (task name op) (sum-groups (groups (load-file name) op)))

(task "input" set-union)
(task "input" set-intersect)



