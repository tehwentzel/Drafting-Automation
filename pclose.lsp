(defun c:pclose ( / polys numpolys idx pent)
	;;Program that closes all polylines on the various fm polyline layer
	;;will affect polylines that are frozen or off as well
	(setvar 'Cmdecho 0)
	(vl-load-com)
	(setq numpolys 0);default to zero in case the loop selection set is empty
	(setq polys ;;Selects all relevant polylines
		(ssget "X"
			'(
				(0 . "LWPOLYLINE")
				(70 . 0)
				(-4 . "<OR")
				(8 . "A-Polyline")
				(8 . "A-POLYLINE-INT")
				(8 . "A-POLYLINE-EXT")
				(-4 . "OR>")
			)
		)
	)
	(if polys
		(progn
			(setq numpolys  ;;stores the number of polylines found
				(sslength polys) 
			)
			(setq idx 0)
			(repeat numpolys ;;repeats as many times as there are polylines
				(progn
					(setq pent  ;;gets one polyline name as a normal object
						(ssname polys idx)
					)
					(vla-put-closed	 ;;closes the polyline
						(vlax-ename->vla-object pent) ;;converts object to a visual lisp object
						:vlax-true
					)
					(setq idx (1+ idx)) ;increment index to select next polyline
				)
			)
		)
	)
	;(princ (strcat "closed " (rtos numpolys) " polylines."))
	(setvar 'Cmdecho 1)
	(setq Retval numpolys)
)
