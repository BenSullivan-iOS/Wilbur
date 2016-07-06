//
//  ProfileTableVC.swift
// Wilbur
//
//  Created by Ben Sullivan on 28/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import UIKit

class ProfileTable: UITableViewController {
  
  var delegate: ProfileTableDelegate? = nil
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    switch indexPath.row {
      
    case 0 where indexPath.section == 0:
      delegate?.rowSelected(SelectedRow.MyPosts)
      
    case 1 where indexPath.section == 0:
      delegate?.rowSelected(SelectedRow.PoppedPosts)
      
    case 0 where indexPath.section == 1:
      delegate?.rowSelected(SelectedRow.Feedback)
      
    case 1 where indexPath.section == 1:
      delegate?.rowSelected(SelectedRow.FeatureRequest)
      
    default: return
      
    }
    
  }
  
}

