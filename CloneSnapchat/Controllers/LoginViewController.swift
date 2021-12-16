//
//  LoginViewController.swift
//  CloneSnapchat
//
//  Created by Ömer Faruk KÖSE on 13.12.2021.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let firestore = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let viewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(viewGestureRecognizer)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            // e-mail regex uyuyorsa e-mail ile giris secenegi
            if isValidEmail(emailTextField.text!) {
                Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { authResult, error in
                    if error != nil {
                        self.MakeAlert(title: "Giriş Hatası", message: error?.localizedDescription ?? "Login Error!")
                    } else {
                        self.performSegue(withIdentifier: "toHomeVC", sender: nil)
                    }
                }
            // regex uymuyorsa username ara
            // username'e ait email var mi kontrolu
            } else {
                let username = emailTextField.text!
                firestore.collection("userInfo").whereField("username", isEqualTo: username).getDocuments { (querySnapshot ,err) in
                    if let err = err {
                        self.MakeAlert(title: "Error !", message: err.localizedDescription )
                    } else if !querySnapshot!.isEmpty && querySnapshot != nil {
                        for document in querySnapshot!.documents {
                            if let email = document.get("email") as? String {
                                Auth.auth().signIn(withEmail: email, password: self.passwordTextField.text!) { authResult, error in
                                    if error != nil {
                                        self.MakeAlert(title: "Login Error !", message: error?.localizedDescription ?? "Login Error!")
                                    } else {
                                        self.performSegue(withIdentifier: "toHomeVC", sender: nil)
                                    }
                                }
                            }
                        }
                    } else {
                        self.MakeAlert(title: "Kullanıcı Bulunamadı", message: "Geçersiz kullanıcı adı")
                    }
                }
            }
        } else {
            self.MakeAlert(title: "", message: " Lütfen Kullanıcı Adı & Sifre Girin")
        }
    }
    
    @IBAction func signupButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "toSignupVC", sender: nil)
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[0-9A-Za-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
