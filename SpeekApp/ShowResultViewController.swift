//
//  ShowResultViewController.swift
//  SpeekApp
//
//  Created by Caesar Alberto Fernandez on 17/07/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import UIKit

class ShowResultViewController: UIViewController {
    @IBOutlet weak var smileResultPercentage: UILabel!
    
    @IBOutlet weak var lostContactPercentage: UILabel!
    @IBOutlet weak var facingCenterPercentage: UILabel!
    @IBOutlet weak var facingRightPercentage: UILabel!
    @IBOutlet weak var facingLeftPercentage: UILabel!
    @IBOutlet weak var videoPlayer: UIImageView!
    @IBOutlet weak var videoPlayBtn: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
