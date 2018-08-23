
(defun c:UpdateTriFields(/ ss fileName floorNum floorExtension floorString SummaryInfo docdata)
	;;updates the file properties for GROSS, Measured SF, NSF and Floor number based on the drawings using the file name and the tririga polyline layers
	;;only changes the floor number if it doesnt already exit
	(COMMAND "FIELDDISPLAY" 0)
	(COMMAND "FILEDIA" 0)
	(vl-load-com)
	
	;;Load needed libraries and connect to the database
	(setq acadObject (vlax-get-acad-object))
	(setq acadDocument (vla-get-ActiveDocument acadObject))
	(setq SummaryInfo (vlax-get-Property acadDocument 'SummaryInfo))
	
	;;Get variable names for the floor and building based on the drawing name
	(setq fileName (getvar "dwgname"))
	;;I feel that this part could be improved by looking into regex to find something like "two numbers after a '-' ", etc
	(setq lastDigit
		( substr fileName (- (strlen fileName) 4) 1)
	)
	(if  ;;checks if the last digst is an "M" to see if therer is a mezzanine
		(= lastDigit "M")
		(setq floorNum 
			( substr fileName (- (strlen fileName) 6) 2) ;second to last  2 digits of the actual file (includes dwg)
		)
		(setq floorNum 
			( substr fileName (- (strlen fileName) 5) 2) ;last 2 digits of the actual file (includes dwg)
		)
	)
	
	(setq onesDigit 
		(substr floorNum 2 1) 
	)
	(setq tensDigit 
		(substr floorNum 1 1) ;Checks if the floor is >= 10
	)
	
	(cond
	;;Figures out the ending of the floor number based on the onesDigit variable
		(
			(= tensDigit "1")
			(setq floorExtension "th")
		)
		(
			(= onesDigit "1")
			(setq floorExtension "st")
		)
		(
			(= onesDigit "2")
			(setq floorExtension "nd")
		)
		(
			(= onesDigit "3")
			(setq floorExtension "rd")
		)
		(
			(or	
				(= onesDigit "4")
				(= onesDigit "5")
				(= onesDigit "6")
				(= onesDigit "7")
				(= onesDigit "8")
				(= onesDigit "9")
			)
			(setq floorExtension "th")
		)
		(
			t ;exits the process if the drawing name is unreadable
			(progn
				(print "Error: drawing isn't named properly.  Floor name will not pull from drawing")
				(if ;; Adds a null floor property
					(not (customDwgPropExists "Floor")) 
					(vla-AddCustomInfo SummaryInfo "Floor" "") 
				)
				(vl-catch-all-apply 'setBuildingName)
				(vl-catch-all-apply 'queryDB)
				(command "regen")
				(vl-exit-with-error "error: drawing is not named properly")
			)
		)
	)
	
	(if 
	;; Make the full xth floor string based on if the floor is < 10 or >= 10
		(= tensDigit "0")
		(setq floorString 
			(strcat onesDigit floorExtension " Floor")
		)
		(if 
			(= floorExtension "th")
			(cond
				(
					(= floorNum "GR")
					(setq floorString "Ground Floor")
				)
				(
					(= floorNum "GN")
					(setq floorString "Ground Floor")
				)
				(
					(= floorNum "AT")
					(setq floorString "Attic")
				)
				(
					(= floorNum "BT")
					(setq floorString "Basement")
				)
				(
					(= floorNum "SB")
					(setq floorString "Sub-Basement")
				)
				(
					(= floorNum "PH")
					(setq floorString "Penthouse")
				)
				(
					(= floorNum "MZ")
					(setq floorString "Mezzanine")
				)
				( 
					t
					(setq floorString
						(strcat floorNum floorExtension " Floor")
					)
				)
			)
			(setq floorString 
				(strcat onesDigit floorExtension " Floor")
			)
		)
	)

	(if (= lastDigit "M")
		(setq floorString
			(strcat floorString " Mezzanine")
		)
	)
	
	(if ;; Only adds in the FLoor file property if it doesn't already exist
		(not (customDwgPropExists "Floor")) 
		(vla-AddCustomInfo SummaryInfo "Floor" floorString)  ;;Update Floor Value
	)
	(setq queryDBRetVal
		(vl-catch-all-apply 'queryDB) 
	)
	(setq updateBldgNameRetVal
		(vl-catch-all-apply 'setBuildingName)
	)
	(setq updateAreasRetVal
		(vl-catch-all-apply 'UpdateTriAreas)  ;; function below that adds teh NASF/Measured Sf/GROSS fields based on the tririga layers
	)
	(COMMAND "regen")
	(COMMAND "filedia" 1)
)

(defun setBuildingName (/ bldgName)
	;;function that finds that building name based on the parent folder of the drawing, and updates the BldgName field if it's missing.  
	(vl-load-com)
	(setq filePath (getvar "dwgprefix")) ;get the relative drawing filepath
	;;looks for the portion of the filepath after a "-" symbol, since the path should be e.g. Y:\FCCAD\R124-1603 Orrington, we want 1603 Orrington
	(setq bldgNamePos  ;string-search returns the position of the "-"
		(+
			(vl-string-search "\-" filePath)
			2
		)
	)
	;extracts the actual part of the file we care about
	(setq bldgName
		(substr filePath bldgNamePos
			( - (strlen filePath) bldgNamePos )
		)
	)
	;;This portion loops through the string looking for areas where there is a lowercase or number followed by a capitol
	;;If so, it inserts a space between them
	(setq idx 1)
	(repeat (- (strlen bldgName) 1)
		(setq twoLetters 
			(substr bldgName idx 2)
		)
		(if 
			(wcmatch twoLetters "*[a-z][A-Z]*,*[1-9][A-Z]*,*[A-Z][A-Z]*")
			(progn
				(setq idx 
					(+ idx 1)
				)
				(setq bldgName
					(insertString bldgName " " idx)
				)
			)
		)
		(setq idx (+ idx 1))
	)
	
	(setq acadObject (vlax-get-acad-object))
	(setq acadDocument (vla-get-ActiveDocument acadObject))
	(setq SummaryInfo (vlax-get-Property acadDocument 'SummaryInfo))
	;;Adds in the BldgName value
	(if ;; Only adds in the BldgName file property if it doesn't already exist
		(not (customDwgPropExists "BldgName")) 
		(vla-AddCustomInfo SummaryInfo "BldgName" bldgName)  
	)
)

(defun insertString (baseString newChars pos /)
	;;helper function that inserts a string NewChars into baseString at position pos
	(strcat
		(substr baseString 1 (1- pos))
		newChars
		(substr baseString pos)
	)
)

(defun UpdateTriAreas(/ polys AreaList nsf msf SummaryInfo myFilter gsf)
	;; Updates the NASF, Measured SF, and GROSS properties in the drawing based on the triSpaceLayer, triMeasuredGrossAreaLayer, and triGrossAreaLayer, respectively
	(setvar 'Cmdecho 0)
	(setvar 'Nomutt 1)
	(vl-load-com)

	;;;Calculates total area of all A-Polyline polylines
  (setq myFilter1 
	(list 
		(cons 0 "LWPOLYLINE")
		(cons 8 "triSpaceLayer")
	)
  )
  (setq polys (ssget "X" myFilter1))
   
	(progn
		(setq nsf 0.0)
		(if polys
			(repeat (setq i (sslength polys))
				(setq nsf (+ nsf (vlax-curve-getarea (ssname polys (setq i (1- i))))))
			)
		)
	)
     
	;;;Calculates the area of all a-polyline-ext objects and links it to the gsf variable  
  
  (setq myFilter2(list (cons 0 "LWPOLYLINE")(cons 8 "triGrossAreaLayer")))
  (setq polys (ssget "X" myFilter2))
   
	(progn
		(setq gsf 0.0)
		(if polys
			(repeat (setq i (sslength polys))
				(setq gsf (+ gsf (vlax-curve-getarea (ssname polys (setq i (1- i))))))
			)
		)
	)
     

	;;;Calculates the area of all a-polyline-int objects and links it to the gsf variable  
  
  (setq myFilter3(list (cons 0 "LWPOLYLINE")(cons 8 "triMeasuredGrossAreaLayer")))
  (setq polys (ssget "X" myFilter3))
  
	(progn
		(setq msf 0.0)
		(if polys
			(repeat (setq i (sslength polys))
				(setq msf (+ msf (vlax-curve-getarea (ssname polys (setq i (1- i))))))
			)
		)
	)
		 
	;;Updates the custom properties in the drawings for GSF and NASF    
	(setq acadObject (vlax-get-acad-object))
	(setq acadDocument (vla-get-ActiveDocument acadObject))
	(setq SummaryInfo (vlax-get-Property acadDocument 'SummaryInfo))

	;;changes units to feet
	(setq gsf (/ gsf 144))
	(setq nsf (/ nsf 144))
	(setq msf (/ msf 144))

	;;Adds in the custom values for the Gross SF and Measured Gross SF.
	;;These correspond to the sum of Exterior and Interior gross polylines, respectively
	;;If these values already exist, it will not change them
	;;The "Update Custom Fields" Lisp will delete all custom info, and this lisp is designed to be run after that one.

	;;Deletes the "Measured SF" field if it already exists
	(if (customDwgPropExists "NASF")
		(vla-RemoveCustomByKey SummaryInfo "NASF")
	)
	(if (customDwgPropExists "GROSS")
		(vla-RemoveCustomByKey SummaryInfo "GROSS")
	)
	(if (customDwgPropExists "Measured SF")
		(vla-RemoveCustomByKey SummaryInfo "Measured SF")
	)
	(vla-AddCustomInfo SummaryInfo "NASF" (rtos nsf 2 2))
	(vla-AddCustomInfo SummaryInfo "GROSS" (rtos gsf 2 2))
	(vla-AddCustomInfo SummaryInfo "Measured SF" (rtos msf 2 2))
	(setvar 'Cmdecho 1)
	(setvar 'Nomutt 0)
	(princ)
)

(defun customDwgPropExists (custProp / pExists i dProps pKey pVal)
;; Function I found online to check if a custom propery exists
  (vl-load-com)
  (setq
    pExists nil
    i -1
    dProps
     (vlax-get-Property
       (vla-get-ActiveDocument
         (vlax-get-acad-object)
       )
      'SummaryInfo
     )
  )
  (repeat (vla-numCustomInfo dProps)
    (vla-getCustomByIndex dProps (setq i (1+ i)) 'pKey 'pVal)
    (if (= (strcase pKey) (strcase custProp))
      (setq pExists 'T)
    )
  )
  (eval pExists)
)

(defun queryDB(/ ss fileName floorNum bldgNum adoconnect currConnectionString SQLStatement cmd queryResult fields fieldsCount fieldsIndex bldgDescL address city state zip doc db si nc nasf gross SummaryInfo docdata)
	
	(COMMAND "filedia" 0)

	;;Get variable names for the floor and building based on the drawing name
	(setq fileName (getvar "dwgname"))
	(setq floorNum (substr fileName 1 (- (strlen fileName) 4)))
	(setq bldgNum (substr floorNum 1 (- (strlen floorNum) 3)))

  ;;Load needed libraries and connect to the database
  (vl-load-com)

(setq acadObject (vlax-get-acad-object))
(setq acadDocument (vla-get-ActiveDocument acadObject))
(setq SummaryInfo (vlax-get-Property acadDocument 'SummaryInfo))

  (if adoConnect
      (if (= adok-adStateOpen (vlax-get-property ADOConnect "State"))
	  (vlax-invoke-method ADOConnect "Close")))
  (setq adoconnect nil)
  (setq ADOConnect (vlax-create-object "ADODB.Connection") ) 


(setq currConnectionString "File Name=Y:\\CAD-Supplemental\\Scripts and Lisps\\Sql connections\\FMNWUS.UDL;User ID=fmuser;Password=fm!user7" )

  (vlax-put-property ADOConnect "ConnectionString" currConnectionString)
  (vlax-invoke-method ADOConnect "Open" currConnectionString "" "" -1) 

;;Query the FMB0 database for the Building Name, address, city, state, and zip
(setq SQLStatement (strcat "SELECT (RTRIM(BLDGDESCL)), (RTRIM(STREET)), (RTRIM(CITY)), (RTRIM(STATE)), (RTRIM(ZIP)) FROM FMB0 WHERE BLDGCODE = '" bldgNum "'" ))

	(setq cmd (vlax-create-object "ADODB.Command"))
	(vlax-put-property cmd "ActiveConnection" ADOConnect)
	(vlax-put-property cmd "CommandTimeout"  30)
	(vlax-put-property cmd "CommandText" SQLStatement)

	(setq queryResult (vlax-create-object "ADODB.Recordset"))
	(vlax-invoke-method queryResult "OPEN" cmd nil adok-adOpenDynamic adok-adLockBatchOptimistic adok-adCmdUnknown) 

	(setq fields (vlax-get-property queryResult "Fields")
	  fieldsCount (1- (vlax-get-property fields "Count")) ; zero-based index
	  fieldsIndex 0
	  strOneRow nil)

	;;Set the variable value to the quieried objects
	(setq bldgDescL (vlax-variant-value (vlax-get-property (vlax-get-property fields "item" 0) "Value")))
	(setq address (vlax-variant-value (vlax-get-property (vlax-get-property fields "item" 1) "Value")))
	(setq city (vlax-variant-value (vlax-get-property (vlax-get-property fields "item" 2) "Value")))
	(setq state (vlax-variant-value (vlax-get-property (vlax-get-property fields "item" 3) "Value")))	
	(setq zip (vlax-variant-value (vlax-get-property (vlax-get-property fields "item" 4) "Value")))


;;Querty the FML0 database for the floornumber (e.g. 2nd) and the NASF
(setq SQLStatement (strcat "SELECT (RTRIM(floordesc)), (RTRIM(assignable)) FROM FML0 WHERE DWGNAME = '" floorNum "'" ))

	(setq cmd (vlax-create-object "ADODB.Command"))
	(vlax-put-property cmd "ActiveConnection" ADOConnect)
	(vlax-put-property cmd "CommandTimeout"  30)
	(vlax-put-property cmd "CommandText" SQLStatement)

	(setq queryResult (vlax-create-object "ADODB.Recordset"))
	(vlax-invoke-method queryResult "OPEN" cmd nil adok-adOpenDynamic adok-adLockBatchOptimistic adok-adCmdUnknown) 

	(setq fields (vlax-get-property queryResult "Fields")
	  fieldsCount (1- (vlax-get-property fields "Count")) ; zero-based index
	  fieldsIndex 0
	  strOneRow nil)

	(setq floorDesc (vlax-variant-value (vlax-get-property (vlax-get-property fields "item" 0) "Value")))
	(setq nasf (vlax-variant-value (vlax-get-property (vlax-get-property fields "item" 1) "Value")))

        (vlax-invoke-method queryResult "Close")
        (vlax-release-object queryResult)
	  (vlax-release-object cmd)

;;Gets the value of the "NASF" custom field and saves it - since I'm about to delete it
;;(setq docdata (vla-get-summaryinfo (vla-get-activedocument (vlax-get-acad-object))))
;;(setq errobj (vl-catch-all-apply 'vla-GetCustomByKey (list docdata "NASF" 'nasf)))
;;(setq errobj2 (vl-catch-all-apply 'vla-GetCustomByKey (list docdata "Gross" 'gross)))


;;Delete Current custom data
(repeat (setq n (vla-NumCustomInfo SummaryInfo))
	(vla-RemoveCustomByIndex SummaryInfo (setq n (1- n)))
)

;; If the NASF value didn't exists, sets NASF to "NA"
;;(if (vl-catch-all-error-p errobj)
;;	(setq nasf "NA")
;;)

	;;Puts back in the custom values that were just deleted - expect for the GSF calculation, which is done in the "Update Areas" Script
	(vla-AddCustomInfo SummaryInfo "BldgName" bldgDescL)
	(vla-AddCustomInfo SummaryInfo "Address" address)
	(vla-AddCustomInfo SummaryInfo "City" city)
	(vla-AddCustomInfo SummaryInfo "State" state)
	(vla-AddCustomInfo SummaryInfo "Zip" zip)
	(vla-AddCustomInfo SummaryInfo "Floor" floorDesc)
	(vla-AddCustomInfo SummaryInfo "NASF" nasf)

	(COMMAND "filedia" 1)
)
(princ)
