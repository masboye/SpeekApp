//
//  CameraController.swift
//  MC2
//
//  Created by boy setiawan on 20/06/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import Vision


class CameraController:NSObject{
    
    var previewLayer:AVCaptureVideoPreviewLayer?
    var faceView: FaceView!
    
    private var captureSession:AVCaptureSession?
    private var frontCamera:AVCaptureDevice?
    private var rearCamera:AVCaptureDevice?
    
    private var currentCameraPosition: CameraPosition?
    private var frontCameraInput: AVCaptureDeviceInput?
    private var rearCameraInput: AVCaptureDeviceInput?
    
    private var flashMode = AVCaptureDevice.FlashMode.off
    private var sequenceHandler = VNSequenceRequestHandler()
    private let dataOutputQueue = DispatchQueue(
        label: "data queue",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem)
    private var maxX: CGFloat = 0.0
    private var midY: CGFloat = 0.0
    private var maxY: CGFloat = 0.0
    
    private var faceDetectOutput: AVCaptureVideoDataOutput?
    private var audioDataOutput : AVCaptureAudioDataOutput?
    private var isRecording = false
    private var videoWriter: AVAssetWriter!
    private var videoWriterInput: AVAssetWriterInput!
    private var audioWriterInput: AVAssetWriterInput!
    private var sessionAtSourceTime: CMTime?
    
    
    //set time for recording
    private let recordTimer = RecordTimer(initValue: 0)
    private var isVideoStreaming = false
    private var isAudioStreaming = false
    private var isReadyToRecord = false
    private var timerForRecording:Timer?
    private var labelCountDown:UILabel?
    
    //set vars for notification
    var imageLayer: CALayer!
    var textTimer:CATextLayer!
    var textNotification:CATextLayer!
    private var showNotification = false
    private var notificationOpaqueLeftLayer: CALayer!
    private var notificationOpaqueRightLayer: CALayer!
    private var notificationOpaqueCenterLayer: CALayer!
    private var notificationOpaqueUpLayer: CALayer!
    
    
    
    //set face characteristic counter
    private var faceCharacteristicCounter = FaceCharacteristicCounter()
    var videoURL:URL!
    
    func prepare(completionHandler:@escaping (Error?) -> Void){
        func createCaptureSession(){
            self.captureSession = AVCaptureSession()
        }
        
        func configureCaptureDevices() throws {
            
            let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
            
            if session.devices.isEmpty {
                throw CameraControllerError.noCameraAvailable
            }
            for camera in session.devices {
                if camera.position == .front {
                    self.frontCamera = camera
                }
                
                if camera.position == .back {
                    self.rearCamera = camera
                    
                    try camera.lockForConfiguration()
                    camera.focusMode = .continuousAutoFocus
                    camera.unlockForConfiguration()
                }
            }
            
        }
        
        func configureDeviceInputs() throws {
            
            guard let captureSession = self.captureSession else {
                throw CameraControllerError.captureSessionIsMissing
            }
            
            if let rearCamera = self.rearCamera{
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                
                if captureSession.canAddInput(self.rearCameraInput!){
                    captureSession.addInput(self.rearCameraInput!)
                    self.currentCameraPosition = .rear
                }
                
            } else if let frontCamera = self.frontCamera {
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                
                if captureSession.canAddInput(self.frontCameraInput!) { captureSession.addInput(self.frontCameraInput!)
                    
                }else {
                    throw CameraControllerError.inputsAreInvalid
                    
                }
                
                self.currentCameraPosition = .front
            } else {
                throw CameraControllerError.noCameraAvailable
            }
            
            //trying to get microphone
            guard let microphone = AVCaptureDevice.default(for: AVMediaType.audio) else {
                throw CameraControllerError.noMicrophoneAvailable
            }
            
            let micInput = try AVCaptureDeviceInput(device: microphone)
            
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
                
            }
            
        }
        
