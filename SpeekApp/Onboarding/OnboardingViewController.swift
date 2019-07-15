//
//  OnboardingViewController.swift
//  SpeekApp
//
//  Created by Caesar Alberto Fernandez on 15/07/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {

    @IBOutlet weak var pict1: UIImageView!
    @IBOutlet weak var pict2: UIImageView!
    @IBOutlet weak var pict3: UIImageView!
    @IBOutlet weak var shapingBtn: UIButton!
    
    @IBAction func startedBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeView = storyboard.instantiateViewController(withIdentifier: "HomeView") as! OnBoardViewController
        self.present(homeView, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        pict1.layer.cornerRadius = 10
        pict2.layer.cornerRadius = 10
        pict3.layer.cornerRadius = 10
        shapingBtn.layer.cornerRadius = 10
        
    }
    

}
