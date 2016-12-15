/*================================================================
 *     Copyright (c) 2014年 lanhu. All rights reserved.
 *
 *   文件名称：HandlerMap.cpp
 *   创 建 者：Zhang Yuanhao
 *   邮    箱：bluefoxah@gmail.com
 *   创建日期：2014年12月02日
 *   描    述：
 *
 ================================================================*/

#include "HandlerMap.h"

#include "business/Login.h"
#include "business/MessageContent.h"
#include "business/RecentSession.h"
#include "business/UserAction.h"
#include "business/MessageCounter.h"
#include "business/GroupAction.h"
#include "business/DepartAction.h"
#include "business/FileAction.h"
#include "business/Register.h"
#include "business/BlogContent.h"
#include "IM.BaseDefine.pb.h"

using namespace IM::BaseDefine;


CHandlerMap* CHandlerMap::s_handler_instance = NULL;

/**
 *  构造函数
 */
CHandlerMap::CHandlerMap()
{

}

/**
 *  析构函数
 */
CHandlerMap::~CHandlerMap()
{

}

/**
 *  单例
 *
 *  @return 返回指向CHandlerMap的单例指针
 */
CHandlerMap* CHandlerMap::getInstance()
{
	if (!s_handler_instance) {
		s_handler_instance = new CHandlerMap();
		s_handler_instance->Init();
	}

	return s_handler_instance;
}

/**
 *  初始化函数,加载了各种commandId 对应的处理函数
 */
