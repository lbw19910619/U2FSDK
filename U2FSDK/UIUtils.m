//
//  UIUtils.m
//  美丽中国
//
//  Created by 九州云腾 on 15/11/23.
//  Copyright (c) 2015年 司马帅帅. All rights reserved.
//

#import "UIUtils.h"

@implementation UIUtils


+(Byte *)getString:(NSString *)srcString and:(NSString *)string{
    
    const char *cstr = [srcString cStringUsingEncoding:NSUTF8StringEncoding];
    
    NSData *data = [NSData dataWithBytes:cstr length:srcString.length];
    
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    
    
    CC_SHA256(data.bytes,(unsigned int)data.length, digest);
    
    const char *cstr1 = [string cStringUsingEncoding:NSUTF8StringEncoding];
    
    NSData *data1 = [NSData dataWithBytes:cstr1 length:string.length];
    
    
    uint8_t digest1[CC_SHA256_DIGEST_LENGTH];
    
    
    CC_SHA256(data1.bytes,(unsigned int)data1.length, digest1);
    
    Byte *byte=(Byte*)malloc(64);
    for(int i =0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        
        byte[i]=digest[i];
        
        
    }
    
    for(int i =0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        
        byte[i+32]=digest1[i];
        // NSLog(@"%d %d",digest1[i],i);
        
    }
    return byte;
    
}

#pragma mark base64编码
+(NSString *)uploadingData: (NSData *)data {
    
    NSString *base64String = [data base64EncodedStringWithOptions:0];
    base64String = [base64String stringByReplacingOccurrencesOfString:@"/"
                                                           withString:@"_"];
    base64String = [base64String stringByReplacingOccurrencesOfString:@"+"
                    
                                                           withString:@"-"];
    NSLog(@"base64String   %@",base64String);
    return base64String;
}
@end
