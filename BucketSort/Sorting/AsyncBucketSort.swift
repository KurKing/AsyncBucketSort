//
//  AsyncBucketSort.swift
//  BucketSort
//
//  Created by Oleksii on 09.05.2023.
//

import Foundation

extension Array<Int> {
    
    private var itemsInBucket: Int { 20 }
    private var maxAmountOfDispatchItems: Int { 128 }
    
    func bucketSort(completion: (([Int]) -> Void)?) {
        
        guard count > itemsInBucket else {
            
            completion?(self.insertionSort())
            return
        }
        
        getMinAndMax() { minVal, maxVal in
            
            guard let minVal = minVal, let maxVal = maxVal else {
                
                completion?([])
                return
            }
            
            fillBuckets(maxValue: maxVal, minValue: minVal) { buckets in
                
                sortBuckets(buckets: buckets, with: { buckets in
                    
                    completion?(buckets.flatMap({ $0 }))
                })
            }
        }
    }
    
    // MARK: - Min and Max
    private func getMinAndMax(completion: ((Int?, Int?) -> Void)?) {
        
        let dispatchGroup = DispatchGroup()
        
        var min: Int?
        var max: Int?
        
        dispatchGroup.enter()
        DispatchQueue.global().async {
            
            min = self.min()
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        DispatchQueue.global().async {
            
            max = self.max()
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .global()) {
            
            completion?(min, max)
        }
    }
    
    // MARK: - Fill buckets
    private func fillBuckets(maxValue: Int,
                             minValue: Int,
                             with completion: (([ThreadSafeArray<Int>]) -> Void)? = nil) {
        
        let bucketsAmount = count / itemsInBucket
        let step = (maxValue - minValue).double / bucketsAmount.double
        let buckets = (0..<bucketsAmount).map({ _ in ThreadSafeArray<Int>() })
        
        let dispatchGroup = DispatchGroup()
        let chunkSize = countChunks(for: count)
        
        for chunk in stride(from: 0, to: count, by: chunkSize) {
            
            dispatchGroup.enter()
            DispatchQueue(label: "fill.buckets.\(chunk)",
                          qos: .userInitiated,
                          attributes: .concurrent).async {
                
                for i in chunk..<Swift.min(chunk + chunkSize, count) {
                    
                    let item = self[i]
                    
                    if item == maxValue {
                        
                        buckets[bucketsAmount - 1].append(item)
                        continue
                    }
                    
                    let index = ((item + minValue).double / step).int
                    buckets[index].append(item)
                }
                
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .global()) {
            
            completion?(buckets)
        }
    }
    
    // MARK: - Sort bucket
    private func sortBuckets(buckets: [ThreadSafeArray<Int>],
                             with completion: (([[Int]]) -> Void)? = nil) {
        
        let dispatchGroup = DispatchGroup()
        let chunkSize = countChunks(for: buckets.count)
        
        for chunk in stride(from: 0, to: buckets.count, by: chunkSize) {
            
            dispatchGroup.enter()
            DispatchQueue(label: "sort.buckets.\(chunk)",
                          qos: .userInitiated,
                          attributes: .concurrent).async {
                
                for i in chunk..<Swift.min(chunk + chunkSize, buckets.count) {
                    
                    let bucket = buckets[i]
                    bucket.data = bucket.data.insertionSort()
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .global()) {
            
            completion?(buckets.map({ $0.data }))
        }
    }
    
    // MARK: - Utils
    private func countChunks(for amount: Int) -> Int {
        
        if amount == 0 { return 1 }
        let chunks = amount / maxAmountOfDispatchItems
        
        return chunks > 0 ? chunks : 1
    }
}
