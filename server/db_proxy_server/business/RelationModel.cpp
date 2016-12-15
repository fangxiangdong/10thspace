/*================================================================
 *   Copyright (C) 2014 All rights reserved.
 *
 *   文件名称：RelationModel.cpp
 *   创 建 者：Zhang Yuanhao
 *   邮    箱：bluefoxah@gmail.com
 *   创建日期：2014年12月15日
 *   描    述：
 *
 ================================================================*/

#include <vector>

#include "../DBPool.h"
#include "RelationModel.h"
#include "MessageModel.h"
#include "GroupMessageModel.h"
using namespace std;

CRelationModel* CRelationModel::m_pInstance = NULL;

CRelationModel::CRelationModel()
{

}

CRelationModel::~CRelationModel()
{

}

CRelationModel* CRelationModel::getInstance()
{
	if (!m_pInstance) {
		m_pInstance = new CRelationModel();
	}

	return m_pInstance;
}

/**
 *  获取会话关系ID
 *  对于群组，必须把nUserBId设置为群ID
 *
 *  @param nUserAId  <#nUserAId description#>
 *  @param nUserBId  <#nUserBId description#>
 *  @param bAdd      <#bAdd description#>
 *  @param nStatus 0 获取未被删除会话，1获取所有。
 */
uint32_t CRelationModel::getRelationId(uint32_t nUserAId, uint32_t nUserBId, bool bAdd)
{
    uint32_t nRelationId = INVALID_VALUE;
    if (nUserAId == 0 || nUserBId == 0) {
        log("invalied user id:%u->%u", nUserAId, nUserBId);
        return nRelationId;
    }
    CDBManager* pDBManager = CDBManager::getInstance();
    CDBConn* pDBConn = pDBManager->GetDBConn("teamtalk_slave");
    if (pDBConn)
    {
        uint32_t nBigId = nUserAId > nUserBId ? nUserAId : nUserBId;
        uint32_t nSmallId = nUserAId > nUserBId ? nUserBId : nUserAId;
        string strSql = "select id from IMRelationShip where smallId=" + int2string(nSmallId) + " and bigId="+ int2string(nBigId) + " and status = 0";
        
        CResultSet* pResultSet = pDBConn->ExecuteQuery(strSql.c_str());
        if (pResultSet)
        {
            while (pResultSet->Next())
            {
                nRelationId = pResultSet->GetInt("id");
            }
            delete pResultSet;
        }
        else
        {
            log("there is no result for sql:%s", strSql.c_str());
        }
        pDBManager->RelDBConn(pDBConn);
        if (nRelationId == INVALID_VALUE && bAdd)
        {
        	//这里可能是用于临时对话，这样对addRelation的修改可能有问题
        	//先注掉
            //nRelationId = addRelation(nUserAId, nUserBId, RELATION_ACTION_ADD_FOLLOW);
        }
    }
    else
    {
        log("no db connection for teamtalk_slave");
    }
    return nRelationId;
}


uint32_t CRelationModel::addRelation(uint32_t nFromUserId, uint32_t nToUserId, uint32_t tag)
{
	uint32_t nBigId = nFromUserId > nToUserId ? nFromUserId : nToUserId;
	uint32_t nSmallId = nFromUserId > nToUserId ? nToUserId : nFromUserId;

	uint32_t status = 0;
    uint32_t nRelationId = INVALID_VALUE;
    CDBManager* pDBManager = CDBManager::getInstance();
    CDBConn* pDBConn = pDBManager->GetDBConn("teamtalk_master");
    if (pDBConn)
    {
        uint32_t nTimeNow = (uint32_t)time(NULL);
        string strSql = "select id,status from IMRelationShip where smallId=" + int2string(nSmallId) + " and bigId="+ int2string(nBigId);
        CResultSet* pResultSet = pDBConn->ExecuteQuery(strSql.c_str());
        if(pResultSet && pResultSet->Next())
        {
            nRelationId = pResultSet->GetInt("id");
            status = pResultSet->GetInt("status");
            //a.已是好友 status不变
            if(tag == RELATION_TYPE_FRIEND){
            	status = RELATION_TYPE_FRIEND;
            }else if (tag == RELATION_TYPE_FOLLOW_BIG){
            	if((status == RELATION_TYPE_FOLLOW_BIG && nSmallId != nFromUserId) || (status == RELATION_TYPE_FOLLOW_SMALL && nBigId != nFromUserId)){
            		status = RELATION_TYPE_FOLLOW_EACH_OTHER;
            	}
            }
            strSql = "update IMRelationShip set status=" + int2string(status) + ", updated=" + int2string(nTimeNow) + " where id=" + int2string(nRelationId);
            bool bRet = pDBConn->ExecuteUpdate(strSql.c_str());
            if(!bRet)
            {
                nRelationId = INVALID_VALUE;
            }
            log("has relation ship set status");
            delete pResultSet;
        }
        else
        {
        	if(tag == RELATION_TYPE_FRIEND){
        	    status = RELATION_TYPE_FRIEND;
        	}else if (tag == RELATION_TYPE_FOLLOW_BIG){
        	    if(nFromUserId ==  nSmallId){
        	        status = RELATION_TYPE_FOLLOW_BIG;
        	    }else{
        	    	status = RELATION_TYPE_FOLLOW_SMALL;
        	    }
        	}
            strSql = "insert into IMRelationShip (`smallId`,`bigId`,`status`,`created`,`updated`) values(?,?,?,?,?)";
            // 必须在释放连接前delete CPrepareStatement对象，否则有可能多个线程操作mysql对象，会crash
            CPrepareStatement* stmt = new CPrepareStatement();
            if (stmt->Init(pDBConn->GetMysql(), strSql))
            {
                uint32_t index = 0;
                stmt->SetParam(index++, nSmallId);
                stmt->SetParam(index++, nBigId);
                stmt->SetParam(index++, status);
                stmt->SetParam(index++, nTimeNow);
                stmt->SetParam(index++, nTimeNow);
                bool bRet = stmt->ExecuteUpdate();
                if (bRet)
                {
                    nRelationId = pDBConn->GetInsertId();
                }
                else
                {
                    log("insert message failed. %s", strSql.c_str());
                }
            }
            if(nRelationId != INVALID_VALUE)
            {
                // 初始化msgId
                if(tag == 0 && !CMessageModel::getInstance()->resetMsgId(nRelationId))
                {
                    log("reset msgId failed. smallId=%u, bigId=%u.", nSmallId, nBigId);
                }
            }
            delete stmt;
        }
        pDBManager->RelDBConn(pDBConn);
    }
    else
    {
        log("no db connection for teamtalk_master");
    }
    return nRelationId;
}

