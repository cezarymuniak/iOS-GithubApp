//
//  AppDelegate.swift
//  GithubApp
//
//  Created by macOS on 22/07/2020.
//  Copyright © 2020 CezaryMuniak. All rights reserved.
//

import UIKit
import OAuth2

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var navigationController: UINavigationController?
    
    var oauth2 = OAuth2CodeGrant(settings: [
        "client_id": "da644ee7034b699c9239",                         // yes, this client-id and secret will work!
        "client_secret": "0844a3df9b40407c2e0f05a2ee90fe3a5b9292dd",
        "authorize_uri": "https://github.com/login/oauth/authorize",
        "token_uri": "https://github.com/login/oauth/access_token",
        "scope": "notifications user repo:status",
        "redirect_uris": ["githubapp://oauth/callback"],            // app has registered this scheme
        "secret_in_body": true,                                      // GitHub does not accept client secret in the Authorization header
        "verbose": true,
        ] as OAuth2JSON)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        oauth2.forgetTokens()
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if  "githubapp" == url.scheme
        {
            if let vc = window?.rootViewController as? LoginViewController {
                vc.oauth2.handleRedirectURL(url)
                return true
            }
        }
        return false
    }
}


