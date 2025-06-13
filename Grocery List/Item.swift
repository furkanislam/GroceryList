//
//  Item.swift
//  Grocery List
//
//  Created by Furkan İSLAM on 11.06.2025.
//

import Foundation
import SwiftData

@Model
class Item {
    var title: String
    var isCompletion: Bool
    
    init(title: String, isCompletion: Bool) {
        self.title = title
        self.isCompletion = isCompletion
    }
}
