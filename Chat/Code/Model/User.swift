//
//  User.swift
//  Chat
//
//  Created by Borja Igartua Pastor on 29/5/17.
//  Copyright © 2017 Borja Igartua Pastor. All rights reserved.
//

import Foundation

class User: NSObject, NSCoding {
    
    var name: String
    var imageData: Data?
    
    init(displayName name: String, userInfo info: [String : String]?) {
        self.name = name
        
        if let info = info, let imageString = info["image"] {
            self.imageData = Data(base64Encoded: imageString, options: .ignoreUnknownCharacters)
        }
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(imageData, forKey: "imageData")
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        self.imageData = aDecoder.decodeObject(forKey: "imageData") as? Data
    }
}
