//
//  signInVC.swift
//  MobInstagram
//
//  Created by wenbinc on 10/9/18.
//  Copyright © 2018 hha6027875. All rights reserved.
//  This file provide Sign In fucntion

import UIKit
import Parse

class SignInVC: UIViewController {

    @IBOutlet var signUpBtn: UIButton!
    @IBOutlet var signInBtn: UIButton!
    @IBOutlet var forgorBtn: UIButton!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet var usernameTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //declare hide keyboard tap, when tapping a blank area hide keyboard
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(SignInVC.hideKeyboardTap(_:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
    }
    
    //hide keyboard if tapped
    @objc func hideKeyboardTap(_ recoginizer:UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    @IBAction func signInClicked(_ sender: Any) {
        print ("Sign In pressed")
        
        //hide keyboard
        self.view.endEditing(true)
        
        //alert if username or password is nil
        if usernameTxt.text!.isEmpty || passwordTxt.text!.isEmpty{
            let alert = UIAlertController(title: "PLEASE", message:"fill in field", preferredStyle: UIAlertController.Style.alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
        
        //login and store the logged user as default user, so that we don't need to login again
        PFUser.logInWithUsername(inBackground: usernameTxt.text!, password: passwordTxt.text!){(user:PFUser?, error:Error?) -> Void in
            if error == nil{
                UserDefaults.standard.set(user!.username, forKey: "username")
                UserDefaults.standard.synchronize()
                
                let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
            } else {
                let alert = UIAlertController(title: "PLEASE", message: error!.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)            }
        }
    }

}
