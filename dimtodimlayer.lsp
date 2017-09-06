(defun c:dimtodimlayer (/ dimset dimlayer dimcount idx thisdim)
;;Helper function
;;Selects all dimensions not on an a-anno-dim layer
;;Creates the a-anno-dim layer if there is none
;;Sends all dimensions to the right layer
	(setvar 'Cmdecho 0)
	(vl-load-com)
	(setq dimset ;;selcts all the dimensions not on the a-anno-dims layer or not of type "dim-96"
		(ssget "X" 
			'(
				(0 . "DIMENSION")
				(-4 . "<OR")
				(8 . "~A-ANNO-DIMS")
				(3 . "~DIM-96")
				(-4 . "OR>")
			)
		)
	)
	(setq acadObj (vlax-get-acad-object))
	(setq doc (vla-get-ActiveDocument acadObj))
	(if ;;Add  the A-anno-layer if missing
		(not
			(tblsearch "LAYER" "A-ANNO-DIMS")
		)
		(progn
			(setq dimlayer
				(vla-Add
					(vla-get-layers doc)
					"A-ANNO-DIMS"
				)
			)
			(vla-put-color dimlayer 140)
		)
	)
	(setq idx 0)
	(setq dimcount 0)
	(if dimset
		(setq dimcount
			(sslength dimset)
		)	
	)
	(while ;;iterates through each erroneous dimension
		(< idx dimcount)
		(progn	
			(setq thisdim
				(ssname dimset idx)
			)
			(setq thisdim (vlax-ename->vla-object thisdim))
			(vla-put-layer thisdim "A-ANNO-DIMS") ;;changes layer of each erroneous dimension
			(vla-put-StyleName thisdim "DIM-96") ;;changes the style to dim-96
			(setq idx (1+ idx))
		)
	)
	(setvar 'Cmdecho 1)
	(setq retVal dimcount)
)
