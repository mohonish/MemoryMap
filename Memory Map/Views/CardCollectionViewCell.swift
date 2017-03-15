//
//  CardCollectionViewCell.swift
//  Memory Map
//
//  Created by Mohonish Chakraborty on 13/03/17.
//  Copyright © 2017 mohonish. All rights reserved.
//

import UIKit
import Kingfisher

class CardCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cardImageView: UIImageView!
    
    var card: Card?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //Set data for card.
    func setupCard(_ card: Card) {
        self.card = card
        if card.isRevealed {
            if let url = URL(string: card.imagePath) {
                self.cardImageView.kf.setImage(with: url, placeholder: Image(named: "defaultCard"), completionHandler: { (_, _, _, _) in
                    NotificationCenter.default.post(Notification(name: NSNotification.Name(rawValue: "DidFinishImageDownload")))
                })
            }
        } else {
            self.cardImageView.image = Image(named: "defaultCard")
        }
    }

}
