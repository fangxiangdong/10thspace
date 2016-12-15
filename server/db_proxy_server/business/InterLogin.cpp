/*================================================================
*     Copyright (c) 2015年 lanhu. All rights reserved.
*   
*   文件名称：InterLogin.cpp
*   创 建 者：Zhang Yuanhao
*   邮    箱：bluefoxah@gmail.com
*   创建日期：2015年03月09日
*   描    述：
*
================================================================*/
#include "InterLogin.h"
#include "../DBPool.h"
#include "EncDec.h"
#include "json/json.h"

bool CInterLoginStrategy::doLogin(const std::string &strDomain, const std::string &strPass, IM::BaseDefine::UserInfo* pUser)
{
    return true;
}
