//
//  PageContainer.swift
//  Wildlife
//
//  Created by Ben Sullivan on 17/06/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit

protocol NavigationControllerDelegate {
  
  func didSelectSegment(segment: Int)
}

protocol UpdateNavButtonsDelegate {
  func updateNavButtons()
}

class PageContainer: UIViewController, UpdateNavButtonsDelegate {
  
  @IBOutlet weak var createPostButton: UIButton!
  @IBOutlet weak var feedButton: UIButton!
  @IBOutlet weak var completeButton: UIButton!
  
  let highlighted = UIColor(colorLiteralRed: 223/255, green: 223/255, blue: 230/255, alpha: 1)
  let standard = UIColor(colorLiteralRed: 239/255, green: 239/255, blue: 244/255, alpha: 1)
  
  static var delegate: NavigationControllerDelegate? = nil
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
  func updateNavButtons() {
    
    switch AppState.shared.currentState {
      
    case .CreatingPost:
      updateColours(0)
      
    case .Feed:
      updateColours(1)

    case .TopTrumps:
      updateColours(2)
      
    default:
      print("default bro")
    }
    
  }
  
  override func viewDidLoad() {
    
    PagingVC.delegate = self
  }
  
  func updateColours(segment: Int) {

    switch segment {
      
    case 0:
      createPostButton.backgroundColor = highlighted
      feedButton.backgroundColor = standard
      completeButton.backgroundColor = standard

    case 1:
      createPostButton.backgroundColor = standard
      feedButton.backgroundColor = highlighted
      completeButton.backgroundColor = standard
      
    case 2:
      createPostButton.backgroundColor = standard
      feedButton.backgroundColor = standard
      completeButton.backgroundColor = highlighted
      
    default:
      print("default bro")
    }
  }

  func didSelectSegment(segment: Int) {
    
    PageContainer.delegate!.didSelectSegment(segment)
  }
  
  @IBAction func feedButton(sender: AnyObject) {
    didSelectSegment(1)
    updateColours(1)
  }
  
  @IBAction func createPostButton(sender: AnyObject) {
    didSelectSegment(0)
    updateColours(0)
  }
  
  @IBAction func completeButton(sender: AnyObject) {
    didSelectSegment(2)
    updateColours(2)

  }
  
  
}