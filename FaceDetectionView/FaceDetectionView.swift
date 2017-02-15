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
        let convertedRect = convertRect(rect, toViewFrom: image)
        debugFaceView.isHidden = false
        debugFaceView.frame = convertedRect
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
}
