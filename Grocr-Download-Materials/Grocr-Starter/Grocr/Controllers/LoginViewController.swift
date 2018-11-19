/// Copyright (c) 2018 Razeware LLC





import UIKit
import Firebase

class LoginViewController: UIViewController {
  
  // MARK: Constants
  let loginToList = "LoginToList"
  
  // MARK: Outlets
  @IBOutlet weak var textFieldLoginEmail: UITextField!
  @IBOutlet weak var textFieldLoginPassword: UITextField!
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: Actions
  @IBAction func loginDidTouch(_ sender: AnyObject) {

    performSegue(withIdentifier: loginToList, sender: nil)

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
                return }
        guard
            let passwordField = alert.textFields?[1],
            let password = passwordField.text
            else { print("Password input error.")
                return }

        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in

            if let error = error {

                print("Create new user authorization error.", error)

            } else {

                guard
                    let loginEmail = self.textFieldLoginEmail.text,
                    let loginPassword = self.textFieldLoginPassword.text
                    else { print("Login Email or Password error.")
                        return }

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
    
    alert.addAction(saveAction)
    alert.addAction(cancelAction)
    
    present(alert, animated: true, completion: nil)
  }

    override func viewDidLoad() {
        super.viewDidLoad()

        Auth.auth().addStateDidChangeListener { (auth, user) in

            guard
                user != nil else { print("user is nil.")
                return
            }
            self.performSegue(withIdentifier: self.loginToList, sender: nil)
            self.textFieldLoginEmail.text = nil
            self.textFieldLoginPassword.text = nil
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
