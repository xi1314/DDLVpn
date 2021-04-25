//
//  DNSConfig.m
//  DDLVPNAlrd
//
//  Created by MrFeng on 2020/12/4.
//

#import "DNSConfig.h"
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/nameser.h>
#include <resolv.h>
#include <arpa/inet.h>

@implementation DNSConfig

+ (NSArray *)getSystemDnsServers {
    res_state res = malloc(sizeof(struct __res_state));
    res_ninit(res);
    NSMutableArray *servers = [NSMutableArray array];
    for (int i = 0; i < res->nscount; i++) {
        sa_family_t family = res->nsaddr_list[i].sin_family;
        char str[INET_ADDRSTRLEN + 1]; // String representation of address
        if (family == AF_INET) { // IPV4 address
            inet_ntop(AF_INET, & (res->nsaddr_list[i].sin_addr.s_addr), str, INET_ADDRSTRLEN);
            str[INET_ADDRSTRLEN] = '\0';
            NSString *address = [[NSString alloc] initWithCString:str encoding:NSUTF8StringEncoding];
            if (address.length) {
                [servers addObject:address];
            }
        }
    }
    res_ndestroy(res);
    free(res);
    return servers;
}

+ (NSArray *)readFile
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"blacklist" ofType:@"txt"];
    NSString *content = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *array = [self jsonStringToKeyValues:content];
    
    
    
    return  array;
}

+ (NSArray *)readWhiteFile
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"whitelist" ofType:@"lst"];
    NSString *content = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *array = [self jsonStringToKeyValues:content];
    
    
    
    return  array;
}

//json字符串转化成OC键值对
+ (id)jsonStringToKeyValues:(NSString *)JSONString {
    
    NSArray *array = [JSONString componentsSeparatedByString:@"\n"];
    NSMutableArray *sortArray = [NSMutableArray new];
    int i = 0;
    int max = 0;
    if (array.count < 50000) {
        max = array.count;
    }else {
        max = 50000;
    }
    
//    max = 10;
    
    for (i = 0 ; i < max; i++) {
        
        NSString *item = array[i];
        
        if (item != nil && ![item  isEqual: @""] && item != NULL) {
            NSString *formatString = @".";
            NSString *newstring = [formatString stringByAppendingString:item];
            [sortArray addObject:newstring];
        }
        
    }
    
    return sortArray;
}

@end
