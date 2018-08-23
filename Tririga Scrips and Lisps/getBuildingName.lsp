(defun c:getBuildingName (/ bldgName)
	(vl-bt)
	(vl-load-com)
	(setq filePath (getvar "dwgprefix"))
	(setq bldgNamePos 
		(+
			(vl-string-search "\-" filePath)
			2
		)
	)
	(setq bldgName
		(substr filePath bldgNamePos
			( - (strlen filePath) bldgNamePos )
		)
	)
	(setq test (wcmatch bldgName "*[a-z][A-Z]*,*[1-9][A-Z]*"))
	(setq idx 1)
	(repeat (- (strlen bldgName) 1)
		(setq twoLetters 
			(substr bldgName idx 2)
		)
		(if 
			(wcmatch twoLetters "*[a-z][A-Z]*,*[1-9][A-Z]*")
			(progn
				(setq idx 
					(+ idx 1)
				)
				(setq bldgName
					(insertString bldgName " " idx)
				)
				(print bldgName)
			)
		)
		(setq idx (+ idx 1))
	)
	(print bldgName)
	(princ)
)

(defun insertString (baseString newChars pos /)
	(strcat
		(substr baseString 1 (1- pos))
		newChars
		(substr baseString pos)
	)
)

