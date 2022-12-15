//
//  AccessoryTableViewCell.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/03/29.
//

import UIKit

class AccessoryTableViewCell: UITableViewCell {

    @IBOutlet weak var summaryView: UIView!
    @IBOutlet var itemViews: [UIView]!
    
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var qualityView: CircleProgressView!
    @IBOutlet weak var partLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var defaultLabel: UILabel!
    @IBOutlet weak var additionalLabel: UILabel!
    @IBOutlet weak var engraveTitleLabel: UILabel!
    @IBOutlet weak var engraveLabel: UILabel!
    
    var selectedPosition: Int = -1
    var data: Character? {
        didSet {
            guard let engrave = data?.engrave?.equips,
                  let data: [Equip] = data?.equip.map({ $0 }) else {
                detailView.isHidden = true
                summaryView.isHidden = true
                
                return
            }
            
            summaryView.isHidden = selectedPosition > 5
            detailView.isHidden = !summaryView.isHidden

            if !summaryView.isHidden {
                setupSummaryView(data, engrave: engrave)
            } else {
                selectedPosition = selectedPosition == 26 ? 12 : selectedPosition
                
                guard let data = data[safe: selectedPosition] else { return }
                setupDetailView(data)
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
    
    
    fileprivate func setupSummaryView(_ data: [Equip], engrave: String) {
        itemViews.enumerated().forEach { i, itemView in            
            guard let progressView = itemView.subviews.first as? CircleProgressView,
                  let label = itemView.subviews.last as? UILabel else { return }
            
            data.forEach { item in
                if Int(item.category) == itemView.tag {
                    let name = item.name
                    let quality = item.quality
                    let grade = item.grade
                    
                    let components = name.components(separatedBy: " ")
                    let prefix = components.first ?? ""
                    
                    let title = prefix.contains("의")
                    ? (components[safe: 0] ?? "") + " " + (components[safe: 1] ?? "")
                    : name.components(separatedBy: "의").first ?? ""
                    
                    progressView.value = quality >= 0 ? Double(quality) / 100 : nil
                    
                    label.text = title
                    label.textColor = grade.getColor()

                    if itemView.tag == 11 { // 어빌리티 스톤
                        let stone = (item.engravingEffect ?? "")
                            .replacingOccurrences(of: "[", with: "")
                            .replacingOccurrences(of: "] 활성도", with: "")
                                                
                        var attributedString = NSMutableAttributedString(string: stone)

                        stone.components(separatedBy: "\n").forEach { engrave in
                            attributedString = attributedString.addAttribute(of: engrave, key: .foregroundColor, value: engrave.contains("감소") ? UIColor.systemRed : UIColor.custom.textBlue)
                        }
                        
                        label.attributedText = attributedString
                    }
                }
            }
            
            if 11...26 ~= itemView.tag { progressView.setProgress("-") }
            if itemView.tag == 27 { // 착용 각인
                progressView.setProgress("+")
                label.text = engrave
                label.textColor = .custom.textBlue
            }
        }
    }
    
    fileprivate func setupDetailView(_ data: Equip) {
        qualityView.value = data.quality >= 0 ? Double(data.quality) / 100 : nil
        if data.quality < 0 { qualityView.setProgress("-") }
        
        switch Int(data.category) {
        case 6:
            partLabel.text = "목걸이"
        case 7, 8:
            partLabel.text = "귀걸이"
        case 9, 10:
            partLabel.text = "반지"
        case 11:
            partLabel.text = "어빌리티 스톤"
        case 26:
            partLabel.text = "팔찌"
        default:
            partLabel.text = data.category
        }
        
        nameLabel.text = data.name
        nameLabel.textColor = data.grade.getColor()
        
        defaultLabel.text = (data.basicEffect ?? "").trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\n ", with: "\n")
        additionalLabel.text = data.additionalEffect
        additionalLabel.superview?.isHidden = data.additionalEffect == nil

        let engrave = data.engravingEffect ?? ""
        var attributedString = NSMutableAttributedString(string: engrave)

        let parts = engrave.split(separator: "[")
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
        
        let penalty = String.engrave(true)
        
        penalty.forEach {
            attributedString = attributedString.addAttribute(of: $0, key: .foregroundColor, value: UIColor.systemRed)
        }

        engraveLabel.attributedText = attributedString
        engraveTitleLabel.isHidden = engrave == ""
    }
}
