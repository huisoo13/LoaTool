//
//  OptionTableViewCell.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/08/03.
//

import UIKit

class OptionTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var switchButton: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        switchButton.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(_ title: String, description: String, isOn: Bool, switchButton isHidden : Bool) {
        titleLabel.text = title
        descriptionLabel.text = description
        switchButton.isOn = isOn
        switchButton.isHidden = isHidden
    }
}
