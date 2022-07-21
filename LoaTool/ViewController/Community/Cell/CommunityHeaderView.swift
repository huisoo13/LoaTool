//
//  CommunityHeaderView.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/05/09.
//

import UIKit

class CommunityHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var button: UIButton!
    
    var data: FilterOption? {
        didSet {
            guard let data = data else {
                return
            }
            
            let title = data.text == "" && !data.isMine && !data.isLiked && !data.isMarked
            ? "전체보기"
            : (data.text == ""
               ? "검색어가 없습니다."
               : "\(data.type == 0 ? "내용" : "작성자") '\(data.text)' 검색 결과"
            )
            
            var subTitle = ""
            if data.isMine && data.isLiked && data.isMarked {
                subTitle = "내가 좋아요와 북마크를 누른 내 글만 보기"
            } else if data.isMine && data.isLiked {
                subTitle = "내가 좋아요를 누른 내 글만 보기"
            } else if data.isMine && data.isMarked {
                subTitle = "내가 북마크를 누른 내 글만 보기"
            } else if data.isLiked && data.isMarked {
                subTitle = "내가 좋아요와 북마크를 누른 글만 보기"
            } else if data.isMine {
                subTitle = "내 글만 보기"
            } else if data.isLiked {
                subTitle = "내가 좋아요를 누른 글만 보기"
            } else if data.isMarked {
                subTitle = "내가 북마크를 누른 글만 보기"
            }

            var configuration = UIButton.Configuration.plain()
            var containerForTitle = AttributeContainer()
            containerForTitle.font = UIFont.systemFont(ofSize: 12, weight: .light)
            containerForTitle.foregroundColor = .label

            configuration.attributedTitle = AttributedString(title, attributes: containerForTitle)
            
            var containerForSubTitle = AttributeContainer()
            containerForSubTitle.font = UIFont.systemFont(ofSize: 10, weight: .light)
            containerForSubTitle.foregroundColor = .secondaryLabel

            configuration.attributedSubtitle = AttributedString(subTitle, attributes: containerForSubTitle)

            button.configuration = configuration
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        button.isUserInteractionEnabled = false
    }
}
