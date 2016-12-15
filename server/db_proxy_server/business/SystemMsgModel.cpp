/*================================================================
 *   Copyright (C) 2014 All rights reserved.
 *
 *   文件名称：MessageModel.cpp
 *   创 建 者：Zhang Yuanhao
 *   邮    箱：bluefoxah@gmail.com
 *   创建日期：2014年12月15日
 *   描    述：
 *
 ================================================================*/

#include <map>
#include <set>

#include "../DBPool.h"
#include "../CachePool.h"
#include "MessageModel.h"
#include "AudioModel.h"
#include "SessionModel.h"
#include "RelationModel.h"
#include "SystemMsgModel.h"
#include "json/json.h"

using namespace std;

CSystemMsgModel* CSystemMsgModel::m_pInstance = NULL;

CSystemMsgModel::CSystemMsgModel()
{

}

CSystemMsgModel::~CSystemMsgModel()
{

}

CSystemMsgModel* CSystemMsgModel::getInstance()
{
	if (!m_pInstance) {
		m_pInstance = new CSystemMsgModel();
	}

	return m_pInstance;
}

void CSystemMsgModel::getAddFriendMsg(uint32_t nUserId, uint32_t nMsgId, uint32_t nMsgCnt,
		IM::Buddy::IMGetAddFriendDataRsp& resp)
{
	CDBManager* pDBManager = CDBManager::getInstance();
	CDBConn* pDBConn = pDBManager->GetDBConn("teamtalk_slave");
	if (pDBConn)
	{
		//string strTableName = "IMMessage_" + int2string(nRelateId % 8);
		string strTableName = "IMSysMsg_0";
		string strSql;
		//uint32_t type1 = IM::BaseDefine::ADD_FRIEND_REQUEST;
		//uint32_t type2 = IM::BaseDefine::ADD_FRIEND_AGREE;
		//uint32_t type3 = IM::BaseDefine::ADD_FRIEND_DISAGREE;

		strSql = "select "+ strTableName + ".* from " + strTableName +
				" where toId=" + int2string(nUserId) +" and (type=" +
				int2string(IM::BaseDefine::ADD_FRIEND_REQUEST) + " or type=" + int2string(IM::BaseDefine::ADD_FRIEND_AGREE) +
				" or type=" + int2string(IM::BaseDefine::ADD_FRIEND_DISAGREE) + ") order by created desc, id desc limit " + int2string(nMsgCnt);
		/*if (nMsgId == 0) {
			//第一次取时
			strSql = "select "+ strTableName + ".* from " + strTableName + " where toId= " + int2string(nUserId) + " and fromId=IMUser.id order by created desc, id desc limit " + int2string(nMsgCnt);
		}else{
			//客户端上传取到的最后一条消息，服务端将所有没取的一次返回。
			strSql = "select " + strTableName + ".* from " + strTableName + " where toId= " + int2string(nUserId) + " and msgId <=" + int2string(nMsgId)+ " and fromId=IMUser.id order by created desc, id desc limit " + int2string(nMsgCnt);
		}*/
		CResultSet* pResultSet = pDBConn->ExecuteQuery(strSql.c_str());
		if (pResultSet)
		{
			while (pResultSet->Next())
			{
				IM::Buddy::IMAddFriendData *pData = resp.add_data_list();
				pData->set_user_id(pResultSet->GetInt("fromId"));
				pData->set_friend_id(pResultSet->GetInt("toId"));
				IM::BaseDefine::SystemMsgType nMsgType = IM::BaseDefine::SystemMsgType(pResultSet->GetInt("type"));
				pData->set_type(nMsgType);
				pData->set_add_friend_data(pResultSet->GetString("content"));
			}
			delete pResultSet;
		}
		else
		{
			log("no result set: %s", strSql.c_str());
		}
		pDBManager->RelDBConn(pDBConn);
	}
	else
	{
		log("no db connection for teamtalk_slave");
	}

}


