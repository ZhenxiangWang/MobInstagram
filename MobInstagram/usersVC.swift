//
//  usersVC.swift
//  MobInstagram
//
//  Created by hha6027875 on 23/9/18.
//  Copyright © 2018 hha6027875. All rights reserved.
//

import UIKit
import Parse

class usersVC: UITableViewController, UISearchBarDelegate {

    // decalre search bar
    var searchBar = UISearchBar()
    
    // arrays to hold information from server
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.sizeToFit()
        searchBar.tintColor = UIColor.groupTableViewBackground
        searchBar.frame.size.width = self.view.frame.size.width - 30
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.leftBarButtonItem = searchItem
        
        loadUsers()
    }
    
    func loadUsers() {
        
        var followerArray = [String]()
        var followerUsers = [String]()
        
        let followerQuery = PFQuery(className: "follow")
        followerQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
        followerQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                for object in objects! {
                    followerArray.append(object.value(forKey: "following") as! String)
                    print(followerArray)
                }
                
                let followerQuery2 = PFQuery(className: "follow")
                followerQuery2.whereKey("follower", containedIn: followerArray)
                followerQuery2.findObjectsInBackground { (objects, error) in
                    if error == nil {
                        for object in objects! {
                            followerUsers.append(object.value(forKey: "following") as! String)
                        }
                        
                        let userQuery = PFQuery(className: "_User")
                        userQuery.whereKey("username", containedIn: followerUsers)
                        userQuery.addDescendingOrder("createdAt")
                        userQuery.findObjectsInBackground { (object, error) in
                            if error == nil {
                                self.usernameArray.removeAll(keepingCapacity: false)
                                self.avaArray.removeAll(keepingCapacity: false)
                                
                                for object in object! {
                                    if (object.object(forKey: "username") as! String) != PFUser.current()?.username! {
                                        self.usernameArray.append(object.value(forKey: "username") as! String)
                                        self.avaArray.append(object.value(forKey: "ava") as! PFFile)
                                    }
                                }
                                
                                self.tableView.reloadData()
                            } else{
                                print (error!.localizedDescription)
                            }
                        }
                        
                    } else {
                        print (error?.localizedDescription ?? "" )
                    }
                }
                
            } else {
                print (error?.localizedDescription ?? "")
            }
        }
    }
    
    // clicked cancel button
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
        // reset text
        searchBar.text = ""
        
        // reset shown users
        loadUsers()
    }
    
    // search updated
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // find by username
        if searchBar.text! == "" {
            loadUsers()
        } else {
            let usernameQuery = PFQuery(className: "_User")
            usernameQuery.whereKey("username", matchesRegex: "(?i)" + searchBar.text!)
            usernameQuery.findObjectsInBackground (block: { (objects, error) -> Void in
                if error == nil {
                    
                    // clean up
                    self.usernameArray.removeAll(keepingCapacity: false)
                    self.avaArray.removeAll(keepingCapacity: false)
                    
                    // found related objects
                    for object in objects! {
                        if (object.object(forKey: "username") as! String) != PFUser.current()?.username! {
                            self.usernameArray.append(object.object(forKey: "username") as! String)
                            self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                        }
                    }
                    
                    // reload
                    self.tableView.reloadData()
                    
                }
            })
        }
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.size.width / 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! followersCell
        
        //cell.followBtn.isHidder = true
        
        cell.usernameLbl.text = usernameArray[indexPath.row]
        avaArray[indexPath.row].getDataInBackground { (data, error) in
            if error == nil {
                cell.avaImg.image = UIImage(data: data!)
            }
        }
        
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
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! followersCell
        
        if cell.usernameLbl.text! == PFUser.current()?.username! {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as! homeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guest.append(cell.usernameLbl.text!)
            let guestvc = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! guestVC
            self.navigationController?.pushViewController(guestvc, animated: true)
        }
    }

}
