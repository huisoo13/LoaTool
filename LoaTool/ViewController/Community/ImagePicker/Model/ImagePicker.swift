//
//  ImagePickerModel.swift
//  ImagePickerViewControllerSample
//
//  Created by AppDeveloper on 2021/04/12.
//

import UIKit
import Photos
import PhotosUI

struct ImagePicker {
    var identifier: String?
    var assets: [PHAsset]
}


struct Album {
    var identifier: String
    var title: String
    var asset: PHAsset
    var numberOfItem: Int
}
