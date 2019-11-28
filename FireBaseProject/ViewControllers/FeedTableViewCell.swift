//
//  FeedTableViewCell.swift
//  FireBaseProject
//
//  Created by Kevin Natera on 11/27/19.
//  Copyright © 2019 Kevin Natera. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postImageOutlet: UIImageView!
    
    
    func configureCell(post: Post) {
        FirebaseStorage.postManager.getImages(profileUrl: post.imageUrl!) { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let imageData):
                self.postImageOutlet.image = UIImage(data: imageData)
            }
        }
        FirestoreService.manager.getUserFromPost(creatorID: post.creatorID) { (result) in
            DispatchQueue.main.async {
                switch result{
                case .failure(let error):
                    print(error)
                case .success(let user):
                    if let userName = user.userName {
                        self.userNameLabel.text = userName
                    } else if let email = user.email {
                        self.userNameLabel.text = email
                    } else {
                        self.userNameLabel.text = "New User"
                    }
                }
            }
        }
    }
}
