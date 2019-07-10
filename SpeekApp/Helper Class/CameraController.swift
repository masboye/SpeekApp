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
    
    var captureSession:AVCaptureSession?
    var frontCamera:AVCaptureDevice?
    var rearCamera:AVCaptureDevice?
    
    var currentCameraPosition: CameraPosition?
    var frontCameraInput: AVCaptureDeviceInput?
    var rearCameraInput: AVCaptureDeviceInput?
    
    var previewLayer:AVCaptureVideoPreviewLayer?
    var flashMode = AVCaptureDevice.FlashMode.off
    
    var sequenceHandler = VNSequenceRequestHandler()
    let dataOutputQueue = DispatchQueue(
        label: "data queue",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem)
    var maxX: CGFloat = 0.0
    var midY: CGFloat = 0.0
    var maxY: CGFloat = 0.0
    var faceView: FaceView!
    var faceDetectOutput: AVCaptureVideoDataOutput?
    var audioDataOutput : AVCaptureAudioDataOutput?
    var isRecording = false
    var videoWriter: AVAssetWriter!
    var videoWriterInput: AVAssetWriterInput!
    var audioWriterInput: AVAssetWriterInput!
    var sessionAtSourceTime: CMTime?
    
    
    //set time for recording
    let recordTimer = RecordTimer(initValue: 0)
    var isVideoStreaming = false
    var isAudioStreaming = false
    var isReadyToRecord = false
    var label:UILabel?
    var timerForRecording:Timer?
   
    
    
    
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
        self.faceView.backgroundColor = UIColor.clear
        self.previewLayer?.addSublayer(faceView.layer)
        
        label = UILabel(frame: CGRect(x: 0, y: -view.frame.height / 2 + 50, width: view.frame.width, height: view.frame.height))
        label?.text = "Preparing Recording"
        label?.font = UIFont(name: "Times new Roman", size: 25.0)
        label?.textColor = .white
        self.faceView.addSubview(label!)
        
        
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
        //print("\(faces.count)")
        
        for feature in faces as! [CIFaceFeature] {
            
            // check if you are smiling
            if feature.hasSmile {
                print("Smilling!!!")
            }else{
                //print("not smilling")
            }
            
            
            if feature.rightEyeClosed {
                //print("Right Eye Closed")
            }
            
            if feature.leftEyeClosed {
                //("Left Eye Closed")
            }
        }
        
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard output != nil,
            sampleBuffer != nil,
            connection != nil,
            CMSampleBufferDataIsReady(sampleBuffer) else { return }
        
        var faceDetectOrientation:CGImagePropertyOrientation = .leftMirrored
        
        let writable = canWrite()
        
//        if output == self.faceDetectOutput{
//            //print("VIDEO IS STREAMING")
//            self.isVideoStreaming = true
//        }else if output == self.audioDataOutput{
//            //print("AUDIO IS STREAMING")
//            self.isAudioStreaming = true
//        }
        
        if self.isAudioStreaming, self.isVideoStreaming, !self.isReadyToRecord, isRecording{
            self.isReadyToRecord = true
            //print("Record is ready \(self.isReadyToRecord)-\(self.isAudioStreaming)-\(self.isVideoStreaming)")
            //start the count down
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                //print("Timer fired!")
                
               self.timerForRecording = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (time) in
                    self.recordTimer.updateTimer()
                    DispatchQueue.main.async {
                        self.label?.text = "\(self.recordTimer.getTime())"
                        
                    }
                }
            }
            
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
                    //print("Video Recording \(videoWriter.status == .writing)")
                    self.isVideoStreaming = true
                    
                    if videoWriter.status != .writing{
                        videoWriter.startWriting()
                    } else {
                        //Means ready to write down the file
                        
                        videoWriterInput.append(sampleBuffer)
                        
                    }
                }
                
            }
            
            //test
            
//
            getFaceLandMarks(sampleBuffer: sampleBuffer, faceDetectOrientation: faceDetectOrientation)
            DispatchQueue.main.async {
            self.getFaceFeatures(sampleBuffer: sampleBuffer)
        }
            //edn test
            
           }else if writable, isRecording,
            output == self.audioDataOutput,sessionAtSourceTime != nil,
            audioWriterInput.isReadyForMoreMediaData {
            //Write audio buffer
            //print("Audio Recording \(videoWriter.status == .writing)")
            self.isAudioStreaming = true
            
            audioWriterInput.append(sampleBuffer)
            
        }
        
        
    }
    
}

extension CameraController{
    
    func convert(rect: CGRect) -> CGRect {
        
        let origin = self.previewLayer!.layerPointConverted(fromCaptureDevicePoint: rect.origin)
        let size = self.previewLayer!.layerPointConverted(fromCaptureDevicePoint: rect.size.cgPoint)
        //print("\(size)")
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
        
        //print("\(self.previewLayer?.layerPointConverted(fromCaptureDevicePoint: result.boundingBox.origin))")
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
            }
        }
        
        
        if let rightEye = landmark(
            points: landmarks.rightEye?.normalizedPoints,
            to: result.boundingBox) {
            if landmarks.confidence > 0.5{
                faceView.rightEye = rightEye
            }else{
                faceView.rightEye = [CGPoint.zero]
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
                
                faceView.clear()
                return
        }
        //yaw -0.7 means turn left +0.7 means turn right 0 means head straight
        //roll 2 head tilt left 0.5 head tilt right 1 means head straight
        //print("Yaw = \(result.yaw)- Roll = \(result.roll)")
        updateFaceView(for: result)
        
    }
}

extension CameraController{
    
    fileprivate func setupWriter() {
        do {
            let url = videoFileLocation()
            videoWriter = try AVAssetWriter(url: url, fileType: AVFileType.mp4)
            
            //Add video input
            videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: 720,
                AVVideoHeightKey: 1280,
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
                //print("ADD AUDIO")
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
        let videoOutputUrl = URL(fileURLWithPath: documentsPath.appendingPathComponent("videoFile")).appendingPathExtension("mov")
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
            guard let url = self?.videoWriter.outputURL else { return }
            let asset = AVURLAsset(url: url)
            //Do whatever you want with your asset here
            print("\(asset.duration.seconds)")
            UISaveVideoAtPathToSavedPhotosAlbum(asset.url.path, nil, nil, nil)
        }
        
        self.timerForRecording?.invalidate()
    }
    
    func pause() {
        isRecording = false
    }
    
    func resume() {
        isRecording = true
    }
}
