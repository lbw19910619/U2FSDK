//
//  BLEList.h
//  U2FSDK
//
//  Created by 九州云腾 on 15/11/30.
//  Copyright © 2015年 九州云腾. All rights reserved.
//

#import <Foundation/Foundation.h>
#import  <CoreBluetooth/CoreBluetooth.h>
@interface BLEList : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>
typedef void (^GetBlePeripheral_list)(NSArray *bleList);

-(void)getBLEList:(GetBlePeripheral_list)blePeripheral_list;
@property(nonatomic,strong)CBCentralManager *m_manger;
@property(nonatomic,strong)NSMutableArray   *m_array_peripheral;
@end
