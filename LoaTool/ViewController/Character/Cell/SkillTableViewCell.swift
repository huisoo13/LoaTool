//
//  SkillTableViewCell.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/03/29.
//

import UIKit
import Kingfisher

class SkillTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    
    @IBOutlet weak var tripodView: UIView!    
    @IBOutlet weak var runeView: UIView!
    
    var data: Skill? {
        didSet {
            guard let data = data else {
                return
            }
            
            iconImageView.contentMode = .scaleAspectFit
            iconImageView.layer.cornerRadius = data.type.contains("각성") ? 0 : iconImageView.bounds.height / 2
            iconImageView.kf.setImage(with: URL(string: data.iconPath))
            nameLabel.text = data.title
            levelLabel.text = data.level
                        
            tripodView.subviews.enumerated().forEach { i, view in
                guard let label = view.subviews.last as? UILabel else { return }
                
                switch i {
                case 0:
                    label.text = data.tripod1?.replacingOccurrences(of: "레벨", with: "Lv.").replacingOccurrences(of: "(최대)", with: "")
                    tripodView.isHidden = data.tripod1 == nil
                case 1:
                    label.text = data.tripod2?.replacingOccurrences(of: "레벨", with: "Lv.").replacingOccurrences(of: "(최대)", with: "")
                    view.isHidden = data.tripod2 == nil
                case 2:
                    label.text = data.tripod3?.replacingOccurrences(of: "레벨", with: "Lv.").replacingOccurrences(of: "(최대)", with: "")
                    view.isHidden = data.tripod3 == nil
                default:
                    break
                }
            }
            
            if let runeImageView = runeView.subviews.first as? UIImageView,
               let runeLabel = runeView.subviews.last as? UILabel {
                
                runeImageView.kf.setImage(with: URL(string: data.rune?.iconPath ?? ""))
                runeLabel.text = data.rune?.tooltip
                runeView.isHidden = data.rune?.tooltip == ""
            }
            
            typeLabel.text = data.category
            switch data.category {
            case "일반":
                typeLabel.textColor = .systemGray
            case "지점":
                typeLabel.textColor = .systemYellow
            case "홀딩", "차지":
                typeLabel.textColor = .green.withAlphaComponent(0.75)
            case "콤보", "체인":
                typeLabel.textColor = .systemBlue.withAlphaComponent(0.5)
            case "캐스팅":
                typeLabel.textColor = .systemPink.withAlphaComponent(0.5)
            case "토글":
                typeLabel.textColor = .systemPink
            default:
                typeLabel.textColor = .label
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
    
}
