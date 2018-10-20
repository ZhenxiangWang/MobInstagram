//
//  feedVC.swift
//  MobInstagram
//
//  Created by Wenbin Chen on 23/9/18.
//  Copyright © 2018 Wenbin Chen. All rights reserved.
//  this file contain the main function of feed page

import UIKit
import Parse

class feedVC: UITableViewController {

    var refresher = UIRefreshControl()
    
    //the all information for posts
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    var dateArray = [Date?]()
    var picArray = [PFFile]()
    var titleArray = [String]()
    var uuidArray = [String]()
    
    
    //this is the arraty store the people that the user following
    var followArray = [String]()
    
    var page : Int = 10
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "FEED"
        
        tableView.rowHeight = 540
        //pull to refresh
        refresher.addTarget(self, action: #selector(feedVC.loadPosts), for: UIControl.Event.valueChanged)
        tableView.addSubview(refresher)
        
    NotificationCenter.default.addObserver(self, selector: #selector(feedVC.refreshCell), name: NSNotification.Name(rawValue: "liked"), object: nil)
        
        loadPosts()
    }
    
    @objc func refresh(){
        self.tableView.reloadData()
    }
    
    @objc func refreshCell(notification:Notification){
        let cellIndex = notification.object as! IndexPath
        self.tableView.reloadRows(at: [cellIndex], with: UITableView.RowAnimation.none)
    }
    
    @objc func loadPosts(){
        //step 1 find the following people
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: PFUser.current()?.username!)
        followQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                self.followArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    self.followArray.append(object.object(forKey: "following") as! String)
                }
                self.followArray.append((PFUser.current()?.username)!)
                
                //step2 according to following people load post
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
    
    //scroll to load more
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height * 2{
            loadMore()
        }
    }
    
    //load more posts
    func loadMore(){
        
        if page <= uuidArray.count{
            //increase load number limit
            page = page + 10
            //step 1 find the following users
            let followQuery = PFQuery(className: "follow")
            followQuery.whereKey("follower", equalTo: PFUser.current()?.username!)
            followQuery.findObjectsInBackground { (objects, error) in
                if error == nil {
                    self.followArray.removeAll(keepingCapacity: false)
                    
                    for object in objects! {
                        self.followArray.append(object.object(forKey: "following") as! String)
                    }
                    self.followArray.append((PFUser.current()?.username)!)
                    
                    //step2 load the post according to following people
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

    //config cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! postCell
        cell.cellIndex = indexPath
        //config each component in cell
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
        
        //load date
        let from = dateArray[indexPath.row]
        let now = Date()
        let components : NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth]
        let difference = (Calendar.current as NSCalendar).components(components, from: from!, to: now, options: [])
        
        if difference.second! <= 0 {
            cell.dateLbl.text = "now"
        }
        if difference.second! > 0 && difference.minute! == 0 {
            cell.dateLbl.text = "\(String(describing: difference.second!))s."
        }
        if difference.minute! > 0 && difference.hour! == 0 {
            cell.dateLbl.text = "\(String(describing: difference.minute!))m."
        }
        if difference.hour! > 0 && difference.day! == 0 {
            cell.dateLbl.text = "\(String(describing: difference.hour!))h."
        }
        if difference.day! > 0 && difference.weekOfMonth! == 0 {
            cell.dateLbl.text = "\(String(describing: difference.day!))d."
        }
        if difference.weekOfMonth! > 0 {
            cell.dateLbl.text = "\(String(describing: difference.weekOfMonth!))w."
        }
        
        // according to like status config like button
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
        
        //count likes number
        let countLikes = PFQuery(className: "likes")
        countLikes.whereKey("to", equalTo: cell.uuidLbl.text!)
        countLikes.countObjectsInBackground { (count, error) in
            cell.likeLbl.text = "\(count)"
        }
        
        //add gesture to like button
        let likeTap  = UITapGestureRecognizer(target: self, action: #selector(feedVC.likeTap))
        likeTap.numberOfTapsRequired = 1
        cell.likeLbl.isUserInteractionEnabled = true
        cell.likeLbl.addGestureRecognizer(likeTap)
        
        cell.commentBtn.layer.setValue(indexPath, forKey: "index")
        cell.likeLbl.layer.setValue(indexPath, forKey:"index")
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    //clicking like label can navigate to the view that list all
    //users that like this posts
    @objc func likeTap(_ sender: UITapGestureRecognizer){
        let i = (sender.view! as AnyObject).layer.value(forKey: "index") as! IndexPath
        let cell = tableView.cellForRow(at: i) as! postCell
        
        user = cell.uuidLbl.text!
        category = "likes"
        
        let likes = self.storyboard?.instantiateViewController(withIdentifier: "followersVC")    as! followersVC
        self.navigationController?.pushViewController(likes, animated: true)
    }
    
    //clicking coment button can navigate to the view that can comment this post
    @IBAction func commentBtn_click(_ sender: Any) {
        let i = (sender as AnyObject).layer.value(forKey: "index") as! IndexPath
        let cell = tableView.cellForRow(at: i) as! postCell
        
        commentuuid.append(cell.uuidLbl.text!)
        commentOwner.append(cell.usernameBtn.titleLabel!.text!)
        
        let comment = self.storyboard?.instantiateViewController(withIdentifier: "commentVC") as! commentVC
        self.navigationController?.pushViewController(comment, animated: true)
    }
    
    //click username can go to their profile page
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
    
    @IBAction func blueToothBtn_click(_ sender: Any) {
        let demoFlowController = self.storyboard?.instantiateViewController(withIdentifier: "DemoFlowController") as! DemoFlowController
        self.navigationController?.pushViewController(demoFlowController, animated: true)
        
    }
    //go back to last view
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
