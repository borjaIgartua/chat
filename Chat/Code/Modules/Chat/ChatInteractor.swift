//
//  ChatInteractor.swift
//  Chat
//
//  Created by Borja Igartua Pastor on 29/5/17.
//  Copyright © 2017 Borja Igartua Pastor. All rights reserved.
//

import Foundation

class ChatInteractor: MPCManagerDelegate {
    let mpcManager: MPCManager
    let user: User
    
    weak var delegate: ChatInteractorDelegate?
    
    var messages = [Message]()
    
    init(manager mpc: MPCManager, withUser user: User) {
        self.mpcManager = mpc
        self.user = user
        
        self.mpcManager.delegate = self
    }
    
//MARK: - Utils
    
    func sendMessage(_ message: String) throws {
        try self.mpcManager.sendDataToConnectedPeer(dictionaryWithData: ["message": message])
        
        messages.append(Message(user: Session.sharedSession.user!, message: message))
        delegate?.messageAdded(atIndex: messages.endIndex-1, isMine: true)
    }
    
    func stopSession() {
        self.mpcManager.disconnect()
    }
    
//MARK: - MPCManager delegate methods
    
    func dataReceived(_ dictionary : Dictionary<String, String> ) {
        print("Data received: \(dictionary)")
        if let messageString = dictionary["message"] {
            messages.append(Message(user: self.user, message: messageString))
            
            OperationQueue.main.addOperation { [unowned self, weak delegate = self.delegate] () -> Void in
                delegate?.messageAdded(atIndex: self.messages.endIndex-1, isMine: false)
            }
        }
    }
    
    func connectSessionError() {
        
        OperationQueue.main.addOperation { [weak delegate = self.delegate] () -> Void in
            delegate?.connectionError()
        }
    }
}

protocol ChatInteractorDelegate: class {
    
    func messageAdded(atIndex index: Int, isMine: Bool)
    func connectionError()
}
