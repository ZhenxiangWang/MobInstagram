//
//  headerView.swift
//  MobInstagram
//
//  Created by hha6027875 on 15/9/18.
//  Copyright © 2018 hha6027875. All rights reserved.
//  this is header view config

import UIKit
import Parse

class headerView: UICollectionReusableView {
        
    @IBOutlet var avaImg: UIImageView!
    @IBOutlet var fullnameLbl: UILabel!
    @IBOutlet var webTxt: UITextView!
    @IBOutlet var bioLbl: UILabel!
    
    
    @IBOutlet var posts: UILabel!
    @IBOutlet var followers: UILabel!
    @IBOutlet var followings: UILabel!
    
    
    @IBOutlet var postsTitle: UILabel!
    @IBOutlet var followerTitle: UILabel!
    @IBOutlet var followingsTitle: UILabel!
    
    @IBOutlet var button: UIButton!
    
    //If it is others profile page, there will be a follow button.
    //Clicking it can follow or unfollow that user
    @IBAction func followBtn_click(_ sender: Any) {
        let title = button.title(for: .normal)
        //to follow
        if title == "FOLLOW" {
            //add a follow information to database
            let object = PFObject(className: "follow")
            object["follower"] = PFUser.current()?.username
            object["following"] = guest.last!
            object.saveInBackground(block: {(success:Bool, error:Error?) -> Void in
                if success {
                    self.button.setTitle("FOLLOWING", for: UIControl.State())
                    self.button.backgroundColor = .green
                    
                    // send follow notification
                    let newsObj = PFObject(className: "news")
                    newsObj["by"] = PFUser.current()?.username
                    newsObj["ava"] = PFUser.current()?.object(forKey: "ava") as! PFFile
                    newsObj["to"] = guest.last
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
            //find the follow information
            let query = PFQuery(className: "follow")
            query.whereKey("follower", equalTo: PFUser.current()!.username!)
            query.whereKey("following", equalTo: guest.last!)
            query.findObjectsInBackground { (objects, error) in
                if error == nil {
                    for object in objects! {
                        //delete the follow information
                        object.deleteInBackground(block: { (success, error) in
                            if success {
                                self.button.setTitle("FOLLOW", for: UIControl.State())
                                self.button.backgroundColor = .lightGray
                                
                                // delete follow notification
                                let newsQuery = PFQuery(className: "news")
                                newsQuery.whereKey("by", equalTo: PFUser.current()!.username!)
                                newsQuery.whereKey("to", equalTo: guest.last!)
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
