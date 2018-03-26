import Foundation
import Arcane

let kDefaultsKey = "Defaults"
let kSecureDefaultsKey = "SecureDefaults"

var defaultsDictionary: NSMutableDictionary! = nil

var secureItemsDictionary: NSMutableDictionary! = nil

public struct UserDefaultsImpl: MOUserDefaults {

    public init() {
        
        if(defaultsDictionary == nil) {
            
            let dictionary = UserDefaults.standard.dictionary(forKey: kDefaultsKey)
            
            if dictionary != nil {
            
                defaultsDictionary = NSMutableDictionary(dictionary: dictionary!)
            } else {
                
                defaultsDictionary = NSMutableDictionary()
            }
            
            let secureDictionary = defaultsDictionary.object(forKey: kSecureDefaultsKey) as? NSDictionary
            
            if secureDictionary != nil {
            
                let decryptedDictionary = decryptDictionary(secureDictionary!)
                
                secureItemsDictionary = NSMutableDictionary(dictionary: decryptedDictionary)
           
            } else {
                
                secureItemsDictionary = NSMutableDictionary()
            
            }
        }
    }
    
    public func stringForKey(_ key: String) -> String? {
    
        return defaultsDictionary.object(forKey: key) as? String
    }
    
    public func secureStringForKey(_ key: String) -> String? {
        
        return secureItemsDictionary.object(forKey: key) as? String
    }
    
    public func dictionaryForKey(_ key: String) -> Dictionary<String, AnyObject>? {
        
        return defaultsDictionary.object(forKey: key) as? Dictionary
    }
    
    public func dataForKey(_ key: String) -> Data? {
        
        return defaultsDictionary.object(forKey: key) as? Data
    }
    
    public func boolForKey(_ key: String) -> Bool? {
        
        let number = defaultsDictionary.object(forKey: key) as? NSNumber
        
        return number?.boolValue
    }
    
    public func integerForKey(_ key: String) -> Int? {
        
        return defaultsDictionary.object(forKey: key) as? Int
        
    }
    
    //MARK: Setting methods

    public func setString(_ value: String?, forKey key: String) {
        
        setItem(value as AnyObject?, forKey: key)
    }
    
    public func setSecureString(_ value: String?, forKey key: String) {
    
        if(secureItemsDictionary == nil) {
    
            secureItemsDictionary = NSMutableDictionary()
        }
    
        if (value == nil) {
    
            secureItemsDictionary.removeObject(forKey: key)
            
        } else {
    
            secureItemsDictionary[key] = value
        }
    }
    
    public func setDictionary(_ value: Dictionary<String, AnyObject>, forKey key: String) {
    
        setItem(value as AnyObject?, forKey:key)
    }
    
    public func setData(_ value: Data?, forKey key: String) {
    
        setItem(value as AnyObject?, forKey:key)
    }
    
    public func setBool(_ value: Bool, forKey key: String) {
    
        let number = NSNumber(value: value as Bool)
    
        setItem(number, forKey:key)
    }
    
    public func setInteger(_ value: Int, forKey key: String) {
        
        setItem(value as AnyObject?, forKey: key)
        
    }
    
    public func synchronize() -> Bool {
    
        if (secureItemsDictionary != nil) {
    
            let encryptedDictionary = encryptDictionary(secureItemsDictionary)
    
            defaultsDictionary[kSecureDefaultsKey] = encryptedDictionary
        }
    
        let defaults = UserDefaults.standard
    
        defaults.set(defaultsDictionary, forKey: kDefaultsKey)
    
        return defaults.synchronize()
    }

    
    //MARK: - Helpers
    
    fileprivate func setItem(_ value: AnyObject?, forKey key: String) {
    
        if (value == nil) {
    
            defaultsDictionary.removeObject(forKey: key)
            
        } else {
    
            defaultsDictionary[key] = value
        }
        
        _ = synchronize()
    }
    
    fileprivate func decryptDictionary(_ dictionary: NSDictionary) -> NSDictionary {
    
        let decryptedDictionary = NSMutableDictionary()
        
        dictionary.enumerateKeysAndObjects(options: NSEnumerationOptions.concurrent) { (dictionaryKey, obj, stop) in
            
            let key = dictionaryKey as! String
            
            guard let keyData = key.data(using: .utf8) else {
                
                return
            
            }
            
            if let secureData = obj as? Data {
                
                let decryptedDate = AES.decrypt(secureData, key: keyData)
                                
                if let data = decryptedDate {
                    
                    let value = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                    
                    decryptedDictionary.setValue(value, forKey: key)
                }
            }

        }
     
        return decryptedDictionary
    }

    fileprivate func encryptDictionary(_ dictionary:NSDictionary) -> NSDictionary {
    
        let encryptedDictionary = NSMutableDictionary()
    
        dictionary.enumerateKeysAndObjects(options: NSEnumerationOptions.concurrent) { (dictionaryKey, obj, stop) in
                
            let key = dictionaryKey as! String
            
            guard let keyData = key.data(using: .utf8) else {
                
                return
            
            }
            
            let item = obj as! String
            
            let data = item.data(using: String.Encoding.utf8)
            
            if let securedData = data {

                let encryptedData = AES.encrypt(securedData, key: keyData)
                
                if encryptedData != nil {
            
                    encryptedDictionary.setValue(encryptedData, forKey: key)
                }
            }
    
        }
    
        return encryptedDictionary;
    }
}
