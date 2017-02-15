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
    
    override var bounds: CGRect { didSet { configureIfNecessary() } }
    
    //MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
    
    private func setupViews() {
        clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        if imageView.superview == nil {
            addSubview(imageView)
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
        
    }
    
    private func convertRect(_ rect: CGRect, toViewFrom image: UIImage) -> CGRect {
        let imageRatio = image.size.width / image.size.height
        let viewRatio = bounds.width / bounds.height
        if imageRatio > viewRatio {
            print("hanging off sides")
        } else {
            print("hanging off top/bototm")
        }
        return rect
    }
}
