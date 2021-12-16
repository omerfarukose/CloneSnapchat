//
//  ShowSnapViewController.swift
//  CloneSnapchat
//
//  Created by Ömer Faruk KÖSE on 15.12.2021.
//

import UIKit
import Firebase
import SDWebImage

class ShowSnapViewController: UIViewController {
    
    let fireStore = Firestore.firestore()
    
    var snapList: [SnapModel] = []
    var snapLinkArray = [String]()
    
    var snapCounter = 1

    var snapSenderName = ""
    var nameIndex =  0
    
    var timeCount = 0
    
    var nameList = UserModel.sharedInstance.snaps

    @IBOutlet weak var senderNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var snapImage: UIImageView!
    
    
    var timer = Timer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getSnapWithIndex()
        
        timeLabel.text = "10"
    
        // snap üzerine tiklama olayi , snap geçmek için
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(nextSnap))
        snapImage.isUserInteractionEnabled = true
        snapImage.addGestureRecognizer(gestureRecognizer)
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }
    
    @objc func fireTimer() {
        // sıfırı göstermemesi için if kontrol
        if timeCount != 10 {
            timeLabel.text = String(10-timeCount)
        }
        timeCount += 1
        if timeCount % 10 == 0 {
            nextSnap()
        }
        
    }
    
    // arttirmayi image değiştikten sonra yapıyoruz
    @objc func nextSnap(){
        let snapLenght = snapLinkArray.count
        if snapCounter < snapLenght {
            timeCount = 0
            self.snapImage.sd_setImage(with: URL(string: self.snapLinkArray[snapCounter]),placeholderImage: UIImage(named: ""))
            deleteSnapFromDatabase()
            snapCounter += 1
        } else {
            deleteSnapFromDatabase()
            timer.invalidate()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // indexle cekiyoruz cunku arkadas listesi ile ayni sirada snapList & tarama isleminden kurtariyor
    func getSnapWithIndex(){
        let username = UserModel.sharedInstance.username
        let name = nameList[nameIndex].senderName
        fireStore.collection("snaps").whereField("username", isEqualTo: username).getDocuments { (snapshot,error) in
            if error != nil {
                print(error?.localizedDescription ?? "Get snap with index error !")
            } else if !snapshot!.isEmpty && snapshot != nil {
                for doc in snapshot!.documents {
                    var snapList = doc.get("snapList") as! [Any]
                    let snapListIndex = snapList[self.nameIndex] as! NSDictionary
                    let indexLinks = snapListIndex["links"] as! [String]
                    if !indexLinks.isEmpty { //arkadas ekli ama snap atmamis olabilir
                        for i in 0...(snapList.count - 1){
                            let snap = snapList[i] as! NSDictionary
                            let snapName = snap["name"] as! String
                            if snapName == name{
                                let linkArray = snap["links"] as! [String]
                                self.snapLinkArray = linkArray
                                self.senderNameLabel.text = name
                                // ilk snap burada gosteriliyor
                                self.snapImage.sd_setImage(with: URL(string: linkArray[0]),placeholderImage: UIImage(named:""))
                            }
                        }
                    }
                }
            }
        }
    }
    
    // snap gecislerinde calisiyor, her zaman links array 0. indexi siliyor
    func deleteSnapFromDatabase(){
        print("Delete calisti")
        fireStore.collection("snaps").whereField("username", isEqualTo: UserModel.sharedInstance.username).getDocuments { (snapshot, error) in
            if error != nil {
                print(error?.localizedDescription ?? "Get snap with name error !")
            } else if snapshot?.isEmpty == false && snapshot != nil {
                print("Snaplist geldi")
                for doc in snapshot!.documents {
                    print("Fora girdi")
                    var snapList: [Any] = doc.get("snapList") as! [Any]
                    var snapDocID = doc.documentID
                    print("Cekilen snaplist : \(snapList)")
                    for i in 0..<snapList.count{
                        print("snaplist fora girdi")
                        var snap = snapList[i] as! NSDictionary
                        var snapName = snap["name"] as! String
                        var snapLinks = snap["links"] as! [String]
                        print("Snap sender name : \(self.snapSenderName)")
                            if snapName == self.snapSenderName{
                            snapLinks.remove(at: 0)
                                print("Snaplinks silindi yenisi : \(snapList)")
                            var newSnapDic = ["name":snapName,"links":snapLinks] as! [String:Any]
                            snapList[i] = newSnapDic
                                print("NewSnapDic : \(newSnapDic)")
                            self.fireStore.collection("snaps").document(snapDocID).setData(["snapList":snapList,"username":UserModel.sharedInstance.username])
                        }
                    }
                }
            }
        }
    }
    
}


