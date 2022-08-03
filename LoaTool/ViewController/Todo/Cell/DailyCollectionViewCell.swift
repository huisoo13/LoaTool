//
//  DailyCollectionViewCell.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/03/30.
//

import UIKit

class DailyCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var jobView: UIView!
    @IBOutlet weak var jobImageView: UIImageView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var serverLabel: UILabel!
        
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    
    weak var coordinator: AppCoordinator?

    var data: Member? {
        didSet {            
            guard let data = data else { return }

            jobImageView.image = data.job.getSymbol()
            levelLabel.text = "Lv.\(data.level)"
            nameLabel.text = data.name.components(separatedBy: " ").last ?? ""
            
            stackView.arrangedSubviews.enumerated().forEach { i, view in
                guard let bonusLabel = view.subviews.first as? UILabel,
                      let bonusView = view.subviews[safe: 4] as? UIStackView,
                      let completeView = view.subviews.last as? UIStackView,
                      let content = data.contents[safe: i] else { return }
                
                let showBonusView = UserDefaults.standard.bool(forKey: "showBonusView")
                bonusLabel.isHidden = showBonusView
                bonusView.isHidden = !showBonusView
                
                bonusLabel.text = "\(content.bonusValue)"
                bonusView.arrangedSubviews.enumerated().forEach { i, view in
                    guard let view = view.subviews.first else { return }
                    let value = content.bonusValue / 10
                    view.isHidden = i * 2 >= value
                    
                    let isHalf = !(value / 2 == i) || value % 2 == 0
                    view.transform = CGAffineTransform(scaleX: isHalf ? 1 : 0.5, y: 1).translatedBy(x: isHalf ? 0 : -view.bounds.midX, y: 0)
                }
                
                completeView.arrangedSubviews.enumerated().forEach { j, view in
                    view.backgroundColor = j < content.value
                    ? .custom.textBlue
                    : (j < content.maxValue ? .systemGray4 : .clear)
                }
            }
            
            setupGestureRecognizer()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        setupView()
    }
    
    func setupView() {
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowRadius = 0
        
        jobView.layer.cornerRadius = 6
        jobView.layer.borderWidth = 0.5
        jobView.layer.borderColor = UIColor.systemGray4.cgColor

        stackView.arrangedSubviews.forEach { view in
            guard let iconView = view.subviews[safe: 1],
                  let bonusView = view.subviews[safe: 4] as? UIStackView,
                  let completeView = view.subviews.last as? UIStackView else { return }
            
            iconView.layer.cornerRadius = 6
            iconView.layer.borderWidth = 0.5
            iconView.layer.borderColor = UIColor.systemGray4.cgColor

            bonusView.arrangedSubviews.forEach {
                $0.layer.cornerRadius = 2
                $0.clipsToBounds = true
            }
            
            completeView.arrangedSubviews.forEach { $0.layer.cornerRadius = 4 }
        }
    }
    
    func setupGestureRecognizer() {
        stackView.arrangedSubviews.enumerated().forEach { i, view in
            guard let data = data,
                  let content = data.contents[safe: i] else { return }
            
            view.addGestureRecognizer { _ in
                RealmManager.shared.update {
                    content.value = content.value < content.maxValue ? content.value + 1 : 0
                    
                    let bonus = content.originBonusValue - (content.value * 20)
                    content.bonusValue = max(0, (bonus < 0 && bonus % 20 != 0 ? 10 : bonus))
                }
                
                self.data = data
            }
        }
        
        button.addGestureRecognizer { _ in
            self.coordinator?.pushToEditCharacterViewController(self.data, animated: true)
        }
    }
}
