//
//  CommentsVCViewController.swift
//  Wilbur
//
//  Created by Ben Sullivan on 02/07/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class CommentsVC: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var postButton: UIButton!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var commentTextView: UITextView!
  @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?
  @IBOutlet var postButtonHeightLayoutConstraint: NSLayoutConstraint?

  fileprivate var viewAppeared = false
  fileprivate var viewDismissing = false
  fileprivate var keyArray = [String]()
  fileprivate var valueArray = [String]()
  fileprivate var usernameArray = [String]()

  fileprivate var commentRef: FIRDatabaseReference!
    
  var post: Post? = nil
  var postImage: UIImage? = nil
  var textFrame: CGRect? = nil
  
  
  //MARK: - VC LIFECYCLE
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Comments"
    
    configureTableView()
    configureTextView()
    
    NotificationCenter.default.addObserver(self, selector: #selector(CommentsVC.reloadComments), name: NSNotification.Name(rawValue: "updateComments"), object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(CommentsVC.keyboardNotification(_:)),name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    
    keyArray = (post?.commentText)!
    valueArray = (post?.commentUsers)!

    populateUsernames()
    
    postButton.isEnabled = false
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    viewDismissing = false
    viewAppeared = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    viewDismissing = true
  }
  
  
  //MARK: - BUTTONS
  
  func reloadComments() {
    
    populateUsernames()
  
  }
  @IBAction func postButtonPressed(_ sender: AnyObject) {
    
    guard let currentUser = DataService.ds.currentUserKey else { guestAlert(); return }

    guard var comment = commentTextView.text, comment != DescriptionText.defaultText && commentTextView.text != "" else { return }
    
    //FIXME: Work on this bug fix, functions correctly but inefficient
    //Commnt Key/Values need to be swapped
    comment = comment.replacingOccurrences(of: ".", with: ",")
    comment = comment.replacingOccurrences(of: "#", with: "-")
    comment = comment.replacingOccurrences(of: "$", with: "£")
    comment = comment.replacingOccurrences(of: "[", with: "(")
    comment = comment.replacingOccurrences(of: "]", with: ")")
    comment = comment.replacingOccurrences(of: "/", with: "-")
    comment = comment.replacingOccurrences(of: "\\", with: "-")

    commentTextView.text = DescriptionText.defaultText
    commentTextView.textColor = .lightGray
    bringCursorToStart()
    postButton.isEnabled = false

    let newCommentRef = DataService.ds.REF_POSTS.child(post!.postKey).child("comments").child(String(keyArray.count)).child(comment)
    keyArray.append(comment)
    
    self.view.endEditing(true)

    newCommentRef.setValue(currentUser)
    
    valueArray.append(currentUser)
    
    markAsCommented()
  }
  
  func markAsCommented() {
    
    guard let selectedPost = post else { return }
    
    commentRef = DataService.ds.REF_USER_CURRENT.child("comments").child(selectedPost.postKey)
    
    commentRef.observeSingleEvent(of: .value, with: { snapshot in
      
      if let _ = snapshot.value as? NSNull {

        self.commentRef.setValue(true)
        
        Cache.shared.commentedOnCache.removeObject(forKey: selectedPost.postKey as AnyObject)
        
      }
    })

  }
  
  //MARK: - POPULATE USERNAMES
  
  func populateUsernames() {
    
    usernameArray = []
    
    let users = DataService.ds.usernames
    
    for i in valueArray {
      
      if let user = users[i] {
        
        usernameArray.append(user)
      }
    }
    
    for i in valueArray {
      
      let userRef = DataService.ds.REF_USERS.child(i)
      
      userRef.observe(FIRDataEventType.value, with: { snapshot in
        let userDict = snapshot.value as! [String : AnyObject]
        
        for user in userDict where user.0 == "username" {
          
          let name = user.1 as! String
          
          //          self.usernameArray.append(name)
          print(name)
        }
        self.tableView.reloadData()
        
      })
    }
  }
  
  
  //MARK: - TABLE VIEW
  
  fileprivate struct cellID {
    static let commentCell = "commentCell"
    static let imageCell = "commentCellImage"
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    if indexPath.section == 0 {
      
      if let image = postImage {
        
        let height = AVMakeRect(aspectRatio: (image.size), insideRect: self.view.frame).height
        
        if let textHeight = textFrame?.height {
          
          return height + textHeight

        }

        return height + 38
      }
    
    return UITableViewAutomaticDimension
      
    } else {
      
      return UITableViewAutomaticDimension
    }

  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.view.endEditing(true)
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   
    switch section {
    case 0:
      return 1
    case 1:
      return keyArray.count

    default: return 0
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if let cell = tableView.dequeueReusableCell(withIdentifier: cellID.commentCell) as? CommentCell, indexPath.section == 1 {
     
      let ip = indexPath.row
      
      if let username = usernameArray.ref(ip) {
        
        cell.configureCell(keyArray[ip], value: valueArray[ip], user: username)

      } else {
        cell.configureCell(keyArray[ip], value: valueArray[ip], user: "")
        
      }
      return cell
    }
    
    if let cellContent = tableView.dequeueReusableCell(withIdentifier: cellID.imageCell) as? CommentImageCell, indexPath.section == 0 {
      
      cellContent.configureCell(post, downloadedImage: postImage)
      
      return cellContent
      
    }
    
    return UITableViewCell()
    
  }
  
  
  //MARK: - TEXT VIEW AND KEYBOARD
  
  struct DescriptionText {
    static let defaultText = "Write a suggestion"
  }
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    
    if textView.text != DescriptionText.defaultText || textView.text != "" {
      postButton.isEnabled = true
    }
    
    if textView.text == DescriptionText.defaultText && viewAppeared == true {
      commentTextView.text = ""
      commentTextView.textColor = .black
    }
    return true
  }
  
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  func keyboardNotification(_ notification: Notification) {
    
    if let userInfo = notification.userInfo, viewDismissing == false {
      
      let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
      let duration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
      let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
      let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions().rawValue
      let animationCurve: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
      
      if endFrame?.origin.y >= UIScreen.main.bounds.size.height {
        
        self.keyboardHeightLayoutConstraint?.constant = 0.0
        self.postButtonHeightLayoutConstraint?.constant = 0.0
        
      } else {
        
        self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
        self.postButtonHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0

      }
      
      UIView.animate(withDuration: duration,
                                 delay: TimeInterval(0),
                                 options: animationCurve,
                                 animations: { self.view.layoutIfNeeded() },
                                 completion: nil)
    }
    
  }
  
  //MARK: - INITIAL SETUP
  
  func configureTableView() {
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(CommentsVC.tapped))
    tap.numberOfTapsRequired = 1
    
    tableView.addGestureRecognizer(tap)
    tableView.estimatedRowHeight = 40
    tableView.rowHeight = UITableViewAutomaticDimension
    
  }
  
  func configureTextView() {
    
    let customGrey = UIColor(colorLiteralRed: 196/255, green: 196/255, blue: 196/255, alpha: 0.5)
    
    commentTextView.becomeFirstResponder()
    commentTextView.delegate = self
    commentTextView.text = DescriptionText.defaultText
    commentTextView.textColor = .lightGray
    commentTextView.layer.addBorder(.top, color: customGrey, thickness: 1)
    postButton.layer.addBorder(.top, color: customGrey, thickness: 1)

    bringCursorToStart()
  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {//Not working, needs to move cursor
    
    if viewAppeared && commentTextView.text == DescriptionText.defaultText {
      
      commentTextView.text = ""
      commentTextView.textColor = .black
      postButton.isEnabled = false

    }
    
  }
  
  func bringCursorToStart() {
    let start = commentTextView.beginningOfDocument
    commentTextView.selectedTextRange = commentTextView.textRange(from: start, to: start)
  }
  
  //MARK: - ALERTS
  
  func guestAlert() {
    
    let alert = UIAlertController(title: "Function unavailable", message: "You must be logged in to comment", preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Login", style: .default, handler: { action in
    
    AppState.shared.currentState = .presentLoginFromComments
      
    self.navigationController?.popViewController(animated: false)
      
    }))
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))

    
    self.present(alert, animated: true, completion: nil)
  }
  
  func tapped() {
    self.view.endEditing(true)
  }
  
  
  //MARK: - MISC
  
  override var preferredStatusBarStyle : UIStatusBarStyle {
    return .lightContent
  }
  
}

private extension CALayer {
  
  func addBorder(_ edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
    
    let border = CALayer()
    
    switch edge {
    case UIRectEdge.top:
      border.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: thickness)
        default: break
    }
    
    border.backgroundColor = color.cgColor;
    
    self.addSublayer(border)
  }
}
