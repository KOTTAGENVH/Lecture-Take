//
//  NoteDetailViewController.swift
//  Lecture-Take
//
//  Created by Nowen on 2024-04-17.
//

import UIKit
import CoreData
import Speech
import PDFKit

//Class to view single note, edit and delete
class NoteDetailViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SFSpeechRecognizerDelegate {
    
    @IBOutlet var titlelabel: UILabel!
    @IBOutlet var descriptionlabel: UILabel!
    @IBOutlet var titlefield: UITextField!
    @IBOutlet var descriptionfield: UITextView!
    @IBOutlet var camerabutton: UIButton!
    @IBOutlet var transcribebutton: UIButton!
    @IBOutlet var deletebutton: UIButton!
    @IBOutlet var downloadbutton: UIButton!
    @IBOutlet var imageviewer: UIImageView!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
     let audioEngine = AVAudioEngine()
    private var titleText: String = ""
    private var transcribedText: String = ""
    private var selectedImage: UIImage?
    private var imagePickerController: UIImagePickerController?
    
    var uploadedimage: Data?
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
        downloadbutton.isEnabled = false
        transcribebutton.isEnabled = true
        navigationItem.title =  "Note"
        speechRecognizer.delegate = self
        
        if(selectedNote != nil)
        {
            titlefield.text = selectedNote?.title
            descriptionfield.text = selectedNote?.desc
            imageviewer.image = UIImage(data: selectedNote?.imageData ?? Data())
            deletebutton.isEnabled = true
            downloadbutton.isEnabled = true
        }
        
        // Add tap gesture recognizer to imageviewer
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewerTapped))
                imageviewer.addGestureRecognizer(tapGesture)
                imageviewer.isUserInteractionEnabled = true
    }
    
    @IBAction func downloadPdf() {
        
        guard let title = selectedNote?.title, let desc = selectedNote?.desc, let imageData = selectedNote?.imageData else {
            print("Error: Missing note data")
            return
        }

        // Create a PDF document
        let pdfDocument = PDFDocument()
        let page = PDFPage()

        // Add title text
        let titleText = PDFAnnotation(bounds: CGRect(x: 50, y: 700, width: 500, height: 50), forType: .freeText, withProperties: nil)
        titleText.contents = title
        page.addAnnotation(titleText)

        // Add description text
        let descText = PDFAnnotation(bounds: CGRect(x: 50, y: 650, width: 500, height: 50), forType: .freeText, withProperties: nil)
        descText.contents = desc
        page.addAnnotation(descText)

        // Add image to the PDF page
        if let image = UIImage(data: imageData) {
            let imageSize = CGSize(width: 300, height: 200)
            let imageRect = CGRect(x: 50, y: 500, width: imageSize.width, height: imageSize.height)
            image.draw(in: imageRect)
        }

        pdfDocument.insert(page, at: 0)

        // Save the PDF to a temporary file
        let tempPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(title).pdf")
        pdfDocument.write(to: tempPath)

        // Share the PDF file
        let activityViewController = UIActivityViewController(activityItems: [tempPath], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        present(activityViewController, animated: true, completion: nil)
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
    
    //Button Action for save button
    @IBAction func saveAction(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        // Check if titleField.text is nil
        if titlefield.text == nil || titlefield.text?.isEmpty == true {
            // Create and configure the alert controller
            let alertController = UIAlertController(title: "Error", message: "Title cannot be empty", preferredStyle: .alert)
            
            // Add an action to the alert (e.g., OK button)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            // Present the alert
            present(alertController, animated: true, completion: nil)
            
            
        } else {
            
            if selectedNote == nil {
                
                let entity = NSEntityDescription.entity(forEntityName: "Note", in: context)
                let newNote = Note(entity: entity!, insertInto: context)
                newNote.id = noteList.count as NSNumber
                newNote.title = titlefield.text
                newNote.desc = descriptionfield.text
                newNote.imageData = uploadedimage
                newNote.date = Date()
                
                
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
                            note.imageData = uploadedimage
                            try context.save()
                            navigationController?.popViewController(animated: true)
                        }
                    }
                } catch {
                    print("Fetch failed: \(error)")
                }
            }
        }
    }
    
    //Button action for camera button
    @IBAction func cameraButtonClicked(_ sender: UIButton) {
        imagePickerController = UIImagePickerController()
        imagePickerController?.delegate = self
        imagePickerController?.sourceType = .photoLibrary
        present(imagePickerController!, animated: true, completion: nil)
    }
    
    //function to enlarge image view on tap
    @objc func imageViewerTapped() {
        // Check if there's an image in imageviewer
        if let image = imageviewer.image {
            // Create a UIAlertController
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            
            // Create a UIImageView and set its image
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            
            // Add the UIImageView to the UIAlertController
            alertController.view.addSubview(imageView)
            
            // Add constraints to the UIImageView to make it fit inside the alert controller
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 16),
                imageView.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 16),
                imageView.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -16),
                imageView.bottomAnchor.constraint(equalTo: alertController.view.bottomAnchor, constant: -16)
            ])
            
            // Add an action to dismiss the alert controller
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            // Present the UIAlertController
            present(alertController, animated: true, completion: nil)
        }
    }

   
    
    //Function to disable description during transcribe
    private func toggleDescriptionFieldInteraction() {
        descriptionfield.isEditable = !audioEngine.isRunning
    }
    
    // Start recording audio for transcribe
     func startRecording() {
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
    
    // Stop recording audio on transcribe
     func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        
        // Remove tap from the audio input node
        audioEngine.inputNode.removeTap(onBus: 0)
        
        transcribebutton.setTitle("Transcribe", for: .normal)
    }
    

    //Upload image from photos
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            if let imageData = pickedImage.jpegData(compressionQuality: 1.0) {
                       uploadedimage = imageData
                       imageviewer.image = pickedImage
                   }
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    
    //To update the delete date and leave the core data in core data
    @IBAction func DeleteNote(_ sender: Any)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        do {
            let results:NSArray = try context.fetch(request) as NSArray
            for result in results
            {
                let note = result as! Note
                if(note == selectedNote)
                {
                    note.deletedDate = Date()
                    try context.save()
                    navigationController?.popViewController(animated: true)
                }
            }
        }
        catch
        {
            print("Fetch Failed")
        }
    }
}
    //To delete the note entirely from core data(This function is optional)
    
//    @IBAction func DeleteNote(_ sender: Any) {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let context = appDelegate.persistentContainer.viewContext
//        
//        if let noteToDelete = selectedNote {
//            context.delete(noteToDelete)
//            
//            do {
//                try context.save()
//                navigationController?.popViewController(animated: true)
//            } catch {
//                print("Failed to delete note: \(error)")
//            }
//        }
//    }
//
//    
//}


