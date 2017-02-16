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
//        faceDetectorView.frame = CGRect(x: 40, y: 40, width: 150, height: 190)
        faceDetectorView.frame = CGRect(x: 40, y: 40, width: 295, height: 374)
        faceDetectorView.isZoomed = true
        
        let image = UIImage(named: "profile3_flip")!
        faceDetectorView.configure(with: image)
        
        let wideFrame = CGRect(x: 0.0, y: 100, width: UIApplication.shared.statusBarFrame.width, height: 230)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            UIView.animate(withDuration: 1.0, animations: { 
//                self.faceDetectorView.isZoomed = false
//                self.faceDetectorView.frame = wideFrame
                self.faceDetectorView.zoomPadding = 100.0
            })
        }
    }
}

