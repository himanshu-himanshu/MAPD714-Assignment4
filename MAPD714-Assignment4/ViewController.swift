//  File Name: ViewController.swift

//  Authors: Himanshu (301296001) & Gurminder (301294300)
//  Subject: MAPD714 iOS Development
//  Assignment: 6

//  Task: Add Gestures to the todo app which we developed in assignment 5.

//  About App: We have to built Todo app using swift programming language that can store the information in some kind of database such as Firebase, SQL lite etc.

//  Date modified: 11/12/2022


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
    
    /**
        * Swipe Action from left to right (edit todo gesture)
     */
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "✎") { [weak self] (action, view, completionHandler) in
            self!.editTodoFunction(id: indexPath.row)
              completionHandler(true)
           }
        editAction.backgroundColor = .systemBlue
        let config = UISwipeActionsConfiguration(actions: [editAction])
        config.performsFirstActionWithFullSwipe = true
        return config
    }
    
    /**
        * Swipe Action from right to left (complete todo and delete todo gestures)
     */
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let completeAction = UIContextualAction(style: .normal, title: "✔") { [weak self] (action, view, completionHandler) in
            self!.markAsComplete(id: indexPath.row)
              completionHandler(true)
           }
        completeAction.backgroundColor = .systemYellow
        
        let deleteAction = UIContextualAction(style: .destructive, title: "🗑️") { [weak self] (action, view, completionHandler) in
            self!.deleteTodo(id: indexPath.row)
              completionHandler(true)
           }
        deleteAction.backgroundColor = .systemRed
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction,completeAction])
        return config
    }
    
    /**
        * Function to presenting table cell UI to the screen     
     */
    
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
        
        if(todoList[indexPath.row].isCompleted == true) {
            cell?.detailTextLabel?.textColor = UIColor.gray
            cell?.textLabel?.textColor = UIColor.gray
        } else {
            cell?.detailTextLabel?.textColor = UIColor.black
            cell?.textLabel?.textColor = UIColor.black
        }
        
        if(todoList[indexPath.row].dueDate == "Overdue") {
            cell?.detailTextLabel?.textColor = UIColor.red
            cell?.textLabel?.textColor = UIColor.red
         }
        
        return cell!
        
    }
    
    /**
        * Function for performing edit todo functionality
        * :param: id -> Integer to hold todo id
        * :returns: void
     */
    func editTodoFunction(id:Int) {
        let transition = CATransition()
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        let stoaryboard = UIStoryboard(name: "Main", bundle: nil)
        let secondController = stoaryboard.instantiateViewController(withIdentifier: "todo_detail") as! TodoDetailViewController
        secondController.todoId = todoList[id].id
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.present(secondController, animated: false, completion: nil);
    }
    
    /**
        * Function for performing mark as completed when user swipes from right to left
        * :param: id -> Integer to hold todo id
        * :returns: void
     */
    func markAsComplete(id:Int) {
        let todoId = todoList[id].id
        let docRef = db.collection("todos").document(todoId)
        
        docRef.getDocument { [self] (document, error) in
            //var todoFirebaseIsCompleted:Bool
            if let document = document, document.exists {
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
    
    /**
        * Function for performing delete todo when user long swipes from right to left
        * :param: id -> Integer to hold todo id
        * :returns: void
     */
    func deleteTodo(id:Int) {
        print("Perform Delete")
        let todoId = todoList[id].id
        db.collection("todos").document(todoId).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
                self.buildTodoList()
            }
        }
    }
}

