//
//  OCRManager.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2021/07/30.
//

import UIKit
import SwiftyJSON
import Alamofire

enum OCRError {
    case networkError
    case unknownError
}

class OCRManager {
    static let shared = OCRManager()
    
    private let apiURL = "https://b4678c03922b4491ac8117536e63664f.apigw.ntruss.com/custom/v1/10232/c99623a3ae93d55e4aada39b8066d45ba4588e9c0e7f1d7ce3c14c9cfb0b7e3e/infer"
    private let secretKey = " UUJoSVpjc2pya29PY2J6eHNtdEJiZnF4VVhIelJpbWc="

    
    func clovaOCRWithJSON(_ imageURL: String, completionHandle: @escaping ([String], OCRError?) -> ()) {
        guard Network.isConnected else {
            completionHandle([], .networkError)
            return
        }

        let timestamp = Date().timeIntervalSince1970

        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(secretKey, forHTTPHeaderField: "X-OCR-SECRET")
        
        let images: JSON = [
            "format": "png",
            "name": "sample",
            "url": imageURL
        ]
        
        let json: JSON = [
            "version": "V2",
            "requestId": "application/json",
            "lang": "ko",
            "timestamp": timestamp,
            "images": [images]
        ]
        
        
        let jsonData = "\(json)".data(using: .utf8, allowLossyConversion: false)!
        request.httpBody = jsonData

        AF.request(request).validate(statusCode: 200..<500).responseData {
            response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                debug("\(#function) JSON: \(json)")
                
                var text: [String] = []

                let images = json["images"].arrayValue
                images.forEach {
                    let fields = $0["fields"].arrayValue
                    for field in fields {
                        let name = field["inferText"].stringValue.components(separatedBy: " ").first!
                        
                        if name != "" && name != "x" && name != "모집중" && name.count > 1 {
                            text.append(name)
                        }
                    }
                }
                
                completionHandle(text, nil)
            case .failure(let error):
                debug("\(#function) error: \((error))")
                completionHandle([], .unknownError)
            }
        }
    }
    
    
    func clovaOCRWithFormData(_ image: UIImage, completionHandle: @escaping ([String], OCRError?) -> ()) {
        guard Network.isConnected else {
            completionHandle([], .networkError)
            return
        }
        
        let timestamp = Date().timeIntervalSince1970
        let imageData = image.jpegData(compressionQuality: 1)!
        
        let headers: HTTPHeaders = [
            "Content-Type": "multipart/form-data",
            "X-OCR-SECRET": secretKey
        ]
        
        let images: JSON = [
            "format": "jpg",
            "name": "sample"
        ]
        
        let json: JSON = [
            "version": "V2",
            "requestId": "multipart/form-data",
            "lang": "ko",
            "timestamp": timestamp,
            "images": [images]
        ]
        
        let jsonData = "\(json)".data(using: .utf8, allowLossyConversion: false)!

        AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(jsonData, withName: "message")
                multipartFormData.append(imageData, withName: "file", fileName: "ocr", mimeType: "image/jpg")
            },
            to: apiURL,
            method: .post,
            headers: headers
        ).responseData { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                debug("\(#function) JSON: \(json)")
                
                var text: [String] = []

                let images = json["images"].arrayValue
                images.forEach {
                    let fields = $0["fields"].arrayValue
                    for field in fields {
                        let name = field["inferText"].stringValue.components(separatedBy: " ").first!
                        
                        if name != "" && name != "x" && name != "모집중" && name.count > 1 {
                            text.append(name)
                        }
                    }
                }
                
                completionHandle(text, nil)
            case .failure(let error):
                debug("\(#function) error: \((error))")
                completionHandle([], .unknownError)
            }
        }
    }
}
