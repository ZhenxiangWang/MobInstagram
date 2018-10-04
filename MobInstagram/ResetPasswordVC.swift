//
//  resetPasswordVC.swift
//  MobInstagram
//
//  Created by hha6027875 on 10/9/18.
//  Copyright © 2018 hha6027875. All rights reserved.
//

import UIKit
import Parse

class ResetPasswordVC: UIViewController {

    @IBOutlet var cancelBtn: UIButton!
    @IBOutlet var resetBtn: UIButton!
    @IBOutlet var emailTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
