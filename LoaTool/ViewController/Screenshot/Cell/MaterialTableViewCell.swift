//
//  MaterialTableViewCell.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/12/12.
//

import UIKit

class MaterialTableViewCell: UITableViewCell {

    @IBOutlet weak var materialImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var neededQuantityLabel: UILabel!
    @IBOutlet weak var unitPriceLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    var data: Material? {
        didSet {
            guard let data = data else { return }
            
            if let url = URL(string: data.url) {
                materialImageView.kf.setImage(with: url)
                materialImageView.backgroundColor = data.grade.getColor().darker(by: 50)
            }

            nameLabel.text = data.name
            neededQuantityLabel.text = String(data.neededQuantity)
            
            let unitPrice = Double(data.currentMinPrice) / Double(data.bundleCount)
            
            unitPriceLabel.text = String(format: "%.2f", unitPrice)
            totalPriceLabel.text = String(format: "%.2f", unitPrice * Double(data.neededQuantity))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
