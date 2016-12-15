
#include <list>
#include "../ProxyConn.h"
#include "../HttpClient.h"
#include "../SyncCenter.h"
#include "UserModel.h"
#include "TokenValidator.h"
#include "json/json.h"
#include "Common.h"
#include "IM.Register.pb.h"
#include "Base64.h"
#include "Register.h"
#include "DBPool.h"


namespace DB_PROXY {
    
void doRegister(CImPdu* pPdu, uint32_t conn_uuid)
{
    CImPdu* pPduResp = new CImPdu;

    int iRet = 0;
    IM::Register::IMRegisterReq msg;
    IM::Register::IMRegisterRsp msgResp;
    if(msg.ParseFromArray(pPdu->GetBodyData(), pPdu->GetBodyLength()))
    {
        string strName = msg.user_name();
        string strPass = msg.password();

        //msgResp.set_user_name(strName);
        msgResp.set_attach_data(msg.attach_data());

        iRet = CUserModel::getInstance()->insertUser2(strName, strPass);

		if (iRet == 0)
		{
			msgResp.set_result_code((IM::BaseDefine::ResultType)0);
		}
		else
		{
			log("register failed: %s", strName.c_str());
			msgResp.set_result_code((IM::BaseDefine::ResultType)1);
		}
    }
    else
    {
        msgResp.set_result_code((IM::BaseDefine::ResultType)2);
        msgResp.set_result_string("服务端内部错误");
    }

    pPduResp->SetPBMsg(&msgResp);
    pPduResp->SetSeqNum(pPdu->GetSeqNum());
    pPduResp->SetServiceId(IM::BaseDefine::SID_OTHER);
    pPduResp->SetCommandId(IM::BaseDefine::CID_OTHER_REGISTER_RSP);
    CProxyConn::AddResponsePdu(conn_uuid, pPduResp);
}

};

