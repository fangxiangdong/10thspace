/*================================================================
 *   Copyright (C) 2014 All rights reserved.
 *
 *   文件名称：MessageContent.h
 *   创 建 者：Zhang Yuanhao
 *   邮    箱：bluefoxah@gmail.com
 *   创建日期：2014年12月15日
 *   描    述：
 *
 ================================================================*/

#ifndef BLOGCONTENT_H_
#define BLOGCONTENT_H_

#include "ImPduBase.h"

namespace DB_PROXY {

    void sendBlog(CImPdu* pPdu, uint32_t conn_uuid);

    void getBlog(CImPdu* pPdu, uint32_t conn_uuid);

    void addBlogComment(CImPdu* pPdu, uint32_t conn_uuid);

    void getBlogComment(CImPdu* pPdu, uint32_t conn_uuid);
};

#endif /* MESSAGECOUTENT_H_ */
