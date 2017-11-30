//
//  TestModels.swift
//  RxRealm
//
//  Created by Marin Todorov on 4/30/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import RealmSwift
import RxRealm

func realmInMemory(_ name: String = UUID().uuidString) -> Realm {
    var conf = Realm.Configuration()
    conf.inMemoryIdentifier = name
    return try! Realm(configuration: conf)
}

func stringifyChanges<E>(_ arg: (AnyRealmCollection<E>, RealmChangeset?)) -> String {
    let (result, changes) = arg
    if let changes = changes {
        return "count:\(result.count) inserted:\(changes.inserted) deleted:\(changes.deleted) updated:\(changes.updated)"
    } else {
        return "count:\(result.count)"
    }
}

//MARK: Message
class Message: Object {
    
    @objc dynamic var text = ""
    
    let recipients = List<User>()
    let mentions = LinkingObjects(fromType: User.self, property: "lastMessage")
    
    convenience init(_ text: String) {
        self.init()
        self.text = text
    }
}

extension Array where Element: Message {
    func equalTo(_ to: [Message]) -> Bool {
        guard count == to.count else {return false}
        let (result, _) = reduce((true, 0)) {acc, el in
            guard acc.0 && self[acc.1] == to[acc.1] else {return (false, 0)}
            return (true, acc.1+1)
        }
        return result
    }
}

func ==(lhs: Message, rhs: Message) -> Bool {
    return lhs.text == rhs.text
}

//MARK: User
class User: Object {
    @objc dynamic var name = ""
    @objc dynamic var lastMessage: Message?
    
    convenience init(_ name: String) {
        self.init()
        self.name = name
    }
}

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.name == rhs.name
}

//MARK: UniqueObject
class UniqueObject: Object {
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    
    convenience init(_ id: Int) {
        self.init()
        self.id = id
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

func ==(lhs: UniqueObject, rhs: UniqueObject) -> Bool {
    return lhs.id == rhs.id
}
