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
    var cards = Dictionary<Int, Card>() // [Card]()
    var currentCard: Card?
    var reviewTimer: Timer?
    
    public var reviewTime = 5
    public let cardCount = 9
    public var loadedImages = 0
    public var revealCount = 0
    private var guessCount = 0
    
    var recollectStartTime = Date()
    var recollectEndTime = Date()
    
    weak var delegate: MainViewModelProtocol?
    
    public init() {
        self.state = .start
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewModel.didFinishImageDownload), name: NSNotification.Name(rawValue: "DidFinishImageDownload"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        reviewTimer?.invalidate()
    }
    
    public func startGame() {
        self.state = .loading
        self.delegate?.reloadGameState()
        self.fetchImages()
    }
    
    public func correctGuess() {
        self.guessCount += 1
        self.nextRecollectTurn()
    }
    
    public func incorrectGuess() {
        self.guessCount += 1
    }
    
    //Return elapsed time in seconds (0 <= Int value)
    public func getElapsedTimeInSeconds() -> Int {
        return Int(recollectEndTime.timeIntervalSince(recollectStartTime))
    }
    
    //Return guess accuracy in percentage (0 <= Int value <= 100)
    public func getGuessAccuracy() -> Int {
        let accuracy = (Float(cardCount) / Float(guessCount)) * 100
        return Int(ceilf(accuracy))
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
        self.cards = Dictionary<Int, Card>()
        
        for item in items {
            if let media = item["media"] as? Dictionary<String, Any> {
                if let imageURL = media["m"] as? String {
                    let thisCard = Card(id: imageID, path: imageURL)
                    self.cards[imageID] = thisCard
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
            NotificationCenter.default.removeObserver(self)
            self.state = .review
            self.delegate?.reloadGameState()
            self.startTimer()
        }
    }
    
    fileprivate func startTimer() {
        self.reviewTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (timer) in
            
            guard let this = self else {
                return
            }
            
            this.reviewTime -= 1
            if this.reviewTime <= 0 {
                timer.invalidate()
                this.hideAllImages()
                this.nextRecollectTurn()
                this.recollectStartTime = Date()
                this.state = .recollect
            }
            this.delegate?.reloadGameState()
            
        })
    }
    
    fileprivate func hideAllImages() {
        var hiddenCards = Dictionary<Int, Card>()
        for thisCard in self.cards {
            hiddenCards[thisCard.key] = thisCard.value
            hiddenCards[thisCard.key]?.setRevealed(false)
        }
        self.cards = hiddenCards
    }
    
    fileprivate func nextRecollectTurn() {
        if let nextCard = getNextCardForDiscovery() {
            self.currentCard = nextCard
            self.delegate?.reloadGameState()
        } else {
            self.recollectEndTime = Date()
            self.state = .end
            self.delegate?.reloadGameState()
        }
    }
    
    fileprivate func getNextCardForDiscovery() -> Card? {
        if revealCount < cardCount {
            let randomImageIndex = getRandomNonRevealedImageIndex()
            revealCount += 1
            return cards[randomImageIndex]
        }
        return nil
    }
    
    fileprivate func getRandomNonRevealedImageIndex() -> Int {
        var imageIndex = 0
        repeat {
            imageIndex = Int(arc4random_uniform(9))
        } while(cards[imageIndex]?.isRevealed == true)
        return imageIndex
    }
    
}
