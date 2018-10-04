//
//  guestVC.swift
//  MobInstagram
//
//  Created by hha6027875 on 17/9/18.
//  Copyright © 2018 hha6027875. All rights reserved.
//

import UIKit
import Parse

//guest stack
var guest = [String]()

class guestVC: UICollectionViewController {

    //UI objects
    var refresher : UIRefreshControl?
    var page : Int = 10
    
    //
    var uuidArray = [String]()
    var picArray = [PFFile]()
    
    // default function
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.alwaysBounceVertical = true
        //top title
        self.navigationItem.title = guest.last
        
        // new back button
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(title: "back", style: .plain, target: self, action: #selector(guestVC.back))
        self.navigationItem.leftBarButtonItem = backBtn
        
        //swip to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(guestVC.back))
        backSwipe.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(backSwipe)
        
        // pull to refresh
        refresher = UIRefreshControl()
        refresher?.addTarget(self, action: #selector(guestVC.refresh), for: UIControl.Event.valueChanged)
        collectionView?.addSubview(refresher!)
        
        loadPosts()
        
        
        
    }
    
    @objc func back(sender: UIBarButtonItem){
        
        //push back
        self.navigationController?.popViewController(animated: true)
        
        //clean the last guest
        if !guest.isEmpty{
            guest.removeLast()
        }
        
    }
    
    @objc func refresh(){
        collectionView?.reloadData()
        refresher?.endRefreshing()
    }
    
    func loadPosts(){
        
        let query = PFQuery(className: "posts")
        query.whereKey("username", equalTo: guest.last!)
        query.limit = page
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                
                //clean up
                self.uuidArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                
                for object in objects!{
                    self.uuidArray.append(object.value(forKey: "uuid") as! String)
                    self.picArray.append(object.value(forKey: "pic") as! PFFile)
                }
                
                self.collectionView?.reloadData()
            }else {
                print(error!.localizedDescription)
            }
        }
    }
    
    //cell number
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    //cell config
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! pictureCell
        
        picArray[indexPath.row].getDataInBackground { (data, error) in
            if error == nil {
                cell.picImg.image = UIImage(data: data!)
            } else {
                print (error!.localizedDescription)
            }
        }
        return cell
    }
    
    //head config
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! headerView
        
        //step1 load data
        let infoQuery = PFQuery(className: "_User")
        infoQuery.whereKey("username", equalTo: guest.last!)
        infoQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                //shown wrong user
                if objects!.isEmpty{
                    print("wrong user")
                }
                
                for object in objects!{
                    header.fullnameLbl.text = (object.object(forKey: "fullname") as? String)?.uppercased()
                    header.bioLbl.text = object.object(forKey: "bio") as? String
                    header.bioLbl.sizeToFit()
                    header.webTxt.text = object.object(forKey: "web") as? String
                    header.webTxt.sizeToFit()
                    let avaFile : PFFile = (object.object(forKey: "ava") as? PFFile)!
                    avaFile.getDataInBackground(block: { (data, error) -> Void in
                        header.avaImg.image = UIImage(data: data!)
                    })
                }
            }else {
                print (error!.localizedDescription)
            }
        }
        
        //step2
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
        followQuery.whereKey("following", equalTo: guest.last!)
        followQuery.countObjectsInBackground { (count, error) in
            if error == nil {
                if count == 0 {
                    header.button.setTitle("FOLLOW", for: UIControl.State())
                    header.button.backgroundColor = .lightGray
                } else {
                    header.button.setTitle("FOLLOWING", for: UIControl.State())
                    header.button.backgroundColor = .green
                }
            } else {
                print (error!.localizedDescription)
            }
        }
        
        
        //step3 count number
        // count posts
        let posts = PFQuery(className: "posts")
        posts.whereKey("username", equalTo: guest.last!)
        posts.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                header.posts.text = "\(count)"
            } else {
                print(error?.localizedDescription ?? String())
            }
        })
        
        // count followers
        let followers = PFQuery(className: "follow")
        followers.whereKey("following", equalTo: guest.last!)
        followers.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                header.followers.text = "\(count)"
            } else {
                print(error?.localizedDescription ?? String())
            }
        })
        
        // count followings
        let followings = PFQuery(className: "follow")
        followings.whereKey("follower", equalTo: guest.last!)
        followings.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                header.followings.text = "\(count)"
            } else {
                print(error?.localizedDescription ?? String())
            }
        })
        
        //step4 implement gestures
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(guestVC.postsTap))
        postsTap.numberOfTapsRequired = 1
        header.posts.isUserInteractionEnabled = true
        header.posts.addGestureRecognizer(postsTap)
        
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(guestVC.followersTap))
        followersTap.numberOfTapsRequired = 1
        header.followers.isUserInteractionEnabled = true
        header.followers.addGestureRecognizer(followersTap)
        
        let followingsTap = UITapGestureRecognizer(target: self, action: #selector(guestVC.followingsTap))
        followingsTap.numberOfTapsRequired = 1
        header.followings.isUserInteractionEnabled = true
        header.followings.addGestureRecognizer(followingsTap)
        
        return header
    }
    
    @objc func postsTap(){
        if !picArray.isEmpty{
            let index = IndexPath(item: 0, section: 0)
            self.collectionView?.scrollToItem(at: index, at: UICollectionView.ScrollPosition.top, animated: true)
        }
    }
    
    @objc func followersTap(){
        user = guest.last!
        category = "followers"
        
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "followersVC") as! followersVC
        
        self.navigationController?.pushViewController(followers, animated: true)
        
    }
    
    @objc func followingsTap(){
        user = guest.last!
        category = "followings"
        
        let followings = self.storyboard?.instantiateViewController(withIdentifier: "followersVC") as! followersVC
        
        self.navigationController?.pushViewController(followings, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        postuuid.append(uuidArray[indexPath.row])
        
        let post = self.storyboard?.instantiateViewController(withIdentifier: "postVC") as! postVC
        self.navigationController?.pushViewController(post, animated: true)
    }
    
    

}
