/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import Vision

class FaceView: UIView {
    var leftEye: [CGPoint] = []
    var rightEye: [CGPoint] = []
    var leftEyebrow: [CGPoint] = []
    var rightEyebrow: [CGPoint] = []
    var nose: [CGPoint] = []
    var outerLips: [CGPoint] = []
    var innerLips: [CGPoint] = []
    var faceContour: [CGPoint] = []
    var leftPupil:CGPoint = CGPoint.zero
    var rightPupil:CGPoint = CGPoint.zero
    var allLandmarks: [CGPoint] = []
    var boundingBox = CGRect.zero
    var isInitBoxShow = true
    var isShowingFace = true
    var textNotification:CATextLayer = CATextLayer()
    var blockLayer:CALayer!
    
    func clear() {
        leftEye = []
        rightEye = []
        leftEyebrow = []
        rightEyebrow = []
        nose = []
        outerLips = []
        innerLips = []
        faceContour = []
        leftPupil = CGPoint.zero
        rightPupil = CGPoint.zero
        
        boundingBox = .zero
        
        
        
        DispatchQueue.main.async {
            
            self.setNeedsDisplay()
        }
    }
    
    func isAllFaceLandmarksAvailable() -> Bool{
        
        if leftEye.isEmpty, rightEye.isEmpty, nose.isEmpty, leftEyebrow.isEmpty
            ,rightEyebrow.isEmpty, outerLips.isEmpty, innerLips.isEmpty, faceContour.isEmpty{
            return false
        }
        
        return true
    }
    
    override func draw(_ rect: CGRect) {
        
        // 1
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        // 2
        context.saveGState()
        
        // 3
        defer {
            context.restoreGState()
        }
        
        
        // 4
        //context.addRect(boundingBox)
        
        // 5
        //UIColor.red.setStroke()
        
        // 6
        //context.strokePath()
        
        if isInitBoxShow{
            
            let xPosition = self.frame.width
            let yPosition = self.frame.height
   
            blockLayer = CALayer()
            blockLayer.frame = self.frame
            blockLayer.rasterizationScale = UIScreen.main.scale
            self.layer.addSublayer(blockLayer)
            
            let radius: CGFloat = blockLayer.frame.width
            let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: blockLayer.frame.width, height: blockLayer.frame.height), cornerRadius: 0)
            let circlePath = UIBezierPath(roundedRect: CGRect(x: xPosition / 3, y: yPosition / 4, width: xPosition / 4, height: yPosition / 2 + yPosition / 6), cornerRadius: radius )
            path.append(circlePath)
            path.usesEvenOddFillRule = true
            
            let faceArea = CAShapeLayer()
            faceArea.frame = blockLayer.bounds
            faceArea.path = path.cgPath
            faceArea.fillRule = .evenOdd
            faceArea.fillColor = UIColor.black.cgColor
            if !isGreen {
                faceArea.strokeColor = UIColor.red.cgColor
            }
            else {
                faceArea.strokeColor = UIColor.green.cgColor
            }
            //faceArea.lineWidth = 5
            blockLayer.addSublayer(faceArea)
            
            textNotification.frame = CGRect(x: 0, y: 0, width: blockLayer.frame.width, height: 50)
            textNotification.font = CTFontCreateWithName("TimesNewRomanPSMT" as CFString, 150.0, nil)
            textNotification.foregroundColor = UIColor.white.cgColor
            textNotification.isWrapped = true
            textNotification.alignmentMode = .center
            textNotification.contentsScale = UIScreen.main.scale
            blockLayer.addSublayer(textNotification)
            
        }
        
        // 1
        UIColor.white.setStroke()
        context.setLineWidth(2.0)
        
        if isShowingFace{
            
            if !leftEye.isEmpty {
                // 2
                //print("left eye \(leftEye)")
                context.addLines(between: leftEye)
                
                // 3
                context.closePath()
                
                // 4
                context.strokePath()
            }
            
            //        if leftPupil != CGPoint.zero  {
            //
            //            let maxLeftEye = leftEye.max { (point1, point2) -> Bool in
            //                point2.y > point1.y
            //            }
            //
            //            let minLeftEye = leftEye.max { (point1, point2) -> Bool in
            //                point2.y < point1.y
            //            }
            //
            //            context.addEllipse(in: CGRect(origin: leftPupil, size: CGSize(width: (maxLeftEye!.y - minLeftEye!.y) / 2 , height: (maxLeftEye!.y - minLeftEye!.y) / 3 )))
            //            context.strokePath()
            //        }
            
            if !leftEyebrow.isEmpty {
                context.addLines(between: leftEyebrow)
                context.strokePath()
            }
            
            //        if rightPupil != CGPoint.zero  {
            //
            //            let maxLeftEye = rightEye.max { (point1, point2) -> Bool in
            //                point2.y > point1.y
            //            }
            //
            //            let minLeftEye = rightEye.max { (point1, point2) -> Bool in
            //                point2.y < point1.y
            //            }
            //
            //            context.addEllipse(in: CGRect(origin: rightPupil, size: CGSize(width: (maxLeftEye!.y - minLeftEye!.y) / 2 , height: (maxLeftEye!.y - minLeftEye!.y) / 3 )))
            //            context.strokePath()
            //        }
            
            if !rightEye.isEmpty {
                context.addLines(between: rightEye)
                context.closePath()
                context.strokePath()
            }
            
            if !rightEyebrow.isEmpty {
                context.addLines(between: rightEyebrow)
                context.strokePath()
            }
            
            if !nose.isEmpty {
                context.addLines(between: nose)
                context.strokePath()
            }
            
            if !outerLips.isEmpty {
                context.addLines(between: outerLips)
                context.closePath()
                context.strokePath()
            }
            
            if !innerLips.isEmpty {
                context.addLines(between: innerLips)
                context.closePath()
                context.strokePath()
            }
            
            if !faceContour.isEmpty {
                context.addLines(between: faceContour)
                context.strokePath()
            }
        }
        
        
    }
}
