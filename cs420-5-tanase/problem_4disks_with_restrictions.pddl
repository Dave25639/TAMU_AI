(define (problem hanoi-2)
  (:domain hanoi)
  (:objects
    disk1 disk2 disk3 disk4
    peg1 peg2 peg3
  )
  (:init
    (arc peg1 peg2)
    (arc peg2 peg1)
    (arc peg1 peg3)
    (arc peg3 peg1)
    (arc peg2 peg3)
    (arc peg3 peg2)
  
    (isDisk disk1)
    (isDisk disk2)
    (isDisk disk3)
    (isDisk disk4)
    
    (isPeg peg1)
    (isPeg peg2)
    (isPeg peg3)
    
    (smaller disk1 disk2)
    (smaller disk1 disk3)
    (smaller disk1 disk4)
    (smaller disk2 disk3)
    (smaller disk2 disk4)
    (smaller disk3 disk4)
    
    (onTopOfPeg disk1 peg1)
    (onDisk disk1 disk2)
    (onDisk disk2 disk3)
    (onDisk disk3 disk4)
    (isBottom disk4 peg1)
    
    (not (isPegFree peg1))
    (isPegFree peg2)
    (isPegFree peg3)
  )
    (:goal (and
        (isPegFree peg1)
        (isPegFree peg2)
        (onTopOfPeg disk1 peg3)
        (onDisk disk1 disk2)
        (onDisk disk2 disk3)
        (onDisk disk3 disk4)
        (isBottom disk4 peg3)
        )
    )
)