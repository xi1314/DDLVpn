

Alrd_rust  install  appversion:1.0 alrd_version 0.1.4

1, 集成Alrd.a , Alrd.h 文件到NetworkExtension 扩展框架下 ；并且引入Alrd.h类
2，添加PacketProcessor
   2.1 导入demo中PacketProcessor 的所有文件
   2.2 对照demo中的Packetprocessor框架下的BuildPhases 主要修改Headers ，和CompileSources 选项
   2.3 对照demo中的Packetprocessor框架下BuildSetting 修改searchPaths 下的路径 
   2.4 对照demo中的Packetprocessor框架下BuildSetting 在 Preprocessor Macors添加对应缺失的宏
3，主程序中VpnManager 为主要入口类，处理客户端所有的vpn连接以及监听

--------------------------------------------------------------------------------------------------------------


Alrd_rust install appverison 2.0 alrd_version 0.2.2

1, 集成Alrd.a , Alrd.h 文件到NetworkExtension 扩展框架下 ；并且引入Alrd.h类
2,修改PacketTunnelProvider内代码，详情见demo
3，数据原理：直接获取tun设备的流量，不经过tun2socks转发
4，添加白名单功能，功能规则为 "allow/dency/direct" + " " + "ip/domain"
(连接策略字符串 + 空格 + 具体的ip地址或者域名 ， 并且每一个规则之间用封号隔开)


------------------------------------------------------------------------------------------------------------

Alrd_rust install appversion 2.1 alrd_version 0.2.5

修改由于sdk http get 引发的ip sdk http resolver failed 的错误
key function
  
  
  void run_with_mode(const char *app_mode,
                     const char *http_address,
                     const char *socks_address,
                     const char *fake_dns_address,
                     const char *fake_pool,
                     const char *log_level,
                     const char *proxy_url,
                     const char *up_dns_address,
                     const char *domain_rules,
                     const char *ip_rules,
                     const char *tun_fd);
                   
   void stop(void);

key words 

app_mode:value = "allow_gfw" or ""
fake_dns_address =  “127.0.0.1:53” (default) 或者 通过DNSConfig.getSystemDnsServers()[0] as! String 获取
proxy_url = "加速服务器地址"
domain_rules = 域名规则
ip_rules = ip规则
tun_fd : 获取方式：let tunFd = self.packetFlow.value(forKeyPath: "socket.fileDescriptor") as! Int32
domain_rules/ip_rules 转化方法函数


func dealDomains(_ list:[String]) -> String{
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

// 未做说明字段可以不用传入 

change:sdk已解决httpproxy get无法响应的bug
install：替换原来libarld4.a  


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

 version2.0 build 1.1
 
 changelog :修改文档说明， 前面记录可以忽略
 
 install 
  导入libalrd4.a 文件 和相关头文件
  函数参数说明：
  
  app_mode:value = "allow_gfw" or ""
  fake_dns_address =  “127.0.0.1:53” (default) 或者 通过DNSConfig.getSystemDnsServers()[0] as! String 获取
  proxy_url = "加速服务器地址"
  domain_rules = 域名规则
  ip_rules = ip规则
  tun_fd : 获取方式：let tunFd = self.packetFlow.value(forKeyPath: "socket.fileDescriptor") as! Int32
  domain_rules/ip_rules  传入规则: (allow/dency/direct) + " " + 域名或ip
  未说明参数可以不用传入
  
  
 ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

version2.2 ,build 1.0 

add http proxy sync with tun interface

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

version2.3 ， build 1.0

rust sdk 0.2.7 alpha :优化了fakedns和fake pool

delete http proxy





  
 

