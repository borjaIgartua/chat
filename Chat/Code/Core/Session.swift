//
//  Session.swift
//  Chat
//
//  Created by Borja Igartua Pastor on 30/5/17.
//  Copyright © 2017 Borja Igartua Pastor. All rights reserved.
//

final class Session {
    
    var user: User?
    
    private init() { }
    
    static let sharedSession = Session()
}
