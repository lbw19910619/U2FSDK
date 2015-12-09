//
//  Authenticate_U2F.m
//  U2FSDK
//
//  Created by 九州云腾 on 15/11/24.
//  Copyright © 2015年 九州云腾. All rights reserved.
//

#import "Authenticate_U2F.h"
#import<CommonCrypto/CommonDigest.h>
#import "GTMBase64.h"
#import "JSONKit.h"

@interface Authenticate_U2F ()<CBCentralManagerDelegate,CBPeripheralDelegate>
{
    
    NSUInteger _keyHandle_length;
    Byte *_keyHandle_byte;
    Byte *_keyHandle_length_byte;

    NSString *_clientDataString;
    NSString *_keyHandle;
    NSString *_signatureData_string;

   
    CBCharacteristic *_writeCharacteristic;
    NSString *_writeCharacteristic_string;
    BlePeripheral *_blePeripheral;
    Byte *_control_byte;
    NSArray *_vertifyArray;
    VertifyInfo *_vertifyInfo;
    VertifyInfo *_vertifyInfo_ture;
    NSInteger   _vertifyArray_count;
}

@end

@implementation Authenticate_U2F
- (instancetype)init
{
    self = [super init];
    if (self) {

        self.m_manger = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
        self.m_array_peripheral=[[NSMutableArray alloc]init];
        _vertifyArray_count=0;

    }
    return self;
}
-(void)startVertifyRequest:(U2FStartVirtifyRequest *)virtifyRequestData Peripheral:(BlePeripheral *)peripheral Characteristic:(NSString *)writeCharacteristic {

    _blePeripheral=peripheral;
    
    _writeCharacteristic_string=writeCharacteristic;
    if([self.u2f_protocol_delegate  respondsToSelector:@selector(ConnectStart)]) {
        
    [self.u2f_protocol_delegate ConnectStart];
        
    }
    if (peripheral==nil||writeCharacteristic==nil) {
        if([self.u2f_protocol_delegate  respondsToSelector:@selector(OnError:And:)]) {
            
            
        [self.u2f_protocol_delegate OnError:@"error: BlePeripheral or writeCharacteristic Cannot be nil!" And:@"101"];
        }
    }else{
        
        NSArray *services = [[NSArray alloc]init];
        //第一个参数指定了要搜寻的服务，如果传nil，表示搜寻搜有的服务
        [self.m_manger scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES,CBCentralManagerScanOptionSolicitedServiceUUIDsKey : services }];
        
        
        
        if (virtifyRequestData.vertifInfoyArray.count>0) {
            _vertifyArray=virtifyRequestData.vertifInfoyArray;
            
    }
    
        
    }
}
#pragma mark base64解码
- (Byte *)decodeKeyHandle:(NSString *)keyHandle_string{
    
    NSData *data=[GTMBase64 webSafeDecodeString:keyHandle_string];
    NSLog(@"data3data3  %@",data);
    NSLog(@"%@",[GTMBase64 stringByWebSafeEncodingData:data padded:YES]);
    Byte *testByte = (Byte *)[data bytes];
    _keyHandle_length_byte=(Byte*)malloc(1);
    _keyHandle_length_byte[0]=[data length];
    _keyHandle_length=(int)[data length];
    
    return testByte;
}

