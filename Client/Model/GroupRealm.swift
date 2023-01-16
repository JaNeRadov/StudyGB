//
//  GroupRealm.swift
//  Client
//
//  Created by Jane Z. on 16.01.2023.
//

import Foundation
import RealmSwift

class Group: Object {
    @objc dynamic var groupName: String = ""
    @objc dynamic var groupLogo: String  = ""
    @objc dynamic var id: Int  = 0
    
    init(groupName: String, groupLogo: String, id: Int) {
        self.groupName = groupName
        self.groupLogo = groupLogo
        self.id = id
    }
    
    // этот инит обязателен для Object
    required override init() {
        super.init()
    }
    
    // в классе типа Object не нужно (можно сравнить по дескрипшину)
    // для проведения сравнения (.contains), только по имени
//    static func ==(lhs: Group, rhs: Group) -> Bool {
//        return lhs.groupName == rhs.groupName //&& lhs.groupLogo == rhs.groupLogo
//    }
}
