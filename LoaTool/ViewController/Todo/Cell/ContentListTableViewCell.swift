//
//  ContentListTableViewCell.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/03/31.
//

import UIKit

class ContentListTableViewCell: UITableViewCell {

    @IBOutlet weak var typeView: UIView!
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var linkView: UIView!
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var chevronView: UIView!
    
    var data: AdditionalContent? {
        didSet {
            guard let data = data else {
                return
            }

            switch data.type / 10 {
            case 1:
                typeView.backgroundColor = .systemRed
            case 2:
                typeView.backgroundColor = .systemYellow
            case 3:
                typeView.backgroundColor = .systemGreen
            case 4:
                typeView.backgroundColor = .systemBlue
            default:
                break
            }
            
            iconImageView.image = UIImage(named: "content.icon.\(data.icon)")
            label.text = data.title
            
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
    
    var showLinkView: Bool? {
        didSet {
            guard let showLinkView = showLinkView else {
                return
            }

            linkView.isHidden = !showLinkView
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        typeView.layer.cornerRadius = typeView.bounds.height / 2
        
        iconView.layer.cornerRadius = 6
        iconView.layer.borderWidth = 0.5
        iconView.layer.borderColor = UIColor.systemGray4.cgColor
        
        switchButton.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        switchButton.isHidden = !(showSwitchButton ?? false)
        chevronView.isHidden = !(showChevornView ?? false)
        linkView.isHidden = !(showLinkView ?? false)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
