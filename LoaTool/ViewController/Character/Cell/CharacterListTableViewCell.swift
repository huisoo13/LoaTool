//
//  CharacterListTableViewCell.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/04/07.
//

import UIKit

class CharacterListTableViewCell: UITableViewCell {
    @IBOutlet weak var jobView: UIView!
    @IBOutlet weak var jobImageView: UIImageView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var chevronView: UIView!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var switchButton: UISwitch!
    
    var data: Sub? {
        didSet {
            guard let data = data else {
                return
            }

            jobImageView.image = data.job.getSymbol()
            levelLabel.text = "Lv.\(data.level)"
            nameLabel.text = data.name.components(separatedBy: " ")[safe: 1] ?? ""
        }
    }
    
    var member: Member? {
        didSet {
            guard let member = member else {
                return
            }

            jobImageView.image = member.job.getSymbol()
            levelLabel.text = "Lv.\(member.level)"
            nameLabel.text = member.name
        }
    }
    
    var showSwitchButton: Bool? {
        didSet {
            guard let showSwitchButton = showSwitchButton else {
                return
            }

            switchButton.isHidden = !showSwitchButton
        }
    }
    
    var showChevornView: Bool? {
        didSet {
            guard let showChevornView = showChevornView else {
                return
            }

            chevronView.isHidden = !showChevornView
        }
    }
    
    var showContentImageView: Bool? {
        didSet {
            guard let showContentImageView = showContentImageView else {
                return
            }

            contentImageView.isHidden = !showContentImageView
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        
        jobView.layer.cornerRadius = 6
        jobView.layer.borderWidth = 0.5
        jobView.layer.borderColor = UIColor.systemGray4.cgColor
        
        jobImageView.tintColor = .label
        
        switchButton.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        switchButton.isHidden = !(showSwitchButton ?? false)
        chevronView.isHidden = !(showChevornView ?? false)
        contentImageView.isHidden = !(showChevornView ?? false)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
