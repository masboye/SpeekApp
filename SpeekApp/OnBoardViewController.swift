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
        
        
        
        let date = Date()
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "dd.MM.yyyy"
        let a =  dateformatter.string(from: date)
        print(a)


        let modelCore = CoreDataHelper()
        let topicModel = TopicModel(title: "cc", recording: RecordingModel(title: "pro", date: dateformatter.date(from: a)!, video: VideoModel(title: "ing", filePath: "ba", eyeContactLost: 2, attention: 3, smileDuration: 3)))

        modelCore.saveTopic(topicModel: topicModel)
        let asd:[Topic] = modelCore.fetch(entityName: "Topic")
        
        for waw in asd {
            let aaa = waw.topicToRec?.allObjects
            print(waw.title)
            let arrayy:[Recording] = aaa as! [Recording]
            for asw in arrayy {
                print(asw.title)
            }
        }
        

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

