(defun c:recolor (/ colour thelayers frozenlayers toplayers)
	(vl-load-com)
	(setvar "filedia" 0)
		(setq acadobject (vlax-get-Acad-Object))
		(setq activedocument (vla-get-activedocument acadobject))
		(setq thelayers (vla-get-layers activedocument)) ;;makes "thelayers" variable a list of all the document layers
		(command "-layer" "thaw" "0" "set" "0" "") ;;set current layer to "0"
		;;This defines a list of layers that are in the layer standards but we dont publish and will freeze by default
		;;This list was derived from the list of layers in the original script made by Madhi
		(setq frozenlayers (list 
								"A-AREA-DRENCH" 
								"A-AREA-SHOWER" 
								"A-AREA-EYEWASH" 
								"A-RSCH-SAFT-DRENCH-HOSE" 
								"A-RSCH-SAFT-EYEWASH" 
								"A-RSCH-SAFT-SHOWER" 
								"A-FLOR-PATT" 
								"_Annotations" 
								"A-AREA-PATT" 
								"A-ANNO-USE" 
								"A-ANNO-ASGN" 
								"A-POLYLINE" 
								"A-POLYLINE-EXT" 
								"A-POLYLINE-INT" 
								"A-WALL-PANEL" 
								"A-FLOR-SLAB" 
								"A-FLOR-ABOVE" 
								"A-CATWALK" 
								"A-CLNG-GRID" 
								"A-LITE" 
								"A-FLOR-IDEN" 
								"A-CLNG" 
								"A-ANNO"
							)
		)
		(command "layon") ;;turns all layers on
		
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
						(
							(wcmatch (vla-get-name item) "*|*");;this uses a regex to search for a "|" in the layer name (to find xrefed layers)
							() ;;This will skip the next condition which freezes the layer. i.e. makes it so that xrefed layers are thawed by default
						)
						(t 
							(vl-catch-all-apply 'vla-put-freeze (list item :vlax-true));;freezes all non-xrefed layers that don't match any of our standard layer names
						)
					)
					(if
						(member (vla-get-name item) frozenlayers)
						(vl-catch-all-apply 'vla-put-freeze (list item :vlax-true))
					)
			)
		)
		
		(setq colorbylayerflag 
			(vl-catch-all-apply 'colorbylayer)  
		)
		(if 
			(vl-catch-all-error-p colorbylayerflag)
			(princ "failed to set all objects to be colored bylayer")
		)
		
		(setq toplayers (list ;;this defines a list of layers to be sent to the top of the draworder in inverse order
							"A-FLOR-PFIX" ;;this will be behind all the following layers, and above anything not on the list
							"A-FLOR-TPTN" 
							"A-FLOR-CHSE" 
							"A-EQIP" 
							"A-FLOOR-STRS" 
							"A-DOOR" 
							"A-COLS" 
							"A-GLAZ" 
							"A-GLAZ-SILL" 
							"A-WALL-PARTIAL" 
							"A-WALL-INTR" 
							"A-WALL-EXTR"))  ;;this will be the topmost layer in the draworder
			(foreach newtop toplayers 
				(if 
					(and ;;2 conditions: the layer exists in the drawing, and has objects on that layer
						(tblsearch "LAYER" newtop) ;;checks to see if the layer is in the drawing
						(setq ss ;;if this selection set it empty it will break the if loop
							(ssget "X" 
								(list 
									(cons 8 newtop) 
								)
							)
						)
					)
					(command "_draworder" ss "" "front");;send the drawing to the front.  could be changed to use vla-movetotop (will consider in the future)
				)
			)
			(command "HATCHTOBACK")
(princ)
(setvar "FILEDIA" 1)
)

(defun colorbylayer (/ layss)
;;helper function to set all colors to be bylayer
	(setq layss
		(ssget "X" ;;gets everything not colored bylayer
			'(
				(-4 . "<not")
				(62 . 256)  ;;62 is object color, 256 is bylayer
				(-4 . "not>")
			)
		)
	)
	(if layss	;;gets the number of layers in the selection set
		(setq laynum
			(sslength layss)
		)
		(setq laynum 0)
	)
	(if layss 
		(repeat laynum ;;iterates through all objects not colored bylayer
			(progn
				(setq layobj
					(ssname layss 0) ;;gets the first object in the set
				)
				(setq vlalayobj 
					(vlax-ename->vla-object layobj) ;;gets a vla object version of the entity
				)
				(vla-put-color vlalayobj 256) ;;changes entity to bylayer
				(ssdel layobj layss)  ;;delete the now correct layer
			)
		)
	)
	(princ)
)