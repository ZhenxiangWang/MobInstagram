//
//  uploadVC.swift
//  MobInstagram
//
//  Created by hha6027875 on 19/9/18.
//  Copyright © 2018 hha6027875. All rights reserved.
//

import UIKit
import Parse

private let reuseIdentifier = "Cell"

class uploadVC: UIViewController {

    @IBOutlet var titleTxt: UITextView!
    @IBOutlet var picImg: UIImageView!
    @IBOutlet var publishBtn: UIButton!
    
    var img: UIImage = UIImage(named: "pbg.jpg")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        publishBtn.isEnabled = false
        publishBtn.backgroundColor = .lightGray
        
        picImg.image = img
        
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.hideKeyboardTap))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        

    }
    
    @objc func hideKeyboardTap(){
        self.view.endEditing(true)
    }
    
    @IBAction func publishBtn_click(_ sender: Any) {
        //dissmis keyboard
        self.view.endEditing(true)
        
        //send data to server
        let object = PFObject(className: "posts")
        object["username"] = PFUser.current()?.username
        object["ava"] = PFUser.current()!.value(forKey: "ava") as! PFFile
        object["uuid"] = "\(PFUser.current()!.username!)\(UUID().uuidString)"
        
        if titleTxt.text.isEmpty{
            object["title"] = ""
        } else {
            object["title"] = titleTxt.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        
        let picData = picImg.image!.jpegData(compressionQuality: 0.5)
        let imageFile = PFFile(name: "post.jpg", data: picData!)
        object["pic"] = imageFile
        
        object.saveInBackground { (success, error) in
            if error == nil {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploaded"), object: nil)
                self.tabBarController!.selectedIndex = 0
                
                self.viewDidLoad()
            } else {
                print (error!.localizedDescription)
            }
        }
        
        let newsObj = PFObject(className: "news")
        newsObj["by"] = PFUser.current()?.username
        newsObj["ava"] = PFUser.current()?.object(forKey: "ava") as! PFFile
        newsObj["to"] = ""
        newsObj["owner"] = ""
        newsObj["uuid"] = object["uuid"]
        newsObj["type"] = "post"
        newsObj["checked"] = "no"
        newsObj.saveEventually()
    }

}
