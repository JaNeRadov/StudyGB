//
//  FriendsRealm.swift
//  Client
//
//  Created by Jane Z. on 16.01.2023.
//

import Foundation
import RealmSwift

class Friend: Object {
    @objc dynamic var userName: String = ""
    @objc dynamic var userAvatar: String  = ""
    @objc dynamic var ownerID: String  = ""
    
    init(userName:String, userAvatar:String, ownerID:String) {
        self.userName = userName
        self.userAvatar = userAvatar
        self.ownerID = ownerID
    }
    
    // этот инит обязателен для Object
    required init() {
        super.init()
    }
}
