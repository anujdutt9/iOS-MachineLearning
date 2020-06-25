//
//  ViewController.swift
//  Utternace Entity Classifier
//
//  Created by Anuj Dutt on 2/18/19.
//  Copyright © 2019 Anuj Dutt. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var inputText: UITextField!
    @IBOutlet weak var outputIntent: UITextField!
    @IBOutlet weak var outputAccuracy: UITextField!
    
    // Initialize the Model
    let model = SwiftNLCModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func submit(_ sender: Any) {
        if let prediction = model.predict(inputText.text!) {
            outputIntent.text = "\(prediction.0)"
            outputAccuracy.text = "(\(String(format: "%2.1f", prediction.1 * 100))%)"
        }
        else {
            outputIntent.text = "error"
            outputAccuracy.text = "error"
        }
    }
    
}

