//
//  CloudManager.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/07/07.
//

import UIKit
import CloudKit
import RealmSwift
import Realm

class CloudManager {
    static let shared: CloudManager = CloudManager()

    fileprivate let container = CKContainer(identifier: "iCloud.loatool")
    fileprivate let database = CKContainer(identifier: "iCloud.loatool").privateCloudDatabase

    let realm = try! Realm()
    
    var timerForUser: Timer?
    var timerForTodo: Timer?
    
    var allowNotification: Bool = true
    var allowAccess: Bool = {
        CKContainer.default().accountStatus { accountStatus, error in
            switch accountStatus {
            case .couldNotDetermine:
                debug("iCloud 확인할 수 없음")
            case .available:
                debug("iCloud 사용 가능")
            case .restricted:
                debug("iCloud 제한됨")
            case .noAccount:
                debug("iCloud 계정 없음")
            case .temporarilyUnavailable:
                debug("iCloud 일시적으로 사용할 수 없음")
            default:
                break
            }
        }
        
        // 사용 설정
        let usingCloudKit = UserDefaults.standard.bool(forKey: "usingCloudKit")
        
        // 기기에 Apple 계정 연결이 되지 않았을 경 nil
        return FileManager.default.ubiquityIdentityToken != nil && usingCloudKit
    }()
    
    func push(_ types: [Object.Type], completionHandler: @escaping (Error?) -> Void) {
        // STEP 1: iCloud 계정 연동 확인하기
        guard allowAccess else { return }

        // STEP 2: Custom zone 생성
        let recordZones: [CKRecordZone] = types.compactMap { type in
            let zoneID = CKRecordZone.ID(zoneName: "\(type.className().firstLowercased)Zone", ownerName: CKCurrentUserDefaultName)
            return CKRecordZone(zoneID: zoneID)
        }

        // STEP 3: Custom zone 저장
        recordZonesToSave(recordZones) { error in
            guard error == nil else { return }
            
            DispatchQueue.main.async {
                // STEP 4: Record 저장
                let records = self.convertObjectToRecord(types)

                self.database.modifyRecords(saving: records, deleting: [], savePolicy: .changedKeys, atomically: true) { result in
                    switch result {
                    case .success((_, _)):
                        completionHandler(nil)
                    case .failure(let error):
                        completionHandler(error)
                    }
                }
            }
        }
    }
    
