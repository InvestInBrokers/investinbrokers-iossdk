import Foundation
import CoreData

public protocol DataSourceProvider {
    
    associatedtype DataSourceDelegate: DataSourceProviderDelegate
    
    associatedtype ItemType
    
    var delegate: DataSourceDelegate? { get set }

    func isEmpty() -> Bool
    
    func numberOfSections() -> Int
    
    func numberOfRowsInSection(_ section: Int) -> Int
    
    func itemAtIndexPath(_ indexPath: IndexPath) -> ItemType
    
    mutating func deleteItemAtIndexPath(_ indexPath: IndexPath)
    
    mutating func insertItem(_ item: ItemType, atIndexPath: IndexPath)
    
    mutating func updateItem(_ item: ItemType, atIndexPath: IndexPath)
 
    mutating func deleteAllInSection(_ section: Int)
    
    func titleForHeaderAtSection(_ section: Int) -> String?
    
}

public protocol DataSourceProviderDelegate {
    
    associatedtype ItemType
    
    mutating func providerWillChangeContent()
    
    mutating func providerDidEndChangeContent()
    
    mutating func providerDidInsertSectionAtIndex(_ index: Int)
    
    mutating func providerDidDeleteSectionAtIndex(_ index: Int)
    
    mutating func providerDidInsertItemsAtIndexPaths(_ items: [ItemType], atIndexPaths: [IndexPath])
    
    mutating func providerDidDeleteItemsAtIndexPaths(_ items: [ItemType], atIndexPaths: [IndexPath])
    
    mutating func providerDidUpdateItemsAtIndexPaths(_ items: [ItemType], atIndexPaths: [IndexPath])
    
    mutating func providerDidMoveItem(_ item: ItemType, atIndexPath: IndexPath, toIndexPath: IndexPath)
    
    mutating func providerDidDeleteAllItemsInSection(_ section: Int)
}


open class ArrayDataSourceProvider<T, Delegate: DataSourceProviderDelegate>: DataSourceProvider where Delegate.ItemType == T {
    
    open var delegate: Delegate?

    var arrayItems: [T]
    
    fileprivate var objectChanges: Array<(DataSourceChangeType,[IndexPath], [T])>!
    fileprivate var sectionChanges: Array<(DataSourceChangeType,Int)>!
    
    public init() {
        
        self.objectChanges = Array()
        self.sectionChanges = Array()

        arrayItems = [T]()
    }
    
    open func isEmpty() -> Bool {
        
        return arrayItems.isEmpty
    }
    
    open func numberOfSections() -> Int {
        
        return 1
    }
    
    open func numberOfRowsInSection(_ section: Int) -> Int {
        
        return arrayItems.count
    }
    
    open func itemAtIndexPath(_ indexPath: IndexPath) -> T {
        
        return arrayItems[(indexPath as NSIndexPath).row]
    }
    
    open func deleteItemAtIndexPath(_ indexPath: IndexPath) {
        
        let item = arrayItems[(indexPath as NSIndexPath).row]
        
        arrayItems.remove(at: (indexPath as NSIndexPath).row)
        
        delegate?.providerDidDeleteItemsAtIndexPaths([item], atIndexPaths: [indexPath])
    }

    open func insertItem(_ item: T, atIndexPath indexPath: IndexPath) {
        
        arrayItems.insert(item, at: (indexPath as NSIndexPath).row)
        
        delegate?.providerDidInsertItemsAtIndexPaths([item], atIndexPaths: [indexPath])
        
    }
    
    open func updateItem(_ item: T, atIndexPath indexPath: IndexPath) {
        
        var newItems = [T](arrayItems)
    
        newItems.remove(at: (indexPath as NSIndexPath).row)
        
        newItems.insert(item, at: (indexPath as NSIndexPath).row)
        
        self.arrayItems = newItems
        
        delegate?.providerDidUpdateItemsAtIndexPaths([item], atIndexPaths: [indexPath])

    }
    
    open func deleteAllInSection(_ section: Int) {

        arrayItems.removeAll()
        
        delegate?.providerDidDeleteAllItemsInSection(0)
    }
    
    open func batchUpdates(_ updatesBlock: VoidCompletion) {
        
        objc_sync_enter(self)
        
        delegate?.providerWillChangeContent()
        
        updatesBlock()
        
        delegate?.providerDidEndChangeContent()

        objc_sync_exit(self)

    }
    
    open func titleForHeaderAtSection(_ section: Int) -> String? {
        return nil
    }
    
