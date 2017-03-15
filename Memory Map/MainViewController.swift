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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MainViewController.didTapBegin))
        self.introductionView.addGestureRecognizer(tapGesture)
    }
    
    func didTapBegin() {
        self.introductionView.isHidden = true
        self.viewModel.startGame()
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
        //TODO: implement.
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
            })
            break
            
        case .end:
            break
            
        }
    }
    
}
