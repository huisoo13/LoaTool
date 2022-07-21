//
//  ImagePickerCollectionViewCell.swift
//  ImagePickerViewControllerSample
//
//  Created by AppDeveloper on 2021/04/12.
//

import UIKit
import AVFoundation
import Photos
import PhotosUI
import MobileCoreServices

class ImagePickerCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var durationLabel: PaddingLabel!
    @IBOutlet weak var extensionLabel: PaddingLabel!
    @IBOutlet weak var badgeImageView: UIImageView!
    
    var representedAssetIdentifier: String?
    var asset: PHAsset! {
        didSet {
            imageView.contentMode = .scaleAspectFill
            if representedAssetIdentifier == asset.localIdentifier {
                self.imageView.image = ImageManager.shared.requestImage(for: asset, isThumbnail: true)
            }

            let time = CMTime(seconds: asset.duration, preferredTimescale: 1000000)
            durationLabel.text = time.positionalTime

            durationLabel.isHidden = asset.mediaType != .video
            extensionLabel.isHidden = true
        }
    }
    
    var selectedNumber: Int? {
        didSet {
            guard let selectedNumber = selectedNumber else {
                badgeImageView.isHidden = true
                return
            }
            
            badgeImageView.isHidden = false
            badgeImageView.image = UIImage(systemName: "\(selectedNumber + 1).circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .light))
        }
    }
    
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }, completion: { result in
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                    self.transform = CGAffineTransform(scaleX: 1, y: 1)
                })
            })
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupLabel()
    }

    fileprivate func setupLabel() {
        extensionLabel.layer.cornerRadius = extensionLabel.bounds.height / 2
        extensionLabel.clipsToBounds = true
        
        badgeImageView.layer.cornerRadius = badgeImageView.bounds.height / 2
        badgeImageView.backgroundColor = UIColor.white
    }
}
