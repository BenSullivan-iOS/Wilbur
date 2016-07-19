//
//  CommentsVCViewController.swift
// Wilbur
//
//  Created by Ben Sullivan on 02/07/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class CommentsVC: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var postButton: UIButton!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var commentTextView: UITextView!
  @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?
  @IBOutlet var postButtonHeightLayoutConstraint: NSLayoutConstraint?

  private var viewAppeared = false
  private var viewDismissing = false
  private var keyArray = [String]()
  private var valueArray = [String]()
  private var usernameArray = [String]()

  private var commentRef: FIRDatabaseReference!

  
  var post: Post? = nil
  var postImage: UIImage? = nil
  
  //MARK: - VC LIFECYCLE
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Comments"
    
    configureTableView()
    configureTextView()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CommentsVC.reloadComments), name: "updateComments", object: nil)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardNotification(_:)),name: UIKeyboardWillChangeFrameNotification, object: nil)
    
    keyArray = (post?.commentText)!
    valueArray = (post?.commentUsers)!
    print(keyArray)
    print(valueArray)
    
    print("view did for loop")

    populateUsernames()
    
    postButton.enabled = false
    
  }
  
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
      
      userRef.observeEventType(FIRDataEventType.Value, withBlock: { snapshot in
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
  
  override func viewDidAppear(animated: Bool) {
    viewDismissing = false
    viewAppeared = true
  }
  
  override func viewWillDisappear(animated: Bool) {
    viewDismissing = true
  }
  
  //MARK: - BUTTONS
  
  func reloadComments() {
    
    populateUsernames()
  
  }
  
  
  @IBAction func postButtonPressed(sender: AnyObject) {
    
    //add a unique string before the username
    //if string is not
    guard let currentUser = DataService.ds.currentUserKey else { guestAlert(); return }

    guard var comment = commentTextView.text
      where comment != DescriptionText.defaultText && commentTextView.text != "" else { return }
    
    //FIXME: Work on this bug fix, functions correctly but inefficient
    comment = comment.stringByReplacingOccurrencesOfString(".", withString: ",")
    comment = comment.stringByReplacingOccurrencesOfString("#", withString: "-")
    comment = comment.stringByReplacingOccurrencesOfString("$", withString: "£")
    comment = comment.stringByReplacingOccurrencesOfString("[", withString: "(")
    comment = comment.stringByReplacingOccurrencesOfString("]", withString: ")")

    commentTextView.text = DescriptionText.defaultText
    commentTextView.textColor = .lightGrayColor()
    bringCursorToStart()
    postButton.enabled = false

    let newCommentRef = DataService.ds.REF_POSTS.child(post!.postKey).child("comments").child(String(keyArray.count)).child(comment)
    keyArray.append(comment)

    newCommentRef.setValue(currentUser)
    
    valueArray.append(currentUser)
    
    markAsCommented()
  }
  
  func markAsCommented() {
    
    guard let selectedPost = post else { return }
    
    commentRef = DataService.ds.REF_USER_CURRENT.child("comments").child(selectedPost.postKey)
    
    commentRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
      
      if let _ = snapshot.value as? NSNull {

        self.commentRef.setValue(true)
        
        Cache.shared.commentedOnCache.removeObjectForKey(selectedPost.postKey)
        
      }
    })

  }
  
  
  
  //MARK: - TABLE VIEW
  
  private struct cellID {
    static let commentCell = "commentCell"
    static let imageCell = "commentCellImage"
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
    if indexPath.section == 0 {
      
      if let image = postImage {
        
        let height = AVMakeRectWithAspectRatioInsideRect((image.size), self.view.frame).height

        return height + UITableViewAutomaticDimension
      }
    
    return UITableViewAutomaticDimension
      
    } else {
      
      return UITableViewAutomaticDimension
    }

  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    self.view.endEditing(true)
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   
    switch section {
    case 0:
      return 1
    case 1:
      return keyArray.count

    default: return 0
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if let cell = tableView.dequeueReusableCellWithIdentifier(cellID.commentCell) as? CommentCell
      where indexPath.section == 1 {
     
      let ip = indexPath.row
      
      if let username = usernameArray.ref(ip) {
        
        cell.configureCell(keyArray[ip], value: valueArray[ip], user: username)

      } else {
        cell.configureCell(keyArray[ip], value: valueArray[ip], user: "")
        
      }
      return cell
    }
    
    if let cellContent = tableView.dequeueReusableCellWithIdentifier(cellID.imageCell) as? CommentImageCell
      where indexPath.section == 0 {
      
      cellContent.configureCell(post, downloadedImage: postImage)
      
      return cellContent
      
    }
    
    return UITableViewCell()
    
  }
  
  
  //MARK: - TEXT VIEW AND KEYBOARD
  
  struct DescriptionText {
    static let defaultText = "Write a suggestion"
  }
  
  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    
    if textView.text != DescriptionText.defaultText || textView.text != "" {
      postButton.enabled = true
    }
    
    if textView.text == DescriptionText.defaultText && viewAppeared == true {
      commentTextView.text = ""
      commentTextView.textColor = .blackColor()
    }
    return true
  }
  
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  func keyboardNotification(notification: NSNotification) {
    
    if let userInfo = notification.userInfo where viewDismissing == false {
      
      let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
      let duration: NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
      let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
      let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
      let animationCurve: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
      
      if endFrame?.origin.y >= UIScreen.mainScreen().bounds.size.height {
        
        self.keyboardHeightLayoutConstraint?.constant = 0.0
        self.postButtonHeightLayoutConstraint?.constant = 0.0
        
      } else {
        
        self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
        self.postButtonHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0

      }
      
      UIView.animateWithDuration(duration,
                                 delay: NSTimeInterval(0),
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
    commentTextView.textColor = .lightGrayColor()
    commentTextView.layer.addBorder(.Top, color: customGrey, thickness: 1)
    postButton.layer.addBorder(.Top, color: customGrey, thickness: 1)

    bringCursorToStart()
  }
  
  func textViewDidBeginEditing(textView: UITextView) {//Not working, needs to move cursor
    
    if viewAppeared && commentTextView.text == DescriptionText.defaultText {
      
      commentTextView.text = ""
      commentTextView.textColor = .blackColor()
      postButton.enabled = false

    }
    
  }
  
  func bringCursorToStart() {
    let start = commentTextView.beginningOfDocument
    commentTextView.selectedTextRange = commentTextView.textRangeFromPosition(start, toPosition: start)
  }
  
  //MARK: - ALERTS
  
  func guestAlert() {
    
    let alert = UIAlertController(title: "Function unavailable", message: "You must be logged in to comment", preferredStyle: .Alert)
    
    alert.addAction(UIAlertAction(title: "Login", style: .Default, handler: { action in
    
    AppState.shared.currentState = .PresentLoginFromComments
      
    self.navigationController?.popViewControllerAnimated(false)
      
    }))
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))

    
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  func tapped() {
    self.view.endEditing(true)
  }
  
  
  //MARK: - MISC
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
}

private extension CALayer {
  
  func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
    
    let border = CALayer()
    
    switch edge {
    case UIRectEdge.Top:
      border.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), thickness)
        default: break
    }
    
    border.backgroundColor = color.CGColor;
    
    self.addSublayer(border)
  }
}
