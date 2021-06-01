//
//  HomeViewController.swift
//  DDLVPNAlrd
//
//  Created by MrFeng on 2020/12/3.
//

import UIKit


class HomeViewController: UIViewController {
    
    var alrdView:AlrdTableView?
    

    var networkcheckbtn:UIButton = {
       
        let btn = UIButton.init()
        btn.setTitle("checkNet", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor.lightGray
        btn.layer.cornerRadius = 20
        btn.layer.borderWidth = 0.5
        btn.layer.borderColor = UIColor.yellow.cgColor
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(tapOnNetcheck), for: .touchUpInside)
        return btn
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        
        self.alrdView = AlrdTableView.init(frame: .zero)
        self.view.addSubview(self.alrdView!)
        self.view.addSubview(networkcheckbtn)
        self.networkcheckbtn.frame = CGRect.init(x: self.view.frame.size.width / 2 - 80, y: self.view.frame.size.height - 80, width: 160, height: 40)
        
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
    
    @objc func tapOnNetcheck() {
        
        let netvc = NetworkCheckViewContorller.init()
        netvc.view.backgroundColor = .white
        self.present(netvc, animated: true, completion: nil)
        
        
    }

}
