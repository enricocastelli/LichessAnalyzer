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
    static let search = "search"
    static let lastDateBullet = "lastDateBullet"
    static let filters = "filters"
    static let lastDateDownload = "lastDateDownload"
    static let untilDateDownload = "untilDateDownload"

}


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

    func storeFilters(_ filter: Filter) {
        if let encoded = try? JSONEncoder().encode(filter) {
            UserDefaults.standard.set(encoded, forKey: StoreKeys.filters)
        }
    }

    func getfilters() -> Filter {
        if let data = UserDefaults.standard.object(forKey: StoreKeys.filters) as? Data {
            if let filters = try? JSONDecoder().decode(Filter.self, from: data) {
                return filters
            }
        }
        return Filter.empty
    }

    func storeSearch(_ filter: SearchItem) {
        if let encoded = try? JSONEncoder().encode(filter) {
            UserDefaults.standard.set(encoded, forKey: StoreKeys.search)
        }
    }

    func getSearch() -> SearchItem {
        if let data = UserDefaults.standard.object(forKey: StoreKeys.search) as? Data {
            if let filters = try? JSONDecoder().decode(SearchItem.self, from: data) {
                return filters
            }
        }
        return SearchItem(searchName: "", gameType: .all)
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


    func storeGames(_ games: [GameItem], gameType: GameType, success: @escaping () -> (),
                    failure: @escaping (Error) -> ()) {
        let context = getContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        GameItem.EntityName = "SavedGame_\(gameType)"
        do {
            let _ = games.map({ do { try $0.toCoreData(gameType: gameType, context: context)
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

    func getStoredGames(gameType: GameType, success: @escaping ([GameItem]) -> (),
                    failure: @escaping (Error) -> ()) {
        let context = getContext()
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "SavedGame_\(gameType)")
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

    func deleteGames(gameType: GameType, success: @escaping () -> (),
    failure: @escaping (Error) -> ()) {
        let context = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedGame_\(gameType)")
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

extension NSManagedObject {

    func toGame() -> GameItem {
        return GameItem(event: value(forKey: "event") as? String ?? "",
                        date: value(forKey: "date") as? String ?? "",
                        white: value(forKey: "white") as? String ?? "",
                        black: value(forKey: "black") as? String ?? "",
                        result: value(forKey: "result") as? String ?? "",
                        termination: value(forKey: "termination")  as? String ?? "",
                        openingString: value(forKey: "openingString") as? String ?? "",
                        pgn: value(forKey: "pgn") as? String ?? "",
                        eco: value(forKey: "eco") as? String ?? "")
    }
}

protocol StructDecoder {
    // The name of our Core Data Entity
    static var EntityName: String { get set }
    // Return an NSManagedObject with our properties set
    func toCoreData(gameType: GameType, context: NSManagedObjectContext) throws
}

extension StructDecoder {
    func toCoreData(gameType: GameType, context: NSManagedObjectContext) throws {
        let entityName = type(of: self).EntityName

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
