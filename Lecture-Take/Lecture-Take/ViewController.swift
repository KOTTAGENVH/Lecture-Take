//
//  ViewController.swift
//  Lecture-Take
//
//  Created by Nowen on 2024-04-12.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    
    @IBAction func didTapAdd() {
        let vc = storyboard?.instantiateViewController(identifier: "addTask") as!NoteDetailViewController
        vc.title = "New Note"
        navigationController?.pushViewController(vc, animated: true)
    }
}



