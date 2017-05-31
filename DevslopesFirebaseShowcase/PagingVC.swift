//
//  mainPageVC.swift
//  PMA CV
//
//  Created by Ben Sullivan on 27/04/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit

class PagingVC: UIPageViewController, UIPageViewControllerDelegate, NavigationBarDelegate {
  
  fileprivate var currentPage = Int()
  
  weak var navButtonsDelegate: UpdateNavButtonsDelegate? = nil
  
  var rootController: PageContainer? = nil
  
  
  //MARK: - VIEW CONTROLLER LIFECYCLE
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    delegate = self
    dataSource = self
    
    configureViewControllers()
  }
  
  
  
  //MARK: - NAVIGATION BAR DELEGATE
  //Scrolls to relevant VC when navigation bar is pressed
  
  func didSelectSegment(_ segment: Int) {
    
    switch segment {
      
    case 0:
      
      if AppState.shared.currentState != .creatingPost {
        self.setViewControllers([orderedViewControllers[segment]], direction: .reverse, animated: true, completion: nil)
      }
      
    case 1:
      
      if AppState.shared.currentState == .creatingPost {
        self.setViewControllers([orderedViewControllers[segment]], direction: .forward, animated: true, completion: nil)
      }
      
      if AppState.shared.currentState == .answered {
        self.setViewControllers([orderedViewControllers[segment]], direction: .reverse, animated: true, completion: nil)
      }
      
    case 2:
      
      if AppState.shared.currentState != .answered {
        self.setViewControllers([orderedViewControllers[segment]], direction: .forward, animated: true, completion: nil)
      }
      
    default:
      print("PagingVC, didSelectSegment default case")
    }
    
  }
  
  
  
  //MARK: - CONFIGURE PAGE VIEW CONTROLLER
  
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    
    guard completed == true else { return }
    
    navButtonsDelegate?.updateNavButtons()
  }
  
  
  func configureViewControllers() {
    
    let secondVC: UIViewController? = orderedViewControllers[1]
    
    if let setFirstViewController = secondVC {
      setViewControllers([setFirstViewController],
                         direction: .forward,
                         animated: true,
                         completion: nil)
    }
  }
  
  
  fileprivate lazy var orderedViewControllers: [UIViewController] = {
    
    return [self.newViewController("CreatePostVC"),
            self.newViewController("Feed"),
            self.newViewController("Answered")]
  }()
  
  
  fileprivate func newViewController(_ title: String) -> UIViewController {
    
    if title == "CreatePostVC" {
      
      let VC = UIStoryboard(name: "Main", bundle: nil) .instantiateViewController(withIdentifier: title) as! CreatePostVC
      
      rootController?.createPostDelegate = VC
      
      return VC

    }
    
    return UIStoryboard(name: "Main", bundle: nil) .instantiateViewController(withIdentifier: title)
  }
  
}



//MARK: - PAGE VIEW CONTROLLER DATA SOURCE

extension PagingVC: UIPageViewControllerDataSource {
  
  func pageViewController(_ pageViewController: UIPageViewController,
                          viewControllerBefore viewController: UIViewController) -> UIViewController? {
    
    guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
      return nil
    }
    
    let previousIndex = viewControllerIndex - 1
    
    guard previousIndex >= 0 else {
      return nil
    }
    
    guard orderedViewControllers.count > previousIndex else {
      return nil
    }
    
    return orderedViewControllers[previousIndex]
  }
  
  func pageViewController(_ pageViewController: UIPageViewController,
                          viewControllerAfter viewController: UIViewController) -> UIViewController? {
    
    guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
      return nil
    }
    
    let nextIndex = viewControllerIndex + 1
    let orderedViewControllersCount = orderedViewControllers.count
    
    guard orderedViewControllersCount != nextIndex else {
      return nil
    }
    
    guard orderedViewControllersCount > nextIndex else {
      return nil
    }
    
    return orderedViewControllers[nextIndex]
  }
  
  override var preferredStatusBarStyle : UIStatusBarStyle {
    return .lightContent
  }
  
}
