//
//  ResultViewController.swift
//  SpeekApp
//
//  Created by boy setiawan on 17/07/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import UIKit
import AVKit


class ResultViewController: UIViewController {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var discardButton: UIButton!
    @IBOutlet weak var videoPlayer: UIView!
    @IBOutlet weak var previewVideo: UIImageView!
    
    var url:URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.saveButton.layer.cornerRadius = 10
        self.discardButton.layer.cornerRadius = 10
        self.HideKeyboard()
        
        // Do any additional setup after loading the view.
        let playVideoTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.videoTap(_:)))
        videoPlayer.addGestureRecognizer(playVideoTapGesture)
        
        
        
    }

    @objc func videoTap( _ recognizer : UITapGestureRecognizer){
        
        let player = AVPlayer(url: url)
        player.allowsExternalPlayback = true
        player.usesExternalPlaybackWhileExternalScreenIsActive = true
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true) {
            player.play()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let previewImage = videoPreviewImage(url: url) else {return}
        
        self.previewVideo.image = previewImage
    }
    
    @IBAction func discardPractice(_ sender: UIButton) {
        
        //delete the video file
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                
                try FileManager.default.removeItem(at: url)
                
            }
        } catch {
            print(error)
        }
        self.performSegue(withIdentifier: "backToBeginning", sender: self)
    }
    
    @IBAction func savePractice(_ sender: UIButton) {
        self.performSegue(withIdentifier: "backToBeginning", sender: self)
    }
    
    func videoPreviewImage(url: URL) -> UIImage? {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        //generator.appliesPreferredTrackTransform = true
        if let cgImage = try? generator.copyCGImage(at: CMTime(seconds: 2, preferredTimescale: 60), actualTime: nil) {
            
            return UIImage(cgImage: cgImage)
        }
        else {
            
            return nil
        }
    }
}
