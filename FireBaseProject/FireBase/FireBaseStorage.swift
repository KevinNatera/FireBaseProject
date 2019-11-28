//
//  FireBaseStorage.swift
//  FireBaseProject
//
//  Created by Kevin Natera on 11/25/19.
//  Copyright © 2019 Kevin Natera. All rights reserved.
//

import Foundation
import FirebaseStorage

enum typeOfReference: String {
    case post = "postImage"
    case profile = "profileImage"
}
class FirebaseStorage {
    
    
    static var profileManager = FirebaseStorage(type: .profile)
    static var postManager = FirebaseStorage(type: .post)
    private let storage: Storage!
    private let storageReference: StorageReference
    private let imagesFolderReference: StorageReference
    
    init(type: typeOfReference) {
        storage = Storage.storage()
        storageReference = storage.reference()
        imagesFolderReference = storageReference.child(type.rawValue)
    }
    
    
    func storeImage(image: Data,  completion: @escaping (Result<URL,Error>) -> ()) {
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let uuid = UUID()
        let imageLocation = imagesFolderReference.child(uuid.description)
        imageLocation.putData(image, metadata: metadata) { (responseMetadata, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                imageLocation.downloadURL { (url, error) in
                    guard error == nil else {completion(.failure(error!));return}
                    guard let url = url else {completion(.failure(error!));return}
                    completion(.success(url))
                }
            }
        }
    }
    
    func getImages(profileUrl: String, completion: @escaping (Result<Data, Error>) -> ()){
        imagesFolderReference.storage.reference(forURL: profileUrl).getData(maxSize: 20000000) { (data, error) in
            if let error = error{
                completion(.failure(error))
            } else  if let data = data {
                completion(.success(data))
            }
        }
    }
}
