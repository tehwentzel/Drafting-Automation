

(defun c:PublishTriPDF(/ ss fileName bldgSitecode floorNum bldgNum bldgDescL address city state zip)
	;command that plots the drawing automatically with hard-coded settings.  May fail if there are irregular prompts in some extenuating circumstances.
	(COMMAND "filedia" 0)
	
	;;sets the plotstyle directory to the one in the y-drive 
	(setq prevPlotDir
		(getenv "PrinterStyleSheetDir")
	)
	(setq prefs	
		(vla-get-preferences 
			(vlax-get-acad-object)
		)
		filePrefs (vla-get-files prefs)
	)
	(vla-put-printerstylesheetpath filePrefs "Y:\\Plotstyles")
	(vla-refreshplotdeviceinfo 
		(vla-get-activelayout
			(vla-get-activedocument 
				(vlax-get-acad-object)
			)
		)
	)
	
	;;Sets values filename and floornum based on name of the drawing
	(setq fileName (getvar "dwgname"))
	(setq fileString (substr fileName 1 (- (strlen fileName) 4)))
	
	;;Sets the value for various strings within the program
	(setq layout "model")
	(setq plotout "DWG to PDF.pc3")
	(setq paperstyle "ANSI full bleed B (11.00 x 17.00 Inches)")
	
	;;CHANGE THIS PART TO USE A DIRRERENT PLOT STYLE
	(setq plotstyle ".")
	;;PLOT STYLEs SHOULD BE IN THE Y:\PLOTSTYLES FOLDER (unless line 16 is changed)
	
	(setq parentFolder "Y:\\FCCAD\\FC-PDF");; main folder where the script will publish the pdf to

	(setq extMin (getvar "EXTMIN"))
	(setq extMax (getvar "EXTMAX"))
	(setq isLandscape nil)
	
	(setq xLen 
		(- (car extMax) (car extMin)) 
	)
	(setq yLen 
		(- (cadr extMax) (cadr extMin)) 
	)
	(if
		(> xLen yLen)
		(setq isLandscape 'T)
	)
	
	(if isLandscape
		(setq orientation "landscape")
		(setq orientation "portrait")
	)
	
	(if ;;decides to plot to portrait or orientation based on the "orientation" tag.  Shoudl default to landscape
		(= orientation "portrait")
		(vl-catch-all-apply 'vl-cmdf
			(list ".-plot" "Y" layout plotout paperstyle "INCHES" "portrait" "no" "extents" "fit" "center" "yes" 
					plotstyle "N" "W" (strcat parentFolder "\\FC-PDF PORTRAIT\\"  fileString) "y" "y" "y")
		) 
		(vl-catch-all-apply 'vl-cmdf
			(list ".-plot" "Y" layout plotout paperstyle "INCHES" "landscape" "no" "extents" "fit" "center" "yes" plotstyle "N" "W" (strcat parentFolder "\\"  fileString) "y" "y" "y")
		)   		
	)
	;puts the plot style back to the previous directory
	(vla-put-printerstylesheetpath filePrefs prevPlotDir)
	(vla-refreshplotdeviceinfo 
		(vla-get-activelayout
			(vla-get-activedocument 
				(vlax-get-acad-object)
			)
		)
	)
	(COMMAND "filedia" 1)
	(princ (< xLen yLen) )
)
(princ)


(defun checkIfLandscape (/isLandscape extMin extMax xLen yLen)
;;Helper functions that compares the extents of the drawing.  Returns true if the drawing is wider than it is tall
	(setq extMin (getvar "EXTMIN"))
	(setq extMax (getvar "EXTMAX"))
	(setq isLandscape nil)
	
	(setq xLen 
		(- (car extMax) (car extMin)) 
	)
	(setq yLen 
		(- (cadr extMax) (cadr extMin)) 
	)
	(if
		(< xLen yLen)
		(setq isLandscape 'T)
	)
	(return-from checkIfLandscape xLen)
)


