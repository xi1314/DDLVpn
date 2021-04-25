//
//  PacketTunnelProvider.swift
//  Packettunel
//
//  Created by MrFeng on 2020/12/4.
//

import NetworkExtension

import PacketProcessor

class PacketTunnelProvider: NEPacketTunnelProvider {

    var lastPath:NWPath?

//    var isRunning:Bool = false

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
        
        
        TunnelInterface.setup(with: self.packetFlow)
//
        guard let conf = (protocolConfiguration as! NETunnelProviderProtocol).providerConfiguration else{
            NSLog("[ERROR] No ProtocolConfiguration Found")
            exit(EXIT_FAILURE)
        }

        self.parseConfig( conf )

        let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "192.0.2.2")
        networkSettings.mtu = TunnelMTU as NSNumber
        networkSettings.ipv4Settings = NEIPv4Settings(addresses: ["192.169.89.1"], subnetMasks: ["255.255.255.0"])
     
     self.confighttplocal(networkSettings: networkSettings)
//
      self.setDNSConfigure(networksetting: networkSettings)

      self.startgoProxy()
//
        setTunnelNetworkSettings(networkSettings) { error in
                    guard error == nil else {
                        completionHandler(error)
                        return
                    }

                   self.startTun2socks()
                   self.beginRead()

                    completionHandler(nil)

                }
        
    }


    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        
        stop()
      
        completionHandler()

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

}

extension PacketTunnelProvider {
    
    fileprivate func setDNSConfigure(networksetting:NEPacketTunnelNetworkSettings!) {
        
        
        let DNSSettings = NEDNSSettings(servers: ["127.0.0.1"])
        DNSSettings.matchDomains = [""]
        networksetting.dnsSettings = DNSSettings
        networksetting.ipv4Settings?.includedRoutes = [NEIPv4Route.init(destinationAddress: "172.16.0.0", subnetMask: "255.240.0.0")]
    }
    
    fileprivate func startgoProxy() {
         DispatchQueue.global(qos: .background).async {
           
            
            let servert = "https://\(self.user):\(self.password)@\(self.server):\(self.port)"
            
            NSLog("\(servert)")
                    
            run_with_mode("allow_gfw", "127.0.0.1:\(self.port)", "\(self.tun2socksAddr)", "127.0.0.1:1053", "172.16.0.0/12", "trace", servert, "", "", "")
        
            }
            
            
       
    
    }
    
    fileprivate func startTun2socks() {
        TunnelInterface.startTun2Socks("\(self.tun2socksAddr)")
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
    
    fileprivate func beginRead() {
        let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
                 TunnelInterface.processPackets()
            }
    }
    
}


extension PacketTunnelProvider {
    fileprivate func escape(_ string: String) -> String {
            let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
            let subDelimitersToEncode = "!$&'()*+,;="

            var allowedCharacterSet = CharacterSet.urlQueryAllowed
            allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

            return string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
        }

       fileprivate func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
            var components: [(String, String)] = []

            if let dictionary = value as? [String: Any] {
                for (nestedKey, value) in dictionary {
                    components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
                }
            } else if let array = value as? [Any] {
                for value in array {
                    components += queryComponents(fromKey: "\(key)[]", value: value)
                }
            } else if let value = value as? NSNumber {
                if CFBooleanGetTypeID() == CFGetTypeID(value) {
                    components.append((escape(key), escape((value.boolValue ? "1" : "0"))))
                } else {
                    components.append((escape(key), escape("\(value)")))
                }
            } else if let bool = value as? Bool {
                components.append((escape(key), escape((bool ? "1" : "0"))))
            } else {
                components.append((escape(key), escape("\(value)")))
            }

            return components
        }

       fileprivate func query(_ parameters: [String: Any]) -> String {
            var components: [(String, String)] = []
            for key in parameters.keys.sorted(by: <) {
                let value = parameters[key]!
                components += queryComponents(fromKey: key, value: value)
            }
            return components.map { "\($0)=\($1)" }.joined(separator: "&")
        }

       fileprivate func post(_ url:URL,parameters:[String:Any]?,timeout:TimeInterval = 15,complete:@escaping (Data?, URLResponse?, Error?)->Void){
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: timeout)
            request.httpMethod = "POST"
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
            }
            if let pars = parameters {
                guard let data = query(pars).data(using: .utf8, allowLossyConversion: false) else {
                    let error = NSError(domain: "Parameter format error,covert to data failed.", code: 500, userInfo: nil)
                    complete(nil, nil,error)
                    return
                }
                request.httpBody = data
            }

            if token.count > 0 {
                request.setValue(token, forHTTPHeaderField: "token")
            }

            var dataTask:URLSessionDataTask!
            dataTask = URLSession.shared.dataTask(with: request){ data, response, error in
                if let index = self.httpTasks.firstIndex(of: dataTask) {
                    self.httpTasks.remove(at: index)
                }
                DispatchQueue.main.async {
                    complete(data, response, error)
                }
            }
            if dataTask != nil {
                dataTask.resume()
                httpTasks.append(dataTask as URLSessionDataTask)
            }
        }
     
     fileprivate func notPrettyString(from object: Any) -> String? {
         if let objectData = try? JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions(rawValue: 0)) {
             let objectString = String(data: objectData, encoding: .utf8)
             return objectString
         }
         return nil
     }
    
    func parseConfig(_ conf:[String : Any]){
        
        
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
            self.keywords.removeAll()
            for keyword in cKeywords {
                self.keywords.append(keyword)
            }
        }
        if let blackwords = conf["blacklist"] as? [String], blackwords.count > 0 {
            self.blackwords.removeAll()
            for keyword in blackwords {
                self.blackwords.append(keyword)
                NSLog("---blackkeywords ---- \(keyword) --- ")
            }
        }
        if let cToken = conf["token"] as? String, cToken.count > 0 {
            self.token = cToken
        }
    }
}


