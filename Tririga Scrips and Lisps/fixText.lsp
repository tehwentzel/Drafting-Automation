(defun c:fixText (/ fmstxtSearch textSet textCount retVal)
	(setvar 'Cmdecho 0)
	(vl-load-com)
	(setq acadObj (vlax-get-acad-object))
	(setq doc (vla-get-ActiveDocument acadObj))
	
	(setq textName "fmstxt")
	(setq textHeight 10)
	
	(setq textFilter 
		(list
			'(0 . "MTEXT,TEXT")
			'(8 . "~G-ANNO-PURPLE")
			'(8 . "~G-ANNO-GRAY")
			'(-4 . "<OR")
			'(-4 . "<NOT")
			(cons 7 textName)
			'(-4 . "NOT>")
			'(-4 . "<NOT")
			(cons 40 textHeight)
			'(-4 . "NOT>")
			'(-4 . "OR>")
		)
	)
	(setq textSet ;;selcts all the dimensions not on the a-anno-dims layer or not of type "dim-96"
		(ssget "_X" textFilter)
	)
	
	(setq fmstxtSearch ;;checks to see if "DIM" textstyle exists
		(tblsearch "style" textName) ;;DIM is the text style for the dimensions
	)
	
	(if ;;creates "DIM" textstyle if there is none
		(not fmstxtSearch)
		(progn
			(setq styles
				(vla-get-textstyles doc)
			)
			(setq objStyle 
				(vla-add styles textName)
			)
			(vla-put-fontfile objStyle "iso.shx")
		)
	)
	
	(setq idx 0)
	(setq textCount 0)
	(if textSet					
		(setq textCount
			(sslength textSet)
		)	
	)
	(while ;;iterates through each erroneous dimension
		(< idx textCount)
		(progn	
			(setq thisText
				(ssname textSet idx)
			)
			(setq thisText (vlax-ename->vla-object thisText))
			(vla-put-StyleName thisText textName) ;;changes text to fmstxt
			(vla-put-Height thisText textHeight)
			(vla-update thisText)
			(setq idx (1+ idx))
		)
	)
	(setvar 'Cmdecho 1)
	(vla-Regen doc acAllViewports)
	(setq retVal textCount)
)
