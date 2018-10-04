//
//  newsCell.swift
//  MobInstagram
//
//  Created by hha6027875 on 24/9/18.
//  Copyright © 2018 hha6027875. All rights reserved.
//

import UIKit

class newsCell: UITableViewCell {

    @IBOutlet var dateLbl: UILabel!
    @IBOutlet var infoLbl: UILabel!
    @IBOutlet var usernameBtn: UIButton!
    @IBOutlet var avaImg: UIImageView!
    @IBOutlet var followBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func followBtn_click(_ sender: Any) {
    }
}