    func recordZonesToSave(_ zones: [CKRecordZone], completionHandler: @escaping (Error?) -> Void) {
        let operation = CKModifyRecordZonesOperation(recordZonesToSave: zones, recordZoneIDsToDelete: nil)
        operation.modifyRecordZonesResultBlock = { result in
            switch result {
            case .success:
                completionHandler(nil)
            case .failure(let error):
                completionHandler(error)
            }
        }

        operation.qualityOfService = .utility
        database.add(operation)
    }

    
    func convertObjectToRecord<T: Object>(_ types: [T.Type]) -> [CKRecord] {
        var records = [CKRecord]()

        for type in types {
            let objects = realm.objects(type)
            
            for object in objects {
                let recordType = object.objectSchema.className
                guard let primaryKey = object.objectSchema.primaryKeyProperty?.name else { fatalError("\(recordType) 오브젝트에 primaryKey를 설정해주세요.") }
                
                let zoneID = CKRecordZone.ID(zoneName: "\(recordType.firstLowercased)Zone", ownerName: CKCurrentUserDefaultName)
                let recordID = CKRecord.ID(recordName: object[primaryKey] as! String, zoneID: zoneID)
                let record = CKRecord(recordType: recordType, recordID: recordID)
                
                let properties = object.objectSchema.properties
                for property in properties {
                    switch property.type {
                    case .int:
                        if let value = object[property.name], !property.isArray {
                            record[property.name] = value as? CKRecordValue
                        } else if let list = object[property.name] as? List<Int>, property.isArray {
                            let value = Array(list)
                            record[property.name] = value
                        }
                    case .string:
                        if let value = object[property.name], !property.isArray {
                            record[property.name] = value as? CKRecordValue
                        } else if let list = object[property.name] as? List<String>, property.isArray {
                            let value = Array(list)
                            record[property.name] = value
                        }
                    case .bool:
                        if let value = object[property.name], !property.isArray {
                            record[property.name] = value as? CKRecordValue
                        } else if let list = object[property.name] as? List<Bool>, property.isArray {
                            let value = Array(list)
                            record[property.name] = value
                        }
                    case .float:
                        if let value = object[property.name], !property.isArray {
                            record[property.name] = value as? CKRecordValue
                        } else if let list = object[property.name] as? List<Float>, property.isArray {
                            let value = Array(list)
                            record[property.name] = value
                        }
                    case .double:
                        if let value = object[property.name], !property.isArray {
                            record[property.name] = value as? CKRecordValue
                        } else if let list = object[property.name] as? List<Double>, property.isArray {
                            let value = Array(list)
                            record[property.name] = value
                        }
                    case .data:
                        if let value = object[property.name], !property.isArray {
                            record[property.name] = value as? CKRecordValue
                        } else if let list = object[property.name] as? List<Data>, property.isArray {
                            let value = Array(list)
                            record[property.name] = value
                        }
                    case .date:
                        if let value = object[property.name], !property.isArray {
                            record[property.name] = value as? CKRecordValue
                        } else if let list = object[property.name] as? List<Date>, property.isArray {
                            let value = Array(list)
                            record[property.name] = value
                        }
                    case .object:
                        if !property.isArray {
                            guard let object = object[property.name] as? DynamicObject,
                                  let recordType = property.objectClassName else { break }
                            
                            guard let primaryKey = object.objectSchema.primaryKeyProperty?.name else { fatalError("\(recordType) 오브젝트에 primaryKey를 설정해주세요.") }
                            
                            let zoneID = CKRecordZone.ID(zoneName: "\(recordType.firstLowercased)Zone", ownerName: CKCurrentUserDefaultName)
                            let recordID = CKRecord.ID(recordName: object[primaryKey] as! String, zoneID: zoneID)
                            let reference = CKRecord.Reference(recordID: recordID, action: .none)

                            record[property.name] = reference
                        } else {
                            let objects = object.dynamicList(property.name).map { $0 }
                            
                            guard let recordType = property.objectClassName else { break }
                            guard let primaryKey = objects.first?.objectSchema.primaryKeyProperty?.name else { fatalError("\(recordType) 오브젝트에 primaryKey를 설정해주세요.") }
                            
                            let zoneID = CKRecordZone.ID(zoneName: "\(recordType.firstLowercased)Zone", ownerName: CKCurrentUserDefaultName)
                            let references: [CKRecord.Reference] = objects.map { object in
                                let recordID = CKRecord.ID(recordName: object[primaryKey] as! String, zoneID: zoneID)
                                let reference = CKRecord.Reference(recordID: recordID, action: .none)

                                return reference
                            }
                            
                            record[property.name] = references
                        }
                    default:
                        break
                    }
                }
                
                records.append(record)
            }
        }
        
        return records
    }
    
