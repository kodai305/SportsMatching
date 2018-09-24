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
    var LatestMessage:UILabel!
    var LatestExchangeTime:UILabel!
    var PartnerImageView:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        PartnerNameLabel = UILabel(frame: CGRect.zero)
        PartnerNameLabel.textAlignment = .left
        self.contentView.addSubview(PartnerNameLabel)
        LatestMessage = UILabel(frame: CGRect.zero)
        LatestMessage.textAlignment = .left
        self.contentView.addSubview(LatestMessage)
        LatestExchangeTime = UILabel(frame: CGRect.zero)
        LatestExchangeTime.textAlignment = .left
        self.contentView.addSubview(LatestExchangeTime)
        PartnerImageView = UIImageView(frame: CGRect.zero)
        self.contentView.addSubview(PartnerImageView)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

}
