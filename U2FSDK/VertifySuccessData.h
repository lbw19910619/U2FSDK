//
//  VertifySuccessData.h
//  U2FSDK
//
//  Created by 九州云腾 on 15/11/27.
//  Copyright © 2015年 九州云腾. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VertifySuccessData : NSObject
@property(strong,nonatomic)NSString *keyHandle;
@property(strong,nonatomic)NSString *vertifyDataString;
@property(strong,nonatomic)NSString *client_data_string;
@end
