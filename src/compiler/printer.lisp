(in-package :KerboL)

(define-constant +invalid-ks-token-characters+ "!?#@%+*/=:<>^" :test 'string=)
(define-constant +invalid-ks-token-characters-replacements+ #("bang" "what" "hash" "at" "percent"
                                                              "plus" "star" "slash" "equals" "colon"
                                                              "lessthan" "greaterthan" "caret") :test 'equalp)

(defvar *kl-print-pretty* t "Pretty-print the resulting KerboScript")

(defvar *kl-stream* nil "Output stream for KerboScript printing.")

(defgeneric kl-print (form)
  (:documentation "Print a KerboL compiled form as KerboScript."))

(defgeneric kl-print% (primitive args)
  (:documentation "Support printer for complex forms of type: (`PRIMITIVE' `ARGS')"))

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
                        (list 'kl-print x) ;FIXME replace it with a proper printing form (PSW-equivalent)
                        x)))))))

(defmethod kl-print ((form (eql t)))
  (write-string "true" *kl-stream*))

(defmethod kl-print ((form null))
  (write-string "false" *kl-stream*))

(defmethod kl-print ((num integer))
  (format *kl-stream* "~D" num))

(defmethod kl-print ((num float))
  (format *kl-stream* "~F" num))

(defmethod kl-print ((num ratio))
  (format *kl-stream* "~D/~D" (numerator num) (denominator num)))

(defmethod kl-print ((str string))
  (prin1 str *kl-stream*))

(defmethod kl-print ((s symbol))
  (if (keywordp s)
      (kl-print (string-downcase s))    ;TODO some specific handling for keywords?
      (write-string (symbol->ks-string s) *kl-stream*)))

(defmethod kl-print ((form cons))
  ;; dispatch to a specific printer
  (kl-print% (car cons) (cdr cons)))

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
