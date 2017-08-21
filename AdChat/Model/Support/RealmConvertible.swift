//
//  RealmObjectSupport.swift
//  Contacts
//
//  Created by ark dan on 23/07/2017.
//  Copyright © 2017 arkdan. All rights reserved.
//

import Foundation
import RealmSwift

class Object: RealmSwift.Object {
    dynamic var id: String = ""

    override class func primaryKey() -> String? {
        return "id"
    }
}

protocol RealmConvertible {

    associatedtype RealmObjectType: Object

    var id: String { get }

    func toObject() -> RealmObjectType
    init(object: RealmObjectType)
}

extension RealmConvertible {

    func persist() {
        let object = self.toObject()
        let realm = makeRealm()
        try! realm.write {
            realm.create(RealmObjectType.self, value: object, update: true)
        }
    }

    func unpersist() {
        let realm = makeRealm()

        // no need to delete in not persisted
        guard let managed = realm.object(ofType: RealmObjectType.self, forPrimaryKey: id) else {
            return
        }
        try! realm.write {
            realm.delete(managed)
        }
        unpersistRelationships()
    }

    // should be implemented by types with relationships.
    // Workaround until Realm supports cascade delete
    func unpersistRelationships() {
    }

    func managedObject() -> RealmObjectType {

        let realm = makeRealm()

        if let managed = realm.object(ofType: RealmObjectType.self, forPrimaryKey: self.id) {
            return managed
        }

        let object = toObject()

        var managed: RealmObjectType! = nil
        try! realm.write {
            managed = realm.create(RealmObjectType.self, value: object, update: true)
        }
        return managed
    }
}


extension RealmConvertible {

    typealias Realationship<T: RealmSwift.Object> = (RealmObjectType) -> List<T>

    func addValue<Model: RealmConvertible, DBModel>(_ value: Model, relationship: Realationship<DBModel>) where Model.RealmObjectType == DBModel {

        let object = value.managedObject()
        try! makeRealm().write {
            relationship(managedObject()).append(object)
        }
    }

    func addValues<Model: RealmConvertible, DBModel>(_ values: [Model], relationship: Realationship<DBModel>) where Model.RealmObjectType == DBModel {

        let objects = values.map { $0.managedObject() }
        try! makeRealm().write {
            relationship(managedObject()).append(objectsIn: objects)
        }
    }
}
