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
        
        let alertController = UIAlertController(title: "SpeekApp", message:
            "Discarding the recording successful", preferredStyle: .alert)
       
        alertController.addAction(UIAlertAction(title: "Discard", style: .default, handler: { (alert) in
            self.performSegue(withIdentifier: "backToBeginning", sender: self)
        }))
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    
    @IBAction func savePractice(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "SpeekApp", message:
            "Saving the recording successful", preferredStyle: .alert)
        
//        let date = Date()
//        let dateformatter = DateFormatter()
//        dateformatter.dateFormat = "dd.MM.yyyy"
//        let a =  dateformatter.string(from: date)
//        print(a)
//        
//        
//        let modelCore = CoreDataHelper()
//        let topicModel = TopicModel(title: "cc", recording: RecordingModel(title: "pro", date: dateformatter.date(from: a)!, video: VideoModel(title: "ing", filePath: "ba", eyeContactLost: 2, attention: 3, smileDuration: 3)))
//        
//        modelCore.saveTopic(topicModel: topicModel)
//        let asd:[Topic] = modelCore.fetch(entityName: "Topic")
//        
//        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { (alert) in
//            self.performSegue(withIdentifier: "backToBeginning", sender: self)
//        }))
//        self.present(alertController, animated: true, completion: nil)
        
        
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
