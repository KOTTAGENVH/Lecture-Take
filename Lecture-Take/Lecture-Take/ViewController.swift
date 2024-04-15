//
//  ViewController.swift
//  Lecture-Take
//
//  Created by Nowen on 2024-04-12.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchbar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the dataSource of the tableView to self
        tableView.dataSource = self

    }
    
    

    
    @IBAction func didTapAdd() {
        print("Button Clicked")
        let vc = storyboard?.instantiateViewController(identifier: "addTask") as! AddTaskViewController
        vc.title = "New Note"
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows you want to display in your table view
        return 0 // Replace 0 with the actual number of rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Implement this method to provide cells for your tableView
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        // Configure the cell...
        return cell
    }
}
