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
    private var zoomedOutImageFrame: CGRect?
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
        setupViews(with: image)
        imageView.image = image
        detector.detectFaces(in: image) { [weak self] (faceRects) in
            self?.configure(with: image, faceRects: faceRects)
        }
    }
    
    //MARK: Private
    
    private func setupDebugFaceView() {
        imageView.addSubview(debugFaceView)
        debugFaceView.isHidden = true
        debugFaceView.backgroundColor = .clear
        debugFaceView.layer.borderColor = UIColor.green.cgColor
        debugFaceView.layer.borderWidth = 4.0
    }
    
    private func setupViews(with image: UIImage) {
        clipsToBounds = true
        imageView.contentMode = .scaleToFill
        if imageView.superview == nil {
            insertSubview(imageView, at: 0)
        }
        
        if case .zoomed(let frame) = zoomState {
            imageView.frame = frame
        } else {
            let frame = calculateZoomedOutFrame(with: image)
            zoomedOutImageFrame = frame
            imageView.frame = frame
        }
    }
    
    private func calculateZoomedOutFrame(with image: UIImage) -> CGRect {
        let imageRatio = image.size.width / image.size.height
        let viewRatio = bounds.width / bounds.height
        let frame: CGRect
        if imageRatio > viewRatio {
            // hanging off left and right
            let imageViewWidth = bounds.height * imageRatio
            let xOffset = (bounds.width - imageViewWidth) / 2.0
            frame = CGRect(x: xOffset, y: 0.0, width: imageViewWidth, height: bounds.height)
        } else {
            // hanging off top and bottom
            let imageViewHeight = bounds.width * imageRatio
            let yOffset = (bounds.height - imageViewHeight) / 2.0
            frame = CGRect(x: 0.0, y: yOffset, width: bounds.width, height: imageViewHeight)
        }
        return frame
    }
    
    private func configureIfNecessary() {
        guard let image = imageView.image else { return }
        configure(with: image)
    }
    
    private func configure(with image: UIImage, faceRects: [CGRect]) {
        guard let rect = faceRects.first else { return }
        let convertedRect = convertFaceRect(rect, toViewFrom: image).applyingPadding(zoomPadding)
        let adjustedImageFrame = zoomedOutImageFrameAdjustedToShow(faceRect: convertedRect)
        let zoomedFrame = zoomedFrameForImageView(with: convertedRect)
        UIView.animateKeyframes(withDuration: 2.0, delay: 0.0, options: UIViewKeyframeAnimationOptions(rawValue: 0), animations: { 
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5, animations: { 
                self.imageView.frame = adjustedImageFrame
            })
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: { 
                self.imageView.frame = zoomedFrame
            })
        }, completion: nil)
        
//        debugFaceView.frame = convertedRect
//        debugFaceView.isHidden = false
    }
    
    private func convertFaceRect(_ faceRect: CGRect, toViewFrom image: UIImage) -> CGRect {
        let scale = imageView.frame.width / image.size.width
        let converted = faceRect.applying(CGAffineTransform(scaleX: scale, y: scale))
        return converted
    }
    
    private func zoomedOutImageFrameAdjustedToShow(faceRect: CGRect) -> CGRect {
        guard var zoomedOutFrame = zoomedOutImageFrame else { return .zero }
        let rectInParent = convert(faceRect, from: imageView)
        if rectInParent.minX < 0.0 {
            zoomedOutFrame.origin.x += abs(rectInParent.minX)
        } else if rectInParent.maxX > bounds.maxX {
            zoomedOutFrame.origin.x -= (rectInParent.maxX - bounds.maxX)
        }
        
        if rectInParent.minY < 0.0 {
            zoomedOutFrame.origin.y += abs(rectInParent.minY)
        } else if rectInParent.maxY > bounds.maxY {
            zoomedOutFrame.origin.y -= (rectInParent.maxY - bounds.maxY)
        }
        return zoomedOutFrame
    }
    
    private func zoomedFrameForImageView(with faceRect: CGRect) -> CGRect {
        guard let imageFrame = zoomedOutImageFrame else { return .zero }
        let convertedRect = convert(faceRect, from: imageView)
        let faceRatio = convertedRect.width / convertedRect.height
        let viewRatio = bounds.width / bounds.height
        let scale = faceRatio > viewRatio ?  bounds.width / faceRect.width : bounds.height / faceRect.height
        let zoomedImageSize = CGSize(width: imageFrame.width * scale, height: imageFrame.height * scale)
        let zoomedFaceSize = CGSize(width: faceRect.width * scale, height: faceRect.height * scale)
        let deltas = CGSize(width: (bounds.width-zoomedFaceSize.width)/2.0, height: (bounds.height-zoomedFaceSize.height)/2.0)
        let xOffset = (faceRect.minX * scale - deltas.width) * -1.0
        let yOffset = (faceRect.minY * scale - deltas.height) * -1.0
        let zoomedFrame = CGRect(x: xOffset, y: yOffset, width: zoomedImageSize.width, height: zoomedImageSize.height)
        return frameByCorrectingEdgeOverhang(with: zoomedFrame).integral
    }
    
    private func frameByCorrectingEdgeOverhang(with rect: CGRect) -> CGRect {
        var zoomedRect = rect
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
