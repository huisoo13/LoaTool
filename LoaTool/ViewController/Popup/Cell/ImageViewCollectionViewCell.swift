//
//  ImageViewCollectionViewCell.swift
//  LoaTool
//
//  Created by Trading Taijoo on 2022/05/04.
//


import UIKit

protocol ImageViewerDelegate {
    func imageViewer(_ imageView: UIImageView, isZooming: Bool)
}

class ImageViewCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var delegate: ImageViewerDelegate?
    var image: UIImage? {
        didSet {
            guard let image = image else { return }
            
            imageView.image = image
        }
    }
    
    var imageURL: String? {
        didSet {
            guard let imageURL = imageURL else {
                return
            }
 
            imageView.kf.setImage(with: URL(string: "http://15.164.244.43/\(imageURL)"),
                                         options: [
                                            .scaleFactor(UIScreen.main.scale),
                                            .transition(.fade(1))
                                         ])
        }
    }
    
    var profileURL: String? {
        didSet {
            guard let profileURL = profileURL else {
                return
            }
 

            imageView.kf.setImage(with: URL(string: profileURL),
                                         options: [
                                            .transition(.fade(1))
                                         ])
        }
    }
    
    // the view that will be overlayed, giving a back transparent look
    var overlayView: UIView!
    
    // a property representing the maximum alpha value of the background
    let maxOverlayAlpha: CGFloat = 0.8
    // a property representing the minimum alpha value of the background
    let minOverlayAlpha: CGFloat = 0.4
    
    // the initial center of the pinch
    var initialCenter: CGPoint?
    // the view to be added to the Window
    var windowImageView: UIImageView?
    // the origin of the source imageview (in the Window coordinate space)
    var startingRect = CGRect.zero

    
    override func awakeFromNib() {
        super.awakeFromNib()

        imageView.isUserInteractionEnabled = true
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(gestureRecognizer(_:)))
        
        imageView.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    @objc func gestureRecognizer(_ sender: UIPinchGestureRecognizer) {
        guard let window = UIApplication.shared.connectedScenes.flatMap({ ($0 as? UIWindowScene)?.windows ?? [] }).first(where: { $0.isKeyWindow }) else { return }
        
        if sender.state == .began {
            // the current scale is the aspect ratio
            let currentScale = self.imageView.frame.size.width / self.imageView.bounds.size.width
            // the new scale of the current `UIPinchGestureRecognizer`
            let newScale = currentScale * sender.scale
            
            // if we are really zooming
            if newScale > 1 {
                // inform listeners that we are zooming, to stop them scrolling the UICollectionView
                self.delegate?.imageViewer(imageView, isZooming: true)

                // setup the overlay to be the same size as the window
                overlayView = UIView.init(
                    frame: CGRect(
                        x: 0,
                        y: 0,
                        width: (window.frame.size.width),
                        height: (window.frame.size.height)
                    )
                )

                // set the view of the overlay as black
                overlayView.backgroundColor = UIColor.black

                // set the minimum alpha for the overlay
                overlayView.alpha = CGFloat(minOverlayAlpha)

                // add the subview to the overlay
                window.addSubview(overlayView)

                // set the center of the pinch, so we can calculate the later transformation
                initialCenter = sender.location(in: window)
                
                // set the window Image view to be a new UIImageView instance
                windowImageView = UIImageView.init(image: self.imageView.image)

                // set the contentMode to be the same as the original ImageView
                windowImageView!.contentMode = .scaleAspectFit

                // Do not let it flow over the image bounds
                windowImageView!.clipsToBounds = true

                // since the to view is nil, this converts to the base window coordinates.
                // so where is the origin of the imageview, in the main window
                let point = self.imageView.convert(
                    imageView.frame.origin,
                    to: nil
                )

                // the location of the imageview, with the origin in the Window's coordinate space
                startingRect = CGRect(
                    x: point.x,
                    y: point.y,
                    width: imageView.frame.size.width,
                    height: imageView.frame.size.height
                )

                // set the frame for the image to be added to the window
                windowImageView?.frame = startingRect

                // add the image to the Window, so it will be in front of the navigation controller
                window.addSubview(windowImageView!)

                // hide the original image
                imageView.isHidden = true
            }
        } else if sender.state == .changed {
            if sender.numberOfTouches < 2 { return }
            
            // if we don't have a current window, do nothing. Ensure the initialCenter has been set
            guard let initialCenter = initialCenter,
                  let windowImageWidth = windowImageView?.frame.size.width
            else { return }

            // Calculate new image scale.
            let currentScale = windowImageWidth / startingRect.size.width

            // the new scale of the current `UIPinchGestureRecognizer`
            let newScale = currentScale * sender.scale

            // Calculate new overlay alpha, so there is a nice animated transition effect
            overlayView.alpha = minOverlayAlpha + (newScale - 1) < maxOverlayAlpha ? minOverlayAlpha + (newScale - 1) : maxOverlayAlpha

            // calculate the center of the pinch
            let pinchCenter = CGPoint(
                x: sender.location(in: window).x - (window.bounds.midX),
                y: sender.location(in: window).y - (window.bounds.midY)
            )
            
            // calculate the zoomscale
            let zoomScale = (newScale * windowImageWidth >= imageView.frame.width) ? newScale : currentScale

            
            // calculate the difference between the inital centerX and new centerX
            let centerXDif = initialCenter.x - sender.location(in: window).x
            // calculate the difference between the intial centerY and the new centerY
            let centerYDif = initialCenter.y - sender.location(in: window).y

            // transform scaled by the zoom scale
            let transform = window.transform
                .translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                .scaledBy(x: zoomScale, y: zoomScale)
                .translatedBy(x: -centerXDif, y: -centerYDif)
                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)

            // apply the transformation
            windowImageView?.transform = transform
                        
            // Reset the scale
            sender.scale = 1
        } else if sender.state == .ended || sender.state == .failed || sender.state == .cancelled {
            guard let windowImageView = self.windowImageView else { return }

            // animate the change when the pinch has finished
            UIView.animate(withDuration: 0.3, animations: {
                // make the transformation go back to the original
                windowImageView.transform = CGAffineTransform.identity
                self.overlayView.alpha = 0
            }, completion: { _ in

                // remove the imageview from the superview
                windowImageView.removeFromSuperview()

                // remove the overlayview
                self.overlayView.removeFromSuperview()

                // make the original view reappear
                self.imageView.isHidden = false

                // tell the collectionview that we have stopped
                self.delegate?.imageViewer(self.imageView, isZooming: false)
            })
        }
    }
}
