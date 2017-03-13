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
    
    // MARK: - Class Members
    
    fileprivate var viewModel = MainViewModel()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    }

    func setupBaseDashboard() {
        baseDashboard.layer.shadowColor = UIColor.black.cgColor
        baseDashboard.layer.shadowOpacity = 0.2
        baseDashboard.layer.shadowRadius = 4.0
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
        self.loadingView.isHidden = false
    }
    
    func hideLoadingView() {
        self.loadingView.isHidden = true
    }

}

extension MainViewController: MainViewModelProtocol {
    
    func toggleLoadingView(show: Bool) {
        show ? showLoadingView() : hideLoadingView()
    }
    
}
