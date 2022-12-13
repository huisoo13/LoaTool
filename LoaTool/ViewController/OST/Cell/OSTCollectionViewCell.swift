//
//  OSTCollectionViewCell.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/11/08.
//

import UIKit
import Kingfisher

class OSTCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var data: OST? {
        didSet {
            guard let data = data,
                  let URL = URL(string: data.imageURL) else { return }
            
            imageView.kf.setImage(with: URL)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.layer.cornerRadius = 4
        
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 3, height: 3)
        layer.shadowRadius = 6
        layer.shadowOpacity = 0.5
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        guard let layoutAttributes = layoutAttributes as? CollectionViewLayoutAttributes else { return }
        layer.anchorPoint = layoutAttributes.anchorPoint
        center.x += (layoutAttributes.anchorPoint.x - 0.5) * bounds.width
    }

}
