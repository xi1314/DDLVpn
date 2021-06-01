//
//  NetworkTestManager.swift
//  DDLVPNAlrd
//
//  Created by MrFeng on 6/1/21.
//

import UIKit

class NetworkTestManager: NSObject {
    
    static let manager = NetworkTestManager.init()
    
    // get
    
    func get(_ urlstring:String) {
        
        
        let url:URL = URL.init(string: urlstring)!
        let request = URLRequest.init(url: url)
        var task:URLSessionDataTask!
        task = URLSession.shared.dataTask(with: request){ data, response, error in
            
            #if DEBUG
            print("\n======================begin====================")
            print("http request: \(request)")
            print("http header: \n \(String(describing: request.allHTTPHeaderFields))")
            #endif
            
            if error != nil {
                
                print("NetworkTestManager get method with error == \(error!)")
                
            }
            
            var dict : Any?
            
            do {
                
                dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.init(rawValue: 0))
                
            }catch {
                
            }
            
            print("NetworkTestManager get method json data == \(String(describing: dict))")
            
            
        }
        
        task.resume()
        
    }
    
    
    //post
    
    func post(with urlstring:String , params:[String:Any]?) {
        
        
        var session = URLSession.shared
        
        var url = URL.init(string: urlstring)
        
        var request = URLRequest.init(url: url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        request.httpMethod = "POST"
        
        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
            
        }
        
        if let pars = params {
            guard let data = query(pars).data(using: .utf8, allowLossyConversion: false) else {
                let error = NSError(domain: "Parameter format error,covert to data failed.", code: 500, userInfo: nil)
                
                return
            }
            request.httpBody = data
        }
        
        
        var task:URLSessionDataTask!
        
        task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            print("\n======================begin====================")
            print("http request: \(request)")
            print("http header: \n \(String(describing: request.allHTTPHeaderFields))")
            print("http parameters:\(String(describing: params))")
            
            if error != nil {
                
                print("NetworkTestManager post method with error == \(error!)")
                
            }
            
            if let parsedata = data {
                
                var dict :Any?
                do {
                    
                    dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.init(rawValue: 0))
                    
                }catch {
                    
                }
                
                print("NetworkTestManager post method json data == \(String(describing: dict))")
                
            }else {
                
                print("NetworkTestManager post method  data == nil")
                
            }
            
            
            
            
           
            
        })
        
          
        task.resume()
        
    }
    
    
    

}

extension NetworkTestManager {
    
    
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
    
}
