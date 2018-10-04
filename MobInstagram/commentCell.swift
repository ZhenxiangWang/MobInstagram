//
//  commentCell.swift
//  MobInstagram
//
//  Created by hha6027875 on 20/9/18.
//  Copyright © 2018 hha6027875. All rights reserved.
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
