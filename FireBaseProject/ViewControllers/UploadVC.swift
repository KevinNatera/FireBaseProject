//
//  UploadVC.swift
//  FireBaseProject
//
//  Created by Kevin Natera on 11/26/19.
//  Copyright © 2019 Kevin Natera. All rights reserved.
//

import UIKit

class UploadVC: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageOutlet: UIImageView!
    
    var user = AppUser(from: FirebaseAuthService.manager.currentUser!)
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
        let imagePickerViewController = UIImagePickerController()
        imagePickerViewController.delegate = self
        imagePickerViewController.sourceType = .photoLibrary
        present(imagePickerViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func UploadButtonPressed(_ sender: UIButton) {
        guard let imageData = imageOutlet.image?.jpegData(compressionQuality: 1.0) else {
            showAlert(title: "No Image Selected", message: "Please select an image to upload.")
            return
        }
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        FirebaseStorage.postManager.storeImage(image: imageData, completion: { [weak self] (result) in
            switch result {
            case .success(let url):
                let post = Post(creatorID: self!.user.uid, dateCreated: nil, imageUrl: url.absoluteString )
                FirestoreService.manager.createPost(post: post) { (result) in
                    switch result{
                    case .success(()):
                        self!.disableSpinner()
                        self?.showAlert(title: "Success!", message: "Photo successfully uploaded.")
                    case .failure(let error):
                        print(error)
                        self!.disableSpinner()
                    }
                }
            case .failure(let error):
                self?.showAlert(title: "Error", message: "An error occurred while uploading photo.")
                self?.disableSpinner()
                print(error)
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    private func setUp() {
        imageOutlet.image = UIImage(named: "noImage")
        activityIndicator.isHidden = true
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

extension UploadVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        
        self.imageOutlet.image = image
        dismiss(animated: true, completion: nil)
    }
}
