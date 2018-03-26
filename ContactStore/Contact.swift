import Foundation

struct Contact {
    
    var contactId: String
    var givenName: String
    var familyName: String
    var phoneNumber: String
    var label: String?
    var thumbnailImageData: Data?
    var note: String
    var phoneNumbers: [String]
    var results_count: Int
    var search_id: String?
    var phoneNumberAndLabel: (String, String)
    var addresses: [ContactAddress]
    var has_quality_match: Bool = false
    var is_relative: Bool
    
}

struct ContactAddress {
    
    var type: String
    var street: String
    var city: String
    var state: String
    var zip: String
    var country_code: String
    
}
