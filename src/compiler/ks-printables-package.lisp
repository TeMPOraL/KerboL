(in-package #:KerboL)

(defpackage #:ks-prn
  (:use)
  (:export
   ;; operators
   ;; arithmetic
   #:+
   #:unary+
   #:-
   #:unary-
   #:*
   #:/

   ;; KerboScript statements
   #:set
   #:declare-global
   #:declare-local
   #:declare-parameter
   #:lock-local
   #:lock-global
   #:prn

   ;; other
   #:funcall
))
