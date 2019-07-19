//
//  CalculationWaitViewController.swift
//  SpeekApp
//
//  Created by boy setiawan on 19/07/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import UIKit

class CalculationWaitViewController: UIViewController {

    @IBOutlet weak var progressView: UIProgressView!
    private var timerForRecording:Timer?
    private var counter = 0
    private let max = 10
    
    var practiceResult: PracticeResult!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async {
            self.timerForRecording = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (time) in
                
                
                DispatchQueue.main.async {
                    self.counter += 1
                    let ratio = Float(self.counter) / Float(self.max)
                    
                    self.progressView.setProgress(Float(ratio), animated: true)
                    self.progressView.setNeedsDisplay()
                }
                
                if self.counter > 10
                {
                    self.performSegue(withIdentifier: "showFinalResult", sender: self.practiceResult )
                }
            }
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let timer = self.timerForRecording else {return}
        timer.fire()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        guard let timer = self.timerForRecording else {return}
        timer.invalidate()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //guard (sender as? URL) != nil else {return}
        guard let result = sender as? PracticeResult else {return}
        
        let controller = segue.destination
        let resultView = controller as! ResultViewController
        
        resultView.practiceResult = result
    }
    
}
