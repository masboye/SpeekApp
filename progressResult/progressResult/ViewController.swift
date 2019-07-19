//
//  ViewController.swift
//  progressResult
//
//  Created by boy setiawan on 19/07/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var progress: UIProgressView!
    
    private var timerForRecording:Timer?
    private var counter = 0
    private let max = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.timerForRecording = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (time) in
            
            self.counter += 1
            let ratio = Float(self.counter) / Float(self.max)
            DispatchQueue.main.async {
                self.progress.setProgress(Float(ratio), animated: true)
            }
            
            if self.counter > 10
            {
                print("Bingo")
            }
        }
    }


    override func viewWillAppear(_ animated: Bool) {
        
        guard let timer = self.timerForRecording else {return}
        timer.fire()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let timer = self.timerForRecording else {return}
        timer.invalidate()
    }
    
}

