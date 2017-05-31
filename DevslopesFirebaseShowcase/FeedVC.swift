//
//  FeedVC.swift
//  Wilbur
//
//  Created by Ben Sullivan on 16/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import FirebaseStorage

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, PostCellDelegate, ReloadTableDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  
  fileprivate let indicator = UIActivityIndicatorView()
    
  //MARK: - VC LIFECYCLE
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NotificationCenter.default.addObserver(self, selector: #selector(FeedVC.reloadTable), name: NSNotification.Name(rawValue: "reloadTables"), object: nil)
    
    self.tableView.estimatedRowHeight = 400
    self.tableView.rowHeight = UITableViewAutomaticDimension
    
    self.tableView.scrollsToTop = false
    DataService.ds.delegate = self
    
    DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {

      DataService.ds.downloadTableContent()
//
//    dispatch_async(dispatch_get_main_queue(),{
//
//      
//        })
      })
    
    addIndicator()
    
    AppState.shared.currentState = .feed
    
    tableView.delegate = self
    tableView.dataSource = self
    
//    NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(self.checkLoggedIn), userInfo: nil, repeats: false)
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    
    if AppState.shared.currentState == .presentLoginFromComments {
      
      dismiss(animated: false, completion: nil)
      
    } else {
      
      AppState.shared.currentState = .feed
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
    print(DataService.ds.posts.count)
    
    return DataService.ds.posts.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if AppState.shared.currentState == .feed {
      
      let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostCell
      
      let post = DataService.ds.posts[indexPath.row]
      
      var img: UIImage?
      var profileImg: UIImage?
      
      if let url = post.imageUrl {
        img = Cache.shared.imageCache.object(forKey: url as AnyObject) as? UIImage
        cell.showcaseImg.isHidden = false
        cell.showcaseImg.image = UIImage(named: "DownloadingImageBackground")
        
      }
      
      if indicator.isAnimating {
        self.indicator.stopAnimating()
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
  
  func reloadTable() {
    
    tableView.reloadData()
    indicator.stopAnimating()
  }
  
  func showAlert(_ post: Post) {
    displayAlert(post)
  }
  
  func customCellCommentButtonPressed() {
    
    performSegue(withIdentifier: Constants.Segues.showComments.rawValue, sender: self)
  }
  
  
  //MARK: - ALERTS
  
  func displayAlert(_ post: Post) {
    
    guard let user = DataService.ds.currentUserKey else { guestAlert(); return }
    
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
      //post belongs to user
      if post.userKey == user {
        
        alert.addAction(UIAlertAction(title: "   Mark as Answered 😃", style: .default, handler: { (action) in
          
          self.markAsAnsweredAlert(post)
          
        }))
        
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
  
  func markAsAnsweredAlert(_ post: Post) {
    
    let alert = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
    
    alert.addTextField { (textField) in
      
      textField.placeholder = "Answer"
      textField.returnKeyType = .default
    }
    
    alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { action in
      
      print(alert.textFields![0])
      if alert.textFields![0].text == "" {
        
        self.answerMissingAlert(post)
        
      } else {
        
        DataService.ds.markPostAsAnswered(post, answer: alert.textFields![0].text!)

      }
      
    }))
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
    
    self.present(alert, animated: true, completion:  nil)
  }
  
  func answerMissingAlert(_ post: Post) {
    
    let alert = UIAlertController(title: "Answer missing!", message: nil, preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
      
      self.markAsAnsweredAlert(post)
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
  
  //MARK: - OTHER FUNCTIONS
  
  func checkLoggedIn() {
    
    if DataService.ds.posts.isEmpty {

      dismiss(animated: true, completion: nil)
      
      let loginViewController: UIViewController!
      
      let storyboard = UIStoryboard(name: "Login", bundle: nil)
      loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginVC")
      
      present(loginViewController, animated: true, completion: nil)
      
    }
  }
  
  func addIndicator() {
    indicator.startAnimating()
    indicator.hidesWhenStopped = true
    indicator.activityIndicatorViewStyle = .gray
    indicator.frame = CGRect(x: self.view.frame.width / 2, y: self.view.frame.width / 2, width: 15.0, height: 15.0)
    
    self.view.addSubview(indicator)
  }
  
  override var preferredStatusBarStyle : UIStatusBarStyle {
    return .lightContent
  }
  
}
