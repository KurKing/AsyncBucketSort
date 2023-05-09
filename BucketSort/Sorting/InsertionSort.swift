//
//  InsertionSort.swift
//  BucketSort
//
//  Created by Oleksii on 09.05.2023.
//

import Foundation

extension Array where Element: AdditiveArithmetic & Comparable {
    
    func insertionSort() -> [Element] {
        
        if count < 2 { return self }
        
        var array = self
        
        for i in 1..<array.count {
            
            let current = array[i]
            var j = i - 1
            
            while j >= 0 && array[j] > current {
                
                array[j+1] = array[j]
                j -= 1
            }
            
            array[j+1] = current
        }
        
        return array
    }
}
