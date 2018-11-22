/// Copyright (c) 2018 Razeware LLC





import UIKit
import Firebase

class GroceryListTableViewController: UITableViewController {

    // MARK: Constants
    let listToUsers = "ListToUsers"

    // MARK: Properties
    var items: [GroceryItem] = []
    var user: User!
    var userCountBarButtonItem: UIBarButtonItem!

    let ref = Database.database().reference(withPath: "grocery-items")
    let usersRef = Database.database().reference(withPath: "online")

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelectionDuringEditing = false
        
        userCountBarButtonItem = UIBarButtonItem(title: "1",
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(userCountButtonDidTouch))
        userCountBarButtonItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = userCountBarButtonItem
        
        user = User(uid: "FakeId", email: "hungry@person.food")

        ref.queryOrdered(byChild: "completed").observe(.value) { (snapshot) in
            
            var newItems: [GroceryItem] = []

            for child in snapshot.children {
                
                if let snapshot = child as? DataSnapshot,
                    let groceryItem = GroceryItem(snapshot: snapshot) {
                    
                    newItems.append(groceryItem)

                } else {
                    print("child can't as DataSnapshot.")
                }
            }
            self.items = newItems
            self.tableView.reloadData()
        }

        Auth.auth().addStateDidChangeListener { (auth, user) in

            guard
                let user = user else { return }
            self.user = User(authData: user)

            let currentUserRef = self.usersRef.child(self.user.uid)
            currentUserRef.setValue(self.user.email)
            currentUserRef.onDisconnectRemoveValue()

        }

        usersRef.observe(.value) { (snapshot) in

            if snapshot.exists() {

                self.userCountBarButtonItem.title = snapshot.childrenCount.description

            } else {

                self.userCountBarButtonItem.title = "0"

            }

        }

    }
    
    // MARK: UITableView Delegate methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let groceryItem = items[indexPath.row]
        
        cell.textLabel?.text = groceryItem.name
        cell.detailTextLabel?.text = groceryItem.addedByUser
        
        toggleCellCheckbox(cell, isCompleted: groceryItem.completed)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {

            let groceryItem = items[indexPath.row]
            groceryItem.ref?.removeValue()

        }

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let cell = tableView.cellForRow(at: indexPath) else { return }

        let groceryItem = items[indexPath.row]
        let toggledCompletion = !groceryItem.completed
        
        toggleCellCheckbox(cell, isCompleted: toggledCompletion)

        groceryItem.ref?.updateChildValues([
            "completed": toggledCompletion
            ])
        items[indexPath.row].ref?.updateChildValues(["compeleted" : !groceryItem.completed])
    }
    
    func toggleCellCheckbox(_ cell: UITableViewCell, isCompleted: Bool) {
        if !isCompleted {
            cell.accessoryType = .none
            cell.textLabel?.textColor = .black
            cell.detailTextLabel?.textColor = .black
        } else {
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = .gray
            cell.detailTextLabel?.textColor = .gray
        }
    }
    
    // MARK: Add Item
    
    @IBAction func addButtonDidTouch(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Grocery Item",
                                      message: "Add an Item",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in

            guard
                let textField = alert.textFields?.first,
                let text = textField.text else { return }
            
            let groceryItem = GroceryItem(name: text,
                                          addedByUser: self.user.email,
                                          completed: false)
            let groceryItemRef = self.ref.child(text.lowercased())

            //setValue method need a Dictionary type, call toAnyObject() to turn it into a Dictionary type.
            groceryItemRef.setValue(groceryItem.toAnyObject())
            
            self.items.append(groceryItem)
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func userCountButtonDidTouch() {
        performSegue(withIdentifier: listToUsers, sender: nil)
    }
}
