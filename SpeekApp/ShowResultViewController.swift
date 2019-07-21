//
//  ShowResultViewController.swift
//  SpeekApp
//
//  Created by Caesar Alberto Fernandez on 17/07/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import UIKit
import AVKit

class ShowResultViewController: UIViewController {
    @IBOutlet weak var smileResultPercentage: UILabel!
    @IBOutlet weak var lostContactPercentage: UILabel!
    @IBOutlet weak var facingCenterPercentage: UILabel!
    
    @IBOutlet weak var videoPlayer: UIView!
    @IBOutlet weak var videoPlayerPreview: UIImageView!
    
    var topicModel: TopicModel!
    
    @objc func playVideo( _ recognizer : UITapGestureRecognizer){
        let fileURL:URL = URL(fileURLWithPath: topicModel.recording.video.filePath)
        let player = AVPlayer(url: fileURL)
        player.allowsExternalPlayback = true
        player.usesExternalPlaybackWhileExternalScreenIsActive = true
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true) {
            player.play()
        }
    }
    
    func videoPreviewImage(url: URL) -> UIImage? {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        //generator.appliesPreferredTrackTransform = true
        print("a")
        if let cgImage = try? generator.copyCGImage(at: CMTime(seconds: 2, preferredTimescale: 60), actualTime: nil) {
            print("v")
            return UIImage(cgImage: cgImage)
        }
        else {
            print("s")
            return nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let fileURL:URL = URL(fileURLWithPath: topicModel.recording.video.filePath)
        print(fileURL.absoluteString)
        guard let previewImage = videoPreviewImage(url: fileURL) else {return}
        print("here")
        self.videoPlayerPreview.image = previewImage

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let playVideoTapGesture = UITapGestureRecognizer(target: self, action: #selector(playVideo(_:)))
        videoPlayer.addGestureRecognizer(playVideoTapGesture)
        
        navigationItem.title = topicModel?.recording.title
        
        if let converterSmile = topicModel?.recording.video.smileDuration {
            let smile = String(converterSmile)
            //smileResultPercentage.text = "\(smileResultPercentage.text!) \(smile)"
            //not fixed
            smileResultPercentage.text = "Smile Maintaned \t\t\t\t:\t\(smile) %"
        }
        
        if let converterContact = topicModel?.recording.video.eyeContactLost {
            let eye = String(converterContact)
//            lostContactPercentage.text = "\(lostContactPercentage.text!) \(eye)"
            //not fixed
            lostContactPercentage.text = "Lost Eye Contact \t\t\t\t:\t\(eye) %"
        }
        
//        if let converterLeft = topicModel?.recording.video.attentionLeft {
//            let left = String(converterLeft)
//            facingLeftPercentage.text = "\(facingLeftPercentage.text!) \(left)"
//        }
//
//        if let converterRight = topicModel?.recording.video.attentionRight {
//            let right = String(converterRight)
//            facingRightPercentage.text = "\(facingRightPercentage.text!) \(right)"
//        }
        
        if let converterCenter = topicModel?.recording.video.attentionCenter {
            let center = String(converterCenter)
//            facingCenterPercentage.text = "\(facingCenterPercentage.text!) \(center)"
            //not fixed
            facingCenterPercentage.text = "Attention \t\t\t\t\t\t:\t\(center) %"
        }
        
        //print(topicModel.recording.video.filePath)

        // Do any additional setup after loading the view.
    }

}
