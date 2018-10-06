//
//  resetPasswordVC.swift
//  MobInstagram
//
//  Created by hha6027875 on 10/9/18.
//  Copyright © 2018 hha6027875. All rights reserved.
//  This file provide password reset function

import UIKit
import Parse

class ResetPasswordVC: UIViewController {

    @IBOutlet var cancelBtn: UIButton!
    @IBOutlet var resetBtn: UIButton!
    @IBOutlet var emailTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(ResetPasswordVC.hideKeyboardTap(_:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
    }

    
    //hide keyboard if tapped
    @objc func hideKeyboardTap(_ recoginizer:UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    //click reset button
    @IBAction func resetBtn_click(_ sender: Any) {
        
        self.view.endEditing(true)
        
        if emailTxt.text!.isEmpty {
            let alert = UIAlertController(title: "Email field", message: "is empty", preferredStyle: UIAlertController.Style.alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
        
        PFUser.requestPasswordResetForEmail(inBackground: emailTxt.text!){(success:Bool, error:Error?) -> Void in
            if success {
                let alert = UIAlertController(title: "Emial for reseting password", message: "has been sent to text email", preferredStyle: UIAlertController.Style.alert)
                let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(UIAlertAction) -> Void in
                    self.dismiss(animated: true, completion: nil)
                })
                alert.addAction(ok)
                self.present(alert, animated: true, completion : nil)
            } else {
                print (error?.localizedDescription)
            }
        }
    }
    
    
    @IBAction func cancelBtn_click(_ sender: Any) {
        
        // hide keyboard when press cancel
        self.view.endEditing(true)
        
        self.dismiss(animated: true, completion: nil)
    }
}
