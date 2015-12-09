//
//  U2F_Protocol.h
//  U2FSDK
//
//  Created by 九州云腾 on 15/11/27.
//  Copyright © 2015年 九州云腾. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RegisterSuccessData,VertifySuccessData;

@protocol U2F_Protocol <NSObject>

//注册数据处理完成
-(void)OnRegisterRequestResultData:(RegisterSuccessData *)registerSuccessData;

//认证数据处理完成
-(void)OnVertifyRequestResultData:(VertifySuccessData *)vertifySuccessData;
//注册或认证失败的原因和errorNumber
-(void)OnError:(NSString *)failure And:(NSString *)errorNumber;
@optional
//设备连接
-(void)ConnectStart;
//连接成功
-(void)ConnectSuccess;
//连接失败
-(void)ConnectFail;
//用户确认
-(void)UserToConfirm;
//用户确认完成
-(void)UserToConfirmFinish;

//设备连接断开
- (void)U2FDisconnet;
@end
