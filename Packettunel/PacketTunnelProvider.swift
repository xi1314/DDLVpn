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

        self.confighttplocal(networkSettings: networkSettings)
        
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
    
    fileprivate func confighttplocal(networkSettings:NEPacketTunnelNetworkSettings) {
        let proxySettings = NEProxySettings()
        /**
         *  这个地方的port 是我们加速服务器的port --29981
         **/
        proxySettings.httpEnabled = true
        proxySettings.httpServer = NEProxyServer(address: "127.0.0.1", port: self.port)
        proxySettings.httpsEnabled = true
        proxySettings.httpsServer = NEProxyServer(address: "127.0.0.1", port: self.port)
        proxySettings.excludeSimpleHostnames = true
        // This will match all domains
        proxySettings.matchDomains = [""]
        proxySettings.exceptionList = ["api.smoot.apple.com","configuration.apple.com","xp.apple.com","smp-device-content.apple.com","guzzoni.apple.com","captive.apple.com","*.ess.apple.com","*.push.apple.com","*.push-apple.com.akadns.net"]
        networkSettings.proxySettings = proxySettings
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
              * 参数 domain_rules 为测试样例，传参格式要求 为 策略 + “ ” + item
              * 策略为（allow/ dency / direct）
              * allow :允许走代理， dency ：为黑名单 direct：直连
              */
            
            let allow  = "allow" + " " + "myip.dengdengli.com"
            
            run_with_mode("127.0.0.1:\(self.port)", "127.0.0.1:8071", "127.0.0.1:53", "172.16.0.0/12", "debug", servert, "", allow, "", "", String(tunfd))
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



