//
//  ViewController.swift
//  FireBaseProject
//
//  Created by Kevin Natera on 11/22/19.
//  Copyright © 2019 Kevin Natera. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginVC: UIViewController {
    
    //MARK: - Properties
    @IBOutlet weak var emailTextFieldOutlet: UITextField!
    @IBOutlet weak var passwordTextFieldOutlet: UITextField!
    @IBOutlet weak var loginButtonOutlet: UIButton!
    @IBOutlet weak var alreadyLabel: UILabel!
    @IBOutlet weak var signUpLabel: UILabel!
    
    
    var user = AppUser(from: FirebaseAuthService.manager.currentUser!)
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        switchVC()
    }
    
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        guard let email = emailTextFieldOutlet.text, let password = passwordTextFieldOutlet.text else {
            showAlert(title: "Error", message: "Please fill out all fields.")
            return
        }
        guard email.isValidEmail else {
            showAlert(title: "Error", message: "Please enter a valid email.")
            return
        }
        guard password.isValidPassword else {
            showAlert(title: "Error", message: "Please enter a valid password. Passwords must have at least 8 characters.")
            return
        }
        
        switch signUpLabel.text {
        case "Login":
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
                if let user = result?.user {
                    UserDefaults.standard.set(email, forKey: "email")
                    UserDefaults.standard.set(password, forKey: "password")
                    self?.dismiss(animated: true)
                    self?.performSegue(withIdentifier: "toFeed", sender: (Any).self)
                } else if let error = error {
                    FirebaseAuthService.manager.createNewUser(email: email.lowercased(), password: password) { [weak self] (result) in
                        switch error.localizedDescription {
                        case "The password is invalid or the user does not have a password.":
                            self!.showAlert(title: "Incorrect Password!", message: "\(error.localizedDescription)")
                        case "There is no user record corresponding to this identifier. The user may have been deleted.":
                            self!.showAlert(title: "New Account Created", message: "\(error.localizedDescription)" + "A new account has been created for you using the above credentials.")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                                self!.performSegue(withIdentifier: "toFeed", sender: self)
                            }
                        default:
                            self?.handleCreateAccountResponse(with: result)
                        }
                    }
                }
            }
        default:
            FirebaseAuthService.manager.createNewUser(email: email.lowercased(), password: password) { [weak self] (result) in
                self?.handleCreateAccountResponse(with: result)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        preFill()
    }
    
    
    //MARK: - Private Methods
    
    
    private func setUp() {
        emailTextFieldOutlet.delegate = self
        emailTextFieldOutlet.keyboardType = .emailAddress
        passwordTextFieldOutlet.delegate = self
    }
    
    private func preFill() {
        if let email = UserDefaults.standard.value(forKey: "email") as? String, let password = UserDefaults.standard.value(forKey: "password") as? String {
            self.emailTextFieldOutlet.text = email
            self.passwordTextFieldOutlet.text = password
            self.switchVC()
        }
    }
    
    private func switchVC() {
        if signUpLabel.text == "Sign Up" {
            signUpLabel.text = "Login"
            alreadyLabel.text = "Don't have an account yet?"
            loginButtonOutlet.setTitle("Sign Up.", for: .normal)
        } else {
            signUpLabel.text = "Sign Up"
            alreadyLabel.text = "Already have an account?"
            loginButtonOutlet.setTitle("Login.", for: .normal)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    
    private func handleCreateAccountResponse(with result: Result<User, Error>) {
        DispatchQueue.main.async { [weak self] in
            switch result {
            case .success(let user):
                FirestoreService.manager.SaveUser(user: AppUser(from: user)) { [weak self] newResult in
                    self?.handleCreatedUserInFirestore(result: newResult)
                }
            case .failure(let error):
                self?.showAlert(title: "Error creating user", message: "An error occured while creating new account \(error)")
            }
        }
    }
    
    private func handleCreatedUserInFirestore(result: Result<(), Error>) {
        switch result {
        case .success:
            performSegue(withIdentifier: "toFeed", sender: self)
        case .failure(let error):
            self.showAlert(title: "Error creating user", message: "An error occured while creating new account \(error)")
        }
    }
}


//MARK: - Extensions
extension LoginVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
