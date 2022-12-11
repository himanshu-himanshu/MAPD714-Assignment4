//  File Name: ViewController.swift

//  Authors: Himanshu (301296001) & Gurminder (301294300)
//  Subject: MAPD714 iOS Development
//  Assignment: 5

//  Task: Create the logic that powers the UI for the Todo App

//  About App: We have to built Todo app using swift programming language that can store the information in some kind of database such as Firebase, SQL lite etc.

//  Date modified: 27/11/2022


import UIKit
import FirebaseCore
import FirebaseFirestore

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    /**
        * Variable declarations
     */
    var todoList:[TodoList] = []
    
    let todoListTableIdentifier = "TodoListTableIdentifier"
    
    var tomDate:String = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    /**
        * viewDidLoad function
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        buildTodoList()
    }
    
    /** Firebase initialization */
    var db = Firestore.firestore()
    
    /**
        * Function to add todo in the table view
     */
    @IBAction func addTodoBtn(_ sender: UIButton) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Add Todo", message: "Enter Todo name", preferredStyle: .alert)

        //2. Add the text field
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.text = ""
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: { [self] (action) -> Void in
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        //3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Add To List", style: .default, handler: { [self, weak alert] (action) -> Void in
            let textField = (alert?.textFields![0])! as UITextField
            if(textField.text == "" || textField.text == " ") {
                return
            }
            addTodo(title: textField.text!)
            //print("Text field: \(String(describing: textField.text))")

            // Firebase Code
            var ref: DocumentReference? = nil
            ref = db.collection("todos").addDocument(data: [
                "name": textField.text!,
                "isCompleted": false,
                "notes": "",
                "dueDate": " ",
                "hasDueDate": false,
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                }
            }
            
            tableView.reloadData()

        }))

        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    /**
        * Function to build the table view and insert todos
     */
    func buildTodoList() -> Void {
        
        let ref = db.collection("todos")
        
        ref.getDocuments() { [self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                todoList = []
                
                for document in querySnapshot!.documents {
                    todoList.append(TodoList(
                        id:document.documentID,
                        name: document.data()["name"] as! String,
                        dueDate: document.data()["dueDate"] as! String,
                        isCompleted:(((document.data()["isCompleted"])) as! Bool),
                        notes: document.data()["notes"] as! String,
                        hasDueDate: (document.data()["hasDueDate"] as! Bool)))
                }
               
                tableView.reloadData()
            }
        }
    }
    
    /**
        * Function to add todo in the table view
     */
    func addTodo(title:String) -> Void {
        buildTodoList()
        tableView.reloadData()
    }
    
    /** TableView Code below */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoList.count
    }
    
//    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        <#code#>
//    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let favouriteaction = UIContextualAction(style: .normal, title: "") { [weak self] (action, view, completionHandler) in
            self!.markAsComplete(id: indexPath.row)
              //completionHandler(true)
           }
           // print(indexPath.row)
           favouriteaction.backgroundColor = .systemYellow
        let config = UISwipeActionsConfiguration(actions: [favouriteaction])
        config.per
        return config
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: todoListTableIdentifier)
        if(cell == nil) {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: todoListTableIdentifier)
        }
        
        let dateFormatter = DateFormatter()

        // Set Date Format
        dateFormatter.dateFormat = "dd/MM/YYYY"

        // Convert Date to String
        //dateFormatter.string(from: todoList[indexPath.row].dueDate)
        
        cell?.textLabel?.text = todoList[indexPath.row].name
        cell?.detailTextLabel?.text = todoList[indexPath.row].dueDate
        //cell?.detailTextLabel?.text = dateFormatter.string(from: todoList[indexPath.row].dueDate)

        let cellFont = UIFont .systemFont(ofSize: 20, weight: UIFont.Weight.medium)
        
        cell?.textLabel?.font = cellFont
        
        //let isCompletedSwitchView = UISwitch(frame: .zero)
        
        if(todoList[indexPath.row].isCompleted == true) {
            cell?.detailTextLabel?.textColor = UIColor.gray
            cell?.textLabel?.textColor = UIColor.gray
            //isCompletedSwitchView.setOn(true, animated: true)
        } else {
            cell?.detailTextLabel?.textColor = UIColor.black
            cell?.textLabel?.textColor = UIColor.black
            //isCompletedSwitchView.setOn(false, animated: true)
        }
        
        if(todoList[indexPath.row].dueDate == "Overdue") {
            cell?.detailTextLabel?.textColor = UIColor.red
            cell?.textLabel?.textColor = UIColor.red
            //isCompletedSwitchView.setOn(false, animated: true)
         }
    
        //isCompletedSwitchView.tag = indexPath.row
  
       // isCompletedSwitchView.addTarget(self, action: #selector(self.switchDidChange(_:)) , for: .valueChanged)
        
        //cell?.accessoryView = isCompletedSwitchView
        
        return cell!
        
    }
    
    /**
        * Function for isComplete Switch change
     */
//    @objc func switchDidChange(_ sender : UISwitch!) {
//        print(sender.tag)
//        let todoId = todoList[sender.tag].id
//        db.collection("todos").document(todoId).setData([ "isCompleted": sender.isOn], merge: true)
//        buildTodoList()
//    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stoaryboard = UIStoryboard(name: "Main", bundle: nil)
        let secondController = stoaryboard.instantiateViewController(withIdentifier: "todo_detail") as! TodoDetailViewController
        secondController.todoId = todoList[indexPath.row].id
        self.present(secondController, animated: true, completion: nil);
    }
    
    func markAsComplete(id:Int) {
        let todoId = todoList[id].id
        let docRef = db.collection("todos").document(todoId)
        
        docRef.getDocument { [self] (document, error) in
            //var todoFirebaseIsCompleted:Bool
            if let document = document, document.exists {
//                print(((document.data()!["isCompleted"])) as! Bool)
                let isComp:Bool = (((document.data()!["isCompleted"])) as! Bool)
                if(isComp == true) {
                    db.collection("todos").document(todoId).setData([ "isCompleted": false], merge: true)
                } else {
                    db.collection("todos").document(todoId).setData([ "isCompleted": true], merge: true)
                }
                buildTodoList()
            }
        }
    }
}

