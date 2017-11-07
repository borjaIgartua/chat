//
//  MPCManager.swift
//  Chat
//
//  Created by Borja Igartua Pastor on 29/5/17.
//  Copyright © 2017 Borja Igartua Pastor. All rights reserved.
//
// https://openradar.appspot.com/27243227

import MultipeerConnectivity

typealias InvitationHandler = (Bool, MCSession) -> Void

class MPCManager: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    
    let session: MCSession
    let peer: MCPeerID
    let browser: MCNearbyServiceBrowser
    let advertiser: MCNearbyServiceAdvertiser
    
    var isAdvertising = false
    var foundPeers = [MCPeerID]()
    var connectedPeer: MCPeerID?
    var invitationHandler: InvitationHandler?
    weak var delegate: MPCManagerDelegate?
    
    required init(displayName name: String, userInfo info: [String : String]?) {
        
        peer = MCPeerID(displayName: name)
        session = MCSession(peer: peer, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.none)
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: "bi-txtchat")
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: info, serviceType: "bi-txtchat")
        
        super.init()
        session.delegate = self
        browser.delegate = self
        advertiser.delegate = self
    }
    
    deinit {
        
        browser.stopBrowsingForPeers()
        advertiser.stopAdvertisingPeer()
        session.disconnect()
    }
    
    //MARK: - Utils
    
    func startSearchingNearbyPeers() {
        
        browser.startBrowsingForPeers()
        advertiser.startAdvertisingPeer()
        isAdvertising = true
    }
    
    func stopSearchingNearbyPeers() {
        
        browser.stopBrowsingForPeers()
        advertiser.stopAdvertisingPeer()
        isAdvertising = false
    }
    
    func deleteInformationAndStopSearch() {
        
        foundPeers.removeAll()
        connectedPeer = nil
        
        browser.stopBrowsingForPeers()
        advertiser.stopAdvertisingPeer()
        isAdvertising = false
    }
    
    func reset() {
        
        foundPeers.removeAll()
        connectedPeer = nil
        
        browser.stopBrowsingForPeers()
        advertiser.stopAdvertisingPeer()
        
        browser.startBrowsingForPeers()
        advertiser.startAdvertisingPeer()
        
        isAdvertising = true
    }
    
    func invitePeer(atIndex index: Int, withContext context: Data?) {
        let peer = self.foundPeers[index]
        browser.invitePeer(peer, to: self.session, withContext: context, timeout: 10)
    }
    
    func userReceivedInvitation(accept: Bool) {
        self.invitationHandler?(accept, self.session)
    }
    
    func sendDataToConnectedPeer(dictionaryWithData dictionary: [String:String]) throws  {
        
        if let connectedPeer = self.connectedPeer {
            
            let dataToSend = NSKeyedArchiver.archivedData(withRootObject: dictionary)
            try session.send(dataToSend, toPeers: [connectedPeer], with: .reliable)
        }
    }
    
    func disconnect() {
        session.disconnect()
    }
    
    //MARK: - MCSessionDelegate
    
    func session(_ session: MCSession,
                 peer peerID: MCPeerID,
                 didChange state: MCSessionState) {
        
        switch state {
            
        case .connected:
            
            connectedPeer = peerID
            print("Peer connected: \(connectedPeer!)")
            delegate?.connectedWithPeer?(peerID)
            
        case . connecting:
            
            print("Connecting Session...")
            delegate?.connectingSession?()
            
        case .notConnected:
            
            print("Not Connected")
            delegate?.connectSessionError?()
            
        }
    }
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        let dataDictionary = NSKeyedUnarchiver.unarchiveObject(with: data) as! [String: String]
        delegate?.dataReceived?(dataDictionary)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
    
    //MARK: - MCNearbyServiceBrowserDelegate
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        foundPeers.append(peerID)
        print("peer found: \(peerID) with info: \(String(describing: info))")
        
        delegate?.foundPeer?(peerID, discoveryInfo: info)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
        if let index = self.foundPeers.index(of: peerID) {
            self.foundPeers.remove(at: index)
            delegate?.lostPeer?(peerID)
        }
        print("lost peer: \(peerID)")
        
    }
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("Browser error \(error.localizedDescription)")
    }
    
    //MARK: - MCNearbyServiceAdvertiserDelegate
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        print("Incoming invitation request")
        
        self.invitationHandler = invitationHandler
        delegate?.invitationWasReceived?(fromPeer: peerID, withContext: context)
    }
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Advertising error \(error.localizedDescription)")
    }
}


@objc protocol MPCManagerDelegate: class {
    
    @objc optional func foundPeer(_ peer: MCPeerID, discoveryInfo: [String : String]?)
    @objc optional func lostPeer(_ peer : MCPeerID)
    @objc optional func invitationWasReceived(fromPeer peer: MCPeerID, withContext context: Data?)
    @objc optional func connectedWithPeer(_ peerID: MCPeerID)
    
    @objc optional func dataReceived(_ dictionary : Dictionary<String, String>)
    @objc optional func connectingSession()
    @objc optional func connectSessionError()
}

