//
//  ScreenViewController.swift
//  SpeekApp
//
//  Created by boy setiawan on 08/07/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import UIKit
import AVKit

class ScreenViewController: UIViewController {
    
    @IBOutlet weak var stackButton: UIStackView!
    @IBOutlet weak var preview: UIView!
    @IBOutlet weak var recordButton: UIButton!
    
    var recordButtonStatus = false
    var showStackStatus = true
    
    var cameraController :CameraController!
    var additionalWindows: [UIWindow] = []
    
    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        
        if !self.recordButtonStatus {
            
            self.recordButton.setImage(UIImage(named: "stop record"), for: .normal)
            self.recordButtonStatus = true
            
            self.stackButton.hideAnimated(in: self.stackButton)
            self.showStackStatus = false
            
            self.cameraController.start()
            
        }else{
            self.recordButtonStatus = false
            self.recordButton.setImage(UIImage(named: "start record"), for: .normal)
            self.cameraController.stop()
            performSegue(withIdentifier: "showResult", sender: self.cameraController.videoURL )
           
        }
        
    }
    
    @objc func screenTap( _ recognizer : UITapGestureRecognizer){
        
        self.stackButton.isHidden = self.showStackStatus
        self.showStackStatus.toggle()
        self.stackButton.layer.zPosition = 1.0
        
    }
    var topic:String = ""
    
    func configureCameraController(){
        cameraController.prepare{ error in
            if let error = error{
                print(error)
            }
        }
        try? self.cameraController.displayPreview(on: self.preview)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        
        //init camera controller
        self.cameraController = CameraController(topic: topic)
        
        // Do any additional setup after loading the view.
        let screenTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.screenTap(_:)))
        view.addGestureRecognizer(screenTapGesture)
        
        func configureExternalMonitor(){
            
            NotificationCenter.default.addObserver(forName: UIScreen.modeDidChangeNotification, object: nil, queue: nil) { (notification) in
                //
                if let extScreen = notification.object as? UIScreen, extScreen == UIScreen.screens.last
                {
                    self.view.setNeedsLayout()
                    self.view.layoutSubviews()
                }
            }
            
            NotificationCenter.default.addObserver(forName: UIScreen.didConnectNotification,
                                                   object: nil, queue: nil) { (notification) in
                                                    
                                                    
                                                    // Get the new screen information.
                                                    let newScreen = notification.object as! UIScreen
                                                    let screenDimensions = newScreen.bounds
                                                    
                                                    // Configure a window for the screen.
                                                    let newWindow = UIWindow(frame: screenDimensions)
                                                    newWindow.screen = newScreen
                                                    
                                                    self.configureAuxilliaryInterface(with: newWindow)
                                                    
                                                    print("connect-\(self.additionalWindows.count)")
            }
            
            NotificationCenter.default.addObserver(forName:
                UIScreen.didDisconnectNotification,
                                                   object: nil,
                                                   queue: nil) { (notification) in
                                                    let screen = notification.object as! UIScreen
                                                    
                                                    //Remove the window associated with the screen.
                                                    for window in self.additionalWindows {
                                                        if window.screen == screen {
                                                            // Remove the window and its contents.
                                                            let index = self.additionalWindows.firstIndex(of: window)
                                                            self.resetAuxilliaryInterface(window: window)
                                                            self.additionalWindows.remove(at: index!)
                                                        }
                                                    }
                                                    print("disconnect-\(self.additionalWindows.count)")
            }
        }
        
        configureCameraController()
        configureExternalMonitor()
        
        //anticipate external screen already available
        if UIScreen.screens.count > 1{
            
            let newScreen = UIScreen.screens.last
            let screenDimensions = newScreen!.bounds
            let newWindow = UIWindow(frame: screenDimensions)
            newWindow.screen = newScreen!
            
            self.configureAuxilliaryInterface(with: newWindow)
            
        }
        
        do {
            try cameraController.switchCamera()
        }
            
        catch {
            print(error)
        }
        
    }
    
    
    func configureAuxilliaryInterface(with: UIWindow){
       
        // You must show the window explicitly.
        with.isHidden = false
        // Save a reference to the window in a local array.
        self.additionalWindows.append(with)
        
        let viewController = UIViewController()
        
        with.rootViewController = viewController
        with.addSubview(self.preview)
       
    }
    
    func resetAuxilliaryInterface(window: UIWindow){
        
        self.view.addSubview(window)
        //self.preview.updateConstraintsIfNeeded()
        
    }
    
    override func viewDidLayoutSubviews() {
       
        //set the previewlayer and faceView so always the same size in any orinetation
        
        cameraController.faceView?.frame = cameraController.previewLayer!.frame
        cameraController.imageLayer?.frame = cameraController.previewLayer!.frame
        cameraController.textTimer?.frame = cameraController.previewLayer!.frame
        cameraController.textNotification?.frame = cameraController.previewLayer!.frame
        
    }
    
    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        
        layer.videoOrientation = orientation
        //check external screen
        if UIScreen.screens.count > 1{
            cameraController.previewLayer?.frame = UIScreen.screens.last!.bounds
        }else{
            cameraController.previewLayer?.frame = self.view.bounds
            
        }
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        if let connection =  self.cameraController.previewLayer?.connection  {
            
            let currentDevice: UIDevice = UIDevice.current
            let orientation: UIDeviceOrientation = currentDevice.orientation
            let previewLayerConnection : AVCaptureConnection = connection
            
            if previewLayerConnection.isVideoOrientationSupported {
                
                switch (orientation) {
                case .portrait:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                    break
                    
                case .landscapeRight:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
                    break
                    
                case .landscapeLeft:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
                    break
                    
                case .portraitUpsideDown:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
                    break
                    
                default:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                    break
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.landscapeRight, andRotateTo: UIInterfaceOrientation.landscapeRight)
        
        //self.cameraController.restartDisplayPreview()
        //configureCameraController()
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        
        self.cameraController.stopDisplayPreview()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //guard (sender as? URL) != nil else {return}
        guard let url = sender as? URL else {return}
        
        let controller = segue.destination
        let resultView = controller as! ResultViewController
       
        resultView.url = url
    }
    
    
}
