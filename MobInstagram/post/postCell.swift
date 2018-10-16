//
//  postCell.swift
//  MobInstagram
//
//  Created by hha6027875 on 19/9/18.
//  Copyright © 2018 hha6027875. All rights reserved.
//

import UIKit
import Parse

class postCell: UITableViewCell {

    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var likeLbl: UILabel!
    @IBOutlet var uuidLbl: UILabel!
    
    @IBOutlet var moreBtn: UIButton!
    @IBOutlet var commentBtn: UIButton!
    @IBOutlet var likeBtn: UIButton!
    
    @IBOutlet var picImg: UIImageView!
    @IBOutlet var dateLbl: UILabel!
    @IBOutlet var usernameBtn: UIButton!
    @IBOutlet var avaImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //like or unlike a post
    @IBAction func likeBtn_click(_ sender: Any) {
        let title = (sender as AnyObject).title(for: UIControl.State())
        if title == "like" {//like the post
            //save the like information
            let object = PFObject(className: "likes")
            object["by"] = PFUser.current()?.username
            object["to"] = uuidLbl.text
            object.saveInBackground { (success, error) in
                if success{
                    print("liked")
                    self.likeBtn.setTitle("unlike", for: UIControl.State())
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "liked"), object: nil)
                    
                    // send notification as unlike
                    if self.usernameBtn.titleLabel?.text != PFUser.current()?.username {
                        let newsObj = PFObject(className: "news")
                        newsObj["by"] = PFUser.current()?.username
                        newsObj["ava"] = PFUser.current()?.object(forKey: "ava") as! PFFile
                        newsObj["to"] = self.usernameBtn.titleLabel!.text
                        newsObj["owner"] = self.usernameBtn.titleLabel!.text
                        newsObj["uuid"] = self.uuidLbl.text
                        newsObj["type"] = "like"
                        newsObj["checked"] = "no"
                        newsObj.saveEventually()
                    }
                }
            }
        } else{//unlike the post
            //search the like information and delete it
            let query = PFQuery(className: "likes")
            query.whereKey("by", equalTo: PFUser.current()!.username!)
            query.whereKey("to", equalTo: uuidLbl.text!)
            query.findObjectsInBackground { (objects, error) in
                for object in objects!{
                    //delete
                    object.deleteInBackground(block: { (success, error) in
                        if success{
                            print("disliked")
                            self.likeBtn.setTitle("like", for: UIControl.State())
                            
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "liked"), object: nil)
                            
                            // delete like notification
                            let newsQuery = PFQuery(className: "news")
                            newsQuery.whereKey("by", equalTo: PFUser.current()!.username!)
                            newsQuery.whereKey("to", equalTo: self.usernameBtn.titleLabel!.text!)
                            newsQuery.whereKey("uuid", equalTo: self.uuidLbl.text!)
                            newsQuery.whereKey("type", equalTo: "like")
                            newsQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                                if error == nil {
                                    for object in objects! {
                                        object.deleteEventually()
                                    }
                                }
                            })
                        }
                    })
                }
            }
        }
    }
}
