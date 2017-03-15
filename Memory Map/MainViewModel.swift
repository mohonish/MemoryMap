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
    var cards = Dictionary<Int, Card>() //Dictionary of image cards.
    var currentCard: Card?
    var reviewTimer: Timer?
    
    public let cardCount = 9
    public fileprivate(set) var reviewTime = 15
    fileprivate var loadedImages = 0
    fileprivate var revealCount = 0
    fileprivate var guessCount = 0
    
    public fileprivate(set) var recollectStartTime = Date()
    public fileprivate(set) var recollectEndTime = Date()
    
    weak var delegate: MainViewModelProtocol?
    
    public init() {
        self.state = .start //Initial State.
        //Set observer for notification, triggered when an image finishes downloading.
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewModel.didFinishImageDownload), name: NSNotification.Name(rawValue: "DidFinishImageDownload"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        reviewTimer?.invalidate()
    }
    
    // MARK: - Public methods
    
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
            //TODO: handle parsing error
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
        self.loadedImages += 1
        if loadedImages >= cardCount { //All images loaded, move to review state.
            NotificationCenter.default.removeObserver(self)
            self.state = .review
            self.delegate?.reloadGameState()
            self.startTimer()
        }
    }
    
    //Start timer for review stage
    fileprivate func startTimer() {
        self.reviewTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (timer) in
            
            guard let this = self else {
                return
            }
            
            this.reviewTime -= 1
            if this.reviewTime <= 0 { //End of review time.
                timer.invalidate()
                this.hideAllImages()
                this.nextRecollectTurn()
                this.recollectStartTime = Date()
                this.state = .recollect
            }
            this.delegate?.reloadGameState()
            
        })
    }
    
    //Set all card images to not revealed.
    fileprivate func hideAllImages() {
        var hiddenCards = Dictionary<Int, Card>()
        for thisCard in self.cards {
            hiddenCards[thisCard.key] = thisCard.value
            hiddenCards[thisCard.key]?.setRevealed(false)
        }
        self.cards = hiddenCards
    }
    
    //Move to next turn/card for recollect stage.
    fileprivate func nextRecollectTurn() {
        if let nextCard = getNextCardForDiscovery() { //Get next card for recollect stage
            self.currentCard = nextCard //Set next card for recollect stage
            self.delegate?.reloadGameState() //Trigger reload
        } else { //If all cards finished for recollect stage
            self.recollectEndTime = Date() //Capture recollect end time.
            self.state = .end //Move to end stage.
            self.delegate?.reloadGameState() //Trigger reload.
        }
    }
    
    //Returns next random card for recollect stage.
    fileprivate func getNextCardForDiscovery() -> Card? {
        if revealCount < cardCount {
            let randomImageIndex = getRandomNonRevealedImageIndex() //Get random index of non revealed image.
            revealCount += 1
            return cards[randomImageIndex] //return card at index
        }
        return nil
    }
    
    //Return random index of non-revealed image card.
    //Note: should not be called after all cards are revealed, will inevitably lead to an infinite loop.
    //TODO: better implementation.
    fileprivate func getRandomNonRevealedImageIndex() -> Int {
        var imageIndex = 0
        repeat {
            imageIndex = Int(arc4random_uniform(9)) //Get random number between 0 - 9
        } while(cards[imageIndex]?.isRevealed == true)
        return imageIndex
    }
    
}
