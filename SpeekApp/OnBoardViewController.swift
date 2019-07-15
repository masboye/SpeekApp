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


class OnBoardViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var topicFld: UITextField!
    @IBAction func rstBtn(_ sender: UIButton) {
        topicFld.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.startButton.layer.cornerRadius = 10
        self.HideKeyboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //self.becomeFirstResponder()
    }
    @IBAction func startAction(_ sender: UIButton) {
        
        //        let alert = UIAlertController(title: "What's your Topic?", message: nil, preferredStyle: .alert)
        //        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        //
        //        alert.addTextField(configurationHandler: { textField in
        //            textField.placeholder = "Input your topic here..."
        //        })
        //
        //        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
        //
        //            if let name = alert.textFields?.first?.text {
        //                self.performSegue(withIdentifier: "recordScreen", sender: name)
        //            }
        //        }))
        
        self.performSegue(withIdentifier: "recordScreen", sender: self)
        
        
        //self.present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard (sender as? String) != nil else {return}
        let topic = sender as? String
        
        let controller = segue.destination
        let screenRecorder = controller as! ScreenViewController
        screenRecorder.topic = topic!
        
        
    }
    
}

