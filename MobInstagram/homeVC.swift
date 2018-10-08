//
//  homeVC.swift
//  MobInstagram
//
//  Created by Wenbin Chen on 15/9/18.
//  Copyright © 2018 Wenbin Chen. All rights reserved.
//  This is the viewController for user profile

import UIKit
import Parse

class homeVC: UICollectionViewController {

    var refresher : UIRefreshControl!
    // each time display 9 posts
    var page : Int = 9
    var uuidArray = [String]()
    var picArray = [PFFile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.alwaysBounceVertical = true
        self.navigationItem.title = PFUser.current()?.username?.uppercased()
        
        //init refresh function
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(homeVC.refresh), for: UIControl.Event.valueChanged)
        collectionView?.addSubview(refresher)
        
        //load posts func
        loadPosts()
    }
    
    //refresh function
    @objc func refresh(){
        collectionView?.reloadData()
        loadPosts()
        refresher.endRefreshing()
    }
    
    //load posts to member variables
    func loadPosts(){
        //search post in server database
        let query = PFQuery(className: "posts")
        query.whereKey("username", equalTo:PFUser.current()!.username!)
        query.limit = page
        query.findObjectsInBackground(block: {(objects:[PFObject]?, error:Error?) -> Void in
            if error == nil {
                //clean up
                self.uuidArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                
                //find related to our request
                for object in objects! {
                    //add found data to arrays (holders)
                    self.uuidArray.append(object.value(forKey: "uuid") as! String)
                    self.picArray.append(object.value(forKey: "pic") as! PFFile)
                }
                //refresh table view
                self.collectionView?.reloadData()
            }else {
                print(error!.localizedDescription)
            }
        })
        
    }
    //scroll view scrolled funtion
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height {
            self.loadMore()
        }
    }
    
    //load more post
    func loadMore(){
        if page <= picArray.count {
           page = page + page
            //search more post
            let query = PFQuery(className: "posts")
            query.whereKey("username", equalTo: guest.last!)
            query.limit = page
            query.findObjectsInBackground { (objects, error) in
                if error == nil {
                    self.uuidArray.removeAll(keepingCapacity: false)
                    self.picArray.removeAll(keepingCapacity: false)
                    
                    for object in objects! {
                        self.uuidArray.append(object.value(forKey: "uuid") as! String)
                        self.picArray.append(object.value(forKey: "pic") as! PFFile)
                    }
                    print("loaded +\(self.page)")
                    self.collectionView?.reloadData()
                } else {
                    print(error!.localizedDescription)
                }
            }
        }
    }
    
    //fucntion when tap post
    @objc func postsTap(){
        if picArray.isEmpty {
            let index = IndexPath(item: 0, section: 0)
            self.collectionView?.scrollToItem(at: index, at: UICollectionView.ScrollPosition.top, animated: true)
        }
    }
    //tap follower lable function. Navigate to new view which listing all followers
    @objc func followersTap(_ sender: Any){
        user = (PFUser.current()?.username)!
        category = "followers"
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "followersVC")    as! followersVC
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    //tap following label function. Navigate to new view which listing all followings
    @objc func followingsTap(){
        user = (PFUser.current()?.username!)!
        category = "followings"
        let followings = self.storyboard?.instantiateViewController(withIdentifier: "followersVC") as! followersVC
        self.navigationController?.pushViewController(followings, animated: true)
    }

    //logout funciton
    @IBAction func logout(_ sender: Any) {
        PFUser.logOutInBackground { (error) in
            if error == nil {
                UserDefaults.standard.removeObject(forKey: "username")
                UserDefaults.standard.synchronize()
                
                let signin = self.storyboard?.instantiateViewController(withIdentifier: "signInVC") as! SignInVC
                let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = signin
            }
        }
    }
    
    //select a post then jump to that post view
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        postuuid.append(uuidArray[indexPath.row])
        
        let post = self.storyboard?.instantiateViewController(withIdentifier: "postVC") as! postVC
        self.navigationController?.pushViewController(post, animated: true)
    }
    
    // cell config
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! pictureCell
        
        //get picture form picarray
        picArray[indexPath.row].getDataInBackground(block: {(data:Data?, error:Error?) -> Void in
            if error == nil{
                cell.picImg.image = UIImage(data: data!)
            } else{
                print (error!.localizedDescription)
            }
        })
        
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    //head view config. Including count statics and load user information
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView{
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! headerView
        
        header.fullnameLbl.text = (PFUser.current()?.object(forKey: "fullname") as! String).uppercased()
        header.webTxt.text = PFUser.current()?.object(forKey: "web") as? String
        header.webTxt.sizeToFit()
        header.bioLbl.text = PFUser.current()?.object(forKey: "bio") as? String
        header.bioLbl.sizeToFit()
        header.button.setTitle("edit profile", for: UIControl.State())
        
        let avaQuery = PFUser.current()?.object(forKey: "ava") as! PFFile
        avaQuery.getDataInBackground(block: {(data:Data?, error:Error?) -> Void in
            header.avaImg.image = UIImage(data: data!)
        })
        
        //count posts
        let posts = PFQuery(className: "posts")
        posts.whereKey("username", equalTo: PFUser.current()!.username!)
        posts.countObjectsInBackground(block: {(count:Int32, error:Error?) -> Void in
            if error == nil {
                header.posts.text = "\(count)"
            }
        })
        
        //count followers
        let followers = PFQuery(className: "follow")
        followers.whereKey("following", equalTo: PFUser.current()!.username!)
        followers.countObjectsInBackground(block: {(count:Int32, error:Error?) -> Void in
            if error == nil {
                header.followers.text = "\(count)"
            }
        })
        
        //count following
        let followings = PFQuery(className: "follow")
        followings.whereKey("follower", equalTo: PFUser.current()!.username!)
        followings.countObjectsInBackground(block: {(count:Int32, error:Error?) -> Void in
            if error == nil {
                header.followings.text = "\(count)"
            }
        })
        
        //tap posts
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(homeVC.postsTap))
        postsTap.numberOfTapsRequired = 1
        header.posts.isUserInteractionEnabled = true
        header.posts.addGestureRecognizer(postsTap)
        
        //tap followers
        let followersTap  = UITapGestureRecognizer(target: self, action: #selector(homeVC.followersTap))
        followersTap.numberOfTapsRequired = 1
        header.followers.isUserInteractionEnabled = true
        header.followers.addGestureRecognizer(followersTap)
        
        //tap followings
        let followingsTap  = UITapGestureRecognizer(target: self, action: #selector(homeVC.followingsTap))
        followingsTap.numberOfTapsRequired = 1
        header.followings.isUserInteractionEnabled = true
        header.followings.addGestureRecognizer(followingsTap)
        
        return header
        
    }
}
