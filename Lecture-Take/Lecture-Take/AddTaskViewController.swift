//
//  AddTaskViewController.swift
//  Lecture-Take
//
//  Created by Nowen on 2024-04-15.
//

import UIKit
import Speech

class AddTaskViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SFSpeechRecognizerDelegate {

    @IBOutlet var titlelabel: UILabel!
    @IBOutlet var descriptionlabel: UILabel!
    @IBOutlet var titlefield: UITextField!
    @IBOutlet var descriptionfield: UITextView!
    @IBOutlet var camerabutton: UIButton!
    @IBOutlet var transcribebutton: UIButton!
    @IBOutlet var imageviewer: UIImageView!
    @IBOutlet var savebutton: UIButton!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private let audioEngine = AVAudioEngine()

    override func viewDidLoad() {
        super.viewDidLoad()
        titlelabel.text = "Title"
        titlefield.delegate = self
        descriptionlabel.text = "Description"
        descriptionfield.delegate = self
        camerabutton.isEnabled = true
        transcribebutton.isEnabled = true
        savebutton.isEnabled = true
        navigationItem.title =  "Add Note"
        speechRecognizer.delegate = self
    }
    
    // Function to handle the camera button click
    @IBAction func cameraButtonClicked(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // UIImagePickerControllerDelegate method to handle image selection
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            imageviewer.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    // Function to start or stop voice recording
    @IBAction func transcribeButtonClicked(_ sender: UIButton) {
        if audioEngine.isRunning {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private var transcribedText: String = ""
    
    // Start recording audio
    private func startRecording() {
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        // Check if recognitionRequest is not nil
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }

        let audioSession = AVAudioSession.sharedInstance()
        do {
            // Set up audio session
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            // Configure recognition request
            recognitionRequest.shouldReportPartialResults = true

            // Start recognition task
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
                var isFinal = false

                if let result = result {
                    // Update transcribedText only if there's valid transcribed text
                    if !result.bestTranscription.formattedString.isEmpty {
                        self.transcribedText = result.bestTranscription.formattedString
                        self.descriptionfield.text = self.transcribedText
                    }
                    isFinal = result.isFinal
                }

                // Check for error or final result, then stop recording
                if error != nil || isFinal {
                    self.stopRecording()
                }
            }

            // Get input node and recording format
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)

            // Install tap on input node to append audio to recognition request
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                recognitionRequest.append(buffer)
            }

            // Prepare and start the audio engine
            audioEngine.prepare()
            try audioEngine.start()

            // Update UI to indicate recording state
            transcribebutton.setTitle("Recording", for: .normal)

        } catch {
            // Handle any errors that occur during setup
            print("Error setting up audio session: \(error.localizedDescription)")
        }
    }


    // Stop recording audio
    private func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        
        // Remove tap from the audio input node
        audioEngine.inputNode.removeTap(onBus: 0)
        
        // Set descriptionfield.text only if transcribedText is not empty
        if !transcribedText.isEmpty {

            descriptionfield.text = transcribedText
        }else {
            print("empty")
        }
        
        transcribebutton.setTitle("Transcribe", for: .normal)
    }

}
