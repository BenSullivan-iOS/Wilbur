//
//  Protocols.swift
//  Wildlife
//
//  Created by Ben Sullivan on 19/07/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import Foundation

protocol AudioPlayerDelegate {
  func audioRecorded()
}

protocol NavigationBarDelegate: class {
  func didSelectSegment(segment: Int)
}

protocol UpdateNavButtonsDelegate: class {
  func updateNavButtons()
}

protocol PostButtonPressedDelegate: class {
  func postButtonPressed()
}

protocol PostCellDelegate: class {
  func showAlert(post: Post)
  func reloadTable()
  func customCellCommentButtonPressed()
}

protocol MyPostsCellDelegate: class {
  func showComments(post: Post, image: UIImage)
  func reloadTable()
  func showDeleteAlert(post: Post)
}

protocol CreatePostDelegate: class {
  func displayAlert(title: String, message: String, state: AlertState)
  func postSuccessful()
  func postError()
}