        func configureFaceDetectOutput() throws {
            
            guard let captureSession = self.captureSession else {
                throw CameraControllerError.captureSessionIsMissing
            }
            self.faceDetectOutput = AVCaptureVideoDataOutput()
            
            if captureSession.canAddOutput(self.faceDetectOutput!){
                self.faceDetectOutput!.setSampleBufferDelegate(self, queue: dataOutputQueue)
                self.faceDetectOutput!.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
                self.faceDetectOutput?.alwaysDiscardsLateVideoFrames = true
                captureSession.addOutput(self.faceDetectOutput!)
            }
        }
        
        func configureAudioDetectOutput() throws {
            
            guard let captureSession = self.captureSession else {
                throw CameraControllerError.captureSessionIsMissing
            }
            self.audioDataOutput = AVCaptureAudioDataOutput()
            
            if captureSession.canAddOutput(self.audioDataOutput!){
                self.audioDataOutput!.setSampleBufferDelegate(self, queue: dataOutputQueue)
                captureSession.addOutput(self.audioDataOutput!)
            }
        }
        
        do {
            createCaptureSession()
            try configureCaptureDevices()
            try configureDeviceInputs()
            try configureFaceDetectOutput()
            try configureAudioDetectOutput()
            self.captureSession?.commitConfiguration()
            self.captureSession?.startRunning()
            
        }catch{
            completionHandler(error)
            return
        }
        
        completionHandler(nil)
        
       
    }
    
    func stopDisplayPreview(){
        self.captureSession?.stopRunning()
        faceCharacteristicCounter.resetCalculation()
        faceCharacteristicCounter.isCalculating = false
        guard let timer = self.timerForRecording else {return}
        timer.invalidate()
        
    }
    
    func displayPreview(on view:UIView) throws {
        
        guard let captureSession = self.captureSession, captureSession.isRunning else {
            throw CameraControllerError.captureSessionIsMissing
        }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = .resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        self.previewLayer?.frame = view.frame
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        
        self.maxX = view.bounds.maxX
        self.maxY = view.bounds.maxY
        self.midY = view.bounds.midY
        
        self.faceView = FaceView(frame: view.bounds)
        self.faceView.textNotification.string = "Press Button to Start Practice"
        self.faceView.backgroundColor = UIColor.clear
        self.previewLayer?.addSublayer(faceView.layer)
        
        labelCountDown = UILabel(frame: CGRect(x: view.frame.height / 2, y: view.frame.width / 2 - 75, width: 150, height: 150))
        labelCountDown?.font = UIFont(name: "TimesNewRomanPSMT", size: 150.0)
        labelCountDown?.textColor = .red
        self.faceView.addSubview(labelCountDown!)
        
        imageLayer = CALayer()
        imageLayer.frame = view.bounds
        imageLayer.contents = UIImage(named: "808808")?.cgImage
        imageLayer.contentsGravity = .resize
        view.layer.insertSublayer(imageLayer , at: 0)
        imageLayer.rasterizationScale = UIScreen.main.scale
        
        textTimer = CATextLayer()
        textTimer.frame = CGRect(x: 0, y: 30, width: 400, height: 50)
        textTimer.font = CTFontCreateWithName("TimesNewRomanPSMT" as CFString, 150.0, nil)
        textTimer.foregroundColor = UIColor.black.cgColor
        textTimer.isWrapped = true
        textTimer.alignmentMode = .left
        textTimer.contentsScale = UIScreen.main.scale
        imageLayer.addSublayer(textTimer)
        
        textNotification = CATextLayer()
        textNotification.frame = CGRect(x: 0, y: 30, width: 400, height: 50)
        textNotification.font = CTFontCreateWithName("TimesNewRomanPSMT" as CFString, 300.0, nil)
        textNotification.foregroundColor = UIColor.white.cgColor
        textNotification.isWrapped = true
        textNotification.alignmentMode = .center
        textNotification.contentsScale = UIScreen.main.scale
        
        imageLayer.addSublayer(textNotification)
        
        notificationOpaqueLeftLayer = CALayer()
        notificationOpaqueLeftLayer.backgroundColor = UIColor.red.cgColor
        notificationOpaqueLeftLayer.opacity = 0.3
        notificationOpaqueLeftLayer.rasterizationScale = UIScreen.main.scale
        imageLayer.insertSublayer(notificationOpaqueLeftLayer, at: 2)
        
        notificationOpaqueRightLayer = CALayer()
        notificationOpaqueRightLayer.backgroundColor = UIColor.red.cgColor
        notificationOpaqueRightLayer.opacity = 0.3
        notificationOpaqueRightLayer.rasterizationScale = UIScreen.main.scale
        imageLayer.insertSublayer(notificationOpaqueRightLayer, at: 2)
        
        notificationOpaqueCenterLayer = CALayer()
        notificationOpaqueCenterLayer.backgroundColor = UIColor.red.cgColor
        notificationOpaqueCenterLayer.opacity = 0.3
        notificationOpaqueCenterLayer.rasterizationScale = UIScreen.main.scale
        imageLayer.insertSublayer(notificationOpaqueCenterLayer, at: 2)
        
        notificationOpaqueUpLayer = CALayer()
        notificationOpaqueUpLayer.backgroundColor = UIColor.red.cgColor
        notificationOpaqueUpLayer.opacity = 0.3
        notificationOpaqueUpLayer.rasterizationScale = UIScreen.main.scale
        imageLayer.insertSublayer(notificationOpaqueUpLayer, at: 2)
        
        
    }
    
    func switchCamera() throws {
        
        guard let currentCameraPosition = currentCameraPosition, let capturedSession = self.captureSession, capturedSession.isRunning else {
            throw CameraControllerError.captureSessionIsMissing
            
        }
        
        capturedSession.beginConfiguration()
        
        func switchFrontCamera() throws {
            
            guard let inputs = capturedSession.inputs as? [AVCaptureInput], let rearCameraInput = self.rearCameraInput, inputs.contains(rearCameraInput),
                let frontCamera = self.frontCamera else {
                    throw CameraControllerError.invalidOperation
                    
            }
            
            self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            
            capturedSession.removeInput(rearCameraInput)
            
            if capturedSession.canAddInput(self.frontCameraInput!) {
                capturedSession.addInput(self.frontCameraInput!)
                
                self.currentCameraPosition = .front
            }
                
            else { throw CameraControllerError.invalidOperation }
        }
        
        func switchRearCamera() throws {
            guard let inputs = captureSession!.inputs as? [AVCaptureInput], let frontCameraInput = self.frontCameraInput, inputs.contains(frontCameraInput),
                let rearCamera = self.rearCamera else {
                    throw CameraControllerError.invalidOperation
                    
            }
            
            self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
            
            captureSession?.removeInput(frontCameraInput)
            
            if captureSession!.canAddInput(self.rearCameraInput!) {
                captureSession?.addInput(self.rearCameraInput!)
                self.currentCameraPosition = .rear
            }
                
            else {
                throw CameraControllerError.invalidOperation
                
            }
        }
        
        switch currentCameraPosition {
        case .front:
            try switchRearCamera()
        case .rear:
            try switchFrontCamera()
        }
        capturedSession.commitConfiguration()
    }
    
    private var topic:String
    init(topic: String) {
        self.topic = topic
    }
}


