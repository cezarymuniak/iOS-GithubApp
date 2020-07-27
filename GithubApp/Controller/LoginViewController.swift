//
//  LoginViewController.swift
//  GithubApp
//
//  Created by macOS on 21/07/2020.
//  Copyright © 2020 CezaryMuniak. All rights reserved.
//

import Foundation
import OAuth2
import UIKit
import Alamofire
import AlamofireObjectMapper


class LoginViewController: UIViewController {
    
    @IBOutlet weak var signInButton: UIButton!
    
    fileprivate var alamofireManager: SessionManager?
    
    func showMainViewController() {
        let storyboard = UIStoryboard(name: R.storyboard.loginViewController.name , bundle:nil)
        let mainVC =  storyboard.instantiateViewController(identifier: R.storyboard.mainViewController.name) as MainViewController
        mainVC.loader = self.loader
               mainVC.oauth2 = self.oauth2
        self.present(mainVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        signInButton.layer.cornerRadius = 20
    }
    
    var loader: OAuth2DataLoader?
    var oauth2 = OAuth2CodeGrant(settings: [
        "client_id": "da644ee7034b699c9239",                         // yes, this client-id and secret will work!
        "client_secret": "0844a3df9b40407c2e0f05a2ee90fe3a5b9292dd",
        "authorize_uri": "https://github.com/login/oauth/authorize",
        "token_uri": "https://github.com/login/oauth/access_token",
        "scope": "notifications user repo",
        "redirect_uris": ["githubapp://oauth/callback"],            // app has registered this scheme
        "secret_in_body": true,                                      // GitHub does not accept client secret in the Authorization header
        "verbose": true,
        ] as OAuth2JSON)
    
    @IBAction func clickSignIn(_ sender: UIButton?) {

        if oauth2.isAuthorizing {
            oauth2.abortAuthorization()
            return
        }
 
            sender?.setTitle("Logging...", for: UIControl.State.normal)
                let sessionManager = SessionManager()
                let retrier = OAuth2RetryHandler(oauth2: oauth2)
                sessionManager.adapter = retrier
                sessionManager.retrier = retrier
                alamofireManager = sessionManager
                
                sessionManager.request("https://api.github.com/user").validate().responseJSON { response in
                    if response.result.isSuccess  {
                        self.showMainViewController()
                    }
        }

    }

    func didCancelOrFail(_ error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                print("Authorization went wrong: \(error)")
            }
            print ( "cancelOrFail" )
        }
    }
}
