//
//  Message.swift
//  Chat
//
//  Created by Borja Igartua Pastor on 29/5/17.
//  Copyright © 2017 Borja Igartua Pastor. All rights reserved.
//

class Message {
    let user: User
    let message: String
    
    var isMine: Bool {
        return Session.sharedSession.user?.name == self.user.name
    }
    
    init(user: User, message: String) {
        self.user = user
        self.message = message
    }
}
