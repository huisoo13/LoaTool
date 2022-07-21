//
//  CommunityTableViewCell.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/04/20.
//

import UIKit
import Kingfisher
import ActiveLabel

class CommunityTableViewCell: UITableViewCell {
    @IBOutlet weak var jobView: UIView!
    @IBOutlet weak var jobImageView: UIImageView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var serverLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    
    @IBOutlet weak var contentLabel: ActiveLabel!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var imageViewHeightAnchor: NSLayoutConstraint!
    @IBOutlet weak var stackImageView: UIImageView!
    
    @IBOutlet weak var heartButton: SHToggleButton!
    @IBOutlet weak var heartLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var bookmarkButton: SHToggleButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var moveView: UIStackView!
    @IBOutlet weak var moveButton: UIButton!
    
    weak var coordinator: AppCoordinator?

    var data: Community? {
        didSet {
            guard let data = data else { return }

            jobImageView.image = data.job.getSymbol()
            levelLabel.text = "Lv.\(data.level)"
            nameLabel.text = data.name
            serverLabel.text = data.server
                        
            stackImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
            stackImageView.isHidden = data.imageURL.count <= 1

            contentImageView.kf.setImage(with: URL(string: "http://15.164.244.43/\(data.imageURL.first ?? "")"),
                                         options: [
                                            .scaleFactor(UIScreen.main.scale),
                                            .transition(.fade(1))
                                         ])

            let width = UIScreen.main.bounds.width
            let height = min(width, (CGFloat(data.height) * width) / CGFloat(data.width))
            imageViewHeightAnchor.constant = height
            contentImageView.isHidden = (data.imageURL.first ?? "") == ""

            bookmarkButton.isSelected = data.isMarked
            heartButton.isSelected = data.isLiked
            heartLabel.text = "\(data.numberOfLiked >= 1000 ? "999+" : String(data.numberOfLiked))"
            commentLabel.text = "\(data.numberOfComment >= 1000 ? "999+" : String(data.numberOfComment))"
            
            dateLabel.text = DateManager.shared.currentDistance(data.date)
            
            contentLabel.enabledTypes = data.gateway == "" ? [.mention, .url] : [.mention, .url, .custom(pattern: "\\b북마크\\b")]
            contentLabel.text = data.text
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        setupView()
        setupGestureRecognizer()
        setupActiveLabel()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupView() {
        backgroundColor = .secondarySystemGroupedBackground
        
        jobView.layer.cornerRadius = 6
        jobView.layer.borderWidth = 0.5
        jobView.layer.borderColor = UIColor.systemGray4.cgColor
        
        jobImageView.tintColor = .label
        
        menuButton.transform = CGAffineTransform(rotationAngle: .pi / 2)
    }
    
    func setupGestureRecognizer() {
        jobView.addGestureRecognizer { _ in
            guard let data = self.data else { return }
            self.coordinator?.pushToCharacterViewController(data.name, animated: true)
        }
        
        contentImageView.isUserInteractionEnabled = true
        contentImageView.addGestureRecognizer { _ in
            self.coordinator?.presentToImageViewerViewController(imageURL: self.data?.imageURL, animated: true)
        }
        
        moveView.addGestureRecognizer { _ in
            self.coordinator?.pushToPostViewController(self.data, animated: true)
        }
    }
    
    func setupActiveLabel() {
        contentLabel.customize { label in
            let customType = ActiveType.custom(pattern: "\\b북마크\\b")
            label.enabledTypes = [.mention, .url, customType]
            
            label.mentionColor = .custom.qualityBlue
            label.URLColor = .systemBlue
            label.customColor[customType] = .custom.qualityOrange

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

            label.handleCustomTap(for: customType) { _ in
                guard let data = self.data else { return }
                
                API.get.selectSinglePost((self.coordinator?.navigationController.viewControllers.last)!, post: data.gateway) { data in
                    self.coordinator?.pushToPostViewController(data, animated: true)
                }
            }
        }
    }
}
