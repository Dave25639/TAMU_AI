(define (domain hanoi) ;clear
  (:requirements :strips)
  (:predicates
    (onTopOfPeg ?disk ?peg)
    (onDisk ?disk1 ?disk2)
    (smaller ?disk1 ?disk2)
    (isDisk ?disk)
    (isPeg ?peg)
    (isPegFree ?peg)
    (isBottom ?disk ?peg)
    (arc ?peg1 ?peg2)
  )
  
  (:action moveFromDiskOnDisk ;c
    :parameters (?disk_top ?disk_under ?new_disk_under ?source_peg ?destination_peg) ;c
    :precondition (and
        (arc ?source_peg ?destination_peg)
    
        (isDisk ?disk_top) ;c
        (isDisk ?disk_under) ;c
        (isDisk ?new_disk_under) ;c
        
        (isPeg ?source_peg) ;c
        (isPeg ?destination_peg) ;c
        
        (onDisk ?disk_top ?disk_under) ;c
        (onTopOfPeg ?disk_top ?source_peg) ;c
        (onTopOfPeg ?new_disk_under ?destination_peg) ;c
    
        (smaller ?disk_top ?new_disk_under) ;c
    )
    :effect (and
        (not (onDisk ?disk_top ?disk_under)) ;c
        (not (onTopOfPeg ?new_disk_under ?destination_peg)) ;c
        (not (onTopOfPeg ?disk_top ?source_peg)) ;c
        
        (onTopOfPeg ?disk_under ?source_peg) ;c
        (onTopOfPeg ?disk_top ?destination_peg) ;c
        (onDisk ?disk_top ?new_disk_under) ;c
    )
  )
  
  (:action moveFromDiskOnEmptyTower ;c
    :parameters (?disk_top ?disk_under ?source_peg ?destination_peg)
    :precondition (and
        (arc ?source_peg ?destination_peg)
    
        (isDisk ?disk_top) ;c
        (isDisk ?disk_under) ;c
        
        (isPeg ?source_peg) ;c
        (isPeg ?destination_peg) ;c
        
        (isPegFree ?destination_peg) ;c

        (onDisk ?disk_top ?disk_under) ;c
        (onTopOfPeg ?disk_top ?source_peg) ;c
    )
    :effect (and
        (not (isPegFree ?destination_peg)) ;c
        (not (onDisk ?disk_top ?disk_under)) ;c
        (not (onTopOfPeg ?disk_top ?source_peg)) ;c
        
        (onTopOfPeg ?disk_under ?source_peg) ;c
        (isBottom ?disk_top ?destination_peg) ;c
        (onTopOfPeg ?disk_top ?destination_peg) ;c
    )
  )
  
  (:action moveFromEmptyTowerToDisk ;c
    :parameters (?disk_top ?new_disk_under ?source_peg ?destination_peg)
    :precondition (and
        (arc ?source_peg ?destination_peg)

        (isDisk ?disk_top) ;c
        (isDisk ?new_disk_under) ;c
        
        (isPeg ?source_peg) ;c
        (isPeg ?destination_peg) ;c
        
        (onTopOfPeg ?disk_top ?source_peg) ;c
        (onTopOfPeg ?new_disk_under ?destination_peg) ;c
        
        (isBottom ?disk_top ?source_peg) ;c
        
        (smaller ?disk_top ?new_disk_under) ;c
    )
    :effect (and
        (not (isBottom ?disk_top ?source_peg)) ;c
        (not (onTopOfPeg ?disk_top ?source_peg)) ;c
        (not (onTopOfPeg ?new_disk_under ?destination_peg)) ;c
        
        (onTopOfPeg ?disk_top ?destination_peg) ;c
        (isPegFree ?source_peg) ;c
        (onDisk ?disk_top ?new_disk_under) ;c
    )
  )
  
  (:action moveFromEmptyTowerOnEmptyTower ;c
    :parameters (?disk_top ?source_peg ?destination_peg)
    :precondition (and
        (arc ?source_peg ?destination_peg)

        (isDisk ?disk_top) ;c
        
        (isPeg ?source_peg) ;c
        (isPeg ?destination_peg) ;c
        
        (isPegFree ?destination_peg) ;c
        
        (onTopOfPeg ?disk_top ?source_peg) ;c
        (isBottom ?disk_top ?source_peg) ;c
    )
    :effect (and
        (not (isPegFree ?destination_peg)) ;c
        (not (isBottom ?disk_top ?source_peg)) ;c
        (not (onTopOfPeg ?disk_top ?source_peg)) ;c
        
        (isPegFree ?source_peg) ;c
        (isBottom ?disk_top ?destination_peg) ;c
        (onTopOfPeg ?disk_top ?destination_peg) ;c
    )
  )
)