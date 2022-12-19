//
//  EngravingCollectionViewCell.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/12/19.
//

import UIKit

class EngravingCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var circleView: TripleDivisionCircleView!
    @IBOutlet weak var label: UILabel!
    
    var data: String? {
        didSet {
            guard let data = data else { return }
            
            let title = data.components(separatedBy: "Lv. ").first ?? ""
            let value = Int(data.components(separatedBy: "Lv. ").last ?? "0") ?? 0
            
            label.text = title
            circleView.value = value
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
