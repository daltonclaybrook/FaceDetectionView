//
//  ViewController.swift
//  FaceDetectionView
//
//  Created by Dalton Claybrook on 2/14/17.
//  Copyright © 2017 Claybrook Software. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let faceDetectorView = FaceDetectionView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(faceDetectorView)
        faceDetectorView.backgroundColor = .green
        faceDetectorView.frame = CGRect(x: 40, y: 40, width: 150, height: 190)
        faceDetectorView.isZoomed = true
        
        let image = UIImage(named: "profile3")!
        faceDetectorView.configure(with: image)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapGestureRecognized(_:)))
        faceDetectorView.addGestureRecognizer(gesture)
    }
    
    @objc private func tapGestureRecognized(_ gesture: UITapGestureRecognizer) {
        gesture.isEnabled = false
        let wideFrame = CGRect(x: 0.0, y: 100, width: UIApplication.shared.statusBarFrame.width, height: 230)
        UIView.animate(withDuration: 1.0, animations: {
            self.faceDetectorView.isZoomed = false
            self.faceDetectorView.frame = wideFrame
        })
    }
}

