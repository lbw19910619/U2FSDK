//
//  Logfile.h
//  U2FSDK
//
//  Created by 九州云腾 on 15/12/3.
//  Copyright © 2015年 九州云腾. All rights reserved.
//

#ifdef DEBUG

#define LOG(fmt, ...) do {\NSString* file = [[NSString alloc] initWithFormat:@"%s", __FILE__]; \NSLog((@"%@(%d) " fmt), [file lastPathComponent], __LINE__, ##__VA_ARGS__);} while(0)
#define LOG_METHOD NSLog(@"%s", __func__)

#define LOG_CMETHOD NSLog(@"%@/%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd))

#define COUNT NSLog(@"%s  count = %d\n  %@", __func__, __LINE__,[NSThread currentThread]);

#define LOG_TRACE(x) do {printf x; putchar('\n'); fflush(stdout);} while (0)

#else

#define LOG(...)

#define LOG_METHOD

#define LOG_CMETHOD

#define COUNT(p)

#efine LOG_TRACE(x)

#endif

