//
//  SignupViewController.swift
//  CloneSnapchat
//
//  Created by Ömer Faruk KÖSE on 14.12.2021.
//

// signup işleminden sonra home screene yönlendir

import UIKit
import Firebase

class SignupViewController: UIViewController {
    
    @IBOutlet weak var closeImage: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let fireStore = Firestore.firestore()
    
    // Sistemde kayitli username-email listesi
    var usernameArray = [String]()
    var emailArray = [String]()
    
    var isEmailEmpty = true
    var isUsernameEmpty = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUserInfoFromDatabase()

        // Signup screen kapatma butonu
        closeImage.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeTab))
        closeImage.addGestureRecognizer(gestureRecognizer)
        
        // Ekrana tiklandiğinda field edit bitirme - klavye gizleme
        let viewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(viewGestureRecognizer)
        
        // email&username kontrol fonksiyonlari cagrisi  - for editing end textfield disina tiklaninca calisir
        emailTextField.addTarget(self, action: #selector(emailCheck), for: .editingDidEnd)
        usernameTextField.addTarget(self, action: #selector(usernameCheck), for: .editingDidEnd)
    }
    
    @objc func closeTab(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    // Username-Email zaten kayitli mi kontrol etmek icin sistemden, kayıtlı kullanıcıları cek, listelere ekle
    func getUserInfoFromDatabase(){
        fireStore.collection("userInfo").getDocuments { (snapshot , error) in
            if error != nil {
                self.MakeAlert(title: "Error", message: error?.localizedDescription ?? "Get user info error !")
            } else {
                for document in snapshot!.documents {
                    if let email = document.get("email") as? String {
                        self.emailArray.append(email)
                    }
                    if let username = document.get("username") as? String {
                        self.usernameArray.append(username)
                    }
                }
            }
        }
    }
    
    //  email, kayitli mail listesinde var mi kontrolu
    @objc func emailCheck(){
        if let email = emailTextField.text {
            if isValidEmail(emailTextField.text!){ //regexe uyuyorsa maillerle kontrol et
                for emailInArray in emailArray {
                    if email == emailInArray {
                        emailTextField.layer.borderWidth = 2
                        emailTextField.layer.masksToBounds = true
                        emailTextField.layer.cornerRadius = 6
                        emailTextField.layer.borderColor = UIColor.red.cgColor
                        isEmailEmpty = false
                        break
                    } else {
                        emailTextField.layer.borderWidth = 0
                        isEmailEmpty = true
                    }
                }
            } else if emailTextField.text != "" {  // regexe uymuyorsa direk kırmızı olsun
                emailTextField.layer.borderWidth = 2
                emailTextField.layer.masksToBounds = true
                emailTextField.layer.cornerRadius = 6
                emailTextField.layer.borderColor = UIColor.red.cgColor
                isEmailEmpty = false
            }
        }
    }
    
    // email kullanilabilir mi kontrolu
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // username, kayitli username listesinde var mi kontrolu
    @objc func usernameCheck(){
        if let username = usernameTextField.text {
            for usernameInArray in usernameArray {
                if username == usernameInArray {
                    usernameTextField.layer.borderWidth = 2
                    usernameTextField.layer.masksToBounds = true
                    usernameTextField.layer.cornerRadius = 6
                    usernameTextField.layer.borderColor = UIColor.red.cgColor
                    isUsernameEmpty = false
                    break
                } else {
                    usernameTextField.layer.borderWidth = 0
                    isUsernameEmpty = true
                }
            }
        }
    }
    
    @IBAction func signupButtonClicked(_ sender: Any) {
        if usernameTextField.text != "" && emailTextField.text != "" && passwordTextField.text != "" {
            if (isUsernameEmpty){
                if(isValidEmail(emailTextField.text!)){
                    if(isEmailEmpty){
                        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { authResult, error in
                            if error != nil {
                                self.MakeAlert(title: "Error !", message: error?.localizedDescription ?? "Create user error !")
                            } else {
                                self.fireStore.collection("userInfo").addDocument(data: ["email": self.emailTextField.text! , "username": self.usernameTextField.text! , "score" : 0 , "friends": [] , "invites" : [] ]) { error in
                                    if error != nil {
                                        self.MakeAlert(title: "Error", message: error?.localizedDescription ?? "Sign up firestore add document error !")
                                    } else {
                                        self.MakeAlert(title: "", message: "Kullanıcı oluşturuldu")
                                    }
                                }
                                self.fireStore.collection("snaps").addDocument(data: ["snapList":[],"username":self.usernameTextField.text!])
                            }
                        }
                    } else {
                        MakeAlert(title: "", message: "E-mail kullanımda")
                    }
                } else {
                    MakeAlert(title: "", message: "Geçersiz e-mail")
                }
            } else {
                MakeAlert(title: "", message: "Kullanıcı adı zaten alınmış")
            }
        } else {
            MakeAlert(title: "", message: "Lütfen tüm alanları doldurun")
        }
    }
    
}