extension CameraController{
    
    enum CameraControllerError:Swift.Error{
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCameraAvailable
        case noMicrophoneAvailable
        case unknown
    }
    
    public enum CameraPosition {
        case front
        case rear
    }
}

extension CameraController:AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate{
    
    func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage {
        let imageBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let baseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = (CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
        let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        let imageRef = context!.makeImage()
        
        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let resultImage: UIImage = UIImage(cgImage: imageRef!)
        
        return resultImage
    }
    
    func getFaceLandMarks(sampleBuffer: CMSampleBuffer, faceDetectOrientation: CGImagePropertyOrientation){
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let detectFaceRequest = VNDetectFaceLandmarksRequest(completionHandler: detectedFace)
        
        do {
            try sequenceHandler.perform(
                [detectFaceRequest],
                on: imageBuffer,
                orientation: faceDetectOrientation)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getFaceFeatures(sampleBuffer: CMSampleBuffer){
        
        let image = self.imageFromSampleBuffer(sampleBuffer: sampleBuffer)
        let ciimage: CIImage! = CIImage(image: image)
        
        let detector: CIDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options:[CIDetectorAccuracy: CIDetectorAccuracyLow])!
        
        // fetch parameter list
        let options = [CIDetectorSmile : true, CIDetectorEyeBlink:true]
        
        // detect face
        let faces = detector.features(in: ciimage, options: options)
        
        for feature in faces as! [CIFaceFeature] {
            
            // check if you are smiling
            if feature.hasSmile {
                self.faceCharacteristicCounter.smilePerimeter = FaceCharacteristic.smilling
                self.faceCharacteristicCounter.notSmilePerimeter = FaceCharacteristic.smilling
            }else{
                self.faceCharacteristicCounter.smilePerimeter = FaceCharacteristic.notSmilling
                self.faceCharacteristicCounter.notSmilePerimeter = FaceCharacteristic.notSmilling
            }
            
            
            if feature.rightEyeClosed  && feature.leftEyeClosed{
                self.faceCharacteristicCounter.eyesPerimeter = FaceCharacteristic.eyesClosed
           
            } else{
                self.faceCharacteristicCounter.eyesPerimeter = FaceCharacteristic.eyesOpen
           
            }
            
            
        }
        
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard CMSampleBufferDataIsReady(sampleBuffer) else { return }
        
        
        
        var faceDetectOrientation:CGImagePropertyOrientation = .leftMirrored
        
        let writable = canWrite()
        
        //running the time counter
        if self.isAudioStreaming, self.isVideoStreaming, !self.isReadyToRecord, isRecording{
            self.isReadyToRecord = true
            
            //start the count down
            
        let countDownTimer = CountDownTimer(initValue: 3)
           
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
               self.timerForRecording = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (time) in
                    self.recordTimer.updateTimer()
                    countDownTimer.updateTimer()
               
                    DispatchQueue.main.async {
                        
                        self.textTimer.isHidden = self.showNotification
                        self.textTimer.string = "\(self.recordTimer.getTime())"
                        self.textNotification.isHidden = !self.showNotification
                        
                        if self.faceCharacteristicCounter.lastNotSmilling > 10 {
                            
                            if #available(iOS 9.0, *) {
                                AudioServicesPlaySystemSoundWithCompletion(SystemSoundID(1117), nil)
                            } else {
                                AudioServicesPlaySystemSound(1117)
                            }
                            
                            self.showNotification = true
                            self.textNotification.string = "Smile Please"
                            self.notificationOpaqueUpLayer.isHidden = false
                            self.notificationOpaqueUpLayer.frame = CGRect(x: 0, y: 0, width: (UIScreen.screens.last?.bounds.width)!, height: 50)
                            
                        }else if self.faceCharacteristicCounter.lastEyesClosed > 1 {
                            
                            if #available(iOS 9.0, *) {
                                AudioServicesPlaySystemSoundWithCompletion(SystemSoundID(1117), nil)
                            } else {
                                AudioServicesPlaySystemSound(1117)
                            }
                            
                            self.showNotification = true
                            self.textNotification.string = "Eye Contact Please"
                            self.faceCharacteristicCounter.lastEyesClosed = 0
                            self.notificationOpaqueUpLayer.isHidden = false
                            self.notificationOpaqueUpLayer.frame = CGRect(x: 0, y: 0, width: (UIScreen.screens.last?.bounds.width)!, height: 50)
                            
                            
                        } else if self.faceCharacteristicCounter.lastStraight > 20 {
                            
                            if #available(iOS 9.0, *) {
                                AudioServicesPlaySystemSoundWithCompletion(SystemSoundID(1117), nil)
                            } else {
                                AudioServicesPlaySystemSound(1117)
                            }
                            
                            self.showNotification = true
                            self.textNotification.string = "Focus On Other Side Please"
                            self.notificationOpaqueUpLayer.isHidden = false
                            self.notificationOpaqueUpLayer.frame = CGRect(x: 0, y: 0, width: (UIScreen.screens.last?.bounds.width)!, height: 50)
                            
                            self.notificationOpaqueLeftLayer.isHidden = false
                            self.notificationOpaqueLeftLayer.frame = CGRect(x: 0, y: 0, width: (UIScreen.screens.last?.bounds.height)! / 3, height: self.imageLayer.frame.height)
                            
                            self.notificationOpaqueRightLayer.isHidden = false
                            self.notificationOpaqueRightLayer.frame = CGRect(x: (UIScreen.screens.last?.bounds.width)! - (UIScreen.screens.last?.bounds.height)! / 3, y: 0, width: (UIScreen.screens.last?.bounds.height)! / 3, height: (UIScreen.screens.last?.bounds.height)!)
                            
                            
                        } else if self.faceCharacteristicCounter.lastTurnLeft > 20 {
                            
                            if #available(iOS 9.0, *) {
                                AudioServicesPlaySystemSoundWithCompletion(SystemSoundID(1117), nil)
                            } else {
                                AudioServicesPlaySystemSound(1117)
                            }
                            
                            self.showNotification = true
                            self.textNotification.string = "Focus On Other Side Please"
                            self.notificationOpaqueUpLayer.isHidden = false
                            self.notificationOpaqueUpLayer.frame = CGRect(x: 0, y: 0, width: (UIScreen.screens.last?.bounds.width)!, height: 50)
                            
                            self.notificationOpaqueRightLayer.isHidden = false
                            self.notificationOpaqueRightLayer.frame = CGRect(x: (UIScreen.screens.last?.bounds.width)! - (UIScreen.screens.last?.bounds.height)! / 3, y: 0, width: (UIScreen.screens.last?.bounds.height)! / 3, height: (UIScreen.screens.last?.bounds.height)!)
                            
                            self.notificationOpaqueCenterLayer.isHidden = false
                            self.notificationOpaqueCenterLayer.frame = CGRect(x: (UIScreen.screens.last?.bounds.width)! / 3 , y: 0, width: (UIScreen.screens.last?.bounds.height)! / 2, height: (UIScreen.screens.last?.bounds.height)!)
                            
                        } else if self.faceCharacteristicCounter.lastTurnRight > 20 {
                            
                            if #available(iOS 9.0, *) {
                                AudioServicesPlaySystemSoundWithCompletion(SystemSoundID(1117), nil)
                            } else {
                                AudioServicesPlaySystemSound(1117)
                            }
                            
                            self.showNotification = true
                            self.textNotification.string = "Focus On Other Side Please"
                            self.notificationOpaqueUpLayer.isHidden = false
                            self.notificationOpaqueUpLayer.frame = CGRect(x: 0, y: 0, width: (UIScreen.screens.last?.bounds.width)!, height: 50)
                            
                            self.notificationOpaqueLeftLayer.isHidden = false
                            self.notificationOpaqueLeftLayer.frame = CGRect(x: 0, y: 0, width: (UIScreen.screens.last?.bounds.height)! / 3, height: self.imageLayer.frame.height)
                            
                            self.notificationOpaqueCenterLayer.isHidden = false
                            self.notificationOpaqueCenterLayer.frame = CGRect(x: (UIScreen.screens.last?.bounds.width)! / 3 , y: 0, width: (UIScreen.screens.last?.bounds.height)! / 2, height: (UIScreen.screens.last?.bounds.height)!)
                            
                        } else{
                            self.showNotification = false
                            self.notificationOpaqueLeftLayer.isHidden = true
                            self.notificationOpaqueCenterLayer.isHidden = true
                            self.notificationOpaqueRightLayer.isHidden = true
                            self.notificationOpaqueUpLayer.isHidden = true
                            
                        }
                        
