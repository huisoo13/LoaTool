//
//  RegisterViewModel.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/06/10.
//

import UIKit
import Alamofire
import SwiftSoup
import WebKit

class RegisterViewModel: NSObject {
    private let webView: WKWebView = {
        let preferences = WKPreferences()
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        return webView
    }()
    
    var result = Bindable<String>()

    func register(_ target: UIViewController, stove identifier: String, authentication code: String) {
        guard let url = "https://timeline.onstove.com/\(identifier)"
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                    debug("\(#file) - \(#function): URL Error")
                    return
                }
        
        guard Network.isConnected else {
            Alert.networkError(target)
            return
        }
        
        IndicatorView.showLoadingView(target, title: "인증 코드를 확인 중 입니다.")
        
        webView.navigationDelegate = self
        webView.load(URLRequest(url: URL(string: url)!))
        
        webView.accessibilityIdentifier = code
    }
}

extension RegisterViewModel: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            webView.evaluateJavaScript("document.body.innerHTML") { result, error in
                guard let html = result, error == nil else {
                    debug("\(#file) - \(#function): \(String(describing: error))")
                    Toast(image: UIImage(systemName: "exclamationmark.triangle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .thin)), title: "인증 실패", description: "알 수 없는 오류가 발생했습니다.\n 잠시 후 다시 시도해주세요.").present()
                    IndicatorView.hideLoadingView()
                    return
                }
                
                do {
                    let document = try SwiftSoup.parse(html as! String)
                    let elements: Elements = try document.select("body")
                    
                    for element in elements {
                        let code = try element.select("li:nth-child(1) > dl.module-swiper-inner > dd.inner-contents > p").text()
                        let stove = try element.select("div.info-wrapper > h2 > a").text()
                        
                        if webView.accessibilityIdentifier == code {
                            self.parsingMainCharacter(stove)
                        } else {
                            Toast(image: UIImage(systemName: "exclamationmark.triangle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .thin)), title: "인증 실패", description: "타임라인에 입력한 인증 코드가 맞지 않습니다.").present()
                            IndicatorView.hideLoadingView()
                        }
                    }
                } catch {
                    debug("\(#file) - \(#function): \(error)")
                    IndicatorView.hideLoadingView()
                }
            }
        }
    }
    
    private func parsingMainCharacter(_ nickname: String) {
        guard let url = "https://lostark.game.onstove.com/Library/Tip/UserList?searchtext=\(nickname)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            debug("\(#file) - \(#function) : URL Error")
            IndicatorView.hideLoadingView()
            return
        }
        
        AF.request(url, method: .post, encoding: URLEncoding.httpBody).responseString { (response) in
            guard let html = response.value else { return }

            do {
                let document: Document = try SwiftSoup.parse(html)
                let elements: Elements = try document.select("#lostark-wrapper")
                
                for element in elements {
                    let isInspection = try element.select("article > div > div.time_wraper > p.check_time").text().contains("점검")
                    if isInspection {
                        Toast(image: UIImage(systemName: "exclamationmark.triangle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .thin)), title: "데이터 불러오기 실패", description: "로스트아크 공식 홈페이지가 점검 중입니다.").present()
                        debug("[LOATOOL][\(DateManager.shared.currentDate())] 캐릭터 데이터 호출 실패: 로스트아크 공식 홈페이지 점검")
                        IndicatorView.hideLoadingView()
                        return
                    }
                }

                if elements.count == 0 {
                    IndicatorView.hideLoadingView()
                    return
                }
                
                for element in elements {
                    let name = try element.select("div > main > div > div.library-userinfo > div.library-userinfo__user > div > div.character-info > span.character-info__name").text()
                    IndicatorView.hideLoadingView()
                    
                    if name == "" {
                        Toast(image: UIImage(systemName: "exclamationmark.triangle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .thin)), title: "대표 캐릭터 미설정", description: "대표 캐릭터 설정이 되어있지 않습니다.\n공식 홈페이지에서 대표 캐릭터 설정 후 재시도해주세요").present()
                        debug("[LOATOOL][\(DateManager.shared.currentDate())] 캐릭터 데이터 호출 실패: 대표 캐릭터 미설정")
                        return
                    }
                    
                    self.result.value = name
                }
            } catch {
                debug("\(#file) - \(#function): \(error)")
                IndicatorView.hideLoadingView()
            }
        }
    }
}
