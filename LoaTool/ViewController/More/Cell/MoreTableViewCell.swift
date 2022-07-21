//
//  MoreTableViewCell.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/04/08.
//

import UIKit

class MoreTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var subIconimageView: UIImageView!
    @IBOutlet weak var arrowImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(title: String, image: UIImage, subTitle: String?, subTitleColor: UIColor? = nil, subImage: UIImage?, showChevron: Bool) {
        label.text = title
        iconImageView.image = image
        
        subLabel.text = subTitle
        subLabel.isHidden = subTitle == nil
        subLabel.textColor = subTitleColor ?? .placeholderText
        
        subIconimageView.image = subImage
        subIconimageView.isHidden = subImage == nil

        arrowImageView.isHidden = !showChevron
    }
}
