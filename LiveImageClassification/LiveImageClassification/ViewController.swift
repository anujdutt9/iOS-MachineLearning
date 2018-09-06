//
//  ViewController.swift
//  LiveImageClassification
//
//  Created by Anuj Dutt on 9/5/18.
//  Copyright © 2018 Anuj Dutt. All rights reserved.
//

// Aim: This project aims to make use of the real time camera stream as input to an iPhone and use a pre-trained classification CoreML      Model to classify objects and show their names with model's confidence in the text field.

import UIKit
import AVFoundation
import CoreML
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var cameraView: UIImageView!
    @IBOutlet weak var imageLabel: UITextView!
    
    // Define a Session using AVCaptureSession.
    // This helps capture the video input
    let session = AVCaptureSession()
    // ------- Define the CoreML Model -------
    private let resnetModel: Resnet50 = Resnet50()
    // -------- Vision CoreML Request ---------
    private var requests = [VNCoreMLRequest]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ----- Create Vision CoreML Request Function -------
        self.createVisionRequest()
        // ----- Function to start getting LIVE Video feed --------
        self.startLiveVideo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // ************************************
    // Function to start LIVE Video feed IN
    // ************************************
    private func startLiveVideo(){
        session.sessionPreset = AVCaptureSession.Preset.photo
        
        // Media type from which we'll be capturing the video feed
        let captureDevice = AVCaptureDevice.default(for: .video)
        
        // Device Feed input
        let deviceInput = try! AVCaptureDeviceInput(device: captureDevice!)
        
        // Device Feed output i.e. in form of video
        let deviceOutput = AVCaptureVideoDataOutput()
        
        // Device Output Video Settings
        // We'll capture the device video using the AVCapture Session
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        deviceOutput.setSampleBufferDelegate(self as AVCaptureVideoDataOutputSampleBufferDelegate, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        
        // Add all settings to Input Session
        session.addInput(deviceInput)
        session.addOutput(deviceOutput)
        
        // Display video preview on Image Layer
        let imageLayer = AVCaptureVideoPreviewLayer(session: session)
        imageLayer.frame = imageLayer.bounds
        
        // Add image layer to cameraview
        cameraView.layer.addSublayer(imageLayer)
        
        // Start the Camera Capture Session
        session.startRunning()
    }

    
    // ******************************************
    // Function to create a Vision CoreML Request
    // ******************************************
    private func createVisionRequest(){
        // Create Vision CoreML Model
        guard let model = try? VNCoreMLModel(for: self.resnetModel.model) else {
            fatalError("Error Loading Model !!")
        }
        
        // VNCoreML Request
        let request = VNCoreMLRequest(model: model) { request, err in
            // If error processing Request, then return
            if err != nil{
                return
            }
            
            // else process vision request and get observations
            guard let observations = request.results as? [VNClassificationObservation] else {
                // If no observations found, then return
                return
            }
            
            // If the model got the observations, get the predictions out of it with their probabilities
            let predictions = observations.map { observation in
                "The model thinks it's a \(observation.identifier) with a confidence of \(observation.confidence * 100.0)"
            }
            
            // Show out classifications in the text view
            DispatchQueue.main.async {
                self.imageLabel.text = predictions.joined(separator: "\n")
            }
            print(observations)
        }
        
        self.requests.append(request)
    }
    
    
    // *******************************************************************************************************************************
    // We have the coreML model and are capturing the video using the AVFoundation. now we need to pass the camera video frames to the CoreML Model and show the classification results in the text view.
    // This function is fired whenever the AVCamera Session is running and it captures the current camera frame from session.
    // *******************************************************************************************************************************
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // Capture Image Buffer
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        // Create a request options dictionary to provide us with camera data
        var requestOptions:[VNImageOption: Any] = [:]
        
        // Create Image Request Handler
        if let camData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil){
            requestOptions = [.cameraIntrinsics: camData]
        }
        
        // Fire the Vision Request
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 6)!, options: requestOptions)
        
        do {
            try imageRequestHandler.perform(self.requests)
        }
        // catch the error if any
        catch {
            print(error)
        }
    }
}

