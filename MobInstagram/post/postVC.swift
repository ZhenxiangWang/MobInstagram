//
//  postVC.swift
//  MobInstagram
//
//  Created by wenbin Chen on 19/9/18.
//  Copyright © 2018 wenbin Chen All rights reserved.
//  This file is for each post. Provide the main function for each post instance

import UIKit
import Parse
//this variable hold the uuid for each postVC instance
var postuuid = [String]()

class postVC: UITableViewController {
    
    //user name
    var usernameArray = [String]()
    //user picture
    var avaArray = [PFFile]()
    var dateArray = [Date?]()
    var picArray = [PFFile]()
    var uuidArray = [String]()
    var titleArray = [String]()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "PHOTO"
        
        //back to the previous view
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(title: "back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(postVC.back))
        self.navigationItem.leftBarButtonItem = backBtn
        //swipe function
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(postVC.back))
        backSwipe.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(backSwipe)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postVC.refresh), name: NSNotification.Name(rawValue: "liked"), object: nil)
        
        //load the post information
        let postQuery = PFQuery(className: "posts")
        postQuery.whereKey("uuid", equalTo: postuuid.last!)
        postQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                // clean up
                self.avaArray.removeAll(keepingCapacity: false)
                self.usernameArray.removeAll(keepingCapacity: false)
                self.dateArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                self.uuidArray.removeAll(keepingCapacity: false)
                self.titleArray.removeAll(keepingCapacity: false)
                
                // find related objects
                for object in objects! {
                    self.avaArray.append(object.value(forKey: "ava") as! PFFile)
                    self.usernameArray.append(object.value(forKey: "username") as! String)
                    self.dateArray.append(object.createdAt)
                    self.picArray.append(object.value(forKey: "pic") as! PFFile)
                    self.uuidArray.append(object.value(forKey: "uuid") as! String)
                    self.titleArray.append(object.value(forKey: "title") as! String)
                }
                self.tableView.reloadData()
            }
        }
    }

    @objc func refresh(){
        self.tableView.reloadData()
    }
    
    //navigate to a view that list all the user likes the post
    @objc func likeTap(_ sender: UITapGestureRecognizer){
        let i = (sender.view! as AnyObject).layer.value(forKey: "index") as! IndexPath
        let cell = tableView.cellForRow(at: i) as! postCell
        
        user = cell.uuidLbl.text!
        category = "likes"
        
        let likes = self.storyboard?.instantiateViewController(withIdentifier: "followersVC")    as! followersVC
        self.navigationController?.pushViewController(likes, animated: true)
    }
    //navigate to the comment view to comment this post
    @IBAction func commentBtn_click(_ sender: Any) {
        let i = (sender as AnyObject).layer.value(forKey: "index") as! IndexPath
        let cell = tableView.cellForRow(at: i) as! postCell
        
        commentuuid.append(cell.uuidLbl.text!)
        commentOwner.append(cell.usernameBtn.titleLabel!.text!)
        
        let comment = self.storyboard?.instantiateViewController(withIdentifier: "commentVC") as! commentVC
        self.navigationController?.pushViewController(comment, animated: true)
    }
    //navigate to the user's profile
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
    
    //back function
    @objc func back(sender: UIBarButtonItem){
        
        self.navigationController?.popViewController(animated: true)
        
        if !postuuid.isEmpty{
            postuuid.removeLast()
        }
    }
    
    //below are table view function
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
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
        
        let likeTap  = UITapGestureRecognizer(target: self, action: #selector(postVC.likeTap))
        likeTap.numberOfTapsRequired = 1
        cell.likeLbl.isUserInteractionEnabled = true
        cell.likeLbl.addGestureRecognizer(likeTap)
        
        cell.commentBtn.layer.setValue(indexPath, forKey: "index")
        cell.likeLbl.layer.setValue(indexPath, forKey:"index")
        
        return cell
    }
}
