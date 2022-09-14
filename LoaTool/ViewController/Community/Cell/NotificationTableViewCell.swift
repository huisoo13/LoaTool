//
//  NotificationTableViewCell.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/05/10.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var jobImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var data: Notification? {
        didSet {
            guard let data = data else {
                return
            }

            iconImageView.layer.cornerRadius = iconImageView.bounds.height / 2
            
            switch data.type {
            case 0, 1, 2:
                iconImageView.image = UIImage(named: "content.icon.19") // data.type == 1 ? UIImage(named: "content.icon.19") : UIImage(named: "content.icon.34")
                iconImageView.layer.borderColor = UIColor.clear.cgColor

                jobImageView.isHidden = false
                jobImageView.image = data.job.getSymbol()
                
                contentLabel.attributedText = "Lv.\(Int(data.level)) \(data.name)\(data.server) \(data.text)"
                    .attributed(of: data.server, key: .foregroundColor, value: UIColor.custom.textBlue)
                    .addAttribute(of: data.server, key: .font, value: UIFont.systemFont(ofSize: 10, weight: .regular))
            case -10:
                // 공지사항
                iconImageView.image = UIImage(named: "icon.loatool")
                iconImageView.layer.borderColor = UIColor.separator.cgColor
                iconImageView.layer.borderWidth = 0.5
                
                jobImageView.isHidden = true
                
                contentLabel.text = data.text
            case -20:
                // 경고
                iconImageView.image = UIImage(named: "content.icon.11")
                iconImageView.layer.borderColor = UIColor.clear.cgColor
                
                jobImageView.isHidden = true

                contentLabel.text = data.text
            default:
                break
            }

            
            dateLabel.text = DateManager.shared.currentDistance(data.date)
            
            self.contentView.backgroundColor = data.isRead
            ? .systemGroupedBackground
            : .secondarySystemGroupedBackground
        }
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
