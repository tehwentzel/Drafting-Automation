(defun c:triPDF (/ retVal)
	;actually used command that formats the file and plots the drawing to the appropriate fccad-pdf folder
	(vl-load-com)
	;formats and cleans the drawing
	(vl-catch-all-apply 'vl-cmdf
			(list "model" "ZOOM" "Extent")
	) 
	(c:fmclean)
	(checkLabels) ;checks for the presents of labels. Will only turn on the a-area-iden layer if there is nothing in the trilabellayer layer
	(c:UpdateTriFields) ;updates the fields in the case of the titleblock using fields
	(vl-catch-all-apply 'vl-cmdf
			(list "qsave") 
	) 
	(c:PublishTriPDF) ;comand that actually plots
	(vl-catch-all-apply 'vl-cmdf
			(list "qsave") 
	) ;the qsaves could possibly be removed 
	(princ)
)

(defun checkLabels (/ labelFilter labels)
	;checks to see if there are text objects on the trilabel layer.  Thaws the a-area-iden layer if not (usually turned off by fmclean)
	(vl-load-com)
	(setq acadobject (vlax-get-Acad-Object))
	(setq activedocument (vla-get-activedocument acadobject))
	(setq thelayers (vla-get-layers activedocument))
	(setq labelFilter
		(list 
			'(0 . "MTEXT")
			'(8 . "triLabelLayer")
		)
	)
	(setq labels (ssget "X" labelFilter))
	(if
		(not labels)
		(vl-catch-all-apply 'vl-cmdf
			(list "-layer" "thaw" "A-AREA-IDEN" "") 
		) 
	)
	princ
)