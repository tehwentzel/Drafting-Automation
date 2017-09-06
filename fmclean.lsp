(defun closehatch (hatchnum ss)
;;Helper function that is given a selection set of hatch objects, and a number
;;Will remove the first element of the set and convert it to a Solid hatch
;;For use as a sub function of fixhatch
	(if ss  ;;make sure the set isnt empty
		(progn	
			(setq curr	
				(vlax-ename->vla-object	 ;;get first set element as a vla object
					(ssname ss 0)
				)
			)
			(vla-SetPattern curr acHatchPatternTypePreDefined "SOLID") ;;changes hatch pattern to solid
			(ssdel (ssname ss 0) ss) ;;deletes the now solid hatch from the set
		)
	)
	(setq retset ss) ;;return the selection set with the first (now solid) element removed
)

(defun hatchrestyle (hatchnum2 ss2 / curr)
;;Helper function that is given a selection set of hatch objects, and a number
;;Will remove the first element of the set and convert it to a Solid hatch
;;For use as a sub function of fixhatch
	(if ss2 ;;make sure  the set isnt empty
		(progn
			(setq curr
				(vlax-ename->vla-object ;;take the first set element as a vla object
					(ssname ss2 0)
				)
			)
			(vla-put-hatchstyle curr acHatchStyleNormal) ;;Change hatch style to normal island detection
			(ssdel (ssname ss2 0) ss2) ;;Remove the first value and return the remaining selection set
		)
	)
	(setq retset ss2) ;;Return the selection set with the first element removed
)

(defun fixhatch (/ ss hatchnum retval)  
;;helper function that will make all hatches solid
	(setq ss	;;Get all non-solid hatches
		(ssget "X"
			'(
				(0 . "HATCH")
				(2 . "~SOLID")
			)
		)
	)
	 (if ss ;;get the number of erroneous hatches
		 (setq hatchnum
				 (sslength ss)
		 )
			; (sslength ss)
		; )
		 (setq hatchnum 0)
	 )
	(repeat hatchnum ;;Visual Lisp should really include a "Pop" function
		(setq ss
			(closehatch hatchnum ss)
		)
	)
	(setq retval hatchnum) ;;return the number of edited hatches
)

(defun hatchislandfix (/ ss2 hatchnum2)
;;helper function that will make all hatches set to normal island detection
	(setvar "CMDECHO" 0)
	(setvar "FILEDIA" 0)
	(setvar 'Nomutt 1)
	(setq ss2	;;Get all non-solid hatches
		(ssget "X"
			'(
				(0 . "HATCH")
				(-4 . "<OR") ;;Selects hatches with "outer" or "ignore" island detection
				(75 . 0) ;; normal
				(75 . 2) ;; ignroe
				(-4 . "OR>")
				(410 . "Model")  ;;selects only objects in the model tab (can give an error otherwise)
			)
		)
	)
	(if ss2 ;;get the number of erroneous hatches
		(setq hatchnum2
			(sslength ss2)
		)
		(setq hatchnum2 1)
	)
	(repeat hatchnum2 ;;Visual Lisp should really include a "Pop" function
		(setq ss2
			(hatchrestyle hatchnum2 ss2)
		)
	)
	(setq retval hatchnum2) ;;return the number of edited hatches
)

	
(defun delnilpolys (/ ss i arealim delcount parea thiserror)
;;Helper function that deletes any lines or polylines 
;;under a certain area on the A-POLYLINE-related layer, or the A-Hatch layer
	(setq arealim 75);variable that sets the upper area limit on what polylines are deleted
	(setq delcount 0);counts the number of items deleted
	(setq ss ;;Selects all relevant polylines
		(ssget "X"
			'(
				(-4 . "<OR")
				(0 . "LWPOLYLINE")
				(0 . "LINE")
				(-4 . "OR>")
				(-4 . "<OR")
				(8 . "A-Polyline")
				(8 . "A-POLYLINE-INT")
				(8 . "A-POLYLINE-EXT")
				(8 . "A-HATCH")
				(-4 . "OR>")
			)
		)
	)
	(setq i
		(sslength ss)
	)
	(repeat	i
		(progn
			(setq thispoly
				(ssname ss
					(setq i 
						(1- i)
					)
				)
			)
			(setq parea 
				(vlax-curve-getArea thispoly)
			)
			(if 
				(>= arealim parea)
				(progn
					(entdel thispoly)
					(setq delcount
						(1+ delcount)
					)
				)
			)
		)
	)
	(setq Retval delcount) ;return number of deleted lines
)
	
