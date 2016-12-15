
#include "PushConn2.h"
#include "netlib.h"
#include "ConfigFileReader.h"
#include "version.h"

IpParser* pIpParser = NULL;
string strMsfsUrl;
string strDiscovery;//发现获取地址

void pushserver2_callback(void* callback_data, uint8_t msg, uint32_t handle, void* pParam)
{
	if (msg == NETLIB_MSG_CONNECT)
	{
		CPush2Conn* pConn = new CLoginConn();
		pConn->OnConnect(handle, LOGIN_CONN_TYPE_CLIENT);
	}
	else
	{
		log("!!!error msg: %d ", msg);
	}
}

int main(int argc, char* argv[])
{
	if ((argc == 2) && (strcmp(argv[1], "-v") == 0)) {
		printf("Server Version: PushServer2/%s\n", VERSION);
		printf("Server Build: %s %s\n", __DATE__, __TIME__);
		return 0;
	}

	signal(SIGPIPE, SIG_IGN);

	CConfigFileReader config_file("pushserver2.conf");

    char* pushserver2_listen_ip = config_file.GetConfigName("PushServer2ListenIP");
    char* str_pushserver2_port = config_file.GetConfigName("PushServer2Port");

	if (!pushserver2_listen_ip || !str_pushserver2_port) {
		log("config item missing, exit... ");
		return -1;
	}

	uint16_t pushserver2_port = atoi(str_pushserver2_port);
    
    pIpParser = new IpParser();
    
	int ret = netlib_init();

	if (ret == NETLIB_ERROR)
		return ret;
	CStrExplode pushserver2_listen_ip_list(pushserver2_listen_ip, ';');
	for (uint32_t i = 0; i < pushserver2_listen_ip_list.GetItemCnt(); i++) {
		ret = netlib_listen(client_listen_ip_list.GetItem(i), pushserver2_port,
				pushserver2_callback, NULL);
		if (ret == NETLIB_ERROR)
			return ret;
	}

	//init_push_conn2();

	printf("now enter the event loop...\n");
    
    writePid();

	netlib_eventloop();

	return 0;
}
