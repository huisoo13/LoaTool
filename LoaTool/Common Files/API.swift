//
//  API.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/06/13.
//

import UIKit
import Alamofire
import SwiftyJSON

class API {
    static let get: API = API(method: .get)
    static let post: API = API(method: .post)
    static let put: API = API(method: .put)
    static let patch: API = API(method: .patch)
    static let delete: API = API(method: .delete)

    var method: HTTPMethod = .post
    
    private let _SERVER: String = "http://15.164.244.43/api/"
    
    init(method: HTTPMethod) {
        self.method = method
    }
    
    
    // MARK: - GET
    func certification(_ target: UIViewController) {
        let parameters: Parameters = [
            "stove": User.shared.stove,
            "sequence": User.shared.sequence
        ]
        
        AF.request(_SERVER + "certification.php", method: method, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate().responseData { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                                
                let result = json["result"].boolValue
                User.shared.isConnected = result
                
                if !result { Alert.message(target, title: "인증 만료", message: "다른 기기 또는 사용자가 동일한 STOVE 계정을 이용하여 기존 인증이 만료되었습니다.", handler: nil) }
                
                // iCloud 사용자 정보 업데이트
                CloudManager.shared.commit()
            case .failure(let error):
                debug(error)
            }
        }
    }
    
    func selectBadge() {
        let parameters: Parameters = [
            "owner": User.shared.identifier
        ]
        
        AF.request(_SERVER + "selectBadge.php", method: method, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate().responseData { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                                
                let result = json["result"].boolValue
                UserDefaults.standard.set(result, forKey: "showBadge")
                if result { NotificationCenter.default.post(name: NSNotification.Name("showBadge"), object: nil) }
            case .failure(let error):
                debug(error)
            }
        }
    }
    
    func selectPost(_ target: UIViewController, page number: Int = 0, filter option: FilterOption = FilterOption(), completionHandler: ((_ data: [Community])->())? = nil) {
        guard Network.isConnected else {
            Alert.networkError(target)
            return
        }
        
        let parameters: Parameters = [
            "owner": User.shared.identifier,
            "page": number,
            "type": option.type,
            "text": option.text,
            "isMine": option.isMine,
            "isLiked": option.isLiked,
            "isMarked": option.isMarked
        ]
        
        var post: [Community] = []
                
        AF.request(_SERVER + "selectPost.php", method: method, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate().responseData { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                let result = json["result"].boolValue
                let array = json["data"].arrayValue
                                
                if !result { return }
                for data in array {
                    let identifier = data["identifier"].stringValue
                    let owner = data["owner"].stringValue
                    let name = data["name"].stringValue
                    let server = data["server"].stringValue
                    let job = data["job"].stringValue
                    let level = data["level"].doubleValue
                    let text = data["text"].stringValue
                    let gateway = data["gateway"].stringValue
                    let image = data["image"].stringValue
                    let width = data["width"].intValue
                    let height = data["height"].intValue
                    let numberOfLike = data["numberOfLike"].intValue
                    let numberOfComment = data["numberOfComment"].intValue
                    let isLiked = data["isLiked"].boolValue
                    let isMarked = data["isMarked"].boolValue
                    let date = data["date"].stringValue
                    
                    post.append(Community(identifier: identifier,
                                          owner: owner,
                                          name: name,
                                          job: job,
                                          level: level,
                                          server: server,
                                          text: text,
                                          imageURL: image.components(separatedBy: ",").sorted(by: { $0 < $1 }),
                                          width: width,
                                          height: height,
                                          gateway: gateway,
                                          numberOfLiked: numberOfLike,
                                          numberOfComment: numberOfComment,
                                          isLiked: isLiked,
                                          isMarked: isMarked,
                                          date: date)
                    )
                }
                
                completionHandler?(post)
            case .failure(let error):
                debug(error)
            }
        }
    }
    
