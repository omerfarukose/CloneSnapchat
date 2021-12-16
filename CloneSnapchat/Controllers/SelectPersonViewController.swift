//
//  SelectPersonViewController.swift
//  CloneSnapchat
//
//  Created by Ömer Faruk KÖSE on 15.12.2021.
//

import UIKit
import Firebase

class SelectPersonViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let fireStore = Firestore.firestore()
    
    var friendList = [String]()
    var feedSelectedName = ""
    var sendImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        getFriendList()
    }
    
    // ekrandan cikis yapilirsa secim kutulari sifirlansin diye
    override func viewWillAppear(_ animated: Bool) {
        SelectedModel.sharedInstance.selectedFriends.removeAll()
        if feedSelectedName != "" && SelectedModel.sharedInstance.selectedFriends.isEmpty {
            SelectedModel.sharedInstance.selectedFriends.append(feedSelectedName)
        }
    }
    
    func getFriendList(){
        fireStore.collection("userInfo").whereField("username", isEqualTo: UserModel.sharedInstance.username).getDocuments { (snapshot, error) in
            if error != nil {
                print(error?.localizedDescription ?? "getFriendList")
            } else if snapshot?.isEmpty == false && snapshot != nil {
                for doc in snapshot!.documents {
                    self.friendList = doc.get("friends") as! [String]
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func sendButtonClicked(_ sender: Any) {
        let storage = Storage.storage()
        let storageReference = storage.reference()
        let mediaFolder = storageReference.child("media")
        
        if let data = sendImage.jpegData(compressionQuality: 0.5){
            
            // storage klasörüne kaydetmek icin unique id
            let uuid = UUID().uuidString
            let imageReference = mediaFolder.child("\(uuid).jpg")
            
            imageReference.putData(data, metadata: nil) { (metadata, error) in
                if error != nil {
                    print(error?.localizedDescription ?? "imageReference.putData error")
                } else {
                    // kaydettikten sonra image download url yi snapliste kaydediyor
                    imageReference.downloadURL { (url, error) in
                        if error != nil {
                            print(error?.localizedDescription ?? "imageReference.downloadURL")
                        } else {
                            let imageUrl = url!.absoluteString
                            self.addImageUrlToSnapList(imageUrl: imageUrl)
                        }
                    }
                }
            }
        }
    }
    
    // image url i secili arkadaslarin snapList lerine kaydediyor
    func addImageUrlToSnapList(imageUrl:String){
        for friend in SelectedModel.sharedInstance.selectedFriends {
            self.fireStore.collection("snaps").whereField("username", isEqualTo: friend).getDocuments { (snapshot,error) in
                if error != nil {
                    print(error?.localizedDescription ?? "add image url to snaplist error !")
                } else if snapshot?.isEmpty == false && snapshot != nil {
                    for doc in snapshot!.documents {
                        let docID =  doc.documentID
                        var sender = UserModel.sharedInstance.username
                        var awaitSnapArray: [Any] = doc.get("snapList") as! [Any]
                        for i in 0...(awaitSnapArray.count - 1){
                            var myArray = awaitSnapArray[i] as! NSMutableDictionary
                            if(myArray["name"] as! String==sender){
                                var linkArray = myArray["links"] as! [String]
                                linkArray.append(imageUrl)
                                myArray["links"]=linkArray
                                awaitSnapArray[i]=myArray
                                var snapsDictionary = ["snapList":awaitSnapArray,"username":friend] as [String : Any]
                                
                                self.fireStore.collection("snaps").document(docID).setData(snapsDictionary, merge: true)
                                self.increaseScore(username: friend)
                                self.increaseScore(username: UserModel.sharedInstance.username)
                            }
                        }
                    }
                }
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func increaseScore(username:String){
        fireStore.collection("userInfo").whereField("username", isEqualTo: username).getDocuments { (snapshot, error) in
            if error != nil {
                print(error?.localizedDescription ?? "Increase Score Error!")
            } else if snapshot?.isEmpty == false && snapshot != nil {
                for doc in snapshot!.documents {
                    let docID = doc.documentID
                    var score = doc.get("score") as! Int
                    score += 10
                    let scoreDictionary = ["score":score]
                    print("Kullanici \(username) skor artti \(score) oldu")
                    self.fireStore.collection("userInfo").document(docID).setData(scoreDictionary, merge: true)
                }
            }
        }
    }
}

extension SelectPersonViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell", for: indexPath) as! PersonCell
        cell.selectionStyle = .none
        cell.usernameLabel.text = friendList[indexPath.row]
        cell.selectedName = friendList[indexPath.row]
        
        var nameList = SelectedModel.sharedInstance.selectedFriends
        for name in nameList {
            if name == UserModel.sharedInstance.snaps[indexPath.row].senderName {
                cell.circleImage.image = UIImage(named: "okloko")
                cell.personSelected = true
            }
        }
        return cell
    }
    
}
