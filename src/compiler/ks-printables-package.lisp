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
   #:lock
   #:lock-local
   #:lock-global
   #:unlock
   #:unlock-all
   #:prn

   ;; other
   #:block
   #:funcall

   #:comment-inline
))
