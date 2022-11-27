
import UIKit
import FirebaseCore
import FirebaseFirestore

class TodoDetailViewController: UIViewController {

    @IBOutlet weak var dateTextField: UITextField!
    
    let datePicker = UIDatePicker()
    
    var todoId: String = ""
    var todoFirebaseName: String = ""
    var todoFirebaseNotes: String = ""
    var todoFirebaseIsCompleted: Bool = false
    var todoFirebaseHasDueDate: Bool = false
    
    @IBOutlet weak var hadDueDateSwitchConn: UISwitch!
    @IBOutlet weak var todoNote: UITextView!
    @IBOutlet weak var todoName: UITextField!
    @IBOutlet weak var isCompletedSwitchConn: UISwitch!
    
    var db = Firestore.firestore()
    
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
                
            } else {
                print("Document does not exist")
            }
        }
        
    }
    
    @IBAction func hasDueDateSwitch(_ sender: Any) {
    }
    
    
    @IBAction func todoDate(_ sender: Any) {
    }
    

    @IBAction func isCompletedSwitch(_ sender: Any) {
        isCompletedSwitchConn.setOn(isCompletedSwitchConn.isOn, animated: true)
    }

    @IBAction func updateBtn(_ sender: Any) {
        let refreshAlert = UIAlertController(title: "Update Data", message: "Are you sure you want to update todo data?", preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
            
            return
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [self] (action: UIAlertAction!) in
           
            db.collection("todos").document(todoId).setData([ "name": todoName.text!, "notes": todoNote.text! ,"isCompleted": isCompletedSwitchConn.isOn], merge: true)
            let stoaryboard = UIStoryboard(name: "Main", bundle: nil)
            let firstController = stoaryboard.instantiateViewController(withIdentifier: "mainScreen")
            firstController.modalPresentationStyle = .fullScreen
            self.present(firstController, animated: true, completion: nil);
        }))

        present(refreshAlert, animated: true, completion: nil)
    }
    
    
    @IBAction func cancelBtn(_ sender: Any) {
        
        print(isCompletedSwitchConn.isOn, todoFirebaseIsCompleted)
        
        if(todoName.text != todoFirebaseName || todoNote.text != todoFirebaseNotes || isCompletedSwitchConn.isOn != todoFirebaseIsCompleted ){
            
            // If there is some change in data then show the alert
            let refreshAlert = UIAlertController(title: "Discard Data", message: "Are you sure you want to discard changes?", preferredStyle: UIAlertController.Style.alert)

            refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { [self] (action: UIAlertAction!) in
               
                db.collection("todos").document(todoId).setData([ "name": todoName.text!, "notes": todoNote.text! ,"isCompleted": isCompletedSwitchConn.isOn], merge: true)
                let stoaryboard = UIStoryboard(name: "Main", bundle: nil)
                let firstController = stoaryboard.instantiateViewController(withIdentifier: "mainScreen")
                firstController.modalPresentationStyle = .fullScreen
                self.present(firstController, animated: true);
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [] (action: UIAlertAction!) in
               
                self.dismiss(animated: true, completion: nil)
            }))

            present(refreshAlert, animated: true, completion: nil)
            
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    @IBAction func deleteBtn(_ sender: Any) {
    }
    
}
