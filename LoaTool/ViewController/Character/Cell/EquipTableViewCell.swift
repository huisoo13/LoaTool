//
//  EquipTableViewCell.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/03/29.
//

import UIKit

class EquipTableViewCell: UITableViewCell {

    @IBOutlet weak var summaryView: UIView!
    @IBOutlet var itemViews: [UIView]!
    
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var qualityView: CircleProgressView!
    @IBOutlet weak var partLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var defaultLabel: UILabel!
    @IBOutlet weak var additionalLabel: UILabel!
    @IBOutlet weak var elixirLabel: UILabel!
    
    var selectedPosition: Int = -1
    var data: [Equip]? {
        didSet {
            guard let data = data else {
                detailView.isHidden = true
                summaryView.isHidden = true
                
                return
            }
            
            summaryView.isHidden = 0...5 ~= selectedPosition
            detailView.isHidden = !summaryView.isHidden

            if !summaryView.isHidden {
                setupSummaryView(data)
            } else {
                if data[safe: selectedPosition] == nil { return }
                setupDetailView(data[selectedPosition])
            }
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
    
    fileprivate func setupSummaryView(_ data: [Equip]) {

        itemViews.enumerated().forEach { i, itemView in
            guard let progressView = itemView.subviews.first as? CircleProgressView,
                  let label = itemView.subviews.last as? UILabel,
                  let name = data[safe: i]?.title,
                  let category = data[safe: i]?.category,
                  let grade = data[safe: i]?.grade,
                  let quality = data[safe: i]?.quality else { return }
            
            let filter = name.components(separatedBy: " ").filter { string in
                return !category.contains(string)
            }.joined(separator: " ")
            
            let components = filter.components(separatedBy: " ")
            let index = components.firstIndex(of: (components.filter({ $0.contains("의") }).last ?? "")) ?? 0
            
            let title = components.enumerated().map { i, string in
                return i <= index + 1 ? string : ""
            }.joined(separator: " ")
            
            progressView.value = quality >= 0 ? Double(quality) / 100 : nil
            label.text = title
            label.textColor = grade.getColor()
        }
    }
    
    fileprivate func setupDetailView(_ data: Equip) {
        qualityView.value = data.quality >= 0 ? Double(data.quality) / 100 : nil
        
        switch Int(data.category) {
        case 0:
            partLabel.text = "무기"
        case 1:
            partLabel.text = "머리"
        case 2:
            partLabel.text = "상의"
        case 3:
            partLabel.text = "하의"
        case 4:
            partLabel.text = "장갑"
        case 5:
            partLabel.text = "어깨장식"
        default:
            partLabel.text = data.category
        }
        
        nameLabel.text = data.title
        nameLabel.textColor = data.grade.getColor()
        
        defaultLabel.text = data.basicEffect
        additionalLabel.text = data.additionalEffect

        // 엘릭서
        let elixir = data.engravingEffect == "" ? "없음" : data.engravingEffect ?? ""

        var attributedString = NSMutableAttributedString(string: elixir)

        let parts = elixir.split(separator: "[")
        let values = parts.compactMap { (part: Substring) -> String? in
            let parts = part.split(separator: "]", omittingEmptySubsequences: false)
            guard parts.count == 2 else {
                return nil
            }
            return String(parts[0])
        }
        
        values.forEach({
            attributedString = attributedString.addAttribute(of: $0, key: .foregroundColor, value: UIColor.systemYellow)
        })

        elixirLabel.attributedText = attributedString
    }
}
