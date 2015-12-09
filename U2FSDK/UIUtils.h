//
//  UIUtils.h
//  美丽中国
//
//  Created by 九州云腾 on 15/11/23.
//  Copyright (c) 2015年 司马帅帅. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import<CommonCrypto/CommonDigest.h>

@interface UIUtils : NSObject
+(Byte *)getString:(NSString *)srcString and:(NSString *)string;

+(NSString *)uploadingData: (NSData *)data;

@end
