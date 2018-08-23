(defun c:insertTitleBLock(/ extMin extMax isLandscape xLen yLen scale filePath)
	;Command to automatically insert and scale a titleblock into the drawing.  Said titleblock is currently in the "Parentfolder" variable.  Placement in bottom-left justified
	(COMMAND "filedia" 0)
	(setvar 'Cmdecho 1)
	(vl-catch-all-apply 'vl-cmdf
		(list "zoom" "extents") ;this needs to be done or the scale keeps increasing every time the command is used.
	)
	;;Sets the value for various strings within the program
	(setq parentFolder "Y:/CAD-Supplemental/Scripts and Lisps/AW Scripts/Publishing PDFs 2.0/Tririga Scrips and Lisps/");; main folder where the script will publish the pdf to
	(setq extMin (getvar "EXTMIN"))
	(setq extMax (getvar "EXTMAX"))
	(setq isLandscape nil)
	;figures out is the drawing should use a landscape or portrait style titleblock
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
	(setq scale ;figure out how to scale the block
		(getScale xLen yLen)
	)
	(if isLandscape
		(setq dwgName "2018_TitleBlock_Horizontal")
		(setq dwgName "2018_TitleBlock_Vertical")
	)
	(deleteOldBlocks dwgName) ;purges old unused block definitions
	(setq filePath 
		(strcat parentFolder dwgName)
	)
	(print scale)
	(print filePath)
	(getBlock filePath)
	(vl-catch-all-apply 'vl-cmdf	;inserts the whole file as a block
		(list "-insert" (strcat dwgName "_Dynamic") extMin scale "" "") ;inserts the file at the bottom left extent of the drawing
	)
	;puts the door on the door layer
	(vla-put-layer
		(vlax-ename->vla-object (entlast))
		"0"
	)
	(setvar 'Cmdecho 1)
	(COMMAND "filedia" 1)
)
(princ)

(defun getBlock (filePath / )
	(vl-catch-all-apply 'vl-cmdf	;inserts the whole file as a block
		(list "-insert" filePath (list 0 0 0) 1 "" "") ;inserts the file at the bottom left extent of the drawing
	)
	(setq block ;get the block so we can explod it
		(ssget "X"
			(list 
				(cons 2 dwgName)
				(cons 0 "INSERT")
			)
		)
	)
	(vl-catch-all-apply 'vl-cmdf ;explodes the block so that you have the inner dynamic block
		(list "._erase"  block "")
	)
	(princ)
)

(defun getScale (xLen yLen / scaleVal xDim yDim)
;helper function to figure out how to scale the titleblock to fit the drawing
	(if
		(> xLen yLen)
		;These are the drawing inner dimensions for the titleblocks rounded down so that they are slightly larger than needed
		(progn ;horizontal titleblock
			(setq xDim 2800)
			(setq yDim 2000)
		)
		(progn ;vertical titleblock
			(setq xDim 3000)
			(setq yDim 4200)
		)
	)
	(setq xScale 
		(/ xLen xDim)
	)
	(setq yScale
		(/ yLen yDim)
	)
	(setq scaleVal nil)
	(if ;figurout out the better scale
		(> xScale yScale)
		(setq scaleVal xScale)
		(setq scaleVal yScale)
	)
	(setq scaleVal scaleVal)
)

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
	(return-from checkIfLandscape xLen);this function doesn't work
)

(defun deleteOldBlocks ( blockName / acadObj adoc blockName2 blockCollection )
;purges old titleblock definitions.  Won't delete any titleblocks that are still active.
	(vl-load-com)
	(setq acadObj (vlax-get-acad-object))
	(setq adoc (vla-get-ActiveDocument acadObj))
	(vla-startundomark adoc)
	(setq blockCollection (vla-get-blocks adoc))
	(setq blockName2 
		(strcat blockName "_Dynamic")
	)
	(vlax-for block blockCollection
		(if 
			(and 
				(= (vla-get-IsLayout block) :vlax-false)
				(= (vla-get-IsXref block) :vlax-false)
			)
			(progn
				(setq thisBlock 
					(vla-get-name block)
				)
				(if 
					(or	
						(= thisBlock blockName)
						(= thisBlock blockName2)
					)
					(vl-catch-all-apply 'vlax-invoke
						(list thisBlock 'Delete)
					)
				)
			)
		)
	)
	(repeat 4
		(vla-purgeall adoc)
	)
	(princ)
)
