//
//  uploadVC.swift
//  MobInstagram
//
//  Created by Wenbin Chen on 19/9/18.
//  Copyright © 2018 Wenbin Chen. All rights reserved.
//  this file contain the main function for upload post view controller
//  receive the edited from imageEditVC view controller

import UIKit
import Parse

class uploadVC: UIViewController {

    @IBOutlet var titleTxt: UITextView!
    @IBOutlet var picImg: UIImageView!
    @IBOutlet var publishBtn: UIButton!
    
    var img: UIImage = UIImage(named: "pbg.jpg")!
    var ciImage : CIImage = CIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //publishBtn.isEnabled = false
        publishBtn.backgroundColor = .lightGray
        
        picImg.image = img
        
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.hideKeyboardTap))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        

    }
    //hidd key board
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
            return
        } else {
            object["title"] = titleTxt.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        
        var picData = picImg.image!.jpegData(compressionQuality: 0.5)
        if picData == nil {
            let ciContext = CIContext()
            picData = ciContext.jpegRepresentation(of: ciImage, colorSpace: ciContext.workingColorSpace!, options: [:])
        }
        let imageFile = PFFile(name: "post.jpg", data: picData!)
        object["pic"] = imageFile
        
        object.saveInBackground { (success, error) in
            if error == nil {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploaded"), object: nil)
                self.picImg.image = UIImage(named: "pbg.jpg")
                self.titleTxt.text = nil
                self.tabBarController!.selectedIndex = 0
                
                self.viewDidLoad()
            } else {
                print (error!.localizedDescription)
            }
        }
        //save this information as an activity
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
