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
    
    @IBOutlet weak var cardCollectionView: UICollectionView!
    
    // MARK: - Class Members
    
    fileprivate var viewModel = MainViewModel()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel.delegate = self
        
        self.cardCollectionView.dataSource = self
        
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
        return cell
    }
    
}

extension MainViewController: MainViewModelProtocol {
    
    func toggleLoadingView(show: Bool) {
        show ? showLoadingView() : hideLoadingView()
    }
    
}
