//
//  mainPageVC.swift
//  PMA CV
//
//  Created by Ben Sullivan on 27/04/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit

class PagingVC: UIPageViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
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
  
  override func viewDidLayoutSubviews() {
    
    var scrollView: UIScrollView?
    var pageControl: UIPageControl?
    
    if (self.view.subviews.count == 2) {
      for view in self.view.subviews {
        if (view.isKindOfClass(UIScrollView)) {
          scrollView = view as? UIScrollView
        } else if (view.isKindOfClass(UIPageControl)) {
          pageControl = view as? UIPageControl
        }
      }
    }
    
    if let scrollView = scrollView {
      if let pageControl = pageControl {
        scrollView.frame = self.view.bounds
        self.view.bringSubviewToFront(pageControl)
      }
    }
    
    super.viewDidLayoutSubviews()
  }
  
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
}
