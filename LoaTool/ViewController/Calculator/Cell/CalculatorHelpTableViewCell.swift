//
//  CalculatorHelpTableViewCell.swift
//  LoaTool
//
//  Created by 정희수 on 2023/02/02.
//

import UIKit
import ActiveLabel

class CalculatorHelpTableViewCell: UITableViewCell {

    @IBOutlet var contentsView: UIView!
    @IBOutlet var activeLabel: ActiveLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        
        setupView()
        setupActiveLabel()
    }
    
    func setupView() {
        contentsView.layer.cornerRadius = 12
        contentsView.layer.masksToBounds = false
        contentsView.layer.shadowColor = UIColor.black.cgColor
        contentsView.layer.shadowOpacity = 0.1
        contentsView.layer.shadowOffset = CGSize(width: 0, height: 1)
        contentsView.layer.shadowRadius = 0
    }
    
    func setupActiveLabel() {
        activeLabel.text = """
• 계산기를 통해 얻은 결과 값은 경매장의 매물이 실시간으로 변동하기 때문에 무조건적인 맹신은 금물입니다.
• 자세한 사용법은 각인 계산기 사용 가이드를 확인해주세요.
• 로스트아크 공식 홈페이지 점검 중에는 설정하실 수 없습니다.
"""
        
        
        activeLabel.customize { label in
            let customType = ActiveType.custom(pattern: "각인 계산기 사용 가이드")
            label.enabledTypes = [customType]
            
            label.customColor[customType] = .link
            label.handleCustomTap(for: customType) { _ in
                print("AAA")
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
