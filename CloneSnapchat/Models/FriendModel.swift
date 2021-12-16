//
//  FriendModel.swift
//  CloneSnapchat
//
//  Created by Ömer Faruk KÖSE on 14.12.2021.
//

import Foundation
import UIKit

struct FriendModel {
    
    static let sharedInstance = FriendModel()
    
    var username = ""
    var snapScore = 0
    var bitmoImage = UIImage(named: "bit1")
    
  init(){}
    
}

