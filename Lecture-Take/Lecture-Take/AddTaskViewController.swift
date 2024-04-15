//
//  AddTaskViewController.swift
//  Lecture-Take
//
//  Created by Nowen on 2024-04-15.
//

import UIKit

class AddTaskViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet var titlelabel: UILabel!
    @IBOutlet var descriptionlabel: UILabel!
    @IBOutlet var titlefield: UITextField!
    @IBOutlet var descriptionfield: UITextView!
    @IBOutlet var camerabutton: UIButton!
    @IBOutlet var transcribebutton: UIButton!
    @IBOutlet var imageviewer: UIImageView!
    @IBOutlet var savebutton: UIButton!


    override func viewDidLoad() {
        super.viewDidLoad()
        titlelabel.text = "Title"
        titlefield.delegate = self
        descriptionlabel.text = "Description"
        descriptionfield.delegate = self
        camerabutton.isEnabled = true
        transcribebutton.isEnabled = true
//        imageviewer.image
        savebutton.isEnabled = true
        navigationItem.title =  "Add Note"
      
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
