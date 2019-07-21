//
//  FirstViewController.swift
//  SpeekApp
//
//  Created by boy setiawan on 08/07/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import UIKit


extension UIViewController{
    func HideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func DismissKeyboard() {
        view.endEditing(true)
    }
}

class OnBoardViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var topicFld: UITextField!

    @IBAction func topicEdit(_ sender: UITextField) {
        topicTemp = sender.text!
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        topicFld.delegate = self
        self.startButton.layer.cornerRadius = 10
    }
    
    override func viewDidAppear(_ animated: Bool) {
        topicFld.text = ""
        isGreen = false
        HideKeyboard()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @IBAction func startAction(_ sender: UIButton) {
        
                if topicFld.text! ==  "" {
                    let alert = UIAlertController(title: "Fill your topic please", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
                else{
                    self.performSegue(withIdentifier: "recordScreen", sender: self)
                }
        
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
}

