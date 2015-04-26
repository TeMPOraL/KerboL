(in-package #:KerboL)

(defvar *special-expression-operators* (make-hash-table :test 'eq))
(defvar *special-statement-operators* (make-hash-table :test 'eq))

(defmacro define-special-operator (type op lambda-list &rest body)
  `(setf (gethash ',op ,type)
         (lambda (&rest args)
           (destructuring-bind ,lambda-list args
             ,@body))))

(defmacro define-special-expression-operator (op lambda-list &body body)
  `(define-special-operator *special-expression-operators* ,op ,lambda-list ,@body))

(defmacro define-special-statement-operator (op lambda-list &body body)
  `(define-special-operator *special-statement-operators* ,op ,lambda-list ,@body))

(defmacro define-trivial-special-expression-operators (&rest mappings)
  `(progn ,@(loop for (form-name ks-primitive) on mappings by #'cddr collect
                 `(define-special-expression-operator ,form-name (&rest args)
                    (cons ',ks-primitive (mapcar #'kl-compile-expression args))))))


;;; utils
(defun mapcan-pairwise (function list)  ;FIXME is this really mapcan? Naming stuff after 02:00 AM is a bad idea.
  (loop for (first-elt second-elt) on list by #'cddr collect
       (funcall function first-elt second-elt)))

(defun flatten-blocks (body)
  (when body
    (if (and (listp (car body)) (eq 'ks-prn::block (caar body)))
        (append (cdr (car body)) (flatten-blocks (cdr body)))
        (cons (car body) (flatten-blocks (cdr body))))))

;;; /utils

(defun special-form? (form)
  (and (consp form)
       (symbolp (car form))
       (or (gethash (car form) *special-expression-operators*)
           (gethash (car form) *special-statement-operators*))))

;;; special forms - statements
(define-special-statement-operator set (&rest mappings)
  (cons 'ks-prn:block (mapcan-pairwise (lambda (var expr)
                                         `(ks-prn:set ,var ,(kl-compile-expression expr)))
                                       mappings)))

(define-special-statement-operator lock (&rest mappings)
  (mapcan-pairwise (lambda (var expr)
                     `(ks-prn:lock-global ,var ,(kl-compile-expression expr)))
                   mappings))

(define-special-statement-operator lock-global (&rest mappings)
  (mapcan-pairwise (lambda (var expr)
                     `(ks-prn:lock-global ,var ,(kl-compile-expression expr)))
                   mappings))

(define-special-statement-operator lock-local (&rest mappings)
  (mapcan-pairwise (lambda (var expr)
                     `(ks-prn:lock-local ,var ,(kl-compile-expression expr)))
                   mappings))

(define-special-statement-operator unlock (&rest variables)
  (mapcan-pairwise (lambda (var expr)
                     `(ks-prn:lock-global ,var ,(kl-compile-expression expr)))
                   mappings))

(define-special-statement-operator defvar (var expr &optional doc)
  `((ks-prn:declare-global ,var ,(kl-compile-expression expr))
    ,(when doc `(ks-prn:comment-inline ,doc))))

(define-special-statement-operator progn (&rest forms)
  (cons 'ks-prn:block (flatten-blocks (mapcar #'kl-compile forms))))

(define-special-statement-operator prn (&rest forms) ;FIXME doesn't work for some magical reason
  (let ((args (mapcar #'kl-compile-expression forms)))
    (cons 'ks-prn:prn args)))

;;; special forms - expressions
(define-trivial-special-expression-operators
    * ks-prn:*
  / ks-prn:/)

(define-special-expression-operator + (&rest operands)
  (let ((args (mapcar #'kl-compile-expression operands)))
    (cons (if (cdr args)
              'ks-prn:+
              'ks-prn:unary+)
          args)))

(define-special-expression-operator - (&rest operands)
  (let ((args (mapcar #'kl-compile-expression operands)))
    (cons (if (cdr args)
              'ks-prn:-
              'ks-prn:unary-)
          args)))
