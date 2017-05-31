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

class AnsweredVC: UIViewController, UITableViewDelegate, UITableViewDataSource, PostCellDelegate, ReloadTableDelegate {
  
  @IBOutlet weak var tableView: UITableView!
    
  //MARK: - VC LIFECYCLE
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NotificationCenter.default.addObserver(self, selector: #selector(AnsweredVC.reloadTable), name: NSNotification.Name(rawValue: "reloadTables"), object: nil)
    
    self.tableView.estimatedRowHeight = 300
    self.tableView.rowHeight = UITableViewAutomaticDimension
    
    self.tableView.scrollsToTop = false
    DataService.ds.delegate = self
    DataService.ds.downloadTableContent()
    
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    
    if AppState.shared.currentState == .presentLoginFromComments {
      
      dismiss(animated: false, completion: nil)
      
    } else {
      
      AppState.shared.currentState = .answered
      tableView.reloadData()
    }
    
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if segue.identifier == Constants.Segues.showProfile.rawValue {
      let backItem = UIBarButtonItem()
      backItem.title = "Back"
      navigationItem.backBarButtonItem = backItem
    }
  }
  
  //MARK: - BUTTONS
  
  @IBAction func profileButtonPressed(_ sender: UIButton) {
    performSegue(withIdentifier: Constants.Segues.showProfile.rawValue, sender: self)
  }
  
  
  //MARK: - TABLE VIEW
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return DataService.ds.answeredPosts.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if AppState.shared.currentState == .answered {
      
      if let cell = tableView.dequeueReusableCell(withIdentifier: "answeredCell") as? AnsweredCell {

        print("indexPath = ", indexPath.row)
        
        let post = DataService.ds.answeredPosts[indexPath.row]
        
        var img: UIImage?
        var profileImg: UIImage?
        
        cell.showcaseImg.isHidden = false
        cell.showcaseImg.image = nil
        cell.profileImg.isHidden = false
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
    }
    return UITableViewCell()
  }
  
  
  //MARK - POST CELL DELEGATE
  
  func reloadTable() {
    
//    tableView.reloadData()
    
  }
  
  func showAlert(_ post: Post) {
    displayAlert(post)
  }
  
  func customCellCommentButtonPressed() {
    
    performSegue(withIdentifier: "showComments", sender: self)
  }
  
  
  //MARK: - ALERTS
  
  func displayAlert(_ post: Post) {
    
    guard let user = DataService.ds.currentUserKey else { guestAlert(); return }
    
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    //post belongs to user
    if post.userKey == user {
      
      //Potentially change this to mark as unanswered
//      alert.addAction(UIAlertAction(title: "Update answer", style: .Default, handler: { (action) in
//        
////        DataService.ds.markPostAsAnswered(post)
//        
//      }))
      
      alert.addAction(UIAlertAction(title: "   Delete Post 👋", style: .default, handler: { (action) in
        
        DataService.ds.deletePost(post)
        
      }))
      
    } else {
      
      alert.addAction(UIAlertAction(title: "Report", style: .default, handler: { action in
        
        self.reportAlert(post)
        
      }))
      
      alert.addAction(UIAlertAction(title: "Block User", style: .default, handler: { action in
        
        DataService.ds.blockUser(post)
        
      }))
      
    }
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  func reportAlert(_ post: Post) {
    
    let alert = UIAlertController(title: "Submit report", message: nil, preferredStyle: .alert)
    
    alert.addTextField { (textField) in
      
      textField.placeholder = "Reason for report"
      textField.returnKeyType = .default
    }
    
    alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { (action) in
      
      DataService.ds.reportPost(post, reason: alert.textFields![0].text!)
      
    }))
    
    self.present(alert, animated: true, completion:  nil)
  }
  
  func guestAlert() {
    
    let alert = UIAlertController(title: "Function unavailable 😕", message: "You must be logged in to comment", preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Login", style: .default, handler: { action in
      
      self.dismiss(animated: false, completion: nil)
      
    }))
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  override var preferredStatusBarStyle : UIStatusBarStyle {
    return .lightContent
  }
  
}
