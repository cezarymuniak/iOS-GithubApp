
//  TopBar.swift
//  GithubApp
//
//  Created by macOS on 21/07/2020.
//  Copyright © 2020 CezaryMuniak. All rights reserved.
//

import Foundation
import UIKit

class TopBar: UIView {
    var isClicked = false
    
    @IBOutlet weak var topBarView: UIView!

    override func awakeFromNib() {
        Bundle.main.loadNibNamed(R.nib.topBar.name, owner: self, options: nil)
        addSubview(topBarView)
    }
}
