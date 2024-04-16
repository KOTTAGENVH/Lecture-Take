//
//  AddTaskViewController.swift
//  Lecture-Take
//
//  Created by Nowen on 2024-04-15.
//

import UIKit
import Speech
import CoreData

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
    private var titleText: String = ""
    private var transcribedText: String = ""
    private var selectedImage: UIImage?
    
    // Core Data context
        private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titlelabel.text = "Title"
        titlefield.delegate = self
        descriptionlabel.text = "Description"
        descriptionfield.delegate = self
        camerabutton.isEnabled = true
        transcribebutton.isEnabled = true
        savebutton.isEnabled = false
        navigationItem.title =  "Add Note"
        speechRecognizer.delegate = self
    }
    
    // Function to handle the save button click
      @IBAction func saveButtonClicked(_ sender: UIButton) {
          saveData()
      }
      
    // Function to save data to CoreData
       private func saveData() {
           let newLectureNote = LectureNotes(context: context)
           newLectureNote.title = titleText
           newLectureNote.descriptionNote = transcribedText
           newLectureNote.date = Date()
           
           // Generate unique 4-digit ID
           newLectureNote.id = generateUniqueID()
           // Save image if available
           if let selectedImage = selectedImage {
               newLectureNote.image = selectedImage.jpegData(compressionQuality: 1.0)
           }
           do {
               try context.save()
               print("Data saved successfully.")
               // Optionally, you can show an alert or perform any other action upon successful save.
           } catch {
               print("Error saving data: \(error.localizedDescription)")
               // Handle the error appropriately, such as showing an alert to the user.
           }
       }
       
       // Function to generate a unique 4-digit ID
       private func generateUniqueID() -> Int32 {
           var isUnique = false
           var id: Int32 = 0
           
           // Keep generating IDs until a unique one is found
           while !isUnique {
               id = Int32.random(in: 1000...9999)
               let fetchRequest: NSFetchRequest<LectureNotes> = LectureNotes.fetchRequest()
               fetchRequest.predicate = NSPredicate(format: "id == %d", id)
               do {
                   let count = try context.count(for: fetchRequest)
                   isUnique = count == 0
               } catch {
                   print("Error checking for existing ID: \(error.localizedDescription)")
                   // Handle the error appropriately
               }
           }
           
           return id
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
        toggleDescriptionFieldInteraction()
    }
    
    
    
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
                        self.transcribedText += result.bestTranscription.formattedString
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
    
    // Function to toggle interaction of descriptionfield
    private func toggleDescriptionFieldInteraction() {
        descriptionfield.isEditable = !audioEngine.isRunning
    }
    
    // Function to handle changes in descriptionfield and titlefield
    func textViewDidChange(_ textView: UITextView) {
        if textView === descriptionfield {
            transcribedText = textView.text
            print("Description field text: \(transcribedText)")
        }
    }
    
    // UITextFieldDelegate method to handle changes in titlefield
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField === titlefield {
            titleText = textField.text ?? ""
            print("Title field text: \(titleText)")
            
            // Disable savebutton if titleText is empty
            if titleText.isEmpty {
                      savebutton.isEnabled = false
                  } else {
                      savebutton.isEnabled = true
                  }
        }
    }
    
    
}
