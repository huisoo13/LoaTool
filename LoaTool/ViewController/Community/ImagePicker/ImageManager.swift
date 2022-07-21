//
//  ImageManager.swift
//  ImagePickerViewControllerSample
//
//  Created by Trading Taijoo on 2022/04/27.
//

import UIKit
import AVFoundation
import Photos
import MobileCoreServices
import UniformTypeIdentifiers

class ImageManager {
    static let shared = ImageManager()

    private let imageManager = PHCachingImageManager()
    
    func requestImage(for asset: PHAsset, isThumbnail: Bool) -> UIImage? {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true

        let width: CGFloat = asset.pixelWidth > asset.pixelHeight ? 300 : CGFloat(asset.pixelWidth) * (300 / CGFloat(asset.pixelHeight))
        let height: CGFloat = asset.pixelWidth > asset.pixelHeight ? CGFloat(asset.pixelHeight) * (300 / CGFloat(asset.pixelWidth)) : 300
        let size = isThumbnail
        ? CGSize(width: width, height: height)
        : CGSize(width: asset.pixelWidth, height: asset.pixelHeight)

        var image: UIImage?
        
        imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) { (originalImage, info) in
            guard let fixOrientationOfImage = originalImage?.fixOrientationOfImage() else { return }
            
            image = fixOrientationOfImage
        }
        
        return image
    }
    
    func requestImageDataAndOrientation(for asset: PHAsset) -> (key: String, data: Data) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true

        var key = ""
        var value = Data()
        
        imageManager.requestImageDataAndOrientation(for: asset, options: options, resultHandler: { (imageData, UTI, _, _) in
            guard let data = imageData else  { return }
            value = data

            guard let uti = UTI, let type = UTType(uti) else { return }
            key = type.conforms(to: UTType.gif) ? "GIF" : "OTHER"
        })
                                                       
        return (key, value)

    }
    
    func requestPlayerItem(forVideo asset: PHAsset, completionHandler: @escaping (_ thumbnail: UIImage?, _ item: AVPlayerItem?) -> Void)  {
        let options = PHVideoRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        let image = requestImage(for: asset, isThumbnail: false)
        
        imageManager.requestPlayerItem(forVideo: asset, options: options) { item, _ in
            completionHandler(image, item)
        }
    }
}
