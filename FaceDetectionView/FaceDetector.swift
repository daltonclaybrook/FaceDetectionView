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
    
    func detectFaces(in image: UIImage, completion: @escaping Completion) {
        DispatchQueue.global(qos: .background).async {
            let faceRects = self.syncDetectFaces(in: image)
            DispatchQueue.main.async {
                completion(faceRects)
            }
        }
    }
    
    func syncDetectFaces(in image: UIImage) -> [CGRect] {
        guard let image = CIImage(image: image) else { return [] }
        
        let context = CIContext()
        let detectorOptions = [ CIDetectorAccuracy : CIDetectorAccuracyHigh ]
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: context, options: detectorOptions)
        
        let features = detector?.features(in: image)
        let rects = features?.flatMap { (feature: CIFeature) -> CGRect? in
            guard let feature = feature as? CIFaceFeature else { return nil }
            return feature.bounds
        } ?? []
        return rects
    }
}
