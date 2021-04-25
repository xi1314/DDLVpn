//
//  HomeViewController.swift
//  DDLVPNAlrd
//
//  Created by MrFeng on 2020/12/3.
//

import UIKit


class HomeViewController: UIViewController {
    
    var alrdView:AlrdTableView?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        
        self.alrdView = AlrdTableView.init(frame: .zero)
        self.view.addSubview(self.alrdView!)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onVPNStatusChanged_), name: NSNotification.Name(rawValue: "kProxyServiceVPNStatusNotification"), object: nil)
        
    }
    
    @objc func onVPNStatusChanged_() {
        
        switch VpnManager.shared.vpnStatus {
                case .off:
                    
                    self.alrdView?.alrdBtn.setTitleColor(.yellow, for: .normal)
                    self.alrdView?.alrdBtn.setTitle("connect", for: .normal)
                    
                    break
                   
                case .on:
                    
                    self.alrdView?.alrdBtn.setTitleColor(.green, for: .normal)
                    self.alrdView?.alrdBtn.setTitle("connected", for: .normal)
                    
                    break
                    
                case .connecting:
                    
                    self.alrdView?.alrdBtn.setTitleColor(.green, for: .normal)
                    self.alrdView?.alrdBtn.setTitle("connecting", for: .normal)
                    
                    break
                  
                case .disconnecting:
                    
                    self.alrdView?.alrdBtn.setTitleColor(.green, for: .normal)
                    self.alrdView?.alrdBtn.setTitle("disconnecting", for: .normal)
                    
                    break
                   
        }
        
    }

}
