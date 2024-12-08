//
//  ViewController.swift
//  NoteAppCoreData
//
//  Created by Yerdaulet Orynbay on 08.12.2024.
//

import UIKit
import CoreData

class NoteDetailVC: UIViewController {
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var descTV: UITextView!

    var selectedNote: Note? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let note = selectedNote {
            titleTF.text = note.title
            descTV.text = note.desc
           
        }
    }
    
    @IBAction func saveAction(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        if selectedNote == nil {
            // Создаем новую заметку
            let entity = NSEntityDescription.entity(forEntityName: "Note", in: context)
            let newNote = Note(entity: entity!, insertInto: context)
            newNote.id = noteList.count as NSNumber
            newNote.title = titleTF.text
            newNote.desc = descTV.text
            newNote.createdAt = Date() // Устанавливаем время создания
            newNote.updatedAt = Date() // Устанавливаем время последнего обновления

            do {
                try context.save()
                noteList.append(newNote)
                navigationController?.popViewController(animated: true)
            } catch {
                print("Ошибка при сохранении контекста")
            }
        } else {
            // Редактируем существующую заметку
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
            do {
                let results: NSArray = try context.fetch(request) as NSArray
                for result in results {
                    let note = result as! Note
                    if note == selectedNote {
                        note.title = titleTF.text
                        note.desc = descTV.text
                        note.updatedAt = Date() // Обновляем время последнего изменения

                        try context.save()
                        navigationController?.popViewController(animated: true)
                    }
                }
            } catch {
                print("Ошибка при получении данных")
            }
        }
    }

    
}
