//
//  SendSnapViewController.swift
//  CloneSnapchat
//
//  Created by Ömer Faruk KÖSE on 15.12.2021.
//

import UIKit

class SendSnapViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    // image secilmeden gonder tusuna basilirsa kontrol degsikeni
    var imageSelected = false
    // feed view san kullanci ustune tiklanarak gelirse , tiklanan kisinin username'i tutacak degisken
    var feedSelectedName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // resim secme
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageGestureRecognizer)
        
    }
    
    // ekran gecislerinde secilen resmi sifirlamak icin
    override func viewWillAppear(_ animated: Bool) {
        imageSelected = false
        imageView.image = UIImage(named: "new.png")
    }
    
    // arkadas ekli mi kontrolu, friend list cekmedigimiz icin snaplist kontrolu
    @objc func selectImage(){
        if UserModel.sharedInstance.snaps.isEmpty {
            self.MakeAlert(title: "", message: "Lütfen önce arkadaş ekleyin")
        } else {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            present(picker, animated: true, completion: nil)
        }
    }
    // picker secim fonksiyonu
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as! UIImage
        imageSelected = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendButtonClicked(_ sender: Any) {
        if imageSelected {
            performSegue(withIdentifier: "toSelectPersonVC", sender: nil)
        } else {
            self.MakeAlert(title: "", message: "Lütfen göndermek için fotoğraf seçin")
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSelectPersonVC" {
            let destination = segue.destination as! SelectPersonViewController
            destination.sendImage = imageView.image!
            // feedden arkadasa tiklanarak geldiyse , tiklana ismi aktarmak icin
            if feedSelectedName != "" {
                destination.feedSelectedName = feedSelectedName
            }
        }
    }
}