    open func itemsArray() -> [T] {
        
        return arrayItems
        
    }
}

open class FetchedResultsDataSourceProvider<ObjectType: NSManagedObject, Delegate: DataSourceProviderDelegate> : DataSourceProvider where Delegate.ItemType == ObjectType {
    
    open var delegate: Delegate? { didSet {
        
            fetchedResultsControllerDelegate = FetchedResultsControllerDelegate<ObjectType, Delegate>(delegate: delegate!)
        
            fetchedResultsController.delegate = fetchedResultsControllerDelegate
        }
    
    }
    
    let fetchedResultsController: NSFetchedResultsController<ObjectType>
    
    var fetchedResultsControllerDelegate: FetchedResultsControllerDelegate<ObjectType, Delegate>?
    
    public init(fetchedResultsController: NSFetchedResultsController<ObjectType>) {
        
        self.fetchedResultsController = fetchedResultsController
    
    }
    
    open func isEmpty() -> Bool {
        
        var empty = true
        
        if let count = self.fetchedResultsController.fetchedObjects?.count {
            empty = (count == 0)
        }
        
        return empty
    
    }
    
    open func numberOfSections() -> Int {
        
        return self.fetchedResultsController.sections?.count ?? 0
    
    }
    
    open func numberOfRowsInSection(_ section: Int) -> Int {
        
        let sectionInfo = self.fetchedResultsController.sections![section]
    
        return sectionInfo.numberOfObjects
    
    }
    
    open func itemAtIndexPath(_ indexPath: IndexPath) -> ObjectType {
        
        return self.fetchedResultsController.object(at: indexPath)
    
    }
    
    open func deleteItemAtIndexPath(_ indexPath: IndexPath) {
        
        let context = self.fetchedResultsController.managedObjectContext
        
        context.delete(self.fetchedResultsController.object(at: indexPath))
        
        do {
            try context.save()
        } catch _ {}
    
    }
    
    open func insertItem(_ item: ObjectType, atIndexPath: IndexPath) {
        
        let context = self.fetchedResultsController.managedObjectContext
        
        context.insert(item)
        
        do {
        
            try context.save()
    
        } catch _ {}
  
    }
    
    open func updateItem(_ item: ObjectType, atIndexPath: IndexPath) {
        
        let context = self.fetchedResultsController.managedObjectContext
        
        //MARK: TODO update the item here
        do {
    
            try context.save()
    
        } catch _ {}
    
    }
    
    open func deleteAllInSection(_ section: Int) {
        
        let context = self.fetchedResultsController.managedObjectContext

        let sectionInfo = self.fetchedResultsController.sections![section]

        if let objects = sectionInfo.objects {

            for object in objects {
        
                context.delete(object as! NSManagedObject)
            }
        }
    }
    
    open func titleForHeaderAtSection(_ section: Int) -> String? {
        
        return self.fetchedResultsController.sections?[section].name
   
    }

}


class FetchedResultsControllerDelegate<ObjectType: NSManagedObject, Delegate: DataSourceProviderDelegate>: NSObject, NSFetchedResultsControllerDelegate where Delegate.ItemType == ObjectType {
    
    var delegate: Delegate
    
    init(delegate: Delegate) {
        
        self.delegate = delegate
  
    }
    
    // MARK: - Fetched results controller
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
     
        self.delegate.providerWillChangeContent()
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
            
        case .insert:
            self.delegate.providerDidInsertSectionAtIndex(sectionIndex)
            
        case .delete:
            self.delegate.providerDidDeleteSectionAtIndex(sectionIndex)
            
        default:
            return
        }
   
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        let obj = anObject as! ObjectType

        switch type {
            
        case .insert:
            
            
            self.delegate.providerDidInsertItemsAtIndexPaths([obj], atIndexPaths: [newIndexPath!])
            
        case .delete:
            
            self.delegate.providerDidDeleteItemsAtIndexPaths([obj], atIndexPaths: [indexPath!])
            
        case .update:
            
            self.delegate.providerDidUpdateItemsAtIndexPaths([obj], atIndexPaths: [indexPath!])
            
        case .move:
            
            if let initiaIndexPath = indexPath, let finalIndexPath = newIndexPath {
            
                if initiaIndexPath != finalIndexPath {
               
                    self.delegate.providerDidMoveItem(anObject as! ObjectType, atIndexPath: indexPath!, toIndexPath: newIndexPath!)
             
                }
            
            }
        
        }
    
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        self.delegate.providerDidEndChangeContent()
    
    }
    
}

