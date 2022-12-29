//
//  ProfitAndLossTableViewCell.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/12/13.
//

import UIKit

class ProfitAndLossTableViewCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var useLabel: UILabel!
    @IBOutlet weak var sellLabel: UILabel!
    
    var reducedCrafingFeeAtPercent: Double = 0
    var data: Recipe? {
        didSet {
            guard let data = data else { return }
            
            if let url = URL(string: data.product.url) {
                itemImageView.kf.setImage(with: url)
                itemImageView.backgroundColor = data.product.grade.getColor().darker(by: 50)
            }
            
            nameLabel.text = data.name
            
            let cost = floor(Double(data.cost) * (1.0 - reducedCrafingFeeAtPercent))
            let material = calculator(onPriceAndFeeAt: data.material)
            
            let fee = Int(ceil(Double(data.product.currentMinPrice) * 0.05)) * data.bundleCount / data.product.bundleCount
            let price = data.product.currentMinPrice * data.bundleCount / data.product.bundleCount

            sellLabel.text = (material.price - material.fee) < Double(price - fee) - cost ? "이득" : "손해"
            useLabel.text = (material.price - material.fee) < Double(price) - cost ? "이득" : "손해"

            sellLabel.textColor = sellLabel.text == "이득" ? .custom.itemGrade2 : .custom.qualityRed
            useLabel.textColor = useLabel.text == "이득" ? .custom.itemGrade2 : .custom.qualityRed

        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func calculator(onPriceAndFeeAt materials: [Material?]?) -> (price: Double, fee: Double) {
        guard let materials = materials else { return (0, 0) }
        
        var price: Double = 0
        var fee: Double = 0
        
        materials.forEach { material in
            guard let material = material else { return }

            price += Double(material.currentMinPrice) * Double(material.neededQuantity) / Double(material.bundleCount)
            
            let bundleFee = material.currentMinPrice == 1 ? 0 : Double(material.currentMinPrice) * 0.05
            fee += ceil(bundleFee) * Double(material.neededQuantity) / Double(material.bundleCount)
        }

        return (price, fee)
    }
}
