(in-package #:KerboL)

(defun kl-compile-to-string (forms)
  "Compile `FORMS' into KerboScript and return them as a string."
  (let ((printed-forms (kerbol-print (kl-compile-statement (cons 'progn forms)))))
    (if (and (not (cdr printed-forms))
             (stringp (car printed-forms)))
        (car printed-forms)
        (with-output-to-string (str)
          (mapcar (lambda (s) (write-string s str)) printed-forms)))))

(defun kl-compile-forms (forms)
  (kerbol-print (kl-compile-statement (cons 'progn forms))))

(defun kl-compile-stream (stream)
  (let ((eof '#:eof))
    (loop for form = (funcall *read-function* stream nil eof)
       until (eq form eof) do (kl-compile-forms form) (newline))))


(defun kl-compile-file (file-name &optional (output-file-name (change-filename-extension file-name ".ks")))
  "Compile `FILE-NAME' and print output to `OUTPUT-FILE-NAME'."
  (with-open-file (*kl-stream* output-file-name
                       :direction :output
                       :if-exists :supersede)
    (with-open-file (in file-name
                        :direction :input)
      (kl-compile-stream in))))