    func selectSinglePost(_ target: UIViewController, post identifier: String, completionHandler: ((_ data: Community)->())? = nil) {
        guard Network.isConnected else {
            Alert.networkError(target)
            return
        }
        
        let parameters: Parameters = [
            "identifier": identifier,
            "owner": User.shared.identifier
        ]
                
        AF.request(_SERVER + "selectSinglePost.php", method: method, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate().responseData { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                let result = json["result"].boolValue
                let array = json["data"].arrayValue
                                
                if !result { return }
                for data in array {
                    let identifier = data["identifier"].stringValue
                    let owner = data["owner"].stringValue
                    let name = data["name"].stringValue
                    let server = data["server"].stringValue
                    let job = data["job"].stringValue
                    let level = data["level"].doubleValue
                    let text = data["text"].stringValue
                    let gateway = data["gateway"].stringValue
                    let image = data["image"].stringValue
                    let width = data["width"].intValue
                    let height = data["height"].intValue
                    let numberOfLike = data["numberOfLike"].intValue
                    let numberOfComment = data["numberOfComment"].intValue
                    let isLiked = data["isLiked"].boolValue
                    let isMarked = data["isMarked"].boolValue
                    let isBlocked = data["isBlocked"].boolValue
                    let status = data["status"].intValue
                    let date = data["date"].stringValue
                    
                    if status == 1 {
                        Alert.message(target, title: "삭제된 게시글", message: "게시글이 삭제되어 이동할 수 없습니다.", option: .onlySuccessAction, handler: nil)
                        return
                    }
                    
                    let post = Community(identifier: identifier,
                                         owner: owner,
                                         name: name,
                                         job: job,
                                         level: level,
                                         server: server,
                                         text: text,
                                         imageURL: image.components(separatedBy: ",").sorted(by: { $0 < $1 }),
                                         width: width,
                                         height: height,
                                         gateway: gateway,
                                         numberOfLiked: numberOfLike,
                                         numberOfComment: numberOfComment,
                                         isLiked: isLiked,
                                         isMarked: isMarked,
                                         date: date)
                    
                    if isBlocked {
                        Alert.message(target, title: "차단한 사용자의 게시글", message: "해당 게시글로 이동하시겠습니까?\n게시글은 확인 할 수 있지만 작성자의 댓글은 보이지 않습니다.", option: .successAndCancelAction) { _ in completionHandler?(post) }
                        return
                    }
                    
                    completionHandler?(post)
                }
            case .failure(let error):
                debug(error)
            }
        }
    }
    
    
    func selectComment(_ target: UIViewController, type: Int = 0, identifier: String, page number: Int = 0, completionHandler: ((_ data: [Comment])->())? = nil) {
        guard Network.isConnected else {
            Alert.networkError(target)
            return
        }
        
        let parameters: Parameters = [
            "owner": User.shared.identifier,
            "type": type,
            "target": identifier,
            "page": number
        ]
                        
        AF.request(_SERVER + "selectComment.php", method: method, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate().responseData { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                debug(json)
                                
                let result = json["result"].boolValue
                let array = json["data"].arrayValue
                
                var comment: [Comment] = []
                
                if !result { return }
                for data in array {
                    let identifier = data["identifier"].stringValue
                    let target = data["target"].stringValue
                    let mention = data["mention"].stringValue
                    let owner = data["owner"].stringValue
                    let name = data["name"].stringValue
                    let server = data["server"].stringValue
                    let job = data["job"].stringValue
                    let level = data["level"].doubleValue
                    let imageURL = data["image"].stringValue
                    let text = data["text"].stringValue
                    let numberOfComment = data["numberOfComment"].intValue
                    let numberOfLike = data["numberOfLike"].intValue
                    let isLiked = data["isLiked"].boolValue
                    let date = data["date"].stringValue
                    
                    comment.append(Comment(identifier: identifier,
                                           target: target,
                                           type: type,
                                           mention: mention,
                                           owner: owner,
                                           name: name,
                                           job: job,
                                           level: level,
                                           server: server,
                                           imageURL: [imageURL],
                                           text: text,
                                           numberOfComment: numberOfComment,
                                           numberOfLiked: numberOfLike,
                                           isLiked: isLiked,
                                           date: date)
                    )
                }
                
                completionHandler?(comment)
            case .failure(let error):
                debug(error)
            }
        }
    }
    
