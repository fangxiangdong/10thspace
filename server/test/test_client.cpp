/*================================================================
 *   Copyright (C) 2014 All rights reserved.
 *
 *   文件名称：test_client.cpp
 *   创 建 者：Zhang Yuanhao
 *   邮    箱：bluefoxah@gmail.com
 *   创建日期：2014年12月30日
 *   描    述：
 *
 ================================================================*/

#include <vector>
#include <iostream>
#include "ClientConn.h"
#include "netlib.h"
#include "TokenValidator.h"
#include "Thread.h"
#include "IM.BaseDefine.pb.h"
#include "IM.Buddy.pb.h"
#include "playsound.h"
#include "Common.h"
#include "Client.h"
#include "EncDec.h"
#include "aliyun_oss.h"
using namespace std;

#define MAX_LINE_LEN	1024
//string g_login_domain = "http://access.tt.mogujie.org";
string g_login_domain = "http://www.d10gs.com:84/msg_server.php";
string g_cmd_string[10];
int g_cmd_num;
CClient* g_pClient = NULL;
void split_cmd(char* buf)
{
	int len = strlen(buf);
	string element;

	g_cmd_num = 0;
	for (int i = 0; i < len; i++) {
		if (buf[i] == ' ' || buf[i] == '\t') {
			if (!element.empty()) {
				g_cmd_string[g_cmd_num++] = element;
				element.clear();
			}
		} else {
			element += buf[i];
		}
	}

	// put the last one
	if (!element.empty()) {
		g_cmd_string[g_cmd_num++] = element;
	}
}

void print_help()
{
	printf("Usage:\n");
    printf("login user_name user_pass\n");
    /*
	printf("connect serv_ip serv_port user_name user_pass\n");
    printf("getuserinfo\n");
    printf("send toId msg\n");
    printf("unreadcnt\n");
     */
	printf("close\n");
	printf("quit\n");
}

void doLogin(const string& strName, const string& strPass)
{
    try
    {
        g_pClient = new CClient(strName, strPass, g_login_domain);
    }
    catch(...)
    {
        printf("get error while alloc memory\n");
        PROMPTION;
        return;
    }
    g_pClient->connect();
}
void exec_cmd()
{
	if (g_cmd_num == 0) {
		return;
	}
    
    if(g_cmd_string[0] == "login")
    {
        if(g_cmd_num == 3)
        {
            char szMd5[33];
            CMd5::MD5_Calculate(g_cmd_string[2].c_str(), g_cmd_string[2].length(), szMd5);
            doLogin(g_cmd_string[1], szMd5);
        }
        else
        {
            print_help();
        }
    }
    else if (strcmp(g_cmd_string[0].c_str(), "close") == 0) {
        g_pClient->close();
    }
    else if (strcmp(g_cmd_string[0].c_str(), "quit") == 0) {
		exit(0);

    }
    else if(strcmp(g_cmd_string[0].c_str(), "list") == 0)
    {
        printf("+---------------------+\n");
        printf("|        用户名        |\n");
        printf("+---------------------+\n");
        g_pClient->getChangedUser();
        
        CMapNick2User_t mapUser = g_pClient->getNick2UserMap();
        auto it = mapUser.begin();
        for(;it!=mapUser.end();++it)
        {
            uint32_t nLen = 21 - it->first.length();
            printf("|");
            for(uint32_t i=0; i<nLen/2; ++it)
            {
                printf(" ");
            }
            printf("%s", it->first.c_str());
            for(uint32_t i=0; i<nLen/2; ++it)
            {
                printf(" ");
            }
            printf("|\n");
            printf("+---------------------+\n");
        }

    }else if(strcmp(g_cmd_string[0].c_str(), "send") == 0){
        printf("send %s\n",g_cmd_string[2].c_str());
        g_pClient->sendMsg(atoi(g_cmd_string[1].c_str()),IM::BaseDefine::MSG_TYPE_SINGLE_TEXT,g_cmd_string[2]);

    }else if (strcmp(g_cmd_string[0].c_str(), "suo") == 0) {
    	printf("suo %s\n",g_cmd_string[1].c_str());
    	g_pClient->sendBlog(g_cmd_string[1]);

    }else if (strcmp(g_cmd_string[0].c_str(), "blog") == 0) {
    	printf("get blog\n");
    	g_pClient->getBlog();

    }else if (strcmp(g_cmd_string[0].c_str(), "find") == 0) {
    	printf("find friend %s\n",g_cmd_string[1].c_str());
    	g_pClient->findFriend(g_cmd_string[1]);

    	CMapNick2User_t mapUser = g_pClient->getNick2UserMap();
		auto it = mapUser.begin();
		for(;it!=mapUser.end();++it)
		{
			uint32_t nLen = 21 - it->first.length();
			printf("|");
			for(uint32_t i=0; i<nLen/2; ++it)
			{
				printf(" ");
			}
			printf("%s", it->first.c_str());
			for(uint32_t i=0; i<nLen/2; ++it)
			{
				printf(" ");
			}
			printf("|\n");
			printf("+---------------------+\n");
		}

    }else if (strcmp(g_cmd_string[0].c_str(), "add") == 0) {
    	printf("add friend %s\n",g_cmd_string[1].c_str());
    	g_pClient->addFriend(atoi(g_cmd_string[1].c_str()));

    }else if (strcmp(g_cmd_string[0].c_str(), "follow") == 0) {
		printf("follow friend %s\n",g_cmd_string[1].c_str());
		g_pClient->followUser(atoi(g_cmd_string[1].c_str()));

    }else if (strcmp(g_cmd_string[0].c_str(), "online") == 0) {
		printf("online users count %s\n");
		g_pClient->online_cnt();

    }else {
	    print_help();
    }
}


class CmdThread : public CThread
{
public:
	void OnThreadRun()
	{
		while (true)
		{
			fprintf(stderr, "%s", PROMPT);	// print to error will not buffer the printed message

			if (fgets(m_buf, MAX_LINE_LEN - 1, stdin) == NULL)
			{
				fprintf(stderr, "fgets failed: %d\n", errno);
				continue;
			}

			m_buf[strlen(m_buf) - 1] = '\0';	// remove newline character

			split_cmd(m_buf);

			exec_cmd();
		}
	}
private:
	char	m_buf[MAX_LINE_LEN];
};

CmdThread g_cmd_thread;

static std::list<uint32_t> ls;

void testlist()
{
	int x = 3;
	ls.push_back(x);
}

int main(int argc, char* argv[])
{
	CAliyunOss* pAliyunOss = CAliyunOss::getInstance();
	pAliyunOss->put_object_from_buffer("IM/avatar/1.png", INTERNAL);

	return 0;

//    play("message.wav");
	g_cmd_thread.StartThread();

	signal(SIGPIPE, SIG_IGN);

	int ret = netlib_init();

	if (ret == NETLIB_ERROR)
		return ret;
    
	netlib_eventloop();

	return 0;
}
