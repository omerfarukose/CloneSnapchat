//
//  File.swift
//  CloneSnapchat
//
//  Created by Ömer Faruk KÖSE on 14.12.2021.
//

import Foundation
import UIKit

class UserModel {
    
    static let sharedInstance = UserModel()
    
    var email = ""
    var username = ""
    var score = 0
    var active = true
    var bitmoImage = UIImage(named: "bit2")
    var friendsArray = [FriendModel]()
    var inviteFriends = [String]()
    var snaps = [SnapModel]()
    var snapsDocID = ""
    
    private init(){}
    
}

