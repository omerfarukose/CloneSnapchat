//
//  FriendsDetailsViewController.swift
//  CloneSnapchat
//
//  Created by Ömer Faruk KÖSE on 14.12.2021.
//

import UIKit
import Firebase

class FriendDetailsViewController: UIViewController {

    @IBOutlet weak var bitmoImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    let fireStore = Firestore.firestore()
    
    var selectedName = ""
    var selectedScore = ""
    
    var friendNameArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scoreLabel.text = selectedScore
        usernameLabel.text = selectedName
        bitmoImage.image = UIImage(named: "bit1")
        
        var friendArray = UserModel.sharedInstance.friendsArray
        
        for friend in friendArray {
            friendNameArray.append(friend.username)
        }
        
    }

    @IBAction func deleteButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title : "", message: "\(self.selectedName) kişisi silinecek ", preferredStyle: UIAlertController.Style.alert)
        let ok = UIAlertAction(title: "Sil", style: UIAlertAction.Style.default) { alert in
            self.deleteFriend()
        }
        let cancel = UIAlertAction(title: "İptal", style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(cancel)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func deleteFriend(){
        deleteFromUserModel()
        deleteFromUserInfo(from: UserModel.sharedInstance.username,who: selectedName)
        deleteFromUserInfo(from: selectedName,who: UserModel.sharedInstance.username)
        deleteFromSnapList(from: UserModel.sharedInstance.username, who: selectedName)
        deleteFromSnapList(from: selectedName, who: UserModel.sharedInstance.username)
        navigationController?.popViewController(animated: true)
    }
    
    func deleteFromUserModel(){
        var userModelFriendArray = UserModel.sharedInstance.friendsArray
        for i in 0...(userModelFriendArray.count) {
            if userModelFriendArray[i].username == selectedName {
                userModelFriendArray.remove(at: i)
                break
            }
        }
        UserModel.sharedInstance.friendsArray = userModelFriendArray
    }
    
    func deleteFromUserInfo(from:String,who:String){
        var userInfoFriendArray = [String]()
        var userInfoDocID = ""
        
        fireStore.collection("userInfo").whereField("username", isEqualTo: from).getDocuments { (snapshot,error) in
            if error != nil {
                print(error?.localizedDescription ?? "Delete from user info error !")
            } else {
                if snapshot?.isEmpty == false && snapshot != nil {
                    for doc in snapshot!.documents {
                        userInfoDocID = doc.documentID
                        userInfoFriendArray = doc.get("friends") as! [String]
                        
                    }
                    
                    for i in 0...(userInfoFriendArray.count){
                        if userInfoFriendArray[i] == who {
                            userInfoFriendArray.remove(at: i)
                            self.fireStore.collection("userInfo").document(userInfoDocID).setData(["friends":userInfoFriendArray], merge: true)
                            break
                        }
                    }
                }
            }
        }
    }
    
    func deleteFromSnapList(from:String,who:String){
        var snapList = [Any]()
        var snapsDocID = ""
        fireStore.collection("snaps").whereField("username", isEqualTo: from).getDocuments { (snapshot, error) in
            if error != nil {
                print(error?.localizedDescription ?? "Delete from snap list error !")
            } else if snapshot?.isEmpty == false && snapshot != nil {
                for doc in snapshot!.documents {
                    snapsDocID = doc.documentID
                    snapList = doc.get("snapList") as! [Any]
                }
                
                for i in 0...(snapList.count){
                    var snap = snapList[i] as! NSDictionary
                    var snapName = snap["name"] as! String
                    if snapName == who {
                        snapList.remove(at: i)
                        self.fireStore.collection("snaps").document(snapsDocID).setData(["snapList":snapList], merge: true)
                        break
                    }
                }
            }
        }
    }
    

    }
