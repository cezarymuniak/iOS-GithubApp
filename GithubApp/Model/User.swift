//
//  User.swift
//  GithubApp
//
//  Created by macOS on 23/07/2020.
//  Copyright © 2020 CezaryMuniak. All rights reserved.
//
import Foundation

import ObjectMapper

class User: Mappable {
    var owner: String?
    var name: String?
    var avatar: String?
    var createdAt: String?
    var pushedAt: String?
    var updatedAt: String?
    var watchers: String?
    var language: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        owner <- map["owner.login"]
        name <- map["name"]
        avatar <- map["owner.avatar_url"]
        createdAt <- map["created_at"]
        pushedAt <- map["created_at"]
        updatedAt <- map["created_at"]
        watchers <- map["watchers_count"]
         language <- map["language"]
    }
}
