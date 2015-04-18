;;; KerboL.asd
(asdf:defsystem #:KerboL
  :serial t

  :long-name "KerboL"
  :author "Jacek 'TeMPOraL' Złydach"
  ;; :version
  :description "A Lisp interface and script compiler for Kerbal Operating System (kOS)."
  :long-description "KerboL, short from Kerbo-Lisp, is a set of tools for Kerbal Operating System mod.
It contains (or rather, will contain):
- a Telnet client connecting to kOS instance, allowing for a limited REPL,
- a way to interactively operate KSP from Lisp REPL, leveraging the power of SLIME,
- a KerboL to KerboScript compiler, allowing one to write kOS scripts in a Lisp."

  :license "TBD"
  :homepage "https://github.com/TeMPOraL/KerboL"
  :bug-tracker "https://github.com/TeMPOraL/KerboL/issues"
  :source-control (:git "https://github.com/TeMPOraL/KerboL/KerboL.git")
  :mailto "temporal.pl@gmail.com"

  :encoding :utf-8

  :depends-on (#:alexandria)


  ;; test link
  
  ;; components
  :components
  ((:module "src"
            :components ((:file "package")
                         (:module "compiler"
                                  :components (("compiler"
                                                "printer")))
                         (:module "remote"
                                  :components (()))))))