    func selectSingleComment(_ target: UIViewController, type: Int = 0, identifier: String, completionHandler: ((_ data: Comment)->())? = nil) {
        guard Network.isConnected else {
            Alert.networkError(target)
            return
        }
        
        let parameters: Parameters = [
            "owner": User.shared.identifier,
            "type": type,
            "identifier": identifier
        ]
                        
        AF.request(_SERVER + "selectSingleComment.php", method: method, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate().responseData { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                                             
                let result = json["result"].boolValue
                let array = json["data"].arrayValue
                
                if !result { return }
                for data in array {
                    let status = data["status"].intValue
                    
                    if status == 1 {
                        Alert.message(target, title: "삭제된 댓글", message: "댓글이 삭제되어 확인할 수 없습니다.", option: .onlySuccessAction, handler: nil)
                        return
                    }
                    
                    let identifier = data["identifier"].stringValue
                    let target = data["target"].stringValue
                    let type = data["type"].intValue
                    let mention = data["mention"].stringValue
                    let owner = data["owner"].stringValue
                    let name = data["name"].stringValue
                    let server = data["server"].stringValue
                    let job = data["job"].stringValue
                    let level = data["level"].doubleValue
                    let text = data["text"].stringValue
                    let numberOfComment = data["numberOfComment"].intValue
                    let numberOfLike = data["numberOfLike"].intValue
                    let isLiked = data["isLiked"].boolValue
                    let date = data["date"].stringValue

                    let comment = Comment(identifier: identifier,
                                          target: target,
                                          type: type,
                                          mention: mention,
                                          owner: owner,
                                          name: name,
                                          job: job,
                                          level: level,
                                          server: server,
                                          text: text,
                                          numberOfComment: numberOfComment,
                                          numberOfLiked: numberOfLike,
                                          isLiked: isLiked,
                                          date: date)
                    
                    completionHandler?(comment)
                }
            case .failure(let error):
                debug(error)
            }
        }
    }


    func selectNotification(_ target: UIViewController, completionHandler: ((_ data: [Notification])->())? = nil) {
        guard Network.isConnected else {
            Alert.networkError(target)
            return
        }
        
        let parameters: Parameters = [
            "owner": User.shared.identifier
        ]
        
        var notification: [Notification] = []
                
        AF.request(_SERVER + "selectNotification.php", method: method, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate().responseData { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                                                
                let result = json["result"].boolValue
                let array = json["data"].arrayValue
                
                if !result { return }
                for data in array {
                    let identifier = data["identifier"].stringValue
                    let type = data["type"].intValue
                    let post = data["post"].stringValue
                    let comment = data["comment"].stringValue
                    let reply = data["reply"].stringValue
                    let sender = data["sender"].stringValue
                    let name = data["name"].stringValue
                    let server = data["server"].stringValue
                    let job = data["job"].stringValue
                    let level = data["level"].doubleValue
                    let text = data["text"].stringValue
                    let status = data["status"].intValue
                    let date = data["date"].stringValue
                    
                    notification.append(Notification(identifier: identifier,
                                                     type: type,
                                                     post: post,
                                                     comment: comment,
                                                     reply: reply,
                                                     sender: sender,
                                                     name: name,
                                                     job: job,
                                                     level: level,
                                                     server: server,
                                                     text: text,
                                                     date: date,
                                                     isRead: status == 1)
                    )
                }
                
                completionHandler?(notification)
            case .failure(let error):
                debug(error)
            }
        }
    }
    
    func selectBlock(_ target: UIViewController, completionHandler: ((_ data: [Block])->())? = nil) {
        guard Network.isConnected else {
            Alert.networkError(target)
            return
        }
        
        let parameters: Parameters = [
            "owner": User.shared.identifier
        ]
        
        var block: [Block] = []
                
        AF.request(_SERVER + "selectBlock.php", method: method, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate().responseData { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                let result = json["result"].boolValue
                let array = json["data"].arrayValue
                
                if !result { return }
                for data in array {
                    let identifier = data["identifier"].stringValue
                    let name = data["name"].stringValue
                    let date = data["date"].stringValue
                    
                    block.append(Block(identifier: identifier,
                                       name: name,
                                       date: date)
                    )
                }
                
                completionHandler?(block)
            case .failure(let error):
                debug(error)
            }
        }
    }


    
    // MARK: - POST
    func insertCertifiedUser(_ target: UIViewController, stove identifier: String, character name: String, completionHandler: ((_ result: Bool)->())? = nil) {
        guard Network.isConnected else {
            Alert.networkError(target)
            return
        }

        let uuid = User.shared.identifier == "" ? UUID().uuidString : User.shared.identifier
        let parameters: Parameters = [
            "identifier": uuid,
            "stove": identifier,
            "name": name
        ]
        
        AF.request(_SERVER + "insertCertifiedUser.php", method: method, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate().responseData { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                                                
                let result = json["result"].boolValue
                let sequence = json["sequence"].stringValue
                let uuid = json["uuid"].stringValue
                completionHandler?(result)
                
                if result {
                    User.shared.isConnected = true
                    User.shared.identifier = uuid
                    User.shared.stove = identifier
                    User.shared.name = name
                    User.shared.sequence = sequence
                    
                    // iCloud 사용자 정보 업데이트
                    CloudManager.shared.commit()
                } else {
                    Alert.unknownError(target)
                }
            case .failure(let error):
                debug(error)
                Alert.unknownError(target)
            }
        }
    }
    
