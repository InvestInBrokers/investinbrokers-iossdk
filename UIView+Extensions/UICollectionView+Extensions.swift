import Foundation
import UIKit

extension UICollectionView {
    
    enum `Type` {
        case cell, header, footer
    }
    
    func register<T: UICollectionReusableView>(_ nib: T.Type, type: Type) where T: Reusable {
        
        switch type {
        case .cell:
        
            register(UINib(nibName: T.identifier, bundle: nil), forCellWithReuseIdentifier: T.identifier as String)

        case .header:
            
            register(UINib(nibName: T.identifier, bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: T.identifier)
            
        case .footer:

            register(UINib(nibName: T.identifier, bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: T.identifier)

        }

    }
    
    func registerClass<T: UICollectionReusableView>(_ aClass: T.Type, type: Type) where T: Reusable {
        
        switch type {
        case .cell:
        
            register(aClass, forCellWithReuseIdentifier: T.identifier as String)
        
        case .header:
        
            register(aClass, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                     withReuseIdentifier: T.identifier)
        case .footer:
    
            register(aClass, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                     withReuseIdentifier: T.identifier)
        
        }
    
    }

    func dequeueReusableClass<T: UICollectionReusableView>(_ aClass: T.Type,
                              forIndexPath indexPath: IndexPath, type: Type) -> T where T: Reusable {
        
        switch type {
        case .cell:
            
            return (dequeueReusableCell(withReuseIdentifier: T.identifier,
                                        for: indexPath) as? T)!
        case .header:
            
            return (dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                     withReuseIdentifier: T.identifier,
                                                     for: indexPath) as? T)!
        case .footer:
         
            return (dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter,
                                                     withReuseIdentifier: T.identifier,
                                                     for: indexPath) as? T)!
        }
    }
    
}
