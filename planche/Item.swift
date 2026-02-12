//
//  Item.swift
//  planche
//
//  Created by Đào Kiên Cường on 12/2/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
