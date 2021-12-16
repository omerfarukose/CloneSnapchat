//
//  InvitesViewController.swift
//  CloneSnapchat
//
//  Created by Ömer Faruk KÖSE on 14.12.2021.
//

import UIKit
import Firebase

class InvitesViewController: UIViewController {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    
    var invitesArray = [String]()
    let fireStore = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        navigationItem.title = "Arkadas Ekle"
        
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
    
        getInvitesArrayFromDatabase()
    }
    
    func refreshTable(){
        getInvitesArrayFromDatabase()
    }
    
    func getInvitesArrayFromDatabase(){
        fireStore.collection("userInfo").whereField("username", isEqualTo: UserModel.sharedInstance.username).getDocuments { (snapshot, error) in
            if error != nil {
                print(error?.localizedDescription ?? "Get userInfo Error !")
            } else if snapshot?.isEmpty == false && snapshot != nil {
                for doc in snapshot!.documents {
                    self.invitesArray = doc.get("invites") as! [String]
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // Kabul edilen kisinin arkadas listesine , kabul eden kisiyi ekleme
    @objc func acceptButtonClicked(_ sender: UIButton) {
        var inviteName = invitesArray[sender.tag]
        var currentUser = UserModel.sharedInstance.username
        addFriendList(from: inviteName, who: currentUser)
        addFriendList(from: currentUser, who: inviteName)
        addSnapList(from: currentUser, who: inviteName)
        addSnapList(from: inviteName, who: currentUser)
        removeInviteFromDatabase(name: inviteName)
    }
    
    func addFriendList(from:String,who:String){
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
                        userInfoFriendArray.append(who)
                        self.fireStore.collection("userInfo").document(userInfoDocID).setData(["friends":userInfoFriendArray], merge: true)
                    }
                }
            }
        }
    }
    
    func addSnapList(from:String,who:String){
        var snapList = [Any]()
        var snapsDocID = ""
        fireStore.collection("snaps").whereField("username", isEqualTo: from).getDocuments { (snapshot, error) in
            if error != nil {
                print(error?.localizedDescription ?? "Delete from snap list error !")
            } else if snapshot?.isEmpty == false && snapshot != nil {
                for doc in snapshot!.documents {
                    snapsDocID = doc.documentID
                    snapList = doc.get("snapList") as! [Any]
                    var snapDictionary = ["links":[],"name":who] as [String : Any]
                    snapList.append(snapDictionary)
                    self.fireStore.collection("snaps").document(snapsDocID).setData(["snapList":snapList], merge: true)
                }
            }
        }
    }
    
    //Arkadaslik istegini reddetme
    @objc func notAcceptButtonClicked(_ sender: UIButton) {
        var inviteName = invitesArray[sender.tag]
        removeInviteFromDatabase(name:inviteName)
    }

    // invites listesinden ismi silmek icin
    func removeInviteFromDatabase(name: String){
        var userInfoInvitesArray = [String]()
        var userInfoDocID = ""
        
        fireStore.collection("userInfo").whereField("username", isEqualTo: UserModel.sharedInstance.username).getDocuments { (snapshot,error) in
            if error != nil {
                print(error?.localizedDescription ?? "Get userInfo Error !")
            } else {
                for doc in snapshot!.documents {
                    userInfoDocID = doc.documentID
                    userInfoInvitesArray = doc.get("invites") as! [String]
                }
                for i in 0...(userInfoInvitesArray.count){
                    if userInfoInvitesArray[i] == name {
                        userInfoInvitesArray.remove(at: i)
                        self.fireStore.collection("userInfo").document(userInfoDocID).setData(["invites":userInfoInvitesArray], merge: true)
                        self.refreshTable()
                        break
                    }
                }
            }
        }
    }
   
    //User aratarak ekleme
    @IBAction func searchAddButtonClicked(_ sender: Any) {
        var username = searchTextField.text
        
        var friendArray = UserModel.sharedInstance.friendsArray
            
        var friendsName = [String]()
        
        for friend in friendArray {
            friendsName.append(friend.username)
        }
        
        if friendsName.contains(username!){
            self.MakeAlert(title: "", message: "Kullanıcı arkadaş listesinde zaten ekli")
        } else if username == UserModel.sharedInstance.username{
            self.MakeAlert(title: "", message: "Kendi kullanıcı adınızı girdiniz")
        } else if username != "" && username != nil {
            fireStore.collection("userInfo").whereField("username", isEqualTo: username).getDocuments { (snapshot,error) in
                if error != nil {
                    print(error?.localizedDescription ?? "Get userInfo Error !")
                } else if snapshot?.isEmpty == false && snapshot != nil {
                    for doc in snapshot!.documents {
                        var docID = doc.documentID
                        var invitesArray = doc.get("invites") as! [String]
                        invitesArray.append(UserModel.sharedInstance.username)
                        var invitesDictionary = ["invites":invitesArray]
                        self.fireStore.collection("userInfo").document(docID).setData(invitesDictionary, merge: true)
                    }
                    self.MakeAlert(title: "", message: "İstek gönderildi")
                } else {
                    self.MakeAlert(title: "", message: "Kullanıcı bulunamadı")
                }
            }
        }
    }
    
    }
    
extension InvitesViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invitesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "inviteCell" , for: indexPath) as! InviteCell
        cell.selectionStyle = .none
        cell.friendNameLabel.text = invitesArray[indexPath.row]
        cell.acceptButton.tag = indexPath.row
        cell.acceptButton.addTarget(self, action: #selector(acceptButtonClicked(_:)), for: UIControl.Event.touchUpInside)
        cell.ignoreButton.tag = indexPath.row
        cell.ignoreButton.addTarget(self, action: #selector(notAcceptButtonClicked(_:)), for: UIControl.Event.touchUpInside)
        return cell
    }
}
