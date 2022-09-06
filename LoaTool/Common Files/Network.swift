//
//  Network.swift
//  Sample
//
//  Created by Trading Taijoo on 2021/05/31.
//

/* Usage
 네트워크 연결상태 실시간 확인
 → application(_:didFinishLaunchingWithOptions:)
 → Network.shared.addObserverNetwork() 입력
 
 현재 네트워크 연결 상태 확인
 → Network.isConnected
 
 현재 Wifi 연결 상태 확인
 → Network.isConnectedToWifi
 */

import UIKit
import SystemConfiguration
import Network

class Network {
    static let shared = Network()
    static let nwPathMonitor = NWPathMonitor()

    // 현재 네트워크 연결 상태 확인
    static var isConnected: Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        return ret
    }
    
    static var isConnectedToWifi: Bool = false

    // 네트워크 상태 변동 실시간 확인
    func addObserverNetwork() {
        Network.nwPathMonitor.pathUpdateHandler = { path in
            if path.usesInterfaceType(.wifi) {
                // Correctly goes to Wi-Fi via Access Point or Phone enabled hotspot
                debug("Wi-Fi를 이용하여 네트워크에 연결되었습니다.")
                Network.isConnectedToWifi = true
            } else if path.usesInterfaceType(.cellular) {
                debug("셀룰러 데이터를 이용하여 네트워크에 연결되었습니다.")
                Network.isConnectedToWifi = false
            } else if path.usesInterfaceType(.wiredEthernet) {
                debug("유선 이더넷을 이용하여 네트워크에 연결되었습니다.")
                Network.isConnectedToWifi = false
            } else if path.usesInterfaceType(.loopback) {
                debug("루프백을 이용하여 네트워크에 연결되었습니다.")
                Network.isConnectedToWifi = false
            } else if path.usesInterfaceType(.other) {
                debug("기타 방법을 이용하여 네트워크에 연결되었습니다.")
                Network.isConnectedToWifi = false
            } else {
                debug("네트워크에 연결할 수 없습니다.")
                Network.isConnectedToWifi = false
            }
        }
        
        Network.nwPathMonitor.start(queue: .main)
    }
    
    func removeObserverNetWork() {
        Network.nwPathMonitor.cancel()
    }
}
