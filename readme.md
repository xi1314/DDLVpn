

Alrd_rust  install 

1, 集成Alrd.a , Alrd.h 文件到NetworkExtension 扩展框架下 ；并且引入Alrd.h类
2，添加PacketProcessor
   2.1 导入demo中PacketProcessor 的所有文件
   2.2 对照demo中的Packetprocessor框架下的BuildPhases 主要修改Headers ，和CompileSources 选项
   2.3 对照demo中的Packetprocessor框架下BuildSetting 修改searchPaths 下的路径 
   2.4 对照demo中的Packetprocessor框架下BuildSetting 在 Preprocessor Macors添加对应缺失的宏
3，主程序中VpnManager 为主要入口类，处理客户端所有的vpn连接以及监听

--------------------------------------------------------------------------------------------------------------




