//
//  MainViewController.swift
//  GithubApp
//
//  Created by macOS on 21/07/2020.
//  Copyright © 2020 CezaryMuniak. All rights reserved.
//

import Foundation
import UIKit
import OAuth2
import Alamofire
import AlamofireObjectMapper
import DisplaySwitcher
import SDWebImage

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate
{
    
    var sessionManager: SessionManager?
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let listLayoutStaticCellHeight: CGFloat = 80
    private let gridLayoutStaticCellHeight: CGFloat = 165
    private var layoutState: LayoutState = .list
    
    fileprivate lazy var listLayout = DisplaySwitchLayout(
        staticCellHeight: listLayoutStaticCellHeight,
        nextLayoutStaticCellHeight: gridLayoutStaticCellHeight,
        layoutState: .list
    )
    
    fileprivate lazy var gridLayout = DisplaySwitchLayout(
        staticCellHeight: gridLayoutStaticCellHeight,
        nextLayoutStaticCellHeight: listLayoutStaticCellHeight,
        layoutState: .grid
    )
    
    fileprivate var alamofireManager: SessionManager?
    fileprivate var isTransitionAvailable = true
    var userData = [User]()
    var loader: OAuth2DataLoader?
    
    var oauth2: OAuth2CodeGrant?

    
    let loginVC = LoginViewController()

    
    @IBOutlet weak var topBar: TopBar!
    @IBOutlet weak var rotationButton: SwitchLayoutButton!
    @IBOutlet weak var searchBar: UISearchBar!

    private let animationDuration: TimeInterval = 0.3

    @IBAction func someButtonClicked(_ sender: AnyObject) {
        if !isTransitionAvailable {
            return
        }
        let transitionManager: TransitionManager
        if layoutState == .list {
            layoutState = .grid
            transitionManager = TransitionManager(
                duration: animationDuration,
                collectionView: collectionView!,
                destinationLayout: gridLayout,
                layoutState: layoutState
            )
        } else {
            layoutState = .list
            transitionManager = TransitionManager(
                duration: animationDuration,
                collectionView: collectionView!,
                destinationLayout: listLayout,
                layoutState: layoutState
            )
        }
        transitionManager.startInteractiveTransition()
        rotationButton.isSelected = layoutState == .list
        rotationButton.animationDuration = animationDuration
        
    }
    let collectionViewCell = UserCollectionViewCell()
    
    fileprivate var tap: UITapGestureRecognizer!
    
   override func viewDidLoad() {
        super.viewDidLoad()

        tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
              searchBar.delegate = self

        collectionView.collectionViewLayout = listLayout
        
        self.collectionView.register(UINib(nibName: R.nib.userCollectionViewCell.name, bundle: nil ),
                                     forCellWithReuseIdentifier: R.reuseIdentifier.userCollectionViewCell.identifier )
collectData()
   self.collectionView.reloadData()
    }

  func collectData() {

             let sessionManager = SessionManager()
           if sessionManager != nil {
               let retrier = OAuth2RetryHandler(oauth2: oauth2!)
               sessionManager.adapter = retrier
               sessionManager.retrier = retrier
           }
           
           self.sessionManager = sessionManager

           sessionManager.request("https://api.github.com/user").validate().responseJSON { response in
                  print(response)
           }
           
           sessionManager.request("https://api.github.com/user/repos").validate().responseArray { (response: DataResponse<[User]>) in
            let reposResponse = response.result.value
                if let repoResponse = reposResponse {
             
                    for response in repoResponse {
                        self.userData = repoResponse
                                print( repoResponse)
                    }
                }

            self.collectionView.reloadData()
           }

   }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: R.reuseIdentifier.userCollectionViewCell,
            for: indexPath
            ) as! UserCollectionViewCell
        
        let userCell = self.userData[indexPath.row]

        cell.createdLabel.text = self.format(date: String(describing:userCell.createdAt!))
        cell.nameLabel.text = userCell.name
        cell.avatarImageView.sd_setImage(with: URL(string: userCell.avatar!), placeholderImage: R.image.logo())
        
        if layoutState == .grid {
            cell.setupGridLayoutConstraints(1, cellWidth: cell.frame.width)
        } else {
            cell.setupListLayoutConstraints(1, cellWidth: cell.frame.width)
        }
            cell.bind(self.userData[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

       return self.userData.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        transitionLayoutForOldLayout fromLayout: UICollectionViewLayout,
                        newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
        
        let customTransitionLayout = TransitionLayout(currentLayout: fromLayout, nextLayout: toLayout)
        
        return customTransitionLayout
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dialog = DetailsView()
        dialog.viewDidLoad()
        dialog.oauth2 = self.oauth2
        dialog.loader = self.loader
        dialog.sessionManager = self.sessionManager
        let userCatchedData = self.userData

        dialog.createdAtLabel.text = "Created At: \(self.format(date: String(describing: userCatchedData[indexPath.row].createdAt!)))"
        dialog.pushedAtLabel.text = "Pushed At : \(self.format(date: String(describing: userCatchedData[indexPath.row].pushedAt!)))"
        dialog.updatedAtLabel.text = "Updated At : \(self.format(date: String(describing: userCatchedData[indexPath.row].updatedAt!)))"
        dialog.userAvatarImageView.sd_setImage(with: URL(string: userCatchedData[indexPath.row].avatar!), placeholderImage: R.image.logo())
        dialog.repoNameLabel.text = "Repo Name : \(String(describing: userCatchedData[indexPath.row].name!))"

        if  userCatchedData[indexPath.row].language != nil {
            dialog.languageLabel.text = "Language: \(String(describing: userCatchedData[indexPath.row].language!))"
        } else {
            dialog.languageLabel.text = "Language: data not found"
        }
        
        dialog.modalPresentationStyle = .custom
        self.present(dialog, animated: true, completion: nil)
    }
    
    func format (date: String, from : String = "yyyy-MM-dd'T'HH:mm:ssZ", to : String = "dd-MM-yyyy HH:mm") -> String {
        let dateFormater = DateFormatter()
        dateFormater.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
        dateFormater.dateFormat = from
        
        let _date = dateFormater.date(from: date)
        dateFormater.timeZone = NSTimeZone.system
        dateFormater.dateFormat = to
        return dateFormater.string(from: _date!)
    }
    
    
    func didGetUserRepo()  {
        self.collectionView.reloadData()
    }

    }


extension MainViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty  {
         collectData()
} else {
            userData = userData.filter { return ($0.name?.contains(searchText))! }
        }
        collectionView.reloadData()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        view.addGestureRecognizer(tap)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        view.removeGestureRecognizer(tap)
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
    
}

