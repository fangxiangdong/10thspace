/*================================================================
*     Copyright (c) 2015年 lanhu. All rights reserved.
*   
*   文件名称：UserModel.h
*   创 建 者：Zhang Yuanhao
*   邮    箱：bluefoxah@gmail.com
*   创建日期：2015年01月05日
*   描    述：
*
#pragma once
================================================================*/
#ifndef __USERMODEL_H__
#define __USERMODEL_H__

#include "IM.BaseDefine.pb.h"
#include "IM.Buddy.pb.h"
#include "ImPduBase.h"
#include "public_define.h"
class CUserModel
{
public:
    static CUserModel* getInstance();
    ~CUserModel();
    void getChangedId(uint32_t& nLastTime, list<uint32_t>& lsIds);
    void getUsers(list<uint32_t> lsIds, list<IM::BaseDefine::UserInfo>& lsUsers);
    void getUsers2(uint32_t nUserId,uint32_t nLastTime,IM::Buddy::IMAllUserRsp& msgResp);
    bool getUserById(uint32_t nUserId, DBUserInfo_t& cUser);

    bool updateUser(uint32_t user_id, IM::BaseDefine::UserInfo &cUser);
    bool insertUser(DBUserInfo_t& cUser);
    int  insertUser2(string &sName,string &sPass);
    void changeAvatar(uint32_t nUserId,string &avatar);

//    void getUserByNick(const list<string>& lsNicks, list<IM::BaseDefine::UserInfo>& lsUsers);
    void clearUserCounter(uint32_t nUserId, uint32_t nPeerId, IM::BaseDefine::SessionType nSessionType);
    void setCallReport(uint32_t nUserId, uint32_t nPeerId, IM::BaseDefine::ClientType nClientType);

    bool updateUserSignInfo(uint32_t user_id, const string& sign_info);
    bool getUserSingInfo(uint32_t user_id, string* sign_info);
    bool updatePushShield(uint32_t user_id, uint32_t shield_status);
    bool getPushShield(uint32_t user_id, uint32_t* shield_status);

    void getUsersByNickOrPhone(string &sName,list<IM::BaseDefine::UserInfo> &lsUsers);

    bool updateFansCnt(uint32_t user_id, bool isIncrease = true);
private:
    CUserModel();
private:
    static CUserModel* m_pInstance;
};

#endif /*defined(__USERMODEL_H__) */
