//
//  SettingsViewController.swift
//  CloneSnapchat
//
//  Created by Ömer Faruk KÖSE on 15.12.2021.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func logoutButtonClicked(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            UserModel.sharedInstance.email = ""
            UserModel.sharedInstance.username = ""
            UserModel.sharedInstance.score = 0
            UserModel.sharedInstance.inviteFriends.removeAll()
            UserModel.sharedInstance.friendsArray.removeAll()
            UserModel.sharedInstance.snaps.removeAll()
            SelectedModel.sharedInstance.selectedFriends.removeAll()
            performSegue(withIdentifier: "toLoginVC", sender: nil)
        }catch{
            MakeAlert(title: "Error !", message: "Çıkış yapamadık hacı !")
        }
    }
    

}
