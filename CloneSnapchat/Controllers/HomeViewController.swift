//
//  HomeViewController.swift
//  CloneSnapchat
//
//  Created by Ömer Faruk KÖSE on 14.12.2021.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let fireStore = Firestore.firestore()
    
    let refreshControl = UIRefreshControl()
    
    var bitmoImageArray = [UIImage(named: "bit1"),UIImage(named: "bit2")]
    
    var feedName = ""
    var snapIndex = 0
    var snapsenderForShowSnap = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self

        navigationItem.title = "Snapchat"
        
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Ayarlar",
                                                                                          style: UIBarButtonItem.Style.done,
                                                                                          target: self,
                                                                                          action: #selector(toSettings))
        
        navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "Profil",
                                                                                         style: UIBarButtonItem.Style.done,
                                                                                         target: self,
                                                                                         action: #selector(toProfile))
        
        // Refresh kod tanimlamalari
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
                                                                                        
        // current user info
        getUserInfoFromFirebase()
        
        // Do any additional setup after loading the view.
    }
    
    // aktif kullanicinin bilgilerini databaseden al
    func getUserInfoFromFirebase() {
        fireStore.collection("userInfo").whereField("email", isEqualTo: Auth.auth().currentUser!.email!).getDocuments { (snapshot,error) in
            if error != nil {
                self.MakeAlert(title: "Error", message: "Get Data From Firebase Error !")
            } else if !snapshot!.isEmpty && snapshot != nil {
                for document in snapshot!.documents {
                    UserModel.sharedInstance.username = document.get("username") as! String
                    UserModel.sharedInstance.email = document.get("email") as! String
                    UserModel.sharedInstance.score = document.get("score") as! Int
                }
                self.getSnapDocId(username: UserModel.sharedInstance.username)
            }
        }
    }
    
    // snapleri cekmek duzenlemek icin snapDocID al
    func getSnapDocId(username:String){
        self.fireStore.collection("snaps").whereField("username", isEqualTo: username).getDocuments { (snapshot, error) in
            if error != nil {
                print(error?.localizedDescription ?? "Get snap document ID error !")
            } else if snapshot != nil {
                for doc in snapshot!.documents {
                    let docID = doc.documentID
                    UserModel.sharedInstance.snapsDocID = docID
                    self.getSnapData(documentId: docID)
                }
            }
        }
    }
    
    // snapshot listener anlik refresh yapmadan guncelleme
    func getSnapData(documentId:String) {
        fireStore.collection("snaps").document(documentId).addSnapshotListener { snapshot, error in
            if  error != nil {
                print(error?.localizedDescription ?? "Get snap data error !")
            } else if snapshot != nil {
                let snapList = snapshot?.get("snapList") as! [Any]
                self.clearAll()
                if !snapList.isEmpty { // arkadas ekli mi kontrol
                    self.tableView.backgroundView = UIImageView(image: UIImage(named: ""))
                    for i in 0...(snapList.count - 1){
                        let myArray = snapList[i] as! NSDictionary
                        let username = myArray["name"] as! String
                        let linkArray = myArray["links"] as! [String]
                        var snapModel = SnapModel()
                        snapModel.senderName = username
                        snapModel.snapLinkArray = linkArray
                        UserModel.sharedInstance.snaps.append(snapModel)
                    }
                    self.tableView.reloadData()
                } else {
                    self.tableView.backgroundView = UIImageView(image: UIImage(named: "tvbgn.png"))
                }
            }
        }
    }
    
    @objc func refresh(_ sender: AnyObject) {
        clearAll()
        do{
            try getSnapData(documentId: UserModel.sharedInstance.snapsDocID)
            // getUserInfo atlaniyor direk snapler cekiliyor
            refreshControl.endRefreshing()
        }catch{
            print("Table View Refresh Error !")
        }
    }
    
    func clearAll(){
        UserModel.sharedInstance.snaps.removeAll()
    }
    
    // SEGUES
    @objc func toSettings(){
        performSegue(withIdentifier: "toSettingsVC", sender: nil)
    }
    
    @objc func toProfile(){
        performSegue(withIdentifier: "toProfileVC", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toShowSnapVC" {
            let destination = segue.destination as! ShowSnapViewController
            destination.nameIndex = snapIndex
            destination.snapSenderName = snapsenderForShowSnap
        }
        
        if segue.identifier == "toSendSnapVC" {
            let destination = segue.destination as! SendSnapViewController
            destination.feedSelectedName = feedName
        }
    }
     
    
}


// UITABLEVİEW
extension HomeViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserModel.sharedInstance.snaps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SnapCell", for: indexPath) as! SnapCell
        cell.selectionStyle = .none
        if !UserModel.sharedInstance.snaps.isEmpty {
            if !UserModel.sharedInstance.snaps[indexPath.row].snapLinkArray.isEmpty {
                cell.senderNameLabel.text = UserModel.sharedInstance.snaps[indexPath.row].senderName
                cell.openImage.image = UIImage(named: "redsuare")
                cell.descriptionLabel.text = "Görüntülemek için dokunun"
            } else {
                cell.senderNameLabel.text = UserModel.sharedInstance.snaps[indexPath.row].senderName
                cell.openImage.image = UIImage(named: "redsquareoff")
                cell.descriptionLabel.text = "Snap göndermek için dokunun"
            }
            cell.bitmoImage.image = bitmoImageArray[Int.random(in: 0..<2)]
        }
        return cell
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if UserModel.sharedInstance.snaps[indexPath.row].snapLinkArray.isEmpty {
            var selectedName = UserModel.sharedInstance.snaps[indexPath.row].senderName
            snapsenderForShowSnap = UserModel.sharedInstance.snaps[indexPath.row].senderName
            snapIndex = indexPath.row
            feedName = UserModel.sharedInstance.snaps[indexPath.row].senderName
            performSegue(withIdentifier: "toSendSnapVC", sender: nil)
        } else {
            snapsenderForShowSnap = UserModel.sharedInstance.snaps[indexPath.row].senderName
            snapIndex = indexPath.row
            performSegue(withIdentifier: "toShowSnapVC", sender: nil)
        }
    }
}