void CHandlerMap::Init()
{
	m_handler_map.insert(make_pair(uint32_t(CID_OTHER_REGISTER_REQ), DB_PROXY::doRegister));

	// Login validate
	m_handler_map.insert(make_pair(uint32_t(CID_OTHER_VALIDATE_REQ), DB_PROXY::doLogin));
    m_handler_map.insert(make_pair(uint32_t(CID_LOGIN_REQ_PUSH_SHIELD), DB_PROXY::doPushShield));
    m_handler_map.insert(make_pair(uint32_t(CID_LOGIN_REQ_QUERY_PUSH_SHIELD), DB_PROXY::doQueryPushShield));
    
    // recent session
    m_handler_map.insert(make_pair(uint32_t(CID_BUDDY_LIST_RECENT_CONTACT_SESSION_REQUEST), DB_PROXY::getRecentSession));
    m_handler_map.insert(make_pair(uint32_t(CID_BUDDY_LIST_REMOVE_SESSION_REQ), DB_PROXY::deleteRecentSession));
    
    // users
    m_handler_map.insert(make_pair(uint32_t(CID_BUDDY_LIST_USER_INFO_REQUEST), DB_PROXY::getUserInfo));
    m_handler_map.insert(make_pair(uint32_t(CID_BUDDY_LIST_ALL_USER_REQUEST), DB_PROXY::getChangedUser));
    m_handler_map.insert(make_pair(uint32_t(CID_BUDDY_LIST_DEPARTMENT_REQUEST), DB_PROXY::getChgedDepart));
    m_handler_map.insert(make_pair(uint32_t(CID_BUDDY_LIST_CHANGE_SIGN_INFO_REQUEST), DB_PROXY::changeUserSignInfo));
    m_handler_map.insert(make_pair(uint32_t(CID_BUDDY_LIST_SEARCH_USER_REQUEST), DB_PROXY::searchUser));
    m_handler_map.insert(make_pair(uint32_t(CID_BUDDY_LIST_ADD_FRIEND_REQUEST), DB_PROXY::addFriend));
    m_handler_map.insert(make_pair(uint32_t(CID_BUDDY_LIST_AGREE_ADD_FRIEND_REQUEST), DB_PROXY::agreeAddFriend));
    m_handler_map.insert(make_pair(uint32_t(CID_BUDDY_LIST_DEL_FRIEND_REQUEST), DB_PROXY::delFriend));
    m_handler_map.insert(make_pair(uint32_t(CID_BUDDY_LIST_FOLLOW_USER_REQUEST), DB_PROXY::followUser));
    m_handler_map.insert(make_pair(uint32_t(CID_BUDDY_LIST_DEL_FOLLOW_USER_REQUEST), DB_PROXY::delFollowUser));
    m_handler_map.insert(make_pair(uint32_t(CID_BUDDY_LIST_CHANGE_AVATAR_REQUEST), DB_PROXY::changeAvatar));
    m_handler_map.insert(make_pair(uint32_t(CID_BUDDY_LIST_UPDATE_USER_INFO_REQUEST), DB_PROXY::updateUserInfo));
    
    m_handler_map.insert(make_pair(uint32_t(CID_BUDDY_LIST_GET_ADD_FRIEND_DATA_REQUEST), DB_PROXY::getUnreadAddFriendData));

    // message content
    m_handler_map.insert(make_pair(uint32_t(CID_MSG_DATA), DB_PROXY::sendMessage));
    m_handler_map.insert(make_pair(uint32_t(CID_MSG_LIST_REQUEST), DB_PROXY::getMessage));
    m_handler_map.insert(make_pair(uint32_t(CID_MSG_UNREAD_CNT_REQUEST), DB_PROXY::getUnreadMsgCounter));
    m_handler_map.insert(make_pair(uint32_t(CID_MSG_READ_ACK), DB_PROXY::clearUnreadMsgCounter));
    m_handler_map.insert(make_pair(uint32_t(CID_MSG_GET_BY_MSG_ID_REQ), DB_PROXY::getMessageById));
    m_handler_map.insert(make_pair(uint32_t(CID_MSG_GET_LATEST_MSG_ID_REQ), DB_PROXY::getLatestMsgId));

    m_handler_map.insert(make_pair(uint32_t(CID_BUDDY_LIST_ADD_FRIEND_UNREAD_CNT_REQUEST), DB_PROXY::getUnreadAddFriendMsgCounter));
    m_handler_map.insert(make_pair(uint32_t(CID_BUDDY_LIST_ADD_FRIEND_READ_DATA_ACK), DB_PROXY::clearAddFriendMsgCounter));

    //blog content
    m_handler_map.insert(make_pair(uint32_t(CID_BLOG_SEND), DB_PROXY::sendBlog));
    m_handler_map.insert(make_pair(uint32_t(CID_BLOG_GET_LIST_REQUEST), DB_PROXY::getBlog));
    m_handler_map.insert(make_pair(uint32_t(CID_BLOG_ADD_COMMENT_REQUEST), DB_PROXY::addBlogComment));
    m_handler_map.insert(make_pair(uint32_t(CID_BLOG_GET_COMMENT_REQUEST), DB_PROXY::getBlogComment));
    
    // device token
    m_handler_map.insert(make_pair(uint32_t(CID_LOGIN_REQ_DEVICETOKEN), DB_PROXY::setDevicesToken));
    m_handler_map.insert(make_pair(uint32_t(CID_OTHER_GET_DEVICE_TOKEN_REQ), DB_PROXY::getDevicesToken));
    
    //push 推送设置
    m_handler_map.insert(make_pair(uint32_t(CID_GROUP_SHIELD_GROUP_REQUEST), DB_PROXY::setGroupPush));
    m_handler_map.insert(make_pair(uint32_t(CID_OTHER_GET_SHIELD_REQ), DB_PROXY::getGroupPush));
    
    
    // group
    m_handler_map.insert(make_pair(uint32_t(CID_GROUP_NORMAL_LIST_REQUEST), DB_PROXY::getNormalGroupList));
    m_handler_map.insert(make_pair(uint32_t(CID_GROUP_INFO_REQUEST), DB_PROXY::getGroupInfo));
    m_handler_map.insert(make_pair(uint32_t(CID_GROUP_CREATE_REQUEST), DB_PROXY::createGroup));
    m_handler_map.insert(make_pair(uint32_t(CID_GROUP_CHANGE_MEMBER_REQUEST), DB_PROXY::modifyMember));

    
    // file
    m_handler_map.insert(make_pair(uint32_t(CID_FILE_HAS_OFFLINE_REQ), DB_PROXY::hasOfflineFile));
    m_handler_map.insert(make_pair(uint32_t(CID_FILE_ADD_OFFLINE_REQ), DB_PROXY::addOfflineFile));
    m_handler_map.insert(make_pair(uint32_t(CID_FILE_DEL_OFFLINE_REQ), DB_PROXY::delOfflineFile));

}

/**
 *  通过commandId获取处理函数
 *
 *  @param pdu_type commandId
 *
 *  @return 处理函数的函数指针
 */
pdu_handler_t CHandlerMap::GetHandler(uint32_t pdu_type)
{
	HandlerMap_t::iterator it = m_handler_map.find(pdu_type);
	if (it != m_handler_map.end()) {
		return it->second;
	} else {
		return NULL;
	}
}


