//
//  ViewController.m
//  U2FSDK
//
//  Created by 九州云腾 on 15/11/25.
//  Copyright © 2015年 九州云腾. All rights reserved.
//

#import "ViewController.h"
#import "Register_U2F.h"
#import "Authenticate_U2F.h"
#import "BLEList.h"
#import "BlePeripheral.h"
@interface ViewController ()<U2F_Protocol>
{

    BlePeripheral *_blePeripheral;
    Register_U2F *register_U2F;
    Authenticate_U2F *authenticate_U2F;
    BLEList *_bleList;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    NSString *fileName = [NSString stringWithFormat:@"MrNSLog.txt"];// 注意不是NSData!
    
    NSString *logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
    
    NSLog(@"%@",logFilePath);
    register_U2F=[[Register_U2F alloc]init];
    
    register_U2F.u2f_protocol_delegate=self;
    
    _bleList=[[BLEList alloc]init];
    
    authenticate_U2F=[[Authenticate_U2F alloc]init];
    authenticate_U2F.u2f_protocol_delegate=self;
}
- (IBAction)click:(id)sender {
    
    [_bleList getBLEList:^(NSArray *bleList) {
        //NSLog(@"%@",bleList);
        for (int i=0;i<bleList.count;i++) {
             BlePeripheral *blePeripheral= bleList[i];
            if ([blePeripheral.m_peripheralLocaName isEqualToString:@"BabyBluetoothStubOnOSX"]) {
                _blePeripheral=blePeripheral;
            }
            NSLog(@"%@", blePeripheral.m_peripheralLocaName);
            //NSLog(@"111%@",blePeripheral.m_peripheralName);

        }

    }];
    
     
}
- (IBAction)cccccc:(id)sender {
    
    NSLog(@"%@",_blePeripheral.m_peripheralLocaName);
    [register_U2F startRegisterRequest:nil Peripheral:_blePeripheral Characteristic:@"FFF1"];
    
    
}
-(void)ConnectStart{


}
-(void)OnError:(NSString *)failure And:(NSString *)errorNumber{

    NSLog(@"%@",failure);
    NSLog(@"%@",errorNumber);
}
-(void)OnVertifyRequestResultData:(VertifySuccessData *)vertifySuccessData{

    NSLog(@"%@  %@ %@",vertifySuccessData.client_data_string,vertifySuccessData.keyHandle,vertifySuccessData.vertifyDataString);
}
-(void)OnRegisterRequestResultData:(RegisterSuccessData *)registerSuccessData{

    NSLog(@"%@ %@",registerSuccessData.client_data_string,registerSuccessData.registrationDataString);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
