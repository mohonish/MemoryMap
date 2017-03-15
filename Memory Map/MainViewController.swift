//
//  MainViewController.swift
//  Memory Map
//
//  Created by Mohonish Chakraborty on 13/03/17.
//  Copyright © 2017 mohonish. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var introductionView: UIView!
    
    @IBOutlet weak var loadingView: UIView!
    
    @IBOutlet weak var scoreView: UIView!
    
    @IBOutlet weak var scoreTimeLabel: UILabel!
    
    @IBOutlet weak var scoreAccuracyLabel: UILabel!
    
    @IBOutlet weak var baseDashboard: UIView!
    
    @IBOutlet weak var currentCardImageView: UIImageView!
    
    @IBOutlet weak var actionLabel: UILabel!
    
    @IBOutlet weak var cardCollectionView: UICollectionView!
    
    // MARK: - Class Members
    
    fileprivate var viewModel = MainViewModel()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel.delegate = self
        
        self.cardCollectionView.dataSource = self
        self.cardCollectionView.delegate = self
        
        setupUI()
        setupGestures()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI Setup
    
    func setupUI() {
        setupBaseDashboard()
        setupCardCollectionView()
    }

    func setupBaseDashboard() {
        baseDashboard.layer.shadowColor = UIColor.black.cgColor
        baseDashboard.layer.shadowOpacity = 0.2
        baseDashboard.layer.shadowRadius = 4.0
    }
    
    func setupCardCollectionView() {
        self.cardCollectionView.register(UINib(nibName: "CardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CardCollectionViewCell")
    }
    
    // MARK: - Gestures/Actions Setup
    
    func setupGestures() {
        let beginTapGesture = UITapGestureRecognizer(target: self, action: #selector(MainViewController.didTapBegin))
        self.introductionView.addGestureRecognizer(beginTapGesture)
        let restartTapGesture = UITapGestureRecognizer(target: self, action: #selector(MainViewController.didTapRestart))
        self.scoreView.addGestureRecognizer(restartTapGesture)
    }
    
    func didTapBegin() {
        self.introductionView.isHidden = true
        self.viewModel.startGame()
    }
    
    func didTapRestart() {
        self.viewModel = MainViewModel()
        self.viewModel.delegate = self
        self.reloadGameState()
    }
    
    // MARK: - Loading View
    
    func showLoadingView() {
        DispatchQueue.main.async(execute: { [weak self] in
            self?.loadingView.isHidden = false
        })
    }
    
    func hideLoadingView() {
        DispatchQueue.main.async(execute: { [weak self] in
            self?.loadingView.isHidden = true
        })
    }
    
    // MARK: - Score View
    
    func showScores() {
        self.scoreTimeLabel.text = "Elapsed Time: " + String(self.viewModel.getElapsedTimeInSeconds()) + "s"
        self.scoreAccuracyLabel.text = "Guess Accuracy: " + String(self.viewModel.getGuessAccuracy()) + "%"
        self.scoreView.isHidden = false
    }

}

extension MainViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.cardCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCollectionViewCell", for: indexPath) as! CardCollectionViewCell
        if self.viewModel.cards.count > 0 {
            if let thisCard = self.viewModel.cards[indexPath.item] {
                cell.setupCard(thisCard)
            }
        }
        return cell
    }
    
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let selectedCard = self.viewModel.cards[indexPath.item] else {
            return
        }
        
        if selectedCard.isRevealed != true,
            selectedCard.id == self.viewModel.currentCard?.id {
            self.viewModel.cards[indexPath.item]?.setRevealed(true)
            self.viewModel.correctGuess()
        } else {
            self.viewModel.incorrectGuess()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width / 3) - 10
        let height = (collectionView.bounds.height / 3) - 10
        return CGSize(width: width, height: height)
    }
    
}

extension MainViewController: MainViewModelProtocol {
    
    func reloadGameState() {
        switch self.viewModel.state {
            
        case .start:
            DispatchQueue.main.async(execute: { [weak self] in
                self?.scoreView.isHidden = true
                self?.introductionView.isHidden = false
                self?.currentCardImageView.image = UIImage(named: "defaultCard")
            })
            break
            
        case .loading:
            showLoadingView()
            DispatchQueue.main.async(execute: { [weak self] in
                self?.cardCollectionView.reloadData()
            })
            break
            
        case .review:
            if !self.loadingView.isHidden {
                hideLoadingView()
            }
            actionLabel.text = "Time Remaining: " + String(self.viewModel.reviewTime) + "s"
            break
            
        case .recollect:
            DispatchQueue.main.async(execute: { [weak self] in
                self?.actionLabel.text = "Guess the image position"
                self?.cardCollectionView.reloadData()
                if let currentCard = self?.viewModel.currentCard {
                    if let cardImageURL = URL(string: currentCard.imagePath) {
                        self?.currentCardImageView.kf.setImage(with: cardImageURL)
                    }
                }
            })
            break
            
        case .end:
            DispatchQueue.main.async(execute: { [weak self] in
                self?.cardCollectionView.reloadData()
                self?.showScores()
            })
            break
            
        }
    }
    
}
