//
//  MessageInfo.swift
//  SportsMatching
//
//  Created by 高木広大 on 2018/09/09.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import Foundation

internal struct MessageInfo: Codable {
    var message: String = ""
    var senderID: String = ""
    var sentDate: Date = Date()
    var kind: String = ""
}
