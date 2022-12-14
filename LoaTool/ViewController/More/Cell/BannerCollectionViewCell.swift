//
//  BannerCollectionViewCell.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/04/08.
//

import UIKit
import Kingfisher

class BannerCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var data: AD? {
        didSet {
            guard let data = data else {
                return
            }

            imageView.kf.setImage(with: URL(string: data.imageURL),
                                            options: [
                                                .scaleFactor(UIScreen.main.scale),
                                                .transition(.fade(1))
                                            ])
            companyLabel.text = "스마일게이트 - 희망스튜디오"
            label.text = data.title
            label.adjustsFontSizeToFitWidth = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 6

        self.layer.cornerRadius = 6
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowRadius = 0
        
//        imageView.layer.cornerRadius = 6
    }
}
