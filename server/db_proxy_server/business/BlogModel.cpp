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
#include "BlogModel.h"
#include "AudioModel.h"

using namespace std;

CBlogModel* CBlogModel::m_pInstance = NULL;
extern string strAudioEnc;

CBlogModel::CBlogModel()
{

}

CBlogModel::~CBlogModel()
{

}

CBlogModel* CBlogModel::getInstance()
{
	if (!m_pInstance) {
		m_pInstance = new CBlogModel();
	}

	return m_pInstance;
}


uint32_t CBlogModel::sendBlog(uint32_t nFromId, uint32_t nCreateTime, uint32_t nMsgId, string& strMsgContent)
{
    bool bRet = false;
    uint32_t blog_id = 0;

	CDBManager* pDBManager = CDBManager::getInstance();
	CDBConn* pDBConn = pDBManager->GetDBConn("teamtalk_master");
	if (pDBConn)
    {
        //string strTableName = "IMMessage_" + int2string(nRelateId % 8);
        string strSql = "insert into IMBlog_0 ( `fromId`, `msgId`, `content`, `type`, `created`, `updated`) values(?, ?, ?, ?, ?, ?)";
        // 必须在释放连接前delete CPrepareStatement对象，否则有可能多个线程操作mysql对象，会crash
        CPrepareStatement* pStmt = new CPrepareStatement();
        if (pStmt->Init(pDBConn->GetMysql(), strSql))
        {
            uint32_t index = 0;
            uint32_t type = IM::BaseDefine::BLOG_TYPE2_BLOG;
            pStmt->SetParam(index++, nFromId);
            pStmt->SetParam(index++, nMsgId);
            pStmt->SetParam(index++, strMsgContent);
            pStmt->SetParam(index++, type);
            pStmt->SetParam(index++, nCreateTime);
            pStmt->SetParam(index++, nCreateTime);
            bRet = pStmt->ExecuteUpdate();
            blog_id = pStmt->GetInsertId();
        }
        delete pStmt;
        pDBManager->RelDBConn(pDBConn);
        if (bRet)
        {
        	//添加为unread
            //uint32_t nNow = (uint32_t) time(NULL);
            //incMsgCount(nFromId, nToId);
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
	return blog_id;
}

//page从0开始
void CBlogModel::getBlog(uint32_t nUserId, uint32_t update_time, IM::BaseDefine::BlogType type,
		uint32_t page, uint32_t page_size, IM::Blog::IMBlogGetListRsp& resp)
{
	CDBManager* pDBManager = CDBManager::getInstance();
	CDBConn* pDBConn = pDBManager->GetDBConn("teamtalk_slave");
	if (pDBConn)
	{
		string strTableName = "IMBlog_0"; //"IMMessage_" + int2string(nUserId % 8);

		string strSql;
		if(type == IM::BaseDefine::BLOG_TYPE_RCOMMEND){
			strSql = "select IMBlog_0.*,nick,avatar from IMBlog_0,IMUser where fromId=IMUser.id and type=" +
				int2string(IM::BaseDefine::BLOG_TYPE2_BLOG) + " order by IMBlog_0.updated desc limit "+
				int2string(page*page_size)+","+int2string(page_size);

		}else if(type == IM::BaseDefine::BLOG_TYPE_FRIEND){
			strSql = "select IMBlog_0.*,nick,avatar from IMBlog_0,IMUser where fromId=IMUser.id and type=" +
				int2string(IM::BaseDefine::BLOG_TYPE2_BLOG) + " and (fromId=" +
				int2string(nUserId) + " or fromId in (select smallId+bigId-" + int2string(nUserId) +
				" from IMRelationShip where status=" + int2string(RELATION_TYPE_FRIEND) +
				" and (smallId=" + int2string(nUserId) + " or bigId=" + int2string(nUserId) +
				"))) order by IMBlog_0.updated desc limit "+
				int2string(page*page_size)+","+int2string(page_size);

		}else if(type == IM::BaseDefine::BLOG_TYPE_FOLLOWUSER){
			strSql = "select IMBlog_0.*,nick,avatar from IMBlog_0,IMUser where fromId=IMUser.id and type=" +
				int2string(IM::BaseDefine::BLOG_TYPE2_BLOG) + " and fromId in (select smallId+bigId-" + int2string(nUserId) +
				" from IMRelationShip where status<>" + int2string(RELATION_TYPE_FRIEND) +
				" and (smallId=" + int2string(nUserId) + " or bigId=" + int2string(nUserId) +
				")) order by IMBlog_0.updated desc limit "+
				int2string(page*page_size)+","+int2string(page_size);

			//".updated>"+ int2string(update_time)
		}

		CResultSet* pResultSet = pDBConn->ExecuteQuery(strSql.c_str());
		if (pResultSet)
		{
			while (pResultSet->Next())
			{
				IM::BaseDefine::BlogInfo* pBlog = resp.add_blog_list();
				pBlog->set_blog_id(pResultSet->GetInt("id"));
				pBlog->set_writer_user_id(pResultSet->GetInt("fromId"));
				pBlog->set_create_time(pResultSet->GetInt("created"));
				pBlog->set_nick_name(pResultSet->GetString("nick"));
				pBlog->set_avatar_url(pResultSet->GetString("avatar"));
				pBlog->set_like_cnt(pResultSet->GetInt("lick_count"));
				pBlog->set_comment_cnt(pResultSet->GetInt("comment_count"));
				pBlog->set_blog_data(pResultSet->GetString("content"));
			}
			delete pResultSet;
		}
		else
		{
			log("no result set: %s", strSql.c_str());
		}

		//以后增加语音说说
		/*if (!lsMsg.empty())
		{
			CAudioModel::getInstance()->readAudios(lsMsg);
		}*/

		pDBManager->RelDBConn(pDBConn);
	}
	else
	{
		log("no db connection for teamtalk_slave");
	}

}

void CBlogModel::getBlogComment(uint32_t nBlogId, uint32_t update_time, IM::Blog::IMBlogGetCommentRsp& resp)
{
	CDBManager* pDBManager = CDBManager::getInstance();
	CDBConn* pDBConn = pDBManager->GetDBConn("teamtalk_slave");
	if (pDBConn)
	{
		string strTableName = "IMBlog_0";//"IMMessage_" + int2string(nRelateId % 8);

		// relationship's status 0:好友  1:小的关注大的  2:大的关注小的  3:相互关注
		string strSql = "select "+ strTableName + ".*,nick,avatar from " + strTableName +
				",IMUser where fromId=IMUser.id and msgId=" + int2string(nBlogId) + " and type=" +
				int2string(IM::BaseDefine::BLOG_TYPE2_COMMENT);
		//" and updated>"+ int2string(update_time);

		CResultSet* pResultSet = pDBConn->ExecuteQuery(strSql.c_str());
		if (pResultSet)
		{
			while (pResultSet->Next())
			{
				IM::BaseDefine::BlogInfo* pComment = resp.add_comment_list();
				pComment->set_blog_id(pResultSet->GetInt("id"));
				pComment->set_writer_user_id(pResultSet->GetInt("fromId"));
				pComment->set_create_time(pResultSet->GetInt("created"));
				pComment->set_nick_name(pResultSet->GetString("nick"));
				pComment->set_avatar_url(pResultSet->GetString("avatar"));
				pComment->set_like_cnt(pResultSet->GetInt("lick_count"));
				pComment->set_comment_cnt(pResultSet->GetInt("comment_count"));
				pComment->set_blog_data(pResultSet->GetString("content"));
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

uint32_t CBlogModel::addBlogComment(uint32_t nUserId, uint32_t nBlogId, uint32_t nCreateTime, string& strMsgContent)
{
    bool bRet = false;
    uint32_t comment_id = 0;

	CDBManager* pDBManager = CDBManager::getInstance();
	CDBConn* pDBConn = pDBManager->GetDBConn("teamtalk_master");
	if (pDBConn)
    {
        //string strTableName = "IMMessage_" + int2string(nRelateId % 8);
        string strSql = "insert into IMBlog_0 ( `fromId`, `msgId`, `content`, `type`, `created`, `updated`) values(?, ?, ?, ?, ?, ?)";
        // 必须在释放连接前delete CPrepareStatement对象，否则有可能多个线程操作mysql对象，会crash
        CPrepareStatement* pStmt = new CPrepareStatement();
        if (pStmt->Init(pDBConn->GetMysql(), strSql))
        {
            uint32_t index = 0;
            uint32_t type = IM::BaseDefine::BLOG_TYPE2_COMMENT;
            pStmt->SetParam(index++, nUserId);
            pStmt->SetParam(index++, nBlogId);
            pStmt->SetParam(index++, strMsgContent);
            pStmt->SetParam(index++, type);
            pStmt->SetParam(index++, nCreateTime);
            pStmt->SetParam(index++, nCreateTime);
            bRet = pStmt->ExecuteUpdate();
            comment_id = pStmt->GetInsertId();
        }
        delete pStmt;

        strSql = "update IMBlog_0 set `comment_count`=comment_count+1 where msgId="+int2string(nBlogId);
        bRet = pDBConn->ExecuteUpdate(strSql.c_str());

        pDBManager->RelDBConn(pDBConn);
	}
    else
    {
        log("no db connection for teamtalk_master");
    }
	return comment_id;
}
