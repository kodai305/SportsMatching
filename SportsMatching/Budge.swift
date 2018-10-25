//
//  Budge.swift
//  SportsMatching
//
//  Created by 高木広大 on 2018/10/14.
//  Copyright © 2018 iosearn. All rights reserved.
//

import Foundation

class Budge {
    func getTotalUnreadCount() -> (Int) {
        var unreadTotalCount = 0
        let defaults = UserDefaults.standard
        var myUID = ""
        if UserDefaults.standard.string(forKey: "UID") != nil {
            myUID = defaults.string(forKey: "UID")!
        }
        
        // 募集履歴を取得
        var _tmpRecruiteHistory:[String] = []
        if UserDefaults.standard.value(forKey: "RecruiteHistory") != nil {
            _tmpRecruiteHistory = UserDefaults.standard.value(forKey: "RecruiteHistory") as! [String]
        }
        for partnerID in _tmpRecruiteHistory {
            let roomID = myUID+"-"+partnerID
            let unreadCount = getUnreadCount(_roomID: roomID)
            if unreadCount > 0 {
                unreadTotalCount += unreadCount
            }
        }
        
        // 応募履歴の取得
        var _tmpApplyHistory:[String] = []
        if defaults.value(forKey: "ApplyHistory") != nil {
            _tmpApplyHistory = defaults.value(forKey: "ApplyHistory") as! [String]
        }
        for partnerID in _tmpApplyHistory {
            let roomID = partnerID+"-"+myUID
            let unreadCount = getUnreadCount(_roomID: roomID)
            if unreadCount > 0 {
                unreadTotalCount += unreadCount
            }
        }
        return unreadTotalCount
    }
    
    func getUnreadCount(_roomID: String) -> (Int) {
        var _unreadCount = 0
        let defaults = UserDefaults.standard
        // ルームIDが_roomIDの総メッセージ数を取得
        var _totalMessageCount = 0
        guard let tmpData = defaults.data(forKey: _roomID) else {
            // データがなかったら0を返す
            return 0
        }
        let _savedMessageInfoArray = try? JSONDecoder().decode([MessageInfo].self, from: tmpData)
        _totalMessageCount = _savedMessageInfoArray!.count
        // ルームIDが_roomIDの表示済みメッセージ数を取得
        let _key = "DisplayedNumber_"+_roomID
        let _displayedCount = defaults.integer(forKey: _key)
        // [未読数] = [メッセージ総数] - [表示済]
        _unreadCount = _totalMessageCount - _displayedCount
        
        return _unreadCount
    }
    
}