                        if countDownTimer.getCounter() >= 0 {
                            if #available(iOS 9.0, *) {
                                AudioServicesPlaySystemSoundWithCompletion(SystemSoundID(1117), nil)
                            } else {
                                AudioServicesPlaySystemSound(1117)
                            }
                            
                            self.labelCountDown?.text = "\(countDownTimer.getCounter())"
                            
                        }else{
                            self.labelCountDown?.text = ""
                            self.labelCountDown?.isHidden = true
                            self.faceView.isHidden = true
                            
                            guard let orientation = self.previewLayer?.connection?.videoOrientation.rawValue else {return}
                            
                            if UIScreen.screens.count > 1 {
                              
                                    self.previewLayer?.frame = CGRect(x: 0, y: (self.previewLayer?.frame.height)!  * 3, width: UIScreen.screens.last!.bounds.height / 4  , height: UIScreen.screens.last!.bounds.height / 4)
                                
                            }else{
                                
                                if orientation == 1 {
                                    self.previewLayer?.frame = CGRect(x: 0, y: (self.previewLayer?.frame.height)!  * 7, width: 100, height: 100)
                                }else{
                                    self.previewLayer?.frame = CGRect(x: 0, y: (self.previewLayer?.frame.height)!  * 3, width: 100, height: 100)
                                }
                            }
                           
                        }
                        
                        
                    }
                }
            }
            
            //faceView.isShowingFace = false
            
        }
       
        if faceView != nil, self.faceView.isAllFaceLandmarksAvailable(){
            
            DispatchQueue.main.async {
                self.faceView.textNotification.string = "Face Feature Detected"
                
            }
            //faceView.isInitBoxShow = true
        }
        
        if output == self.faceDetectOutput{
            
            if writable,
                sessionAtSourceTime == nil {
                //Start writing
                sessionAtSourceTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                videoWriter.startSession(atSourceTime: sessionAtSourceTime!)
                
            }
            
            switch UIDevice.current.orientation {
            case .landscapeRight:
                
                connection.videoOrientation = .landscapeLeft
                if self.currentCameraPosition == CameraPosition.front {
                    
                    faceDetectOrientation = .downMirrored
                }else{
                    faceDetectOrientation = .upMirrored
                }
                
            case .landscapeLeft:
                connection.videoOrientation = .landscapeRight
                if self.currentCameraPosition == CameraPosition.front {
                    
                    faceDetectOrientation = .upMirrored
                }else{
                    faceDetectOrientation = .downMirrored
                }
                
            case .portrait:
                connection.videoOrientation = .portrait
                faceDetectOrientation = .leftMirrored
            case .portraitUpsideDown:
                connection.videoOrientation = .portraitUpsideDown
                faceDetectOrientation = .leftMirrored
            default:
                connection.videoOrientation = .portrait
                faceDetectOrientation = .leftMirrored
                //Make `.portrait` as default (should check will `.faceUp` and `.faceDown`)
            }
            
            if writable, isRecording, isAudioStreaming{
                
                //write video
                if videoWriterInput.isReadyForMoreMediaData {
                    //Write video buffer
                   
                    self.isVideoStreaming = true
                    
                    if videoWriter.status != .writing{
                        videoWriter.startWriting()
                    } else {
                        //Means ready to write down the file
                        
                        videoWriterInput.append(sampleBuffer)
                        
                    }
                }
                
            }
            
            if !isRecording{
                getFaceLandMarks(sampleBuffer: sampleBuffer, faceDetectOrientation: faceDetectOrientation)
            }
            
            
            DispatchQueue.main.async {
            self.getFaceFeatures(sampleBuffer: sampleBuffer)
                if self.isRecording{
                    self.getFaceLandMarks(sampleBuffer: sampleBuffer, faceDetectOrientation: faceDetectOrientation)
                }
        }
            
            
           }else if writable, isRecording,
            output == self.audioDataOutput,sessionAtSourceTime != nil,
            audioWriterInput.isReadyForMoreMediaData {
            //Write audio buffer
           
            self.isAudioStreaming = true
            
            audioWriterInput.append(sampleBuffer)
            
        }
        
        
    }
    
}

