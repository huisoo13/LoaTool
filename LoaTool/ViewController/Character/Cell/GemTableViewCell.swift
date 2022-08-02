//
//  GemTableViewCell.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/03/29.
//

import UIKit
import Kingfisher

class GemTableViewCell: UITableViewCell {

    @IBOutlet weak var chartView: GemBarChartView!
    @IBOutlet weak var summaryView: UIView!
    @IBOutlet var itemViews: [UIView]!

    var isSelectedItem: Bool = false
    var data: Character? {
        didSet {
            guard let data = data else {
                return
            }

            let gem = Array(data.gem)
            chartView.values = gem
            itemViews.enumerated().forEach { i, view in
                view.isHidden = i >= gem.count || !isSelectedItem

                guard let imageView = view.subviews[safe: 0] as? UIImageView,
                      let titleLabel = view.subviews[safe: 1] as? UILabel,
                      let descriptionLabel = view.subviews[safe: 2] as? UILabel,
                      let gem = gem[safe: i] else { return }
                
                imageView.kf.setImage(with: URL(string: gem.iconPath))
                titleLabel.text = gem.title
                titleLabel.textColor = gem.grade.getColor()
                descriptionLabel.text = gem.tooltip
                descriptionLabel.textColor = gem.tooltip.contains(data.info?.job ?? "알수없음") ? .label : .systemRed
            }
            
            summaryView.isHidden = isSelectedItem
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
