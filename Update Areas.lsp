;;POLYAREA.LSP - (c) 1997-2001 Tee Square Graphics
;;
;;  Calculates the area of one or more closed polylines and
;;  displays the result in an AutoCAD Alert Window.
;;

(defun C:UpdateAreas(/ polys AreaList nsf msf SummaryInfo myFilter gsf)
	(setvar 'Cmdecho 0)
	(setvar 'Nomutt 1)
  (vl-load-com)

;;;Calculates total area of all A-Polyline polylines
  (setq myFilter1(list (cons 0 "LWPOLYLINE")(cons 8 "A-POLYLINE")))
  (setq polys (ssget "X" myFilter1))
   
  (progn
    (setq nsf 0.0)
      (repeat (setq i (sslength polys))
        (setq nsf (+ nsf (vlax-curve-getarea (ssname polys (setq i (1- i))))))
    )
  )
     
;;;Calculates the area of all a-polyline-ext objects and links it to the gsf variable  
  
  (setq myFilter2(list (cons 0 "LWPOLYLINE")(cons 8 "A-POLYLINE-EXT")))
  (setq polys (ssget "X" myFilter2))
   
  (progn
    (setq gsf 0.0)
      (repeat (setq i (sslength polys))
        (setq gsf (+ gsf (vlax-curve-getarea (ssname polys (setq i (1- i))))))
    )
  )

;;;Calculates the area of all a-polyline-int objects and links it to the gsf variable  
  
  (setq myFilter3(list (cons 0 "LWPOLYLINE")(cons 8 "A-POLYLINE-INT")))
  (setq polys (ssget "X" myFilter3))
   
  (progn
    (setq msf 0.0)
      (repeat (setq i (sslength polys))
        (setq msf (+ msf (vlax-curve-getarea (ssname polys (setq i (1- i))))))
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
(vla-AddCustomInfo SummaryInfo "Measured SF" (rtos msf 2 2))
(vla-AddCustomInfo SummaryInfo "GROSS" (rtos gsf 2 2))
	(setvar 'Cmdecho 1)
	(setvar 'Nomutt 0)
(princ)
)
