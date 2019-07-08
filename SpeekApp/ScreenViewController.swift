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
    
    let cameraController = CameraController()
    var additionalWindows: [UIWindow] = []
    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        
        if !self.recordButtonStatus {
            
            self.recordButton.setImage(UIImage(named: "stop record"), for: .normal)
            self.recordButtonStatus = true
            self.stackButton.isHidden = true
            self.showStackStatus = false
            
            if #available(iOS 9.0, *) {
                AudioServicesPlaySystemSoundWithCompletion(SystemSoundID(1108), nil)
            } else {
                AudioServicesPlaySystemSound(1108)
            }
           
        }else{
            self.recordButtonStatus = false
            self.recordButton.setImage(UIImage(named: "start record"), for: .normal)
           
        }
        
    }
    
    @objc func screenTap( _ recognizer : UITapGestureRecognizer){
        
        self.stackButton.isHidden = self.showStackStatus
        self.showStackStatus.toggle()
        
    }
    var topic:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let screenTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.screenTap(_:)))
        self.preview.addGestureRecognizer(screenTapGesture)
        
        func configureCameraController(){
            cameraController.prepare{ error in
                if let error = error{
                    print(error)
                }
            }
            try? self.cameraController.displayPreview(on: self.preview)
            
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
                                                    //print("\(screenDimensions)-\(self.view.bounds)")
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
        
        //anticipate external screen already available
        if UIScreen.screens.count > 1{
            
            let newScreen = UIScreen.screens.last
            let screenDimensions = newScreen!.bounds
            let newWindow = UIWindow(frame: screenDimensions)
            newWindow.screen = newScreen!
            
            self.configureAuxilliaryInterface(with: newWindow)
            
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
        
        
        self.view.addSubview(self.preview)
        self.preview.updateConstraintsIfNeeded()
        
       
        
    }
    
}


