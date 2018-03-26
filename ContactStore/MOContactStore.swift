import Foundation
import Contacts
import UIKit

class MOContactStore {
    
    public var contactStore: CNContactStore {
        get {
           
            var store: CNContactStore?
            
            if store == nil {
                
                store = CNContactStore()
                
            }
            
            return store!
        
        }
        
    }
    
    var formattedContactArray: [Contact] = []
    
    var formattedFilteredArray: [Contact] = []
    
    var profileImageData: Data?
        
    func requestForAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        switch authorizationStatus {
            
        case .authorized:
            
            completionHandler(true)
            
        case .denied, .restricted:
            
            completionHandler(false)
            
        case .notDetermined:
            
            self.contactStore.requestAccess(for: .contacts, completionHandler: { access, accessError -> Void in
                
                if access {
                    
                    completionHandler(true)
                    
                } else {
                    
                    completionHandler(false)
                    
                }
                
                
            })
            
        }
    
    }
    
    func accessToContactsNotDetermined() -> Bool {
        
        var success = false
        
        if CNContactStore.authorizationStatus(for: .contacts) == .notDetermined {
            
            success = true
            
        }
        
        return success
        
    }
    
    func accessToContacts() -> Bool {
        
        var success = false
        
        if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
            
            success = true
            
        }
        
        return success
        
    }
    
    func fetchContactWith(id: String) -> Contact? {
      
        let keys = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactThumbnailImageDataKey as CNKeyDescriptor,
            CNContactNoteKey as CNKeyDescriptor,
            CNContactPostalAddressesKey as CNKeyDescriptor
            ]
        
        var contact: Contact?
        
        do {
            
            let mutableContact = try self.contactStore.unifiedContact(withIdentifier: id, keysToFetch: keys)
            
            contact = mutableContact.toContact()
            
        } catch let error {
            
            print(error.localizedDescription)
            
        }
        
        return contact
        
    }
    
    func saveAsInformed(recipient: String) {
        
        let request = CNContactFetchRequest(keysToFetch: [
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactNoteKey as CNKeyDescriptor
            ])

        do {
            
            try self.contactStore.enumerateContacts(with: request, usingBlock: { contact, stop in
                
                for phoneNumber in contact.phoneNumbers {
                    
                    if phoneNumber.value.stringValue == recipient {
                        
                        let informedNote = "Klaim: Informed"
                        
                        let thisContact = contact.mutableCopy() as! CNMutableContact
                        
                        thisContact.note.append(informedNote)
                        
                        let request = CNSaveRequest()
                        
                        request.update(thisContact)
                        
                        do {
                            
                            try self.contactStore.execute(request)
                            
                            self.fetchAllFormattedContacts(completion: { _ in })
                            
                        } catch let error {
                            
                            print(error.localizedDescription)
                            
                        }
                        
                    }
                    
                }

            })
            
        } catch let error {
            
            print(error.localizedDescription)
            
        }
        
    }
    
    func fetchAllFormattedContacts(firstName: String? = nil, lastName: String? = nil, completion: (_ success: Bool) -> Void) {
        
        let request = CNContactFetchRequest(keysToFetch: [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactThumbnailImageDataKey as CNKeyDescriptor,
            CNContactNoteKey as CNKeyDescriptor,
            CNContactPostalAddressesKey as CNKeyDescriptor,
            CNContactBirthdayKey as CNKeyDescriptor
            ])
        
        do {
            
            var contacts: [Contact] = []
            
            self.profileImageData = nil
            
            try self.contactStore.enumerateContacts(with: request) { contact, stop in
                                
                if let firstName = firstName, let lastName = lastName {
                    
                    if self.profileImageData == nil {
                    
                        self.getCurrentPicture(contact: contact, firstName: firstName, lastName: lastName)
                    
                    }
                    
                }
                
                if let c = contact.toContact() {
                    
                    contacts.append(c)
   
                }
                
            }
            
            self.formattedContactArray = contacts.filterDuplicates(includeElement: { $0.contactId == $1.contactId })
 
            completion(true)

        } catch _ {
            
            completion(false)
                        
        }
        
    }
    
    func getCurrentPicture(contact: CNContact, firstName: String, lastName: String) {
     
        if contact.givenName.containsCharacters(ch: firstName) && contact.familyName.containsCharacters(ch: lastName) {
            
            if contact.phoneNumbers.count == 0 {
                
                if let image = contact.thumbnailImageData {
                    
                    self.profileImageData = image
                    
                    return
                    
                }
                
            } else {
                
                if let image = contact.thumbnailImageData {
                    
                    self.profileImageData = image
                    
                    return
                    
                }
                
            }
            
        }
        
    }
    
    func clearData() {
        
        self.formattedContactArray.removeAll()
        
        self.formattedFilteredArray.removeAll()
        
        self.profileImageData = nil
        
    }
    
}

