//  File Name: TodoDetailViewController.swift

//  Authors: Himanshu (301296001) & Gurminder (301294300)
//  Subject: MAPD714 iOS Development
//  Assignment: 5

//  Task: Create the logic that powers the UI for the Todo App

//  About App: We have to built Todo app using swift programming language that can store the information in some kind of database such as Firebase, SQL lite etc.

//  Date modified: 27/11/2022


import UIKit
import FirebaseCore
import FirebaseFirestore

class TodoDetailViewController: UIViewController {
    
    /**
        * Variable declarations
     */
    @IBOutlet weak var dateTextField: UITextField!
    
    let datePicker = UIDatePicker()
    
    var todoId: String = ""
    var todoFirebaseName: String = ""
    var todoFirebaseNotes: String = ""
    var todoFirebaseIsCompleted: Bool = false
    var todoFirebaseHasDueDate: Bool = false
    var dueDateString: String = ""
    
    /**
        * Variable Connections
     */
    @IBOutlet weak var todoDateElement: UIDatePicker!
    @IBOutlet weak var hadDueDateSwitchConn: UISwitch!
    @IBOutlet weak var todoNote: UITextView!
    @IBOutlet weak var todoName: UITextField!
    @IBOutlet weak var isCompletedSwitchConn: UISwitch!
    
    /** Firebase initialization */
    var db = Firestore.firestore()
    
    /**
        * viewDidLoad function
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        todoName.text = todoId
        print(todoId)
        
        let docRef = db.collection("todos").document(todoId)

        docRef.getDocument { [self] (document, error) in
            if let document = document, document.exists {
                
                print("Document data: \(String(describing: document.data()!["name"]))")
                
                // Store Todo data into varibales
                todoFirebaseName = (document.data()!["name"] as! String)
                todoFirebaseNotes = (document.data()!["notes"] as! String)
                todoFirebaseIsCompleted = (((document.data()!["isCompleted"])) as! Bool)
                todoFirebaseHasDueDate = (((document.data()!["hasDueDate"])) as! Bool)
                
                // Set TodoViewScreen fields
                todoName.text = todoFirebaseName
                todoNote.text = todoFirebaseNotes
                isCompletedSwitchConn.setOn( todoFirebaseIsCompleted, animated: true)
                hadDueDateSwitchConn.setOn( todoFirebaseHasDueDate, animated: true)
                todoDateElement.isEnabled = todoFirebaseHasDueDate
                
            } else {
                print("Document does not exist")
            }
        }
        
    }
    
    /**
        * hasDueDate Switch change function
     */
    
    @IBAction func hasDueDateSwitch(_ sender: Any) {
        if(hadDueDateSwitchConn.isOn) {
            todoDateElement.isEnabled = true
        } else {
            todoDateElement.isEnabled = false
        }
    }
    
    /**
        * isCompleted Switch change function
     */
    
    @IBAction func isCompletedSwitch(_ sender: Any) {
        isCompletedSwitchConn.setOn(isCompletedSwitchConn.isOn, animated: true)
    }
    
    /**
        * Update Button Function
     */

    @IBAction func updateBtn(_ sender: Any) {
        let refreshAlert = UIAlertController(title: "Update Data", message: "Are you sure you want to update todo data?", preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
            
            return
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [self] (action: UIAlertAction!) in
           
          saveDataToFirebase()
            
        }))

        present(refreshAlert, animated: true, completion: nil)
    }
    
    /**
        * Cancel Button Function
     */
    
    @IBAction func cancelBtn(_ sender: Any) {
        
        print(isCompletedSwitchConn.isOn, todoFirebaseIsCompleted)
        
        if(todoName.text != todoFirebaseName || todoNote.text != todoFirebaseNotes || isCompletedSwitchConn.isOn != todoFirebaseIsCompleted || hadDueDateSwitchConn.isOn != todoFirebaseHasDueDate ){

            // If there is some change in data then show the alert
            let refreshAlert = UIAlertController(title: "Discard Data", message: "Are you sure you want to discard changes?", preferredStyle: UIAlertController.Style.alert)

            refreshAlert.addAction(UIAlertAction(title: "Update", style: .cancel, handler: { [self] (action: UIAlertAction!) in
                
                saveDataToFirebase()
                
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Discard", style:  UIAlertAction.Style.destructive, handler: { [] (action: UIAlertAction!) in
               
                self.dismiss(animated: true, completion: nil)
            }))

            present(refreshAlert, animated: true, completion: nil)
            
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    /**
        * Delete Todo Function
     */
    
    @IBAction func deleteBtn(_ sender: Any) {
        
        let refreshAlert = UIAlertController(title: "Delete Todo", message: "Are you sure you want to delete todo?", preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction!) in
            return
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { [self] (action: UIAlertAction!) in
            db.collection("todos").document(todoId).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            
            let stoaryboard = UIStoryboard(name: "Main", bundle: nil)
            let firstController = stoaryboard.instantiateViewController(withIdentifier: "mainScreen")
            firstController.modalPresentationStyle = .fullScreen
            self.present(firstController, animated: true, completion: nil);
        }))

        present(refreshAlert, animated: true, completion: nil)
    }
    
    /**
        * Function to save current or updated data into Firebase store
     */
    
    func saveDataToFirebase() {
        
        let dateFormatter = DateFormatter()

        // Set Date Format
        dateFormatter.dateFormat = "dd/MM/YYYY"

        // Convert Date to String
        dateFormatter.string(for: todoDateElement)
        
        if(hadDueDateSwitchConn.isOn) {
            dueDateString = dateFormatter.string(for: todoDateElement.date)!
        } else {
            dueDateString = " "
        }
        
        db.collection("todos").document(todoId).setData(
            ["name": todoName.text!,
             "notes": todoNote.text!,
             "hasDueDate": hadDueDateSwitchConn.isOn,
             "dueDate": dueDateString,
             "isCompleted": isCompletedSwitchConn.isOn],
            merge: true)
        
        let stoaryboard = UIStoryboard(name: "Main", bundle: nil)
        let firstController = stoaryboard.instantiateViewController(withIdentifier: "mainScreen")
        firstController.modalPresentationStyle = .fullScreen
        self.present(firstController, animated: true, completion: nil);
    }
}
