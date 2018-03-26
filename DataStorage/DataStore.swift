
import Foundation

public typealias StorableDictionary = [String: Any]

let kStorageDictionaryKey = "StorageDictionary"

public protocol Storable {
    
    static var typeName: String { get }
    
    var id: String? { get }
    
    func toDictionary() -> [String: Any]
    
    init(dictionary: StorableDictionary)
}

public protocol Downloadable {
    
    var id: String! { get }

    var fileName: String! { get }
    
    var fileURL: String! { get }
    
    var localFileURL: String? { get }
    
}

public protocol DataStore {
    
    func fetchEntity<T: Storable>(_ type: T.Type, id: String) -> Storable?
    
    func fetchAllEntities<T: Storable>(_ type: T.Type) -> [Storable]
    
    func fetchEntities<T: Storable>(_ type: T.Type, predicateOptional: NSPredicate?) -> [Storable]
    
    func storeEntity<T: Storable>(_ type: T.Type, entity: Storable)
    
    func storeEntities<T: Storable>(_ type: T.Type, entities: [Storable])
    
    func removeEntity<T: Storable>(_ type: T.Type, entity: Storable)
    
    func removeEntities<T: Storable>(_ type: T.Type, entities: [Storable])
    
    func synchronize()

    func removeAllObjects()
}

open class DataStoreImpl: DataStore {
    
    var storageDictionary: NSMutableDictionary
    
    var userDefaults: MOUserDefaults
    
    public init(userDefaults: MOUserDefaults) {
        
        self.userDefaults = userDefaults
        
        if let dictionary = self.userDefaults.dictionaryForKey(kStorageDictionaryKey) {
            
            storageDictionary = NSMutableDictionary(dictionary: dictionary)
            
        } else {
            
            storageDictionary = NSMutableDictionary()
            
        }
        
    }
    
    open func synchronize() {
        
        var dict = [String: AnyObject]()
        
        for (key, value) in self.storageDictionary {
            dict[key as! String] = value as AnyObject?
        }
        
        self.userDefaults.setDictionary(dict, forKey: kStorageDictionaryKey)
        
        _ = self.userDefaults.synchronize()
    }
    
    
    open func fetchEntity<T: Storable>(_ type: T.Type, id: String) -> Storable? {
        
        var item: Storable?
        
        let typeDictionary = dictionaryForType(type.typeName)
        
        
        if let object = typeDictionary[id] as? StorableDictionary {
            
            item = T(dictionary: object)
        }
        
        
        return item
    }
    
    open func fetchAllEntities<T: Storable>(_ type: T.Type) -> [Storable] {
        
        return fetchEntities(type, predicateOptional: nil)
    }
    
    open func fetchEntities<T: Storable>(_ type: T.Type, predicateOptional: NSPredicate?) -> [Storable] {
        
        return fetchAllEntities(type, predicateOptional: predicateOptional)
    }
    
    
    open func storeEntity<T: Storable>(_ type: T.Type, entity: Storable) {
        
        var typeDictionary = dictionaryForType(T.typeName)
        
        if let id = entity.id {
            
            let itemDictionary = entity.toDictionary()
            
            typeDictionary[id] = itemDictionary as AnyObject?
            
            self.storageDictionary.setValue(typeDictionary, forKey: type.typeName)
        }
    }
    
    open func storeEntities<T: Storable>(_ type: T.Type, entities: [Storable]) {
        
        var typeDictionary = dictionaryForType(T.typeName)
        
        entities.forEach({ (storable) -> () in
            
            if let id = storable.id {
                typeDictionary[id] = storable.toDictionary() as AnyObject?
            }
        })
        
        self.storageDictionary.setValue(typeDictionary, forKey: type.typeName)
    }
    
    open func removeEntity<T: Storable>(_ type: T.Type, entity: Storable) {
        
//        _ = dictionaryForType(T.typeName)
        
//        if let id = entity.id {
        
//            typeDictionary[id] = nil
            
//            self.storageDictionary.setValue(nil, forKey: type.typeName)
        
//        }
        
    }
    
    open func removeEntities<T: Storable>(_ type: T.Type, entities: [Storable]) {
    
    }
    
    open func removeAllObjects() {
        
        self.storageDictionary.removeAllObjects()
        
    }
    
    fileprivate func fetchAllEntities<T: Storable>(_ type: T.Type, predicateOptional: NSPredicate? = nil) -> [Storable] {
        
        var items = [Storable]()
        
        let typeDictionary = dictionaryForType(T.typeName)
        
        let filteredItems = typeDictionary.filter({ (id: String, value: AnyObject) -> Bool in
            
            var includeObject = true
            
            if let predicate = predicateOptional {
                includeObject = predicate.evaluate(with: value)
            }
            
            return includeObject
        })
        
        filteredItems.forEach({ (id: String, value: AnyObject) -> () in
            
            let objectDictionary = value as! [String: AnyObject]
            
            let item = T(dictionary: objectDictionary)
            
            items.append(item)
        })
        
        
        return items
    }
    
    func dictionaryForType(_ typeName: String) -> [String: AnyObject] {
        
        var typeDictionary: [String: AnyObject]! = self.storageDictionary.value(forKey: typeName) as? [String: AnyObject]
        
        if typeDictionary == nil {
            typeDictionary = [String: AnyObject]()
        }
        
        return typeDictionary
    }
}
