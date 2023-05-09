//
//  SyncBucketSort.swift
//  BucketSort
//
//  Created by Oleksii on 09.05.2023.
//

import Foundation

extension Array<Int> {
    
    private var itemsInBucket: Int { 20 }
    
    func bucketSort() -> [Element] {
        
        guard count > itemsInBucket else { return self.insertionSort() }
        
        let bucketsAmount = count / itemsInBucket

        let minVal = self.min()!
        let maxVal = self.max()!
        let bucketStep = (maxVal - minVal).double / (bucketsAmount).double

        var buckets = (0..<bucketsAmount).map({ _ in [Int]() })
        
        for item in self {
            
            if item == maxVal {
                
                buckets[bucketsAmount - 1].append(item)
                continue
            }
            
            let index = ((item + minVal).double / bucketStep).int
            buckets[index].append(item)
        }
                
        return buckets.map({ $0.insertionSort() }).flatMap({ $0 })
    }
}
