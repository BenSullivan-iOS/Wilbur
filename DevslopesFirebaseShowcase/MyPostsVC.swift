//
//  Answered
//  Wilbur
//
//  Created by Ben Sullivan on 16/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import FirebaseStorage

class MyPostsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MyPostsCellDelegate, ReloadTableDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  
  var selectedPost: Post? = nil
  var selectedPostImage: UIImage? = nil
    
  //MARK: - VC LIFECYCLE
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Posts"
    
    NotificationCenter.default.addObserver(self, selector: #selector(MyPostsVC.reloadTable), name: NSNotification.Name(rawValue: "reloadTables"), object: nil)
    
    self.tableView.estimatedRowHeight = 300
    self.tableView.rowHeight = UITableViewAutomaticDimension
    
    self.tableView.scrollsToTop = false
    
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    
    if AppState.shared.currentState == .presentLoginFromComments {
      
      dismiss(animated: false, completion: nil)
      
    } else {
      
      tableView.reloadData()
    }
    
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if segue.identifier == Constants.Segues.showProfile.rawValue {
      let backItem = UIBarButtonItem()
      backItem.title = "Back"
      navigationItem.backBarButtonItem = backItem
    }
    
    if segue.identifier == "showComments" {
      
      if let dest = segue.destination as? CommentsVC {
        
        dest.post = selectedPost
        dest.postImage = selectedPostImage
        
        selectedPost = nil
        selectedPostImage = nil
      }
    }
  }
  
  //MARK: - BUTTONS
  
  @IBAction func profileButtonPressed(_ sender: UIButton) {
    performSegue(withIdentifier: Constants.Segues.showProfile.rawValue, sender: self)
  }
  
  
  //MARK: - TABLE VIEW
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return DataService.ds.myPosts.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
      if let cell = tableView.dequeueReusableCell(withIdentifier: "myPostCell") as? MyPostsCell {
        
        print("indexPath = ", indexPath.row)
        
        let post = DataService.ds.myPosts[indexPath.row]
        
        var img: UIImage?
        var profileImg: UIImage?
        
        cell.showcaseImg.isHidden = true
        cell.showcaseImg.image = nil
        cell.profileImg.isHidden = true
        cell.profileImg.image = nil
        
        if let url = post.imageUrl {
          img = Cache.shared.imageCache.object(forKey: url as AnyObject) as? UIImage
          cell.showcaseImg.isHidden = false
          cell.showcaseImg.image = UIImage(named: "DownloadingImageBackground")
        }
        
        if let profileImage = Cache.shared.profileImageCache.object(forKey: post.userKey as AnyObject) as? UIImage {
          profileImg = profileImage
        }
        
        cell.delegate = self
        cell.reloadTableDelegate = self
        cell.configureCell(post, img: img, profileImg: profileImg)
        
        return cell

      }
    return UITableViewCell()
  }
  
  //MARK - POST CELL DELEGATE
  
  func showComments(_ post: Post, image: UIImage) {
    
    selectedPostImage = image
    selectedPost = post
    
    performSegue(withIdentifier: "showComments", sender: self)
  }
  func reloadTable() {
    
    tableView.reloadData()
    
  }
  
  func showDeleteAlert(_ post: Post) {
    
    let alert = UIAlertController(title: "Are you sure you want to delete this post??", message: nil, preferredStyle: .actionSheet)
    
    alert.addAction(UIAlertAction(title: "🤔...Yes please!", style: .default, handler: { (action) in
        
        DataService.ds.deletePost(post)
        
      }))
    
    alert.addAction(UIAlertAction(title: "   No thanks 😁", style: .cancel, handler: nil))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  //MARK: - ALERTS
  
  override var preferredStatusBarStyle : UIStatusBarStyle {
    return .lightContent
  }
  
}
