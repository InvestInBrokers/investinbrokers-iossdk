import Foundation

public protocol MOUserDefaults {
    
    // MARK: - Getting methods
    
    func stringForKey(_ key: String) -> String?
    
    func secureStringForKey(_ key: String) -> String?
    
    func dictionaryForKey(_ key: String) -> Dictionary<String, AnyObject>?
    
    func dataForKey(_ key: String) -> Data?
    
    func boolForKey(_ key: String) -> Bool?
    
    func integerForKey(_ key: String) -> Int?
    
    //MARK: - Setting methods
    
    func setString(_ value: String?, forKey key: String)
    
    func setSecureString(_ value: String?, forKey key: String)
    
    func setDictionary(_ value: Dictionary<String, AnyObject>, forKey key: String)
    
    func setData(_ value: Data?, forKey key: String)
    
    func setBool(_ value: Bool, forKey key: String)
    
    func setInteger(_ value: Int, forKey key: String)
    
    func synchronize() -> Bool
}
