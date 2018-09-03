//
//  ViewController.swift
//  Vision-CoreML
//
//  Created by Anuj Dutt on 9/3/18.
//  Copyright © 2018 Anuj Dutt. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageLabel: UITextView!
    
    // Variable for Picking images from local photo library
    private var imagePicker = UIImagePickerController()
    
    // Define CoreML Model
    private var model = GoogLeNetPlaces()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Define the Source Type from where we want to load the images
        self.imagePicker.sourceType = .photoLibrary
        self.imagePicker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Delegate to tell if selected image has been loaded or not
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Dismiss Image Picker
        dismiss(animated: true, completion: nil)
        //Access selected image
        guard let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            print("Error loading image !!")
            return
        }
        // Image loaded successfully, show it on screen
        self.imageView.image = pickedImage
        
        // Function to Process image using CoreML Model
        self.processImage(image: pickedImage)
    }
    
    // Action Button to Capture or Load Images from Image Source
    @IBAction func captureImage(_ sender: Any) {
        // Execute Image Picker on click
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    // Function to process image using CoreML
    func processImage(image: UIImage) {
        // Create a Vision Model
        guard let visionModel = try? VNCoreMLModel(for: self.model.model) else {
            fatalError("Unable to create Vision Model !!")
        }
        
        // Create Vision Request
        let visionRequest = VNCoreMLRequest(model: visionModel) { request, error in
            if (error != nil){
                return
            }
            
            guard let results = request.results as? [VNClassificationObservation] else {
                return
            }
            
            // Get Predictions from CoreML Model
            let predictions = results.map { observation in
                "\(observation.identifier): \(observation.confidence * 100)"
            }
            
            // Show Predictions in Text Box
            DispatchQueue.main.async {
                self.imageLabel.text = predictions.joined(separator: "\n")
            }
        }
        
        // Vision Request Handler
        let visionRequestHandler = VNImageRequestHandler(ciImage: CIImage(image: image)!, orientation: .up, options: [:])
        
        // Run the Vision Request on Main Thread
        DispatchQueue.global(qos: .userInteractive).async {
            try! visionRequestHandler.perform([visionRequest])
        }
    }

}