    func uploadImageForPost(_ target: UIViewController, input text: String, input image: [Image], gateway: String, completionHandler: ((_ result: Bool)->())? = nil) {
        guard Network.isConnected else {
            Alert.networkError(target)
            return
        }
        
        let post = UUID().uuidString

        let headers: HTTPHeaders = ["Content-type": "multipart/form-data"]
        let parameters = ["target": post,
                          "category": "0"]

        AF.upload(
            multipartFormData: { multipartFormData in
                image.enumerated().forEach { i, item in
                    guard let data = item.image.jpegData(compressionQuality: 0.9) else { return }
                    multipartFormData.append(data, withName: "\(i)", fileName: "\(item.fileName).jpg", mimeType: "image/jpg")
                }
                
                for (key, value) in parameters {
                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                }
            },
            to: _SERVER + "uploadImageFile.php",
            method: method,
            headers: headers).uploadProgress(queue: .global(qos: .background)) { progress in
                debug("Upload Progress: \(progress.fractionCompleted)")
            }.responseData { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let result = json["result"].boolValue

                    if result {
                        self.insertPost(target, post: post, input: text, gateway: gateway) { result in completionHandler?(result) }
                    } else {
                        completionHandler?(false)
                    }
                case .failure(let error):
                    debug(error)
                    Alert.unknownError(target)
                }
            }
        
    }
    
    func insertPost(_ target: UIViewController, post identifier: String, input text: String, gateway: String = "", completionHandler: ((_ result: Bool)->())? = nil) {
        guard let data = RealmManager.shared.readAll(Character.self).last?.info else { return }
        
        let parameters: Parameters = [
            "identifier": identifier,
            "owner": User.shared.identifier,
            "name": User.shared.name,
            "server": data.server,
            "job": data.job,
            "level": data.level,
            "text": text,
            "gateway": gateway,
        ]
        
        AF.request(_SERVER + "insertPost.php", method: method, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate().responseData { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)

                let result = json["result"].boolValue
                completionHandler?(result)
            case .failure(let error):
                debug(error)
                Alert.unknownError(target)
            }
        }
    }
    
    func uploadImageForComment(_ target: UIViewController, type: Int, post: String, mention: String = "", input text: String, input image: [Image], completionHandler: ((_ result: Bool)->())? = nil) {
        guard Network.isConnected else {
            Alert.networkError(target)
            return
        }
        
        let identifier = UUID().uuidString

        let headers: HTTPHeaders = ["Content-type": "multipart/form-data"]
        let parameters = ["target": identifier,
                          "category": "1"]

        AF.upload(
            multipartFormData: { multipartFormData in
                image.enumerated().forEach { i, item in
                    guard let data = item.image.jpegData(compressionQuality: 0.9) else { return }
                    multipartFormData.append(data, withName: "\(i)", fileName: "\(item.fileName).jpg", mimeType: "image/jpg")
                }
                
                for (key, value) in parameters {
                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                }
            },
            to: _SERVER + "uploadImageFile.php",
            method: method,
            headers: headers).uploadProgress(queue: .global(qos: .background)) { progress in
                debug("Upload Progress: \(progress.fractionCompleted)")
            }.responseData { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let result = json["result"].boolValue

                    if result {
                        self.insertComment(target, identifier: identifier, type: type, post: post, mention: mention, input: text) { result in completionHandler?(result) }
                    } else {
                        completionHandler?(false)
                    }
                case .failure(let error):
                    debug(error)
                    Alert.unknownError(target)
                }
            }
        
    }
    
    func insertComment(_ target: UIViewController, identifier: String = "", type: Int, post: String, mention: String = "", input text: String, completionHandler: ((_ result: Bool)->())? = nil) {
        guard let data = RealmManager.shared.readAll(Character.self).last?.info else { return }
        
        let parameters: Parameters = [
            "identifier": identifier,
            "target": post,
            "type": type,
            "mention": mention,
            "owner": User.shared.identifier,
            "name": User.shared.name,
            "server": data.server,
            "job": data.job,
            "level": data.level,
            "text": text,
        ]
        
        AF.request(_SERVER + "insertComment.php", method: method, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate().responseData { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                let result = json["result"].boolValue
                completionHandler?(result)
            case .failure(let error):
                debug(error)
                Alert.unknownError(target)
            }
        }
    }
    
    func insertReport(_ target: UIViewController, category: Int, targetIdentifier: String, type: Int, user identifier: String, text: String = "", completionHandler: ((_ result: Bool)->())? = nil) {
        let parameters: Parameters = [
            "category": category,
            "target": targetIdentifier,
            "identifier": identifier,
            "type": type,
            "owner": User.shared.identifier,
            "text": text,
        ]
        
        AF.request(_SERVER + "insertReport.php", method: method, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate().responseData { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                let result = json["result"].boolValue
                completionHandler?(result)
            case .failure(let error):
                debug(error)
                Alert.unknownError(target)
            }
        }
    }
    
    func updateLike(type: Int, identifier: String, completionHandler: ((_ result: Bool)->())? = nil) {
        let parameters: Parameters = [
            "type": type,
            "owner": User.shared.identifier,
            "target": identifier
        ]
        
        AF.request(_SERVER + "updateLike.php", method: method, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate().responseData { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                let result = json["result"].boolValue
                completionHandler?(result)
            case .failure(let error):
                debug(error)
            }
        }
    }

    func updateBookmark(post identifier: String, completionHandler: ((_ result: Bool)->())? = nil) {
        let parameters: Parameters = [
            "owner": User.shared.identifier,
            "target": identifier
        ]
        
        AF.request(_SERVER + "updateBookmark.php", method: method, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate().responseData { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                let result = json["result"].boolValue
                completionHandler?(result)
            case .failure(let error):
                debug(error)
            }
        }
    }
    
    func updatePost(_ identifier: String, text: String = "", forKey: String, completionHandler: ((_ result: Bool)->())? = nil) {
        var parameters: Parameters = [:]
        
        switch forKey {
        case "DELETE":
            parameters = [
                "owner": User.shared.identifier,
                "identifier": identifier,
                "key": forKey
            ]
        case "UPDATE":
            parameters = [
                "owner": User.shared.identifier,
                "identifier": identifier,
                "text": text,
                "key": forKey
            ]
        default:
            return
        }
        

        
        AF.request(_SERVER + "updatePost.php", method: method, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate().responseData { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                let result = json["result"].boolValue
                completionHandler?(result)
            case .failure(let error):
                debug(error)
            }
        }
    }
    
    func updateComment(_ identifier: String, type: Int, completionHandler: ((_ result: Bool)->())? = nil) {
        let parameters: Parameters = [
            "owner": User.shared.identifier,
            "type": type,
            "identifier": identifier
        ]
        
        AF.request(_SERVER + "updateComment.php", method: method, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate().responseData { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                let result = json["result"].boolValue
                completionHandler?(result)
            case .failure(let error):
                debug(error)
            }
        }
    }
    
    func updateBlock(_ identifier: String, type: Int = 0, completionHandler: ((_ result: Bool)->())? = nil) {
        let parameters: Parameters = [
            "owner": User.shared.identifier,
            "type": type,
            "target": identifier
        ]
        
        AF.request(_SERVER + "updateBlock.php", method: method, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate().responseData { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                                
                let result = json["result"].boolValue
                completionHandler?(result)
            case .failure(let error):
                debug(error)
            }
        }
    }
    
    func updateNotification(_ identifier: String = "", completionHandler: ((_ result: Bool)->())? = nil) {
        let parameters: Parameters = [
            "owner": User.shared.identifier,
            "identifier": identifier
        ]
        
        AF.request(_SERVER + "updateNotification.php", method: method, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate().responseData { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                let result = json["result"].boolValue
                completionHandler?(result)
            case .failure(let error):
                debug(error)
            }
        }
    }
    
    func updateToken(_ token: String = "", completionHandler: ((_ result: Bool)->())? = nil) {
        if User.shared.identifier == "" { return }
        let parameters: Parameters = [
            "identifier": User.shared.identifier,
            "stove": User.shared.stove,
            "device": UIDevice.current.localizedModel,
            "token": token
        ]
        
        AF.request(_SERVER + "updateToken.php", method: method, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate().responseData { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                let result = json["result"].boolValue
                completionHandler?(result)
            case .failure(let error):
                debug(error)
            }
        }
    }
    
    // MARK: - PUT
    
    
    // MARK: - PATCH
    
    
    // MARK: - DELETE

    
    
}