    func pull(_ types: [Object.Type], completionHandler: @escaping (Error?) -> Void) {
        // STEP 1: iCloud 계정 연동 확인하기
        guard allowAccess else { return }
        NotificationCenter.default.post(name: NSNotification.Name("beginUpdateRealmFromCloudKit"), object: nil)
        
        for type in types {
            // STEP 2: 정보 불러오기
            let predicate = NSPredicate(value: true)
            let query = CKQuery(recordType: type.className(), predicate: predicate)
            let operation = CKQueryOperation(query: query)
            operation.database = container.privateCloudDatabase
            operation.zoneID = CKRecordZone.ID(zoneName: "\(type.className().firstLowercased)Zone")
                        
            operation.recordMatchedBlock = { recordID, result in
                switch result {
                case .success(let record):
                    // STEP 3: modificationDate 확인
                    let modificationDateInCloud = record.modificationDate
                    let modificationDateInDevice = UserDefaults.standard.object(forKey: "modificationDate") as? Date
                    
                    if modificationDateInCloud != nil && modificationDateInDevice != nil, modificationDateInCloud! <= modificationDateInDevice! {
                        NotificationCenter.default.post(name: NSNotification.Name("endUpdateRealmFromCloudKit"), object: nil)
                        CloudManager.shared.update(withTimeInterval: 0)
                        return
                    }
                    
                    UserDefaults.standard.set(modificationDateInCloud, forKey: "modificationDate")

                    // STEP 4: Record 변환
                    self.convertRecordToObject(type, using: record) { object, error in
                        // STEP 5: Realm 저장
                        guard let object = object, error == nil else { return }
                        
                        DispatchQueue.main.async {
                            RealmManager.shared.delete(type)
                            RealmManager.shared.add(object)
                        }
                        
                        NotificationCenter.default.post(name: NSNotification.Name("endUpdateRealmFromCloudKit"), object: nil)
                        completionHandler(nil)
                    }
                case .failure(let error):
                    completionHandler(error)
                }
            }
            
            operation.start()
        }
    }
    
    func convertRecordToObject<T: Object>(_ type: T.Type, using record: CKRecord, completionHandler: @escaping (T?, Error?) -> Void) {
        // STEP 1: Object 생성
        let object = type.init()
        let properties = object.objectSchema.properties
        
        var propertyCount = 0
        for property in properties {
            // STEP 2: Property에 데이터 삽입
            switch property.type {
            case .int:
                guard let value = property.isArray ? record[property.name] as? Array<Int> : record[property.name] else { return }
                object[property.name] = value
                propertyCount += 1
                if propertyCount == properties.count { completionHandler(object, nil) }
            case .string, .bool, .float, .double, .data, .date:
                object[property.name] = record[property.name]
                propertyCount += 1
                if propertyCount == properties.count { completionHandler(object, nil) }
            case .object:
                // STEP 3: Reference에서 정보 불러오기
                guard let moduleName = Bundle.main.infoDictionary!["CFBundleName"] as? String,
                      let objectClassName = property.objectClassName else { return }

                let aClassName = "\(moduleName).\(objectClassName)"
                guard let type = NSClassFromString(aClassName) as? Object.Type else { return }

                var recordIDs: [CKRecord.ID] = []
                if !property.isArray {
                    guard let reference = record[property.name] as? CKRecord.Reference else { return }
                    recordIDs = [reference.recordID]
                } else {
                    guard let array = record[property.name] as? [CKRecord.Reference] else { return }
                    recordIDs = array.compactMap { $0.recordID }
                }
                
                let fetchRecordsOperation = CKFetchRecordsOperation(recordIDs: recordIDs)
                fetchRecordsOperation.database = container.privateCloudDatabase
                
                var list: [Object] = []
                var recordIDsCount = 0

                fetchRecordsOperation.perRecordResultBlock = { recordID, result in
                    switch result {
                    case .success(let record):
                        // STEP 4: 하위 오브젝트 Record 변환
                        self.convertRecordToObject(type, using: record) { subObject, error in
                            guard let subObject = subObject else { return }

                            list.append(subObject)
                            object[property.name] = property.isArray ? list : subObject

                            recordIDsCount += 1
                            if recordIDsCount == recordIDs.count { propertyCount += 1 }
                            if propertyCount == properties.count {
                                if property.isArray {
                                    // STEP 5: 하위 오브젝트에 추가로 하위 오브젝트가 있다면 데이터를 추가로 가져오기 때문에 데이터 획득 시간 차로 인하여 재정렬 필요
                                    object[property.name] = list.sorted(by: { first, second in
                                        guard let firstIdentifier = first[first.objectSchema.primaryKeyProperty?.name ?? "primaryKey"] as? String,
                                              let firstIndex = recordIDs.map({ $0.recordName }).firstIndex(of: firstIdentifier) else { return false }
                                        
                                        guard let secondIdentifier = second[second.objectSchema.primaryKeyProperty?.name ?? "primaryKey"] as? String,
                                              let secondIndex = recordIDs.map({ $0.recordName }).firstIndex(of: secondIdentifier) else { return false }

                                        return firstIndex < secondIndex
                                    })
                                }
                                
                                completionHandler(object, nil)
                            }
                        }
                    case .failure(let error):
                        recordIDsCount += 1
                        if recordIDsCount == recordIDs.count { propertyCount += 1 }
                        if propertyCount == properties.count { completionHandler(object, error) }
                    }
                }

                fetchRecordsOperation.start()
            default:
                break
            }
        }
    }
    
