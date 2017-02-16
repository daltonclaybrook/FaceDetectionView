//
//  FaceDetectionView.swift
//  FaceDetectionView
//
//  Created by Dalton Claybrook on 2/14/17.
//  Copyright © 2017 Claybrook Software. All rights reserved.
//

import UIKit

class FaceDetectionView: UIView {
    enum ZoomState {
        case notZoomed
        case zoomed(CGRect)
    }
    
    private let imageView = UIImageView()
    private let detector = FaceDetector()
    private var zoomState = ZoomState.notZoomed
    private var zoomPadding: CGFloat = 40.0
    private let debugFaceView = UIView()
    
    override var bounds: CGRect { didSet { configureIfNecessary() } }
    
    //MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDebugFaceView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDebugFaceView()
    }
    
    //MARK: Public
    
    func setIsZoomed(_ zoomed: Bool, animated: Bool) {
        //TODO
    }
    
    func configure(with image: UIImage) {
        setupViews()
        imageView.image = image
        detector.detectFaces(in: image) { [weak self] (faceRects) in
            self?.configure(with: image, faceRects: faceRects)
        }
    }
    
    //MARK: Private
    
    private func setupDebugFaceView() {
        addSubview(debugFaceView)
        debugFaceView.isHidden = true
        debugFaceView.backgroundColor = .clear
        debugFaceView.layer.borderColor = UIColor.green.cgColor
        debugFaceView.layer.borderWidth = 4.0
    }
    
    private func setupViews() {
        clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        if imageView.superview == nil {
            insertSubview(imageView, at: 0)
        }
        
        if case .zoomed(let frame) = zoomState {
            imageView.frame = frame
        } else {
            imageView.frame = bounds
        }
    }
    
    private func configureIfNecessary() {
        guard let image = imageView.image else { return }
        configure(with: image)
    }
    
    private func configure(with image: UIImage, faceRects: [CGRect]) {
        guard let rect = faceRects.first else { return }
        let convertedRect = convertRect(rect, toViewFrom: image).applyingPadding(zoomPadding)
//        debugFaceView.frame = convertedRect
//        debugFaceView.isHidden = false
        
        let zoomedFrame = zoomedFrameForImageView(with: convertedRect)
        UIView.animate(withDuration: 1.0) {
            self.imageView.frame = zoomedFrame
        }
    }
    
    private func convertRect(_ rect: CGRect, toViewFrom image: UIImage) -> CGRect {
        let imageRatio = image.size.width / image.size.height
        let viewRatio = bounds.width / bounds.height
        
        if imageRatio > viewRatio {
            // hanging off left and right
            let scale = bounds.height / image.size.height
            let converted = rect.applying(CGAffineTransform(scaleX: scale, y: scale)).integral
            let actualWidth = bounds.height * image.size.width / image.size.height
            let xPadding = (actualWidth - bounds.width) / 2.0
            return converted.offsetBy(dx: -xPadding, dy: 0.0)
        } else {
            // hanging off top and bottom
            let scale = bounds.width / image.size.width
            let converted = rect.applying(CGAffineTransform(scaleX: scale, y: scale)).integral
            let actualHeigth = bounds.width * image.size.height / image.size.width
            let yPadding = (actualHeigth - bounds.height) / 2.0
            return converted.offsetBy(dx: 0.0, dy: -yPadding)
        }
    }
    
    private func zoomedFrameForImageView(with faceRect: CGRect) -> CGRect {
        let faceRatio = faceRect.width / faceRect.height
        let viewRatio = bounds.width / bounds.height
        var zoomedRect = bounds
        
        if faceRatio > viewRatio {
            // pin left and right to view
            let zoomScale = bounds.width / faceRect.width
            let faceRectZoomedHeight = faceRect.height * zoomScale
            let xOffset = (faceRect.minX * zoomScale) * -1.0
            
            // space between the top of the screen and the top edge of the face rect
            let yPadding = (bounds.height - faceRectZoomedHeight) / 2.0
            
            // space between the top of the image view and the top edge of the face rect, minus the xPadding.
            let yOffset = (faceRect.minY * zoomScale - yPadding) * -1.0
            
            zoomedRect = CGRect(x: xOffset, y: yOffset, width: bounds.width * zoomScale, height: bounds.height * zoomScale)
        } else {
            // pin top and bottom to view
            let zoomScale = bounds.height / faceRect.height
            let faceRectZoomedWidth = faceRect.width * zoomScale
            let yOffset = (faceRect.minY * zoomScale) * -1.0
            
            // space between the left side of the screen and the left edge of the face rect
            let xPadding = (bounds.width - faceRectZoomedWidth) / 2.0
            
            // space between the left side of the image view and the left edge of the face rect, minus the xPadding.
            let xOffset = (faceRect.minX * zoomScale - xPadding) * -1.0
            
            zoomedRect = CGRect(x: xOffset, y: yOffset, width: bounds.width * zoomScale, height: bounds.height * zoomScale)
        }
        
        // correct view edge padding
        if zoomedRect.minY > 0 {
            zoomedRect.origin.y = 0.0
        } else if zoomedRect.maxY < bounds.maxY {
            zoomedRect.origin.y = bounds.height - zoomedRect.height
        }
        
        if zoomedRect.minX > 0 {
            zoomedRect.origin.x = 0.0
        } else if zoomedRect.maxX < bounds.maxX {
            zoomedRect.origin.x = bounds.width - zoomedRect.width
        }
        
        return zoomedRect
    }
}

extension CGRect {
    func applyingPadding(_ padding: CGFloat) -> CGRect {
        return CGRect(x: self.minX-padding, y: self.minY-padding, width: self.width+padding*2, height: self.height+padding*2)
    }
}
