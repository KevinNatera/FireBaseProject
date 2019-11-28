//
//  FeedVC.swift
//  
//
//  Created by Kevin Natera on 11/26/19.
//

import UIKit

class FeedVC: UIViewController {
    
    @IBOutlet weak var feedTableOutlet: UITableView!
    
    var user = AppUser(from: FirebaseAuthService.manager.currentUser!)
    
    var posts = [Post]() {
        didSet {
           
            feedTableOutlet.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let detailVC = segue.destination as? PostDetailVC else { fatalError() }
        
        let post = posts[feedTableOutlet.indexPathForSelectedRow!.row]
        
        detailVC.post = post
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        getPosts()
        
      
    }
    
    private func setup() {
        feedTableOutlet.delegate = self
        feedTableOutlet.dataSource = self
        feedTableOutlet.rowHeight = 200
    }
    
    
    private func getPosts(){
        
        FirestoreService.manager.getAllPost { (result) in
            DispatchQueue.main.async {
                switch result{
                case .failure(let error):
                    print(error)
                case .success(let data):
                    self.posts = data.filter { (post) -> Bool in
                        return post.creatorID != self.user.uid
                    }
                }
                
            }
        }}
    
}

extension FeedVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = feedTableOutlet.dequeueReusableCell(withIdentifier: "post") as! FeedTableViewCell
        let post = posts[indexPath.row]
        cell.configureCell(post: post)
        return cell
    }
    
}
