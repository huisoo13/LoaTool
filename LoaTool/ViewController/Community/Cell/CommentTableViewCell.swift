//
//  CommentTableViewCell.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/04/21.
//

import UIKit
import ActiveLabel

class CommentTableViewCell: UITableViewCell {
    @IBOutlet weak var jobImageView: UIImageView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var serverLabel: UILabel!
    
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var contentLabel: ActiveLabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var heartView: UIStackView!
    @IBOutlet weak var heartImageView: UIImageView!
    @IBOutlet weak var heartLabel: UILabel!
    
    @IBOutlet weak var commentView: UIStackView!
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var notificationView: UIImageView!
    
    weak var coordinator: AppCoordinator?
    
    var isOwner: Bool? {
        didSet {
            guard let isOwner = isOwner else {
                return
            }

            ownerLabel.clipsToBounds = true
            ownerLabel.layer.cornerRadius = 8
            ownerLabel.layer.borderColor = UIColor.custom.qualityOrange.cgColor
            ownerLabel.layer.borderWidth = 0.5
            ownerLabel.isHidden = !isOwner
        }
    }
    
    var isNotification: Bool? {
        didSet {
            guard let isNotification = isNotification else {
                return
            }

            notificationView.isHidden = !isNotification
        }
    }
    
    
    var data: Comment? {
        didSet {
            guard let data = data else {
                return
            }

            
            jobImageView.image = data.job.getSymbol()
            levelLabel.text = "Lv.\(Int(data.level))"
            nameLabel.text = data.name
            serverLabel.text = data.server
            
            contentLabel.text = data.text
            contentImageView.kf.setImage(with: URL(string: "http://15.164.244.43/\(data.imageURL.first ?? "")"),
                                         options: [
                                            .scaleFactor(UIScreen.main.scale),
                                            .transition(.fade(1))
                                         ])
            
            contentImageView.superview?.isHidden = (data.imageURL.first ?? "") == ""
            dateLabel.text = DateManager.shared.currentDistance(data.date)
            
            heartImageView.image = data.isLiked ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
            heartImageView.tintColor = data.isLiked ? .custom.qualityRed : .label
            heartLabel.text = "\(data.numberOfLiked)"
            
            commentLabel.text = data.numberOfComment != 0 ? "\(data.numberOfComment)개의 댓글" : "댓글달기"
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let data = data else {
            return
        }
        
        if data.type != 0 {
            commentView.isHidden = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
        backgroundColor = .secondarySystemGroupedBackground
        
        setupActiveLabel()
        setupGestureRecognizer()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupGestureRecognizer() {
        contentImageView.isUserInteractionEnabled = true
        contentImageView.addGestureRecognizer { _ in
            self.coordinator?.presentToImageViewerViewController(imageURL: self.data?.imageURL, animated: true)
        }
    }
    
    func setupActiveLabel() {
        contentLabel.customize { label in
            label.enabledTypes = [.mention, .url]
            label.mentionColor = .custom.qualityBlue
            label.URLColor = .systemBlue

            label.handleMentionTap { mention in
                self.coordinator?.pushToCharacterViewController(mention, animated: true)
            }
            
            label.handleURLTap { url in
                guard let data = self.data else { return }

                if data.owner == User.shared.identifier && User.shared.isConnected {
                    guard UIApplication.shared.canOpenURL(url) else { return }
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    Alert.message((self.coordinator?.navigationController.viewControllers.last)!, title: "타 사용자가 올린 링크", message: "확인 버튼을 누르면 링크를 열 수 있지만, 해당 링크를 열어 발생할 수 있는 문제에 대한 책임은 모두 사용자에게 있습니다.", option: .successAndCancelAction) { _ in
                        guard UIApplication.shared.canOpenURL(url) else { return }
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }
}
