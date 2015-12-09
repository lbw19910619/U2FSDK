//
//  Authenticate_U2F.h
//  U2FSDK
//
//  Created by 九州云腾 on 15/11/24.
//  Copyright © 2015年 九州云腾. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "U2FStartVirtifyRequest.h"
#import "BlePeripheral.h"
#import "JSONKit.h"
#import "RegisterInfo.h"
#import "U2F_Protocol.h"
#import "UIUtils.h"
#import "VertifyInfo.h"
#import "VertifySuccessData.h"
@interface Authenticate_U2F : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>

-(void)startVertifyRequest:(U2FStartVirtifyRequest *)registerData
                 Peripheral:(BlePeripheral *)peripheral
             Characteristic:(NSString *)writeCharacteristic;
@property(nonatomic,strong)CBCentralManager *m_manger;
@property(nonatomic,strong)NSMutableArray   *m_array_peripheral;

@property(nonatomic,weak)id<U2F_Protocol> u2f_protocol_delegate;
@end
