//
//  ThreadSafeArray.swift
//  BucketSort
//
//  Created by Oleksii on 09.05.2023.
//

import Foundation

class ThreadSafeArray<T> {
    
    var data: [T]
    private let semaphore = DispatchSemaphore(value: 1)
    
    init(data: [T] = [T]()) {
        
        self.data = data
    }
    
    func append(_ item: T) {
        
        semaphore.wait()
        
        data.append(item)
        
        semaphore.signal()
    }
}
