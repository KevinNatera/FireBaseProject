//
//  PostDetailVC.swift
//  FireBaseProject
//
//  Created by Kevin Natera on 11/27/19.
//  Copyright © 2019 Kevin Natera. All rights reserved.
//

import UIKit

class PostDetailVC: UIViewController {

    
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var dateCreatedLabel: UILabel!
    
    var post: Post!
       
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }

    private func loadData() {
        FirebaseStorage.postManager.getImages(profileUrl: post.imageUrl!) { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let imageData):
                self.imageOutlet.image = UIImage(data: imageData)
            }
        }
        
        FirestoreService.manager.getUserFromPost(creatorID: post.creatorID) { (result) in
                   DispatchQueue.main.async {
                       switch result{
                       case .failure(let error):
                           print(error)
                       case .success(let user):
                           if let userName = user.userName {
                               self.creatorLabel.text = userName
                           } else if let email = user.email {
                               self.creatorLabel.text = email
                           } else {
                               self.creatorLabel.text = "New User"
                           }
                       }
                   }
               }
        
        let df = DateFormatter()
        df.dateFormat = "MM-dd-yyyy   hh:mm aa"
        dateCreatedLabel.text = df.string(from: post.dateCreated!)
    }
    
    
}
