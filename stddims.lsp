(defun c:stddims (/ dimlst doc ss dim dimset dimtext dimtodimlayererror numdimschanged)
	(setvar 'Cmdecho 0)
  (vl-load-com)
	(setq doc ;standard Visual Lisp setup
		(vla-get-ActiveDocument
			(vlax-get-acad-object)
		)
	)
	(setq dimStyles ;more setup-getting the dimension styles in the documens
		(vla-get-DimStyles doc)
	)
	(setq dim	;adds "DIM-96" style to the document
		(vla-Add dimStyles "DIM-96")
	)
	(vla-put-ActiveDimStyle doc dim) ;sets DIM-96 to the active dimension style
	
	(setq dimtexttest ;;checks to see if "DIM" textstyle exists
		(tblsearch "style" "DIM") ;;DIM is the text style for the dimensions
	)
	
	(if ;;creates "DIM" textstyle if there is none
		(not dimtexttest)
		(progn
			(setq styles
				(vla-get-textstyles doc)
			)
			(setq objStyle 
				(vla-add styles "DIM")
			)
			(vla-put-fontfile objStyle "iso.shx")
		)
	)
		;;Here I set a bunch of the variable for the active dimension style, which *should* be dim-96
		(setvar "DIMSCALE" 1)
		(setvar "DIMALT" 0)
		(setvar "DIMARCSYM" 0)               ;   Arc length symbol
		(setvar "DIMASZ" 3.0000)
		(setvar "DIMCEN" 0.0900)
		(setvar "DIMTSZ" 0)
		(setvar "DIMDLI" 0.025)
		(setvar "DIMASSOC" 1)
		(setvar "DIMEXE" 0.025)
		(setvar "DIMEXO" 0.025)
		(setvar "DIMGAP" 0.025)
		(setvar "DIMLUNIT" 4)
		;(setvar "DIMMZF" 100.000)
		(setvar "DIMTDEC" 0)
		(setvar "DIMTIH" 0)
		(setvar "DIMTMOVE" 2)
		(setvar "DIMTOFL" 1)
		(setvar "DIMTOH" 1)
		(setvar "DIMTP" 0)
		(setvar "DIMTXSTY" "DIM")
		(setvar "DIMTXT" 7.2)
		(setvar "DIMZIN" 3)
		(setvar "DIMBLK" "ArchTick")          ;   Arrow block name
		(setvar "DIMBLK1" "ArchTick")
		(setvar "DIMBLK2" "ArchTick")
		(setvar "DIMCLRD" 256)            ;      Dimension line and leader color
		(setvar "DIMCLRE" 256)           ;       Extension line color
		(setvar "DIMCLRT" 256)           ;        Dimension text color
		(setvar "DIMDEC" 0)                ;Decimal places
		(setvar "DIMLDRBLK" "ArchTick")         ;    Leader block name
		(setvar "DIMLWD" -1)                   ;Dimension line and leader lineweight
		(setvar "DIMLWE" -1)                   ;Extension line lineweight
		(setvar "DIMRND" 0.05)                   ;Rounding value
		(setvar "DIMSE1" 1)
		(setvar "DIMSE2" 1)
		(setvar "DIMTAD" 0)
		(setvar "DIMTVP" 0)
		(vla-copyfrom dim doc) ; I honestly don't know what this does but I was working from code that used this during a similar variable setup process I found that did this.
 
	(setq numdimschanged ;custom lisp that changes the layer and dimstyle of all active dims
		(vl-catch-all-apply 'c:dimtodimlayer)
	) 
	(setq dimset ;selects all the dimensions in the drawing
		(ssget "X"
			'((0 . "DIMENSION"))
		)
	)
	(if dimset
		(command "dimoverride" "clear" dimset "") ;;clears dimstyle overrides on the found dimensions
	)
	(setvar 'Cmdecho 1)
	(setq retVal numdimschanged)
)