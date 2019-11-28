//
//  ProfileVC.swift
//  FireBaseProject
//
//  Created by Kevin Natera on 11/26/19.
//  Copyright © 2019 Kevin Natera. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {

    var user = AppUser(from: FirebaseAuthService.manager.currentUser!)
    
    
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var userNameTextFieldOutlet: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
        let imagePickerViewController = UIImagePickerController()
        imagePickerViewController.delegate = self
        imagePickerViewController.sourceType = .photoLibrary
        present(imagePickerViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        guard let newUserName = userNameTextFieldOutlet.text else {
            showAlert(title: "No username entered", message: "Please enter a new username.")
            return
        }
        
        guard let imageData = imageOutlet.image?.jpegData(compressionQuality: 1.0) else {
            showAlert(title: "No image selected", message: "Please select a profile image.")
            return
        }
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        FirebaseStorage.profileManager.storeImage(image: imageData, completion: { [weak self] (result) in
            switch result {
            case .failure(let error):
                print(error)
                self!.disableSpinner()
            case .success(let url):
                FirebaseAuthService.manager.updateUserFields(userName: newUserName, photoURL: url) { (result) in
                    switch result {
                    case .failure(let error):
                        print(error)
                        self!.disableSpinner()
                    case .success(()):
                        FirestoreService.manager.updateCurrentUser(userName: newUserName, photoURL: url) { [weak self] (result) in
                            switch result {
                            case .failure(let error):
                                print(error)
                                self!.disableSpinner()
                            case .success(()):
                                self!.disableSpinner()
                                self!.showAlert(title: "Success!", message: "Profile successfully updated.")
                            }
                        }
                    }
                }
            }
        })
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    private func setUp() {
        activityIndicator.isHidden = true
        if user.userName == nil {
            userNameTextFieldOutlet.text = user.email
        } else {
            userNameTextFieldOutlet.text = user.userName
        }
        
        if let photoUrl = user.photoURL {
        FirebaseStorage.profileManager.getImages(profileUrl: photoUrl) { (result) in
            switch result{
            case .failure(let error):
                self.imageOutlet.image = UIImage(named: "noImage")
            case .success(let data):
                self.imageOutlet.image = UIImage(data: data)
            }
        }
        } else {
            self.imageOutlet.image = UIImage(named: "noImage")
        }
    }
    
    private func disableSpinner() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showAlert(title: String, message: String) {
           let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
           alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
           present(alertVC, animated: true, completion: nil)
       }

}

extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        
        self.imageOutlet.image = image
        dismiss(animated: true, completion: nil)
    }
}

extension ProfileVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
