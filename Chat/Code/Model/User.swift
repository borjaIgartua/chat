//
//  User.swift
//  Chat
//
//  Created by Borja Igartua Pastor on 29/5/17.
//  Copyright © 2017 Borja Igartua Pastor. All rights reserved.
//

import Foundation

class User {
    
    var name: String
    
    init(displayName name: String, userInfo info: [String : String]?) {
        self.name = name
    }
}
