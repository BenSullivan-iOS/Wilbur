//
//  ProfileVC.swift
//  Fart Club
//
//  Created by Ben Sullivan on 17/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit

protocol ProfileTableDelegate {
  
  func rowSelected(rowTitle: SelectedRow)
}

enum SelectedRow {
  
  case MyPosts
  case PoppedPosts
  case Feedback
  case FeatureRequest
}

class ProfileVC: UIViewController, ProfileTableDelegate {
  
  @IBOutlet weak var profileImage: UIImageView!
  
  @IBAction func popOffButtonPressed(sender: UIButton) {
    
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func rowSelected(rowTitle: SelectedRow) {
    
    switch rowTitle {
    case .MyPosts:
      print("my posts")
    self.navigationController?.pushViewController(TopTrumpsVC(), animated: true) //FIXME: Why isn't this pusing as a nav controller?
    case .PoppedPosts:
      print("popped posts")
    case .Feedback:
      print("feedback")
    case .FeatureRequest:
      print("feature request")
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "embeddedTable" {
      print("embedded segue")
      
      let profileTable = segue.destinationViewController as? ProfileTable
      
      profileTable!.delegate = self
      
    }
  }
  
  override func viewDidLoad() {
    
    profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
    profileImage.clipsToBounds = true
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
}