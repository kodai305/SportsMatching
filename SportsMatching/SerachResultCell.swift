//
//  CustomCell.swift
//  SportsMatching
//
//  Created by user on 2018/08/08.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit

class SerachResultCell: UITableViewCell {

    @IBOutlet weak var ImageView: UIImageView!
    
    @IBOutlet weak var TeamNameLabel: UILabel!
    @IBOutlet weak var PrefectureNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.frame.size.height = 150
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
