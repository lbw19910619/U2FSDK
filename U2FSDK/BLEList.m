//
//  BLEList.m
//  U2FSDK
//
//  Created by 九州云腾 on 15/11/30.
//  Copyright © 2015年 九州云腾. All rights reserved.
//

#import "BLEList.h"
#import "BlePeripheral.h"


@interface BLEList ()
{

    GetBlePeripheral_list _blePeripheral_list;
}
@end


@implementation BLEList


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.m_manger = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
        self.m_array_peripheral=[[NSMutableArray alloc]init];
    }
    return self;
}
-(void)getBLEList:(GetBlePeripheral_list)blePeripheral_list{

    _blePeripheral_list=blePeripheral_list;
    NSArray *services = [[NSArray alloc]init];
    [self.m_manger scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES,CBCentralManagerScanOptionSolicitedServiceUUIDsKey : services }];
    
}
- (void)centralManagerDidUpdateState:(CBCentralManager *)central;
{
    if (central.state == CBCentralManagerStatePoweredOff) {
        NSLog(@"zzzzz系统蓝牙关闭了，请先打开蓝牙");
        
        
    }else{
        //可以自己判断其他的类型
        /*
         CBCentralManagerStateUnknown = 0,
         CBCentralManagerStateResetting,
         CBCentralManagerStateUnsupported,
         CBCentralManagerStateUnauthorized,
         CBCentralManagerStatePoweredOff,
         CBCentralManagerStatePoweredOn,
         */
    }
}
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
{
    
    //这个方法是一旦扫描到外设就会调用的方法，注意此时并没有连接上外设，这个方法里面，你可以解析出当前扫描到的外设的广播包信息，当前RSSI等，现在很多的做法是，会根据广播包带出来的设备名，初步判断是不是自己公司的设备，才去连接这个设备，就是在这里面进行判断的
    
    NSString *localName = [advertisementData valueForKey:@"kCBAdvDataLocalName"];
    // NSLog(@"localName = %@ RSSI = %@",localName,RSSI);
    NSArray *services = [advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"];
    
    // NSLog(@"advertisementData = %@",advertisementData);
    // NSLog(@"%@",services[0]);
    BOOL isExist = [self comparePeripheralisEqual:peripheral RSSI:RSSI];
    if (!isExist) {
        BlePeripheral *l_per = [[BlePeripheral alloc]init];
        l_per.m_peripheral = peripheral;
        l_per.m_peripheralIdentifier = [peripheral.identifier UUIDString];
        l_per.m_peripheralLocaName = localName;
        l_per.m_peripheralRSSI = RSSI;
        l_per.m_peripheralUUID       =(NSString *)peripheral.identifier; //IOS 7.0 之后弃用了，功能和 identifier 一样
        
        //[NSTemporaryDirectory()stringByAppendingPathComponent:[NSStringstringWithFormat:@"%@-%@", prefix, uuidStr]]
        l_per.m_peripheralServices   = [services count];
        
        
        [self.m_array_peripheral addObject:l_per];
        if ([localName isEqualToString:@""]) {
            [self.m_manger stopScan];
        }
    }
    _blePeripheral_list(self.m_array_peripheral);
    
   
    // NSLog(@"%ld",self.m_array_peripheral.count);
    
    
}
-(BOOL) comparePeripheralisEqual :(CBPeripheral *)disCoverPeripheral RSSI:(NSNumber *)RSSI
{
    if ([self.m_array_peripheral count]>0) {
        for (int i=0;i<[self.m_array_peripheral count];i++) {
            BlePeripheral *l_per = [self.m_array_peripheral objectAtIndex:i];
            if ([disCoverPeripheral isEqual:l_per.m_peripheral]) {
                l_per.m_peripheralRSSI = RSSI;
                return YES;
            }
        }
    }
    return NO;
}

@end
