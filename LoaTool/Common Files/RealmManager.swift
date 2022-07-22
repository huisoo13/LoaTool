//
//  RealmMamager.swift
//  SwiftSoupSamle
//
//  Created by Trading Taijoo on 2021/11/03.
//

import UIKit
import RealmSwift

class RealmManager {
    static let shared = RealmManager()
    
    let realm = try! Realm()

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    // MARK:- WRITE
    func add(_ data: Object) {
        do {
            try realm.write {
                realm.add(data, update: .all)
            }
            
            if data is Character { return }
            /// 수정 - 001
            // CloudManager.shared.update()
        } catch {
            debug("Write Error: \(error)")
        }
    }
    
    func add(_ data: [Object]) {
        do {
            try realm.write {
                realm.add(data, update: .all)
            }
            
            if data.first is Character { return }
            /// 수정 - 001
            // CloudManager.shared.update()
        } catch {
            debug("Write Error: \(error)")
        }
    }
    
    /*
     RealmManager.shared.add(/*Object*/)
     */
    

    // MARK:- READ
    func readAll<T: Object>(_ object: T.Type) -> Results<T> {
        let object = realm.objects(object)
        
        return object
    }
    
    func read<T: Object>(_ object: T.Type, filter: String) -> Results<T> {
        let object = realm.objects(object).filter(filter)
        return object
    }
    
    func read<T: Object>(_ object: T.Type, identifier: String) -> Results<T> {
        let object = realm.objects(object).filter("identifier == \"\(identifier)\"")
        return object
    }
    
    // MARK:- UPDATE
    func update(_ handler: @escaping () -> Void) {
        do {
            try realm.write {
                handler()
            }
            
            /// 수정 - 001
            // CloudManager.shared.update()
        } catch {
            debug("Update Error: \(error)")
        }
    }
    
    /*
     func readAll<T: Object>(_ object: T.Type) -> Results<T> {
         let object = realm.objects(object)
         return object
     }
     
     func update(_ handler: @escaping () -> Void) {
         do {
             try realm.write {
                 handler()
             }
         } catch {
             print("Update Error: \(error)")
         }
     }
     
     RealmManager.shared.update {
        let object = RealmManager.shared.readAll(Object.self)
        object.forEach {
            $0.value = 0
        }
        
        object.first?.value = 12
     }
     */
    
    // MARK:- DELETE
    func delete(_ object: Object?) {
        if let object = object {
            do {
                if realm.isInWriteTransaction {
                    realm.delete(object)
                } else {
                    try realm.write {
                        realm.delete(object)
                    }
                }
                
                /// 수정 - 001
                // CloudManager.shared.update()
            } catch {
                debug("Delete Error: \(error)")
            }
        }
    }
    
    func delete<T: Object>(_ object: Results<T>) {
        do {
            if realm.isInWriteTransaction {
                realm.delete(object)
            } else {
                try realm.write {
                    realm.delete(object)
                }
            }
            
            /// 수정 - 001
            // CloudManager.shared.update()
        } catch {
            debug("Delete Error: \(error)")
        }
    }
    
    func delete<T: Object>(_ object: List<T>) {
        do {
            if realm.isInWriteTransaction {
                realm.delete(object)
            } else {
                try realm.write {
                    realm.delete(object)
                }
            }
            
            /// 수정 - 001
            // CloudManager.shared.update()
        } catch {
            debug("Delete Error: \(error)")
        }
    }
    
    func delete<T: Object>(_ object: T.Type) {
        do {
            let object = readAll(object)

            if realm.isInWriteTransaction {
                realm.delete(object)
            } else {
                try realm.write {
                    realm.delete(object)
                }
            }
            
            /// 수정 - 001
            // CloudManager.shared.update()
        } catch {
            debug("Delete Error: \(error)")
        }
    }
    
    
    func deleteAll() {
        do {
            if realm.isInWriteTransaction {
                realm.deleteAll()
            } else {
                try realm.write {
                    realm.deleteAll()
                }
            }
            
            /// 수정 - 001
            // CloudManager.shared.update()
        } catch {
            debug("Delete Error: \(error)")
        }
    }
}
