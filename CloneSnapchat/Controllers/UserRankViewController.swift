//
//  UserRankViewController.swift
//  CloneSnapchat
//
//  Created by Ömer Faruk KÖSE on 16.12.2021.
//

import UIKit
import Firebase

class UserRankViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let firestore = Firestore.firestore()
    let refreshControl = UIRefreshControl()
    
    
    
    var userArray = [String]()
    var scoreArray = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        // refresh islemi kod tanimlamasi
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        getFriendList()
    }
    
    func getFriendList(){
        var username = UserModel.sharedInstance.username
        firestore.collection("userInfo").whereField("username", isEqualTo: username).getDocuments { (snapshot, error) in
            if error != nil {
                print(error?.localizedDescription ?? "Get friend list error !")
            } else if snapshot != nil && !snapshot!.isEmpty {
                for doc in snapshot!.documents {
                    self.userArray = doc.get("friends") as! [String]
                    self.userArray.append(username)
                    self.getUsersScore(users: self.userArray)
                }
            }
        }
    }
    
    func getUsersScore(users:[String]){
        for user in users {
            firestore.collection("userInfo").whereField("username", isEqualTo: user).getDocuments { (snapshot, error) in
                if error != nil {
                    print(error?.localizedDescription ?? "error !")
                } else if snapshot != nil && !snapshot!.isEmpty {
                    for doc in snapshot!.documents {
                        var score = doc.get("score") as! Int
                        self.scoreArray.append(score)
                        if self.scoreArray.count == users.count {
                            self.sortUsers()
                        }
                    }
                }
            }
        }
    }
    
    func sortUsers(){
        scoreArray = scoreArray.reversed()
        for i in 1..<scoreArray.count {
            for j in 0..<(scoreArray.count - 1){
                if scoreArray[j]<scoreArray[j+1]{
                    self.scoreArray.swapAt(j, j+1)
                    self.userArray.swapAt(j, j+1)
                }
            }
        }
        self.tableView.reloadData()
    }
    
    func clearAll(){
        userArray.removeAll()
        scoreArray.removeAll()
    }
    
    @objc func refresh(_ sender: AnyObject) {
        clearAll()
        do{
            try getFriendList()
            self.tableView.reloadData()
            refreshControl.endRefreshing()
        }catch{
            print("Table View Refresh Error !")
        }
    }
    
}

extension UserRankViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scoreArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RankCell") as! RankCell
        cell.selectionStyle = .none
        cell.userIndexLabel.text = String(indexPath.row + 1)
        cell.usernameLabel.text = userArray[indexPath.row]
        cell.userScoreLabel.text = String(scoreArray[indexPath.row])
        return cell
    }
}

