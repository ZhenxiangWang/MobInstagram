//
//  commentCell.swift
//  MobInstagram
//
//  Created by Wenbin Chen on 20/9/18.
//  Copyright © 2018 Wenbin Chen. All rights reserved.
//

import UIKit

class commentCell: UITableViewCell {


    @IBOutlet var dateLbl: UILabel!
    @IBOutlet var commentLbl: UILabel!
    @IBOutlet var usernameBtn: UIButton!
    @IBOutlet var avaImg: UIImageView!
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
