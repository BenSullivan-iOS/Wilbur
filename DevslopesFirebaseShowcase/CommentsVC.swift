//
//  CommentsVCViewController.swift
//  Wildlife
//
//  Created by Ben Sullivan on 02/07/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit
import AVFoundation

class CommentsVC: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var commentTextView: UITextView!
  @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?
  
  
  private var viewAppeared = false
  private var viewDismissing = false
  
  var post: Post? = nil
  var postImage: UIImage? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.estimatedRowHeight = 40
    tableView.rowHeight = UITableViewAutomaticDimension
    
    configureTextView()
    
    if let post = post {
      
      print(post.postDescription)
      if let postImage = postImage {
//        selectedImage.image = postImage
      }
    }
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardNotification(_:)),name: UIKeyboardWillChangeFrameNotification, object: nil)
    
  }
  
  override func viewDidAppear(animated: Bool) {
    viewDismissing = false
    viewAppeared = true
  }
  
  override func viewWillDisappear(animated: Bool) {
    viewDismissing = true
  }
  
  
  
  //MARK: - TABLE VIEW
  
  private let testText = ["Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor", "Nam liber te conscient to factor tum poen legum odioque civiuda.Nam liber te conscient to factor tum poen legum odioque civiuda.Nam liber te conscient to factor tum poen legum odioque civiuda.Nam liber te conscient to factor tum poen legum odioque civiuda.","Nam liber te conscient to factor tum poen legum odioque civiuda.Nam liber te conscient to factor tum poen legum odioque civiuda.","Nam liber te conscient to factor tum poen legum odioque civiuda."
  ]
  
  private struct cellID {
    static let commentCell = "commentCell"
    static let imageCell = "commentCellImage"
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
    if indexPath.section == 0 {
    
      let height = AVMakeRectWithAspectRatioInsideRect((postImage!.size), self.view.frame).height
    
      return height
      
    } else {
      
      return UITableViewAutomaticDimension
    }

  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   
    switch section {
    case 0:
      return 1
    case 1:
      return testText.count
    default: return 0
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if let cell = tableView.dequeueReusableCellWithIdentifier(cellID.commentCell) as? CommentCell
      where indexPath.section == 1 {
    
      cell.commentText.text = testText[indexPath.row]
      return cell
      
    }
    
    if let cellImage = tableView.dequeueReusableCellWithIdentifier(cellID.imageCell) as? CommentImageCell
      where indexPath.section == 0 {
      
      cellImage.postImage.image = postImage
      
      return cellImage
    }
    
    return UITableViewCell()
    
  }
  
  
  
  //MARK: - TEXT VIEW AND KEYBOARD
  
  struct DescriptionText {
    static let defaultText = "Write a suggestion"
  }
  
  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    
    if textView.text == DescriptionText.defaultText && viewAppeared == true {
      commentTextView.text = ""
      commentTextView.textColor = .darkGrayColor()
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
        
      } else {
        
        self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
      }
      
      UIView.animateWithDuration(duration,
                                 delay: NSTimeInterval(0),
                                 options: animationCurve,
                                 animations: { self.view.layoutIfNeeded() },
                                 completion: nil)
    }
    
  }
  
  func configureTextView() {
    
    commentTextView.becomeFirstResponder()
    commentTextView.delegate = self
    commentTextView.text = DescriptionText.defaultText
    commentTextView.textColor = .lightGrayColor()
    
    let start = commentTextView.beginningOfDocument
    commentTextView.selectedTextRange = commentTextView.textRangeFromPosition(start, toPosition: start)
    
  }
  
  
  //MARK: - MISC
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    self.view.endEditing(true)
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
}
