//
//  FaceDetectionView.swift
//  FaceDetectionView
//
//  Created by Dalton Claybrook on 2/14/17.
//  Copyright © 2017 Claybrook Software. All rights reserved.
//

import UIKit

public final class FaceDetectionView: UIView {
    
    struct ZoomFrames {
        let zoomedIn: CGRect
        let zoomedOut: CGRect
    }
    
    public var isZoomed = false {
        didSet {
            if oldValue != isZoomed {
                updateZoomFramesIfNecessary()
            }
        }
    }
    public var zoomPadding: CGFloat = 40.0 { didSet { updateZoomFramesIfNecessary() } }
    
    private let imageView = UIImageView()
    private let detector = FaceDetector()
    private var faceRect: CGRect?
    private var zoomFrames: ZoomFrames?
    
    public override var bounds: CGRect { didSet { updateZoomFramesIfNecessary() } }
    public override var frame: CGRect { didSet { updateZoomFramesIfNecessary() } }
    
    //MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupImageView()
    }
    
    //MARK: Public
    
    public func configure(with image: UIImage) {
        reset()
        imageView.image = image
        detector.detectFaces(in: image) { [weak self] (faceRects) in
            // if no faces detected, use the entire image for the face rect
            let rect = faceRects.first ?? CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            self?.configure(with: image, faceRect: rect)
        }
    }
    
    public func reset() {
        zoomFrames = nil
        faceRect = nil
        imageView.image = nil
        imageView.isHidden = true
    }
    
    //MARK: Private
    
    private func setupImageView() {
        clipsToBounds = true
        imageView.isHidden = true
        imageView.contentMode = .scaleToFill
        if imageView.superview == nil {
            insertSubview(imageView, at: 0)
        }
    }
    
    private func updateZoomFramesIfNecessary() {
        guard let image = imageView.image, let faceRect = faceRect else { return }
        configure(with: image, faceRect: faceRect)
    }
    
    private func configure(with image: UIImage, faceRect: CGRect) {
        let zoomedOutCenteredFrame = calculateZoomedOutFrame(with: image)
        let convertedFaceRect = convertFaceRect(faceRect, toImageViewFrame: zoomedOutCenteredFrame, fromImage: image).applyingPadding(zoomPadding)
        let zoomedOutAdjustedFrame = frameFromZoomedOutFrame(zoomedOutCenteredFrame, adjustedToShow: convertedFaceRect)
        let zoomedInFrame = zoomedFrameForImageView(withZoomedOutFrame: zoomedOutAdjustedFrame, faceRect: convertedFaceRect)
        
        self.faceRect = faceRect
        let zoomFrames = ZoomFrames(zoomedIn: zoomedInFrame.integral, zoomedOut: zoomedOutAdjustedFrame.integral)
        self.zoomFrames = zoomFrames
        imageView.frame = isZoomed ? zoomFrames.zoomedIn : zoomFrames.zoomedOut
        imageView.isHidden = false
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
    
    private func convertFaceRect(_ faceRect: CGRect, toImageViewFrame: CGRect, fromImage: UIImage) -> CGRect {
        let scale = toImageViewFrame.width / fromImage.size.width
        let converted = faceRect.applying(CGAffineTransform(scaleX: scale, y: scale))
        return converted
    }
    
    private func frameFromZoomedOutFrame(_ zoomedOutFrame: CGRect, adjustedToShow faceRect: CGRect) -> CGRect {
        var adjustedFrame = zoomedOutFrame
        let rectInParent = faceRect.offsetBy(dx: zoomedOutFrame.minX, dy: zoomedOutFrame.minY)
        if rectInParent.minX < 0.0 {
            adjustedFrame.origin.x += abs(rectInParent.minX)
        } else if rectInParent.maxX > bounds.maxX {
            adjustedFrame.origin.x -= (rectInParent.maxX - bounds.maxX)
        }
        
        if rectInParent.minY < 0.0 {
            adjustedFrame.origin.y += abs(rectInParent.minY)
        } else if rectInParent.maxY > bounds.maxY {
            adjustedFrame.origin.y -= (rectInParent.maxY - bounds.maxY)
        }
        return adjustedFrame
    }
    
    private func zoomedFrameForImageView(withZoomedOutFrame imageFrame: CGRect, faceRect: CGRect) -> CGRect {
        let faceRatio = faceRect.width / faceRect.height
        let viewRatio = bounds.width / bounds.height
        
        // the scale which the image will be zoomed by
        let scale = faceRatio > viewRatio ?  bounds.width / faceRect.width : bounds.height / faceRect.height
        let zoomedImageSize = CGSize(width: imageFrame.width * scale, height: imageFrame.height * scale)
        let zoomedFaceSize = CGSize(width: faceRect.width * scale, height: faceRect.height * scale)
        
        // extra padding which will need to be applied to center the image in the view bounds
        let deltas = CGSize(width: (bounds.width-zoomedFaceSize.width)/2.0, height: (bounds.height-zoomedFaceSize.height)/2.0)
        let xOffset = (faceRect.minX * scale - deltas.width) * -1.0
        let yOffset = (faceRect.minY * scale - deltas.height) * -1.0
        let zoomedFrame = CGRect(x: xOffset, y: yOffset, width: zoomedImageSize.width, height: zoomedImageSize.height)
        
        // adjust the image view frame to completely fills the view bounds (if necessary)
        return frameByCorrectingEdgeOverhang(with: zoomedFrame)
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
