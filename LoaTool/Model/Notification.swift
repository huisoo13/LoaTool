//
//  Notification.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/05/04.
//

import UIKit

class Notification {
    var identifier: String
    var type: Int
    var post: String
    var comment: String
    var reply: String
    var sender: String
    var name: String
    var job: String
    var level: Double
    var server: String
    var text: String
    var date: String
    
    var isRead: Bool
    
    /**
     구성 요소
     
     - parameters:
        - identifier: 알림 고유값
        - type: 알림 타입   0: 댓글     1: 언급     -10: 시스템 메시지        -20: 경고 메시지
        - post: 게시글 고유값
        - comment: 댓글 고유값
        - reply: 답글 고유값
        - sender: 알림을 보낸 사용자 고유값
        - name: 이름
        - job: 직업
        - level: 레벨
        - server: 서버
        - text: 내용
        - date: 시간
        - isRead: 읽음 여부
     */
    
    init(identifier: String, type: Int, post: String, comment: String, reply: String, sender: String, name: String, job: String, level: Double, server: String, text: String, date: String, isRead: Bool) {
        self.identifier = identifier
        self.type = type
        self.post = post
        self.comment = comment
        self.reply = reply
        self.sender = sender
        self.name = name
        self.job = job
        self.level = level
        self.server = server
        self.text = text
        self.date = date
        self.isRead = isRead
    }
}
