//
//  PacketTunnelProvider.swift
//  Packettunel
//
//  Created by MrFeng on 2020/12/4.
//

import NetworkExtension

class PacketTunnelProvider: NEPacketTunnelProvider {

    var lastPath:NWPath?

    private var server = "test.light.ustclug.org"
    private var port = 29980
    private var localdns = ""
    private var tun2socksAddr = ""
    private var user = "xueshi"
    private var password = "q10WMcWRmHzMjKf8"
    private var keywords:[String] = []
    private var blackwords:[String] = []
    private var token = ""

    private var httpTasks:[URLSessionTask] = []

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        
//
        guard let conf = (protocolConfiguration as! NETunnelProviderProtocol).providerConfiguration else{
            NSLog("[ERROR] No ProtocolConfiguration Found")
            exit(EXIT_FAILURE)
        }

        self.parseConfig( conf )

        let networkSettings = createTunnelSettings()

        
        let tunFd = self.packetFlow.value(forKeyPath: "socket.fileDescriptor") as! Int32
        
        setTunnelNetworkSettings(networkSettings) { error in
                    guard error == nil else {
                        completionHandler(error)
                        return
                    }


            
            DispatchQueue.global(qos: .userInitiated).async {
                signal(SIGPIPE, SIG_IGN)
                self.startWith(tunfd: tunFd)
            }

                    completionHandler(nil)

                }
        
    }
    
    


    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
      
        completionHandler()

        stop()
        exit(EXIT_SUCCESS)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {


        if keyPath == "defaultPath" {
            if self.defaultPath?.status == .satisfied && self.defaultPath != lastPath{
                if(lastPath == nil){
                    lastPath = self.defaultPath
                }else{
                    NSLog("received network change notifcation")
                    let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: delayTime) {
                        self.startTunnel(options: nil){_ in}
                    }
                }
            }else{
                lastPath = defaultPath
            }
        }

    }

    func parseConfig(_ conf:[String : Any]){
        
        self.keywords.removeAll()
        
        if  let configServer = conf["server"] as? String , configServer.count > 0 {
            self.server = configServer
            
        }
        if let configPort = conf["port"] as? String , configPort.count > 0 {
            self.port = Int(configPort)!
            NSLog("port---\(self.port)")
        }
        if let cUser = conf["user"] as? String , cUser.count > 0 {
            self.user = cUser
        }
        
        if let localds = conf["localdns"] as? String , localds.count > 0 {
            self.localdns = localds
            
            NSLog("self.localdns--\(self.localdns)")
        }
        
        
        if let tun2socks = conf["tun2socksaddr"] as? String , tun2socks.count > 0 {
            self.tun2socksAddr = tun2socks
        }
        
        
        if let cPassword = conf["password"] as? String , cPassword.count > 0 {
            self.password = cPassword
        }
        if let cKeywords = conf["whitelist"] as? [String], cKeywords.count > 0 {
            
            for keyword in cKeywords {
                self.keywords.append(keyword)
            }
        }
        if let blackwords = conf["blacklist"] as? [String], blackwords.count > 0 {
            
            for keyword in blackwords {
                self.keywords.append(keyword)
                NSLog("---blackkeywords ---- \(keyword) --- ")
            }
        }
        if let cToken = conf["token"] as? String, cToken.count > 0 {
            self.token = cToken
        }
    }
}

extension PacketTunnelProvider {
  
    
    fileprivate func startWith(tunfd:Int32) {
         DispatchQueue.global(qos: .background).async {
            
            let servert = "https://\(self.user):\(self.password)@\(self.server):\(self.port)"
            NSLog("----servert----\(servert)")
            /**
             *app_mode: allow_gfw ? (domianrules and ip rules can not init) :(must init domain rules or ip rules)
             *socks_address: can not init
             *fakedns_address: can not init
             *domain rules / ip rules :app_mode need "" or "default" , then read as fileprivate func dealDomains(_ list:[String]) -> String
             */
            run_with_mode("allow_gfw", "127.0.0.1:\(self.port)", "127.0.0.1:9091", "127.0.0.1:53", "172.16.0.0/12", "trace", servert, "", "", "", String(tunfd))
            NSLog("servert---\(servert)")

            }
        
    
    }
    
    func createTunnelSettings() -> NEPacketTunnelNetworkSettings  {
        let newSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "240.0.0.10")
        newSettings.ipv4Settings = NEIPv4Settings(addresses: ["240.0.0.1"], subnetMasks: ["255.255.255.0"])
        newSettings.ipv4Settings?.includedRoutes = [NEIPv4Route.`default`()]
        newSettings.proxySettings = nil
        newSettings.dnsSettings = NEDNSSettings(servers: ["223.5.5.5", "8.8.8.8"])
        newSettings.mtu = 1500
        return newSettings
    }
    
    fileprivate func dealDomains(_ list:[String]) -> String{
        
        if  list.count == 0  {
            return ""
        }
        
        var wdicts = [String]()
        for item in list {
            let newItem = "allow" + " " +  item
            
            wdicts.append(newItem)
        }
        
        let wstring = wdicts.joined(separator: ";")
        NSLog("dicts---\(wdicts)---wstirng:-\(wstring)")
        return wstring
    }
    
    
}



