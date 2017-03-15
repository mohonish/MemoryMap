//
//  Card.swift
//  Memory Map
//
//  Created by Mohonish Chakraborty on 13/03/17.
//  Copyright © 2017 mohonish. All rights reserved.
//

import UIKit

public struct Card {
    
    let id: Int!
    let imagePath: String!
    
    private(set) var isRevealed = true
    
    public init(id: Int, path: String) {
        self.id = id
        self.imagePath = path
    }
    
    public mutating func setRevealed(_ revealed: Bool = true) {
        self.isRevealed = revealed
    }
    
}
