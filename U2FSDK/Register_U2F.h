//
//  BLE4.h
//  U2FSDK
//
//  Created by 九州云腾 on 15/11/26.
//  Copyright © 2015年 九州云腾. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "U2FStartRegisterRequest.h"
#import "BlePeripheral.h"
#import "RegisterInfo.h"
#import "VertifyInfo.h"
#import "U2F_Protocol.h"
#import "BlePeripheral.h"
#import "UIUtils.h"
#import "RegisterSuccessData.h"
@interface Register_U2F : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate,U2F_Protocol>

-(void)startRegisterRequest:(U2FStartRegisterRequest *)registerData
                 Peripheral:(BlePeripheral *)peripheral
             Characteristic:(NSString *)writeCharacteristic;
@property(nonatomic,strong)CBCentralManager *m_manger;
@property(nonatomic,strong)NSMutableArray   *m_array_peripheral;
@property(nonatomic,assign)id<U2F_Protocol>  u2f_protocol_delegate;


@end
