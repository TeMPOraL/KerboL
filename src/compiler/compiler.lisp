(in-package #:KerboL)

(defvar *read-function* #'read)

;;; compiler

(defun kl-compile (form)
  (typecase form
    ((or null number string character symbol)
     form)
    (cons
     (if (special-form? form)
         (kl-compile-special-form form)
         `(ks-prn:funcall ,@(mapcar #'kl-compile-expression form))))
    (t (error "Unsupported form."))))

(defun kl-compile-special-form (form)
  (let* ((op (car form))
         (statement-compiler (gethash op *special-statement-operators*))
         (expression-compiler (gethash op *special-expression-operators*)))
    (apply (or statement-compiler expression-compiler) (cdr form))))

(defun kl-compile-expression (form)
  (kl-compile form))

(defun kl-compile-statement (form)
  (kl-compile form))
