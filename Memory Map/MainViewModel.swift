//
//  MainViewModel.swift
//  Memory Map
//
//  Created by Mohonish Chakraborty on 13/03/17.
//  Copyright © 2017 mohonish. All rights reserved.
//

import Foundation

public enum GameState {
    case start, review, recollect, end
}

public class MainViewModel {
    
    var state: GameState
    
    public init() {
        self.state = .start
    }
    
}
