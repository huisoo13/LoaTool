//
//  AppDelegate.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2021/07/19.
//

import UIKit
import UserNotifications
import RealmSwift
import CloudKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    // 테스트
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Local Database form Migration for Realm
        migrationForRealm()
        
        // Set up CloudKit
        setupCloudKit()
        
        // Request authorization for APNS
        requestAuthorizationForNotification(application)
        
        // Adjust spacing between Navigation bar button items
        let stackViewAppearance = UIStackView.appearance(whenContainedInInstancesOf: [UINavigationBar.self])
        stackViewAppearance.spacing = -5
        
        // Add network state checking observer
        Network.shared.addObserverNetwork()
        
        // Setup notification center
        UNUserNotificationCenter.current().delegate = self
                
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

// MARK: - Push notification
extension AppDelegate: UNUserNotificationCenterDelegate {
    func requestAuthorizationForNotification(_ application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            guard granted else { return }
            
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        
        DispatchQueue.global(qos: .background).async {
            API.post.updateToken(token) { result in
                debug("[LOATOOL][\(DateManager.shared.currentDate())] 토큰 갱신")
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debug("\(#function): \(error)")
    }
    
    // 앱이 foreground상태 일 때, 알림이 온 경우
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        debug(userInfo)
        
        completionHandler([.list, .banner])
    }
    
    // 알림을 누른 경우
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        completionHandler()
        
        guard let payload = userInfo["aps"] as? [String: AnyObject],
              let category = payload["category"] as? String else { return }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate else { return }
        
        switch category {
        case "LOATOOL_NOTIFICATION":
            sceneDelegate.coordinator?.pushToNotificationViewController(animated: true)
        case "OTHER":
            // 나중에 무언가 추가되면 이런식으로 추가하기
            break
        default:
            break
        }
    }
}

// MARK: - CloudKit
extension AppDelegate {
    func setupCloudKit() {
        CloudManager.shared.pull([Todo.self]) { error in
            guard error == nil else { return }
            debug("[LOATOOL][\(DateManager.shared.currentDate())] iCloud 할 일 정보 가져오기 완료")
        }
    
        CloudManager.shared.fetch()
        CloudManager.shared.addSubscription()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let _ = CKNotification(fromRemoteNotificationDictionary: userInfo) {
            guard let payload = userInfo["ck"] as? [String: AnyObject],
                  let query = payload["qry"] as? [String: AnyObject] else { return }

            // let recordName = query["rid"] as? String ?? ""
            let zoneName = query["zid"] as? String ?? ""

            // print(recordName)
            // print(zoneName)
            
            switch zoneName {
            case "todoZone":
                CloudManager.shared.pull([Todo.self]) { error in
                    guard error == nil else { return }
                    debug("[LOATOOL][\(DateManager.shared.currentDate())] iCloud 할 일 정보 가져오기 완료")
                }
            default:
                CloudManager.shared.fetch()
            }

            completionHandler(.noData)
        }
    }
}


// MARK: - Realm
extension AppDelegate {
    func migrationForRealm() {
        let oldSchemaVersion = UserDefaults.standard.integer(forKey: "oldSchemaVersion")
        let newSchemaVersion = 8
        
        let configuration = Realm.Configuration(
            schemaVersion: UInt64(newSchemaVersion),
            migrationBlock: { migration, oldSchemaVersion in
                debug("업데이트 시작")
                if oldSchemaVersion < newSchemaVersion {
                    UserDefaults.standard.set(newSchemaVersion, forKey: "oldSchemaVersion")
                }
            },
            deleteRealmIfMigrationNeeded: true
        )
        
        Realm.Configuration.defaultConfiguration = configuration
        
        if oldSchemaVersion != newSchemaVersion {
            debug("업데이트 종료")
            UserDefaults.standard.set(newSchemaVersion, forKey: "oldSchemaVersion")
        }
        
        debug("\(#function): \(RealmManager.shared.getDocumentsDirectory())")
    }
}

