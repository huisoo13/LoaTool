//
//  Service.swift
//  Sample
//
//  Created by Trading Taijoo on 2021/05/31.
//
/*
import Foundation
import Alamofire
import SwiftyJSON

enum ServiceError: Error {
    case network
    case failed
}

class Service {
    static let shared = Service()

    func fetchApps(parameters: [String: Any], urlString: String, method: HTTPMethod = .post, completionHandler: @escaping (JSON?, Error?) -> ()) {
        fetchGenericJSONData(parameters: parameters, urlString: urlString, completionHandler: completionHandler)
    }
    
    func fetchGenericJSONData<T>(parameters: [String: Any], urlString: String, method: HTTPMethod = .post, completionHandler: @escaping (T?, Error?) -> ()) {
        if Network.isConnected {
            AF.request(urlString, method: method, parameters: parameters as Parameters).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    
                    completionHandler(json as? T, nil)

                case .failure(let error):
                    completionHandler(nil, error)
                }
            }
        } else {
            // 네트워크 연결 에러
            completionHandler(nil, ServiceError.network)
        }
    }
}
*/

