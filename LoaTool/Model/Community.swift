//
//  Community.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/04/21.
//

import UIKit

class Community {
    var identifier: String
    
    var owner: String
    var name: String
    var job: String
    var level: Double
    var server: String

    var text: String
    var imageURL: [String]
    var width: Int = 0
    var height: Int = 0
    
    var gateway: String
    
    var numberOfLiked: Int
    var numberOfComment: Int 
    
    var isLiked: Bool
    var isMarked: Bool
    
    var date: String
    
    /**
     구성 요소
     
     - parameters:
        - identifier: 고유값
        - owner: 작성자 고유값
        - name: 이름
        - job: 직업
        - level: 레벨
        - server: 서버
        - text: 본문 내용
        - imageURL: 이미지 주소
        - gateway: 첨부 고유걊
        - numberOfLiked: 좋아요 수
        - numberOfComment: 댓글 수
        - isLiked: 좋아요 여부
        - isMarked: 북마크 여부
        - date: 날짜
     */
    init(identifier: String, owner: String, name: String, job: String, level: Double, server: String, text: String, imageURL: [String], width: Int = 0, height: Int = 0, gateway: String, numberOfLiked: Int, numberOfComment: Int, isLiked: Bool, isMarked: Bool, date: String) {
        self.identifier = identifier
        self.owner = owner
        self.name = name
        self.job = job
        self.level = level
        self.server = server
        self.text = text
        self.imageURL = imageURL
        self.width = width
        self.height = height
        self.gateway = gateway
        self.numberOfLiked = numberOfLiked
        self.numberOfComment = numberOfComment
        self.isLiked = isLiked
        self.isMarked = isMarked
        self.date = date
    }
}

class Comment {
    var identifier: String
    var target: String
    var type: Int
    
    var mention: String
    var owner: String
    var name: String
    var job: String
    var level: Double
    var server: String
    
    var text: String
    
    var date: String
    
    var numberOfComment: Int
    var numberOfLiked: Int
    var isLiked: Bool

    /**
     구성 요소
     
     - parameters:
        - identifier: 댓글 고유값
        - target: 글 고유값
        - mention: 대상 고유값
        - owner: 작성자 고유값
        - name: 이름
        - job: 직업
        - level: 레벨
        - server: 서버
        - text: 내용
        - numberOfLiked: 좋아요 수
        - isLiked: 좋아요 여부
        - date: 날짜
     */
    init(identifier: String, target: String, type: Int, mention: String, owner: String, name: String, job: String, level: Double, server: String, text: String, numberOfComment: Int, numberOfLiked: Int, isLiked: Bool, date: String) {
        self.identifier = identifier
        self.target = target
        self.type = type
        self.mention = mention
        self.owner = owner
        self.name = name
        self.job = job
        self.level = level
        self.server = server
        self.text = text
        self.numberOfComment = numberOfComment
        self.numberOfLiked = numberOfLiked
        self.isLiked = isLiked
        self.date = date
    }

}

class FilterOption {
    var text: String = ""
    var type: Int = 0
    
    var isMine: Bool = false
    var isLiked: Bool = false
    var isMarked: Bool = false
}


class Image {
    var fileName: String = ""
    var image: UIImage = UIImage()
    
    init(fileName: String, image: UIImage) {
        self.fileName = fileName
        self.image = image
    }
    
    init() { }
}
