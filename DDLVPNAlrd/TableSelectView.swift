//
//  TableSelectView.swift
//  DDLVPNAlrd
//
//  Created by MrFeng on 2020/12/3.
//

import UIKit

class Cell : UITableViewCell {
    
    lazy var label :UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.blue
        label.font = UIFont.systemFont(ofSize: 16)
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(label)
        label.frame = CGRect.init(x: 0, y: 0, width: self.contentView.frame.width - 60, height: 44)
        
        label.center = self.contentView.center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TableSelectView: UIView ,UITableViewDelegate , UITableViewDataSource {
    
    typealias BlockTable = (_ select:Int)->()
    var block : BlockTable?
    
    lazy var tableView:UITableView = {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .gray
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(Cell.self, forCellReuseIdentifier: "Cell")
        tableView.separatorStyle = .singleLine
        return tableView
    }()
    
    let datas = ["V_1","V_2","V_3","V_4"]

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = CGRect.init(x: 0, y: 0, width: 200, height: 70 * 3)
        self.backgroundColor = .gray
        
        self.tableView.frame = self.frame
        self.addSubview(self.tableView)
        
        self.tableView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : Cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell
        let item = datas[indexPath.row]
        cell.label.text = item
        cell.backgroundColor = .brown
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let idx = indexPath.row
        self.block!(idx)
    }
    
}