/*void CSystemMsgModel::getSystemMsg(uint32_t nUserId, uint32_t nMsgId,
                               uint32_t nMsgCnt, list<IM::BaseDefine::MsgInfo>& lsMsg)
{
	CDBManager* pDBManager = CDBManager::getInstance();
	CDBConn* pDBConn = pDBManager->GetDBConn("teamtalk_slave");
	if (pDBConn)
	{
		//string strTableName = "IMMessage_" + int2string(nRelateId % 8);
		string strTableName = "IMSysMsg_0";
		string strSql;

		if (nMsgId == 0) {
			//第一次取时
			strSql = "select "+ strTableName + ".* from " + strTableName + " where toId= " + int2string(nUserId) + " and fromId=IMUser.id order by created desc, id desc limit " + int2string(nMsgCnt);
		}
		else
		{
			//客户端上传取到的最后一条消息，服务端将所有没取的一次返回。
			strSql = "select " + strTableName + ".* from " + strTableName + " where toId= " + int2string(nUserId) + " and msgId <=" + int2string(nMsgId)+ " and fromId=IMUser.id order by created desc, id desc limit " + int2string(nMsgCnt);
		}
		CResultSet* pResultSet = pDBConn->ExecuteQuery(strSql.c_str());
		if (pResultSet)
		{
			while (pResultSet->Next())
			{
				IM::BaseDefine::MsgInfo cMsg;
				cMsg.set_msg_id(pResultSet->GetInt("msgId"));
				cMsg.set_from_session_id(pResultSet->GetInt("fromId"));
				cMsg.set_create_time(pResultSet->GetInt("created"));
				IM::BaseDefine::MsgType nMsgType = IM::BaseDefine::MsgType(pResultSet->GetInt("type"));
				if(IM::BaseDefine::MsgType_IsValid(nMsgType))
				{
					cMsg.set_msg_type(nMsgType);

					Json::Value json_obj;

					json_obj["user_nick_name"] = pResultSet->GetString("nick");
					json_obj["avatar_url"] = pResultSet->GetString("avatar");
					json_obj["addition_msg"] = pResultSet->GetString("content");
					cMsg.set_msg_data(json_obj.toStyledString().c_str());
					lsMsg.push_back(cMsg);
				}
				else
				{
					log("invalid msgType. userId=%u, msgId=%u, msgCnt=%u, msgType=%u", nUserId, nMsgId, nMsgCnt, nMsgType);
				}
			}
			delete pResultSet;
		}
		else
		{
			log("no result set: %s", strSql.c_str());
		}
		pDBManager->RelDBConn(pDBConn);
		if (!lsMsg.empty())
		{
			CAudioModel::getInstance()->readAudios(lsMsg);
		}
	}
	else
	{
		log("no db connection for teamtalk_slave");
	}

}*/

/*
 * IMMessage 分表
 * AddFriendShip()
 * if nFromId or nToId is ShopEmployee
 * GetShopId
 * Insert into IMMessage_ShopId%8
 */
bool CSystemMsgModel::sendSystemMsg(uint32_t nFromId, uint32_t nToId,
		IM::BaseDefine::SystemMsgType type, uint32_t nMsgId,
		string& strMsgContent, uint32_t nStatus)
{
    bool bRet = false;

	CDBManager* pDBManager = CDBManager::getInstance();
	CDBConn* pDBConn = pDBManager->GetDBConn("teamtalk_master");
	if (pDBConn)
    {
		uint32_t nNow = (uint32_t)time(NULL);

        //string strTableName = "IMSysMsg_" + int2string(nToId % 8);
		string strTableName = "IMSysMsg_0";
        string strSql = "insert into " + strTableName + " (`fromId`, `toId`, `msgId`, `content`, `status`, `type`, `created`, `updated`) values(?, ?, ?, ?, ?, ?, ?, ?)";
        // 必须在释放连接前delete CPrepareStatement对象，否则有可能多个线程操作mysql对象，会crash
        CPrepareStatement* pStmt = new CPrepareStatement();
        if (pStmt->Init(pDBConn->GetMysql(), strSql))
        {
            uint32_t index = 0;
            uint32_t nType = type;
            //pStmt->SetParam(index++, 0);
            pStmt->SetParam(index++, nFromId);
            pStmt->SetParam(index++, nToId);
            pStmt->SetParam(index++, nMsgId);
            pStmt->SetParam(index++, strMsgContent);
            pStmt->SetParam(index++, nStatus);
            pStmt->SetParam(index++, nType);
            pStmt->SetParam(index++, nNow);
            pStmt->SetParam(index++, nNow);
            bRet = pStmt->ExecuteUpdate();

            log("insert system message");
        }
        delete pStmt;
        pDBManager->RelDBConn(pDBConn);
        if (bRet)
        {
        	if(type == IM::BaseDefine::ADD_FRIEND_REQUEST || type == IM::BaseDefine::ADD_FRIEND_AGREE ||
        			type == IM::BaseDefine::ADD_FRIEND_DISAGREE){
        		incMsgCount(nToId, ADD_FRIEND);
        	}else{
        		incMsgCount(nToId, SYSTEM);
        	}
            log("inc sys msg count");
        }
        else
        {
            log("insert message failed: %s", strSql.c_str());
        }
	}
    else
    {
        log("no db connection for teamtalk_master");
    }
	return bRet;
}

