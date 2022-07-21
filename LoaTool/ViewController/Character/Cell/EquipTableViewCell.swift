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
    @IBOutlet weak var tripodLabel: UILabel!
    
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
                  let name = data[safe: i]?.name,
                  let grade = data[safe: i]?.grade,
                  let quality = data[safe: i]?.quality else { return }
            
            let components = name.components(separatedBy: " ")
            let prefix = (components[safe: 1] ?? "").replacingOccurrences(of: "의", with: "")
            
            let title = prefix.containOfSet()
            ? (components[safe: 0] ?? "") + " " + (components[safe: 1] ?? "").replacingOccurrences(of: "의", with: "")
            : (components[safe: 0] ?? "") + " " + (components[safe: 1] ?? "") + " " + (components[safe: 2] ?? "").replacingOccurrences(of: "의", with: "")
            
            progressView.value = quality >= 0 ? Double(quality) / 100 : nil
            label.text = title
            label.textColor = grade.getColor()
            
            
        }
    }
    
    fileprivate func setupDetailView(_ data: Equip) {
        qualityView.value = data.quality >= 0 ? Double(data.quality) / 100 : nil
        
        switch Int(data.position) {
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
            break
        }
        
        nameLabel.text = data.name
        nameLabel.textColor = data.grade.getColor()
        
        defaultLabel.text = data.defaultOption
        additionalLabel.text = data.additionalOption

        
        let tripod = data.tripod ?? ""
        var attributedString = NSMutableAttributedString(string: tripod)

        let parts = tripod.split(separator: "]")
        let values = parts.compactMap { (part: Substring) -> String? in
            let parts = part.split(separator: "L", omittingEmptySubsequences: false)
            guard parts.count == 2 else {
                return nil
            }
            return String(parts[0])
        }
        
        values.forEach({
            attributedString = attributedString.addAttribute(of: $0, key: .foregroundColor, value: UIColor.systemPurple)
        })

        tripodLabel.attributedText = attributedString
    }
}