extension CNContact {
    
    func toContact() -> Contact? {
        
        var mutableContact: Contact?
        
        if !self.givenName.isEmpty && !self.familyName.isEmpty {
        
            if let year = self.birthday?.year {
                
                let yearCurrent = Calendar.current.component(.year, from: Date())
                
                if yearCurrent - year < 18  { return nil }
                
            }
            
            for phoneNumber in self.phoneNumbers {
                
                var labelString: String = ""
                
                var phoneNumberString: String = ""
                
                var phoneNumbersArray: [String] = []

                var addressesArray: [ContactAddress] = []
                
                var priorytet = 5

                if let labelText = phoneNumber.label {
                    
                    if labelText.contains("HomeFAX") || labelText.contains("WorkFAX") || labelText.contains("Pager") {
                        
                        break
                        
                    }
                    
                }
                
                for phoneNumber in self.phoneNumbers {
                    
                    let phone = phoneNumber.value.stringValue
                    
                    phoneNumbersArray.append(phone)
                    
                    if let labelText = phoneNumber.label?.replacingOccurrences(of: "_$!<", with: "").replacingOccurrences(of: ">!$_", with: "") {
                        
                        if labelText == "Work" {
                            
                            if priorytet > 4 {
                                
                                labelString = labelText
                                
                                phoneNumberString = phone
                                
                            }
                           
                            priorytet = 4
                            
                        }
                        
                        if labelText == "Home" {
                            
                            if priorytet > 3 {
                                
                                labelString = labelText
                                
                                phoneNumberString = phone
                                
                            }
                           
                            priorytet = 3
                            
                        }
                        
                        if labelText == "Main" {
                            
                            if priorytet > 2 {
                                
                                labelString = labelText
                                
                                phoneNumberString = phone
                                
                            }
                           
                            priorytet = 2
                            
                        }
                       
                        if labelText == "Mobile" {
                            
                            if priorytet > 1 {
                                
                                labelString = labelText
                                
                                phoneNumberString = phone
                                
                            }
                         
                            priorytet = 1
                            
                        }
                        
                        if labelText == "iPhone" {
                            
                            if priorytet > 0 {
                                
                                labelString = labelText
                                
                                phoneNumberString = phone
                            
                            }
                           
                            priorytet = 0
                            
                        }
                        
                        if labelText == "Other" {
                            
                            if priorytet > 0 {
                                
                                labelString = labelText
                                
                                phoneNumberString = phone
                                
                            }
                            
                            priorytet = 0
                            
                        }
                        
                    } else {
                        
                        phoneNumberString = phone

                    }
                
                }

                for address in self.postalAddresses {
                    
                    if var label = address.label?.replacingOccurrences(of: "_$!<", with: "").replacingOccurrences(of: ">!$_", with: "").uppercased() {
                                            
                        if label != "WORK" && label != "HOME" && label != "OTHER" {
                            
                            label = "CUSTOM"
                            
                        }
                        
                        let street = address.value.street
                        let city = address.value.city
                        let state = address.value.state
                        let zip = address.value.postalCode
                        let isoCountryCode = address.value.isoCountryCode.uppercased()

                        let contactAddress = ContactAddress(type: label,
                                                            street: street,
                                                            city: city,
                                                            state: state,
                                                            zip: zip,
                                                            country_code: isoCountryCode)

                        addressesArray.append(contactAddress)

                    }
                    
                }
                                
                mutableContact = Contact(contactId: self.identifier,
                                         givenName: self.givenName,
                                         familyName: self.familyName,
                                         phoneNumber: phoneNumberString,
                                         label: labelString,
                                         thumbnailImageData: self.thumbnailImageData,
                                         note: self.note,
                                         phoneNumbers: phoneNumbersArray,
                                         results_count: 0,
                                         search_id: nil,
                                         phoneNumberAndLabel: (labelString, phoneNumberString),
                                         addresses: addressesArray,
                                         has_quality_match: false,
                                         is_relative: false)
                                
            }
            
        }
        
        return mutableContact
        
    }
    
}

extension Array {
    
    func filterDuplicates(includeElement: (_ lhs:Element, _ rhs:Element) -> Bool) -> [Element]{
        
        var results = [Element]()
        
        forEach { (element) in
          
            let existingElements = results.filter {
            
                return includeElement(element, $0)
            
            }
            
            if existingElements.count == 0 {
            
                results.append(element)
            
            }
        
        }
        
        return results
    }

}
