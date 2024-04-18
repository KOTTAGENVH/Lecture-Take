//
//  NoteDetailViewController.swift
//  Lecture-Take
//
//  Created by Nowen on 2024-04-17.
//

import UIKit
import CoreData
import Speech

class NoteDetailViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SFSpeechRecognizerDelegate {
    
    @IBOutlet var titlelabel: UILabel!
    @IBOutlet var descriptionlabel: UILabel!
    @IBOutlet var titlefield: UITextField!
    @IBOutlet var descriptionfield: UITextView!
    @IBOutlet var camerabutton: UIButton!
    @IBOutlet var transcribebutton: UIButton!
    @IBOutlet var deletebutton: UIButton!
    @IBOutlet var imageviewer: UIImageView!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private let audioEngine = AVAudioEngine()
    private var titleText: String = ""
    private var transcribedText: String = ""
    private var selectedImage: UIImage?
    private var imagePickerController: UIImagePickerController?
    
    
    var selectedNote: Note? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        titlelabel.text = "Title"
        titlefield.delegate = self
        descriptionlabel.text = "Description"
        descriptionfield.delegate = self
        camerabutton.isEnabled = true
        deletebutton.isEnabled = false
        transcribebutton.isEnabled = true
        navigationItem.title =  "Add Note"
        speechRecognizer.delegate = self
        
        if(selectedNote != nil)
        {
            titlefield.text = selectedNote?.title
            descriptionfield.text = selectedNote?.desc
//            if let imageData = selectedNote?.image {
//                imageviewer.image = UIImage(data: (imageData))!
//            }

            deletebutton.isEnabled = true
            
        }
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

    
        private func toggleDescriptionFieldInteraction() {
            descriptionfield.isEditable = !audioEngine.isRunning
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
                            self.descriptionfield.text += result.bestTranscription.formattedString
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
    
            transcribebutton.setTitle("Transcribe", for: .normal)
        }
    
    
    @IBAction func saveAction(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        if selectedNote == nil {

            let entity = NSEntityDescription.entity(forEntityName: "Note", in: context)
            let newNote = Note(entity: entity!, insertInto: context)
            newNote.id = noteList.count as NSNumber
            newNote.title = titlefield.text
            newNote.desc = descriptionfield.text
            newNote.date = Date()
//            if let pickedImage = imageviewer.image {
//                newNote.image = pickedImage.pngData()
//            }
            
            
            do {
                try context.save()
                noteList.append(newNote)
                navigationController?.popViewController(animated: true)
            } catch {
                print("Context save error: \(error)")
            }
        } else {
         
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
            do {
                let results = try context.fetch(request) as! [Note]
                for note in results {
                    if note == selectedNote {
                        note.title = titlefield.text
                        note.desc = descriptionfield.text
//                        if let pickedImage = imageviewer.image {
//                            note.image = pickedImage.pngData()
//                        }
                        try context.save()
                        navigationController?.popViewController(animated: true)
                    }
                }
            } catch {
                print("Fetch failed: \(error)")
            }
        }
    }

    @IBAction func cameraButtonClicked(_ sender: UIButton) {
        imagePickerController = UIImagePickerController()
        imagePickerController?.delegate = self
        imagePickerController?.sourceType = .photoLibrary
        present(imagePickerController!, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            imageviewer.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }

    
 
 //To update the deletedate and leave the core data in core data
//    @IBAction func DeleteNote(_ sender: Any)
//    {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
//        
//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
//        do {
//            let results:NSArray = try context.fetch(request) as NSArray
//            for result in results
//            {
//                let note = result as! Note
//                if(note == selectedNote)
//                {
//                    note.deletedDate = Date()
//                    try context.save()
//                    navigationController?.popViewController(animated: true)
//                }
//            }
//        }
//        catch
//        {
//            print("Fetch Failed")
//        }
//    }
    
    //To delete the note entirely from core data
    
    @IBAction func DeleteNote(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        if let noteToDelete = selectedNote {
            context.delete(noteToDelete)
            
            do {
                try context.save()
                navigationController?.popViewController(animated: true)
            } catch {
                print("Failed to delete note: \(error)")
            }
        }
    }

    
}


