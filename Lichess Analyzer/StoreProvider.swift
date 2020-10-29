//
//  StoreProvider.swift
//  Lichess Analyzer
//
//  Created by Enrico Castelli on 25/10/2020.
//

import UIKit
import CoreData

enum StoreKeys {
    static let isFirstTime = "isFirstTime"
    static let name = "name"
    static let refreshToken = "refreshToken"
    static let gamesBullet = "gamesBullet"
    static let lastDateBullet = "lastDateBullet"
    static let preferredSorting = "preferredSorting"
    static let lastDateDownload = "lastDateDownload"
    static let untilDateDownload = "untilDateDownload"

}

fileprivate var coreGames: [NSManagedObject] = []


protocol StoreProvider {}

extension StoreProvider {

    func storeFirstTime() {
        UserDefaults.standard.set(false, forKey: StoreKeys.isFirstTime)
    }

    func isFirstTime() ->  Bool {
//        if isSimulator() { return true }
        if let _ = UserDefaults.standard.object(forKey: StoreKeys.isFirstTime) as? Bool {
            return false
        } else {
            return true
        }
    }

    func storeName(_ name: String) {
        UserDefaults.standard.set(name, forKey: StoreKeys.name)
    }

    func getName() -> String? {
        return UserDefaults.standard.object(forKey: StoreKeys.name) as? String
    }


    func storeRefreshToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: StoreKeys.refreshToken)
    }

    func getRefreshToken() -> String? {
        return UserDefaults.standard.object(forKey: StoreKeys.refreshToken) as? String
    }

    func deleteRefreshToken() {
        UserDefaults.standard.removeObject(forKey: StoreKeys.refreshToken)
    }

    func storePreferredSorting(_ sorting: GamesSorting) {
        UserDefaults.standard.set(sorting.rawValue, forKey: StoreKeys.preferredSorting)
    }

    func getPreferredSorting() -> GamesSorting {
        if let preferred = UserDefaults.standard.object(forKey: StoreKeys.preferredSorting) as? String, let sort = GamesSorting(rawValue: preferred) {
            return sort
        }
        return GamesSorting.mostPlayed
    }

    func storeLastDate(_ date: String) {
        UserDefaults.standard.set(date, forKey: StoreKeys.lastDateDownload)
    }

    func getLastDate() -> String? {
        return UserDefaults.standard.object(forKey: StoreKeys.lastDateDownload) as? String
    }

    func storeFirstDate(_ date: String) {
        UserDefaults.standard.set(date, forKey: StoreKeys.untilDateDownload)
    }

    func getFirstDate() -> String? {
        return UserDefaults.standard.object(forKey: StoreKeys.untilDateDownload) as? String
    }

    func storeGames(_ games: [GameItem], success: @escaping () -> (),
                    failure: @escaping (Error) -> ()) {
        let context = getContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        let source = Testest(grouping: games, by: { $0.opening })


        do {
            let _ = games.map({ do { try $0.toCoreData(context: context)
            } catch let error {
                Logger.error(error)
                failure(error)
            }})
            try context.save()
            success()
        } catch let error as NSError {
            Logger.error(error)
            failure(error)
        }
    }

    func storeTest(_ games: [GameItem], success: @escaping () -> (),
                   failure: @escaping (Error) -> ()) {
        let context = getContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        let source = Testest(grouping: games, by: { $0.opening })
        do {
            try source.toCoreData(context: context)
            try context.save()
            success()
        } catch let error  {
            Logger.error(error)
            failure(error)
        }
    }

    func getStoredGames(success: @escaping ([GameItem]) -> (),
                    failure: @escaping (Error) -> ()) {
        let context = getContext()
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "SavedGame")
        let dateSort = NSSortDescriptor(key:"date", ascending:true)
        fetchRequest.sortDescriptors = [dateSort]
        do {
            let games = try context.fetch(fetchRequest)
            guard games.count > 0 else {
                failure(SerializationError.empty)
                return }
            success(games.map({ $0.toGame() }))
        } catch let error as NSError {
            Logger.error(error)
            failure(error)
        }
    }

    func deleteGames(success: @escaping () -> (),
    failure: @escaping (Error) -> ()) {
        let context = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedGame")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                context.delete(objectData)
            }
            success()
        } catch let error {
            Logger.error(error)
            failure(error)
        }
    }

    private func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
}

typealias Testest = [KnownOpening: [GameItem]]

extension Testest: StructDecoder {

    static var EntityName: String = "OpeningTest"

}

extension NSManagedObject {

    func toGame() -> GameItem {
        return GameItem(event: value(forKey: "event") as? String ?? "",
                        date: value(forKey: "date") as? String ?? "",
                        white: value(forKey: "white") as? String ?? "",
                        black: value(forKey: "black") as? String ?? "",
                        result: value(forKey: "result") as? String ?? "",
                        termination: value(forKey: "termination")  as? String ?? "",
                        completeOpening: value(forKey: "completeOpening") as? String ?? "",
                        pgn: value(forKey: "pgn") as? String ?? "",
                        eco: value(forKey: "eco") as? String ?? "")
    }
}

protocol StructDecoder {
    // The name of our Core Data Entity
    static var EntityName: String { get }
    // Return an NSManagedObject with our properties set
    func toCoreData(context: NSManagedObjectContext) throws -> NSManagedObject
}

extension StructDecoder {
    func toCoreData(context: NSManagedObjectContext) throws -> NSManagedObject {
        let entityName = type(of:self).EntityName

        // Create the Entity Description
        guard let desc = NSEntityDescription.entity(forEntityName: entityName, in: context)
        else { throw SerializationError.unknownEntity(name: entityName) }

        // Create the NSManagedObject
        let managedObject = NSManagedObject(entity: desc, insertInto: context)

        // Create a Mirror
        let mirror = Mirror(reflecting: self)

        // Make sure we're analyzing a struct
        guard mirror.displayStyle == .struct else { throw SerializationError.structRequired }

        for case let (label?, anyValue) in mirror.children {
            managedObject.setValue(anyValue, forKey: label)
        }

        return managedObject
    }
}

enum SerializationError: Error {
    // We only support structs
    case structRequired
    // The entity does not exist in the Core Data Model
    case unknownEntity(name: String)
    // The provided type cannot be stored in core data
    case unsupportedSubType(label: String?)
    case empty

}
