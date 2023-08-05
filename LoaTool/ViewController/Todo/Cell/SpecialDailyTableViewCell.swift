//
//  SpecialDailyTableViewCell.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/03/30.
//

import UIKit

class SpecialDailyTableViewCell: UITableViewCell {

    @IBOutlet weak var stackView: UIStackView!
    
    var data: Member? {
        didSet {
            stackView.arrangedSubviews.enumerated().forEach { i, view in
                guard let completeView = view.subviews.last as? UIStackView,
                      let titleLabel = view.subviews[safe: 2] as? UILabel,
                      let content = data?.contents[safe: i] else { return }
                
                if i != 2 {
                    let weekday = DateManager.shared.currentWeekday()
                    let yesterday = weekday == 1 ? 7 : weekday - 1
                    let isAfterAM6 = DateManager.shared.isAfterAM6
                    
                    if content.weekday.contains(weekday) && isAfterAM6 {
                        titleLabel.textColor = .label
                    } else if content.weekday.contains(yesterday) && !isAfterAM6 {
                        titleLabel.textColor = .label
                    } else {
                        titleLabel.textColor = .systemRed
                    }
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupView() {
        self.selectionStyle = .none
        
        stackView.arrangedSubviews.forEach { view in
            guard let typeView = view.subviews.first,
                  let iconView = view.subviews[safe: 1],
                  let completeView = view.subviews.last as? UIStackView else { return }
            
            view.layer.cornerRadius = 12
            view.layer.masksToBounds = false
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.1
            view.layer.shadowOffset = CGSize(width: 0, height: 1)
            view.layer.shadowRadius = 0

            typeView.layer.cornerRadius = typeView.bounds.height / 2
            
            iconView.layer.cornerRadius = 6
            iconView.layer.borderWidth = 0.5
            iconView.layer.borderColor = UIColor.systemGray4.cgColor

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
                }

                self.data = data
            }
        }
    }
}