    // iCloud에 업데이트 되기 전에 동일 Record 업데이트 시 Error: client oplock error updating record
    // 요청한 Record의 Change Tag와 iCloud 내 Record의 Change Tag가 맞지 않아서 생기는 에러
    func update(_ type: Object.Type, recordNameWith identifier: String , data: [String: Any]) {
        // STEP 1: iCloud 계정 연동 확인하기
        guard allowAccess else { return }

        // STEP 2: 정보 불러오기
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: type.className(), predicate: predicate)
        let operation = CKQueryOperation(query: query)
        operation.database = container.privateCloudDatabase

        // STEP 3: 데이터 저장
        let zoneName = "\(type.className().firstLowercased)Zone"
        let recordID = CKRecord.ID(recordName: identifier, zoneID: CKRecordZone.ID(zoneName: zoneName))
        operation.database?.fetch(withRecordID: recordID) { record, error in
            guard let record = record, error == nil else { return }

            for (key, value) in data {
                record.setValue(value, forKey: key)
            }
            
            operation.database?.save(record) { _, error in
                debug("iCloud \(type.className()) 정보 갱신 (ERROR: \(error?.localizedDescription ?? "없음"))")
            }
        }
    }
    
    
    // Lostark
    func update(withTimeInterval: TimeInterval = 3) {
        timerForTodo?.invalidate()
        
        // STEP 1: iCloud 계정 연동 확인하기
        guard allowAccess else { return }

        // CKNotification 일시 정지
        allowNotification = false
        
        timerForTodo = Timer.scheduledTimer(withTimeInterval: withTimeInterval, repeats: false, block: { (_) in
            DispatchQueue.global(qos: .background).async {
                self.push([Todo.self, Content.self, Member.self, AdditionalContent.self]) { error in
                    guard error == nil else { return }
                    UserDefaults.standard.set(Date(), forKey: "modificationDate")
                    
                    // CKNotification 활성화
                    self.allowNotification = true
                    debug("iCloud 할 일 정보 갱신")
                }
            }
        })
        
        if withTimeInterval == 0 {
            timerForTodo?.fire()
        }
    }
    
    func commit() {
        timerForUser?.invalidate()
        
        // STEP 1: iCloud 계정 연동 확인하기
        guard allowAccess else { return }

        timerForUser = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (_) in
            // STEP 2: 정보 불러오기
            let predicate = NSPredicate(value: true)
            let query = CKQuery(recordType: "User", predicate: predicate)
            let operation = CKQueryOperation(query: query)
            operation.database = self.container.privateCloudDatabase

            // STEP 3: 데이터 저장
            operation.database?.fetch(withQuery: query, resultsLimit: 1) { result in
                switch result {
                case .success(let record):
                    if record.matchResults.count == 0 {
                        // INSERT
                        let record = CKRecord(recordType: "User", recordID: CKRecord.ID(recordName: User.shared.identifier, zoneID: CKRecordZone.default().zoneID))
                        record.setValuesForKeys([
                            "isConnected": User.shared.isConnected,
                            "identifier": User.shared.identifier,
                            "stove": User.shared.stove,
                            "name": User.shared.name,
                            "sequence": User.shared.sequence
                        ])
                        
                        operation.database?.save(record) { _, error in
                            debug("iCloud 사용자 정보 추가 (ERROR: \(error?.localizedDescription ?? "없음"))")
                        }
                    } else {
                        // UPDATE
                        guard let matchResult = record.matchResults.first else { return }
                        
                        let recordID = matchResult.0
                        operation.database?.fetch(withRecordID: recordID) { record, error in
                            guard let record = record, error == nil else { return }
                            
                            record.setValue(User.shared.isConnected, forKey: "isConnected")
                            record.setValue(User.shared.identifier, forKey: "identifier")
                            record.setValue(User.shared.stove, forKey: "stove")
                            record.setValue(User.shared.name, forKey: "name")
                            record.setValue(User.shared.sequence, forKey: "sequence")
                            
                            operation.database?.save(record) { _, error in
                                debug("iCloud 사용자 정보 갱신 (ERROR: \(error?.localizedDescription ?? "없음"))")
                            }
                        }
                    }
                case .failure(let error):
                    debug("iCloud 에러 (ERROR: \(error))")
                    
                    /* 개발 중 해당 레코드 타입이 없을때 확인해서 추가하는 코드: 레코드 타입이 있으면 필요없는 코드
                    if error.localizedDescription == "Did not find record type: User" {
                        // INSERT
                        let record = CKRecord(recordType: "User", recordID: CKRecord.ID(recordName: User.shared.identifier, zoneID: CKRecordZone.default().zoneID))
                        record.setValuesForKeys([
                            "isConnected": User.shared.isConnected,
                            "identifier": User.shared.identifier,
                            "stove": User.shared.stove,
                            "name": User.shared.name,
                            "sequence": User.shared.sequence
                        ])
                        
                        operation.database?.save(record) { _, error in
                            print("iCloud 사용자 정보 추가 (ERROR: \(error?.localizedDescription ?? "없음"))")
                        }
                    }
                     */
                }
            }
        })
    }
    

    func fetch() {
        // STEP 1: iCloud 계정 연동 확인하기
        guard allowAccess else { return }
        
        // STEP 2: 정보 불러오기
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "User", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        operation.database = container.privateCloudDatabase
        
        operation.recordMatchedBlock = { recordID, result in
            switch result {
            case .success(let record):
                guard record.value(forKey: "isConnected") as? Bool != nil else { return }
                
                User.shared.isConnected = record.value(forKey: "isConnected") as? Bool ?? false
                User.shared.identifier = record.value(forKey: "identifier") as? String ?? ""
                User.shared.stove = record.value(forKey: "stove") as? String ?? ""
                User.shared.name = record.value(forKey: "name") as? String ?? ""
                User.shared.sequence = record.value(forKey: "sequence") as? String ?? ""
                
                debug("iCloud 에서 사용자 정보 가져오기")
            case .failure(let error):
                debug("\(#function): \(error)")
            }
        }
        
        operation.start()
    }
    
    func addSubscription() {
        // STEP 1: iCloud 계정 연동 확인하기
        guard allowAccess else { return }

        // STEP 2: 변경 알림 추가
        let predicate = NSPredicate(value: true)
        let subscription = CKQuerySubscription(recordType: "User", predicate: predicate, options: .firesOnRecordUpdate)
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true

        notificationInfo.titleLocalizationKey = "%€0.96@"
        notificationInfo.titleLocalizationArgs = ["isConnected"]

        subscription.notificationInfo = notificationInfo

        database.save(subscription) { subscription, error in
            guard error == nil else { return }
            debug("iCloud 'User' 옵저버 생성")
        }
        
        let subscription2 = CKQuerySubscription(recordType: "Todo", predicate: predicate)
        let notificationInfo2 = CKSubscription.NotificationInfo()
        notificationInfo2.shouldSendContentAvailable = true

        notificationInfo2.titleLocalizationKey = "identifier"
        notificationInfo2.titleLocalizationArgs = ["identifier"]

        subscription2.notificationInfo = notificationInfo2

        database.save(subscription2) { subscription, error in
            guard error == nil else { return }
            debug("iCloud 'Todo' 옵저버 생성")
        }
    }
}


