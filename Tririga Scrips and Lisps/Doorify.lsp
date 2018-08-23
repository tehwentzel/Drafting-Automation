(defun c:doorify(/ isBlock doorName)
	;Command to automatically insert and scale a titleblock into the drawing.  Said titleblock is currently in the "Parentfolder" variable.  Placement in bottom-left justified
	(COMMAND "filedia" 0)
	(setvar 'Cmdecho 1)
	(vl-load-com)
	;;Sets the value for various strings within the program
	(setq doorName "door_block")
	(setq isBlock
		(tblsearch "BLOCK" doorName)
	)
	;inserts the door block if there is no "door_block" block
	(if
		(not isBlock)
		(getDoor)
	)
	;inserts the door at a given selected point
	(vl-catch-all-apply 'vl-cmdf	;inserts the whole file as a block
		(list "-insert" doorName (getpoint "select insertion point") "" "" "") ;inserts the file at the bottom left extent of the drawing
	)
	;puts the door on the door layer
	(vla-put-layer
		(vlax-ename->vla-object (entlast))
		"A-DOOR"
	)
	(setvar 'Cmdecho 1)
	(COMMAND "filedia" 1)
)
(princ)

(defun getDoor ( / block doorpath) 
	;inserts the door block in the event that the door block isn't in the drawing.  Inserts the "Dynamic Door" file with the block and then deletes it
	
	;checks if there's already a "dynamic door" block and deletes it, as that messes up the insertion
	(if	
		(tblsearch "BLOCK" "Dynamic_Door")
		(deleteOldBlocks "Dynamic_Door")
	)
	;inserts the door
	(setq doorPath "Y:/CAD-Supplemental/Scripts and Lisps/AW Scripts/Publishing PDFs 2.0/Tririga Scrips and Lisps/Dynamic_Door");; main folder where the script will publish the pdf to
	(vl-catch-all-apply 'vl-cmdf	
		(list "-insert" doorPath (list 0 0 0) "" "" "")
	)
	;gets the given block and erases it
	(setq block 
		(ssget "X"
			(list 
				(cons 2 "Dynamic_Door")
				(cons 0 "INSERT")
			)
		)
	)
	(vl-catch-all-apply 'vl-cmdf
		(list "._erase"  block "")
	)
	(princ)
)

(defun deleteOldBlocks ( blockName / acadObj adoc blockCollection )
	;deletes a block by name
	(vl-load-com)
	(setq acadObj (vlax-get-acad-object))
	(setq adoc (vla-get-ActiveDocument acadObj))
	(vla-startundomark adoc)
	(setq blockCollection (vla-get-blocks adoc))
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
					(= thisBlock blockName)
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
