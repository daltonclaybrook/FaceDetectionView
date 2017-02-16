//
//  ViewController.swift
//  FaceDetectionView
//
//  Created by Dalton Claybrook on 2/14/17.
//  Copyright © 2017 Claybrook Software. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var faceDetectorView: FaceDetectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let image = UIImage(named: "profile3")!
        let image = UIImage(named: "profile3_flip")!
        faceDetectorView.configure(with: image)
    }
}

