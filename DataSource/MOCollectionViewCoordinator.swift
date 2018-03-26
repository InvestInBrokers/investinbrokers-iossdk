import Foundation
import UIKit

enum DataSourceChangeType {
    
    case insert
    case delete
    case move
    case update

}

open class DataSourceProviderCollectionViewAdapter<ItemType>: DataSourceProviderDelegate {
    
    var collectionView: UICollectionView?
  
    fileprivate var objectChanges: Array<(DataSourceChangeType,[IndexPath])>!
    fileprivate var sectionChanges: Array<(DataSourceChangeType,Int)>!
    
    
    init(collectionView: UICollectionView) {
        
        self.collectionView = collectionView
        self.objectChanges = Array()
        self.sectionChanges = Array()

    }
    
    //MARK:  conformance to the DataSourceProviderDelegate
    open func providerWillChangeContent() {
        
    }
    
    open func providerDidEndChangeContent() {
        
        if sectionChanges.count > 0 {
            
            collectionView?.performBatchUpdates( {  () -> Void in
                
                for (type, obj) in self.sectionChanges {
                    
                    let set = IndexSet(integer: obj)
                    
                    switch (type) {
                        
                    case .insert:
                        
                        self.collectionView?.insertSections(set)
                        break
                        
                    case .delete:
                        
                        self.collectionView?.deleteSections(set)
                        break
                        
                    case .update:
                        
                        self.collectionView?.reloadSections(set)
                        break
                        
                    default:
                        break
                    }
                }
                }, completion: { (_) -> Void in
                    
                    
            })
        }
        
        if self.objectChanges.count > 0 && self.sectionChanges.count == 0 {
            
            let shouldReload = shouldReloadCollectionViewToPreventKnownIssue()
            
            if shouldReload || self.collectionView?.window == nil {
                // This is to prevent a bug in UICollectionView from occurring.
                // The bug presents itself when inserting the first object or deleting the last object in a collection view.
                // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
                // This code should be removed once the bug has been fixed, it is tracked in OpenRadar
                // http://openradar.appspot.com/12954582
                self.collectionView?.reloadData()
                
            } else {
                
                self.collectionView?.performBatchUpdates({ () -> Void in
                    
                    for (type, obj) in self.objectChanges {
                        
                        switch type {
                            
                        case .insert:
                            
                            self.collectionView?.insertItems(at: obj)
                            
                        case .delete:
                            
                            self.collectionView?.deleteItems(at: obj)
                            
                        case .update:
                            
                            self.collectionView?.reloadItems(at: obj)
                            
                        case .move:
                            
                            let oldIndexPath = obj.first
                            let newIndexPath = obj.last
                            
                            self.collectionView?.moveItem(at: oldIndexPath!, to: newIndexPath!)
                        }
                    }
                    }, completion: { (_) -> Void in
                        
                })
            }
        }
        
        self.sectionChanges.removeAll(keepingCapacity: true)
        self.objectChanges.removeAll(keepingCapacity: true)
    }
    
    
    open func providerDidInsertSectionAtIndex(_ index: Int) {
        
        let change = (DataSourceChangeType.insert, index)
        
        sectionChanges.append(change)
    }
    
    open func providerDidDeleteSectionAtIndex(_ index: Int) {
        
        let change = (DataSourceChangeType.delete, index)
        
        sectionChanges.append(change)
    }
    
    
    open func providerDidInsertItemsAtIndexPaths(_ items: [ItemType], atIndexPaths: [IndexPath]) {

        updateWithItemChange(.insert, indexPaths: atIndexPaths)
    }
    
    open func providerDidDeleteItemsAtIndexPaths(_ items: [ItemType], atIndexPaths: [IndexPath]) {

        
        updateWithItemChange(.delete, indexPaths: atIndexPaths)
    }
    
    open func providerDidUpdateItemsAtIndexPaths(_ items: [ItemType], atIndexPaths indexPaths: [IndexPath]) {
        
        updateWithItemChange(.update, indexPaths: indexPaths)
    }
    
    open func providerDidMoveItem(_ item: ItemType, atIndexPath: IndexPath, toIndexPath: IndexPath) {
        
        self.collectionView?.moveItem(at: atIndexPath, to: toIndexPath)
    }
    
    open func providerDidDeleteAllItemsInSection(_ section: Int) {
        
        let indexSet = IndexSet(integer: section)
        
        self.collectionView?.reloadSections(indexSet)
    }
    
    
    fileprivate func updateWithItemChange(_ type: DataSourceChangeType, indexPaths: [IndexPath]) {
            
        let change = (type, indexPaths)
            
        objectChanges.append(change)
    }
    