void CSystemMsgModel::incMsgCount(uint32_t nToId, SysType type)
{
	string strKey;
	if(type == ADD_FRIEND){
		strKey = "unread_buddy_";
	}else if(type == SYSTEM){
		strKey = "unread_sys_";
	}else{
		log("type error");
		return;
	}

	CacheManager* pCacheManager = CacheManager::getInstance();
	// increase message count
	CacheConn* pCacheConn = pCacheManager->GetCacheConn("unread");
	if (pCacheConn) {
		pCacheConn->incrBy(strKey + int2string(nToId), 1);
		pCacheManager->RelCacheConn(pCacheConn);
	} else {
		log("no cache connection to increase unread_sys count: %d", nToId);
	}
}

bool CSystemMsgModel::getUnreadSysMsgCount(uint32_t nUserId, uint32_t &nTotalCnt, SysType type)
{
    string strKey;
	if(type == ADD_FRIEND){
		strKey = "unread_buddy_";
	}else if(type == SYSTEM){
		strKey = "unread_sys_";
	}else{
		log("type error");
		return false;
	}

	uint32_t bRet = -1;
	CacheManager* pCacheManager = CacheManager::getInstance();
	CacheConn* pCacheConn = pCacheManager->GetCacheConn("unread");
    if (pCacheConn)
    {
        map<string, string> mapUnread;

		strKey += int2string(nUserId);
		nTotalCnt = atoi(pCacheConn->get(strKey).c_str());
        pCacheManager->RelCacheConn(pCacheConn);
    }
    else
    {
        log("no cache connection for unread");
        return false;
    }
    return true;
}

/*void CSystemMsgModel::getUnReadCntAll(uint32_t nUserId, uint32_t &nTotalCnt)
{
    CacheManager* pCacheManager = CacheManager::getInstance();
    CacheConn* pCacheConn = pCacheManager->GetCacheConn("unread");
    if (pCacheConn)
    {
        map<string, string> mapUnread;
        string strKey = "unread_sys_" + int2string(nUserId);
        bool bRet = pCacheConn->hgetAll(strKey, mapUnread);
        pCacheManager->RelCacheConn(pCacheConn);
        
        if(bRet)
        {
            for (auto it = mapUnread.begin(); it != mapUnread.end(); it++) {
                nTotalCnt += atoi(it->second.c_str());
            }
        }
        else
        {
            log("hgetall %s failed!", strKey.c_str());
        }
    }
    else
    {
        log("no cache connection for unread");
    }
}*/

void CSystemMsgModel::clearSysMsgCounter(uint32_t nUserId, SysType type)
{
	string strKey;
	if(type == ADD_FRIEND){
		strKey = "unread_buddy_";
	}else if(type == SYSTEM){
		strKey = "unread_sys_";
	}else{
		log("type error");
		return;
	}

	CacheManager* pCacheManager = CacheManager::getInstance();
	CacheConn* pCacheConn = pCacheManager->GetCacheConn("unread");

	if (pCacheConn)
	{
		strKey += int2string(nUserId);

		bool nRet = pCacheConn->del(strKey);
		if(!nRet)
		{
			log("del failed %d", nUserId);
		}

		pCacheManager->RelCacheConn(pCacheConn);
	}
	else
	{
		log("no cache connection for sys unread");
	}
}


