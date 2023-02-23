//
//  CalculatorResultTableViewCell.swift
//  LoaTool
//
//  Created by 정희수 on 2023/02/17.
//

import UIKit

class CalculatorResultTableViewCell: UITableViewCell {

    @IBOutlet var qualityView: CircleProgressView!
    @IBOutlet var partsLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var statsLabel: UILabel!
    @IBOutlet var engravingLabel: UILabel!
    @IBOutlet var goldLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
