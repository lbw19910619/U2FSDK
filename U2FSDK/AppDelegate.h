//
//  AppDelegate.h
//  U2F SDK
//
//  Created by 九州云腾 on 15/11/19.
//  Copyright © 2015年 九州云腾. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{

    UIWindow *window;
    
    ViewController *mainView; //在此定义
}
@property (strong, nonatomic) UIWindow *window;


@end

