//
//  CONSTANT.h
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-23.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

/**
 *  Debug模式和Release模式不同的宏定义
 */

//-------------------打印--------------------
#ifdef DEBUG
#define NEED_OUTPUT_LOG             1
#define Is_CanSwitchServer          1

#else
#define NEED_OUTPUT_LOG             0
#define Is_CanSwitchServer          0
#endif

#if NEED_OUTPUT_LOG
#define DDLog(xx, ...)                      NSLog(@"%s[line:%d]: " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DDLog(xx, ...)                 nil
#endif

#define IM_PDU_HEADER_LEN   16
#define IM_PDU_VERSION      13

//#define SERVER_ADDR                             @"http://www.d10gs.com:86/msg_server"

//#define STS_SERVER                              @"http://www.d10gs.com:86/sts"

//#define REGISTER                                @"http://www.d10gs.com:86/register"

//#define LOGINCHECK                              @"http://www.d10gs.com:86/login"

//#define GET_VALID_CODE                          @"http://www.d10gs.com:86/get_phone_valid_code"


//10thcommune.com:86
#define SERVER_ADDR                             @"http://www.10thcommune.com:86/msg_server"

#define STS_SERVER                              @"http://www.10thcommune.com:86/sts"

#define REGISTER                                @"http://www.10thcommune.com:86/register"

#define LOGINCHECK                              @"http://www.10thcommune.com:86/login"
#define FIRSTREGIST                             @"http://10thcommune.com:86/get_phone_valid_code"

#define GET_VALID_CODE                          @"http://www.10thcommune.com:86/get_phone_valid_code"

#define _(x)                                    NSLocalizedString(x,@"")

