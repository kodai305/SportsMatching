//
//  SearchMailBoxCell.swift
//  SportsMatching
//
//  Created by user on 2018/08/23.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import UIKit

class MailBoxCell: UITableViewCell {

    var PartnerNameLabel:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        PartnerNameLabel = UILabel(frame: CGRect.zero)
        PartnerNameLabel.textAlignment = .left
        self.contentView.addSubview(PartnerNameLabel)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        PartnerNameLabel.frame = CGRect(x: 10, y: 0, width: frame.width - 100, height: frame.height)
        PartnerNameLabel.adjustsFontSizeToFitWidth = true
    }

}
