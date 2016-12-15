/*================================================================
 *   Copyright (C) 2014 All rights reserved.
 *
 *   文件名称：MessageModel.h
 *   创 建 者：Zhang Yuanhao
 *   邮    箱：bluefoxah@gmail.com
 *   创建日期：2014年12月15日
 *   描    述：
 *
 ================================================================*/

#ifndef SYSTEM_MSG_MODEL_H_
#define SYSTEM_MSG_MODEL_H_

#include <list>
#include <string>

#include "util.h"
#include "ImPduBase.h"
#include "AudioModel.h"
#include "IM.BaseDefine.pb.h"
#include "IM.Buddy.pb.h"
using namespace std;

typedef enum _SysType{
	ADD_FRIEND,
	SYSTEM
}SysType;

class CSystemMsgModel {
public:
	virtual ~CSystemMsgModel();
	static CSystemMsgModel* getInstance();

    bool sendSystemMsg(uint32_t nFromId, uint32_t nToId, IM::BaseDefine::SystemMsgType nMsgType,
    		uint32_t nMsgId, string& strMsgContent, uint32_t nStatus);
    void getSystemMsg(uint32_t nUserId, uint32_t nMsgId, uint32_t nMsgCnt,
    		list<IM::BaseDefine::MsgInfo>& lsMsg);
    bool getUnreadSysMsgCount(uint32_t nUserId, uint32_t &nTotalCnt,
    		SysType type);
    //void getUnReadCntAll(uint32_t nUserId, uint32_t &nTotalCnt);
    void clearSysMsgCounter(uint32_t nUserId, SysType type);

    void getAddFriendMsg(uint32_t nUserId, uint32_t nMsgId, uint32_t nMsgCnt,
    		IM::Buddy::IMGetAddFriendDataRsp& resp);

private:
    CSystemMsgModel();
    void incMsgCount(uint32_t nToId, SysType type);
private:
	static CSystemMsgModel*	m_pInstance;
};



#endif
