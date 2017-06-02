//
//  SettingsInteractor.swift
//  Chat
//
//  Created by Borja Igartua Pastor on 2/6/17.
//  Copyright © 2017 Borja Igartua Pastor. All rights reserved.
//

import UIKit

class SettingsInteractor {
    
    func retriveUserData() -> (name: String, image: Data?) {
        
        let user = Session.sharedSession.user!
        return (user.name, user.imageData)
    }
    
    func saveUserImage(_ image: UIImage) {
        Session.sharedSession.user?.imageData = UIImagePNGRepresentation(image)
        Session.sharedSession.storeData()
    }
    
    func saveUserName(_ name: String) {
        Session.sharedSession.user?.name = name
        Session.sharedSession.storeData()
    }
}
