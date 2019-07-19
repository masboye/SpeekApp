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
    
    var topicModel: TopicModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = topicModel?.recording.title
        
        if let converterSmile = topicModel?.recording.video.smileDuration {
            let smile = String(converterSmile)
            smileResultPercentage.text = smile
        }
        
        if let converterContact = topicModel?.recording.video.eyeContactLost {
            let eye = String(converterContact)
            lostContactPercentage.text = eye
        }
        
        if let converterLeft = topicModel?.recording.video.attentionLeft {
            let left = String(converterLeft)
            facingLeftPercentage.text = left
        }
        
        if let converterRight = topicModel?.recording.video.attentionRight {
            let right = String(converterRight)
            facingRightPercentage.text = right
        }
        
        if let converterCenter = topicModel?.recording.video.attentionCenter {
            let center = String(converterCenter)
            facingCenterPercentage.text = center
        }
        
        
        

        // Do any additional setup after loading the view.
    }

}
