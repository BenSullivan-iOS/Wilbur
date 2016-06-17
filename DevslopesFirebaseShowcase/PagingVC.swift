//
//  mainPageVC.swift
//  PMA CV
//
//  Created by Ben Sullivan on 27/04/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit

class PagingVC: UIPageViewController, UIPageViewControllerDelegate, NavigationControllerDelegate {
  
  var currentPage = Int()
  
  static var delegate: UpdateNavButtonsDelegate? = nil

  func didSelectSegment(segment: Int) {
    
    switch segment {
      
    case 0:
      
      if AppState.shared.currentState != .CreatingPost {
        self.setViewControllers([orderedViewControllers[segment]], direction: .Reverse, animated: true, completion: nil)
      }

    case 1:

      if AppState.shared.currentState == .CreatingPost {
        self.setViewControllers([orderedViewControllers[segment]], direction: .Forward, animated: true, completion: nil)
      }
      
      if AppState.shared.currentState == .TopTrumps {
        self.setViewControllers([orderedViewControllers[segment]], direction: .Reverse, animated: true, completion: nil)
      }
      
    case 2:
      
      if AppState.shared.currentState != .TopTrumps {
        self.setViewControllers([orderedViewControllers[segment]], direction: .Forward, animated: true, completion: nil)
      }
    default:
      print("boo")
    }
    
  }
  
  func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    
    guard completed == true else { return }
    
    PagingVC.delegate!.updateNavButtons()

  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    PageContainer.delegate = self
    
    delegate = self
    dataSource = self
    
    let secondVC: UIViewController? = orderedViewControllers[1]
    
    if let setFirstViewController = secondVC {
      setViewControllers([setFirstViewController],
                         direction: .Forward,
                         animated: true,
                         completion: nil)
    }
  }
  
  private lazy var orderedViewControllers: [UIViewController] = {
    
    return [self.newViewController("Record"),
            self.newViewController("Feed"),
            self.newViewController("TopTrumpsVC")]
  }()
  
  private func newViewController(title: String) -> UIViewController {
    return UIStoryboard(name: "Main", bundle: nil) .instantiateViewControllerWithIdentifier(title)
  }
  
//  override func viewDidLayoutSubviews() {
//    super.viewDidLayoutSubviews()
//    
//    var scrollView: UIScrollView?
//    var pageControl: UIPageControl?
//    
//    if self.view.subviews.count == 2 {
//      
//      for view in self.view.subviews {
//        
//        if view.isKindOfClass(UIScrollView) {
//          let button = UIButton(type: UIButtonType.InfoDark)
//          
//          button.frame = CGRectMake(50, 50, 100, 100)
//          view.addSubview(button)
//
//          scrollView = view as? UIScrollView
//          
//        } else if view.isKindOfClass(UIPageControl) {
//          
//          pageControl = view as? UIPageControl
//          pageControl!.pageIndicatorTintColor = .whiteColor()
//          pageControl?.alpha = 0
//          pageControl!.currentPageIndicatorTintColor = .redColor()
//          
//          let button = UIButton(type: .InfoDark)
//          
//          button.frame = (pageControl?.frame)!
//          pageControl!.addSubview(button)
//        }
//      }
//    }
  
//    if let scrollView = scrollView {
//      if let pageControl = pageControl {
//        scrollView.frame = self.view.bounds
//        self.view.bringSubviewToFront(pageControl)
//      }
//    }
//    
////    super.viewDidLayoutSubviews()
//  }
  
}


extension PagingVC: UIPageViewControllerDataSource {
  
  func pageViewController(pageViewController: UIPageViewController,
                          viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
    
    guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
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
  
  func pageViewController(pageViewController: UIPageViewController,
                          viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
    
    guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
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
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
//  func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
//    return orderedViewControllers.count
//  }
//  
//  func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
//    guard let firstViewController = viewControllers?.first,
//      firstViewControllerIndex = orderedViewControllers.indexOf(firstViewController) else {
//        return 0
//    }
//    
//    return firstViewControllerIndex
//  }
}


