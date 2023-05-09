//
//  Utils.swift
//  BucketSort
//
//  Created by Oleksii on 09.05.2023.
//

import Foundation

extension Int {
    
    var double: Double { Double(self) }
}

extension Double {
    
    var int: Int { Int(self) }
    
    var string: String { String(format: "%.5f", self) }
}
