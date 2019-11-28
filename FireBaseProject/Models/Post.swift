//
//  Post.swift
//  FireBaseProject
//
//  Created by Kevin Natera on 11/25/19.
//  Copyright © 2019 Kevin Natera. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct Post {
    let id: String
    let creatorID: String
    let dateCreated: Date?
    let imageUrl: String?

    
    init( creatorID: String, dateCreated: Date? = nil , imageUrl: String? = nil){
        self.creatorID = creatorID
        self.dateCreated = dateCreated
        self.imageUrl = imageUrl
        self.id = UUID().description
   
    }
    init? (from dict: [String: Any], id: String){
        guard let userId = dict["creatorID"] as? String,
         let userImage = dict["imageUrl"] as? String,
    
         let dateCreated = (dict["dateCreated"] as? Timestamp)?.dateValue() else { return nil }
        self.creatorID = userId
        self.id = id
        self.dateCreated = dateCreated
        self.imageUrl = userImage
    }
    var fieldsDict: [String: Any] {
           return [
               "creatorID": self.creatorID,
               "imageUrl": self.imageUrl ?? "",
           ]
       }
}
