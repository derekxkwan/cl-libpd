(asdf:load-system :cffi)

(defpackage :libpd
  (:use :common-lisp :cffi))

(in-package :libpd)


(define-foreign-library libpd
  (:unix "/usr/local/lib/libpd.so")
  (t (:default "/usr/local/lib/libpd")))

(cffi:use-foreign-library libpd)

;;not sure if char pointers shouldn't be string bc of c?
(defcfun ("libpd_init" libpd-init) :int)
(defcfun ("libpd_clear_search_path" libpd-clear-search-path) :void)
(defcfun ("libpd_add_to_search_path" libpd-add-to-search-path) :void (sym :string))

;;imported functions
(defcfun ("libpd_openfile" libpd-openfile) (:pointer :void)
  (basename :string) (dirname :string))
(defcfun ("libpd_closefile" libpd-closefile) :void
  (p (:pointer :void)))
(defcfun ("libpd_getdollarzero" libpd-getdollarzero) :int
  (p (:pointer :void)))

(defcfun ("libpd_blocksize" libpd-blocksize) :int)
(defcfun ("libpd_init_audio" libpd-init-audio) :int
  (inChans :int outChans :int sampleRate :int))
(defcfun ("libpd_process_raw" libpd-process-raw) :int
  (inBuffer (:pointer :float)) (outBuffer (:pointer :float)))
(defcfun ("libpd_process_short" libpd-process-short) :int
  (ticks :int) (inBuffer (:pointer :short)) (outBuffer (:pointer :short)))
(defcfun ("libpd_process_float" libpd-process-float) :int
  (ticks :int) (inBuffer (:pointer :float)) (outBuffer (:pointer :float)))
(defcfun ("libpd_process_double" libpd-process-double) :int
  (ticks :int) (inBuffer (:pointer :double)) (outBuffer (:pointer :double)))

(defcfun ("libpd_arraysize" libpd-arraysize) :int
  (name :string))
(defcfun ("libpd_read_array" libpd-read-array) :int
  (dest (:pointer :float)) (src :string) (offset :int)
  (n :int))
(defcfun ("libpd_write_array" libpd-write-array) :int
  (dest :string) (offset :int) (src (:pointer :float))
  (n :int))

(defcfun ("libpd_bang" libpd-bang) :int
  (recv :string))
(defcfun ("libpd_float" libpd-float) :int
  (recv :string) (x :float))
(defcfun ("libpd_symbol" libpd-symbol) :int
  (recv :string) (sym :string))

(defcfun ("libpd_start_message" libpd-start-message) :int
  (max_length :int))
(defcfun ("libpd_add_float" libpd-add-float) :void
  (x :float))
(defcfun ("libpd_add_symbol" libpd-add-symbol) :void
  (sym :string))
(defcfun ("libpd_finish_list" libpd-finish-list) :int
  (recv :string))
(defcfun ("libpd_finish_message" libpd-finish-message) :int
  (recv :string) (msg :string))

;;helper functions
(defun libpd-process-args (mylist)
  (if (not (equal (libpd-start-message (length mylist)) 0)) -2
      (dolist (x mylist)
	 (cond ((floatp x) (libpd-add-float x))
	       ((stringp x) (libpd-add-symbol x))))))

;;emulated functions
(defun libpd-message (recv msg mylist)
  (if (listp mylist) (or (libpd-process-args mylist)
			 (libpd-finish-message recv msg))))

(defun libpd-list (recv mylist)
  (if (listp mylist)
      (or (libpd-process-args mylist)
	  (libpd-finish-list recv))))
