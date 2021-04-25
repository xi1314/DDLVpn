//
//  DNSConfig.h
//  DDLVPNAlrd
//
//  Created by MrFeng on 2020/12/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DNSConfig : NSObject

+ (NSArray *)getSystemDnsServers ;

+ (NSArray *)readFile;

+ (NSArray *)readWhiteFile;

@end

NS_ASSUME_NONNULL_END
