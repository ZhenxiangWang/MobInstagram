//
//  newsVC.swift
//  MobInstagram
//
//  Created by hha6027875 on 24/9/18.
//  Copyright © 2018 hha6027875. All rights reserved.
//

import UIKit
import Parse

class newsVC: UITableViewController {
    
    // arrays to hold data from server
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    var typeArray = [String]()
    var dateArray = [Date?]()
    var uuidArray = [String]()
    var ownerArray = [String]()
    var toArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // title at the top
        self.navigationItem.title = "NOTIFICATIONS"
        
        tableView.rowHeight = 80
        
        self.loadNews()

    }
    
    func loadNews() {
        var followingUsers = [String]()
        let followingQuery = PFQuery(className: "follow")
        followingQuery.whereKey("follower", equalTo: PFUser.current()?.username!)
        followingQuery.findObjectsInBackground { (objects, error) in
            for object in objects! {
                followingUsers.append(object.object(forKey: "following") as! String)
            }
            
            let queryf = PFQuery(className: "news")
            queryf.whereKey("by", containedIn: followingUsers)
            
            let queryU = PFQuery(className: "news")
            queryU.whereKey("to", equalTo: PFUser.current()!.username!)
            
            let query = PFQuery.orQuery(withSubqueries: [queryf, queryU])
            query.addDescendingOrder("createdAt")
            query.limit = 30
            query.findObjectsInBackground (block: { (objects, error) -> Void in
                if error == nil {
                    
                    // clean up
                    self.usernameArray.removeAll(keepingCapacity: false)
                    self.toArray.removeAll(keepingCapacity: false)
                    self.avaArray.removeAll(keepingCapacity: false)
                    self.typeArray.removeAll(keepingCapacity: false)
                    self.dateArray.removeAll(keepingCapacity: false)
                    self.uuidArray.removeAll(keepingCapacity: false)
                    self.ownerArray.removeAll(keepingCapacity: false)
                    
                    // found related objects
                    for object in objects! {
                        self.usernameArray.append(object.object(forKey: "by") as! String)
                        self.toArray.append(object.object(forKey: "to") as! String)
                        self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                        self.typeArray.append(object.object(forKey: "type") as! String)
                        self.dateArray.append(object.createdAt)
                        self.uuidArray.append(object.object(forKey: "uuid") as! String)
                        self.ownerArray.append(object.object(forKey: "owner") as! String)
                        
                        // save notifications as checked
                        object["checked"] = "yes"
                        object.saveEventually()
                    }
                    
                    // reload tableView to show received data
                    self.tableView.reloadData()
                }
            })
        }
        
        // request notifications
        
    }

    // cell numb
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }
    
    
    // cell config
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // declare cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! newsCell
        
        cell.followBtn.isHidden = true
        
        // connect cell objects with received data from server
        cell.usernameBtn.setTitle(usernameArray[indexPath.row], for: UIControl.State())
        avaArray[indexPath.row].getDataInBackground { (data, error) -> Void in
            if error == nil {
                cell.avaImg.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        }
        
        // calculate post date
        
         cell.dateLbl.text = "\(String(describing: dateArray[indexPath.row]!))"
        if toArray[indexPath.row] == PFUser.current()?.username!{
            if typeArray[indexPath.row] == "comment" {
                cell.infoLbl.text = "has commented your post."
            }
            else if typeArray[indexPath.row] == "follow" {
                cell.infoLbl.text = "now following you."
            }
            else if typeArray[indexPath.row] == "like" {
                cell.infoLbl.text = "likes your post."
            }
        }
        else{
            if typeArray[indexPath.row] == "comment" {
                cell.infoLbl.text = "has commented a post."
            }
            else if typeArray[indexPath.row] == "follow" {
                cell.infoLbl.text = "now following a user."
            }
            else if typeArray[indexPath.row] == "like" {
                cell.infoLbl.text = "likes a post."
            }
            else if typeArray[indexPath.row] == "post" {
                cell.infoLbl.text = "upload a new post"
            }
        }
        
        // asign index of button
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        
        return cell
    }
    
    
    // clicked username button
    @IBAction func usernameBtn_click(_ sender: AnyObject) {
        
        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        // call cell to call further cell data
        let cell = tableView.cellForRow(at: i) as! newsCell
        
        // if user tapped on himself go home, else go guest
        if cell.usernameBtn.titleLabel?.text == PFUser.current()?.username {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as! homeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guest.append(cell.usernameBtn.titleLabel!.text!)
            let guestvc = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! guestVC
            self.navigationController?.pushViewController(guestvc, animated: true)
        }
    }

}
