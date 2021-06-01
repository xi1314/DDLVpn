//
//  NetworkCheckViewContorller.swift
//  DDLVPNAlrd
//
//  Created by MrFeng on 6/1/21.
//

import UIKit

class NetworkCheckViewContorller: UIViewController {
    
    
    
    var getBtn:UIButton = {
        let btn = UIButton.init()
        btn.setTitle("get", for: .normal)
        btn.setTitleColor(.red, for: .normal)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.cornerRadius = 20
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(tapOnget), for: .touchUpInside)
        return btn
    }()
    
    var postBtn:UIButton = {
        let btn = UIButton.init()
        btn.setTitle("post", for: .normal)
        btn.setTitleColor(.red, for: .normal)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.cornerRadius = 20
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(tapOnpost), for: .touchUpInside)
        return btn
    }()
    
    var params:[String:Any]?

    override func viewDidLoad() {
        super.viewDidLoad()

        
        //params 需要手动输入
        
        
        self.view.addSubview(getBtn)
        self.view.addSubview(postBtn)
        
        getBtn.frame = CGRect.init(x: self.view.frame.size.width / 2 - 80, y: 120, width: 160, height: 40)
        postBtn.frame = CGRect.init(x: self.view.frame.size.width / 2 - 80, y: 200, width: 160, height: 40)
        
        
        
    }
    
    @objc func tapOnget() {
        
    }
    
    @objc func tapOnpost() {
        
        
        //post 测试接口
        /**
        * http://api.ivygate.vip/api/system_set/get_user_explain
        * http://api.ivygate.vip/api/system_set/get_vip_explain
        * http://api.ivygate.vip/api/vip_package/get_list
        */
        
        DispatchQueue.global().async {
            NetworkTestManager.manager.post(with: "http://api.ivygate.vip/api/system_set/get_user_explain", params: nil)
        }
        
//        DispatchQueue.global().async {
//            NetworkTestManager.manager.post(with: "http://api.ivygate.vip/api/system_set/get_vip_explain", params: nil)
//        }
//        
//        DispatchQueue.global().async {
//            NetworkTestManager.manager.post(with: "http://api.ivygate.vip/api/vip_package/get_listn", params: nil)
//        }
        
    }
    


}
