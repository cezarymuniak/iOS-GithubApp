//
//  UserCollectionViewCell.swift
//  GithubApp
//
//  Created by macOS on 19/07/2020.
//  Copyright © 2020 CezaryMuniak. All rights reserved.
//

import UIKit
import DisplaySwitcher
import OAuth2
import Alamofire

private let avatarListLayoutSize: CGFloat  = 80

class UserCollectionViewCell: UICollectionViewCell {
    fileprivate var alamofireManager: SessionManager?
    
    @IBOutlet fileprivate weak var backgroundCellView: UIView!
    
    @IBOutlet  weak var avatarImageView: UIImageView!
    
    @IBOutlet  weak var nameLabel: UILabel!
    
    @IBOutlet weak var nameGridLabel: UILabel!
    
    
    @IBOutlet weak var createdLabel: UILabel!
    
    @IBOutlet fileprivate weak var avatarImageViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var avatarImageViewHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet var nameLabelLeadingConstraint: NSLayoutConstraint! {
        didSet {
            initialLabelsLeadingConstraintValue = nameLabelLeadingConstraint.constant
        }
    }
    
    @IBOutlet weak var createdDateLabelLeadingConstraint: NSLayoutConstraint!
    
    fileprivate var avatarGridLayoutSize: CGFloat = 0.0
    fileprivate var initialLabelsLeadingConstraintValue: CGFloat = 0.0
    
    func bind(_ user: User) {
        nameLabel.text = user.name
      //  createdLabel.text = user.createdAt
        nameGridLabel.text = nameLabel.text
    }
    
    func setupGridLayoutConstraints(_ transitionProgress: CGFloat, cellWidth: CGFloat) {
        avatarImageViewHeightConstraint.constant = ceil(
            (cellWidth - avatarListLayoutSize) * transitionProgress + avatarListLayoutSize
        )
        avatarImageViewWidthConstraint.constant = ceil(avatarImageViewHeightConstraint.constant)
        nameLabelLeadingConstraint.constant = -avatarImageViewWidthConstraint.constant * transitionProgress + initialLabelsLeadingConstraintValue
        
        backgroundCellView.alpha = transitionProgress <= 0.5 ? 1 - transitionProgress : transitionProgress
        nameLabel.alpha = 1 - transitionProgress
    }
    
    
    func setupListLayoutConstraints(_ transitionProgress: CGFloat, cellWidth: CGFloat) {
        avatarImageViewHeightConstraint.constant = ceil(
            avatarGridLayoutSize - (avatarGridLayoutSize - avatarListLayoutSize) * transitionProgress
        )
        avatarImageViewWidthConstraint.constant = avatarImageViewHeightConstraint.constant
        nameLabelLeadingConstraint.constant = avatarImageViewWidthConstraint.constant * transitionProgress + (initialLabelsLeadingConstraintValue - avatarImageViewHeightConstraint.constant)
        backgroundCellView.alpha = transitionProgress <= 0.5 ? 1 - transitionProgress : transitionProgress
        nameLabel.alpha = transitionProgress
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? DisplaySwitchLayoutAttributes {
            if attributes.transitionProgress > 0 {
                if attributes.layoutState == .grid {
                    setupGridLayoutConstraints(attributes.transitionProgress,
                                               cellWidth: attributes.nextLayoutCellFrame.width)
                    avatarGridLayoutSize = attributes.nextLayoutCellFrame.width
                } else {
                    setupListLayoutConstraints(attributes.transitionProgress,
                                               cellWidth: attributes.nextLayoutCellFrame.width)
                }
            }
        }
    }
}
