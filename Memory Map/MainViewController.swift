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
    
    @IBOutlet weak var baseDashboard: UIView!
    
    // MARK: - Class Members
    
    fileprivate var viewModel = MainViewModel()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
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

}
