/// Copyright (c) 2018 Razeware LLC





import UIKit
import Firebase

class LoginViewController: UIViewController {

    var author = Author(uid: "", email: "")
    
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Actions
    @IBAction func loginDidTouch(_ sender: AnyObject) {
        
        performSegue(withIdentifier: "SegueToNavigationController", sender: nil)
        
        guard
            let email = textFieldLoginEmail.text,
            let password = textFieldLoginPassword.text,
            email.count > 0,
            password.count > 0
            else {
                return
                
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if let error = error, user == nil {
                
                let alert = UIAlertController(title: "Sign In Failed", message: error.localizedDescription, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                
                self.present(alert, animated: true)
                
            }
            
        }
        
    }
  
    @IBAction func signUpDidTouch(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: "Register",
                                      message: "Register",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            
            guard
                let emailField = alert.textFields?[0],
                let email = emailField.text
                else { print("Email input error.")
                    return
            }
            
            guard
                let passwordField = alert.textFields?[1],
                let password = passwordField.text
                else { print("Password input error.")
                    return
            }
            
            guard
                let firstNameField = alert.textFields?[2],
                let firstName = firstNameField.text
                else { print("Firstname input error.")
                    return
            }
            
            guard
                let lastNameField = alert.textFields?[3],
                let lastName = lastNameField.text
                else { print("Lastname input error.")
                    return
            }
            
            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                
                if let error = error {
                    
                    print("Create new user authorization error.", error)
                    
                } else {
                    
                    guard
                        let loginEmail = self.textFieldLoginEmail.text,
                        let loginPassword = self.textFieldLoginPassword.text
                        else { print("Login Email or Password error.")
                            return
                    }
                    
                    if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {

                        changeRequest.displayName = firstName + lastName

                        changeRequest.commitChanges(completion: { (error) in

                            if let error = error {

                                print("Fail to change displayName:\(error.localizedDescription)")

                            }

                        })

                    }
                    
                    Auth.auth().signIn(withEmail: loginEmail, password: loginPassword, completion: nil)
                    
                }
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        alert.addTextField { textEmail in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextField { textPassword in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        alert.addTextField { (textFirstName) in
            textFirstName.placeholder = "Enter your first name"
        }
        
        alert.addTextField { (textLastName) in
            textLastName.placeholder = "Enter your last name"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            
            
            if let user = user {
                
//                guard var author = self.author
//                    else { print("author in LoginViewController is nil.")
//                    return
//                }
                
                self.author = Author(authData: user)
                print("self.author in addStateDidChangeListener", self.author)
                self.performSegue(withIdentifier: "SegueToNavigationController", sender: nil)
                
                self.textFieldLoginEmail.text = nil
                self.textFieldLoginPassword.text = nil
                
            } else {
                
                print("user is nil.")
                
            }
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SegueToNavigationController" {
            
            if let navigationController = segue.destination as? UINavigationController {

                if let destinationViewController = navigationController.topViewController as? ArticleListTableViewController {

                    destinationViewController.author = self.author
                    print("in destinationViewController")

                } else {

                    print("navigationController as ArticleListTableViewController error.")

                }
                
            } else {
                
                print("segue destination as navigationController error.")
                
            }
            
        } else {
            
            print("segue identifier error.")
            
        }
        
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldLoginEmail {
            textFieldLoginPassword.becomeFirstResponder()
        }
        if textField == textFieldLoginPassword {
            textField.resignFirstResponder()
        }
        return true
    }
}
