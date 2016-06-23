//
//  PageContainer.swift
//  Wildlife
//
//  Created by Ben Sullivan on 17/06/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit

protocol NavigationBarDelegate: class {
  func didSelectSegment(segment: Int)
}

protocol UpdateNavButtonsDelegate: class {
  func updateNavButtons()
}

protocol PostButtonPressedDelegate: class {
  func postButtonPressed()
}

class PageContainer: UIViewController, UpdateNavButtonsDelegate, NavigationBarDelegate {

  @IBOutlet weak var createPostButton: UIButton!
  @IBOutlet weak var feedButton: UIButton!
  @IBOutlet weak var completeButton: UIButton!
  @IBOutlet weak var postButton: UIButton!
  
  weak var createPostDelegate: PostButtonPressedDelegate? = nil
  weak var navigationBarDelegate: NavigationBarDelegate? = nil

  private struct Colours {
    static let highlighted = UIColor(colorLiteralRed: 223/255, green: 223/255, blue: 230/255, alpha: 1)
    static let standard = UIColor(colorLiteralRed: 239/255, green: 239/255, blue: 244/255, alpha: 1)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "embedSegue" {
      
      let dest = segue.destinationViewController as? PagingVC
      
      dest?.navButtonsDelegate = self
      dest?.rootController = self
      navigationBarDelegate = dest
    }
  }
  
  //MARK: - VIEW CONTROLLER LIFECYCLE
  
  override func viewDidLoad() {
//    PagingVC.delegate = self
    postButton.alpha = 0


    
  }
  
  
  
  //MARK: - DELEGATES
  
  func postButtonPressed() {
    
    createPostDelegate?.postButtonPressed()
  }
  
  //Notifies paging VC to scroll to selected segment
  func didSelectSegment(segment: Int) {
    
  navigationBarDelegate?.didSelectSegment(segment)
  }

  
  
  //MARK: - BUTTONS
  
  @IBAction func profileButtonPressed(sender: AnyObject) {
    performSegueWithIdentifier(Constants.sharedSegues.showProfile, sender: self)
  }
  
  @IBAction func postButtonPressed(sender: AnyObject) {
    postButtonPressed()
  
  }
  
  @IBAction func feedButton(sender: AnyObject) {
    didSelectSegment(1)
    updateColours(1)
    UIView.animateWithDuration(0.2, animations: {
      self.postButton.alpha = 0
    })

  }
  
  @IBAction func createPostButton(sender: AnyObject) {
    didSelectSegment(0)
    updateColours(0)
    UIView.animateWithDuration(0.5, animations: {
      self.postButton.alpha = 1
    })

  }
  
  @IBAction func completeButton(sender: AnyObject) {
    didSelectSegment(2)
    updateColours(2)
    UIView.animateWithDuration(0.2, animations: {
      self.postButton.alpha = 0
    })

  }
  
  
  
  //MARK: - STYLE NAV BUTTONS
  
  func updateNavButtons() {
    
    switch AppState.shared.currentState {
      
    case .CreatingPost:
      updateColours(0)
      UIView.animateWithDuration(0.5, animations: {
        self.postButton.alpha = 1
      })
    case .Feed:
      updateColours(1)
      UIView.animateWithDuration(0.2, animations: {
        self.postButton.alpha = 0
      })
    case .TopTrumps:
      updateColours(2)
      UIView.animateWithDuration(0.2, animations: {
        self.postButton.alpha = 0
      })
    default:
      print("default bro")
    }
  }
  
  func updateColours(segment: Int) {

    switch segment {
      
    case 0:
      createPostButton.backgroundColor = Colours.highlighted
      feedButton.backgroundColor = Colours.standard
      completeButton.backgroundColor = Colours.standard

    case 1:
      createPostButton.backgroundColor = Colours.standard
      feedButton.backgroundColor = Colours.highlighted
      completeButton.backgroundColor = Colours.standard
      
    case 2:
      createPostButton.backgroundColor = Colours.standard
      feedButton.backgroundColor = Colours.standard
      completeButton.backgroundColor = Colours.highlighted
      
    default:
      print("Page Container, update colours, default case")
    }
  }
  
  
  
  //MARK: - MISC FUNCTIONS
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
}