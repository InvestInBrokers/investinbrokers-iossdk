import Foundation

extension String {
    
    func getJwtBodyString(userID: String) -> Bool {
        
        var segments = self.components(separatedBy: ".")
        
        var base64String = segments[1]
        
        print("\(base64String)")
        
        let requiredLength = Int(4 * ceil(Float(base64String.count) / 4.0))
        
        let nbrPaddings = requiredLength - base64String.count
        
        if nbrPaddings > 0 {
            
            let padding = String().padding(toLength: nbrPaddings, withPad: "=", startingAt: 0)
            
            base64String = base64String.appending(padding)
            
        }
        
        base64String = base64String.replacingOccurrences(of: "-", with: "+")
        
        base64String = base64String.replacingOccurrences(of: "_", with: "/")
        
        let decodedData = Data(base64Encoded: base64String, options: Data.Base64DecodingOptions(rawValue: UInt(0)))
        
        let base64Decoded: String = String(data: decodedData! as Data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
        
        if base64Decoded.containsCharacters(ch: userID) {
            
            return true
            
        } else {
            
            return false
            
        }
        
    }
    
}
