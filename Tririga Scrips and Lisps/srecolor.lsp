(defun c:srecolor (/ colour thelayers frozenlayers)
;;This is a version of the "recolor" lisp that will not freeze layers
	(vl-load-com)
	(setvar "filedia" 0)
		(setq acadobject (vlax-get-Acad-Object))
		(setq activedocument (vla-get-activedocument acadobject))
		(setq thelayers (vla-get-layers activedocument)) ;;makes "thelayers" variable a list of all the document layers

		;;This is a loop that loops through the layers, and if they meet certain criteria, will set their color and freeze/unfreeze them
		;;All layers that aren't standard layers are frozen.  Layers in standar layers are set to their default color
		(vlax-for item thelayers ;iterate throught the 
			(progn
				(vl-catch-all-apply 'vla-put-freeze (list item :vlax-false))
					(cond
						(
							(member (vla-get-name item) '("_Annotations"))
							(vla-put-color item 11) ;;sets the color
						)
						(
							(member (vla-get-name item) '("A-HATCH"))
							(vla-put-color item 253)
						)
						(
							(member (vla-get-name item) '("A-FLOR-CHSE"))
							(vla-put-color item 210)
						)
						(
							(member (vla-get-name item) '("A-WALL-CAGE" "A-LAB-CASE"))
							(vla-put-color item 170)
						)
						(
							(member (vla-get-name item) '("A-COLS"))
							(vla-put-color item 170)
						)
						(
							(member (vla-get-name item) '("A-FLOR-TPTN"))
							(vla-put-color item 151)
						)
						(
							(member (vla-get-name item) '("A-LAB-TEXT" "A-ANNO-DIMS"))
							(vla-put-color item 140)
						)
						(
							(member (vla-get-name item) '("A-LAB-SINK"))
							(vla-put-color item 135)
						)
						(
							(member (vla-get-name item) '("A-GLAZ"))
							(vla-put-color item 130)
						)
						(
							(member (vla-get-name item) '("A-DOOR"))
							(vla-put-color item 90)
						)
						(
							(member (vla-get-name item) '("A-FLOR-PATT" "A-FLOR-EVTR"))
							(vla-put-color item 30)
						)
						(
							(member (vla-get-name item) '("A-FLOR-STRS"))
							(vla-put-color item 10)
						)
						(
							(member (vla-get-name item) '("A-AREA-PATT" "A-AREA-IDEN" "A-ANNO-USE" "A-ANNO-ASGN" "A-ANNO-AREA"))
							(vla-put-color item 7)
						)
						(
							(member (vla-get-name item) '("A-POLYLINE-EXT"))
							(vla-put-color item 6)
						)
						(
							(member (vla-get-name item) '("A-WALL-PANEL" "A-ROOF" "A-GLAZ-SILL" "A-FURN" "A-FLOR-SLAB" "A-FLOR-PFIX" "A-FLOR-CASE" "A-FLOR-ABOVE" "A-EQIP" "A-CATWALK"))
							(vla-put-color item 5)
						)
						(
							(member (vla-get-name item) '("A-CLNG-GRID"))
							(vla-put-color item 4)
						)
						(
							(member (vla-get-name item) '("A-WALL-PARTIAL" "A-WALL-INTR" "A-PORCH" "A-LITE" "A-FLOR-IDEN" "A-CLNG" "A-ANNO"))
							(vla-put-color item 3)
						)
						(
							(member (vla-get-name item) '("A-POLYLINE-INT" "A-ANNO-TITL"))
							(vla-put-color item 2)
						)
						(
							(member (vla-get-name item) '("A-WALL-EXTR" "A-POLYLINE"))
							(vla-put-color item 1)
						)
						(
							(member (vla-get-name item) '("A-RSCH-SAFT-SHOWER" "A-AREA-SHOWER"))
							(vla-put-color item 100)
						)
						(
							(member (vla-get-name item) '("A-RSCH-SAFT-EYEWASH" "A-AREA-EYEWASH"))
							(vla-put-color item 172)
						)
						(
							(member (vla-get-name item) '("A-RSCH-SAFT-DRENCH-HOSE" "A-AREA-DRENCH"))
							(vla-put-color item 200)
						)
					)
			)
		)
	(setq toplayers (list "A-FLOR-PFIX" "A-FLOR-TPTN" "A-FLOR-CHSE" "A-EQIP" "A-FLOOR-STRS" "A-DOOR" "A-COLS" "A-GLAZ" "A-GLAZ-SILL" "A-WALL-PARTIAL" "A-WALL-INTR" "A-WALL-EXTR"))
		(foreach newtop toplayers
			(if 
				(and (tblsearch "LAYER" newtop)
					(setq ss (ssget "X" (list (cons 8 newtop))))
				)
				(command "_draworder" ss "" "front")
			)
		)
(princ)
(setvar "FILEDIA" 1)
)