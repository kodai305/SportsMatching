//
//  PostDetail.swift
//  SportsMatching
//
//  Created by user on 2018/09/14.
//  Copyright © 2018年 iosearn. All rights reserved.
//

import Foundation


// 応募詳細の構造体
internal struct PostDetail: Codable {
    var PostedTime  : String? = nil
    var UpdateTime  : String? = nil
    var PostUser    : String? = nil
    var TeamName    : String? = nil
    var Category    : String? = nil
    var Prefecture  : String? = nil
    var Place       : String? = nil
    var ApplyGender : String? = nil
    var Timezone    : Array<String>? = nil
    var Image       : Data = Data()
    var Position    : Array<String>? = nil
    var ApplyLevel  : Array<String>? = nil
    var GenderRatio : String? = nil
    var TeamLevel   : String? = nil
    var NumMembers  : Int? = nil
    var Day         : Array<String>? = nil
    var MainAge     : Array<String>? = nil
    var Comments    : String? = nil
}
