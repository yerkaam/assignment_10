import UIKit
import CoreData

var noteList = [Note]()

class NoteTableView: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {

    var firstLoad = true
    var searchController: UISearchController!
    var filteredNotes = [Note]()
    
    func nonDeletedNotes() -> [Note] {
        var noDeleteNoteList = [Note]()
        for note in noteList {
            if note.deletedDate == nil {
                noDeleteNoteList.append(note)
            }
        }
        return noDeleteNoteList
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

      
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        if firstLoad {
            firstLoad = false
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
            do {
                let results:NSArray = try context.fetch(request) as NSArray
                for result in results {
                    let note = result as! Note
                    noteList.append(note)
                }
            } catch {
                print("Ошибка при получении данных")
            }
        }
    }
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let noteCell = tableView.dequeueReusableCell(withIdentifier: "noteCellID", for: indexPath) as! NoteCell
        let thisNote: Note!
        
        if isFiltering() {
            thisNote = filteredNotes[indexPath.row]
        } else {
            thisNote = nonDeletedNotes()[indexPath.row]
        }
        
        noteCell.titleLabel.text = thisNote.title
        noteCell.descLabel.text = thisNote.desc
        if let updatedAt = thisNote.updatedAt {
              noteCell.timeLabel.text = "\(formatTime(updatedAt))"
          } else if let createdAt = thisNote.createdAt {
              noteCell.timeLabel.text = "\(formatTime(createdAt))"
          }
        
        return noteCell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredNotes.count
        }
        return nonDeletedNotes().count
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "editNote", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editNote" {
            let indexPath = tableView.indexPathForSelectedRow!
            let noteDetail = segue.destination as? NoteDetailVC
            
            let selectedNote : Note!
            if isFiltering() {
                selectedNote = filteredNotes[indexPath.row]
            } else {
                selectedNote = nonDeletedNotes()[indexPath.row]
            }
            noteDetail!.selectedNote = selectedNote
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    

    func filterContentForSearchText(_ searchText: String) {
        filteredNotes = nonDeletedNotes().filter { (note: Note) -> Bool in
            return note.title.lowercased().contains(searchText.lowercased()) || note.desc.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    

    func isFiltering() -> Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }

   
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let noteToDelete: Note
            
            if isFiltering() {
                noteToDelete = filteredNotes[indexPath.row]
                filteredNotes.remove(at: indexPath.row)
            } else {
                noteToDelete = nonDeletedNotes()[indexPath.row]
                noteList.removeAll { $0 == noteToDelete }
            }
           
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            context.delete(noteToDelete)
            
            do {
                try context.save()
            } catch {
                print("Ошибка при удалении заметки")
            }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
