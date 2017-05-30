//
//  UsersInteractor.swift
//  Chat
//
//  Created by Borja Igartua Pastor on 29/5/17.
//  Copyright © 2017 Borja Igartua Pastor. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class UsersInteractor: MPCManagerDelegate {
    let mpcManager: MPCManager
    weak var delegate: UsersInteractorDelegate?
    
    var users = [User]()
    var connectedUser: User?
    
    init() {
        Session.sharedSession.user = User(displayName: UIDevice.current.name, userInfo: nil)
        self.mpcManager = MPCManager(displayName: UIDevice.current.name, userInfo: nil)        
    }
    
//MARK: - Utils
    
    func start() {
        users = []
        self.mpcManager.delegate = self
        self.mpcManager.startSearchingNearbyPeers()
    }
    
    func sendInvitationToUser(inIndexPath indexPath: IndexPath) {
        self.connectedUser = self.users[indexPath.row]
        self.mpcManager.invitePeer(atIndex: indexPath.row, withContext: nil)
    }
        
    
//MARK: - MPCManagerDelegate methods
    
    func foundPeer(_ peer: MCPeerID, discoveryInfo: [String : String]?) {        
        users.append(User(displayName: peer.displayName, userInfo: discoveryInfo))
        delegate?.userAdded(atIndex: users.endIndex-1)
    }
    
    func lostPeer(_ peer : MCPeerID) {
        
        let index = users.index { (user) -> Bool in
            return user.name == peer.displayName
        }
        
        if let index = index {
            users.remove(at: index)
            delegate?.userRemoved(atIndex: index)
        }
    }
    
    func invitationWasReceived(fromPeer peer: MCPeerID, withContext context: Data?) {
        
        OperationQueue.main.addOperation { [unowned self, weak delegate = self.delegate] () -> Void in
            delegate?.invitationReceived(fromName: peer.displayName, context: context, accept: { [unowned self] in
                
                //TODO: convert context in userInfo                
                self.connectedUser = User(displayName: peer.displayName, userInfo: nil)
                self.mpcManager.userReceivedInvitation(accept: true)
                
            }, decline: { [unowned self] in
                self.mpcManager.userReceivedInvitation(accept: false)
            })
        }
    }
    func connectedWithPeer(_ peerID: MCPeerID) {
        
        self.mpcManager.stopSearchingNearbyPeers()
        OperationQueue.main.addOperation { [unowned self, weak delegate = self.delegate] () -> Void in
            delegate?.connectedWithUser(self.connectedUser)
        }
    }
    
    func connectSessionError() {
        //TODO: show conecction error and try to reconnect
    }
}

protocol UsersInteractorDelegate: class {
    
    func userAdded(atIndex index: Int)
    func userRemoved(atIndex index: Int)
    func invitationReceived(fromName name: String, context: Data?, accept: @escaping () -> (), decline: @escaping () -> ())
    func connectedWithUser(_ user: User?)
}
