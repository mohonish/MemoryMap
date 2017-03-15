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
    
    func setupCard(_ card: Card) {
        print("setupCard: \(card.id) revealed: \(card.isRevealed)")
        self.card = card
        if card.isRevealed {
            if let url = URL(string: card.imagePath) {
                print("setupCard Image: \(card.imagePath)")
                self.cardImageView.kf.setImage(with: url, placeholder: Image(named: "defaultCard"), completionHandler: { (_, _, _, _) in
                    print("downloadCompletionHandler")
                    NotificationCenter.default.post(Notification(name: NSNotification.Name(rawValue: "DidFinishImageDownload")))
                })
            }
        } else {
            self.cardImageView.image = Image(named: "defaultCard")
        }
    }

}
