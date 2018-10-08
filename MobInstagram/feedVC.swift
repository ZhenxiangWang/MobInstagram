//
//  feedVC.swift
//  MobInstagram
//
//  Created by hha6027875 on 23/9/18.
//  Copyright © 2018 hha6027875. All rights reserved.
//

import UIKit
import Parse

class feedVC: UITableViewController {

    var refresher = UIRefreshControl()
    
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    var dateArray = [Date?]()
    var picArray = [PFFile]()
    var titleArray = [String]()
    var uuidArray = [String]()
    
    var followArray = [String]()
    
    var page : Int = 10
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "FEED"
        
        tableView.rowHeight = 540
        //pull to refresh
        refresher.addTarget(self, action: #selector(feedVC.loadPosts), for: UIControl.Event.valueChanged)
        tableView.addSubview(refresher)
        
        NotificationCenter.default.addObserver(self, selector: #selector(feedVC.refresh), name: NSNotification.Name(rawValue: "liked"), object: nil)
        
        loadPosts()
    }
    
    @objc func refresh(){
        self.tableView.reloadData()
    }
    
    @objc func loadPosts(){
        //step 1
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: PFUser.current()?.username!)
        followQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                self.followArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    self.followArray.append(object.object(forKey: "following") as! String)
                }
                self.followArray.append((PFUser.current()?.username)!)
                
