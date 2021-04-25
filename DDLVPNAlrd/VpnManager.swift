//
//  VpnManager.swift
//  rabbit
//
//  Created by CYC on 2016/11/19.
//  Copyright © 2016年 yicheng. All rights reserved.
//

import Foundation
import NetworkExtension

enum VPNStatus {
    case off
    case connecting
    case on
    case disconnecting
}


class VpnManager{
    
    static let shared = VpnManager()
    
    var observerAdded: Bool = false
    var siteKeywords:[String] = []
    var blackwords:[String] = []
    var model:Model?
    var alrdVersion :Int = 0
    
    fileprivate(set) var vpnStatus = VPNStatus.off {
        didSet {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "kProxyServiceVPNStatusNotification"), object: nil)
        }
    }
    
    init() {
        loadProviderManager{
            guard let manager = $0 else{return}
            self.updateVPNStatus(manager)
        }
        addVPNStatusObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addNotifucation(_ manager:NETunnelProviderManager){
        let center = NotificationCenter.default
        let name = NSNotification.Name.NEVPNStatusDidChange
        let object = manager.connection
        let queue = OperationQueue.main
        
        center.addObserver(forName: name , object: object, queue: queue, using: { [weak self] (not) -> Void in
            self?.updateVPNStatus(manager)
        })
    }
    
    func addVPNStatusObserver() {
        guard !observerAdded else{
            return
        }
        loadProviderManager { [weak self] (manager) -> Void in
            guard let stongSelf = self else {
                return
            }
            if let manager = manager {
                stongSelf.observerAdded = true
                stongSelf.addNotifucation(manager)
            }
        }
    }
    
    
    func updateVPNStatus(_ manager: NEVPNManager) {
        switch manager.connection.status {
        case .connected:
            self.vpnStatus = .on
            
        case .connecting, .reasserting:
            self.vpnStatus = .connecting
        case .disconnecting:
            self.vpnStatus = .disconnecting
        case .disconnected, .invalid:
            self.vpnStatus = .off
            
        @unknown default:
            fatalError()
        }
    }
}

// load VPN Profiles
extension VpnManager{

    
    fileprivate func createProviderManager() -> NETunnelProviderManager {
        let manager = NETunnelProviderManager()
        let conf = NETunnelProviderProtocol()
        conf.serverAddress = "DDLTestVpn"
        manager.protocolConfiguration = conf
        manager.localizedDescription = "DDLTestVpn "
        return manager
    }
    
    
    func loadAndCreatePrividerManager(_ complete: @escaping (NETunnelProviderManager?) -> Void ){
        NETunnelProviderManager.loadAllFromPreferences{ (managers, error) in
            guard let managers = managers else{
                return
            }
            let manager: NETunnelProviderManager
            if managers.count > 0 {
                manager = managers[0]
                self.delDupConfig(managers)
            }else{
                manager = self.createProviderManager()
            }
            
            manager.isEnabled = true
            self.setRulerConfig(manager)
            manager.saveToPreferences{
                if $0 != nil{complete(nil);return;}
                manager.loadFromPreferences{
                    if $0 != nil{
                        print("\(#function)\($0.debugDescription)")
                        complete(nil);return;
                    }
                    self.addVPNStatusObserver()
                    complete(manager)
                }
            }
            
        }
    }
    
    func loadProviderManager(_ complete: @escaping (NETunnelProviderManager?) -> Void){
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            if let managers = managers {
                if managers.count > 0 {
                    let manager = managers[0]
                    complete(manager)
                    return
                }
            }
            complete(nil)
        }
    }
    
    
    func delDupConfig(_ arrays:[NETunnelProviderManager]){
        if (arrays.count)>1{
            for i in 0 ..< arrays.count{
                arrays[i].removeFromPreferences(completionHandler: { (error) in
                    if(error != nil){
                        
                    }
                })
            }
        }
    }
}

// Actions
extension VpnManager{
    func connect(){
        self.loadAndCreatePrividerManager { (manager) in
            guard let manager = manager else{
                self.vpnStatus = .off
                return
            }
            do{
                try manager.connection.startVPNTunnel(options: [:])
            }catch let err{
                
                print("err---\(err)")
                
            }
        }
    }
    
    func disconnect(){
        loadProviderManager{
            $0?.connection.stopVPNTunnel()
        }
    }
}

// Generate and Load ConfigFile
extension VpnManager{
   
    
    fileprivate func setRulerConfig(_ manager:NETunnelProviderManager){
        
        self.addwhitelist()
        self.addblacklist()
        
        var conf = [String:Any]()
        conf["server"] = model?.services
        conf["port"] = model?.port
        conf["user"] = model?.username
        conf["password"] = model?.password
        conf["blacklist"] = model?.blacklist
        conf["whitelist"] = model?.whitelist
        conf["localdns"] = model?.localdns
        conf["tun2socksaddr"] = model?.tun2socksAddr
        conf["version"] = self.alrdVersion
    
        let tpProtocol = manager.protocolConfiguration as! NETunnelProviderProtocol
        tpProtocol.providerConfiguration = conf
        manager.protocolConfiguration = tpProtocol
        
    }
    
    
    func addwhitelist() {
        model?.whitelist = VpnManager.shared.siteKeywords
    }
    
    func addblacklist() {
        
        self.model?.blacklist = VpnManager.shared.blackwords
        
        
    }
}
