//
//  Profile.swift
//  
//
//  Created by 高木広大 on 2018/09/09.
//

import Foundation

internal struct Profile: Codable {
    var UserName: String? = nil
    var Gender: String? = nil
    var Age: String? = nil
    var Level: String? = nil
    var Image: Data = Data()
    var Comments: String? = nil
}

