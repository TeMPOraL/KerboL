(in-package :KerboL)

(define-constant +invalid-ks-token-characters+ "!?#@%+*/=:<>^" :test 'string=)
(define-constant +invalid-ks-token-characters-replacements+ #("bang" "what" "hash" "at" "percent"
                                                              "plus" "star" "slash" "equals" "colon"
                                                              "lessthan" "greaterthan" "caret") :test 'equalp)

(defvar *kl-print-pretty* t "Pretty-print the resulting KerboScript")

(defparameter *kl-pp-indent-num-spaces* 4)

(defvar *kl-stream* nil "Output stream for KerboScript printing.")

(defgeneric kl-print (form)
  (:documentation "Print a KerboL compiled form as KerboScript."))

(defgeneric kl-print% (primitive args)
  (:documentation "Support printer for complex forms of type: (`PRIMITIVE' `ARGS')"))

(defun symbol->ks-string (symbol)
  "Convert `SYMBOL' to a proper KerboScript term. Apply following transformations:
- lowercase,
- turn dashes into underlines,
- replace characters invalid for KerboScript token with a textual name."
  (let ((symbol-name (string-downcase symbol)))
    (with-output-to-string (acc)
      (loop for c across symbol-name
         do (cond ((eql c #\-)
                   (write-char #\_ acc))
                  ((position c +invalid-ks-token-characters+)
                   (write-sequence (aref +invalid-ks-token-characters-replacements+
                                         (position c +invalid-ks-token-characters+))
                                   acc))
                  (t (write-char c acc)))))))

(defmacro defprinter (primitive args &body body)
  "Helper macro defining a `KL-PRINT%' method for one or more `PRIMITIVE's. Lifted pretty much straight from Parenscript."
  (if (listp primitive)
      (cons 'progn (mapcar (lambda (p)
                             `(defprinter ,p ,args ,@body))
                           primitive))
      (let ((pargs (gensym)))
        `(defmethod kl-print% ((op (eql ',primitive)) ,pargs)
           (declare (ignorable op))
           (destructuring-bind ,args
               ,pargs
             ,@(loop for x in body collect
                    (if (or (characterp x)
                            (stringp x))
                                        ;(list 'kl-print x) ;FIXME replace it with a proper printing form (PSW-equivalent)
                        (list 'kl-print-objects x)
                        x)))))))

(defun kl-print-objects (&rest objects)
  (dolist (obj objects)
    (typecase obj
      (string
       (write-string obj *kl-stream*))
      (character
       (write-char obj *kl-stream*)))))

;;; interface

(defun kerbol-print (form)
  (let ((*kl-stream* (make-string-output-stream)))
    (if (and (listp form)
             (eq 'ks-prn:block (car form)))
        (loop for (statement . rest) on (cdr form) do
             (kl-print statement)
             (kl-print-objects #\.)
             (when rest (kl-print-objects #\Newline)))
        (kl-print form))
    (get-output-stream-string *kl-stream*)))


;;; pretty printing utilities
(defun indent-one-column ()
  (if *kl-print-pretty*
      (loop repeat *kl-pp-indent-num-spaces* do (kl-print-objects #\Space))
      (kl-print-objects #\Space)))
