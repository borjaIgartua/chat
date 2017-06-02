//
//  Session.swift
//  Chat
//
//  Created by Borja Igartua Pastor on 30/5/17.
//  Copyright © 2017 Borja Igartua Pastor. All rights reserved.
//

import Foundation

final class Session {
    
    var user: User?
    
    private init() {
        
        if let data = UserDefaults.standard.data(forKey: "user_key") {
            let user = NSKeyedUnarchiver.unarchiveObject(with: data) as? User
            self.user = user
        }
    }
    
    static let sharedSession = Session()
    
    func storeData() {
    
        guard let user = user else {
            return
        }
        
        let data = NSKeyedArchiver.archivedData(withRootObject: user)
        UserDefaults.standard.setValue(data, forKey: "user_key")
        UserDefaults.standard.synchronize()
    }
}
