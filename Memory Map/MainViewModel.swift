//
//  MainViewModel.swift
//  Memory Map
//
//  Created by Mohonish Chakraborty on 13/03/17.
//  Copyright © 2017 mohonish. All rights reserved.
//

import Foundation

public protocol MainViewModelProtocol: class {
    func reloadGameState()
}

public enum GameState {
    case start, loading, review, recollect, end
}

public class MainViewModel {
    
    var state: GameState
    var cards = [Card]()
    
    public let cardCount = 9
    public var loadedImages = 0
    
    weak var delegate: MainViewModelProtocol?
    
    public init() {
        self.state = .start
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewModel.didFinishImageDownload), name: NSNotification.Name(rawValue: "DidFinishImageDownload"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func startGame() {
        self.state = .loading
        self.delegate?.reloadGameState()
        self.fetchImages()
    }
    
}

extension MainViewModel {
    
    fileprivate func fetchImages() {
        APIController.fetchImages(success: { [weak self] (response) in
            self?.parseImageResponse(response)
        }, failure: { (error) in
            //TODO: handle error.
        })
    }
    
    fileprivate func parseImageResponse(_ response: [String: Any]) {
        guard let items = response["items"] as? [Dictionary<String, Any>] else {
            //TODO: handle error
            return
        }
        
        var imageID = 0
        self.cards = [Card]()
        
        for item in items {
            if let media = item["media"] as? Dictionary<String, Any> {
                if let imageURL = media["m"] as? String {
                    let thisCard = Card(id: imageID, path: imageURL)
                    self.cards.append(thisCard)
                    imageID += 1
                }
            }
            if imageID >= cardCount {
                break
            }
        }
        
        //Trigger reload to download and show images.
        self.delegate?.reloadGameState()
    }
    
    @objc fileprivate func didFinishImageDownload() {
        print("didFinishImageDownload: \(loadedImages)")
        self.loadedImages += 1
        if loadedImages >= cardCount {
            self.state = .review
            self.delegate?.reloadGameState()
        }
    }
    
}
