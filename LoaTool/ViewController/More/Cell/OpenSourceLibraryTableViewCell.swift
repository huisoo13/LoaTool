//
//  OpenSourceLibraryTableViewCell.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/04/18.
//

import UIKit

class OpenSourceLibraryTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var licenseLabel: UILabel!
    @IBOutlet weak var permissionLabel: UILabel!
    @IBOutlet weak var limitationLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    
    var data: OpenSource? {
        didSet {
            guard let data = data else {
                return
            }

            
            label.text = data.title
            licenseLabel.text = data.license
            permissionLabel.text = data.permission
            limitationLabel.text = data.limitation
            conditionLabel.text = data.condition
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        separatorInset = .zero
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
