//
//  ViewController.swift
//  MAPD714-Assignment4
//
//  Created by Himanshu on 2022-11-13.
//

import UIKit
import FirebaseCore
import FirebaseFirestore

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var todoList:[TodoList] = []
    
    let todoListTableIdentifier = "TodoListTableIdentifier"
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildTodoList()
        print("Hello")
        
    }
    
    var db = Firestore.firestore()
    
    @IBAction func addTodoBtn(_ sender: UIButton) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Add Todo", message: "Enter Todo name", preferredStyle: .alert)

        //2. Add the text field. You can configure it however you need.
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.text = ""
        })

        //3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Add To List", style: .default, handler: { [self, weak alert] (action) -> Void in
            let textField = (alert?.textFields![0])! as UITextField
            if(textField.text == "" || textField.text == " ") {
                return
            }
            addTodo(title: textField.text!)
            print("Text field: \(String(describing: textField.text))")
            
            // Firebase Code
            var ref: DocumentReference? = nil
            ref = db.collection("todos").addDocument(data: [
                "name": textField.text!,
                "isCompleted": false,
                "notes": "",
                "hasDueDate": true,
                "dueDate": " "
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
    
    func buildTodoList() -> Void {
        
        let ref = db.collection("todos")
        //let id = ref.collectionID
        
        ref.getDocuments() { [self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                todoList = []
                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(String(describing: document.data()["name"]))")
//                    print("\(document.documentID) => \(String(describing: document.data()["isCompleted"]))")
//                    print("\(document.documentID) => \(String(describing: document.data()["notes"]))")
//                    print("\(document.documentID) => \(String(describing: document.data()["hasDueDate"]))")
//                    print("\(document.documentID) => \(String(describing: document.data()["dueDate"]))")
                    todoList.append(TodoList(
                        id:document.documentID,
                        name: document.data()["name"] as! String,
                        dueDate: document.data()["dueDate"] as! String,
                        isCompleted:(((document.data()["isCompleted"])) as! Bool),
                        notes: document.data()["notes"] as! String,
                        hasDueDate: (document.data()["hasDueDate"] as! Bool)))
                    //print(document.documentID)
                }
               
                tableView.reloadData()
            }
        }
    }
    
    func addTodo(title:String) -> Void {
        buildTodoList()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: todoListTableIdentifier)
        if(cell == nil) {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: todoListTableIdentifier)
        }
//        let dateFormatter = DateFormatter()
//
//        // Set Date Format
//        dateFormatter.dateFormat = "YY/MM/dd"
//
//        // Convert Date to String
//        dateFormatter.string(from: todoList[indexPath.row].dueDate)
        
        cell?.textLabel?.text = todoList[indexPath.row].name
        cell?.detailTextLabel?.text = todoList[indexPath.row].dueDate

        let cellFont = UIFont .systemFont(ofSize: 20, weight: UIFont.Weight.medium)
        
        cell?.textLabel?.font = cellFont
        
        let isCompletedSwitchView = UISwitch(frame: .zero)
        
        if(todoList[indexPath.row].isCompleted == true) {
            cell?.detailTextLabel?.textColor = UIColor.gray
            cell?.textLabel?.textColor = UIColor.gray
            isCompletedSwitchView.setOn(true, animated: true)
        } else {
            cell?.detailTextLabel?.textColor = UIColor.black
            cell?.textLabel?.textColor = UIColor.black
            isCompletedSwitchView.setOn(false, animated: true)
        }
        
        if(todoList[indexPath.row].dueDate == "Overdue") {
            cell?.detailTextLabel?.textColor = UIColor.red
            cell?.textLabel?.textColor = UIColor.red
            isCompletedSwitchView.setOn(false, animated: true)
         }
    
        isCompletedSwitchView.tag = indexPath.row
  
        isCompletedSwitchView.addTarget(self, action: #selector(self.switchDidChange(_:)) , for: .valueChanged)
        
        cell?.accessoryView = isCompletedSwitchView
        
        return cell!
        
    }
    
    @objc func switchDidChange(_ sender : UISwitch!) {
        let todoId = todoList[sender.tag].id
        db.collection("todos").document(todoId).setData([ "isCompleted": sender.isOn], merge: true)
        buildTodoList()
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stoaryboard = UIStoryboard(name: "Main", bundle: nil)
        let secondController = stoaryboard.instantiateViewController(withIdentifier: "todo_detail") as! TodoDetailViewController
        secondController.todoId = todoList[indexPath.row].id
        self.present(secondController, animated: true, completion: nil);
    }
}

