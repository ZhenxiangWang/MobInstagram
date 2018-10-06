//
//  followersVC.swift
//  MobInstagram
//
//  Created by hha6027875 on 16/9/18.
//  Copyright © 2018 hha6027875. All rights reserved.
//

import UIKit
import Parse

var category = String()
var user = String()

class followersVC: UITableViewController {
    
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    
    var followArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = category
        
        //according to different category load different users
        if category == "followers" {
            loadFollowers()
        } else if category == "followings" {
            loadFollowings()
        } else if category == "likes" {
            loadLikes()
        }
    }
    
    func loadFollowers(){
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("following", equalTo: user)
        followQuery.findObjectsInBackground(block: {(object:[PFObject]?, error:Error?) -> Void in
            if error == nil {
                //clean up
                self.followArray.removeAll(keepingCapacity: false)
                //find the follower object
                for object in object! {
                    self.followArray.append(object.value(forKey: "follower") as! String)
                }
                //find the following user
                let query = PFQuery(className: "_User")
                query.whereKey("username", containedIn: self.followArray)
                query.addDescendingOrder("createdAt")
                query.findObjectsInBackground(block: {(objects:[PFObject]?, error:Error?) -> Void in
                    if error == nil{
                        
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.avaArray.removeAll(keepingCapacity: false)
                        //add to array
                        for object in objects! {
                            self.usernameArray.append(object.object(forKey: "username") as! String)
                            self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                            self.tableView.reloadData()
                        }
                        
                    } else{
                        print(error!.localizedDescription)
                    }
                })
            } else {
                print(error!.localizedDescription)
            }
        })
    }
    
    func loadFollowings(){
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: user)
        followQuery.findObjectsInBackground(block: {(object:[PFObject]?, error:Error?) -> Void in
            if error == nil {
                
                //clean up
                self.followArray.removeAll(keepingCapacity: false)
                //find the follower object
                for object in object! {
                    self.followArray.append(object.value(forKey: "following") as! String)
                }
                //find the following user
                let query = PFQuery(className: "_User")
                query.whereKey("username", containedIn: self.followArray)
                query.addDescendingOrder("createdAt")
                query.findObjectsInBackground(block: {(objects:[PFObject]?, error:Error?) -> Void in
                    if error == nil{
                        
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.avaArray.removeAll(keepingCapacity: false)
                        //add to array
                        for object in objects! {
                            self.usernameArray.append(object.object(forKey: "username") as! String)
                            self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                            self.tableView.reloadData()
                        }
                        
                    } else{
                        print(error!.localizedDescription)
                    }
                })
            } else {
                print(error!.localizedDescription)
            }
        })
    }
    
    func loadLikes(){
        //find the users that likes the post
        let followQuery = PFQuery(className: "likes")
        followQuery.whereKey("to", equalTo: user)
        followQuery.findObjectsInBackground(block: {(object:[PFObject]?, error:Error?) -> Void in
            if error == nil {
                
                //clean up
                self.followArray.removeAll(keepingCapacity: false)
                //find the follower object
                for object in object! {
                    self.followArray.append(object.value(forKey: "by") as! String)
                }
                //find the user ava
                let query = PFQuery(className: "_User")
                query.whereKey("username", containedIn: self.followArray)
                query.addDescendingOrder("createdAt")
                query.findObjectsInBackground(block: {(objects:[PFObject]?, error:Error?) -> Void in
                    if error == nil{
                        //clean up
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.avaArray.removeAll(keepingCapacity: false)
                        //add to array
                        for object in objects! {
                            self.usernameArray.append(object.object(forKey: "username") as! String)
                            self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                            self.tableView.reloadData()
                        }
                        
                    } else{
                        print(error!.localizedDescription)
                    }
                })
            } else {
                print(error!.localizedDescription)
            }
        })
    }

    //cell number
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernameArray.count
    }

    //cell config
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! followersCell
        
        //connect data from server to object
        cell.usernameLbl.text = usernameArray[indexPath.row]
        avaArray[indexPath.row].getDataInBackground(block: {(data:Data?, error:Error?) -> Void in
            if error == nil {
                cell.avaImg.image = UIImage(data: data!)
            }else {
                print(error!.localizedDescription)
            }
        })
        
        //show do user following or do not
        let query = PFQuery(className: "follow")
        query.whereKey("follower", equalTo: PFUser.current()!.username!)
        query.whereKey("following", equalTo: cell.usernameLbl.text!)
        query.countObjectsInBackground(block: {(count:Int32, error:Error?) -> Void in
            if error == nil {
                if count == 0 {
                    cell.followBtn.setTitle("FOLLOW", for: UIControl.State())
                    cell.followBtn.backgroundColor = .lightGray
                }else {
                    cell.followBtn.setTitle("FOLLOWING", for: UIControl.State())
                    cell.followBtn.backgroundColor = UIColor.green
                }
            }
        })
        
        if cell.usernameLbl.text == PFUser.current()?.username {
            cell.followBtn.isHidden = true
        }
        
        return cell
    }
    
    //select each cell can navigate to the user's profile
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! followersCell
        
        //jump to myself
        if cell.usernameLbl.text! == PFUser.current()!.username! {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as! homeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {//guest jump
            guest.append(cell.usernameLbl.text!)
            let guestv = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! guestVC
            self.navigationController?.pushViewController(guestv, animated: true)
        }
    }

}
