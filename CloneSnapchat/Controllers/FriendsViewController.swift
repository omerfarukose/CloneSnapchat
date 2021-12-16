//
//  FriendsViewController.swift
//  CloneSnapchat
//
//  Created by Ömer Faruk KÖSE on 14.12.2021.
//

import UIKit
import Firebase

class FriendsViewController: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    
    let firestore = Firestore.firestore()
    let refreshControl = UIRefreshControl()
    
    
    
    var choosenFriendName = ""
    var choosenFriendScore = ""
    var choosenIndex = 0
    
    var friendList = [FriendModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.title = "Arkadaslar"
        
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
    
        getFriendsListFromDatabase()
    }
    
    @objc func toProfile(){
        navigationController?.popViewController(animated: true)
    }
    
    func getFriendsListFromDatabase(){
        self.clearAll()
        firestore.collection("userInfo").whereField("username", isEqualTo: UserModel.sharedInstance.username).getDocuments { (snapshot, error) in
            if error != nil {
                print(error?.localizedDescription ?? "Get Friends Info Error !")
            } else if snapshot != nil && !snapshot!.isEmpty {
                for doc in snapshot!.documents{
                    var friendList = doc.get("friends") as! [String]
                    self.getFriendsInfoFromDatabase(friendList: friendList)
                }
            }
        }
    }
    
    func getFriendsInfoFromDatabase(friendList:[String]){
        for friend in friendList {
            firestore.collection("userInfo").whereField("username", isEqualTo: friend).getDocuments { (snapshot, error) in
                if error != nil {
                    print(error?.localizedDescription ?? "Get friend info error !")
                } else if snapshot != nil && !snapshot!.isEmpty {
                    for doc in snapshot!.documents {
                        var friend = FriendModel()
                        friend.username = doc.get("username") as! String
                        friend.snapScore = doc.get("score") as! Int
                        UserModel.sharedInstance.friendsArray.append(friend)
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @objc func refresh(_ sender: AnyObject) {
        do{
            try getFriendsListFromDatabase()
            refreshControl.endRefreshing()
        }catch{
            print("Table View Refresh Error !")
        }
    }
    
    func clearAll(){
        UserModel.sharedInstance.friendsArray.removeAll()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFriendDetailsVC" {
            let destination = segue.destination as? FriendDetailsViewController
            destination?.selectedScore = choosenFriendScore
            destination?.selectedName = choosenFriendName
        }
    }
    
}

// UITableView

extension FriendsViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserModel.sharedInstance.friendsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell") as! FriendCell
        cell.usernameLabel.text = UserModel.sharedInstance.friendsArray[indexPath.row].username
        return cell
    }
}

extension FriendsViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var friend = UserModel.sharedInstance.friendsArray[indexPath.row]
        choosenFriendName = friend.username
        choosenFriendScore = String(friend.snapScore)
        performSegue(withIdentifier: "toFriendDetailsVC", sender: nil)
    }
}
