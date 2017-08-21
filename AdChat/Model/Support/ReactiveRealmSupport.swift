//
//  RealmSupport.swift
//  Contacts
//
//  Created by ark dan on 25/07/2017.
//  Copyright © 2017 arkdan. All rights reserved.
//

import Foundation
import RealmSwift

import ReactiveSwift
import Result

import Extensions

extension Realm {

    func observeObjectsResult<T: RealmSwift.Object>(ofType objectType: T.Type) -> SignalProducer<Results<T>, NoError> {

        return SignalProducer { observer, lifetime in
            let collection: Results<T> = self.objects(objectType)

            let token = collection.addNotificationBlock { changeset in

                switch changeset {
                case .initial(let latestValue):
                    observer.send(value: latestValue)
                case .update(let latestValue, let deletions, let insertions, let modifications):
                    print("latest \(latestValue.count) del \(deletions.count) ins \(insertions.count) mod \(modifications.count)")
                    observer.send(value: latestValue)
                case .error:
                    break
                }
            }

            lifetime.observeEnded {
                print("** ended")
                token.stop()
            }
            
        }
    }

    func observeObjects<T: RealmSwift.Object>(ofType objectType: T.Type) -> SignalProducer<[T], NoError> {

        return SignalProducer { observer, lifetime in
            let collection: Results<T> = self.objects(objectType)

            let token = collection.addNotificationBlock { changeset in

                switch changeset {
                case .initial(let latestValue):
                    observer.send(value: latestValue.map { $0 })
                case .update(let latestValue, _, _, _):
                    observer.send(value: latestValue.map { $0 })
                case .error:
                    break
                }
            }

            lifetime.observeEnded {
                token.stop()
            }
            
        }
    }

}

extension RealmSwift.Results {
    func signalProducer() -> SignalProducer<[T], NoError> {
        return SignalProducer { observer, lifetime in

            let token = self.addNotificationBlock { changeset in
                switch changeset {
                case .initial(let latestValue):
                    observer.send(value: latestValue.map { $0 })
                case .update(let latestValue, _, _, _):
                    observer.send(value: latestValue.map { $0 })
                case .error:
                    break
                }
            }

            lifetime.observeEnded {
                token.stop()
            }
        }
    }

    func valueAdded() -> Signal<T, NoError> {
        let (signal, observer) = Signal<T, NoError>.pipe()

        let token = addNotificationBlock { changeset in
            switch changeset {
            case .update(_, _, let insertions, _):
                insertions.forEach { observer.send(value: self[$0]) }
            default:
                break
            }
        }

        signal.observeCompleted { token.stop() }
        signal.observeInterrupted { token.stop() }

        return signal
    }
}

extension RealmSwift.List {
    func signalProducer() -> SignalProducer<[Element], NoError> {
        
        return SignalProducer { observer, lifetime in
            let token = self.addNotificationBlock { changeset in
                switch changeset {
                case .initial(let latestValue):
                    observer.send(value: latestValue.map { $0 })
                case .update(let latestValue, _, _, _):
                    observer.send(value: latestValue.map { $0 })
                case .error:
                    break
                }
            }
            lifetime.observeEnded {
                token.stop()
            }
        }
    }

    func valueAdded() -> Signal<(T, Int), NoError> {
        let (signal, observer) = Signal<(T, Int), NoError>.pipe()

        let token = addNotificationBlock { changeset in
            switch changeset {
            case .update(_, _, let insertions, _):
                insertions.forEach { observer.send(value: (self[$0], $0)) }
            default:
                break
            }
        }

        signal.observeCompleted { token.stop() }
        signal.observeInterrupted { token.stop() }

        return signal
    }
}

extension SignalProducer where Value: Sequence, Value.Iterator.Element: AdChat.Object {
    func toModelArray<Model: RealmConvertible>(_ type: Model.Type) -> SignalProducer<[Model], Error>
        where Value == [Model.RealmObjectType] {
            return map { $0.map { Model(object: $0) } }
    }
}

extension SignalProducer where Value == AdChat.Object {
    func toModel<Model: RealmConvertible>() -> SignalProducer<Model, Error>
        where Model.RealmObjectType == Value {
            return map { Model(object: $0) }
    }
}
