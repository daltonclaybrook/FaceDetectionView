//
//  FaceDetector.swift
//  FaceDetectionView
//
//  Created by Dalton Claybrook on 2/14/17.
//  Copyright © 2017 Claybrook Software. All rights reserved.
//

import UIKit
import CoreImage
import ImageIO

class FaceDetector {
    typealias Completion = (_ faceRects: [CGRect]) -> ()
    private(set) var isDetecting = false
    
    func detectFaces(in image: UIImage, completion: @escaping Completion) {
        guard !isDetecting else { assertionFailure("FaceDetector is already detecting"); return }
        isDetecting = true
        DispatchQueue.global(qos: .background).async {
            let faceRects = self.syncDetectFaces(in: image)
            DispatchQueue.main.async {
                isDetecting = false
                completion(faceRects)
            }
        }
    }
    
    func syncDetectFaces(in image: UIImage) -> [CGRect] {
        let imageSize = image.size
        guard let image = CIImage(image: image) else { return [] }
        
        let detectorOptions = [ CIDetectorAccuracy : CIDetectorAccuracyHigh ]
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: detectorOptions)
        
        let features = detector?.features(in: image)
        let rects = features?.flatMap { (feature: CIFeature) -> CGRect? in
            guard let feature = feature as? CIFaceFeature else { return nil }
            return feature.bounds.applying(CGAffineTransform(scaleX: 1.0, y: -1.0)).offsetBy(dx: 0.0, dy: imageSize.height)
        } ?? []
        return rects
    }
}
