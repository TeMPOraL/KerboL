(in-package #:KerboL)

;;; BASIC PRINTERS
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
  (kl-print% (car form) (cdr form)))

;;; COMPLEX PRINTERS
;; (defprinter )

(defprinter 'ks-prn:comment-inline (text)
  (indent-one-column) "//" (kl-print-objects text))

(defprinter 'ks-prn:declare-global (var expression)
  "GLOBAL " (kl-print var) " TO " (kl-print expression))

(defprinter 'ks-prn:set (var expression)
  "SET " (kl-print var) " TO " (kl-print expression))

(defprinter 'ks-prn:lock (var expression)
  "LOCK " (kl-print var) " TO " (kl-print expression))

(defprinter 'ks-prn:lock-global (var expression)
  "GLOBAL LOCK " (kl-print var) " TO " (kl-print expression))

(defprinter 'ks-prn:lock-local (var expression)
  "LOCAL LOCK " (kl-print var) " TO " (kl-print expression))

(defprinter 'ks-prn:unlock (var)
  "UNLOCK " (kl-print var))

(defprinter 'ks-prn:unlock-all ()
  "UNLOCK ALL")
