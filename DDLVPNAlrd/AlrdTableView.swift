//
//  AlrdTableView.swift
//  DDLVPNAlrd
//
//  Created by MrFeng on 2020/12/2.
//

import UIKit

struct AlrdShowModel {
    var ask : String?
    var ans : String?
    
    init() {
        self.ask = ""
        self.ans = ""
    }
}

class AlrdTableView: UIView {
    
    var bgView:UIView?
    var model:Model?
    var alrdVersion = 1
    
    lazy var selectView = TableSelectView.init(frame: .zero)
    
    lazy var selectItemButton:UIButton = {
        
        let button = UIButton.init(type: .custom)
        button.setTitle("Alrd_rust", for: .normal)
        button.setTitleColor(.green, for: .normal)
        button.addTarget(self, action: #selector(tapOnSelect), for: .touchUpInside)
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        return button
        
    }()
    
    
    lazy var whiteItemButton:UIButton = {
        
        let button = UIButton.init(type: .custom)
        button.setTitle("white", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.setTitleColor(.green, for: .selected)
        button.isSelected = true
        button.addTarget(self, action: #selector(tapOnWhite), for: .touchUpInside)
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.cornerRadius = 4
        button.isHidden = true
        button.layer.masksToBounds = true
        return button
        
    }()
    
    
    lazy var blackItemButton:UIButton = {
        
        let button = UIButton.init(type: .custom)
        button.setTitle("black", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.setTitleColor(.green, for: .selected)
        button.addTarget(self, action: #selector(tapOnBlack), for: .touchUpInside)
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.cornerRadius = 4
        button.isHidden = true
        button.layer.masksToBounds = true
        return button
        
    }()
    
    
    lazy var savebtn:UIButton = {
       
        let button = UIButton.init(type: .custom)
        button.setTitle("save", for: .normal)
        button.setTitleColor(.systemRed, for: .highlighted)
        button.setTitleColor(.green, for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(save), for: .touchUpInside)
        return button
    }()
    
    lazy var alrdBtn:UIButton  = {
       
        let button = UIButton.init(type: .custom)
        button.setTitle("connect", for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.setTitleColor(.yellow, for: .normal)
        button.addTarget(self, action: #selector(tapOnConnect), for: .touchUpInside)
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        return button
    }()
    var alrdShowModelArray = [AlrdShowModel]()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        self.frame = UIScreen.main.bounds
        self.backgroundColor = UIColor.init(named: "#484848")
        
        self.model = Model()
        self.createAlrdShowModel()
        let itemHeight :CGFloat =  CGFloat(self.alrdShowModelArray.count * 44 + 40)
        let itemHorSpace:CGFloat = 0
        let itemWidth:CGFloat = UIScreen.main.bounds.width - itemHorSpace * 2
        
        
        
        self.bgView = UIView.init(frame: CGRect.init(x: 0, y: 200, width: itemWidth, height: itemHeight))

        self.bgView?.layer.cornerRadius = 6
        self.bgView?.layer.masksToBounds = true
        
        self.addSubview(self.bgView!)
        
        self.alrdBtn.frame = CGRect.init(x: 30, y: (self.bgView?.frame.maxY)! + 60, width: self.frame.size.width - 60, height: 40)
        self.addSubview(self.alrdBtn)
        
        self.savebtn.frame = CGRect.init(x: 200, y: self.alrdBtn.frame.maxY + 30, width: 70, height: 50)
        self.addSubview(self.savebtn)
        
        self.addSubview(self.whiteItemButton)
        self.addSubview(self.blackItemButton)
        
        VpnManager.shared.blackwords.removeAll()
        VpnManager.shared.siteKeywords = (DNSConfig.readWhiteFile() as? [String])!
        
        self.selectItemButton.frame = CGRect.init(x: 30, y: 100, width: self.frame.size.width - 60, height: 40)
        self.whiteItemButton.frame = CGRect.init(x: 30, y: 160, width: 100, height: 40)
        self.blackItemButton.frame = CGRect.init(x: self.whiteItemButton.frame.maxX + 40, y: 160, width: 100, height: 40)
        self.addSubview(self.selectItemButton)
        self.createItem()
        
        self.check()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createAlrdShowModel() {
        
        /**
         var password : String?
         var whitelist : [String]?
         var blacklist : [String]?
         var updns : String?
         var tun2socksAddr : String?
        */
        
        var alrdItemModel1 = AlrdShowModel()
            alrdItemModel1.ask = "server"
            alrdItemModel1.ans = ""
        var alrdItemModel2 = AlrdShowModel()
            alrdItemModel2.ask = "port"
            alrdItemModel2.ans = ""
        var alrdItemModel3 = AlrdShowModel()
            alrdItemModel3.ask = "username"
            alrdItemModel3.ans = ""
        var alrdItemModel4 = AlrdShowModel()
            alrdItemModel4.ask = "password"
            alrdItemModel4.ans = ""
//        var alrdItemModel5 = AlrdShowModel()
//            alrdItemModel5.ask = "localdns"
//            alrdItemModel5.ans = (DNSConfig.getSystemDnsServers()[0] as! String)
//        alrdItemModel5.ans = "127.0.0.1"
        var alrdItemModel6 = AlrdShowModel()
            alrdItemModel6.ask = "tun2socksAddr"
            alrdItemModel6.ans = ""
       
        self.alrdShowModelArray.append(alrdItemModel1)
        self.alrdShowModelArray.append(alrdItemModel2)
        self.alrdShowModelArray.append(alrdItemModel3)
        self.alrdShowModelArray.append(alrdItemModel4)
//        self.alrdShowModelArray.append(alrdItemModel5)
        self.alrdShowModelArray.append(alrdItemModel6)
        
    }
    
    func createItem() {
        
        var itemTop:CGFloat = 20
        for i in 0 ..< self.alrdShowModelArray.count {
            itemTop = CGFloat(20 + 44 * i)
            var mode = self.alrdShowModelArray[i]
            let itemView = ItemView.init(frame: CGRect.init(x: 0, y: itemTop, width: self.bgView!.frame.size.width, height: 44))
                itemView.tag = 1000 + i
            itemView.leftLabel.text = mode.ask?.appending(":")
            itemView.textfield.text = ""
            if mode.ask == "localdns" {
                itemView.textfield.text = (DNSConfig.getSystemDnsServers()[0] as! String)
//                itemView.textfield.text = "127.0.0.1"
            }
            
            itemView.block = { (str , tag) in
                mode.ans = str
                let idx = tag - 1000
                if idx >= 0 && idx < 6 {
                    self.alrdShowModelArray.remove(at: idx)
                    self.alrdShowModelArray.insert(mode, at: idx)
                }
                print("\(mode.ans ?? "----")")
                print("alrdShowModelArray\(self.alrdShowModelArray[i])")
                
                self.check()
            }
            self.bgView!.addSubview(itemView)
            
            
            let line = UIView.init(frame: CGRect.init(x: itemView.textfield.frame.minX, y: itemView.frame.maxY, width: itemView.textfield.frame.width - 20, height: 0.5))
            line.backgroundColor = UIColor.lightGray
            self.bgView?.addSubview(line)
            
            
        }
        
        
    }
    
    func combine() {
        
        for i in 0 ..< self.alrdShowModelArray.count {
            
            let alrdmodel = self.alrdShowModelArray[i]
            if alrdmodel.ask == "server" {
                model?.services = alrdmodel.ans
            }
            if alrdmodel.ask == "port" {
                model?.port = alrdmodel.ans
            }
            
            if alrdmodel.ask == "password" {
                model?.password = alrdmodel.ans
            }
            if alrdmodel.ask == "localdns" {
                model?.localdns = alrdmodel.ans
            }
            if alrdmodel.ask == "username" {
                model?.username = alrdmodel.ans
            }
            if alrdmodel.ask == "tun2socksAddr" {
                model?.tun2socksAddr = alrdmodel.ans
            }
            
        }
        
    }
    
    @objc func tapOnBlack() {
        
        self.blackItemButton.isSelected = true
        self.whiteItemButton.isSelected = false
        
        listInuse()
        
    }
    
    @objc func tapOnWhite() {
        
        self.blackItemButton.isSelected = false
        self.whiteItemButton.isSelected = true
        
        listInuse()
        
    }
    
    
    func listInuse() {
        
        if self.blackItemButton.isSelected == true {
            VpnManager.shared.blackwords =  (DNSConfig.readFile() as? [String])!
            VpnManager.shared.siteKeywords.removeAll()
        }else {
            
            VpnManager.shared.blackwords.removeAll()
            VpnManager.shared.siteKeywords = (DNSConfig.readWhiteFile() as? [String])!
            
        }
        
    }
    
    @objc func tapOnConnect() {
        
        self.combine()
        self.check()
        VpnManager.shared.model = self.model
        VpnManager.shared.alrdVersion = self.alrdVersion
        
        
        if VpnManager.shared.vpnStatus == .off {
            VpnManager.shared.connect()
        }else {
            VpnManager.shared.disconnect()
        }
        
        
    }
    
    @objc func tapOnSelect() {
       

        
        
        self.load()
        self.configure()
        self.check()
        
    }
    
    func check() {
        for i in 0 ..< self.alrdShowModelArray.count {
            let item = self.alrdShowModelArray[i]
            if item.ans?.count == 0 || item.ans == "" {
                self.alrdBtn.isEnabled = false
                break
            }else {
                self.alrdBtn.isEnabled = true
            }
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let view = touches.first?.view , view == self {
            
            self.endEditing(true)
        }
        
    }
    
}

class ItemView:UIView {
    
    typealias  Block = (_ str: String , _ tag:Int) -> ()
    var block :Block?
    
    lazy var leftLabel:UILabel = {
        let label = UILabel.init()
            label.textColor = UIColor.black
            label.font = UIFont.systemFont(ofSize: 18)
        self.addSubview(label)
            return label
    }()
    
    lazy var textfield: UITextField = {
        let field = UITextField.init()
        field.placeholder = ""
        field.textColor = UIColor.blue
        field.font = UIFont.systemFont(ofSize: 14)
        field.addTarget(self, action: #selector(textContentChanged), for: .editingChanged)
        self.addSubview(field)
        return field
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        leftLabel.frame = CGRect.init(x: 5, y: 0, width: 100, height: self.frame.size.height)
        
        textfield.frame = CGRect.init(x: leftLabel.frame.maxX + 30, y: 0, width: self.frame.size.width - leftLabel.frame.size.width - 20, height: self.frame.size.height)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func textContentChanged() {
        
        if self.leftLabel.text == "localdns:" {
            self.textfield.text = (DNSConfig.getSystemDnsServers()[0] as! String)
//            self.textfield.text = "127.0.0.1"
            print("getSystemDnsServers--\(self.textfield.text)")
            
        }
        
        self.block!(self.textfield.text ?? "" , self.tag)
        
    }
    
}


extension AlrdTableView {
    
    func load() {
        
        if let   server = UserDefaults.standard.value(forKey: "server") as? String , server.count > 0 {
            
            self.model?.services = UserDefaults.standard.value(forKey: "server") as! String
            self.model?.port = UserDefaults.standard.value(forKey: "port") as! String
            self.model?.username = UserDefaults.standard.value(forKey: "username") as! String
            self.model?.password = UserDefaults.standard.value(forKey: "password") as! String
            self.model?.tun2socksAddr = UserDefaults.standard.value(forKey: "tun2socksAddr") as! String
            self.model?.localdns = (DNSConfig.getSystemDnsServers()[0] as! String)
//            self.model?.localdns = "127.0.0.1"
            
        }
        self.model?.services = "light-alpha.int.automesh.org"
        self.model?.port = "29951"
        self.model?.username = "test"
        self.model?.password = "jl20fdg"
        self.model?.tun2socksAddr = "127.0.0.1:9091"
        self.model?.localdns = (DNSConfig.getSystemDnsServers()[0] as! String)
//        self.model?.localdns = "127.0.0.1"
        
    }
    
    @objc func save() {
        
        if model?.services?.count == 0 {
            return
        }
        
        UserDefaults.standard.setValue(model?.services, forKey: "server")
        UserDefaults.standard.setValue(model?.password, forKey: "password")
        UserDefaults.standard.setValue(model?.username, forKey: "username")
        UserDefaults.standard.setValue(model?.port, forKey: "port")
        UserDefaults.standard.setValue(model?.localdns, forKey: "localdns")
        UserDefaults.standard.setValue(model?.tun2socksAddr, forKey: "tun2socksAddr")
        
    }
    
    
    func getFromUserdefault() {
        
        self.model?.services = UserDefaults.standard.value(forKey: "server") as! String
        self.model?.port = UserDefaults.standard.value(forKey: "port") as! String
        self.model?.username = UserDefaults.standard.value(forKey: "username") as! String
        self.model?.password = UserDefaults.standard.value(forKey: "password") as! String
        self.model?.tun2socksAddr = UserDefaults.standard.value(forKey: "tun2socksAddr") as! String
        self.model?.localdns = UserDefaults.standard.value(forKey: "localdns") as! String
        
    }
    
    
    func configure() {
        
        for i in 0 ..< self.alrdShowModelArray.count {
            
            let tag = 1000 + i
            let itemview:ItemView = self.viewWithTag(tag) as! ItemView
            var item = self.alrdShowModelArray[i]
//            let alrdmodel = self.alrdShowModelArray[i]
            if itemview.leftLabel.text == "server:" {
                itemview.textfield.text = self.model?.services
                item.ans = self.model?.services
                self.alrdShowModelArray.remove(at: i)
                self.alrdShowModelArray.insert(item, at: i)
            }
            if itemview.leftLabel.text == "port:" {
                itemview.textfield.text = self.model?.port
                item.ans = self.model?.port
                self.alrdShowModelArray.remove(at: i)
                self.alrdShowModelArray.insert(item, at: i)
            }
            
            if itemview.leftLabel.text == "password:" {
                itemview.textfield.text = self.model?.password
                item.ans = self.model?.password
                self.alrdShowModelArray.remove(at: i)
                self.alrdShowModelArray.insert(item, at: i)
            }
            
            if itemview.leftLabel.text == "localdns:" {
                itemview.textfield.text = self.model?.localdns
                item.ans = self.model?.localdns
                self.alrdShowModelArray.remove(at: i)
                self.alrdShowModelArray.insert(item, at: i)
            }
            if itemview.leftLabel.text == "username:" {
                itemview.textfield.text = self.model?.username
                item.ans = self.model?.username
                self.alrdShowModelArray.remove(at: i)
                self.alrdShowModelArray.insert(item, at: i)
            }
            if itemview.leftLabel.text == "tun2socksAddr:" {
                itemview.textfield.text = self.model?.tun2socksAddr
                item.ans = self.model?.tun2socksAddr
                self.alrdShowModelArray.remove(at: i)
                self.alrdShowModelArray.insert(item, at: i)
            }
        }
        
        
    }
    
}
