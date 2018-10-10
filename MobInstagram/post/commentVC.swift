//
//  commentVC.swift
//  MobInstagram
//
//  Created by wenbin chen on 20/9/18.
//  Copyright © 2018 wenbin Chen. All rights reserved.
//

import UIKit
import Parse

var commentuuid = [String]()
var commentOwner = [String]()

class commentVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var commentTxt: UITextView!
    @IBOutlet var sendBtn: UIButton!
    var refresher = UIRefreshControl()
    
    //this variable is for rising the input text field when tap the
    //text field and keyboard shows up
    var tableViewHeight : CGFloat = 0
    var commentY : CGFloat = 0
    var commentHeight : CGFloat = 0
    
    //this arrays restore all the comment information
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    var commentArray = [String]()
    var dateArray = [Date?]()
    
    var page : Int32 = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "COMMENT"
        
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(title: "back", style: .plain, target: self, action: #selector(commentVC.back))
        self.navigationItem.leftBarButtonItem = backBtn
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(commentVC.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(commentVC.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //declare hide keyboard tap
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(commentVC.hideKeyboardTap(_:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        loadComments()
        
    }
    //go back function
    @objc func back(_ sender: UIBarButtonItem){
        self.navigationController?.popViewController(animated: true)
        
        if !commentuuid.isEmpty{
            commentuuid.removeLast()
        }
        
        if !commentOwner.isEmpty{
            commentOwner.removeLast()
        }
    }
    
    // func loading when keyboard is shown
    @objc func keyboardWillShow(_ notification : Notification) {
        // move UI up
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.commentY = self.commentTxt.frame.origin.y
            self.commentTxt.frame.origin.y = 400
            self.sendBtn.frame.origin.y = self.commentTxt.frame.origin.y

        })
    }
    
    
    // func loading when keyboard is hidden
    @objc func keyboardWillHide(_ notification : Notification) {
        // move UI down
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.commentTxt.frame.origin.y = self.commentY
            self.sendBtn.frame.origin.y = self.commentY
        })
    }
    
    
    //hide keyboard if tapped
    @objc func hideKeyboardTap(_ recoginizer:UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    // load comments function
    func loadComments() {
        
        // STEP 1. Count total comments in order to skip all except (page size = 15)
        let countQuery = PFQuery(className: "comments")
        countQuery.whereKey("to", equalTo: commentuuid.last!)
        countQuery.countObjectsInBackground (block: { (count, error) -> Void in
            
            // if comments on the server for current post are more than (page size 15), implement pull to refresh func
            if self.page < count {
                self.refresher.addTarget(self, action: #selector(commentVC.loadMore), for: UIControl.Event.valueChanged)
                self.tableView.addSubview(self.refresher)
            }
            
            // STEP 2. Request last (page size 15) comments
            let query = PFQuery(className: "comments")
            query.whereKey("to", equalTo: commentuuid.last!)
            query.limit = count.distance(to: self.page)
            query.addAscendingOrder("createdAt")
            query.findObjectsInBackground(block: { (objects, erro) -> Void in
                if error == nil {
                    
                    // clean up
                    self.usernameArray.removeAll(keepingCapacity: false)
                    self.avaArray.removeAll(keepingCapacity: false)
                    self.commentArray.removeAll(keepingCapacity: false)
                    self.dateArray.removeAll(keepingCapacity: false)
                    
                    // find related objects
                    for object in objects! {
                        self.usernameArray.append(object.object(forKey: "username") as! String)
                        self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                        self.commentArray.append(object.object(forKey: "comment") as! String)
                        self.dateArray.append(object.createdAt)
                        self.tableView.reloadData()
                        
                        // scroll to bottom
                        self.tableView.scrollToRow(at: IndexPath(row: self.commentArray.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)
                    }
                } else {
                    print(error?.localizedDescription ?? String())
                }
            })
        })
        
    }
    
    
    // pagination
    @objc func loadMore() {
        
        // STEP 1. Count total comments in order to skip all except (page size = 15)
        let countQuery = PFQuery(className: "comments")
        countQuery.whereKey("to", equalTo: commentuuid.last!)
        countQuery.countObjectsInBackground (block: { (count, error) -> Void in
            
            // self refresher
            self.refresher.endRefreshing()
            
            // remove refresher if loaded all comments
            if self.page >= count {
                self.refresher.removeFromSuperview()
            }
            
            // STEP 2. Load more comments
            if self.page < count {
                
                // increase page to load 30 as first paging
                self.page = self.page + 15
                
                // request existing comments from the server
                let query = PFQuery(className: "comments")
                query.whereKey("to", equalTo: commentuuid.last!)
                query.skip = count.distance(to: self.page)
                query.addAscendingOrder("createdAt")
                query.findObjectsInBackground(block: { (objects, error) -> Void in
                    if error == nil {
                        
                        // clean up
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.avaArray.removeAll(keepingCapacity: false)
                        self.commentArray.removeAll(keepingCapacity: false)
                        self.dateArray.removeAll(keepingCapacity: false)
                        
                        // find related objects
                        for object in objects! {
                            self.usernameArray.append(object.object(forKey: "username") as! String)
                            self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                            self.commentArray.append(object.object(forKey: "comment") as! String)
                            self.dateArray.append(object.createdAt)
                            self.tableView.reloadData()
                        }
                    } else {
                        print(error?.localizedDescription ?? String())
                    }
                })
            }
            
        })
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! commentCell
        
        cell.usernameBtn.setTitle(usernameArray[indexPath.row], for: UIControl.State())

        cell.commentLbl.text = commentArray[indexPath.row]
        avaArray[indexPath.row].getDataInBackground { (data, error) in
            cell.avaImg.image = UIImage(data: data!)
        }

        cell.dateLbl.text = "\(String(describing: dateArray[indexPath.row]!))"
        
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        
        return cell
    }
    
    
    @IBAction func sendBtn_click(_ sender: Any) {
        
        if commentTxt.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "" {
            return
        }
        
        let commentObj = PFObject(className: "comments")
        commentObj["to"] = commentuuid.last
        commentObj["username"] = PFUser.current()?.username
        commentObj["ava"] = PFUser.current()?.value(forKey: "ava")
        commentObj["comment"] = commentTxt.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        commentObj.saveInBackground { (success, error) in
            if error == nil {
                self.usernameArray.append(PFUser.current()!.username!)
                self.avaArray.append(PFUser.current()?.object(forKey: "ava") as! PFFile)
                self.dateArray.append(Date())
                self.commentArray.append(self.commentTxt.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
                self.commentTxt.text = ""
                self.tableView.reloadData()
            } else {
                print (error!.localizedDescription)
            }
        }
        
        //Send notification as comment
        if commentOwner.last != PFUser.current()?.username{
            let newsObj = PFObject(className: "news")
            newsObj["by"] = PFUser.current()?.username
            newsObj["ava"] = PFUser.current()?.object(forKey: "ava") as! PFFile
            newsObj["to"] = commentOwner.last
            newsObj["owner"] = commentOwner.last
            newsObj["uuid"] = commentuuid.last
            newsObj["type"] = "comment"
            newsObj["checked"] = "no"
            newsObj.saveEventually()
        }
    
    }
    
    //clicking username navigate to the user's profile
    @IBAction func usernameBtn_click(_ sender: Any) {
        
        let i = (sender as AnyObject).layer.value(forKey: "index") as! IndexPath
        
        let cell = tableView.cellForRow(at: i) as! commentCell
        
        if cell.usernameBtn.titleLabel?.text == PFUser.current()?.username{
            let home = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as! homeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guest.append(cell.usernameBtn.titleLabel!.text!)
            let guestvc = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! guestVC
            self.navigationController?.pushViewController(guestvc, animated: true)
        }
        
    }
}
