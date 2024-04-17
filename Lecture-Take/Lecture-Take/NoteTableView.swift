//
//  NoteTableView.swift
//  Lecture-Take
//
//  Created by Nowen on 2024-04-17.
//


import UIKit
import CoreData

var noteList = [Note]()

class NoteTableView: UITableViewController, UISearchBarDelegate {
    var firstLoad = true
    @IBOutlet weak var searchBar: UISearchBar!
    var filteredNotes: [Note] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        loadData()
    }

    func loadData() {
        if firstLoad {
            firstLoad = false
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
            do {
                let results = try context.fetch(request)
                for result in results as! [Note] {
                    noteList.append(result)
                }
            } catch {
                print("Fetch Failed")
            }
        }
        filteredNotes = noteList // Initially, set filteredNotes to all notes
    }

    func filterNotes(with searchText: String) {
        let dateFormatter = DateFormatter() // Define the DateFormatter outside the closure
        
        if searchText.isEmpty {
            filteredNotes = noteList // If search text is empty, show all notes
        } else {
            filteredNotes = noteList.filter { note in
                let dateString = dateFormatter.string(from: note.date!) // Force unwrap note.date
                          return note.title?.range(of: searchText, options: .caseInsensitive) != nil ||
                                 dateString.range(of: searchText, options: .caseInsensitive) != nil
                      }
        }
        tableView.reloadData()
    }

    // MARK: - IBActions

    @IBAction func didTapAdd() {
        let vc = storyboard?.instantiateViewController(identifier: "addTask") as! NoteDetailViewController
        vc.title = "New Note"
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - UISearchBarDelegate

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let searchText = searchBar.text else { return }
        filterNotes(with: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filterNotes(with: "")
    }

    // MARK: - Table View Data Source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let noteCell = tableView.dequeueReusableCell(withIdentifier: "noteCellID", for: indexPath) as! NoteTableCelll

        let thisNote = filteredNotes[indexPath.row]

        noteCell.titleLabel.text = thisNote.title
        if let noteDate = thisNote.date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = dateFormatter.string(from: noteDate)
            noteCell.dateLabel.text = dateString // Assign directly to noteCell.dateLabel.text
        } else {
            noteCell.dateLabel.text = "Unknown Date"
        }

        return noteCell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredNotes.count
    }

    // MARK: - Navigation

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "editNote", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editNote" {
            let indexPath = tableView.indexPathForSelectedRow!
            let noteDetail = segue.destination as? NoteDetailViewController
            let selectedNote = filteredNotes[indexPath.row]
            noteDetail?.selectedNote = selectedNote
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}


//import UIKit
//import CoreData
//
//var noteList = [Note]()
//
//class NoteTableView: UITableViewController
//{
//    var firstLoad = true
//    
//    @IBAction func didTapAdd() {
//        let vc = storyboard?.instantiateViewController(identifier: "addTask") as!NoteDetailViewController
//        vc.title = "New Note"
//        navigationController?.pushViewController(vc, animated: true)
//    }
//
//    func nonDeletedNotes() -> [Note]
//    {
//        var noDeleteNoteList = [Note]()
//        for note in noteList
//        {
//            if(note.deletedDate == nil)
//            {
//                noDeleteNoteList.append(note)
//            }
//        }
//        return noDeleteNoteList
//    }
//    
//    override func viewDidLoad()
//    {
//        if(firstLoad)
//        {
//            firstLoad = false
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
//            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
//            do {
//                let results:NSArray = try context.fetch(request) as NSArray
//                for result in results
//                {
//                    let note = result as! Note
//                    noteList.append(note)
//                }
//            }
//            catch
//            {
//                print("Fetch Failed")
//            }
//        }
//    }
//    
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
//    {
//        let noteCell = tableView.dequeueReusableCell(withIdentifier: "noteCellID", for: indexPath) as! NoteTableCelll
//        
//        let thisNote: Note!
//        thisNote = nonDeletedNotes()[indexPath.row]
//        
//        noteCell.titleLabel.text = thisNote.title
//        if let noteDate = thisNote.date {
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Set your desired date format
//                let dateString = dateFormatter.string(from: noteDate)
//                noteCell.dateLabel.text = dateString
//            } else {
//                noteCell.dateLabel.text = "Unknown Date"
//            }
//            
//        
//        return noteCell
//    }
//    
//    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
//    {
//        return nonDeletedNotes().count
//    }
//    
//    override func viewDidAppear(_ animated: Bool)
//    {
//        tableView.reloadData()
//    }
//    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
//    {
//        self.performSegue(withIdentifier: "editNote", sender: self)
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
//    {
//        if(segue.identifier == "editNote")
//        {
//            let indexPath = tableView.indexPathForSelectedRow!
//            
//            let noteDetail = segue.destination as? NoteDetailViewController
//            
//            let selectedNote : Note!
//            selectedNote = nonDeletedNotes()[indexPath.row]
//            noteDetail!.selectedNote = selectedNote
//            
//            tableView.deselectRow(at: indexPath, animated: true)
//        }
//    }
//    
//    
//}
