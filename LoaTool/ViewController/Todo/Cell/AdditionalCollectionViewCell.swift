//
//  AdditionalCollectionViewCell.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/04/11.
//

import UIKit

class AdditionalCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var jobView: UIView!
    @IBOutlet weak var jobImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var clearStamp: UIImageView!
    
    var data: Member? {
        didSet {
            guard let data = data else {
                return
            }

            jobImageView.image = data.job.getSymbol()
            nameLabel.text = data.name
        }
    }
    
    var completed: Bool? {
        didSet {
            guard let completed = completed else {
                return
            }

            self.alpha = completed ? 0.7 : 1
            clearStamp.isHidden = !completed
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        jobView.layer.cornerRadius = 6
        jobView.layer.borderWidth = 0.5
        jobView.layer.borderColor = UIColor.systemGray4.cgColor
    }
}
