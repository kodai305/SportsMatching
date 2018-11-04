//
//  CustomCell.swift
//  SportsMatching
//
//  Created by user on 2018/08/08.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

    @IBOutlet weak var ImageView: UIImageView!
    

    @IBOutlet weak var TeamNameLabel: UILabel!
    @IBOutlet weak var CategoryLabel: UILabel!
    @IBOutlet weak var PlaceLabel: UILabel!
    @IBOutlet weak var GenderLabel: UILabel!
    @IBOutlet weak var DayLabel: UILabel!
    @IBOutlet weak var UpdatedTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // セルの幅を設定（高さはSearchResultViewで再設定される）
        self.frame.size.width = UIScreen.main.bounds.width
        self.layer.borderColor = UIColor(hex: "EBEDEF").cgColor
        self.layer.borderWidth = 10
        self.layer.cornerRadius = 15
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
