/*================================================================
 *   Copyright (C) 2014 All rights reserved.
 *
 *   文件名称：MessageContent.cpp
 *   创 建 者：Zhang Yuanhao
 *   邮    箱：bluefoxah@gmail.com
 *   创建日期：2014年12月15日
 *   描    述：
 *
 ================================================================*/

#include "../ProxyConn.h"
#include "../CachePool.h"
#include "../DBPool.h"
#include "ImPduBase.h"
#include "IM.Blog.pb.h"
#include "BlogModel.h"


namespace DB_PROXY {

    void sendBlog(CImPdu* pPdu, uint32_t conn_uuid)
	{
		IM::Blog::IMBlogSend blog;
		IM::Blog::IMBlogSendAck blogResp;
		if(!blog.ParseFromArray(pPdu->GetBodyData(), pPdu->GetBodyLength()))
		{
			log("parse pb failed");
			return;
		}

		uint32_t nUserId = blog.user_id();
		uint32_t nMsgLen = blog.blog_data().length();

		uint32_t nNow = (uint32_t)time(NULL);

		if(nMsgLen == 0)
		{
			return;
		}

		CImPdu* pPduResp = new CImPdu;

		CBlogModel* pBlogModel = CBlogModel::getInstance();

		uint32_t blog_id = pBlogModel->sendBlog(nUserId, nNow, 0, (string&)blog.blog_data());

		log("db send blog");

		blogResp.set_user_id(nUserId);
		blogResp.set_blog_id(blog_id);
		blogResp.set_update_time(nNow);
		blogResp.set_attach_data(blog.attach_data());
		pPduResp->SetPBMsg(&blogResp);
		pPduResp->SetSeqNum(pPdu->GetSeqNum());
		pPduResp->SetServiceId(IM::BaseDefine::SID_BLOG);
		pPduResp->SetCommandId(IM::BaseDefine::CID_BLOG_SEND_ACK);
		CProxyConn::AddResponsePdu(conn_uuid, pPduResp);

	}

    void getBlog(CImPdu* pPdu, uint32_t conn_uuid)
    {
        IM::Blog::IMBlogGetListReq blog;
        if(blog.ParseFromArray(pPdu->GetBodyData(), pPdu->GetBodyLength()))
        {
			uint32_t nUserId = blog.user_id();
			uint32_t nUpdateTime = blog.update_time();
			uint32_t nPage = blog.page();
			uint32_t nPageSize = blog.page_size();
			IM::BaseDefine::BlogType nType(blog.blog_type());

			CImPdu* pPduResp = new CImPdu;
			IM::Blog::IMBlogGetListRsp blogResp;

			blogResp.set_user_id(nUserId);
			blogResp.set_blog_type(nType);
			blogResp.set_page(nPage);
			blogResp.set_page_size(nPageSize);
			CBlogModel::getInstance()->getBlog(nUserId, nUpdateTime, nType, nPage, nPageSize, blogResp);

			log("userid %d get blog list size %d",nUserId,blogResp.blog_list_size());

			blogResp.set_attach_data(blog.attach_data());
			pPduResp->SetPBMsg(&blogResp);
			pPduResp->SetSeqNum(pPdu->GetSeqNum());
			pPduResp->SetServiceId(IM::BaseDefine::SID_BLOG);
			pPduResp->SetCommandId(IM::BaseDefine::CID_BLOG_GET_LIST_RESPONSE);
			CProxyConn::AddResponsePdu(conn_uuid, pPduResp);

		}
		else
		{
			log("parse pb failed");
		}
	}

    void addBlogComment(CImPdu* pPdu, uint32_t conn_uuid)
    {
    	IM::Blog::IMBlogAddCommentReq blog;
    	IM::Blog::IMBlogAddCommentRsp blogResp;
		if(!blog.ParseFromArray(pPdu->GetBodyData(), pPdu->GetBodyLength()))
		{
			log("parse pb failed");
			return;
		}

		uint32_t nUserId = blog.user_id();
		uint32_t nBlogId = blog.blog_id();
		uint32_t nBlogLen = blog.blog_data().length();
		uint32_t nNow = (uint32_t)time(NULL);

		if(nBlogLen == 0)
		{
			return;
		}

		CImPdu* pPduResp = new CImPdu;

		CBlogModel* pBlogModel = CBlogModel::getInstance();

		uint32_t comment_id = pBlogModel->addBlogComment(nUserId, nBlogId, nNow, (string&)blog.blog_data());

		blogResp.set_user_id(nUserId);
		blogResp.set_comment_id(comment_id);
		blogResp.set_update_time(nNow);
		blogResp.set_result_code(0);
		blogResp.set_attach_data(blog.attach_data());
		pPduResp->SetPBMsg(&blogResp);
		pPduResp->SetSeqNum(pPdu->GetSeqNum());
		pPduResp->SetServiceId(IM::BaseDefine::SID_BLOG);
		pPduResp->SetCommandId(IM::BaseDefine::CID_BLOG_ADD_COMMENT_RESPONSE);
		CProxyConn::AddResponsePdu(conn_uuid, pPduResp);
    }

    void getBlogComment(CImPdu* pPdu, uint32_t conn_uuid)
	{
		IM::Blog::IMBlogGetCommentReq blog;
		IM::Blog::IMBlogGetCommentRsp blogResp;
		if(blog.ParseFromArray(pPdu->GetBodyData(), pPdu->GetBodyLength()))
		{
			uint32_t nUserId = blog.user_id();
			uint32_t nBlogId = blog.blog_id();
			uint32_t nUpdateTime = blog.update_time();

			CImPdu* pPduResp = new CImPdu;

			//有问题，先注掉
			CBlogModel::getInstance()->getBlogComment(nBlogId, nUpdateTime, blogResp);

			blogResp.set_user_id(nUserId);
			blogResp.set_blog_id(nBlogId);
			blogResp.set_update_time(nUpdateTime);
			blogResp.set_attach_data(blog.attach_data());
			pPduResp->SetPBMsg(&blogResp);
			pPduResp->SetSeqNum(pPdu->GetSeqNum());
			pPduResp->SetServiceId(IM::BaseDefine::SID_BLOG);
			pPduResp->SetCommandId(IM::BaseDefine::CID_BLOG_GET_COMMENT_RESPONSE);
			CProxyConn::AddResponsePdu(conn_uuid, pPduResp);

		}
		else
		{
			log("parse pb failed");
		}
	}
	
};