extension CameraController{
    
    func convert(rect: CGRect) -> CGRect {
        
        let origin = self.previewLayer!.layerPointConverted(fromCaptureDevicePoint: rect.origin)
        let size = self.previewLayer!.layerPointConverted(fromCaptureDevicePoint: rect.size.cgPoint)
        
        return CGRect(origin: origin, size: size.cgSize)
    }
    
    func landmark(point: CGPoint, to rect: CGRect) -> CGPoint {
        let absolute = point.absolutePoint(in: rect)
        let converted = self.previewLayer!.layerPointConverted(fromCaptureDevicePoint: absolute)
        return converted
    }
    
    func landmark(points: [CGPoint]?, to rect: CGRect) -> [CGPoint]? {
        guard let points = points else {
            return nil
        }
        
        return points.compactMap { landmark(point: $0, to: rect) }
    }
    
    func updateFaceView(for result: VNFaceObservation) {
        defer {
            DispatchQueue.main.async {
                self.faceView.setNeedsDisplay()
            }
        }
        
        let box = result.boundingBox
        faceView.boundingBox = convert(rect: box)
        
        guard let landmarks = result.landmarks else {
            return
        }
        
        
        if let leftPupil = landmark(
            points: landmarks.leftPupil?.normalizedPoints,
            to: result.boundingBox) {
            if landmarks.confidence > 0.5{
                faceView.leftPupil = leftPupil[0]
            }else{
                faceView.leftPupil = CGPoint.zero
            }
        }
        
        if let rightPupil = landmark(
            points: landmarks.rightPupil?.normalizedPoints,
            to: result.boundingBox) {
            if landmarks.confidence > 0.5{
                faceView.rightPupil = rightPupil[0]
            }else{
                faceView.rightPupil = CGPoint.zero
            }
            
        }
        
        if let leftEye = landmark(
            points: landmarks.leftEye?.normalizedPoints,
            to: result.boundingBox) {
            if landmarks.confidence > 0.5{
                faceView.leftEye = leftEye
            }else{
                faceView.leftEye = [CGPoint.zero]
                self.faceCharacteristicCounter.eyesPerimeter = FaceCharacteristic.eyesClosed
            }
        }
        
        
        if let rightEye = landmark(
            points: landmarks.rightEye?.normalizedPoints,
            to: result.boundingBox) {
            if landmarks.confidence > 0.5{
                faceView.rightEye = rightEye
            }else{
                faceView.rightEye = [CGPoint.zero]
                self.faceCharacteristicCounter.eyesPerimeter = FaceCharacteristic.eyesClosed
            }
            
        }
        
        if let leftEyebrow = landmark(
            points: landmarks.leftEyebrow?.normalizedPoints,
            to: result.boundingBox) {
            if landmarks.confidence > 0.5{
                faceView.leftEyebrow = leftEyebrow
            }else{
                faceView.leftEyebrow = [CGPoint.zero]
            }
            
        }
        
        if let rightEyebrow = landmark(
            points: landmarks.rightEyebrow?.normalizedPoints,
            to: result.boundingBox) {
            if landmarks.confidence > 0.5{
                faceView.rightEyebrow = rightEyebrow
            }else{
                faceView.rightEyebrow = [CGPoint.zero]
            }
            
        }
        
        if let nose = landmark(
            points: landmarks.nose?.normalizedPoints,
            to: result.boundingBox) {
            if landmarks.confidence > 0.5{
                faceView.nose = nose
            }else{
                faceView.nose = [CGPoint.zero]
            }
        }
        
        if let outerLips = landmark(
            points: landmarks.outerLips?.normalizedPoints,
            to: result.boundingBox) {
            if landmarks.confidence > 0.5{
                faceView.outerLips = outerLips
            }else{
                faceView.outerLips = [CGPoint.zero]
            }
            
        }
        
        if let innerLips = landmark(
            points: landmarks.innerLips?.normalizedPoints,
            to: result.boundingBox) {
            if landmarks.confidence > 0.5{
                faceView.innerLips = innerLips
            }else{
                faceView.innerLips = [CGPoint.zero]
            }
            
        }
        
        if let faceContour = landmark(
            points: landmarks.faceContour?.normalizedPoints,
            to: result.boundingBox) {
            if landmarks.confidence > 0.5{
                faceView.faceContour = faceContour
            }else{
                faceView.faceContour = [CGPoint.zero]
            }
            
        }
    }
    