#pragma mark   CBCentralMangerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central;
{
    if (central.state == CBCentralManagerStatePoweredOff) {
        NSLog(@"系统蓝牙关闭了，请先打开蓝牙");
        
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
    }
    //if ([_blePeripheral.m_peripheral isEqual:peripheral]) {
        [self.m_manger connectPeripheral:peripheral options:nil];
    //}
    
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
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;
{
    
    [self.m_manger stopScan];
    
    peripheral.delegate=self;
    NSLog(@"已经连接上了jjjjj: %@",peripheral);
    if([self.u2f_protocol_delegate  respondsToSelector:@selector(ConnectSuccess)]) {
    
    [self.u2f_protocol_delegate ConnectSuccess];
    }
    [peripheral discoverServices:nil]; //我们直接一次读取外设的所有的： Services ,如果只想找某个服务，直接传数组进去就行，比如你只想扫描服务UUID为 FFF1和FFE2 的这两项服务
    // NSArray *array_service = [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"1800"],nil];
    
    // [peripheral discoverServices:array_service];
    
    
    
    
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error;
{
    //到这里，说明你上面调用的  [m_peripheral discoverServices:nil]; 方法起效果了，我们接着来找找特征值UUID
    NSLog(@"%@",peripheral.services);
    NSArray *services = nil;
    
    
    
    if (error != nil) {
        NSLog(@"Error %@", error);
        return ;
    }
    
    services = [peripheral services];
    if (!services || ![services count]) {
        NSLog(@"No Services");
        return ;
    }
    
    for (CBService *service in services) {
        NSLog(@"service是:%@",service.UUID);
        [peripheral discoverCharacteristics:nil forService:service];
        
    }
    
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
{
    //发现了（指定）的特征值了，如果你想要有所动作，你可以直接在这里做，比如有些属性为 notify 的 Characteristics ,你想要监听他们的值，可以这样写
    NSLog(@"发现了特征值");
    for (CBCharacteristic *c in service.characteristics) {
        if ([[c.UUID UUIDString]isEqualToString:_writeCharacteristic_string]) {
            _writeCharacteristic=c;
            VertifyInfo *vertifyInfo=_vertifyArray[0];
            
            
            _keyHandle=vertifyInfo.keyHandle;
            _vertifyInfo=vertifyInfo;
            
            //clienData
            NSDictionary *dictionary=@{@"typ":@"navigator.id.getAssertion",
                                       @"challenge":[NSString stringWithFormat:@"%@",vertifyInfo.challenge],
                                       @"origin":vertifyInfo.appId};
            
            NSString *returnString=[dictionary JSONString];
            _clientDataString=returnString;
            Byte *clientData_byte=(Byte*)malloc(64);
            clientData_byte=[UIUtils getString:_clientDataString and:vertifyInfo.appId];
            
            Byte *authenticate_byte=(Byte*)malloc(74+1+_keyHandle_length);
            authenticate_byte[0]=131;
            authenticate_byte[1]=0;
            authenticate_byte[2]=0;
            authenticate_byte[3]=0;
            authenticate_byte[4]=64;
            authenticate_byte[5]=7;
            authenticate_byte[6]=0;
            authenticate_byte[7]=0;
            authenticate_byte[8]=0;
            authenticate_byte[9]=0;
            for (int i=10; i<74; i++) {
                authenticate_byte[i]=clientData_byte[i-10];
            }
            _keyHandle_byte= [self decodeKeyHandle:vertifyInfo.keyHandle];
            for (int i=0;i<_keyHandle_length ; i++) {
                //printf("testByte = %d\n",_keyHandle_byte[i]);
            }
            authenticate_byte[74]=_keyHandle_length;
            for (int i=75; i<74+1+_keyHandle_length; i++) {
                authenticate_byte[i]=_keyHandle_byte[i-75];
            }
            _control_byte=(Byte*)malloc(1);
            _control_byte[0]=authenticate_byte[5];
            NSString *str =@"中国🇨🇳rwerwerwerwerwerewrwerwerwerwerewrwerewrwerwerewds";
            NSData *adata=[str dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        NSLog(@"_writeCharacteristic %@",c.UUID);
        if ([[c.UUID UUIDString] isEqualToString:_writeCharacteristic_string]) {
            [peripheral setNotifyValue:YES forCharacteristic:c]; //不想监听的时候，设置为：NO 就行了
        }
    }
    
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
{
    //这个可是重点了，你收的一切数据，基本都从这里得到,你只要判断一下 [characteristic.UUID UUIDString] 符合你们定义的哪个，然后进行处理就行，值为：characteristic.value 一切数据都是这个，至于怎么解析，得看你们自己的了
    //[characteristic.UUID UUIDString]  注意： UUIDString 这个方法是IOS 7.1之后才支持的,要是之前的版本，得要自己写一个转换方法
    _vertifyArray_count++;
    NSString *result = [[NSString alloc] initWithData:characteristic.value  encoding:NSUTF8StringEncoding];
    if ([result isEqualToString: @"9B00"]&&_control_byte[0]==7) {
  
        _vertifyInfo_ture=_vertifyInfo;
                _keyHandle=_vertifyInfo_ture.keyHandle;
                
                
                //clienData
                NSDictionary *dictionary=@{@"typ":@"navigator.id.getAssertion",
                                           @"challenge":[NSString stringWithFormat:@"%@",_vertifyInfo_ture.challenge],
                                           @"origin":_vertifyInfo_ture.appId};
                
                NSString *returnString=[dictionary JSONString];
                _clientDataString=returnString;
                Byte *clientData_byte=(Byte*)malloc(64);
                clientData_byte=[UIUtils getString:_clientDataString and:_vertifyInfo_ture.appId];
                
                Byte *authenticate_byte=(Byte*)malloc(74+1+_keyHandle_length);
                authenticate_byte[0]=131;
                authenticate_byte[1]=0;
                authenticate_byte[2]=0;
                authenticate_byte[3]=0;
                authenticate_byte[4]=64;
                authenticate_byte[5]=3;
                authenticate_byte[6]=0;
                authenticate_byte[7]=0;
                authenticate_byte[8]=0;
                authenticate_byte[9]=0;
                for (int i=10; i<74; i++) {
                    authenticate_byte[i]=clientData_byte[i-10];
                }
                _keyHandle_byte= [self decodeKeyHandle:_vertifyInfo_ture.keyHandle];
                for (int i=0;i<_keyHandle_length ; i++) {
                    //printf("testByte = %d\n",_keyHandle_byte[i]);
                }
                authenticate_byte[74]=_keyHandle_length;
                for (int i=75; i<74+1+_keyHandle_length; i++) {
                    authenticate_byte[i]=_keyHandle_byte[i-75];
                }
                _control_byte=(Byte*)malloc(1);
                _control_byte[0]=authenticate_byte[5];
                NSString *str =@"中国🇨🇳rwerwerwerwerwerewrwerwerwerwerewrwerewrwerwerewds";
                NSData *adata=[str dataUsingEncoding:NSUTF8StringEncoding];
        
        
    }
    else if ([result isEqualToString: @"9B01"])
    {
    
        if (_vertifyArray_count<_vertifyArray.count) {
            VertifyInfo *vertifyInfo=_vertifyArray[_vertifyArray_count];
            
            
            _keyHandle=vertifyInfo.keyHandle;
            _vertifyInfo=vertifyInfo;
            
            //clienData
            NSDictionary *dictionary=@{@"typ":@"navigator.id.getAssertion",
                                       @"challenge":[NSString stringWithFormat:@"%@",vertifyInfo.challenge],
                                       @"origin":vertifyInfo.appId};
            
            NSString *returnString=[dictionary JSONString];
            _clientDataString=returnString;
            Byte *clientData_byte=(Byte*)malloc(64);
            clientData_byte=[UIUtils getString:_clientDataString and:vertifyInfo.appId];
            
            Byte *authenticate_byte=(Byte*)malloc(74+1+_keyHandle_length);
            authenticate_byte[0]=131;
            authenticate_byte[1]=0;
            authenticate_byte[2]=0;
            authenticate_byte[3]=0;
            authenticate_byte[4]=64;
            authenticate_byte[5]=7;
            authenticate_byte[6]=0;
            authenticate_byte[7]=0;
            authenticate_byte[8]=0;
            authenticate_byte[9]=0;
            for (int i=10; i<74; i++) {
                authenticate_byte[i]=clientData_byte[i-10];
            }
            _keyHandle_byte= [self decodeKeyHandle:vertifyInfo.keyHandle];
            for (int i=0;i<_keyHandle_length ; i++) {
                //printf("testByte = %d\n",_keyHandle_byte[i]);
            }
            authenticate_byte[74]=_keyHandle_length;
            for (int i=75; i<74+1+_keyHandle_length; i++) {
                authenticate_byte[i]=_keyHandle_byte[i-75];
            }
            _control_byte=(Byte*)malloc(1);
            _control_byte[0]=authenticate_byte[5];
            NSString *str =@"中国🇨🇳rwerwerwerwerwerewrwerwerwerwerewrwerewrwerwerewds";
            NSData *adata=[str dataUsingEncoding:NSUTF8StringEncoding];
  
        }else{
        if([self.u2f_protocol_delegate  respondsToSelector:@selector(OnError:And:)]) {
    
        [self.u2f_protocol_delegate OnError:@"Bad Key Handle" And:@"103"];
         return;
        }
            
        }
        
  
    }
    else if([result isEqualToString: @"9B00"]&&_control_byte[0]==3){
    
        if([self.u2f_protocol_delegate  respondsToSelector:@selector(OnError:And:)]) {
    
        [self.u2f_protocol_delegate OnError:@"time out" And:@"102"];
        }
        return;
    }
  else  if ([result isEqualToString: @"6985"]) {
        
        if([self.u2f_protocol_delegate  respondsToSelector:@selector(UserToConfirm)]) {
        
        [self.u2f_protocol_delegate UserToConfirm];
        }
    }
    else if ([result isEqualToString: @"9000"]){
    NSLog(@"receiveData = %@,fromCharacteristic.UUID = %@",result,characteristic.UUID);
        if([self.u2f_protocol_delegate  respondsToSelector:@selector(UserToConfirmFinish)]) {
            
            [self.u2f_protocol_delegate UserToConfirmFinish];
        }
        VertifySuccessData *vertifySuccessData=[[VertifySuccessData alloc]init];
        NSData *client_data =[_clientDataString dataUsingEncoding:NSASCIIStringEncoding];
        NSString *client_data_string=[UIUtils uploadingData:client_data];
        vertifySuccessData.client_data_string=client_data_string;
        vertifySuccessData.keyHandle=_keyHandle;
        vertifySuccessData.vertifyDataString=result;
        if([self.u2f_protocol_delegate  respondsToSelector:@selector(OnVertifyRequestResultData:)]) {
        [self.u2f_protocol_delegate OnVertifyRequestResultData:vertifySuccessData];
        }
    }
    else{
    
        if([self.u2f_protocol_delegate  respondsToSelector:@selector(OnError:And:)]) {
            
            [self.u2f_protocol_delegate OnError:@"An unknown error" And:@"105"];
            return;
        }
    }
    NSLog(@"%@",error);
    
    
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
{
    //自己看看官方的说明，这个函数被调用是有前提条件的，首先你的要先调用过了 connectPeripheral:options:这个方法，其次是如果这个函数被回调的原因不是因为你主动调用了 cancelPeripheralConnection 这个方法，那么说明，整个蓝牙连接已经结束了，不会再有回连的可能，得要重来了
    NSLog(@"didDisconnectPeripheral");
    
    //如果你想要尝试回连外设，可以在这里调用一下链接函数
    /*
     [central connectPeripheral:peripheral options:@{CBCentralManagerScanOptionSolicitedServiceUUIDsKey : @YES,CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES}];
     */
    //_disconnet(@"didDisconnectPeripheral");
    
    if([self.u2f_protocol_delegate  respondsToSelector:@selector(U2FDisconnet)]){
        
        [self.u2f_protocol_delegate U2FDisconnet];
        return;
    }

   
}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
{
    //看苹果的官方解释 {@link connectPeripheral:options:} ,也就是说链接外设失败了
    NSLog(@"链接外设失败");
    if([self.u2f_protocol_delegate  respondsToSelector:@selector(ConnectFail)]){
        
        [self.u2f_protocol_delegate ConnectFail];
        return;
    }

}
-(void)GetVertifyRequestResultData:(NSString *)clientDataString keyHandle:(NSString *)keyHandle vertifyDataString:(NSString *)vertifyDataString{
    
    
}
-(void)GetRegisterRequestFailure:(NSString *)failure And:(NSString *)errorNumber{
    
    
}
-(void)GetRegisterRequestResultData:(NSString *)clientDataString registrationDataString:(NSString *)registrationDataString{
    
    
}
@end
