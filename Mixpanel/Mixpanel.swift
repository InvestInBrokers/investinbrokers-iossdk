import Foundation
import Mixpanel

var mixpanelCount = 0

class MOMixpanel: MixpanelInstance {
    
    class func initialize() {
        
        Mixpanel.initialize(token: MIXPANEL_TOKEN)
        
    }
    
    class func mainInstance() -> MixpanelInstance {
     
        return Mixpanel.mainInstance()
        
    }
    
}

extension UIViewController {
    
    var mixpanel: MixpanelInstance {
        
        return MOMixpanel.mainInstance()
        
    }
    
}

extension AppDelegate {
    
    var mixpanel: MixpanelInstance {
        
        return MOMixpanel.mainInstance()
        
    }
    
}

extension SearchingHelper {
    
    var mixpanel: MixpanelInstance {
        
        return MOMixpanel.mainInstance()
        
    }
    
}

extension MixpanelInstance {
    
    func initProperties() {
        
        self.people.set(properties: ["_number_of_all_searchable_contacts": ""])

        self.people.set(properties: ["_onboarding_completed": ""])

        self.people.set(properties: ["_access_contact_book": ""])

        self.people.set(properties: ["_found_properties_user": ""])
        
        self.people.set(properties: ["_faq_read": ""])

        self.people.set(properties: ["_privacy_policy_read": ""])

        self.people.set(properties: ["_terms_of_service_read": ""])

        self.people.set(properties: ["_number_of_relatives_found": ""])
        
        self.people.set(properties: ["_number_of_contacts_found": ""])

        self.people.set(properties: ["_number_of_relatives_stars": ""])

        self.people.set(properties: ["_number_of_contacts_stars": ""])

        self.people.set(properties: ["_number_of_all_contacts_sent": ""])

        self.people.set(properties: ["_requested_claim_forms": 0])

        self.people.set(properties: ["_details_view_visits": 0])

        self.people.set(properties: ["_deleted": ""])

        self.people.set(property: "_using_TLO", to: "")

        self.people.set(properties: ["_user_joind_via_text": ""])

        self.people.set(properties: ["_user_joind_via_twillio": ""])

        self.people.set(properties: ["_invited_by": ""])
        
        self.people.set(property: "_best_searches", to: 0)

        self.people.set(property: "_exact_searches", to: 0)

    }
    
}

extension MixpanelInstance {
    
    func set_identity(id: String) {
        
        self.identify(distinctId: id)
        
        if mixpanelCount == 0 {

            self.set_new_session()
    
            mixpanelCount = 1
            
        }
        
    }
    
    func set_new_session() {
        
        self.time(event: "Session closed")
        
        self.track(event: "New session")
        
    }
    
    func set_close_session() {
    
        self.track(event: "Session closed")
        
        mixpanelCount = 0
        
    }
    
    func increment_session() {
        
        self.people.increment(property: "_number_of_sessions", by: 1)
        
    }
    
    func set_id(id: String) {
        
        self.people.set(properties: ["_id": id])
        
    }
    
    func set_sign_up() {
        
        self.track(event: "Sign up")
        
    }
    
    func set_email(email: String) {
        
        self.people.set(properties: ["_email": email])

        self.people.set(properties: ["$email": email])
        
    }
    
    func set_phoneNumber(phone: String) {
        
        self.people.set(properties: ["_phone_number": phone])
        
    }

    func set_username(first_name: String, middle_name: String, last_name: String) {
        
        self.people.set(properties: ["_name": first_name + " " + middle_name + " " + last_name])
        
        self.people.set(properties: ["$name": first_name + " " + middle_name + " " + last_name])

        self.people.set(properties: ["_name_first_name": first_name,
                                         "_name_middle_name": middle_name,
                                         "_name_last_name": last_name])
            
    }
    
    func set_address(addresss_line1: String, addresss_line2: String, city: String, zip: String, state: String) {
        
        self.people.set(properties: ["_address_line1": addresss_line1,
                                         "_address_line2": addresss_line2,
                                         "_address_city": city,
                                         "_address_zip": zip,
                                         "_address_state": state])
        
    }
    
    func set_onboarding_completed() {
    
        self.people.set(properties: ["_onboarding_completed": "true"])
        
    }
    
    func set_access_contact_book(enabled: Bool) {
        
        if enabled {
            
            self.people.set(properties: ["_access_contact_book": "enabled"])

        } else {
            
            self.people.set(properties: ["_access_contact_book": "disabled"])

        }
        
    }
    