//好像没有使用
bool CRelationModel::updateRelation(uint32_t nRelationId, uint32_t nUpdateTime)
{
    bool bRet = false;
    CDBManager* pDBManager = CDBManager::getInstance();
    CDBConn* pDBConn = pDBManager->GetDBConn("teamtalk_master");
    if (pDBConn)
    {
        string strSql = "update IMRelationShip set `updated`="+int2string(nUpdateTime) + " where id="+int2string(nRelationId);
        bRet = pDBConn->ExecuteUpdate(strSql.c_str());
        pDBManager->RelDBConn(pDBConn);
    }
    else
    {
        log("no db connection for teamtalk_master");
    }
    return bRet;
}

//好像没有使用
bool CRelationModel::removeRelation(uint32_t nRelationId)
{
    bool bRet = false;
    CDBManager* pDBManager = CDBManager::getInstance();
    CDBConn* pDBConn = pDBManager->GetDBConn("teamtalk_master");
    if (pDBConn)
    {
        uint32_t nNow = (uint32_t) time(NULL);
        string strSql = "update IMRelationShip set status = 1, updated="+int2string(nNow)+" where id=" + int2string(nRelationId);
        bRet = pDBConn->ExecuteUpdate(strSql.c_str());
        pDBManager->RelDBConn(pDBConn);
    }
    else
    {
        log("no db connection for teamtalk_master");
    }
    return bRet;
}

bool CRelationModel::delFriend(uint32_t nUserId, uint32_t nFriendId)
{
	bool bRet = false;
	uint32_t nBigId = nUserId > nFriendId ? nUserId : nFriendId;
	uint32_t nSmallId = nUserId > nFriendId ? nFriendId : nUserId;

	CDBManager* pDBManager = CDBManager::getInstance();
	CDBConn* pDBConn = pDBManager->GetDBConn("teamtalk_master");
	if (pDBConn)
	{
		uint32_t nNow = (uint32_t) time(NULL);
		string strSql = "delete from IMRelationShip where smallId=" + int2string(nSmallId) +
				" and bigId=" + int2string(nBigId) + " and status=" + int2string(RELATION_TYPE_FRIEND);
		bRet = pDBConn->ExecuteDelete(strSql.c_str());
		pDBManager->RelDBConn(pDBConn);
	}
	else
	{
		log("no db connection for teamtalk_master");
	}
	return bRet;

}

bool CRelationModel::delFollowUser(uint32_t nUserId, uint32_t nFriendId)
{
	bool bRet = false;

	CDBManager* pDBManager = CDBManager::getInstance();
	CDBConn* pDBConn = pDBManager->GetDBConn("teamtalk_master");
	if (pDBConn)
	{
		uint32_t nNow = (uint32_t) time(NULL);
		string strSql = "delete from IMRelationShip where (bigId=" + int2string(nFriendId) +
				+ " and smallId=" + int2string(nUserId) + " and status=" + int2string(RELATION_TYPE_FOLLOW_BIG) +
				") or (smallId=" + int2string(nFriendId) + " and bigId=" + int2string(nUserId) +
				" and status=" + int2string(RELATION_TYPE_FOLLOW_SMALL) + ")";

		bRet = pDBConn->ExecuteUpdate(strSql.c_str());
		pDBManager->RelDBConn(pDBConn);

		bRet = true;
		//log("%s", strSql.c_str());
	}
	else
	{
		log("no db connection for teamtalk_master");
	}
	return bRet;

}

