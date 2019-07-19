//
//  ResultViewController.swift
//  SpeekApp
//
//  Created by boy setiawan on 17/07/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import UIKit
import AVKit



class ResultViewController: UIViewController, UITextFieldDelegate {
    var textTemp: String?
    
    @IBOutlet weak var recTitleTextField: UITextField!
    @IBAction func txtField(_ sender: UITextField) {
        textTemp = sender.text
    }
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var discardButton: UIButton!
    @IBOutlet weak var videoPlayer: UIView!
    @IBOutlet weak var previewVideo: UIImageView!
    
    @IBOutlet weak var lostEyeContactResult: UILabel!
    @IBOutlet weak var smileResult: UILabel!
    @IBOutlet weak var facingRight: UILabel!
    @IBOutlet weak var facingCenter: UILabel!
    
    @IBOutlet weak var facingLeft: UILabel!
    
    @IBOutlet weak var titleSave: UITextField!
    
    var practiceResult: PracticeResult!
    var dataHelper = CoreDataHelper()
    var topicModel = TopicModel()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.HideKeyboard()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recTitleTextField.delegate = self
        print("Topic : \(topicTemp)")
        // Do any additional setup after loading the view.
        self.saveButton.layer.cornerRadius = 10
        self.discardButton.layer.cornerRadius = 10
        print(topicTemp)
        // Do any additional setup after loading the view.
        let playVideoTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.videoTap(_:)))
        videoPlayer.addGestureRecognizer(playVideoTapGesture)
        
        let resultOfSmile = (Float(practiceResult.smile) / practiceResult.duration) * 100.0
        
        let resultOfContact = (Float(practiceResult.eyeClosedAccumulation) / practiceResult.duration) * 100.0
        
        let resultOfFacingLeft = (Float(practiceResult.focusOnLeftSide) / practiceResult.duration) * 100.0
        
        let resultOfFacingRight = (Float(practiceResult.focusOnRightSide) / practiceResult.duration) * 100.0
        
        let resultOfFacingCenter = (Float(practiceResult.focusOnCenterSide) / practiceResult.duration) * 100.0
        
        self.smileResult.text = "Smile Maintaned \t\t\t\t:\t\(String(format: "%.1f", resultOfSmile)) %"
        self.lostEyeContactResult.text = "Lost Eye Contact \t\t\t\t:\t\(String(format: "%.1f", resultOfContact)) %"
        self.facingCenter.text = "Focus On Center \t\t\t\t:\t\(String(format: "%.1f", resultOfFacingCenter)) %"
        self.facingRight.text = "Focus On Right \t\t\t\t\t:\t\(String(format: "%.1f", resultOfFacingRight)) %"
        self.facingLeft.text = "Focus On Left \t\t\t\t\t:\t\(String(format: "%.1f", resultOfFacingLeft)) %"
    }
    
    @objc func videoTap( _ recognizer : UITapGestureRecognizer){
        
        let player = AVPlayer(url: practiceResult.videoURL)
        player.allowsExternalPlayback = true
        player.usesExternalPlaybackWhileExternalScreenIsActive = true
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true) {
            player.play()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let previewImage = videoPreviewImage(url: practiceResult.videoURL) else {return}
        
        self.previewVideo.image = previewImage
    }
    
    @IBAction func discardPractice(_ sender: UIButton) {
        
        //delete the video file
        do {
            if FileManager.default.fileExists(atPath: practiceResult.videoURL.path) {
                
                try FileManager.default.removeItem(at: practiceResult.videoURL)
                
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
        
        print(textTemp!)
        print(topicModel.title)
        
        topicModel.recording.title = textTemp!
        topicModel.title = topicTemp
        topicModel.recording.date = Date()
        topicModel.recording.video.title = textTemp!
        topicModel.recording.video.smileDuration = Int64(practiceResult.smile)
        topicModel.recording.video.eyeContactLost = Int64(practiceResult.eyeClosedAccumulation)
        
        topicModel.recording.video.attentionLeft = Int64(practiceResult.focusOnLeftSide)
        
        topicModel.recording.video.attentionRight = Int64(practiceResult.focusOnRightSide)
        
        topicModel.recording.video.attentionCenter = Int64(practiceResult.focusOnCenterSide)
        
        dataHelper.saveTopic(topicModel: topicModel)
        
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { (alert) in
            self.performSegue(withIdentifier: "backToBeginning", sender: self)
        }))
        self.present(alertController, animated: true, completion: nil)
        
        
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

