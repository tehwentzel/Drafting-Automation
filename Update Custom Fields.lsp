

(defun c:UpdateFields(/ ss fileName floorNum bldgNum adoconnect currConnectionString SQLStatement cmd queryResult fields fieldsCount fieldsIndex bldgDescL address city state zip doc db si nc nasf gross SummaryInfo docdata)
	
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