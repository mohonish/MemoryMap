//
//  MainViewModel.swift
//  Memory Map
//
//  Created by Mohonish Chakraborty on 13/03/17.
//  Copyright © 2017 mohonish. All rights reserved.
//

import Foundation

public protocol MainViewModelProtocol: class {
    func toggleLoadingView(show: Bool)
}

public enum GameState {
    case start, loading, review, recollect, end
}

public class MainViewModel {
    
    var state: GameState
    
    weak var delegate: MainViewModelProtocol?
    
    public init() {
        self.state = .start
    }
    
    public func startGame() {
        self.state = .loading
        self.delegate?.toggleLoadingView(show: true)
        self.fetchImages()
    }
    
}

extension MainViewModel {
    
    fileprivate func fetchImages() {
        APIController.fetchImages(success: { (response) in
            print(response)
        }, failure: { (error) in
            //TODO: handle error.
        })
    }
    
}
