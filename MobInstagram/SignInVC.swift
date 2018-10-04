//
//  signInVC.swift
//  MobInstagram
//
//  Created by hha6027875 on 10/9/18.
//  Copyright © 2018 hha6027875. All rights reserved.
//

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

        //declare hide keyboard tap
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(SignInVC.hideKeyboardTap(_:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //hide keyboard if tapped
    @objc func hideKeyboardTap(_ recoginizer:UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    

    @IBAction func signInClicked(_ sender: Any) {
        print ("Sign In pressed")
        
        //hide keyboard
        self.view.endEditing(true)
        
        if usernameTxt.text!.isEmpty || passwordTxt.text!.isEmpty{
            let alert = UIAlertController(title: "PLEASE", message:"fill in field", preferredStyle: UIAlertController.Style.alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
        
        //login func
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