    func set_found_properties(number: Int) {
        
        self.people.set(properties: ["_found_properties_user": number])
        
    }
    
    func increment_requested_claim_forms(number: Double) {
        
        self.track(event: "Requested claim forms")

        self.people.increment(property: "_requested_claim_forms", by: number)
        
    }
    
    func increment_visited_state_websites(number: Double) {
        
        self.track(event: "Visited state websites")

        self.people.increment(property: "_visited_state_websites", by: number)
        
    }
    
    func set_account_deleted() {
        
        self.track(event: "Accounts deleted")
        
        self.people.set(properties: ["_deleted": "true"])

    }
    
    func set_faq_read() {
        
        self.people.set(properties: ["_faq_read": true])
        
    }
    
    func set_privacy_policy_read() {
        
        self.people.set(properties: ["_privacy_policy_read": true])
        
    }
    
    func set_terms_of_service_read() {
        
        self.people.set(properties: ["_terms_of_service_read": true])
        
    }
    
    func increment_best_searches() {
        
        self.track(event: "Best searches")
        
        self.people.increment(property: "_best_searches", by: 1)
        
    }
    
    func increment_exact_searches() {
        
        self.track(event: "Exact searches")

        self.people.increment(property: "_exact_searches", by: 1)
        
    }
    
    func increment_details_view_visits() {
        
        self.people.increment(property: "_details_view_visits", by: 1)
        
    }
    
    func set_number_of_relatives(number: Int) {
        
        self.people.set(properties: ["_number_of_relatives_found": number])
        
    }
    
    func set_number_of_contacts(number: Int) {
        
        self.people.set(properties: ["_number_of_contacts_found": number])
        
    }
    
    func set_number_of_all_searchable_contacts(number: Int) {
        
        self.people.set(properties: ["_number_of_all_searchable_contacts": number])
        
    }
    
    func set_number_of_relatives_with_stars(number: Int) {
        
        self.people.set(properties: ["_number_of_relatives_stars": number])
        
    }
    
    func set_number_of_contacts_with_stars(number: Int) {
        
        self.people.set(properties: ["_number_of_contacts_stars": number])
        
    }
  
    func increment_dossier_form_requested() {
        
        self.track(event: "Requested dossiers")

        self.people.increment(property: "_dossier_form_requested", by: 1)
        
    }
    
    func set_number_of_contacts_sent(number: Int) {
        
        self.people.set(properties: ["_number_of_all_contacts_sent": number])
        
    }
   
    // Invitations
    
    // Send
    
    func increment_twillio_invites(name: String) {
        
        let properties = ["_Sent to": name]
        
        let random = String().randomString()
        
        self.track(event: "Twillio invite sent", properties: properties)
        
        self.people.increment(property: "_twillio_deeplink_invites", by: 1)
        
        self.people.set(property: "_twillio_invite_sent_name_" + random, to: name)
    
    }
    
    func increment_text_invites(name: String) {
        
        let properties = ["_Sent to": name]
        
        let random = String().randomString()
        
        self.track(event: "Text invite sent", properties: properties)
        
        self.people.increment(property: "_text_deeplink_invites", by: 1)
        
        self.people.set(property: "_text_invite_sent_name_" + random, to: name)
        
    }
    
    // Receive 
    
    func set_invited(invited_by: String, tag: Int) {
        
        if tag == 0 {
            
            self.track(event: "Recruited by text message")
            
            self.people.setOnce(properties: ["_user_joind_via_text": "true"])
            
        } else {
            
            self.track(event: "Recruited by twillio")
            
            self.people.setOnce(properties: ["_user_joind_via_twillio": "true"])
        
        }
        
        self.people.setOnce(properties: ["_invited_by": invited_by])
    
    }
    
    func increment_successful_deeplink_onboard(id: String, invitationID: String, tag: Int, name: String) {
        
        self.identify(distinctId: invitationID)
        
        let random = String().randomString()
        
        if tag == 0 {
            
            self.people.increment(property: "_text_deeplink_onboard", by: 1)

            self.people.set(property: "_text_deeplink_onboard_name_" + random, to: name)
            
        } else {
            
            self.people.increment(property: "_twillio_deeplink_onboard", by: 1)
            
            self.people.set(property: "_twillio_deeplink_onboard_name_" + random, to: name)

        }
    
        self.identify(distinctId: id)
        
    }
    
    func set_using_TLO(using: Bool) {
        
        self.people.set(property: "_using_TLO", to: using)
        
    }
    
}
