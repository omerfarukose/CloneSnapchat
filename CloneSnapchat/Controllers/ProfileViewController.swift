//
//  ProfileViewController.swift
//  CloneSnapchat
//
//  Created by Ömer Faruk KÖSE on 14.12.2021.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var bitmoImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Profil"
        usernameLabel.text = UserModel.sharedInstance.username
        scoreLabel.text = String(UserModel.sharedInstance.score)
    }

    @IBAction func friendsButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "toFriendsVC", sender: nil)
    }
    @IBAction func invitesButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "toInvitesVC", sender: nil)
    }
    
}