    func detectedFace(request: VNRequest, error: Error?) {
        
        guard
            let results = request.results as? [VNFaceObservation],
            let result = results.first
            else {
                
                //do not erase this comment 15-07-2019 boye
                //faceView.clear()
                return
        }
        //yaw -0.7 means turn left +0.7 means turn right 0 means head straight
        //yaw.boolValue false means turn right yaw.boolValue true means turn left
        //roll 2 head tilt left 0.5 head tilt right 1 means head straight
        
        
        guard let yaw = result.yaw?.doubleValue else { return  }
        
        //turn left
        if yaw < -0.3 {
            self.faceCharacteristicCounter.turnLeftPerimeter = FaceCharacteristic.turnLeft
            self.faceCharacteristicCounter.turnRightPerimeter = FaceCharacteristic.turnLeft
            self.faceCharacteristicCounter.straightPerimeter = FaceCharacteristic.turnLeft
        }
        
        //turn right
        if yaw > 0.3 {
            self.faceCharacteristicCounter.turnLeftPerimeter = FaceCharacteristic.turnRight
            self.faceCharacteristicCounter.turnRightPerimeter = FaceCharacteristic.turnRight
            self.faceCharacteristicCounter.straightPerimeter = FaceCharacteristic.turnRight
        }
        
        //straight
        if yaw == 0.0 {
            self.faceCharacteristicCounter.turnLeftPerimeter = FaceCharacteristic.straight
            self.faceCharacteristicCounter.turnRightPerimeter = FaceCharacteristic.straight
            self.faceCharacteristicCounter.straightPerimeter = FaceCharacteristic.straight
        }
        
        updateFaceView(for: result)
        
    }
}

