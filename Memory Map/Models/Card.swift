//
//  Card.swift
//  Memory Map
//
//  Created by Mohonish Chakraborty on 13/03/17.
//  Copyright © 2017 mohonish. All rights reserved.
//

import UIKit

public struct Card {
    
    let id: Int! //Used to uniquely identify card.
    let imagePath: String! //Path to image received from api.
    
    private(set) var isRevealed = true //Whether image is currently shown to user or hidden.
    
    public init(id: Int, path: String) {
        self.id = id
        self.imagePath = path
    }
    
    public mutating func setRevealed(_ revealed: Bool = true) {
        self.isRevealed = revealed
    }
    
}
