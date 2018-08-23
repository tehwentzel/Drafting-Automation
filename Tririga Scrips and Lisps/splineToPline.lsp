(defun c:splineToPline ( / splineSet ss sRetVal tempBlock bList)
;function that flatten splines, as they don't show up in tririga
	(setvar 'Cmdecho 0)
	(setvar 'Nomutt 1)
	(vl-load-com)
	(setq acadObj (vlax-get-acad-object))
	(setq adoc (vla-get-ActiveDocument acadObj))
	(vla-startundomark adoc)
	;(setq blockCollection (vla-get-BLocks adoc))
	;(vlax-for block blockCollection
	;	(if 
	;		(and 
	;			(= (vla-get-IsLayout block) :vlax-false)
	;			(= (vla-get-IsXref block) :vlax-false)
	;		)
	;		(print (assoc 100 (entget (vlax-vla-object->ename block))))
	;	)
	;)
	;;finds all splines
	(setq splineSet
		(ssget "X" 
			'((0 . "SPLINE"))
		)
	)
	(if splineSet
		(setq sRetVal (sslength splineSet))
		(setq sRetVal 0)
	)
	;iterates through the splines and flattens them
	(if splineSet
		(progn
			(vlax-for splineObj
				(setq splineSS
					(vla-get-activeselectionset adoc)
				)
				(setq splineEname (vlax-vla-object->ename splineObj))
				(vl-catch-all-apply 'acet-flatn-spline ;will draw a polyline over the spline without deleteing it
					(list splineEname)
				)
				(entdel splineEname) ;delete the old spline
			)
			(vla-delete splineSS) ;delete the new selection set
		)
	)
	(vla-endundomark adoc)
	(vla-regen adoc acallviewports)
	(setvar 'Cmdecho 1)
	(setvar 'Nomutt 0)
	(princ sRetVal)
)

;;below this is part of the "flattensup.lsp" file from express tools, which holds most of the functions for the flatten function
;;I don't know what the deal with all the other acet-* functions that are called, but this functions works as far as I cn tell
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Takes a spline and creates a lwpolyline
;
(defun acet-flatn-spline ( e1 / na cxv lst x proplst ss na2 gp xt fuz lst2 )
 (if (equal (type e1) 'ENAME)
     (setq na e1
           e1 (entget na)
     );setq then
     (setq na (cdr (assoc -1 e1)));setq else
 );if
 (setq     cxv (acet-geom-z-axis)
           lst (acet-geom-object-point-list na -1)
           lst (mapcar '(lambda (x) 
                         (acet-point-flat x 1 cxv)
                        )
                        lst
               );mapcar
           ;lst (acet-geom-list-remove-straight-segs lst nil)
            xt (acet-geom-list-extents lst)
            xt (distance (car xt) (cadr xt))
           fuz (acet-geom-calc-arc-error xt) 
       proplst (acet-general-props-get e1)
           na2 (entlast)
 );setq
 (cond
  ((= (length lst) 2)
   (setq  gp (acet-general-props-get-pairs e1)   ;; get general properties
          e1 (list '(0 . "LINE") '(100 . "AcDbEntity")
                   (assoc 67 e1) (assoc 410 e1) (assoc 8 e1)
                   '(100 . "AcDbLine")
                   (cons 10 (trans (car lst) 1 cxv))
                   (cons 11 (trans (cadr lst) 1 cxv))
                   (cons 210 cxv)
             );list
          e1 (acet-general-props-set-pairs e1 gp)
   );setq
   (entmake e1)
  );cond #1 draw a line
  ((setq lst2 (acet-geom-point-list-to-arc-list lst fuz))
      (acet-geom-arc-list-to-pline 
        (list (assoc 67 e1) (assoc 410 e1) (assoc 8 e1) (cons 210 cxv))
        lst2
      )
  );cond #2 create a pline with arcs
  ((assoc 210 e1)
   (setq e1 (acet-flatn-orthogonal-object-elist na))
   (entmake e1)
  );cond #3
 );cond close
 (if (not (equal na2 (entlast)))
     (progn
      (setq ss (ssadd (entlast) (ssadd)))
      (acet-general-props-set ss proplst)
      (setq na (ssname ss 0))
     );progn
     (setq na nil)
 );if
 na
);defun acet-flatn-spline
 
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun acet-flatn-orthogonal-object-elist ( na / e1 xv cxv ss p1 p2 p3 p4 c d xva gp )
   ;; then the arc is orthogonal to the current ucs so just create a line
   (setq  e1 (entget na)
          xv (cdr (assoc 210 e1))
         cxv (acet-geom-z-axis)
          ss (ssadd na (ssadd))
          p1 (acet-geom-ss-extents ss T) ;; shrinkwrap=T
          p2 (cadr p1)
          p1 (car p1)
          p1 (acet-point-flat p1 cxv cxv)	;; flatten the extents points and convert to current ucs
          p2 (acet-point-flat p2 cxv cxv)
           c (acet-geom-midpoint p1 p2)
           d (distance c p1)
   );setq
   (if (not xv)
       (setq xv cxv)
   );if
 
   (setq xva (trans xv 0 cxv T)			;; extrusion vector
         xva (- (angle '(0.0 0.0 0.0) xva)	;; angle of arc z vector - 90
                (/ pi 2.0)
             )
          p3 (polar c xva d)
          p4 (polar c (+ xva pi) d)
 
          gp (acet-general-props-get-pairs e1)   ;; get general properties
          e1 (list '(0 . "LINE") '(100 . "AcDbEntity")
                   (assoc 67 e1) (assoc 410 e1) (assoc 8 e1)
                   '(100 . "AcDbLine")
                   (cons 10 (trans p3 cxv 0))
                   (cons 11 (trans p4 cxv 0))
                   (cons 210 cxv)
            );list
         e1 (acet-general-props-set-pairs e1 gp)
   );setq
 e1
);defun acet-flatn-orthogonal-object-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun acet-flatn-insert ( e1 / na bna na2 e2 a na2 ss n p1 xv bna2 attlst )
 (if (equal (type e1) 'ENAME)
     (setq na e1
           e1 (entget na)
     );setq then
     (setq na (cdr (assoc -1 e1)));setq else
 );if
 (setq bna (cdr (assoc 2 e1))
       na2 (tblobjname "block" bna)
        e2 (entget na2)
         a (cdr (assoc 70 e2))
 );setq
 (cond
  ((member '(100 . "AcDbMInsertBlock") e1)	;; minsert
   (setq na2 (entlast))
   (setq ss (acet-minsert-to-inserts na))
   (if ss
       (progn
        (setq n 0)
        (repeat (sslength ss)
         (setq na (ssname ss n))
         (acet-flatn-insert na)
         (setq n (+ n 1));setq
        );repeat
       );progn then
   );if
   (acet-ss-entdel ss)
   (if (setq ss (acet-ss-new na2))
       (progn
           (setq bna (strcat bna "-flat-"))
           (setq n 1)
           (while (tblobjname "block" (strcat bna (itoa n)))
            (setq n (+ n 1))
           );while
           (setq bna (strcat bna (itoa n))
                  xv (cdr (assoc 210 e1))
                  p1 (cdr (assoc 10 e1))
                  p1 (acet-point-flat p1 xv 1)
           );setq
           (command "_.-block" bna p1 ss "")
           (command "_.-insert" bna p1 "1" "1" "0")
           (setq na (entlast))
       );progn
       (setq na nil)
   );if
  );cond #1
 
  ((= 4 (logand 4 a))
   (setq na (acet-flatn-xref e1))	;; xref
  );cond #2
 
  (T
      ;; Make a copy and explode it and then flatten each of the new objects and delete 
      ;; the non-flat ones from the explode.
      (command "_.copy" na "" "0,0" "0,0")
      (setq    na2 (entlast)
            attlst (acet-insert-attrib-get na2)
                ss (acet-inherit-xplode na2 nil) ;;the nil used to be T to convert attdefs to text 5:37 PM 4/10/00
      );setq
 
      (acet-flatn-objects (list ss T nil)) ;; wmf when needed
      (acet-ss-entdel ss)
 
      ;; Define a new block from the flat objects and create an insert of of it
      (setq ss (acet-ss-new na2))
      (if (equal "*" (substr bna 1 1))
          (progn
           (setq bna2 (acet-block-make-anon ss nil))
           (acet-ss-entdel ss)
           (setq e2 e1
                 e2 (subst (cons 2 bna2) (assoc 2 e2) e2)
                 e2 (subst '(10 0.0 0.0 0.0) (assoc 10 e2) e2)
                 e2 (subst '(50 . 0.0) (assoc 50 e2) e2)
                 e2 (subst '(41 . 1.0) (assoc 41 e2) e2)
                 e2 (subst '(42 . 1.0) (assoc 42 e2) e2)
                 e2 (subst '(43 . 1.0) (assoc 43 e2) e2)
                 e2 (subst '(210 0.0 0.0 1.0) (assoc 210 e2) e2)
           );setq
           (entmake e2)
          );progn then anonymous
          (progn
           (acet-flatn-insert-preprocess-text ss)
           ;; get a unique name    
           (setq bna (strcat bna "-flat-"))
           (setq n 1)
           (while (tblobjname "block" (strcat bna (itoa n)))
            (setq n (+ n 1))
           );while
           (setq bna (strcat bna (itoa n))
                  xv (cdr (assoc 210 e1))
                  p1 (cdr (assoc 10 e1))
                  p1 (acet-point-flat p1 xv 1)
           );setq
           (command "_.-block" bna p1 ss "")
           (command "_.-insert" bna p1 "1" "1" "0")
          );progn then
      );if
      (setq na (entlast))
      (if attlst
          (acet-insert-attrib-set na attlst T)
      );if
  );cond #3
 );cond close
 
 na
);defun acet-flatn-insert

(defun acet-flatn-xref ( e1 / na bna tmp na2 ss n xv p1 e2 bna2 )
 (if (equal (type e1) 'ENAME)
     (setq na e1
           e1 (entget na)
     );setq then
     (setq na (cdr (assoc -1 e1)));setq else
 );if
 (setq bna (cdr (assoc 2 e1))
       tmp (vl-filename-mktemp "ACET" (getvar "tempprefix") ".dwg")
        xv (cdr (assoc 210 e1))
        p1 (cdr (assoc 10 e1))
        p1 (acet-point-flat p1 xv 1)
 );setq
 ;; get a unique name    
 (setq bna2 (strcat bna "-xref-"))
 (setq n 1)
 (while (tblobjname "block" (strcat bna2 (itoa n)))
  (setq n (+ n 1))
 );while
 (setq bna2 (strcat bna2 (itoa n)));setq


 ;; bind the xref and then wblock the bound version to a temp file 
 ;; and undo to bring back original state
 (command "_.-xref" "_bind" bna)

 (setq e2 (entget (tblobjname "block" bna)))
 (if (/= 4 (logand 4 (cdr (assoc 70 e2))))
     (progn
      (acet-sysvar-set (list "thumbsave" 0)) ;turn thumbnail creation off before wblock.
      (command "_.-wblock" tmp bna)
      (acet-cmd-exit)
      (acet-sysvar-restore)
      (command "_.undo" 2)
 
      ;; temporarily insert the block to import the definition and then delete it.
      (command "_.-insert" (strcat bna2 "=" tmp) "0,0" 1 1 0)
      (entdel (entlast))
      (vl-file-delete tmp)
 
      ;; now entmake an insert of the new block in the proper location
      (setq e1 (subst (cons 2 bna2) (assoc 2 e1) e1)) ;; swap in the new name and entmake
      (entmake e1)
 
      (setq na2 (entlast)) 
      (setq na (acet-flatn-insert na2))  ;;now call flatn on the new insert
 
      (entdel na2) ;; delete the temp block
      (acet-table-purge "block" bna2 T)
     );progn then bind succeeded
     (setq na nil);setq else
 );if
 na
);defun acet-flatn-xref

(acet-autoload2	'("acet-wmf.lsp"	(acet-flatn-pline-adjust-widths e1 xv)))
(acet-autoload2	'("acet-wmf.lsp"	(acet-geom-arc-list-to-pline e1 alst)))
(acet-autoload2	'("acet-wmf.lsp"	(acet-geom-point-list-to-arc-list lst fuz)))
(acet-autoload2	'("acet-wmf.lsp"	(acet-wmf-convert alst)))
(princ)
