(defun c:triPublish (/ retVal)
;;;function that publishes that temporary creates exploded dimensiosn and then publishes to tririga
	;SETUP
	(vl-load-com)
	(setvar 'Cmdecho 0)
	(setq acadDocument 
		(vla-get-activedocument
			(vlax-get-acad-object)
		)
	)
	(vla-startundomark acadDocument)
	;Turns off the prompt to disregard draworder when exploding a lot of objects
	(setq drawctl (getvar "DRAWORDERCTL"))
	(setvar "DRAWORDERCTL" 0)
	;gets all the dimensions
	(setq dimset
		(ssget "X"
			'((0 . "DIMENSION"))
		)
	)
	(if dimset
		(progn
			;copys all the dimensions in place
			(print "copying dimensions...")
			(vlax-for dimension
				(setq ss
					(vla-get-activeselectionset
						(vla-get-activedocument
							(vlax-get-acad-object)
						)
					)
				)
				(vla-copy dimension)
			)
			(vla-delete ss)
			;explodes the non-copy dimensions
			(print "exploding dimensions...")
			(setvar "qaflags" 1)
			(vl-catch-all-apply 'vl-cmdf
					(list "._explode" dimset "") 
			) 
			(setvar "qaflags" 0)
			;gets the exploded dimensions
			(setq olddims 
				(ssget "P")
			)
			;publishes and waits 20 seconds to be safe
			(vl-catch-all-apply 'vl-cmdf
					(list "trga_publish") 
			) 
			(setq waitTime (getWaitTime))
			(print 
				(strcat "waiting " (itoa waitTime) " seconds before deleting exploded dimensions...")
			)
			(wait waitTime) ;ideally this would wait until publishing complete
			;deletes old dimensions
			(print "deleting old dimensions (This message should appear after 'Publishing')...")
			(vl-catch-all-apply 'vl-cmdf
					(list "erase" olddims "") 
			) 
		)
		(progn
			(print "no dimensions found, publishing file normally...\n")
			(vl-catch-all-apply 'vl-cmdf
				(list "trga_publish") 
			)
		)
	)
	(vla-endundomark acadDocument)
	(print "triPublish complete")
	(setvar "DRAWORDERCTL" drawctl)
	(setvar 'Cmdecho 1)
	(setq retVal (sslength dimset))
)

(defun wait (seconds / stop)
;helper functions that delays "stop" seconds.  shamelessly stolen from the internet
	(setq stop (+ (getvar "DATE") (/ seconds 86400.0)))
	(while (> stop (getvar "DATE")))
)

(defun getWaitTime (/ retVal2)
;hepler function that decided the time to wait after using the "trga_publish" comand before deleting the exploded stuff
;based on the number of objects in the drawings
	(setq allstuff
		(ssget "_X")
	)
	(setq nStuff (sslength allstuff))
	(cond ;these cutoffs are fairly arbitrary
		(
			(< nStuff 1000)
			(setq waitTime 10)
		)
		(
			(< nStuff 10000)
			(setq waitTime 15)
		)
		( 
			(< nStuff 25000)
			(setq waitTime 20)
		)
		(
			t
			(setq waitTime 25)
		)
	)
	(setq retVal2 waitTime)
)