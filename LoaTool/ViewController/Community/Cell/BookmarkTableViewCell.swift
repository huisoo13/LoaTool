//
//  BookmarkTableViewCell.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/04/28.
//

import UIKit
import Kingfisher

class BookmarkTableViewCell: UITableViewCell {
    @IBOutlet weak var jobImageView: UIImageView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var serverLabel: UILabel!
    
    @IBOutlet weak var heartImageView: UIImageView!
    @IBOutlet weak var heartLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    var data: Community? {
        didSet {
            guard let data = data else { return }

            jobImageView.image = data.job.getSymbol()
            levelLabel.text = "Lv.\(data.level)"
            nameLabel.text = data.name
            serverLabel.text = data.server
            
            contentLabel.text = data.text
            thumbnailImageView.kf.setImage(with: URL(string: "http://15.164.244.43/\(data.imageURL.first ?? "")"),
                                           options: [
                                            .scaleFactor(UIScreen.main.scale),
                                            .transition(.fade(1))
                                           ])
            
            heartImageView.image = data.isLiked ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
            heartImageView.tintColor = data.isLiked ? .systemRed : .label
            heartLabel.text = "\(data.numberOfLiked)"

        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        thumbnailImageView.layer.cornerRadius = 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
