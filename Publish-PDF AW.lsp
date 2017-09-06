

(defun c:FMINTERACT-PDF(/ ss fileName bldgSitecode floorNum bldgNum bldgDescL address city state zip)
	
	(COMMAND "filedia" 0)

	;;Sets values filename and floornum based on name of the drawing
	(setq fileName (getvar "dwgname"))
	(setq floorNum (substr fileName 1 (- (strlen fileName) 4)))
	(setq bldgNum (substr floorNum 1 (- (strlen floorNum) 3)))

	;;Sets the value for various strings within the program
	(setq layout "FMINTERACT")
	(setq plotout "DWG to PDF.pc3")
	(setq paperstyle "ANSI full bleed B (11.00 x 17.00 Inches)")
	(setq plotstyle "NU plotstyle.ctb")
	(setq parentfolder "Z:\\fminteract 8\\fminteract\\")

  ;;Loads the vla library and connects to the server
  (vl-load-com)

  (if adoConnect
      (if (= adok-adStateOpen (vlax-get-property ADOConnect "State"))
	  (vlax-invoke-method ADOConnect "Close")))
  (setq adoconnect nil)
  (setq ADOConnect (vlax-create-object "ADODB.Connection") ) 


(setq currConnectionString "File Name=Y:\\CAD-Supplemental\\Scripts and Lisps\\Sql connections\\FMNWUS.UDL;User ID=fmuser;Password=fm!user7" )

  (vlax-put-property ADOConnect "ConnectionString" currConnectionString)
  (vlax-invoke-method ADOConnect "Open" currConnectionString "" "" -1) 

;;queries the FMB0 database for the bldgSitecode value
(setq SQLStatement (strcat "SELECT (RTRIM(SITECODE)) FROM FMB0 WHERE BLDGCODE = '" bldgNum "'" ))

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
	(setq thisField (vlax-get-property fields "item" fieldsIndex)) 
	(setq bldgSitecode (vlax-variant-value (vlax-get-property thisField "Value")))

	;;Closes the query metioned above to the FMB0 database
        (vlax-invoke-method queryResult "Close")
        (vlax-release-object queryResult)
	(vlax-release-object cmd)

;;This uses the plot command and is followed by all of the responses to the settings.
;;There are extra ""'s at the end which is the equivalent of the *enter* key.
;;which exist as there are sometimes extra prompts for plotting that don't normally appear.
;;The enter's will just make it use the default value.
(vl-catch-all-apply 'vl-cmdf
  (list ".-plot" "Y" layout plotout paperstyle "INCHES" "landscape" "N" "layout" "1=1" "0.13,0.12" "N" plotstyle "Y" "N" "N" "N" (strcat parentfolder bldgSitecode  "\\"  floorNum) "y" "y")
)    	
	(COMMAND "filedia" 1)
)
(princ)