                //step2
                let query = PFQuery(className: "posts")
                query.whereKey("username", containedIn: self.followArray)
                query.limit = self.page
                query.addDescendingOrder("createdAt")
                query.findObjectsInBackground(block: { (objects, error) in
                    if error == nil {
                        
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.avaArray.removeAll(keepingCapacity: false)
                        self.dateArray.removeAll(keepingCapacity: false)
                        self.picArray.removeAll(keepingCapacity: false)
                        self.titleArray.removeAll(keepingCapacity: false)
                        self.uuidArray.removeAll(keepingCapacity: false)
                        
                        for object in objects! {
                            self.usernameArray.append(object.object(forKey: "username") as! String)
                            self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                            self.dateArray.append(object.createdAt)
                            self.picArray.append(object.object(forKey: "pic") as! PFFile)
                            self.titleArray.append(object.object(forKey: "title") as! String)
                            self.uuidArray.append(object.object(forKey: "uuid") as! String)
                        }
                        
                        self.tableView.reloadData()
                        self.refresher.endRefreshing()
                        
                    } else {
                        print(error!.localizedDescription)
                    }
                })
            } else {
                print (error!.localizedDescription)
            }
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height * 2{
            loadMore()
        }
    }
    
    func loadMore(){
        
        if page <= uuidArray.count{
            page = page + 10
            //step 1
            let followQuery = PFQuery(className: "follow")
            followQuery.whereKey("follower", equalTo: PFUser.current()?.username!)
            followQuery.findObjectsInBackground { (objects, error) in
                if error == nil {
                    self.followArray.removeAll(keepingCapacity: false)
                    
                    for object in objects! {
                        self.followArray.append(object.object(forKey: "following") as! String)
                    }
                    self.followArray.append((PFUser.current()?.username)!)
                    
                    //step2
                    let query = PFQuery(className: "posts")
                    query.whereKey("username", containedIn: self.followArray)
                    query.limit = self.page
                    query.addDescendingOrder("createdAt")
                    query.findObjectsInBackground(block: { (objects, error) in
                        if error == nil {
                            
                            self.usernameArray.removeAll(keepingCapacity: false)
                            self.avaArray.removeAll(keepingCapacity: false)
                            self.dateArray.removeAll(keepingCapacity: false)
                            self.picArray.removeAll(keepingCapacity: false)
                            self.titleArray.removeAll(keepingCapacity: false)
                            self.uuidArray.removeAll(keepingCapacity: false)
                            
                            for object in objects! {
                                self.usernameArray.append(object.object(forKey: "username") as! String)
                                self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                                self.dateArray.append(object.createdAt)
                                self.picArray.append(object.object(forKey: "pic") as! PFFile)
                                self.titleArray.append(object.object(forKey: "title") as! String)
                                self.uuidArray.append(object.object(forKey: "uuid") as! String)
                            }
                            
                            self.tableView.reloadData()
                            self.refresher.endRefreshing()
                            
                        } else {
                            print(error!.localizedDescription)
                        }
                    })
                } else {
                    print (error!.localizedDescription)
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! postCell
        
        cell.usernameBtn.setTitle(usernameArray[indexPath.row], for: UIControl.State())
        cell.uuidLbl.text = uuidArray[indexPath.row]
        cell.titleLbl.text = titleArray[indexPath.row]
        
        avaArray[indexPath.row].getDataInBackground { (data, error) in
            if error == nil{
                cell.avaImg.image = UIImage(data: data!)
            }
        }
        
        picArray[indexPath.row].getDataInBackground { (data, error) in
            if error == nil{
                cell.picImg.image = UIImage(data: data!)
            }
        }
        
        cell.dateLbl.text = "\(String(describing: dateArray[indexPath.row]!))"
        
        let didLike = PFQuery(className:"likes")
        didLike.whereKey("by", equalTo: PFUser.current()!.username!)
        didLike.whereKey("to", equalTo: cell.uuidLbl.text!)
        didLike.countObjectsInBackground { (count, erroe) in
            if count == 0 {
                cell.likeBtn.setTitle("like", for: UIControl.State())
            }else {
                cell.likeBtn.setTitle("unlike", for: UIControl.State())
            }
        }
        
        let countLikes = PFQuery(className: "likes")
        countLikes.whereKey("to", equalTo: cell.uuidLbl.text!)
        countLikes.countObjectsInBackground { (count, error) in
            cell.likeLbl.text = "\(count)"
        }
        
        let likeTap  = UITapGestureRecognizer(target: self, action: #selector(feedVC.likeTap))
        likeTap.numberOfTapsRequired = 1
        cell.likeLbl.isUserInteractionEnabled = true
        cell.likeLbl.addGestureRecognizer(likeTap)
        
        cell.commentBtn.layer.setValue(indexPath, forKey: "index")
        cell.likeLbl.layer.setValue(indexPath, forKey:"index")
        
        cell.isUserInteractionEnabled = false
        return cell
    }
    
    @objc func likeTap(_ sender: UITapGestureRecognizer){
        let i = (sender.view! as AnyObject).layer.value(forKey: "index") as! IndexPath
        let cell = tableView.cellForRow(at: i) as! postCell
        
        user = cell.uuidLbl.text!
        category = "likes"
        
        let likes = self.storyboard?.instantiateViewController(withIdentifier: "followersVC")    as! followersVC
        self.navigationController?.pushViewController(likes, animated: true)
    }
    
    @IBAction func commentBtn_click(_ sender: Any) {
        let i = (sender as AnyObject).layer.value(forKey: "index") as! IndexPath
        let cell = tableView.cellForRow(at: i) as! postCell
        
        commentuuid.append(cell.uuidLbl.text!)
        commentOwner.append(cell.usernameBtn.titleLabel!.text!)
        
        let comment = self.storyboard?.instantiateViewController(withIdentifier: "commentVC") as! commentVC
        self.navigationController?.pushViewController(comment, animated: true)
    }
    
    @IBAction func usernameBtn_click(_ sender: Any) {
        let title = (sender as AnyObject).title(for: UIControl.State())
        if title == PFUser.current()!.username!{
            let home = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as! homeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guest.append(title!)
            let guestvc = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! guestVC
            self.navigationController?.pushViewController(guestvc, animated: true)
        }
    }
    
    
    @objc func back(sender: UIBarButtonItem){
        
        self.navigationController?.popViewController(animated: true)
        
        if !postuuid.isEmpty{
            postuuid.removeLast()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return uuidArray.count
    }

}
