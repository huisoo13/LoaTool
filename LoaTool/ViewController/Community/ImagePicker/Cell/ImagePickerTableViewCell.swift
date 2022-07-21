//
//  ImagePickerTableViewCell.swift
//  ImagePickerViewControllerSample
//
//  Created by Trading Taijoo on 2022/04/26.
//

import UIKit
import Photos
import PhotosUI
import MobileCoreServices

class ImagePickerTableViewCell: UITableViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    
    var data: Album? {
        didSet {
            guard let data = data else {
                return
            }

            self.thumbnailImageView.image = ImageManager.shared.requestImage(for: data.asset, isThumbnail: true)
            
            label.text = "\(data.title) (\(data.numberOfItem))"
        }
    }
    
    var isSelectedAlbum: Bool? {
        didSet {
            guard let isSelectedAlbum = isSelectedAlbum else {
                return
            }

            checkImageView.isHidden = !isSelectedAlbum
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        checkImageView.isHidden = true
        thumbnailImageView.layer.cornerRadius = 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
