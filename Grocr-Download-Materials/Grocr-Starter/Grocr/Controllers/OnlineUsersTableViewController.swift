/// Copyright (c) 2018 Razeware LLC
///
///
///
///
///

import UIKit
import Firebase

class OnlineUsersTableViewController: UITableViewController {

    let userCell = "UserCell"

    var currentUsers: [String] = []
    let authorsRef = Database.database().reference(withPath: "Online")

    override var preferredStatusBarStyle: UIStatusBarStyle {

        return .lightContent

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        authorsRef.observe(.childAdded) { (snap) in

            guard
                let email = snap.value as? String
                else { print("email as String error.")
                return
            }

            self.currentUsers.append(email)
            let row = self.currentUsers.count - 1
            let indexPath = IndexPath(row: row, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .top)

        }

        authorsRef.observe(.childRemoved) { (snap) in

            guard
                let emailToFind = snap.value as? String
                else { print("emailToFind as String error.")
                return
            }

            for (index, email) in self.currentUsers.enumerated() {

                if email == emailToFind {

                    let indexPath = IndexPath(row: index, section: 0)
                    self.currentUsers.remove(at: index)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)

                }

            }

        }

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return currentUsers.count

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: userCell, for: indexPath)
        let onlineUserEmail = currentUsers[indexPath.row]
        cell.textLabel?.text = onlineUserEmail

        return cell

    }

    @IBAction func signoutButtonPressed(_ sender: AnyObject) {

        guard
            let user = Auth.auth().currentUser else { print("currentUser is nil.")
            return
        }

        let onlineRef = Database.database().reference(withPath: "Online/\(user.uid)")

        onlineRef.removeValue { (error, _) in

            if let error = error {

                print("Removing online failed: \(error)")

                return

            }

        }

        do {

            try Auth.auth().signOut()
            self.dismiss(animated: true, completion: nil)

        } catch {

            print("Auth sign out failed:\(error)")

        }

    }

}
