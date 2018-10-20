//
//  followersCell.swift
//  MobInstagram
//
//  Created by Wenbin Chen on 16/9/18.
//  Copyright © 2018 Wenbin Chen. All rights reserved.
//  this is the cell file for each user in followers view controller

import UIKit
import Parse

class followersCell: UITableViewCell {

    @IBOutlet var followBtn: UIButton!
    @IBOutlet var avaImg: UIImageView!
    @IBOutlet var usernameLbl: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    //click button to follow or unfollow a user
    @IBAction func followBtn_click(_ sender: Any) {
        let title = followBtn.title(for: .normal)
        //to follow
        if title == "FOLLOW" {
            //add follow information to database
            let object = PFObject(className: "follow")
            object["follower"] = PFUser.current()?.username
            object["following"] = usernameLbl.text!
            object.saveInBackground(block: {(success:Bool, error:Error?) -> Void in
                if success {
                    self.followBtn.setTitle("FOLLOWING", for: UIControl.State())
                    self.followBtn.backgroundColor = .green
                    
                    // send follow notification
                    let newsObj = PFObject(className: "news")
                    newsObj["by"] = PFUser.current()?.username
                    newsObj["ava"] = PFUser.current()?.object(forKey: "ava") as! PFFile
                    newsObj["to"] = self.usernameLbl.text!
                    newsObj["owner"] = ""
                    newsObj["uuid"] = ""
                    newsObj["type"] = "follow"
                    newsObj["checked"] = "no"
                    newsObj.saveEventually()
                }else{
                    print(error!.localizedDescription)
                }
            })
        //unfollow
        } else {
            //find follow information
            let query = PFQuery(className: "follow")
            query.whereKey("follower", equalTo: PFUser.current()!.username!)
            query.whereKey("following", equalTo: usernameLbl.text!)
            query.findObjectsInBackground { (objects, error) in
                if error == nil {
                    for object in objects! {
                        //delete follow information
                        object.deleteInBackground(block: { (success, error) in
                            if success {
                                self.followBtn.setTitle("FOLLOW", for: UIControl.State())
                                self.followBtn.backgroundColor = .lightGray
                                
                                // delete follow notification
                                let newsQuery = PFQuery(className: "news")
                                newsQuery.whereKey("by", equalTo: PFUser.current()!.username!)
                                newsQuery.whereKey("to", equalTo: self.usernameLbl.text!)
                                newsQuery.whereKey("type", equalTo: "follow")
                                newsQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                                    if error == nil {
                                        for object in objects! {
                                            object.deleteEventually()
                                        }
                                    }
                                })
                            } else {
                                print(error!.localizedDescription)
                            }
                        })
                    }
                } else {
                    print (error!.localizedDescription)
                }
            }
            
        }
    }
}