extension CameraController{
    
    fileprivate func setupWriter() {
        do {
            videoURL = videoFileLocation()
            videoWriter = try AVAssetWriter(url: videoURL, fileType: AVFileType.mp4)
            
            //Add video input
            videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: 1280,
                AVVideoHeightKey: 780,
                AVVideoCompressionPropertiesKey: [
                    AVVideoAverageBitRateKey: 2300000,
                ],
                ])
            
            
            videoWriterInput.expectsMediaDataInRealTime = true //Make sure we are exporting data at realtime
            if videoWriter.canAdd(videoWriterInput) {
                videoWriter.add(videoWriterInput)
            }
            
            //Add audio input
            audioWriterInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVNumberOfChannelsKey: 1,
                AVSampleRateKey: 44100,
                AVEncoderBitRateKey: 64000,
                ])
            audioWriterInput.expectsMediaDataInRealTime = true
            if videoWriter.canAdd(audioWriterInput) {
                
                videoWriter.add(audioWriterInput)
            }
            
            videoWriter.startWriting() //Means ready to write down the file
        }
        catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    
    fileprivate func canWrite() -> Bool {
        return isRecording
            && videoWriter != nil
            && videoWriter.status == .writing
    }
    
    //video file location method
    func videoFileLocation() -> URL {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let randomNumber = Int.random(in: 1...100)
        let videoOutputUrl = URL(fileURLWithPath: documentsPath.appendingPathComponent("\(self.topic)\(randomNumber)")).appendingPathExtension("mp4")
        do {
            if FileManager.default.fileExists(atPath: videoOutputUrl.path) {
                
                try FileManager.default.removeItem(at: videoOutputUrl)
                
            }
        } catch {
            print(error)
        }
        
        return videoOutputUrl
    }
    
    func start() {
        
        DispatchQueue.main.async {
            self.faceView.textNotification.string = "Please Put Your Face Here"
        }
        guard !isRecording else { return }
        isRecording = true
        sessionAtSourceTime = nil
        //startWriting()
        setupWriter()
        
        guard let timer = self.timerForRecording else {return}
        timer.fire()
        
       
    }
    
    
    func stop() {
        
        guard isRecording else { return }
        //guard videoWriter.status.rawValue == 1 else { return }
        
        isRecording = false
        videoWriter.finishWriting { [weak self] in
            self?.sessionAtSourceTime = nil
            //guard let url = self?.videoWriter.outputURL else { return }
            //let asset = AVURLAsset(url: url)
            //Do whatever you want with your asset here
            
            //UISaveVideoAtPathToSavedPhotosAlbum(asset.url.path, nil, nil, nil)
            //self!.saveVideoInDirectory(from: asset.url)
            
            
        }
        self.isReadyToRecord = false
        self.recordTimer.resetTimer()
        self.timerForRecording?.invalidate()
        self.labelCountDown?.isHidden = false
        
    }
    
    
    
    func pause() {
        isRecording = false
    }
    
    func resume() {
        isRecording = true
    }
}
