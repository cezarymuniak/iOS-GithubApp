//
//  DetailsView.swift
//  GithubApp
//
//  Created by macOS on 25/07/2020.
//  Copyright © 2020 CezaryMuniak. All rights reserved.
//

import Foundation
import UIKit
import OAuth2
import Alamofire

class DetailsView: UIViewController {
    
    var loader: OAuth2DataLoader?
    var oauth2: OAuth2CodeGrant?
    var sessionManager: SessionManager?
    
    
    @IBOutlet weak var detailView: UIView!
    
    @IBOutlet weak var userAvatarImageView: UIImageView!
    
    @IBOutlet weak var repoNameLabel: UILabel!
    
    @IBOutlet weak var createdAtLabel: UILabel!
    
    @IBOutlet weak var pushedAtLabel: UILabel!
    
    @IBOutlet weak var updatedAtLabel: UILabel!
    
    @IBOutlet weak var languageLabel: UILabel!
    
    @IBAction func buttonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Bundle.main.loadNibNamed(R.nib.detailsView.name, owner: self, options: nil)
        
        detailView.layer.cornerRadius = 10
    }
    
}
