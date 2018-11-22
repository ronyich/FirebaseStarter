//
//  ArticleListTableViewController.swift
//  Grocr
//
//  Created by Ron Yi on 2018/11/19.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import UIKit
import Firebase

class ArticleListTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var toggleLikeButton: UIButton!

}
      
class ArticleListTableViewController: UITableViewController {

    let listToUsers = "ListToUsers"
    
    var userCountBarButtonItem: UIBarButtonItem!

    var articles: [Article] = []
    var author: Author?
    
    let articlesRef = Database.database().reference(withPath: "articles")
    let authorsRef = Database.database().reference(withPath: "Online")

    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("0")
        tableView.allowsMultipleSelectionDuringEditing = false
        
        userCountBarButtonItem = UIBarButtonItem(title: "1",
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(userCountButtonDidTouch))
        userCountBarButtonItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = userCountBarButtonItem

        //author = Author(uid: "FakeID", email: "Fake@firebase.com")

        articlesRef.queryOrdered(byChild: "isLike").observe(.value) { (snapshot) in
            
            var newItems: [Article] = []

            for child in snapshot.children {

                if let snapshot = child as? DataSnapshot,
                    let articleItem = Article(snapshot: snapshot) {

                    newItems.append(articleItem)

                } else {

                    print("child can't as DataSnapshot.")

                }

            }

            self.articles = newItems
            self.tableView.reloadData()

        }

        Auth.auth().addStateDidChangeListener { (auth, user) in

            print("1")
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            guard
                let user = user
                else { print("user is nil.")
                    return
            }
            
            print("2")

            guard
                let author = self.author
                else { print("author is nil.")
                    return
            }
            print("3")
            self.author = Author(authData: user)

            let currentUserRef = self.authorsRef.child(author.uid)
            currentUserRef.setValue(author.email)
            //currentUserRef.setValue(author.userName)
            currentUserRef.onDisconnectRemoveValue()
            print("4")
        }

        authorsRef.observe(.value) { (snapshot) in
            
            if snapshot.exists() {
                
                self.userCountBarButtonItem.title = snapshot.childrenCount.description
                
            } else {
                
                self.userCountBarButtonItem.title = "0"
                
            }
            
        }
        print("author:\(self.author)")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return articles.count

    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {

            let articleItem = articles[indexPath.row]
            articleItem.ref?.removeValue()

        } else {

            print("Remove cell error.")

        }

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleListTableViewCell", for: indexPath) as? ArticleListTableViewCell
            else { fatalError("ArticleListTableViewCell is nil.") }

        let articleItem = articles[indexPath.row]

        cell.dateLabel.text = articleItem.date
        cell.titleLabel.text = articleItem.title
        cell.authorLabel.text = articleItem.addByAuthor
        cell.contentLabel.text = articleItem.content

        if articleItem.isLike == true {

            cell.toggleLikeButton.setTitleColor(.red, for: .normal)

        } else {

            cell.toggleLikeButton.setTitleColor(.lightGray, for: .normal)

        }

        cell.toggleLikeButton.addTarget(self, action: #selector(switchLikeStatus), for: .touchUpInside)
        
        return cell

    }

    @objc func switchLikeStatus(button: UIButton) {

        guard
            let cell = button.superview?.superview as? ArticleListTableViewCell
            else { print("switchLikeStatus cell as ArticleListTableViewCell error.")
                return
        }

        guard
            let indexPath = tableView.indexPath(for: cell)
            else { print("indexPath is nil.")
                return
        }

        let articleItem = articles[indexPath.row]
        let toggledCompletion = !articleItem.isLike

        if articleItem.isLike {

            cell.toggleLikeButton.setTitleColor(.lightGray, for: .normal)
            
        } else {

            cell.toggleLikeButton.setTitleColor(.red, for: .normal)

        }
        
        articleItem.ref?.updateChildValues(["isLike": toggledCompletion])

    }

    @IBAction func addNewArticleDidTouch(_ sender: AnyObject) {

        let alert = UIAlertController(title: "Article Item",
                                      message: "Add an Article",
                                      preferredStyle: .alert)

        let saveAction = UIAlertAction(title: "Save", style: .default) { (_) in

            guard
                let title = alert.textFields?[0].text
                else { print("title input error.")
                return
                    
            }

            guard
                let content = alert.textFields?[1].text
                else { print("content input error.")
                return
            }

            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "MM.dd.yyyy"
            let dateResult = formatter.string(from: date)

//            guard
//                let author = self.author
//                else { print("author is nil.")
//                return
//            }

            guard
                let currentUsername = Auth.auth().currentUser?.displayName
                else { print("currentUser is nil.")
                    return
            }

            let articleItem = Article(addByAuthor: currentUsername, key: "", title: title, content: content, date: dateResult, isLike: false)
            let articleItemRef = self.articlesRef.child(title.lowercased())

            //setValue method need a Dictionary type, call toAnyObject() to turn it into a Dictionary type.
            articleItemRef.setValue(articleItem.toAnyObject())

            self.articles.append(articleItem)
            self.tableView.reloadData()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addTextField { (articleTitle) in
            articleTitle.placeholder = "Enter article title"
        }

        alert.addTextField { (articleContent) in
            articleContent.placeholder = "Enter article content"
        }
        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)

    }

    @objc func userCountButtonDidTouch() {
        performSegue(withIdentifier: listToUsers, sender: nil)
    }
}