(defun c:fmclean (/ delnilpolysretval stddimsretval pcloseretval recolorretval fixhatchretval)
	(setvar "CMDECHO" 0)
	(setvar "FILEDIA" 0)
	(setvar 'Nomutt 1)
	(vl-load-com)
	(command 
		"model" 
		"zoom" 
		"extents" 
		"laythw"
		"layon"
		"-overkill"
		"all"
		""
		"Ignore"
		"color"
		"Ignore"
		"Ltype"
		"Ignore"
		"ltScale"
		"Ignore"
		"LWeight"
		"Ignore"
		"Thickness"
		"Ignore"
		"Transparency"
		"Ignore"
		"plotSTyle"
		"Ignore"
		"Material"
		"tolerance"
		".5"
		"plines"
		"no"
		"partial"
		"yes"
		"endtoend"
		"yes"
		"associativity"
		"no"
		""
	)
	
	;This block executes the various custom lisps, and checks their return values
	(setq delnilpolysretval
		(vl-catch-all-apply 'delnilpolys)
	)
	(setq recolorretval
		(vl-catch-all-apply 'c:recolor)
	)
	(setq fixhatchretval
		(vl-catch-all-apply 'fixhatch)
	)
	(setq hatchislandretval
		(vl-catch-all-apply 'hatchislandfix)
	)
	(setq stddimsretval
		(vl-catch-all-apply 'c:stddims)
	)
	(setq pcloseretval
		(vl-catch-all-apply 'c:pclose)
	)

	(command
		"-purge"
		"all"
		"*"
		"no"
	)
	
	(princ	"\nRESULTS:...\n");this blocks prints out the results of the various scripts
	(cond
		(
			(vl-catch-all-error-p delnilpolysretval)
			(princ "\ndelnilpolys failed\n")
		)
		(t
			(princ 
				(strcat
					"\ndelnilpolys deleted "
					(itoa delnilpolysretval)
					" items\n"
				)
			)
		)
	)
	(cond
		(
			(vl-catch-all-error-p recolorretval)
			(princ "\nrecolor failed\n")
		)
		(t
			(princ "\nrecolor successful\n")
		)
	)
	(cond
		(
			(vl-catch-all-error-p fixhatchretval)
			(princ "fixhatch failed\n")
		)
		(t
			(princ 
				(strcat
					"fixhatch converted "
					(itoa fixhatchretval)
					" hatches to solid\n"
				)
			)
		)
	)
	(cond
		(
			(vl-catch-all-error-p hatchislandretval)
			(princ "hatchislandfix failed\n")
		)
		(t
			(princ 
				(strcat
					"hatchislandfix converted "
					(itoa hatchislandretval)
					" hatches to normal island detection\n"
				)
			)
		)
	)
	(cond
		(
			(vl-catch-all-error-p stddimsretval)
			(princ "stddims failed\n")
		)
		(t
			(princ
				(strcat
					"stddims edited "
					(itoa stddimsretval)
					" dimensions\n"
				)
			)
		)
	)
	(cond
		(
			(vl-catch-all-error-p pcloseretval)
			(princ "pclose failed\n")
		)
		(t
			(princ
				(strcat
					"pclose closed "
					(itoa pcloseretval)
					" polylines\n"
				)
			)
		)
	)
	(setvar "CMDECHO" 1)
	(setvar 'Nomutt 0)
	(princ)
)