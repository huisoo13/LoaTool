//
//  ContentPreviewViewController.swift
//  ImagePickerViewControllerSample
//
//  Created by AppDeveloper on 2021/04/16.
//

import UIKit
import AVFoundation
import Photos
import MobileCoreServices
import UniformTypeIdentifiers

class ContentPreviewViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    fileprivate let imageManager = PHImageManager.default()
    
    fileprivate var playerLayer: AVPlayerLayer!
    fileprivate var queuePlayer: AVQueuePlayer!
    fileprivate var playerLooper: AVPlayerLooper!
    
    var asset: PHAsset?
    var assets: [PHAsset] = []
    var indexPath: IndexPath = IndexPath()
    
    var completionResult: Bool = false
    
    // MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPreview ()
        
        if completionResult {
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if completionResult {
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    
    // MARK:- Setup
    func setupPreview() {
        guard let asset = self.asset else { return }
        
        switch asset.mediaType {
        case .image:
            setupImage(for: asset)
        case .video:
            setupVideo(forVideo: asset)
        case.audio:
            debug("Audio")
        default:
            debug("Unknown")
        }
    }
    
    fileprivate func setupImage(for asset: PHAsset) {
        let data = ImageManager.shared.requestImageDataAndOrientation(for: asset)
        
        guard let image = UIImage(data: data.data) else { return }
        
        imageView.image = image

        let width = UIScreen.main.bounds.width
        let height = image.size.height * (width / image.size.width)
        let size = CGSize(width: width, height: height)
        preferredContentSize = size

        if data.key == "GIF" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                let gif = UIImage.gifImageWithData(data.data)
                self.imageView.image = gif
            })
        }
    }

    
    fileprivate func setupVideo(forVideo asset: PHAsset) {
        if let image = ImageManager.shared.requestImage(for: asset, isThumbnail: false) {
            self.imageView.image = image

            let width = UIScreen.main.bounds.width
            let height = image.size.height * (width / image.size.width)
            let size = CGSize(width: width, height: height)
            
            self.preferredContentSize = size
        }
        
        ImageManager.shared.requestPlayerItem(forVideo: asset) { _, item in
            guard let item = item else { return }
            
            self.queuePlayer = AVQueuePlayer(playerItem: item)
            self.playerLooper = AVPlayerLooper(player: self.queuePlayer, templateItem: item)
            self.playerLayer = AVPlayerLayer(player: self.queuePlayer)
                        
            self.playerLayer.frame = CGRect(origin: .zero, size: self.view.frame.size)
            self.playerLayer.videoGravity = .resizeAspectFill
            
            self.imageView.layer.addSublayer(self.playerLayer)
            self.queuePlayer.preventsDisplaySleepDuringVideoPlayback = true
            
            self.queuePlayer.isMuted = true
            self.queuePlayer.play()
        }
    }
}
