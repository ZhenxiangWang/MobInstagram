//
//  postVC.swift
//  MobInstagram
//
//  Created by hha6027875 on 19/9/18.
//  Copyright © 2018 hha6027875. All rights reserved.
//

import UIKit
import Parse
var postuuid = [String]()

class postVC: UITableViewController {
    
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    var dateArray = [Date?]()
    var picArray = [PFFile]()
    var uuidArray = [String]()
    var titleArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "PHOTO"
        
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(title: "back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(postVC.back))
        self.navigationItem.leftBarButtonItem = backBtn
        
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(postVC.back))
        backSwipe.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(backSwipe)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postVC.refresh), name: NSNotification.Name(rawValue: "liked"), object: nil)
        
        //dynamic cell height
        //tableView.rowHeight = UITableViewAutomaticDimension
        //tableView.estimatedRowHeight = 450
        
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
        
        let likeTap  = UITapGestureRecognizer(target: self, action: #selector(postVC.likeTap))
        likeTap.numberOfTapsRequired = 1
        cell.likeLbl.isUserInteractionEnabled = true
        cell.likeLbl.addGestureRecognizer(likeTap)
        
        cell.commentBtn.layer.setValue(indexPath, forKey: "index")
        cell.likeLbl.layer.setValue(indexPath, forKey:"index")
        
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
}
