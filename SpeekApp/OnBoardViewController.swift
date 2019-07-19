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
    @IBOutlet weak var topicFld: UITextField!

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
        
//        if topicFld.text! ==  "" {
//            let alert = UIAlertController(title: "Fill your topic please", message: nil, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//            self.present(alert, animated: true)
//        }
//        else{
//            self.performSegue(withIdentifier: "recordScreen", sender: self)
//        }
               

       self.performSegue(withIdentifier: "recordScreen", sender: self)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard (sender as? String) != nil else {return}
        let topic = sender as? String
        
        let controller = segue.destination
        let screenRecorder = controller as! ScreenViewController
        screenRecorder.topic = topic!
        
        
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
         self.tabBarController?.tabBar.isHidden = false
    }
}

