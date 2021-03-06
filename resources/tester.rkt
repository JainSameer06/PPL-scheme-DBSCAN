#lang racket
(provide(all-defined-out))
(define inFile(open-input-file (vector-ref (current-command-line-arguments) 0)))
;(define inFile(open-input-file "/home/sameer/Projects/PPL Assignment/resources/t0.in"))
(define precision '6)

(define (mysetprecision n p)
  (if (= n +inf.0) +inf.0
      (string->number (~r n #:precision p))
  )
) 

(define (precision_util lst)
  (if (null? lst) '()
      (cons (list (car(car lst)) (mysetprecision (car(cdr(car lst))) precision))  (precision_util (cdr lst))))
)

(define (modify_precision lst)
  (if (null? lst) '()
  (cons (precision_util (car lst)) (modify_precision (cdr lst))))
)

(define (trav input-file l)
  (define nextLine (read-line input-file))
  (if (eof-object? nextLine)
      l
      (cons nextLine (trav input-file l))))
      
(define extFileList (trav inFile'())); extFileList is the list of points as strings extracted from the input file

(define firstLine (string-split(car extFileList)));firstLine is the string corresponding to the first line of the input file
(define pointStrings (cdr extFileList));pointStrings is the list of point coordinates as strings

(define (toNumbers charList l);converts a list of characters to a list of numbers
  (define len (length charList))
  (if (equal? 0 len)
      l
      (cons (string->number(list-ref charList 0)) (toNumbers (cdr charList) l))))

(define specsList (toNumbers firstLine '()))
(define numPoints (list-ref specsList 0))
(define numDimensions (list-ref specsList 1))
(define k (list-ref specsList 2))
(define eps (list-ref specsList 3))
(define minpts (list-ref specsList 4))

(define (pointMatrix pointStringMatrix m)
  (define len (length pointStringMatrix))
  (if (equal? 0 len)
      m
      (cons (toNumbers(string-split(car pointStringMatrix)) '()) (pointMatrix (cdr pointStringMatrix) m))))

(define points (pointMatrix pointStrings '()))
(define pointCount (build-list (length points) (lambda(x) (+ x 1))))

(define (pointsWithIndices pointsWithoutIndices pointCountList m)
  (define len (length pointsWithoutIndices))
  (if (equal? 0 len)
      m
      (cons (list(car pointCountList) (car pointsWithoutIndices)) (pointsWithIndices (cdr pointsWithoutIndices) (cdr pointCountList) m))))

(define step1 (pointsWithIndices points pointCount '()))

(define (distanceSquare list1 list2 result)
  (define len(length list1))
  (if(equal? 0 len)
     result
     (+ (expt (- (car list1) (car list2)) 2) (distanceSquare (cdr list1) (cdr list2) result))))

(define (pointDistance point1 point2)
   (sqrt (distanceSquare (list-ref point1 1) (list-ref point2 1) 0)))

(define (pointDistanceWithIndex point1 point2)
  (if(equal? point1 point2)
     (list (list-ref point2 0) +inf.0)
     (list (list-ref point2 0) (pointDistance point1 point2))))
     
     
(define (distFromPoint point otherPoints l)
  (define len(length otherPoints))
  (if (equal? 0 len)
      l
      (cons (pointDistanceWithIndex point (car otherPoints)) (distFromPoint point (cdr otherPoints) l))))

(define (pointsFromPoints points1 points2 l)
  (define len(length points1))
  (if (equal? 0 len)
      l
      (cons (distFromPoint (car points1) points2 '()) (pointsFromPoints (cdr points1) points2 l))))

(define step2Old (pointsFromPoints step1 step1 '()))
(define step2 (modify_precision step2Old))

(define (insertInSortedList point lst)
  (define len(length lst))
  (if (equal? 0 len)
      (list point) 
      (if (< (list-ref point 1) (list-ref (car lst) 1)) (cons point lst) (cons (car lst) (insertInSortedList point (cdr lst)) ))))

(define (sortPointList inputList l)
  (define len(length inputList))
  (if (equal? 0 len)
      l
     (insertInSortedList (car inputList) (sortPointList (cdr inputList) l))))

(define (sortAll pointDistList l)
  (define len(length pointDistList))
  (if (equal? 0 len)
      l
      (cons (sortPointList (car pointDistList) '()) (sortAll (cdr pointDistList) l))))

  
(define distancesAllSorted (sortAll step2 '()))

(define (getTopElements sortedList kElems l)
  (if (equal? kElems 0)
      l
      (cons (list-ref (car sortedList) 0) (getTopElements (cdr sortedList) (- kElems 1) l))))
      

(define (getNeighboursAll sortedDistances kElems l)
  (define len(length sortedDistances))
  (if (equal? 0 len)
      l
      (cons (getTopElements (car sortedDistances) kElems '()) (getNeighboursAll (cdr sortedDistances) kElems l))))
  
  
(define (insertNumberSortedList num lst)
  (define len(length lst))
  (if (equal? 0 len)
      (list num) 
      (if (< num (car lst)) (cons num lst) (cons (car lst) (insertNumberSortedList num (cdr lst)) ))))

(define (sortList inputList l)
  (define len(length inputList))
  (if (equal? 0 len)
      l
     (insertNumberSortedList (car inputList) (sortList (cdr inputList) l))))

(define (sortAllLists lists l)
  (define len(length lists))
  (if (equal? 0 len)
      l
      (cons (sortList (car lists) '()) (sortAllLists (cdr lists) l))))

(define step3(sortAllLists (getNeighboursAll distancesAllSorted k '()) '()))

(define (isPresent elem lst)
  (define len(length lst))
  (if (equal? 0 len)
      false
      (if (equal? elem (car lst)) true (isPresent elem (cdr lst)))))

(define (intersection list1 list2 l)
  (define len(length list1))
  (if (equal? 0 len)
      l
      (if (isPresent (car list1) list2) (cons (car list1) (intersection (cdr list1) list2 l)) (intersection (cdr list1) list2 l))))
  
  
(define (pointEdgeList pointNeighbours allNeighbours pId index l)
  (if(equal? index (+ numPoints 1))
     l
     (if (and (isPresent pId (car allNeighbours)) (isPresent index pointNeighbours)) (cons (list index (length(intersection pointNeighbours (car allNeighbours) '()))) (pointEdgeList pointNeighbours (cdr allNeighbours) pId (+ index 1) l)) (pointEdgeList pointNeighbours (cdr allNeighbours) pId (+ index 1) l))))

(define (snGraph mainList neighboursList l count)
  (define len(length mainList))
  (if (equal? count (+ numPoints 1))
      l
      (cons (reverse (sortPointList (pointEdgeList (car mainList) neighboursList count 1 '()) '())) (snGraph (cdr mainList) neighboursList l (+ count 1)))))
  

(define step4(snGraph step3 step3 '() 1))

(define (getCoreConnections neighbourList epsilon l);uses a single list from step4 and gives a list of points within a distance epsilon from the given point
  (define len(length neighbourList))
  (if (equal? 0 len)
      l
      (if (>= (list-ref (car neighbourList) 1) epsilon) (cons (list-ref (car neighbourList) 0) (getCoreConnections (cdr neighbourList) epsilon l)) (getCoreConnections (cdr neighbourList) epsilon l))))

(define (getAllCoreConnections mainList neighbourList epsilon l)
  (define len(length mainList))
  (if (equal? 0 len)
      l
      (cons (getCoreConnections (car mainList) epsilon '()) (getAllCoreConnections (cdr mainList) neighbourList epsilon l))))
(define (getAllLengths lst l)
  (define len(length lst))
  (if (equal? 0 len)
      l
      (cons (length (car lst)) (getAllLengths (cdr lst) l))))
  
(define directConnectionList (getAllCoreConnections step4 step4 eps '()))
(define step5 (getAllLengths  directConnectionList '()))

(define (getCoreIndices densityList index minpts l)
  (define len(length densityList))
  (if (equal? 0 len)
      l
      (if (>= (car densityList) minpts) (cons index (getCoreIndices (cdr densityList) (+ index 1) minpts l))(getCoreIndices (cdr densityList) (+ index 1) minpts l))))
(define step6 (getCoreIndices step5 1 minpts '()))

;Step 7 calculation begins here
#|
(define (getRealCoreConnections allConnectionsFalse coreIndices l)
  (define len(length allConnectionsFalse))
  (if (equal? 0 len)
      l
      (cons (intersection (car allConnectionsFalse) coreIndices '()) (getRealCoreConnections (cdr allConnectionsFalse) coreIndices l))))
(define realCoreConnections(getRealCoreConnections directConnectionList step6 '()))
  

(define (getConnectedPoints adjList neighboursLists l)
  (define len(length adjList))
  (if (equal? 0 len)
      l
      (set-union (list->set(list-ref neighboursLists (- (car adjList) 1))) (getConnectedPoints (cdr adjList) neighboursLists l))))

(define (equalSets set1 set2)
  (and (subset? set1 set2) (subset? set2 set1)))

(define (getAllConnectedPoints mainList connectionList l)
  (define len(length mainList))
  (if (equal? 0 len)
      l
      (cons (getConnectedPoints (car mainList) connectionList (list->set'())) (getAllConnectedPoints (cdr mainList)connectionList l))))
  
(define coreConnectsList (getAllConnectedPoints realCoreConnections realCoreConnections '()))

(define (isPresentSet set setList)
  (define len(length setList))
  (if (equal? 0 len)
      false
      (if (equalSets set (car setList)) true (isPresentSet set (cdr setList)))))
  
(define (getClusters mainList connectedPointList l)
  (define len(length mainList))
  (if (equal? 0 len)
      l
      (if (and(not (set-empty? (car mainList))) (not (isPresentSet (car mainList)  (getClusters (cdr mainList) connectedPointList l)))) (cons (car mainList) (getClusters (cdr mainList) connectedPointList l)) (getClusters (cdr mainList) connectedPointList l))))

(define clusterListingS (getClusters coreConnectsList coreConnectsList '()))

(define (allSetsToLists mainList l)
  (define len(length mainList))
  (if (equal? 0 len)
      l
      (cons (sortList(set->list(car mainList)) '()) (allSetsToLists (cdr mainList) l))))
  
(define clusterListing (allSetsToLists clusterListingS '()))
(define clusterCount (build-list (length clusterListing) (lambda(x) (+ x 1))))

(define step7 (pointsWithIndices clusterListing clusterCount '()))
|#
;Step 7 calculation ends here. Step 7 runs slow on the larger inputs. Comment out the lines from the beginning of step 7 calculation till here to terminate within 2 seconds when testing the larger files. Beginning of step7 calculations is marked with a comment.
(define (getNoisePoints densityList index l)
  (define len(length densityList))
  (if (equal? 0 len)
      l
      (if (equal? (car densityList) 0) (cons index (getNoisePoints (cdr densityList) (+ index 1) l))(getNoisePoints (cdr densityList) (+ index 1) l))))
(define step8 (getNoisePoints step5 1 '()))

(define (getBorderPoints coreList noiseList everyPoint l)
  (define len(length everyPoint))
  (if (equal? 0 len)
      l
      (if (and(not (isPresent (car everyPoint) coreList)) (not (isPresent (car everyPoint) noiseList))) (cons (car everyPoint) (getBorderPoints coreList noiseList (cdr everyPoint) l))(getBorderPoints coreList noiseList (cdr everyPoint) l)))) 

(define step9 (getBorderPoints step6 step8 (build-list numPoints (lambda(x) (+ x 1))) '()))