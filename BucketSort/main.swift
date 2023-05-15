//
//  main.swift
//  BucketSort
//
//  Created by Oleksii on 09.05.2023.
//

import Foundation

// Before 2800 async array
// On 2800 async array becomes quicker than sync in 1.1 times
// On 10000 in 1.9 times
// On 100000 in 2.4 times
// On 1000000 in 2.65 times

let amount = 10000000
let arrayToSort = (0..<amount).compactMap({ (0...$0).randomElement() }).shuffled()
let semaphore = DispatchSemaphore(value: 0)

var sorted: [Int]!
var syncDateDiff = 0.0

DispatchQueue.global().async {
    
    let syncDate = Date().timeIntervalSince1970
    sorted = arrayToSort.bucketSort()
    syncDateDiff = Date().timeIntervalSince1970 - syncDate
    
    print("Sync time: \(syncDateDiff.string)")
    let isCorrectDate = Date().timeIntervalSince1970
    let correctArray = arrayToSort.sorted()
    print("Is correct: \(sorted == correctArray)\n")

    print("System time: \((Date().timeIntervalSince1970 - isCorrectDate).string)\n")
    
    semaphore.signal()
}

semaphore.wait()

let asyncDate = Date().timeIntervalSince1970
arrayToSort.bucketSort(completion: { result in

    let asyncDateDiff = Date().timeIntervalSince1970 - asyncDate

    print("Async time: \(asyncDateDiff.string)")
    print("Is correct: \(sorted == result)")

    if asyncDateDiff < syncDateDiff {

        print("\nAsync quicker in \((syncDateDiff / asyncDateDiff).string) times\n")
    }

    semaphore.signal()
})

semaphore.wait()
