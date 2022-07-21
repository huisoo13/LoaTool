//
//  BlockTableViewCell.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/06/28.
//

import UIKit

class BlockTableViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    var data: Block? {
        didSet {
            guard let data = data else {
                return
            }

            nameLabel.text = data.name
            dateLabel.text = DateManager.shared.convertDateFormat(data.date, originFormat: "yyyy-MM-dd HH:mm:ss", newFormat: "yyyy. MM. dd a hh:mm")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
