//
//  ScreenViewController.swift
//  SpeekApp
//
//  Created by boy setiawan on 08/07/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import UIKit

class ScreenViewController: UIViewController {
    
    @IBOutlet weak var stackButton: UIStackView!
    @IBOutlet weak var preview: UIView!
    @IBOutlet weak var recordButton: UIButton!
    
    var recordButtonStatus = false
    var showStackStatus = true
    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        
        if !self.recordButtonStatus {
            
            self.recordButton.setImage(UIImage(named: "stop record"), for: .normal)
            self.recordButtonStatus = true
            self.stackButton.isHidden = true
            self.showStackStatus = false
           
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
        
    }
    
    
    
}


