(defun c:fmlayers (/ ltype)

#| 
Program that will create all of the standard layers with the correct colors and linetypes
will also change the color and lineweights of any standard layers in the drawing
loads the hidden and hidden2 linetypes if they don't exist - assumes you have acadiso file in the default location
Intended to be used as a file to quickly load in the proper layers to start bringing in new drawings
|#

	(vl-load-com)
		(setq acadobject (vlax-get-Acad-Object))
		(setq activedocument (vla-get-activedocument acadobject))
		(setq thelayers (vla-get-layers activedocument))
	
	(setq linelist (list "HIDDEN2" "HIDDEN"))
	(setq linefile "acadiso.lin")
	
	(foreach ltype linelist
		(if (= (tblsearch "ltype" ltype) nil)  ;;Looks for the hidden linetype and loads it from acadiso.lin if not already in the drawing
			(command "-linetype" "load" ltype linefile "")
				(princ)
		)
	)
	
	(setq laylist ;;creates of list of layers
		(list 
		'("A-ANNO" 3 "CONTINUOUS")
		'("A-ANNO-AREA" 7 "CONTINUOUS")
		'("A-ANNO-ASGN" 7 "CONTINUOUS")
		'("A-ANNO-DIMS" 140 "CONTINUOUS")
		'("A-ANNO-TITL" 2 "CONTINUOUS")
		'("A-ANNO-USE" 7 "CONTINUOUS")
		'("A-AREA-IDEN" 7 "CONTINUOUS")
		'("A-AREA-PATT" 7 "CONTINUOUS")
		'("A-CATWALK" 5 "HIDDEN")
		'("A-CLNG" 3 "CONTINUOUS")
		'("A-CLNG-GRID" 4 "CONTINUOUS")
		'("A-COLS" 170 "CONTINUOUS")
		'("A-DOOR" 90 "CONTINUOUS")
		'("A-EQIP" 5 "CONTINUOUS")
		'("A-FLOR-CASE" 5 "CONTINUOUS")
		'("A-FLOR-CHSE" 210 "CONTINUOUS")
		'("A-FLOR-EVTR" 30 "CONTINUOUS")
		'("A-FLOR-IDEN" 3 "CONTINUOUS")
		'("A-FLOR-PATT" 30 "CONTINUOUS")
		'("A-FLOR-PFIX" 5 "CONTINUOUS")
		'("A-FLOR-SLAB" 5 "CONTINUOUS")
		'("A-FLOR-STRS" 10 "CONTINUOUS")
		'("A-FLOR-TPTN" 151 "CONTINUOUS")
		'("A-FURN" 5 "HIDDEN2")
		'("A-GLAZ" 130 "CONTINUOUS")
		'("A-GLAZ-SILL" 5 "CONTINUOUS")
		'("A-HATCH" 253 "CONTINUOUS")
		'("A-LAB-CASE" 190 "CONTINUOUS")
		'("A-LAB-SINK" 135 "CONTINUOUS")
		'("A-LAB-TEXT" 140 "CONTINUOUS")
		'("A-LITE" 3 "CONTINUOUS")
		'("A-POLYLINE" 1 "CONTINUOUS")
		'("A-POLYLINE-EXT" 6 "CONTINUOUS")
		'("A-POLYLINE-INT" 2 "CONTINUOUS")
		'("A-PORCH" 3 "CONTINUOUS")
		'("A-ROOF" 5 "CONTINUOUS")
		'("A-WALL-CAGE" 190 "HIDDEN")
		'("A-WALL-EXTR" 1 "CONTINUOUS")
		'("A-WALL-INTR" 3 "CONTINUOUS")
		'("A-WALL-PARTIAL" 3 "HIDDEN2")
		'("A-RSCH-SAFT-DRENCH-HOSE" 200 "CONTINUOUS")
		'("A-RSCH-SAFT-EYEWASH" 172 "CONTINUOUS")
		'("A-RSCH-SAFT-SHOWER" 100 "CONTINUOUS")
		'("A-AREA-DRENCH" 200 "CONTINUOUS")
		'("A-AREA-EYEWASH" 172 "CONTINUOUS")
		'("A-AREA-SHOWER" 100 "CONTINUOUS")
		)
	)
	
	(foreach stdlayer laylist ;step through all of the layers in the list
		(progn
			(setq layname (car stdlayer))
			(setq laycolor (nth 1 stdlayer))
			(setq laytype (nth 2 stdlayer))
			(if (= (tblsearch "LAYER" layname) nil)  ;makes a layer if it doesnt exist
				(vla-add thelayers layname)
			)
			(setq laycur (tblobjname "layer" layname));;gets the layer as a normal object
			(setq layobj (vlax-ename->vla-object laycur));;makes the layer a vla-object so it can be used with vla function
			(vla-put-color layobj laycolor) ;sets the color of the layer 
			(vla-put-linetype layobj laytype)  ;sets the linetype
		)
	)
		
	(princ)
)