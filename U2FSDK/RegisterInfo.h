//
//  RegisterInfo.h
//  U2FSDK
//
//  Created by 九州云腾 on 15/11/26.
//  Copyright © 2015年 九州云腾. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RegisterInfo : NSObject
@property(strong,nonatomic)NSString *challenge;
@property(strong,nonatomic)NSString *appId;
@property(strong,nonatomic)NSString *version;
@property(strong,nonatomic)NSString *type;

@end
