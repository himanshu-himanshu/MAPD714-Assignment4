//
//  ViewController.swift
//  MAPD714-Assignment4
//
//  Created by Himanshu on 2022-11-13.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var todoList:[TodoList] = []
    
    let todoListTableIdentifier = "TodoListTableIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildTodoList()
    }
    
    
    func buildTodoList() -> Void {
        todoList.append(TodoList(title: "Buy Book", dueDate: " "))
        todoList.append(TodoList(title: "Assignment 4", dueDate: "Overdue"))
        todoList.append(TodoList(title: "Read Novel", dueDate: "24 November, 2022"))
        todoList.append(TodoList(title: "Do Homework", dueDate: "Completed"))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: todoListTableIdentifier)
        if(cell == nil) {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: todoListTableIdentifier)
        }
        
        cell?.textLabel?.text = todoList[indexPath.row].title
        cell?.detailTextLabel?.text = todoList[indexPath.row].dueDate
//        let image = UIImage(named: "edit")
//        cell?.imageView?.image = image

        let cellFont = UIFont .systemFont(ofSize: 20, weight: UIFont.Weight.medium)
        
        cell?.textLabel?.font = cellFont
        
        let switchView = UISwitch(frame: .zero)
        
        if(todoList[indexPath.row].dueDate == "Completed") {
            cell?.detailTextLabel?.textColor = UIColor.gray
            cell?.textLabel?.textColor = UIColor.gray
            switchView.setOn(true, animated: true)
         }
        
        if(todoList[indexPath.row].dueDate == "Overdue") {
            cell?.detailTextLabel?.textColor = UIColor.red
            cell?.textLabel?.textColor = UIColor.red
            switchView.setOn(false, animated: true)
         }
    
        switchView.tag = indexPath.row
        cell?.accessoryView = switchView
        
        return cell!
        
    }
    
    @objc func switchDidChange(sender: UISwitch) {
        print("Anything")
    }
    
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath.row == 0 ? nil : indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(todoList[indexPath.row].title)
        print(todoList[indexPath.row].dueDate)
        
        let stoaryboard = UIStoryboard(name: "Main", bundle: nil)
        let secondController = stoaryboard.instantiateViewController(withIdentifier: "todo_detail")
        self.present(secondController, animated: true, completion: nil);
    }
    

}

