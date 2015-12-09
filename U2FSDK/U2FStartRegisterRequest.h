//
//  U2FStartRegisterRequest.h
//  U2FSDK
//
//  Created by 九州云腾 on 15/11/26.
//  Copyright © 2015年 九州云腾. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface U2FStartRegisterRequest : NSObject
@property(strong,nonatomic)NSArray *registerInfoArray;
@property(strong,nonatomic)NSArray *vertifInfoyArray;

@end
