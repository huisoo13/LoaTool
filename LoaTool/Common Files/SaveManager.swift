//
//  FileManager.swift
//  Common
//
//  Created by AppDeveloper on 2020/11/27.
//
/* Usage
 → Image
SaveManager.shared.savePhotoToLibrary(image: /* Image */) { result in
    DispatchQueue.main.async {
        // Code..
    }
}
 
 → Video
SaveManager.shared.saveMovieToLibrary(movieURL: /* URL */) { result in
    DispatchQueue.main.async {
        // Code..
    }
})
 */


import UIKit
import Photos

class SaveManager: NSObject {
    static let albumName = "로아툴" /*(Bundle.main.infoDictionary?["CFBundleName"] as? String) ?? "Other"*/
    static let shared = SaveManager()
    
    var assetCollection: PHAssetCollection!
    
    private override init() {
        super.init()
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
    }
    
    private func checkAuthorizationWithHandler(completion: @escaping ((_ success: Bool) -> Void)) {
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { (status) in
                self.checkAuthorizationWithHandler(completion: completion)
            }
        } else if PHPhotoLibrary.authorizationStatus() == .authorized {
            self.createAlbumIfNeeded { (success) in
                if success {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        } else {
            completion(false)
        }
    }
    
    private func createAlbumIfNeeded(completion: @escaping ((_ success: Bool) -> Void)) {
        if let assetCollection = fetchAssetCollectionForAlbum() {
            // Album already exists
            self.assetCollection = assetCollection
            completion(true)
        } else {
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: SaveManager.albumName)   // create an asset collection with the album name
            }) { success, error in
                if success {
                    self.assetCollection = self.fetchAssetCollectionForAlbum()
                    completion(true)
                } else {
                    // Unable to create album
                    completion(false)
                }
            }
        }
    }
    
    private func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", SaveManager.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        
        return nil
    }
    
    func savePhotoToLibrary(image: UIImage, completionHandler: @escaping (Bool) -> ()) {
        self.checkAuthorizationWithHandler { (success) in
            if success, self.assetCollection != nil {
                PHPhotoLibrary.shared().performChanges({
                    let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
                    if let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection) {
                        let enumeration: NSArray = [assetPlaceHolder!]
                        albumChangeRequest.addAssets(enumeration)
                    }
                    
                }, completionHandler: { (success, error) in
                    if success {
                        completionHandler(true)
                    } else {
                        debug("사진 저장 중 에러가 발생했습니다 → \(String(describing: error?.localizedDescription))")
                        completionHandler(false)
                    }
                })
            } else if success, self.assetCollection == nil {
                PHPhotoLibrary.shared().performChanges({
                    let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
                    if let albumChangeRequest = PHAssetCollectionChangeRequest(for: PHAssetCollection()) {
                        let enumeration: NSArray = [assetPlaceHolder!]
                        albumChangeRequest.addAssets(enumeration)
                    }
                }, completionHandler: { (success, error) in
                    if success {
                        completionHandler(true)
                    } else {
                        debug("사진 저장 중 에러가 발생했습니다 → \(String(describing: error?.localizedDescription))")
                        completionHandler(false)
                    }
                })
        } else {
                completionHandler(false)
            }
        }
    }
    
    func saveMovieToLibrary(movieURL: URL, completionHandler: @escaping (Bool) -> ()) {
        self.checkAuthorizationWithHandler { (success) in
            if success, self.assetCollection != nil {
                PHPhotoLibrary.shared().performChanges({
                    if let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: movieURL) {
                        let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
                        if let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection) {
                            let enumeration: NSArray = [assetPlaceHolder!]
                            albumChangeRequest.addAssets(enumeration)
                        }
                    }
                }, completionHandler:  { (success, error) in
                    if success {
                        completionHandler(true)
                    } else {
                        debug("영상 저장 중 에러가 발생했습니다 → \(String(describing: error?.localizedDescription))")
                        completionHandler(false)
                    }
                })
            }
        }
    }
}