    fileprivate func handleObjectChanges() {
        
        
        if self.objectChanges.count > 0 && self.sectionChanges.count == 0 {
            
            let shouldReload = shouldReloadCollectionViewToPreventKnownIssue()
            
            if shouldReload || self.collectionView?.window == nil {
                // This is to prevent a bug in UICollectionView from occurring.
                // The bug presents itself when inserting the first object or deleting the last object in a collection view.
                // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
                // This code should be removed once the bug has been fixed, it is tracked in OpenRadar
                // http://openradar.appspot.com/12954582
                self.collectionView?.reloadData()
                
            } else {
                
                self.collectionView?.performBatchUpdates({ () -> Void in
                    
                    for (type, obj) in self.objectChanges {
                        
                        switch type {
                            
                        case .insert:
                            
                            self.collectionView?.insertItems(at: obj)
                            
                        case .delete:
                            
                            self.collectionView?.deleteItems(at: obj)
                            
                        case .update:
                            
                            self.collectionView?.reloadItems(at: obj)
                            
                        case .move:
                            
                            let oldIndexPath = obj.first
                            let newIndexPath = obj.last
                            
                            self.collectionView?.moveItem(at: oldIndexPath!, to: newIndexPath!)
                        }
                    }
                    }, completion: { (_) -> Void in
                        
                })
            }
        }
        
        self.sectionChanges.removeAll(keepingCapacity: true)
        self.objectChanges.removeAll(keepingCapacity: true)
    }
    
    open func shouldReloadCollectionViewToPreventKnownIssue() -> Bool {
        
        var shouldReload: Bool = false
        
        for (type, obj) in self.objectChanges {
            
            let indexPaths = obj
            
            switch type {
                
            case .insert:
                
                let indexPath = indexPaths.first
                
                if self.collectionView?.numberOfItems(inSection: (indexPath! as NSIndexPath).section) == 0 {
                    
                    shouldReload = true
                    
                } else {
                    
                    shouldReload = false
                }
                break
                
            case .delete:
                
                let indexPath = indexPaths.first
                
                if self.collectionView?.numberOfItems(inSection: (indexPath! as NSIndexPath).section) == 1 {
                    
                    shouldReload = true
                } else {
                    
                    shouldReload = false
                }
                break
                
            case .update:
                shouldReload = false
                break
                
            case .move:
                shouldReload = false
                break
            }
            
        }
        
        return shouldReload
    }
}

@objc public protocol CollectionViewCellProvider {
    
    func collectionView(_ collectionView: UICollectionView, cellForRowAtIndexPath indexPath: IndexPath) -> UICollectionViewCell
    
    @objc optional func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: IndexPath) -> UICollectionReusableView
    
    @objc optional func collectionView(_ collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: IndexPath) -> Bool
    

}


open class CollectionViewCoordinator<CollectionType, DataSource: DataSourceProvider> : NSObject, UICollectionViewDataSource where DataSource.ItemType == CollectionType, DataSource.DataSourceDelegate == DataSourceProviderCollectionViewAdapter<CollectionType> {
    
    let collectionView: UICollectionView
    
    var dataSource: DataSource
    
    var dataSourceProviderCollectionViewAdapter: DataSourceProviderCollectionViewAdapter<CollectionType>
    
    let collectionViewCellProvider: CollectionViewCellProvider
    
    
    public init(collectionView: UICollectionView, dataSource: DataSource, cellProvider: CollectionViewCellProvider) {
        
        self.collectionView = collectionView
        self.dataSource = dataSource
        self.collectionViewCellProvider = cellProvider
        self.dataSourceProviderCollectionViewAdapter = DataSourceProviderCollectionViewAdapter<CollectionType>(collectionView: collectionView)
        
        super.init()
        
        self.collectionView.dataSource = self
        self.dataSource.delegate = self.dataSourceProviderCollectionViewAdapter
    }
    
    // MARK: - Collection View Datasource
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return self.dataSource.numberOfSections()
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.dataSource.numberOfRowsInSection(section) 
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        return collectionViewCellProvider.collectionView(collectionView, cellForRowAtIndexPath: indexPath)
    }
    
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        return (collectionViewCellProvider.collectionView?(collectionView, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath))!
    }
    
    open func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        
        return (collectionViewCellProvider.collectionView?(collectionView, canMoveItemAtIndexPath: indexPath))!
    }
 
    open func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let item = self.dataSource.itemAtIndexPath(sourceIndexPath)
        
        self.dataSource.insertItem(item, atIndexPath: destinationIndexPath)
        
        self.dataSource.deleteItemAtIndexPath(sourceIndexPath)
    }

}

open class CollectionViewCoordinatorWithItemCountLimit<CollectionType, DataSource: DataSourceProvider>: CollectionViewCoordinator<CollectionType, DataSource> where DataSource.ItemType == CollectionType, DataSource.DataSourceDelegate == DataSourceProviderCollectionViewAdapter<CollectionType> {
    
    let itemCountLimit: Int
    
    public init(collectionView: UICollectionView, dataSource: DataSource, itemCountLimit: Int, cellProvider: CollectionViewCellProvider) {
        
        self.itemCountLimit = itemCountLimit

        super.init(collectionView: collectionView, dataSource: dataSource, cellProvider: cellProvider)
        
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return dataSource.numberOfRowsInSection(section) > itemCountLimit ? itemCountLimit : dataSource.numberOfRowsInSection(section)

    }
    
}
