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

#ifndef BLOG_MODEL_H_
#define BLOG_MODEL_H_

#include <list>
#include <string>

#include "util.h"
#include "ImPduBase.h"
#include "IM.BaseDefine.pb.h"
#include "IM.Blog.pb.h"
using namespace std;

class CBlogModel {
public:
	virtual ~CBlogModel();
	static CBlogModel* getInstance();

    uint32_t sendBlog(uint32_t nFromId, uint32_t nCreateTime, uint32_t nMsgId, string& strMsgContent);
    void getBlog(uint32_t nUserId, uint32_t update_time, IM::BaseDefine::BlogType type,
    		uint32_t page, uint32_t page_size, IM::Blog::IMBlogGetListRsp& resp);
    uint32_t addBlogComment(uint32_t nUserId, uint32_t nBlogId, uint32_t nCreateTime, string& strMsgContent);
    void getBlogComment(uint32_t nBlogId, uint32_t update_time, IM::Blog::IMBlogGetCommentRsp& resp);
private:
	CBlogModel();
private:
	static CBlogModel*	m_pInstance;
};



#endif /* MESSAGE_MODEL_H_ */
