//
//  ErrorTableViewCell.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/03/31.
//

import UIKit

class ErrorTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    var error: Parsing.ParsingError? {
        didSet {
            guard let error = error else { return }
            
            switch error {
            case .notFound:
                label.text = "캐릭터 정보가 없습니다.\n캐릭터명을 확인해주세요."
            case .websiteInspect:
                label.text = "전투 정보실이 점검 중 입니다.\n나중에 다시 이용해주세요."
            case .unknown:
                label.text = "알 수 없는 오류가 발생했습니다.\n잠시 후 다시 이용해주세요."
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
