//
//  ImagePickerViewModel.swift
//  ImagePickerViewControllerSample
//
//  Created by AppDeveloper on 2021/04/12.
//

import UIKit
import Photos

class ImagePickerViewModel {
    var result = Bindable<ImagePicker>()
    var isLoading = Bindable<Bool>()
        
    private var fetchResult: PHFetchResult<PHAsset>?
    
    func configure(_ identifier: String? = nil, completionHandle: (()->())? = nil) {
        self.fetchAssets(identifier)
        completionHandle?()
    }
    
    fileprivate func fetchAssets(_ identifier: String? = nil) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        // fetchOptions.predicate = NSPredicate(format: "mediaType = %d || mediaType = %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        
        if identifier != nil && identifier != "" {
            let userLibraryCollection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
            userLibraryCollection.enumerateObjects({ collection, _, _ in
                if collection.localIdentifier == identifier {
                    self.fetchResult = PHAsset.fetchAssets(in: collection, options: fetchOptions)
                }
            })
        } else {
            let userLibraryCollection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
            userLibraryCollection.enumerateObjects({ collection, _, _ in
                self.fetchResult = PHAsset.fetchAssets(in: collection, options: fetchOptions)
            })
        }

        guard let fetchResult = self.fetchResult else { return }
        
        let assets: [PHAsset] = fetchResult.objects(at: IndexSet(0..<fetchResult.count))
        self.result.value = ImagePicker(identifier: identifier, assets: assets)
    }
    
    func getAlbumList() -> [Album] {
        var albums: [Album] = []
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        // fetchOptions.predicate = NSPredicate(format: "mediaType = %d || mediaType = %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)

        let smartAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        smartAlbum.enumerateObjects({ collection, _, _ in
            let fetchResult = PHAsset.fetchAssets(in: collection, options: fetchOptions)
            
            if fetchResult.count > 0 {
                let asset = fetchResult.object(at: 0)
                albums.append(Album(identifier: "",
                                    title: collection.localizedTitle ?? "이름 없음",
                                    asset: asset,
                                    numberOfItem: fetchResult.count))
            }
        })
        
        let album = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        album.enumerateObjects({ collection, _, _ in
            let fetchResult = PHAsset.fetchAssets(in: collection, options: fetchOptions)
            
            if fetchResult.count > 0 {
                let asset = fetchResult.object(at: 0)
                albums.append(Album(identifier: collection.localIdentifier,
                                    title: collection.localizedTitle ?? "이름 없음",
                                    asset: asset,
                                    numberOfItem: fetchResult.count))

            }
        })
                
        return albums
    }
}




