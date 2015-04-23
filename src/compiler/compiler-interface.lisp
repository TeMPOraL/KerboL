(in-package #:KerboL)

(defun kl-compile-to-string (forms)
  "Compile `FORMS' into KerboScript and return them as a string."
  (let ((printed-forms (kerbol-print (kl-compile-statement (cons 'progn forms)))))
    (if (and (not (cdr printed-forms))
             (stringp (car printed-forms)))
        (car printed-forms)
        (with-output-to-string (str)
          (mapcar (lambda (s) (write-string s str)) printed-forms)))))

(defun kl-compile-to-file (file-name &optional (output-file-name (concatenate 'string file-name ".ks")))
  "Compile `FILE-NAME' and print output to `OUTPUT-FILE-NAME'."
  ;; TODO compile file.
  
  )
