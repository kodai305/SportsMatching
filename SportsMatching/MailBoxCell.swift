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
    // 未読数をLINE風に表示する
    // Labelだと上手く丸にならないのでButtonで代用
    var UnReadCountBadge:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.frame.size.width = UIScreen.main.bounds.width
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
        UnReadCountBadge = UIButton(frame: CGRect.zero)
        self.contentView.addSubview(UnReadCountBadge)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

}
